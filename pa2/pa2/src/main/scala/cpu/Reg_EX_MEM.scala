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
    // Detect Bubble: All control signals are 0
    val is_bubble = !io.in.ctrl.ctrlRegWrite && !io.in.ctrl.ctrlMemWrite && 
                    !io.in.ctrl.ctrlMemRead && !io.in.ctrl.ctrlBranch && !io.in.ctrl.ctrlJump
    
    when(is_bubble) {
        // PRESERVE state during Load-Use Stall Bubble
        // We keep the old Address and Control (Read Enable) alive for one more cycle
        // so DataMem sees a stable read request.
        alu_result_ex := alu_result_ex
        ctrl_ex       := ctrl_ex
        rs2_data_ex   := rs2_data_ex
    } .otherwise {
        // Normal Update: Capture new instruction from ID/EX
        alu_result_ex := io.in.alu_result
        ctrl_ex       := io.in.ctrl
        rs2_data_ex   := io.in.rs2_data
    }
    
    // Always update rd_addr. 
    // If it's a bubble, input is 0, so rd_addr_ex becomes 0.
    // This prevents Forwarding Unit from forwarding this "Ghost" Load.
    rd_addr_ex := io.in.rd_addr
  }

  io.out.alu_result := alu_result_ex
  io.out.rs2_data   := rs2_data_ex
  io.out.rd_addr    := rd_addr_ex
  io.out.ctrl       := ctrl_ex
}