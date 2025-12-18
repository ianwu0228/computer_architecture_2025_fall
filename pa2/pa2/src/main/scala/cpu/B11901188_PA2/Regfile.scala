// package cpu

// import chisel3._
// import chisel3.util._

// class Regfile_io extends Bundle {
//     /// TODO ///
//     // read ports
//     val rs1_addr = Input(UInt(5.W))
//     val rs2_addr = Input(UInt(5.W))
//     val rs1_data = Output(UInt(32.W))
//     val rs2_data = Output(UInt(32.W))
//     // write port
//     val rd_addr  = Input(UInt(5.W))
//     val rd_data  = Input(UInt(32.W))
//     val reg_write = Input(Bool())
// }

// class Regfile extends Module {
//     val io = IO(new Regfile_io())

//     // declare 32 registers each 32 bits
//     val regs = Reg(Vec(32, UInt(32.W)))

//     /// TODO ///

//     // read ports (x0 always 0)
//     io.rs1_data := Mux(io.rs1_addr === 0.U, 0.U, regs(io.rs1_addr))
//     io.rs2_data := Mux(io.rs2_addr === 0.U, 0.U, regs(io.rs2_addr))

//     when(io.rs1_addr === 0.U)
//     {
//         io.rs1_data := 0.U
//     }
//     when(io.rs2_addr === 0.U)
//     {
//         io.rs2_data := 0.U
//     }

    

//     // write  
//     when(io.reg_write && io.rd_addr =/= 0.U)
//     {
//         regs(io.rd_addr) := io.rd_data
//     }


// }


package cpu

import chisel3._
import chisel3.util._

class Regfile_io extends Bundle {
    val rs1_addr = Input(UInt(5.W))
    val rs2_addr = Input(UInt(5.W))
    val rs1_data = Output(UInt(32.W))
    val rs2_data = Output(UInt(32.W))
    val rd_addr  = Input(UInt(5.W))
    val rd_data  = Input(UInt(32.W))
    val reg_write = Input(Bool())
}

class Regfile extends Module {
    val io = IO(new Regfile_io())

    // declare 32 registers each 32 bits
    val regs = Reg(Vec(32, UInt(32.W)))

    // --- FIX START ---
    // 1. Read from the register array (The "Old" value)
    val r1_data_raw = regs(io.rs1_addr)
    val r2_data_raw = regs(io.rs2_addr)

    // 2. Internal Forwarding (Collision Detection)
    // Check if we are reading the same register that is currently being written
    val bypass_rs1 = io.reg_write && (io.rd_addr === io.rs1_addr) && (io.rs1_addr =/= 0.U)
    val bypass_rs2 = io.reg_write && (io.rd_addr === io.rs2_addr) && (io.rs2_addr =/= 0.U)

    // 3. Mux to select the data (Forwarded vs. Array)
    io.rs1_data := Mux(bypass_rs1, io.rd_data, r1_data_raw)
    io.rs2_data := Mux(bypass_rs2, io.rd_data, r2_data_raw)

    // 4. Force x0 to be 0 (overrides everything)
    when(io.rs1_addr === 0.U) { io.rs1_data := 0.U }
    when(io.rs2_addr === 0.U) { io.rs2_data := 0.U }
    // --- FIX END ---

    // write  
    when(io.reg_write && io.rd_addr =/= 0.U) {
        regs(io.rd_addr) := io.rd_data
    }
}