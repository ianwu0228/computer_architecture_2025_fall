// package cpu

// import chisel3._
// import chisel3.util._
// import OP_TYPES._

// class Decoder_io extends Bundle {
//   val inst = Input(UInt(32.W))
//   val ctrl = Output(new CtrlSignal)
//   val regs = Output(new RegAddr)
//   val imm  = Output(UInt(32.W))
// }

// class Decoder extends Module {
//   val io = IO(new Decoder_io())

//   val inst   = io.inst
//   val opcode = inst(6,0)
//   val rd     = inst(11,7)
//   val funct3 = inst(14,12)
//   val rs1    = inst(19,15)
//   val rs2    = inst(24,20)
//   val funct7 = inst(31,25)

//   // Default outputs
//   io.ctrl := 0.U.asTypeOf(new CtrlSignal)
//   io.regs.rs1_addr := rs1
//   io.regs.rs2_addr := rs2
//   io.regs.rd_addr  := rd
//   io.imm := 0.U

//   // Opcodes
//   val OP_R     = "b0110011".U
//   val OP_I_ALU = "b0010011".U
//   val OP_LOAD  = "b0000011".U
//   val OP_STORE = "b0100011".U
//   val OP_BRANCH= "b1100011".U
//   val OP_JAL   = "b1101111".U
//   val OP_JALR  = "b1100111".U
//   val OP_LUI   = "b0110111".U
//   val OP_AUIPC = "b0010111".U

//   // Sign-extend helper
//   def sext(x: UInt, bits: Int): UInt = {
//     Cat(Fill(32 - bits, x(bits-1)), x(bits-1,0))
//   }

//   switch(opcode) {
//     // ------------------------------------------------------------
//     // R-type (add, sub, and, or, xor, slt, sll, srl, sra)
//     // ------------------------------------------------------------
//     is(OP_R) {
//       io.ctrl.ctrlRegWrite := true.B

//       switch(funct3) {
//         is("b000".U) { io.ctrl.ctrlALUOp := Mux(funct7 === "b0100000".U, OP_SUB, OP_ADD) } // add/sub
//         is("b111".U) { io.ctrl.ctrlALUOp := OP_AND }
//         is("b110".U) { io.ctrl.ctrlALUOp := OP_OR  }
//         is("b100".U) { io.ctrl.ctrlALUOp := OP_XOR }
//         is("b010".U) { io.ctrl.ctrlALUOp := OP_SLT }
//         is("b001".U) { io.ctrl.ctrlALUOp := OP_SLL }
//         is("b101".U) { io.ctrl.ctrlALUOp := Mux(funct7 === "b0100000".U, OP_SRA, OP_SRL) }
//       }
//     }

//     // ------------------------------------------------------------
//     // I-type ALU (addi, slti, slli, srli, srai)
//     // ------------------------------------------------------------
//     is(OP_I_ALU) {
//       io.ctrl.ctrlRegWrite := true.B
//       io.ctrl.ctrlALUSrc   := true.B
//       io.imm := sext(inst(31,20), 12)

//       switch(funct3) {
//         is("b000".U) { io.ctrl.ctrlALUOp := OP_ADD }  // addi
//         is("b010".U) { io.ctrl.ctrlALUOp := OP_SLT }  // slti
//         is("b001".U) { io.ctrl.ctrlALUOp := OP_SLL }  // slli
//         is("b101".U) { 
//           io.ctrl.ctrlALUOp := Mux(funct7 === "b0100000".U, OP_SRA, OP_SRL) // srai/srli
//         }
//       }
//     }

//     // ------------------------------------------------------------
//     // LOAD (lw)
//     // ------------------------------------------------------------
//     is(OP_LOAD) {
//       io.ctrl.ctrlRegWrite := true.B
//       io.ctrl.ctrlALUSrc   := true.B
//       io.ctrl.ctrlMemRead  := true.B
//       io.ctrl.ctrlMemToReg := true.B
//       io.ctrl.ctrlALUOp    := OP_ADD   // addr = rs1 + imm
//       io.imm := sext(inst(31,20), 12)
//     }

//     // ------------------------------------------------------------
//     // STORE (sw)
//     // ------------------------------------------------------------
//     is(OP_STORE) {
//       io.ctrl.ctrlMemWrite := true.B
//       io.ctrl.ctrlALUSrc   := true.B
//       io.ctrl.ctrlALUOp    := OP_ADD
//       val immS = Cat(inst(31,25), inst(11,7))
//       io.imm := sext(immS, 12)
//     }

