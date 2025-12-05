package cpu
import chisel3._
import chisel3.util._

class ForwardingUnit extends Module {
    val io = IO(new Bundle {
        // Current Instruction (EX Stage)
        val rs1_ex = Input(UInt(5.W))
        val rs2_ex = Input(UInt(5.W))

        // Previous Instruction (MEM Stage)
        val rd_mem = Input(UInt(5.W))
        val reg_write_mem = Input(Bool())

        // 2nd Previous Instruction (WB Stage)
        val rd_wb = Input(UInt(5.W))
        val reg_write_wb = Input(Bool())

        // Forwarding Control Signals (0=No, 1=From WB, 2=From MEM)
        val forward_a = Output(UInt(2.W)) 
        val forward_b = Output(UInt(2.W))
    })

    // // Default: No forwarding
    // io.forward_a := 0.U
    // io.forward_b := 0.U

    // // -------------------------
    // // Forward A (Source 1)
    // // -------------------------
    // // Priority 1: EX Hazard (From MEM stage)
    // when(io.reg_write_mem && io.rd_mem =/= 0.U && io.rd_mem === io.rs1_ex) {
    //     io.forward_a := 2.U 
    // }
    // // Priority 2: MEM Hazard (From WB stage)
    // .elsewhen(io.reg_write_wb && io.rd_wb =/= 0.U && io.rd_wb === io.rs1_ex) {
    //     io.forward_a := 1.U
    // }

    // // -------------------------
    // // Forward B (Source 2)
    // // -------------------------
    // // Priority 1: EX Hazard (From MEM stage)
    // when(io.reg_write_mem && io.rd_mem =/= 0.U && io.rd_mem === io.rs2_ex) {
    //     io.forward_b := 2.U
    // }
    // // Priority 2: MEM Hazard (From WB stage)
    // .elsewhen(io.reg_write_wb && io.rd_wb =/= 0.U && io.rd_wb === io.rs2_ex) {
    //     io.forward_b := 1.U
    // }

   
    // 1. Initialize Default Values (Crucial to prevent latches/unknown states)
    io.forward_a := 0.U
    io.forward_b := 0.U

    // -------------------------
    // Forward A (Source 1)
    // -------------------------

    // Priority 1: EX Hazard (Distance 1 - Forward from EX/MEM pipeline register)
    // Checks if the instruction currently in MEM stage wrote to Rs1
    when(io.reg_write_mem && io.rd_mem =/= 0.U && io.rd_mem === io.rs1_ex) {
        io.forward_a := 2.U  // Selects input from ALU result (EX/MEM)
    }
    // Priority 2: MEM Hazard (Distance 2 - Forward from MEM/WB pipeline register)
    // Checks if the instruction currently in WB stage wrote to Rs1
    // AND ensures that the EX Hazard (Priority 1) is NOT active (The "Blue Text" condition)
    .elsewhen(io.reg_write_wb && io.rd_wb =/= 0.U && io.rd_wb === io.rs1_ex && 
            !(io.reg_write_mem && io.rd_mem =/= 0.U && io.rd_mem === io.rs1_ex)) { // Explicit Double Hazard Check
        io.forward_a := 1.U  // Selects input from WB data (MEM/WB)
    }

    // -------------------------
    // Forward B (Source 2)
    // -------------------------

    // Priority 1: EX Hazard (Distance 1 - Forward from EX/MEM pipeline register)
    when(io.reg_write_mem && io.rd_mem =/= 0.U && io.rd_mem === io.rs2_ex) {
        io.forward_b := 2.U
    }
    // Priority 2: MEM Hazard (Distance 2 - Forward from MEM/WB pipeline register)
    .elsewhen(io.reg_write_wb && io.rd_wb =/= 0.U && io.rd_wb === io.rs2_ex && 
            !(io.reg_write_mem && io.rd_mem =/= 0.U && io.rd_mem === io.rs2_ex)) { // Explicit Double Hazard Check
        io.forward_b := 1.U
    }
}