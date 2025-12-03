package cpu

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation

// io for testbench to access
class Core_io extends Bundle {
    // for debugging
    val pc = Output(UInt(32.W))
    val inst = Output(UInt(32.W))
    val wb_result = Output(UInt(32.W))
    // for grading, DO NOT MODIFY
    val peek_write = Output(Bool())
    val peek_addr = Output(UInt(32.W))
    val peek_data = Output(UInt(32.W))
}

class Core extends Module {
    val io = IO(new Core_io())

    // instantiate all the modules
    val pc_handle = Module(new PCHandle())
    val inst_mem = Module(new InstMem())
    val decoder = Module(new Decoder())
    val reg_file = Module(new Regfile())
    val alu = Module(new Alu())
    val data_mem = Module(new DataMem())

    /// TODO ///
    // connect all the modules here 
    
    // core
    io.pc := 
    io.inst := 
    io.wb_result := 

    /// DO NOT MODIFY ///
    io.peek_write := data_mem.io.peek_write
    io.peek_addr := data_mem.io.addr
    io.peek_data := data_mem.io.data_in


}

/// You can add the following code
//  and generate verilog by command: sbt "runMain cpu.main" ///

// object main extends App {

//     (new ChiselStage).execute(
//     Array("--target-dir", "verilog_output"),
//     Seq(ChiselGeneratorAnnotation(() => new Core()))
//     )
// }