//     // ------------------------------------------------------------
//     // BRANCH (beq, bne, blt, bge)
//     // ------------------------------------------------------------
//     is(OP_BRANCH) {
//       io.ctrl.ctrlBranch := true.B
//       val immB = Cat(inst(31), inst(7), inst(30,25), inst(11,8), 0.U(1.W))
//       io.imm := sext(immB, 13)

//       switch(funct3) {
//         is("b000".U) { io.ctrl.ctrlALUOp := OP_BEQ }
//         is("b001".U) { io.ctrl.ctrlALUOp := OP_BNE }
//         is("b100".U) { io.ctrl.ctrlALUOp := OP_BLT }
//         is("b101".U) { io.ctrl.ctrlALUOp := OP_BGE }
//       }
//     }

//     // ------------------------------------------------------------
//     // JAL
//     // ------------------------------------------------------------
//     is(OP_JAL) {
//       io.ctrl.ctrlJump     := true.B
//       io.ctrl.ctrlRegWrite := true.B
//       val immJ = Cat(inst(31), inst(19,12), inst(20), inst(30,21), 0.U(1.W))
//       io.imm := sext(immJ, 21)
//       io.ctrl.ctrlALUOp := OP_JAL
//     }

//     // ------------------------------------------------------------
//     // JALR
//     // ------------------------------------------------------------
//     is(OP_JALR) {
//       io.ctrl.ctrlJump     := true.B
//       io.ctrl.ctrlRegWrite := true.B
//       io.ctrl.ctrlALUSrc   := true.B
//       io.ctrl.ctrlALUOp    := OP_JALR
//       io.imm := sext(inst(31,20), 12)
//     }

//     // ------------------------------------------------------------
//     // LUI
//     // ------------------------------------------------------------
//     is(OP_LUI) {
//       io.ctrl.ctrlRegWrite := true.B
//       io.ctrl.ctrlALUOp    := OP_LUI
//       io.imm := Cat(inst(31,12), Fill(12, 0.U))
//     }

//     // ------------------------------------------------------------
//     // AUIPC
//     // ------------------------------------------------------------
//     is(OP_AUIPC) {
//       io.ctrl.ctrlRegWrite := true.B
//       io.ctrl.ctrlALUOp    := OP_AUIPC
//       io.imm := Cat(inst(31,12), Fill(12, 0.U))
//     }
//   }
// }


package cpu

import chisel3._
import chisel3.util._
import OP_TYPES._

class Decoder_io extends Bundle {
  val inst = Input(UInt(32.W))
  val ctrl = Output(new CtrlSignal)
  val regs = Output(new RegAddr)
  val imm  = Output(UInt(32.W))
}

class Decoder extends Module {
  val io = IO(new Decoder_io())

  val inst   = io.inst
  val opcode = inst(6,0)
  val rd     = inst(11,7)
  val funct3 = inst(14,12)
  val rs1    = inst(19,15)
  val rs2    = inst(24,20)
  val funct7 = inst(31,25)

  // Default outputs
  io.ctrl := 0.U.asTypeOf(new CtrlSignal)
  io.regs.rs1_addr := rs1
  io.regs.rs2_addr := rs2
  io.regs.rd_addr  := rd
  io.imm := 0.U

  // Opcodes  (RENAMED to avoid clashing with OP_TYPES)
  val OPC_R     = "b0110011".U
  val OPC_I_ALU = "b0010011".U
  val OPC_LOAD  = "b0000011".U
  val OPC_STORE = "b0100011".U
  val OPC_BRANCH= "b1100011".U
  val OPC_JAL   = "b1101111".U
  val OPC_JALR  = "b1100111".U
  val OPC_LUI   = "b0110111".U
  val OPC_AUIPC = "b0010111".U

  // Sign-extend helper
  def sext(x: UInt, bits: Int): UInt = {
    Cat(Fill(32 - bits, x(bits-1)), x(bits-1,0))
  }

