package cpu

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation

// io for testbench to access
class Core_io extends Bundle {
  // for debugging
  val pc        = Output(UInt(32.W))
  val inst      = Output(UInt(32.W))
  val wb_result = Output(UInt(32.W))
  // for grading, DO NOT MODIFY
  val peek_write = Output(Bool())
  val peek_addr  = Output(UInt(32.W))
  val peek_data  = Output(UInt(32.W))
}

class Core extends Module {
  val io = IO(new Core_io())

  // ------------------------------------------------------------
  // Instantiate shared modules
  // ------------------------------------------------------------
  val pc_handle = Module(new PCHandle())
  val inst_mem  = Module(new InstMem())
  val decoder   = Module(new Decoder())
  val reg_file  = Module(new Regfile())
  val alu       = Module(new Alu())
  val data_mem  = Module(new DataMem())

  // ------------------------------------------------------------
  // IF stage
  // ------------------------------------------------------------
  pc_handle.io.to_branch := false.B
  pc_handle.io.jump_addr := 0.U

  inst_mem.io.addr := pc_handle.io.pc
  val inst_if = inst_mem.io.inst

  val if_id    = Module(new Reg_IF_ID())
  val if_id_in = Wire(new IF_ID_Bundle)
  if_id_in.pc   := pc_handle.io.pc
  if_id_in.inst := inst_if

  if_id.io.stall := false.B
  if_id.io.flush := false.B
  if_id.io.in    := if_id_in

  val pc_id   = if_id.io.out.pc
  val inst_id = if_id.io.out.inst

  // ------------------------------------------------------------
  // ID stage
  // ------------------------------------------------------------
  decoder.io.inst := inst_id

  reg_file.io.rs1_addr := decoder.io.regs.rs1_addr
  reg_file.io.rs2_addr := decoder.io.regs.rs2_addr
  reg_file.io.rd_addr  := 0.U
  reg_file.io.wdata    := 0.U
  reg_file.io.wen      := false.B

  val id_ex    = Module(new Reg_ID_EX())
  val id_ex_in = Wire(new ID_EX_Bundle)

  id_ex_in.pc        := pc_id
  id_ex_in.rs1_data  := reg_file.io.rs1_data
  id_ex_in.rs2_data  := reg_file.io.rs2_data
  id_ex_in.imm       := decoder.io.imm
  id_ex_in.regs      := decoder.io.regs
  id_ex_in.ctrl      := decoder.io.ctrl

  id_ex.io.stall := false.B
  id_ex.io.flush := false.B
  id_ex.io.in    := id_ex_in

  val ex_in = id_ex.io.out



  // ------------------------------------------------------------
  // EX stage
  // ------------------------------------------------------------
  val alu_src2 = Mux(ex_in.ctrl.ctrlALUSrc, ex_in.imm, ex_in.rs2_data)


  // val ex_src1 = Wire(UInt(32.W))
  // val ex_src2 = Wire(UInt(32.W))

  alu.io.src1  := ex_in.rs1_data
  alu.io.src2  := alu_src2
  alu.io.pc    := ex_in.pc
  alu.io.imm   := ex_in.imm
  alu.io.aluOp := ex_in.ctrl.ctrlALUOp

  val ex_mem    = Module(new Reg_EX_MEM())
  val ex_mem_in = Wire(new EX_MEM_Bundle)

  ex_mem_in.pc       := ex_in.pc
  ex_mem_in.alu_res  := alu.io.alu_result
  ex_mem_in.rs2_data := ex_in.rs2_data
  ex_mem_in.regs     := ex_in.regs
  ex_mem_in.ctrl     := ex_in.ctrl

  ex_mem.io.stall := false.B
  ex_mem.io.flush := false.B
  ex_mem.io.in    := ex_mem_in

  // data_mem.io.addr := ex_mem_in.alu_res
  val mem_in = ex_mem.io.out

  // ------------------------------------------------------------
  // MEM stage
  // ------------------------------------------------------------
  
