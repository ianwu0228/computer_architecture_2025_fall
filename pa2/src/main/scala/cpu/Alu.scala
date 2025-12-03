package cpu

import chisel3._
import chisel3.util._
import cpu.OP_TYPES._

class Alu_io extends Bundle {
    val to_branch = Output(Bool())
    val alu_result = Output(UInt(32.W))
    val jump_addr = Output(UInt(32.W))
    /// TODO ///
}

class Alu extends Module {
    val io = IO(new Alu_io())

    val to_branch = WireDefault(false.B)
    val alu_result = WireDefault(0.U(32.W))
    val jump_addr = WireDefault(0.U(32.W))

    /// TODO ///

    
    io.alu_result := alu_result
    io.to_branch := to_branch
    io.jump_addr := jump_addr
}