  switch(opcode) {
    // ------------------------------------------------------------
    // R-type (add, sub, and, or, xor, slt, sll, srl, sra)
    // ------------------------------------------------------------
    is(OPC_R) {
      io.ctrl.ctrlRegWrite := true.B

      switch(funct3) {
        is("b000".U) { io.ctrl.ctrlALUOp := Mux(funct7 === "b0100000".U, OP_SUB, OP_ADD) } // add/sub
        is("b111".U) { io.ctrl.ctrlALUOp := OP_AND }
        is("b110".U) { io.ctrl.ctrlALUOp := OP_OR  }
        is("b100".U) { io.ctrl.ctrlALUOp := OP_XOR }
        is("b010".U) { io.ctrl.ctrlALUOp := OP_SLT }
        is("b001".U) { io.ctrl.ctrlALUOp := OP_SLL }
        is("b101".U) { io.ctrl.ctrlALUOp := Mux(funct7 === "b0100000".U, OP_SRA, OP_SRL) }
      }
    }

    // ------------------------------------------------------------
    // I-type ALU (addi, slti, slli, srli, srai)
    // ------------------------------------------------------------
    is(OPC_I_ALU) {
      io.ctrl.ctrlRegWrite := true.B
      io.ctrl.ctrlALUSrc   := true.B
      io.imm := sext(inst(31,20), 12)

      switch(funct3) {
        is("b000".U) { io.ctrl.ctrlALUOp := OP_ADD }  // addi
        is("b010".U) { io.ctrl.ctrlALUOp := OP_SLT }  // slti
        is("b001".U) { io.ctrl.ctrlALUOp := OP_SLL }  // slli
        is("b101".U) {
          io.ctrl.ctrlALUOp := Mux(funct7 === "b0100000".U, OP_SRA, OP_SRL) // srai/srli
        }
      }
    }

    // ------------------------------------------------------------
    // LOAD (lw)
    // ------------------------------------------------------------
    is(OPC_LOAD) {
      io.ctrl.ctrlRegWrite := true.B
      io.ctrl.ctrlALUSrc   := true.B
      io.ctrl.ctrlMemRead  := true.B
      io.ctrl.ctrlMemToReg := true.B
      io.ctrl.ctrlALUOp    := OP_ADD   // addr = rs1 + imm
      io.imm := sext(inst(31,20), 12)
    }

    // ------------------------------------------------------------
    // STORE (sw)
    // ------------------------------------------------------------
    is(OPC_STORE) {
      io.ctrl.ctrlMemWrite := true.B
      io.ctrl.ctrlALUSrc   := true.B
      io.ctrl.ctrlALUOp    := OP_ADD
      val immS = Cat(inst(31,25), inst(11,7))
      io.imm := sext(immS, 12)
    }

    // ------------------------------------------------------------
    // BRANCH (beq, bne, blt, bge)
    // ------------------------------------------------------------
    is(OPC_BRANCH) {
      io.ctrl.ctrlBranch := true.B
      val immB = Cat(inst(31), inst(7), inst(30,25), inst(11,8), 0.U(1.W))
      io.imm := sext(immB, 13)

      switch(funct3) {
        is("b000".U) { io.ctrl.ctrlALUOp := OP_BEQ }
        is("b001".U) { io.ctrl.ctrlALUOp := OP_BNE }
        is("b100".U) { io.ctrl.ctrlALUOp := OP_BLT }
        is("b101".U) { io.ctrl.ctrlALUOp := OP_BGE }
      }
    }

    // ------------------------------------------------------------
    // JAL
    // ------------------------------------------------------------
    is(OPC_JAL) {
      io.ctrl.ctrlJump     := true.B
      io.ctrl.ctrlRegWrite := true.B
      val immJ = Cat(inst(31), inst(19,12), inst(20), inst(30,21), 0.U(1.W))
      io.imm := sext(immJ, 21)
      io.ctrl.ctrlALUOp := OP_JAL
    }

    // ------------------------------------------------------------
    // JALR
    // ------------------------------------------------------------
    is(OPC_JALR) {
      io.ctrl.ctrlJump     := true.B
      io.ctrl.ctrlRegWrite := true.B
      io.ctrl.ctrlALUSrc   := true.B
      io.ctrl.ctrlALUOp    := OP_JALR
      io.imm := sext(inst(31,20), 12)
    }

    // ------------------------------------------------------------
    // LUI
    // ------------------------------------------------------------
    is(OPC_LUI) {
      io.ctrl.ctrlRegWrite := true.B
      io.ctrl.ctrlALUOp    := OP_LUI      // from OP_TYPES (ALU op), not opcode
      io.imm := Cat(inst(31,12), Fill(12, 0.U))
    }

    // ------------------------------------------------------------
    // AUIPC
    // ------------------------------------------------------------
    is(OPC_AUIPC) {
      io.ctrl.ctrlRegWrite := true.B
      io.ctrl.ctrlALUOp    := OP_AUIPC   // from OP_TYPES
      io.imm := Cat(inst(31,12), Fill(12, 0.U))
    }
  }
}
