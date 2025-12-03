package cpu

import chisel3._
import chisel3.util._

class Regfile_io extends Bundle {
    /// TODO ///
}

class Regfile extends Module {
    val io = IO(new Regfile_io())

    // declare 32 registers each 32 bits
    val regs = Reg(Vec(32, UInt(32.W)))

    /// TODO ///

}
