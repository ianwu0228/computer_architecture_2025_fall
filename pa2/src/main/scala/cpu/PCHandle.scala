package cpu

import chisel3._
import chisel3.util._

class PCHandle_io extends Bundle {
    /// TODO ///   
}

class PCHandle extends Module {
    val io = IO(new PCHandle_io())  

    val pc = RegInit(UInt(32.W), 0.U) 
    
    /// TODO ///
}