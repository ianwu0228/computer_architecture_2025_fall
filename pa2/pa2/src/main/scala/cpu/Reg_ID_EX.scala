package cpu

import chisel3._

class ID_EX_Bundle extends Bundle {
    val ctrl      = new CtrlSignal
    val pc        = UInt(32.W)
    val rs1_data  = UInt(32.W)
    val rs2_data  = UInt(32.W)
    val imm       = UInt(32.W)
    val rd_addr   = UInt(5.W)
    // forwarding
    val rs1_addr  = UInt(5.W)
    val rs2_addr  = UInt(5.W)
}



class Reg_ID_EX extends Module {
  val io = IO(new Bundle {
    val stall = Input(Bool())
    val flush = Input(Bool())
    val in    = Input(new ID_EX_Bundle)
    val out   = Output(new ID_EX_Bundle)
  })

  // real registers
  val ctrl_id     = RegInit(0.U.asTypeOf(new CtrlSignal))
  val pc_id       = RegInit(0.U(32.W))
  val rs1_data_id = RegInit(0.U(32.W))
  val rs2_data_id = RegInit(0.U(32.W))
  val imm_id      = RegInit(0.U(32.W))
  val rd_addr_id  = RegInit(0.U(5.W))
  val rs1_addr_id = RegInit(0.U(5.W))
  val rs2_addr_id = RegInit(0.U(5.W))

  when (io.flush) {
    ctrl_id     := 0.U.asTypeOf(new CtrlSignal)
    pc_id       := 0.U
    rs1_data_id := 0.U
    rs2_data_id := 0.U
    imm_id      := 0.U
    rd_addr_id  := 0.U
  } .elsewhen (!io.stall) {
    ctrl_id     := io.in.ctrl
    pc_id       := io.in.pc
    rs1_data_id := io.in.rs1_data
    rs2_data_id := io.in.rs2_data
    imm_id      := io.in.imm
    rd_addr_id  := io.in.rd_addr
  }

  io.out.ctrl     := ctrl_id
  io.out.pc       := pc_id
  io.out.rs1_data := rs1_data_id
  io.out.rs2_data := rs2_data_id
  io.out.imm      := imm_id
  io.out.rd_addr  := rd_addr_id

  io.out.rs1_addr := rs1_addr_id
  io.out.rs2_addr := rs2_addr_id
}