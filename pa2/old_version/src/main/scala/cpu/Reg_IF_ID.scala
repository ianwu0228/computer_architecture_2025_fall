package cpu

import chisel3._
import chisel3.util._

/** IF/ID pipeline bundle: values passed from IF to ID */
class IF_ID_Bundle extends Bundle {
  val pc   = UInt(32.W)
  val inst = UInt(32.W)
}

/** IF/ID pipeline register */
class Reg_IF_ID extends Module {
  val io = IO(new Bundle {
    val stall = Input(Bool())
    val flush = Input(Bool())
    val in    = Input(new IF_ID_Bundle)
    val out   = Output(new IF_ID_Bundle)
  })

  val reg = RegInit(0.U.asTypeOf(new IF_ID_Bundle))

  when (io.flush) {
    reg := 0.U.asTypeOf(new IF_ID_Bundle)
  } .elsewhen (!io.stall) {
    reg := io.in
  }

  io.out := reg
}

/** ID/EX pipeline bundle: values passed from ID to EX */
class ID_EX_Bundle extends Bundle {
  val pc        = UInt(32.W)
  val rs1_data  = UInt(32.W)
  val rs2_data  = UInt(32.W)
  val imm       = UInt(32.W)
  val regs      = new RegAddr
  val ctrl      = new CtrlSignal
}

/** ID/EX pipeline register */
class Reg_ID_EX extends Module {
  val io = IO(new Bundle {
    val stall = Input(Bool())
    val flush = Input(Bool())
    val in    = Input(new ID_EX_Bundle)
    val out   = Output(new ID_EX_Bundle)
  })

  val reg = RegInit(0.U.asTypeOf(new ID_EX_Bundle))

  when (io.flush) {
    reg := 0.U.asTypeOf(new ID_EX_Bundle)
  } .elsewhen (!io.stall) {
    reg := io.in
  }

  io.out := reg
}

/** EX/MEM pipeline bundle: values passed from EX to MEM */
class EX_MEM_Bundle extends Bundle {
  val pc        = UInt(32.W)
  val alu_res   = UInt(32.W)
  val rs2_data  = UInt(32.W)
  val regs      = new RegAddr
  val ctrl      = new CtrlSignal
}

/** EX/MEM pipeline register */
class Reg_EX_MEM extends Module {
  val io = IO(new Bundle {
    val stall = Input(Bool())
    val flush = Input(Bool())
    val in    = Input(new EX_MEM_Bundle)
    val out   = Output(new EX_MEM_Bundle)
  })

  val reg = RegInit(0.U.asTypeOf(new EX_MEM_Bundle))

  when (io.flush) {
    reg := 0.U.asTypeOf(new EX_MEM_Bundle)
  } .elsewhen (!io.stall) {
    reg := io.in
  }

  io.out := reg
}

/** MEM/WB pipeline bundle: values passed from MEM to WB */
class MEM_WB_Bundle extends Bundle {
  val pc        = UInt(32.W)
  val mem_data  = UInt(32.W)
  val alu_res   = UInt(32.W)
  val regs      = new RegAddr
  val ctrl      = new CtrlSignal
}

/** MEM/WB pipeline register */
class Reg_MEM_WB extends Module {
  val io = IO(new Bundle {
    val stall = Input(Bool())
    val flush = Input(Bool())
    val in    = Input(new MEM_WB_Bundle)
    val out   = Output(new MEM_WB_Bundle)
  })

  val reg = RegInit(0.U.asTypeOf(new MEM_WB_Bundle))

  when (io.flush) {
    reg := 0.U.asTypeOf(new MEM_WB_Bundle)
  } .elsewhen (!io.stall) {
    reg := io.in
  }

  io.out := reg
}
