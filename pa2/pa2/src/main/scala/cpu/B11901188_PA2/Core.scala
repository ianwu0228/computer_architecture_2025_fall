package cpu

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation

// io for testbench to access
class Core_io extends Bundle {
    // for debugging
    val pc = Output(UInt(32.W))
    val inst = Output(UInt(32.W))
    val wb_result = Output(UInt(32.W))
    // for grading, DO NOT MODIFY
    val peek_write = Output(Bool())
    val peek_addr = Output(UInt(32.W))
    val peek_data = Output(UInt(32.W))
}

class Core extends Module {
    val io = IO(new Core_io())

    // instantiate all the modules
    val pc_handle = Module(new PCHandle())
    val inst_mem = Module(new InstMem())
    val decoder = Module(new Decoder())
    val reg_file = Module(new Regfile())
    val alu = Module(new Alu())
    val data_mem = Module(new DataMem())

    /// TODO ///
    // connect all the modules here 
    
    // instantiate pipeline registers
    val if_id = Module(new Reg_IF_ID())
    val id_ex = Module(new Reg_ID_EX())
    val ex_mem = Module(new Reg_EX_MEM())
    val mem_wb = Module(new Reg_MEM_WB())


    // ------------------------------------------------------------
    // HAZARD DETECTION UNIT
    // ------------------------------------------------------------
    
    // Check if the instruction currently in EX stage is a LOAD
    val is_ex_load = id_ex.io.out.ctrl.ctrlMemRead

    // Check if the instruction in ID stage (Decoder output) reads from the load destination
    val rs1_conflict = (decoder.io.regs.rs1_addr === id_ex.io.out.rd_addr) && (id_ex.io.out.rd_addr =/= 0.U)
    val rs2_conflict = (decoder.io.regs.rs2_addr === id_ex.io.out.rd_addr) && (id_ex.io.out.rd_addr =/= 0.U)

    // Detect Load-Use Hazard
    val load_use_hazard = is_ex_load && (rs1_conflict || rs2_conflict)


    // ------------------------------------------------------------
    // IF stage
    // ------------------------------------------------------------
    
    // stall the pc_handle when load-use hazard detected
    pc_handle.io.stall := load_use_hazard  // Freeze PC
    
    
    // assign the pc variables
    pc_handle.io.to_branch := alu.io.to_branch 
    pc_handle.io.jump_addr := alu.io.jump_addr


    // assign the instruction memory address
    inst_mem.io.addr := pc_handle.io.pc


    val inst_wire = inst_mem.io.inst

    // prepare the input for IF/ID pipeline register
    // if_id.io.in.pc := pc_handle.io.pc
    if_id.io.in.pc := RegNext(pc_handle.io.pc)
    if_id.io.in.inst := inst_mem.io.inst
    
    // Stall IF/ID if hazard is detected (hold the instruction in ID)
    if_id.io.stall := load_use_hazard 
    if_id.io.flush := alu.io.to_branch


    // ------------------------------------------------------------
    // ID stage
    // ------------------------------------------------------------
    

    // write back 
    reg_file.io.reg_write := mem_wb.io.out.ctrl.ctrlRegWrite
    reg_file.io.rd_addr := mem_wb.io.out.rd_addr
    reg_file.io.rd_data := Mux(mem_wb.io.out.ctrl.ctrlMemToReg, data_mem.io.data_out, mem_wb.io.out.alu_result) // either from mem (lw) or alu (add
    
    // decoder
    decoder.io.inst := if_id.io.out.inst

    // register file
    reg_file.io.rs1_addr := decoder.io.regs.rs1_addr
    reg_file.io.rs2_addr := decoder.io.regs.rs2_addr

    
    id_ex.io.in.rs1_addr := decoder.io.regs.rs1_addr
    id_ex.io.in.rs2_addr := decoder.io.regs.rs2_addr
   
    // stall and flush
    id_ex.io.stall := false.B
    id_ex.io.flush := load_use_hazard || alu.io.to_branch
    
    // prepare the input for ID/EX pipeline register
    id_ex.io.in.ctrl := decoder.io.ctrl
    id_ex.io.in.pc := if_id.io.out.pc
    id_ex.io.in.rs1_data := reg_file.io.rs1_data
    id_ex.io.in.rs2_data := reg_file.io.rs2_data
    id_ex.io.in.imm := decoder.io.imm
    id_ex.io.in.rd_addr := decoder.io.regs.rd_addr


    

    // ------------------------------------------------------------
    // EX stage
    // ------------------------------------------------------------

    // forwarding unit
    val forwarding_unit = Module(new ForwardingUnit())

    // Inputs from ID/EX (Current Stage)
    forwarding_unit.io.rs1_ex := id_ex.io.out.rs1_addr
    forwarding_unit.io.rs2_ex := id_ex.io.out.rs2_addr

