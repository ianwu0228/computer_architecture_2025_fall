package cpu

import chisel3._


class MEM_WB_Bundle extends Bundle {
    val alu_result = UInt(32.W)
    val rd_addr    = UInt(5.W)
    val ctrl       = new CtrlSignal
}

class Reg_MEM_WB extends Module {
  val io = IO(new Bundle {
    val stall = Input(Bool())
    val flush = Input(Bool())
    val in    = Input(new MEM_WB_Bundle)
    val out   = Output(new MEM_WB_Bundle)
  })

  // real registers
  val alu_result_mem     = RegInit(0.U(32.W))
  val rd_addr_mem        = RegInit(0.U(5.W))
  val ctrl_mem           = RegInit(0.U.asTypeOf(new CtrlSignal))

  when (io.flush) {
    alu_result_mem     := 0.U
    rd_addr_mem        := 0.U
    ctrl_mem           := 0.U.asTypeOf(new CtrlSignal)
  } .elsewhen (!io.stall) {
    alu_result_mem     := io.in.alu_result
    rd_addr_mem        := io.in.rd_addr
    ctrl_mem           := io.in.ctrl
  }

  io.out.alu_result := alu_result_mem
  io.out.rd_addr    := rd_addr_mem
  io.out.ctrl       := ctrl_mem
}