  // data_mem.io.ctrlMemRead  := mem_in.ctrl.ctrlMemRead
  val delayedMemRead  = RegNext(mem_in.ctrl.ctrlMemRead, 0.B)
  data_mem.io.ctrlMemRead  := delayedMemRead



  data_mem.io.ctrlMemWrite := mem_in.ctrl.ctrlMemWrite
  data_mem.io.addr         := mem_in.alu_res
  data_mem.io.data_in      := mem_in.rs2_data

  val mem_wb    = Module(new Reg_MEM_WB())
  val mem_wb_in = Wire(new MEM_WB_Bundle)

  // carry everything *except* the memory data
  mem_wb_in.pc       := mem_in.pc
  mem_wb_in.alu_res  := mem_in.alu_res
  mem_wb_in.regs     := mem_in.regs
  mem_wb_in.ctrl     := mem_in.ctrl

  // mem_data is not used for loads when memory is synchronous
  mem_wb_in.mem_data := 0.U  // or mem_in.alu_res, doesn't matter


  mem_wb.io.stall := false.B
  mem_wb.io.flush := false.B
  mem_wb.io.in    := mem_wb_in

  val wb_in = mem_wb.io.out

  // ------------------------------------------------------------
  // WB stage
  // ------------------------------------------------------------
  val wb_data = Mux(mem_wb.io.out.ctrl.ctrlMemToReg,
                    data_mem.io.data_out,  // <- use memory output here
                    wb_in.alu_res)


  
  reg_file.io.wen     := wb_in.ctrl.ctrlRegWrite
  reg_file.io.rd_addr := wb_in.regs.rd_addr
  reg_file.io.wdata   := wb_data



  
  // // ------------------------------------------------------------
  // // Forwarding Unit 
  // // ------------------------------------------------------------
  

  // val forward_unit = Module(new ForwardUnit())

  // forward_unit.io.ex_mem_regwrite := ex_mem.io.out.ctrl.ctrlRegWrite
  // forward_unit.io.ex_mem_rd       := ex_mem.io.out.regs.rd_addr
  // forward_unit.io.mem_wb_regwrite := mem_wb.io.out.ctrl.ctrlRegWrite
  // forward_unit.io.mem_wb_rd       := mem_wb.io.out.regs.rd_addr
  // forward_unit.io.id_ex_rs1       := ex_in.regs.rs1_addr
  // forward_unit.io.id_ex_rs2       := ex_in.regs.rs2_addr


  // // raw EX sources
  // val ex_src1_raw = ex_in.rs1_data
  // val ex_src2_raw = ex_in.rs2_data

  // // ALU src2 consider immediate
  // val ex_alu_src2 = Mux(ex_in.ctrl.ctrlALUSrc, ex_in.imm, ex_src2_raw)

  // // final EX sources after forwarding
  // ex_src1 := ex_src1_raw
  // ex_src2 := ex_alu_src2

  // // EX hazard: forward from EX/MEM REGISTER (one cycle later)
  // when(forward_unit.io.forwardA === "b10".U) {
  //   ex_src1 := mem_in.alu_res      // registered output, no loop
  // }
  // when(forward_unit.io.forwardB === "b10".U) {
  //   ex_src2 := mem_in.alu_res
  // }

  // // MEM hazard
  // when(forward_unit.io.forwardA === "b01".U){
  //   ex_src1 := wb_data
  // }
  // when(forward_unit.io.forwardB === "b01".U){
  //   ex_src2 := wb_data
  // }




  // ------------------------------------------------------------
  // Outputs
  // ------------------------------------------------------------
  io.pc        := pc_handle.io.pc
  io.inst      := inst_if
  io.wb_result := wb_data

  /// DO NOT MODIFY ///
  io.peek_write := data_mem.io.peek_write
  io.peek_addr  := data_mem.io.addr
  io.peek_data  := data_mem.io.data_in
}