    // Inputs from EX/MEM (Pipeline Reg for MEM stage)
    forwarding_unit.io.rd_mem := ex_mem.io.out.rd_addr
    forwarding_unit.io.reg_write_mem := ex_mem.io.out.ctrl.ctrlRegWrite

    // Inputs from MEM/WB (Pipeline Reg for WB stage)
    forwarding_unit.io.rd_wb := mem_wb.io.out.rd_addr
    forwarding_unit.io.reg_write_wb := mem_wb.io.out.ctrl.ctrlRegWrite

    // Define the data available for forwarding
    // Data from MEM stage (Result of the previous instruction)
    val forward_mem_data = ex_mem.io.out.alu_result 
    
    // Data from WB stage (Result of instruction 2 cycles ago)
    // Note: We use reg_file.io.rd_data because that holds the FINAL value (ALU result or Mem result)
    val forward_wb_data  = reg_file.io.rd_data 

    // --- ALU Source 1 Logic ---
    // 0 = Original, 1 = From WB, 2 = From MEM
    val forwarded_src1 = MuxLookup(forwarding_unit.io.forward_a, id_ex.io.out.rs1_data, Seq(
        0.U -> id_ex.io.out.rs1_data,
        1.U -> forward_wb_data,
        2.U -> forward_mem_data
    ))
    
    // --- ALU Source 2 Logic ---
    val forwarded_src2 = MuxLookup(forwarding_unit.io.forward_b, id_ex.io.out.rs2_data, Seq(
        0.U -> id_ex.io.out.rs2_data,
        1.U -> forward_wb_data,
        2.U -> forward_mem_data
    ))

    // --- Final Connection to ALU ---
    alu.io.src1 := forwarded_src1
    
    // Remember: Src2 can also be an Immediate!
    // The Mux for ALUSrc (Immediate vs Reg) happens AFTER forwarding
    alu.io.src2 := Mux(id_ex.io.out.ctrl.ctrlALUSrc, id_ex.io.out.imm, forwarded_src2)

    // data to ALU
    // // prepare ALU src1 and src2 with
    // val actual_src1 = id_ex.io.out.rs1_data
    // val actual_src2 = Mux(id_ex.io.out.ctrl.ctrlALUSrc, id_ex.io.out.imm, id_ex.io.out.rs2_data)

    // // ALU inputs
    // alu.io.src1 := actual_src1
    // alu.io.src2 := actual_src2
    alu.io.pc := id_ex.io.out.pc
    alu.io.imm := id_ex.io.out.imm
    alu.io.aluOp := id_ex.io.out.ctrl.ctrlALUOp

    // stall and flush
    ex_mem.io.stall := false.B
    ex_mem.io.flush := false.B

    // prepare the input for EX/MEM pipeline register
    ex_mem.io.in.alu_result := alu.io.alu_result
    ex_mem.io.in.rs2_data := forwarded_src2
    ex_mem.io.in.rd_addr := id_ex.io.out.rd_addr
    ex_mem.io.in.ctrl := id_ex.io.out.ctrl

    // ------------------------------------------------------------
    // MEM stage
    // ------------------------------------------------------------

    // data_mem inputs
    data_mem.io.ctrlMemRead := ex_mem.io.out.ctrl.ctrlMemRead || mem_wb.io.out.ctrl.ctrlMemToReg // to make sure the data_mem ctrlMemRead is high when lw in WB stage
    data_mem.io.ctrlMemWrite := ex_mem.io.out.ctrl.ctrlMemWrite
    data_mem.io.addr := ex_mem.io.out.alu_result
    data_mem.io.data_in := ex_mem.io.out.rs2_data

    // stall and flush
    mem_wb.io.stall := false.B
    mem_wb.io.flush := false.B

    // prepare the input for MEM/WB pipeline register
    mem_wb.io.in.alu_result := ex_mem.io.out.alu_result
    mem_wb.io.in.rd_addr := ex_mem.io.out.rd_addr
    mem_wb.io.in.ctrl := ex_mem.io.out.ctrl

    // ------------------------------------------------------------
    // WB stage
    // ------------------------------------------------------------ 



    // core
    io.pc := pc_handle.io.pc
    io.inst := inst_wire
    io.wb_result := Mux(mem_wb.io.out.ctrl.ctrlMemToReg, data_mem.io.data_out, mem_wb.io.out.alu_result)

    /// DO NOT MODIFY ///
    io.peek_write := data_mem.io.peek_write
    io.peek_addr := data_mem.io.addr
    io.peek_data := data_mem.io.data_in


}

/// You can add the following code
//  and generate verilog by command: sbt "runMain cpu.main" ///

// object main extends App {

//     (new ChiselStage).execute(
//     Array("--target-dir", "verilog_output"),
//     Seq(ChiselGeneratorAnnotation(() => new Core()))
//     )
// }


