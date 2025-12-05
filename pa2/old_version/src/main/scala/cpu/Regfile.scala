// package cpu

// import chisel3._
// import chisel3.util._

// class Regfile_io extends Bundle {
//     /// TODO ///
//     val ctrlRegWrite = Input(Bool())
//     val reg_addr = Flipped(new RegAddr()) // input
//     val data_write = Input(UInt(32.W))
//     val data_read1 = Output(UInt(32.W))
//     val data_read2 = Output(UInt(32.W))
    
// }

// class Regfile extends Module {
//     val io = IO(new Regfile_io())

//     // declare 32 registers each 32 bits
//     val regs = Reg(Vec(32, UInt(32.W)))

//     /// TODO ///
//     // read
//     when(io.reg_addr.rs1_addr === 0.U)
//     {
//         io.data_read1 := 0.U
//     }
//     when(io.reg_addr.rs2_addr === 0.U)
//     {
//         io.data_read2 := 0.U
//     }

//     io.data_read1 := regs(io.reg_addr.rs1_addr)
//     io.data_read2 := regs(io.reg_addr.rs2_addr)

//     // write  
//     when(io.ctrlRegWrite && io.reg_addr.rd_addr =/= 0.U)
//     {
//         regs(io.reg_addr.rd_addr) := io.data_write
//     }

// }


package cpu

import chisel3._
import chisel3.util._

class Regfile_io extends Bundle {
  // read ports
  val rs1_addr = Input(UInt(5.W))
  val rs2_addr = Input(UInt(5.W))
  val rs1_data = Output(UInt(32.W))
  val rs2_data = Output(UInt(32.W))
  // write port
  val rd_addr  = Input(UInt(5.W))
  val wdata    = Input(UInt(32.W))
  val wen      = Input(Bool())
}

class Regfile extends Module {
  val io = IO(new Regfile_io())

  // 32 x 32-bit registers, init to 0
  val regs = RegInit(VecInit(Seq.fill(32)(0.U(32.W))))

  // write-back (ignore writes to x0)
  when(io.wen && (io.rd_addr =/= 0.U)) {
    regs(io.rd_addr) := io.wdata
  }

  // read ports (x0 always 0)
  io.rs1_data := Mux(io.rs1_addr === 0.U, 0.U, regs(io.rs1_addr))
  io.rs2_data := Mux(io.rs2_addr === 0.U, 0.U, regs(io.rs2_addr))
}
