package cpu

import chisel3._
import chisel3.util._

class PCHandle_io extends Bundle {
  val to_branch = Input(Bool())
  val jump_addr = Input(UInt(32.W))
  val pc        = Output(UInt(32.W))
  val stall     = Input(Bool())
}

class PCHandle extends Module {
  val io = IO(new PCHandle_io())

  val pc = RegInit(0.U(32.W))

  // basic next PC logic: PC+4 or branch/jump target
  val next_pc = Mux(io.to_branch, io.jump_addr, pc + 4.U)

  // Only update PC if NOT stalled
  when(!io.stall) {
      pc := next_pc
  }

  // io.pc := pc
  
  // to make sure when stalled, the output pc remains the same as previous cycle
  io.pc := Mux(io.stall, pc - 4.U, pc)

}