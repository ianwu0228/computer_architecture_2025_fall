package cpu

import chisel3._

class IF_ID_Bundle extends Bundle {
  val pc   = UInt(32.W)
  val inst = UInt(32.W)
}

class Reg_IF_ID extends Module {
  val io = IO(new Bundle {
    val in    = Input(new IF_ID_Bundle())
    val stall = Input(Bool())
    val flush = Input(Bool())
    val out   = Output(new IF_ID_Bundle())
  })

  // pipeline registers between IF and ID
  val pc_if   = RegInit(0.U(32.W))
  val inst_if = RegInit(0.U(32.W))

  when (io.flush) {
    pc_if   := 0.U
    inst_if := 0.U  // treat as bubble / NOP
  } .elsewhen (!io.stall) {
    pc_if   := io.in.pc
    inst_if := io.in.inst
  }

  io.out.pc   := pc_if
  io.out.inst := inst_if
}
