
  package cpu
  import chisel3._
  
  
  /** Forwarding unit for 5-stage pipeline (EX/MEM & MEM/WB -> EX stage).
    * ForwardA / ForwardB encoding:
    *   00 -> use ID/EX register value
    *   10 -> forward from EX/MEM
    *   01 -> forward from MEM/WB
    *   ForwardA for rs1, ForwardB for rs2
    */

  class ForwardUnit extends Module{
    val io = IO(new Bundle{
      val ex_mem_regwrite = Input(Bool())
      val ex_mem_rd       = Input(UInt(5.W))
      val mem_wb_regwrite = Input(Bool())
      val mem_wb_rd       = Input(UInt(5.W))
      val id_ex_rs1       = Input(UInt(5.W))
      val id_ex_rs2       = Input(UInt(5.W))
      val forwardA        = Output(UInt(2.W))
      val forwardB        = Output(UInt(2.W))
    })

    // Default: no forwarding
    io.forwardA := 0.U
    io.forwardB := 0.U

    // EX hazard
    when(io.ex_mem_regwrite && (io.ex_mem_rd =/= 0.U) && (io.ex_mem_rd === io.id_ex_rs1)){
      io.forwardA := "b10".U
    }
    when(io.ex_mem_regwrite && (io.ex_mem_rd =/= 0.U) && (io.ex_mem_rd === io.id_ex_rs2)){
      io.forwardB := "b10".U
    }

    // MEM hazard
    when(io.mem_wb_regwrite && (io.mem_wb_rd =/= 0.U) && 
         !(io.ex_mem_regwrite && (io.ex_mem_rd =/= 0.U) && (io.ex_mem_rd === io.id_ex_rs1)) &&
         (io.mem_wb_rd === io.id_ex_rs1)){
      io.forwardA := "b01".U
    }
    when(io.mem_wb_regwrite && (io.mem_wb_rd =/= 0.U) && 
         !(io.ex_mem_regwrite && (io.ex_mem_rd =/= 0.U) && (io.ex_mem_rd === io.id_ex_rs2)) &&
         (io.mem_wb_rd === io.id_ex_rs2)){
      io.forwardB := "b01".U
    }
  }
