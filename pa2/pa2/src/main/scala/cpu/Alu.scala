package cpu

import chisel3._
import chisel3.util._
import OP_TYPES._

class Alu_io extends Bundle {
  // inputs
  val src1      = Input(UInt(32.W))
  val src2      = Input(UInt(32.W))
  val pc        = Input(UInt(32.W))
  val imm       = Input(UInt(32.W))
  val aluOp     = Input(UInt(5.W))
  // outputs
  val to_branch  = Output(Bool())      // true when branch/jump is taken
  val alu_result = Output(UInt(32.W))  // main ALU output / write-back value
  val jump_addr  = Output(UInt(32.W))  // branch/jump target
}

class Alu extends Module {
  val io = IO(new Alu_io())

  // defaults
  val to_branch  = WireDefault(false.B)
  val alu_result = WireDefault(0.U(32.W))
  val jump_addr  = WireDefault(0.U(32.W))

  val shamt = io.src2(4,0)              // shift amount uses low 5 bits
  val src1_s = io.src1.asSInt
  val src2_s = io.src2.asSInt

  switch(io.aluOp) {
    // ------------------------------------------------------------
    // Basic arithmetic / logic
    // ------------------------------------------------------------
    is(OP_ADD)   { alu_result := io.src1 + io.src2 }
    is(OP_SUB)   { alu_result := io.src1 - io.src2 }
    is(OP_AND)   { alu_result := io.src1 & io.src2 }
    is(OP_OR)    { alu_result := io.src1 | io.src2 }
    is(OP_XOR)   { alu_result := io.src1 ^ io.src2 }
    is(OP_SLT)   { alu_result := (src1_s < src2_s).asUInt }
    is(OP_SLL)   { alu_result := io.src1 << shamt }
    is(OP_SRL)   { alu_result := io.src1 >> shamt }
    is(OP_SRA)   { alu_result := (src1_s >> shamt).asUInt }

    // ------------------------------------------------------------
    // LUI / AUIPC
    // ------------------------------------------------------------
    is(OP_LUI)   { alu_result := io.imm }             // LUI writes imm directly
    is(OP_AUIPC) { alu_result := io.pc + io.imm }     // AUIPC: pc + imm

    // ------------------------------------------------------------
    // Branches
    // (we compute both branch decision & target here)
    // ------------------------------------------------------------
    is(OP_BEQ) {
      to_branch := (io.src1 === io.src2)
      jump_addr := io.pc + io.imm
    }
    is(OP_BNE) {
      to_branch := (io.src1 =/= io.src2)
      jump_addr := io.pc + io.imm
    }
    is(OP_BLT) {
      to_branch := (src1_s < src2_s)
      jump_addr := io.pc + io.imm
    }
    is(OP_BGE) {
      to_branch := (src1_s >= src2_s)
      jump_addr := io.pc + io.imm
    }

    // ------------------------------------------------------------
    // Jumps (JAL / JALR)
    // ------------------------------------------------------------
    is(OP_JAL) {
      // rd = pc + 4, PC <- pc + imm
      alu_result := io.pc + 4.U
      to_branch  := true.B
      jump_addr  := io.pc + io.imm
    }
    is(OP_JALR) {
      // rd = pc + 4, PC <- (rs1 + imm) & ~1
      alu_result := io.pc + 4.U
      to_branch  := true.B
      jump_addr  := (io.src1 + io.imm) & (~1.U(32.W))
    }

    // ------------------------------------------------------------
    // NOP / default
    // ------------------------------------------------------------
    is(OP_NOP) {
      // nothing; defaults already zero
    }
  }

  io.alu_result := alu_result
  io.to_branch  := to_branch
  io.jump_addr  := jump_addr
}
