package cpu

import chisel3._


class EX_MEM_Bundle extends Bundle {
    val alu_result = UInt(32.W)
    val rs2_data   = UInt(32.W)
    val rd_addr    = UInt(5.W)
    val ctrl       = new CtrlSignal

}


class Reg_EX_MEM extends Module {
  val io = IO(new Bundle {
    val stall = Input(Bool())
    val flush = Input(Bool())
    val in    = Input(new EX_MEM_Bundle)
    val out   = Output(new EX_MEM_Bundle)
  })

  // real registers
  val alu_result_ex     = RegInit(0.U(32.W))
  val rs2_data_ex       = RegInit(0.U(32.W))
  val rd_addr_ex        = RegInit(0.U(5.W))
  val ctrl_ex           = RegInit(0.U.asTypeOf(new CtrlSignal))

  when (io.flush) {
    alu_result_ex     := 0.U
    rs2_data_ex       := 0.U
    rd_addr_ex        := 0.U
    ctrl_ex           := 0.U.asTypeOf(new CtrlSignal)
  } .elsewhen (!io.stall) {
    alu_result_ex     := io.in.alu_result
    rs2_data_ex       := io.in.rs2_data
    rd_addr_ex        := io.in.rd_addr
    ctrl_ex           := io.in.ctrl
  }

  io.out.alu_result := alu_result_ex
  io.out.rs2_data   := rs2_data_ex
  io.out.rd_addr    := rd_addr_ex
  io.out.ctrl       := ctrl_ex
}