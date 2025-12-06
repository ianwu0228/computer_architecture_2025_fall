circuit Core :
  module PCHandle :
    input clock : Clock
    input reset : UInt<1>
    input io_to_branch : UInt<1>
    input io_jump_addr : UInt<32>
    output io_pc : UInt<32>
    input io_stall : UInt<1>

    reg pc : UInt<32>, clock with :
      reset => (UInt<1>("h0"), pc) @[PCHandle.scala 16:19]
    node _next_pc_T = add(pc, UInt<3>("h4")) @[PCHandle.scala 19:52]
    node _next_pc_T_1 = tail(_next_pc_T, 1) @[PCHandle.scala 19:52]
    node next_pc = mux(io_to_branch, io_jump_addr, _next_pc_T_1) @[PCHandle.scala 19:20]
    node _T = eq(io_stall, UInt<1>("h0")) @[PCHandle.scala 22:8]
    node _GEN_0 = mux(_T, next_pc, pc) @[PCHandle.scala 22:19 23:10 16:19]
    node _io_pc_T = sub(pc, UInt<3>("h4")) @[PCHandle.scala 29:29]
    node _io_pc_T_1 = tail(_io_pc_T, 1) @[PCHandle.scala 29:29]
    node _io_pc_T_2 = mux(io_stall, _io_pc_T_1, pc) @[PCHandle.scala 29:15]
    io_pc <= _io_pc_T_2 @[PCHandle.scala 29:9]
    pc <= mux(reset, UInt<32>("h0"), _GEN_0) @[PCHandle.scala 16:{19,19}]

  module InstMem :
    input clock : Clock
    input reset : UInt<1>
    input io_addr : UInt<32>
    output io_inst : UInt<32>

    mem mem : @[InstMem.scala 25:20]
      data-type => UInt<32>
      depth => 1024
      read-latency => 1
      write-latency => 1
      reader => io_inst_MPORT
      read-under-write => undefined
    node index = dshr(io_addr, UInt<2>("h2")) @[InstMem.scala 19:25]
    node _GEN_0 = validif(UInt<1>("h1"), index) @[InstMem.scala 34:{24,24}]
    node _io_inst_WIRE = _GEN_0 @[InstMem.scala 34:24]
    node _io_inst_T = or(_io_inst_WIRE, UInt<10>("h0")) @[InstMem.scala 34:24]
    node _io_inst_T_1 = bits(_io_inst_T, 9, 0) @[InstMem.scala 34:24]
    node _GEN_1 = mux(UInt<1>("h1"), UInt<1>("h1"), UInt<1>("h0")) @[InstMem.scala 25:20 34:{24,24}]
    node _GEN_2 = validif(UInt<1>("h1"), _io_inst_T_1) @[InstMem.scala 34:{24,24}]
    node _GEN_3 = validif(UInt<1>("h1"), clock) @[InstMem.scala 34:{24,24}]
    io_inst <= mem.io_inst_MPORT.data @[InstMem.scala 34:13]
    mem.io_inst_MPORT.addr <= _GEN_2
    mem.io_inst_MPORT.en <= _GEN_1
    mem.io_inst_MPORT.clk <= _GEN_3

  module Decoder :
    input clock : Clock
    input reset : UInt<1>
    input io_inst : UInt<32>
    output io_ctrl_ctrlJump : UInt<1>
    output io_ctrl_ctrlBranch : UInt<1>
    output io_ctrl_ctrlRegWrite : UInt<1>
    output io_ctrl_ctrlMemRead : UInt<1>
    output io_ctrl_ctrlMemWrite : UInt<1>
    output io_ctrl_ctrlALUSrc : UInt<1>
    output io_ctrl_ctrlALUOp : UInt<5>
    output io_ctrl_ctrlMemToReg : UInt<1>
    output io_regs_rs1_addr : UInt<5>
    output io_regs_rs2_addr : UInt<5>
    output io_regs_rd_addr : UInt<5>
    output io_imm : UInt<32>

    node opcode = bits(io_inst, 6, 0) @[Decoder.scala 18:20]
    node rd = bits(io_inst, 11, 7) @[Decoder.scala 19:20]
    node funct3 = bits(io_inst, 14, 12) @[Decoder.scala 20:20]
    node rs1 = bits(io_inst, 19, 15) @[Decoder.scala 21:20]
    node rs2 = bits(io_inst, 24, 20) @[Decoder.scala 22:20]
    node funct7 = bits(io_inst, 31, 25) @[Decoder.scala 23:20]
    node _T = eq(UInt<6>("h33"), opcode) @[Decoder.scala 48:18]
    node _T_1 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 55:22]
    node _io_ctrl_ctrlALUOp_T = eq(funct7, UInt<6>("h20")) @[Decoder.scala 56:56]
    node _io_ctrl_ctrlALUOp_T_1 = mux(_io_ctrl_ctrlALUOp_T, UInt<2>("h2"), UInt<1>("h1")) @[Decoder.scala 56:48]
    node _T_2 = eq(UInt<3>("h7"), funct3) @[Decoder.scala 55:22]
    node _T_3 = eq(UInt<3>("h6"), funct3) @[Decoder.scala 55:22]
    node _T_4 = eq(UInt<3>("h4"), funct3) @[Decoder.scala 55:22]
    node _T_5 = eq(UInt<2>("h2"), funct3) @[Decoder.scala 55:22]
    node _T_6 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 55:22]
    node _T_7 = eq(UInt<3>("h5"), funct3) @[Decoder.scala 55:22]
    node _io_ctrl_ctrlALUOp_T_2 = eq(funct7, UInt<6>("h20")) @[Decoder.scala 62:56]
    node _io_ctrl_ctrlALUOp_T_3 = mux(_io_ctrl_ctrlALUOp_T_2, UInt<4>("h9"), UInt<4>("h8")) @[Decoder.scala 62:48]
    node _io_ctrl_WIRE_ctrlALUOp = UInt<5>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_0 = mux(_T_7, _io_ctrl_ctrlALUOp_T_3, _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 26:11 55:22 62:42]
    node _GEN_1 = mux(_T_6, UInt<3>("h7"), _GEN_0) @[Decoder.scala 55:22 61:42]
    node _GEN_2 = mux(_T_5, UInt<3>("h6"), _GEN_1) @[Decoder.scala 55:22 60:42]
    node _GEN_3 = mux(_T_4, UInt<3>("h5"), _GEN_2) @[Decoder.scala 55:22 59:42]
    node _GEN_4 = mux(_T_3, UInt<3>("h4"), _GEN_3) @[Decoder.scala 55:22 58:42]
    node _GEN_5 = mux(_T_2, UInt<2>("h3"), _GEN_4) @[Decoder.scala 55:22 57:42]
    node _GEN_6 = mux(_T_1, _io_ctrl_ctrlALUOp_T_1, _GEN_5) @[Decoder.scala 55:22 56:42]
    node _T_8 = eq(UInt<5>("h13"), opcode) @[Decoder.scala 48:18]
    node _io_imm_T = bits(io_inst, 31, 20) @[Decoder.scala 72:26]
    node _io_imm_T_1 = bits(_io_imm_T, 11, 11) @[Decoder.scala 45:26]
    node _io_imm_T_2 = bits(_io_imm_T_1, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_3 = mux(_io_imm_T_2, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_4 = bits(_io_imm_T, 11, 0) @[Decoder.scala 45:38]
    node _io_imm_T_5 = cat(_io_imm_T_3, _io_imm_T_4) @[Cat.scala 31:58]
    node _T_9 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 74:22]
    node _T_10 = eq(UInt<2>("h2"), funct3) @[Decoder.scala 74:22]
    node _T_11 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 74:22]
    node _T_12 = eq(UInt<3>("h5"), funct3) @[Decoder.scala 74:22]
    node _io_ctrl_ctrlALUOp_T_4 = eq(funct7, UInt<6>("h20")) @[Decoder.scala 79:43]
    node _io_ctrl_ctrlALUOp_T_5 = mux(_io_ctrl_ctrlALUOp_T_4, UInt<4>("h9"), UInt<4>("h8")) @[Decoder.scala 79:35]
    node _GEN_7 = mux(_T_12, _io_ctrl_ctrlALUOp_T_5, _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 26:11 74:22 79:29]
    node _GEN_8 = mux(_T_11, UInt<3>("h7"), _GEN_7) @[Decoder.scala 74:22 77:42]
    node _GEN_9 = mux(_T_10, UInt<3>("h6"), _GEN_8) @[Decoder.scala 74:22 76:42]
    node _GEN_10 = mux(_T_9, UInt<1>("h1"), _GEN_9) @[Decoder.scala 74:22 75:42]
    node _T_13 = eq(UInt<2>("h3"), opcode) @[Decoder.scala 48:18]
    node _io_imm_T_6 = bits(io_inst, 31, 20) @[Decoder.scala 93:26]
    node _io_imm_T_7 = bits(_io_imm_T_6, 11, 11) @[Decoder.scala 45:26]
    node _io_imm_T_8 = bits(_io_imm_T_7, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_9 = mux(_io_imm_T_8, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_10 = bits(_io_imm_T_6, 11, 0) @[Decoder.scala 45:38]
    node _io_imm_T_11 = cat(_io_imm_T_9, _io_imm_T_10) @[Cat.scala 31:58]
    node _T_14 = eq(UInt<6>("h23"), opcode) @[Decoder.scala 48:18]
    node _immS_T = bits(io_inst, 31, 25) @[Decoder.scala 103:26]
    node _immS_T_1 = bits(io_inst, 11, 7) @[Decoder.scala 103:39]
    node immS = cat(_immS_T, _immS_T_1) @[Cat.scala 31:58]
    node _io_imm_T_12 = bits(immS, 11, 11) @[Decoder.scala 45:26]
    node _io_imm_T_13 = bits(_io_imm_T_12, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_14 = mux(_io_imm_T_13, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_15 = bits(immS, 11, 0) @[Decoder.scala 45:38]
    node _io_imm_T_16 = cat(_io_imm_T_14, _io_imm_T_15) @[Cat.scala 31:58]
    node _T_15 = eq(UInt<7>("h63"), opcode) @[Decoder.scala 48:18]
    node _immB_T = bits(io_inst, 31, 31) @[Decoder.scala 112:26]
    node _immB_T_1 = bits(io_inst, 7, 7) @[Decoder.scala 112:36]
    node _immB_T_2 = bits(io_inst, 30, 25) @[Decoder.scala 112:45]
    node _immB_T_3 = bits(io_inst, 11, 8) @[Decoder.scala 112:58]
    node immB_lo = cat(_immB_T_3, UInt<1>("h0")) @[Cat.scala 31:58]
    node immB_hi_hi = cat(_immB_T, _immB_T_1) @[Cat.scala 31:58]
    node immB_hi = cat(immB_hi_hi, _immB_T_2) @[Cat.scala 31:58]
    node immB = cat(immB_hi, immB_lo) @[Cat.scala 31:58]
    node _io_imm_T_17 = bits(immB, 12, 12) @[Decoder.scala 45:26]
    node _io_imm_T_18 = bits(_io_imm_T_17, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_19 = mux(_io_imm_T_18, UInt<19>("h7ffff"), UInt<19>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_20 = bits(immB, 12, 0) @[Decoder.scala 45:38]
    node _io_imm_T_21 = cat(_io_imm_T_19, _io_imm_T_20) @[Cat.scala 31:58]
    node _T_16 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 115:22]
    node _T_17 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 115:22]
    node _T_18 = eq(UInt<3>("h4"), funct3) @[Decoder.scala 115:22]
    node _T_19 = eq(UInt<3>("h5"), funct3) @[Decoder.scala 115:22]
    node _GEN_11 = mux(_T_19, UInt<4>("hd"), _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 115:22 119:42 26:11]
    node _GEN_12 = mux(_T_18, UInt<4>("hc"), _GEN_11) @[Decoder.scala 115:22 118:42]
    node _GEN_13 = mux(_T_17, UInt<4>("hb"), _GEN_12) @[Decoder.scala 115:22 117:42]
    node _GEN_14 = mux(_T_16, UInt<4>("ha"), _GEN_13) @[Decoder.scala 115:22 116:42]
    node _T_20 = eq(UInt<7>("h6f"), opcode) @[Decoder.scala 48:18]
    node _immJ_T = bits(io_inst, 31, 31) @[Decoder.scala 129:26]
    node _immJ_T_1 = bits(io_inst, 19, 12) @[Decoder.scala 129:36]
    node _immJ_T_2 = bits(io_inst, 20, 20) @[Decoder.scala 129:49]
    node _immJ_T_3 = bits(io_inst, 30, 21) @[Decoder.scala 129:59]
    node immJ_lo = cat(_immJ_T_3, UInt<1>("h0")) @[Cat.scala 31:58]
    node immJ_hi_hi = cat(_immJ_T, _immJ_T_1) @[Cat.scala 31:58]
    node immJ_hi = cat(immJ_hi_hi, _immJ_T_2) @[Cat.scala 31:58]
    node immJ = cat(immJ_hi, immJ_lo) @[Cat.scala 31:58]
    node _io_imm_T_22 = bits(immJ, 20, 20) @[Decoder.scala 45:26]
    node _io_imm_T_23 = bits(_io_imm_T_22, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_24 = mux(_io_imm_T_23, UInt<11>("h7ff"), UInt<11>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_25 = bits(immJ, 20, 0) @[Decoder.scala 45:38]
    node _io_imm_T_26 = cat(_io_imm_T_24, _io_imm_T_25) @[Cat.scala 31:58]
    node _T_21 = eq(UInt<7>("h67"), opcode) @[Decoder.scala 48:18]
    node _io_imm_T_27 = bits(io_inst, 31, 20) @[Decoder.scala 142:26]
    node _io_imm_T_28 = bits(_io_imm_T_27, 11, 11) @[Decoder.scala 45:26]
    node _io_imm_T_29 = bits(_io_imm_T_28, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_30 = mux(_io_imm_T_29, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_31 = bits(_io_imm_T_27, 11, 0) @[Decoder.scala 45:38]
    node _io_imm_T_32 = cat(_io_imm_T_30, _io_imm_T_31) @[Cat.scala 31:58]
    node _T_22 = eq(UInt<6>("h37"), opcode) @[Decoder.scala 48:18]
    node _io_imm_T_33 = bits(io_inst, 31, 12) @[Decoder.scala 151:25]
    node _io_imm_T_34 = mux(UInt<1>("h0"), UInt<12>("hfff"), UInt<12>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_35 = cat(_io_imm_T_33, _io_imm_T_34) @[Cat.scala 31:58]
    node _T_23 = eq(UInt<5>("h17"), opcode) @[Decoder.scala 48:18]
    node _io_imm_T_36 = bits(io_inst, 31, 12) @[Decoder.scala 160:25]
    node _io_imm_T_37 = mux(UInt<1>("h0"), UInt<12>("hfff"), UInt<12>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_38 = cat(_io_imm_T_36, _io_imm_T_37) @[Cat.scala 31:58]
    node _io_ctrl_WIRE_ctrlRegWrite = UInt<1>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_15 = mux(_T_23, UInt<1>("h1"), _io_ctrl_WIRE_ctrlRegWrite) @[Decoder.scala 48:18 158:28 26:11]
    node _GEN_16 = mux(_T_23, UInt<5>("h11"), _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 48:18 159:28 26:11]
    node _GEN_17 = mux(_T_23, _io_imm_T_38, UInt<1>("h0")) @[Decoder.scala 160:14 30:10 48:18]
    node _GEN_18 = mux(_T_22, UInt<1>("h1"), _GEN_15) @[Decoder.scala 48:18 149:28]
    node _GEN_19 = mux(_T_22, UInt<5>("h10"), _GEN_16) @[Decoder.scala 48:18 150:28]
    node _GEN_20 = mux(_T_22, _io_imm_T_35, _GEN_17) @[Decoder.scala 151:14 48:18]
    node _io_ctrl_WIRE_ctrlJump = UInt<1>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_21 = mux(_T_21, UInt<1>("h1"), _io_ctrl_WIRE_ctrlJump) @[Decoder.scala 48:18 138:28 26:11]
    node _GEN_22 = mux(_T_21, UInt<1>("h1"), _GEN_18) @[Decoder.scala 48:18 139:28]
    node _io_ctrl_WIRE_ctrlALUSrc = UInt<1>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_23 = mux(_T_21, UInt<1>("h1"), _io_ctrl_WIRE_ctrlALUSrc) @[Decoder.scala 48:18 140:28 26:11]
    node _GEN_24 = mux(_T_21, UInt<4>("hf"), _GEN_19) @[Decoder.scala 48:18 141:28]
    node _GEN_25 = mux(_T_21, _io_imm_T_32, _GEN_20) @[Decoder.scala 142:14 48:18]
    node _GEN_26 = mux(_T_20, UInt<1>("h1"), _GEN_21) @[Decoder.scala 48:18 127:28]
    node _GEN_27 = mux(_T_20, UInt<1>("h1"), _GEN_22) @[Decoder.scala 48:18 128:28]
    node _GEN_28 = mux(_T_20, _io_imm_T_26, _GEN_25) @[Decoder.scala 130:14 48:18]
    node _GEN_29 = mux(_T_20, UInt<4>("he"), _GEN_24) @[Decoder.scala 48:18 131:25]
    node _GEN_30 = mux(_T_20, _io_ctrl_WIRE_ctrlALUSrc, _GEN_23) @[Decoder.scala 26:11 48:18]
    node _io_ctrl_WIRE_ctrlBranch = UInt<1>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_31 = mux(_T_15, UInt<1>("h1"), _io_ctrl_WIRE_ctrlBranch) @[Decoder.scala 48:18 111:26 26:11]
    node _GEN_32 = mux(_T_15, _io_imm_T_21, _GEN_28) @[Decoder.scala 113:14 48:18]
    node _GEN_33 = mux(_T_15, _GEN_14, _GEN_29) @[Decoder.scala 48:18]
    node _GEN_34 = mux(_T_15, _io_ctrl_WIRE_ctrlJump, _GEN_26) @[Decoder.scala 26:11 48:18]
    node _GEN_35 = mux(_T_15, _io_ctrl_WIRE_ctrlRegWrite, _GEN_27) @[Decoder.scala 26:11 48:18]
    node _GEN_36 = mux(_T_15, _io_ctrl_WIRE_ctrlALUSrc, _GEN_30) @[Decoder.scala 26:11 48:18]
    node _io_ctrl_WIRE_ctrlMemWrite = UInt<1>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_37 = mux(_T_14, UInt<1>("h1"), _io_ctrl_WIRE_ctrlMemWrite) @[Decoder.scala 48:18 100:28 26:11]
    node _GEN_38 = mux(_T_14, UInt<1>("h1"), _GEN_36) @[Decoder.scala 48:18 101:28]
    node _GEN_39 = mux(_T_14, UInt<1>("h1"), _GEN_33) @[Decoder.scala 48:18 102:28]
    node _GEN_40 = mux(_T_14, _io_imm_T_16, _GEN_32) @[Decoder.scala 104:14 48:18]
    node _GEN_41 = mux(_T_14, _io_ctrl_WIRE_ctrlBranch, _GEN_31) @[Decoder.scala 26:11 48:18]
    node _GEN_42 = mux(_T_14, _io_ctrl_WIRE_ctrlJump, _GEN_34) @[Decoder.scala 26:11 48:18]
    node _GEN_43 = mux(_T_14, _io_ctrl_WIRE_ctrlRegWrite, _GEN_35) @[Decoder.scala 26:11 48:18]
    node _GEN_44 = mux(_T_13, UInt<1>("h1"), _GEN_43) @[Decoder.scala 48:18 88:28]
    node _GEN_45 = mux(_T_13, UInt<1>("h1"), _GEN_38) @[Decoder.scala 48:18 89:28]
    node _io_ctrl_WIRE_ctrlMemRead = UInt<1>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_46 = mux(_T_13, UInt<1>("h1"), _io_ctrl_WIRE_ctrlMemRead) @[Decoder.scala 26:11 48:18 90:28]
    node _io_ctrl_WIRE_ctrlMemToReg = UInt<1>("h0") @[Decoder.scala 26:{26,26}]
    node _GEN_47 = mux(_T_13, UInt<1>("h1"), _io_ctrl_WIRE_ctrlMemToReg) @[Decoder.scala 26:11 48:18 91:28]
    node _GEN_48 = mux(_T_13, UInt<1>("h1"), _GEN_39) @[Decoder.scala 48:18 92:28]
    node _GEN_49 = mux(_T_13, _io_imm_T_11, _GEN_40) @[Decoder.scala 48:18 93:14]
    node _GEN_50 = mux(_T_13, _io_ctrl_WIRE_ctrlMemWrite, _GEN_37) @[Decoder.scala 26:11 48:18]
    node _GEN_51 = mux(_T_13, _io_ctrl_WIRE_ctrlBranch, _GEN_41) @[Decoder.scala 26:11 48:18]
    node _GEN_52 = mux(_T_13, _io_ctrl_WIRE_ctrlJump, _GEN_42) @[Decoder.scala 26:11 48:18]
    node _GEN_53 = mux(_T_8, UInt<1>("h1"), _GEN_44) @[Decoder.scala 48:18 70:28]
    node _GEN_54 = mux(_T_8, UInt<1>("h1"), _GEN_45) @[Decoder.scala 48:18 71:28]
    node _GEN_55 = mux(_T_8, _io_imm_T_5, _GEN_49) @[Decoder.scala 48:18 72:14]
    node _GEN_56 = mux(_T_8, _GEN_10, _GEN_48) @[Decoder.scala 48:18]
    node _GEN_57 = mux(_T_8, _io_ctrl_WIRE_ctrlMemRead, _GEN_46) @[Decoder.scala 26:11 48:18]
    node _GEN_58 = mux(_T_8, _io_ctrl_WIRE_ctrlMemToReg, _GEN_47) @[Decoder.scala 26:11 48:18]
    node _GEN_59 = mux(_T_8, _io_ctrl_WIRE_ctrlMemWrite, _GEN_50) @[Decoder.scala 26:11 48:18]
    node _GEN_60 = mux(_T_8, _io_ctrl_WIRE_ctrlBranch, _GEN_51) @[Decoder.scala 26:11 48:18]
    node _GEN_61 = mux(_T_8, _io_ctrl_WIRE_ctrlJump, _GEN_52) @[Decoder.scala 26:11 48:18]
    node _GEN_62 = mux(_T, UInt<1>("h1"), _GEN_53) @[Decoder.scala 48:18 53:28]
    node _GEN_63 = mux(_T, _GEN_6, _GEN_56) @[Decoder.scala 48:18]
    node _GEN_64 = mux(_T, _io_ctrl_WIRE_ctrlALUSrc, _GEN_54) @[Decoder.scala 26:11 48:18]
    node _GEN_65 = mux(_T, UInt<1>("h0"), _GEN_55) @[Decoder.scala 30:10 48:18]
    node _GEN_66 = mux(_T, _io_ctrl_WIRE_ctrlMemRead, _GEN_57) @[Decoder.scala 26:11 48:18]
    node _GEN_67 = mux(_T, _io_ctrl_WIRE_ctrlMemToReg, _GEN_58) @[Decoder.scala 26:11 48:18]
    node _GEN_68 = mux(_T, _io_ctrl_WIRE_ctrlMemWrite, _GEN_59) @[Decoder.scala 26:11 48:18]
    node _GEN_69 = mux(_T, _io_ctrl_WIRE_ctrlBranch, _GEN_60) @[Decoder.scala 26:11 48:18]
    node _GEN_70 = mux(_T, _io_ctrl_WIRE_ctrlJump, _GEN_61) @[Decoder.scala 26:11 48:18]
    io_ctrl_ctrlJump <= _GEN_70
    io_ctrl_ctrlBranch <= _GEN_69
    io_ctrl_ctrlRegWrite <= _GEN_62
    io_ctrl_ctrlMemRead <= _GEN_66
    io_ctrl_ctrlMemWrite <= _GEN_68
    io_ctrl_ctrlALUSrc <= _GEN_64
    io_ctrl_ctrlALUOp <= _GEN_63
    io_ctrl_ctrlMemToReg <= _GEN_67
    io_regs_rs1_addr <= rs1 @[Decoder.scala 27:20]
    io_regs_rs2_addr <= rs2 @[Decoder.scala 28:20]
    io_regs_rd_addr <= rd @[Decoder.scala 29:20]
    io_imm <= _GEN_65

  module Regfile :
    input clock : Clock
    input reset : UInt<1>
    input io_rs1_addr : UInt<5>
    input io_rs2_addr : UInt<5>
    output io_rs1_data : UInt<32>
    output io_rs2_data : UInt<32>
    input io_rd_addr : UInt<5>
    input io_rd_data : UInt<32>
    input io_reg_write : UInt<1>

    reg regs_0 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_0) @[Regfile.scala 71:19]
    reg regs_1 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_1) @[Regfile.scala 71:19]
    reg regs_2 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_2) @[Regfile.scala 71:19]
    reg regs_3 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_3) @[Regfile.scala 71:19]
    reg regs_4 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_4) @[Regfile.scala 71:19]
    reg regs_5 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_5) @[Regfile.scala 71:19]
    reg regs_6 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_6) @[Regfile.scala 71:19]
    reg regs_7 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_7) @[Regfile.scala 71:19]
    reg regs_8 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_8) @[Regfile.scala 71:19]
    reg regs_9 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_9) @[Regfile.scala 71:19]
    reg regs_10 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_10) @[Regfile.scala 71:19]
    reg regs_11 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_11) @[Regfile.scala 71:19]
    reg regs_12 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_12) @[Regfile.scala 71:19]
    reg regs_13 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_13) @[Regfile.scala 71:19]
    reg regs_14 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_14) @[Regfile.scala 71:19]
    reg regs_15 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_15) @[Regfile.scala 71:19]
    reg regs_16 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_16) @[Regfile.scala 71:19]
    reg regs_17 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_17) @[Regfile.scala 71:19]
    reg regs_18 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_18) @[Regfile.scala 71:19]
    reg regs_19 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_19) @[Regfile.scala 71:19]
    reg regs_20 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_20) @[Regfile.scala 71:19]
    reg regs_21 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_21) @[Regfile.scala 71:19]
    reg regs_22 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_22) @[Regfile.scala 71:19]
    reg regs_23 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_23) @[Regfile.scala 71:19]
    reg regs_24 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_24) @[Regfile.scala 71:19]
    reg regs_25 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_25) @[Regfile.scala 71:19]
    reg regs_26 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_26) @[Regfile.scala 71:19]
    reg regs_27 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_27) @[Regfile.scala 71:19]
    reg regs_28 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_28) @[Regfile.scala 71:19]
    reg regs_29 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_29) @[Regfile.scala 71:19]
    reg regs_30 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_30) @[Regfile.scala 71:19]
    reg regs_31 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_31) @[Regfile.scala 71:19]
    node _bypass_rs1_T = eq(io_rd_addr, io_rs1_addr) @[Regfile.scala 80:50]
    node _bypass_rs1_T_1 = and(io_reg_write, _bypass_rs1_T) @[Regfile.scala 80:35]
    node _bypass_rs1_T_2 = neq(io_rs1_addr, UInt<1>("h0")) @[Regfile.scala 80:83]
    node bypass_rs1 = and(_bypass_rs1_T_1, _bypass_rs1_T_2) @[Regfile.scala 80:67]
    node _bypass_rs2_T = eq(io_rd_addr, io_rs2_addr) @[Regfile.scala 81:50]
    node _bypass_rs2_T_1 = and(io_reg_write, _bypass_rs2_T) @[Regfile.scala 81:35]
    node _bypass_rs2_T_2 = neq(io_rs2_addr, UInt<1>("h0")) @[Regfile.scala 81:83]
    node bypass_rs2 = and(_bypass_rs2_T_1, _bypass_rs2_T_2) @[Regfile.scala 81:67]
    node _GEN_0 = validif(eq(UInt<1>("h0"), io_rs1_addr), regs_0) @[Regfile.scala 84:{23,23}]
    node _GEN_1 = mux(eq(UInt<1>("h1"), io_rs1_addr), regs_1, _GEN_0) @[Regfile.scala 84:{23,23}]
    node _GEN_2 = mux(eq(UInt<2>("h2"), io_rs1_addr), regs_2, _GEN_1) @[Regfile.scala 84:{23,23}]
    node _GEN_3 = mux(eq(UInt<2>("h3"), io_rs1_addr), regs_3, _GEN_2) @[Regfile.scala 84:{23,23}]
    node _GEN_4 = mux(eq(UInt<3>("h4"), io_rs1_addr), regs_4, _GEN_3) @[Regfile.scala 84:{23,23}]
    node _GEN_5 = mux(eq(UInt<3>("h5"), io_rs1_addr), regs_5, _GEN_4) @[Regfile.scala 84:{23,23}]
    node _GEN_6 = mux(eq(UInt<3>("h6"), io_rs1_addr), regs_6, _GEN_5) @[Regfile.scala 84:{23,23}]
    node _GEN_7 = mux(eq(UInt<3>("h7"), io_rs1_addr), regs_7, _GEN_6) @[Regfile.scala 84:{23,23}]
    node _GEN_8 = mux(eq(UInt<4>("h8"), io_rs1_addr), regs_8, _GEN_7) @[Regfile.scala 84:{23,23}]
    node _GEN_9 = mux(eq(UInt<4>("h9"), io_rs1_addr), regs_9, _GEN_8) @[Regfile.scala 84:{23,23}]
    node _GEN_10 = mux(eq(UInt<4>("ha"), io_rs1_addr), regs_10, _GEN_9) @[Regfile.scala 84:{23,23}]
    node _GEN_11 = mux(eq(UInt<4>("hb"), io_rs1_addr), regs_11, _GEN_10) @[Regfile.scala 84:{23,23}]
    node _GEN_12 = mux(eq(UInt<4>("hc"), io_rs1_addr), regs_12, _GEN_11) @[Regfile.scala 84:{23,23}]
    node _GEN_13 = mux(eq(UInt<4>("hd"), io_rs1_addr), regs_13, _GEN_12) @[Regfile.scala 84:{23,23}]
    node _GEN_14 = mux(eq(UInt<4>("he"), io_rs1_addr), regs_14, _GEN_13) @[Regfile.scala 84:{23,23}]
    node _GEN_15 = mux(eq(UInt<4>("hf"), io_rs1_addr), regs_15, _GEN_14) @[Regfile.scala 84:{23,23}]
    node _GEN_16 = mux(eq(UInt<5>("h10"), io_rs1_addr), regs_16, _GEN_15) @[Regfile.scala 84:{23,23}]
    node _GEN_17 = mux(eq(UInt<5>("h11"), io_rs1_addr), regs_17, _GEN_16) @[Regfile.scala 84:{23,23}]
    node _GEN_18 = mux(eq(UInt<5>("h12"), io_rs1_addr), regs_18, _GEN_17) @[Regfile.scala 84:{23,23}]
    node _GEN_19 = mux(eq(UInt<5>("h13"), io_rs1_addr), regs_19, _GEN_18) @[Regfile.scala 84:{23,23}]
    node _GEN_20 = mux(eq(UInt<5>("h14"), io_rs1_addr), regs_20, _GEN_19) @[Regfile.scala 84:{23,23}]
    node _GEN_21 = mux(eq(UInt<5>("h15"), io_rs1_addr), regs_21, _GEN_20) @[Regfile.scala 84:{23,23}]
    node _GEN_22 = mux(eq(UInt<5>("h16"), io_rs1_addr), regs_22, _GEN_21) @[Regfile.scala 84:{23,23}]
    node _GEN_23 = mux(eq(UInt<5>("h17"), io_rs1_addr), regs_23, _GEN_22) @[Regfile.scala 84:{23,23}]
    node _GEN_24 = mux(eq(UInt<5>("h18"), io_rs1_addr), regs_24, _GEN_23) @[Regfile.scala 84:{23,23}]
    node _GEN_25 = mux(eq(UInt<5>("h19"), io_rs1_addr), regs_25, _GEN_24) @[Regfile.scala 84:{23,23}]
    node _GEN_26 = mux(eq(UInt<5>("h1a"), io_rs1_addr), regs_26, _GEN_25) @[Regfile.scala 84:{23,23}]
    node _GEN_27 = mux(eq(UInt<5>("h1b"), io_rs1_addr), regs_27, _GEN_26) @[Regfile.scala 84:{23,23}]
    node _GEN_28 = mux(eq(UInt<5>("h1c"), io_rs1_addr), regs_28, _GEN_27) @[Regfile.scala 84:{23,23}]
    node _GEN_29 = mux(eq(UInt<5>("h1d"), io_rs1_addr), regs_29, _GEN_28) @[Regfile.scala 84:{23,23}]
    node _GEN_30 = mux(eq(UInt<5>("h1e"), io_rs1_addr), regs_30, _GEN_29) @[Regfile.scala 84:{23,23}]
    node _GEN_31 = mux(eq(UInt<5>("h1f"), io_rs1_addr), regs_31, _GEN_30) @[Regfile.scala 84:{23,23}]
    node _regs_io_rs1_addr = _GEN_31 @[Regfile.scala 84:23]
    node _io_rs1_data_T = mux(bypass_rs1, io_rd_data, _regs_io_rs1_addr) @[Regfile.scala 84:23]
    node _GEN_32 = validif(eq(UInt<1>("h0"), io_rs2_addr), regs_0) @[Regfile.scala 85:{23,23}]
    node _GEN_33 = mux(eq(UInt<1>("h1"), io_rs2_addr), regs_1, _GEN_32) @[Regfile.scala 85:{23,23}]
    node _GEN_34 = mux(eq(UInt<2>("h2"), io_rs2_addr), regs_2, _GEN_33) @[Regfile.scala 85:{23,23}]
    node _GEN_35 = mux(eq(UInt<2>("h3"), io_rs2_addr), regs_3, _GEN_34) @[Regfile.scala 85:{23,23}]
    node _GEN_36 = mux(eq(UInt<3>("h4"), io_rs2_addr), regs_4, _GEN_35) @[Regfile.scala 85:{23,23}]
    node _GEN_37 = mux(eq(UInt<3>("h5"), io_rs2_addr), regs_5, _GEN_36) @[Regfile.scala 85:{23,23}]
    node _GEN_38 = mux(eq(UInt<3>("h6"), io_rs2_addr), regs_6, _GEN_37) @[Regfile.scala 85:{23,23}]
    node _GEN_39 = mux(eq(UInt<3>("h7"), io_rs2_addr), regs_7, _GEN_38) @[Regfile.scala 85:{23,23}]
    node _GEN_40 = mux(eq(UInt<4>("h8"), io_rs2_addr), regs_8, _GEN_39) @[Regfile.scala 85:{23,23}]
    node _GEN_41 = mux(eq(UInt<4>("h9"), io_rs2_addr), regs_9, _GEN_40) @[Regfile.scala 85:{23,23}]
    node _GEN_42 = mux(eq(UInt<4>("ha"), io_rs2_addr), regs_10, _GEN_41) @[Regfile.scala 85:{23,23}]
    node _GEN_43 = mux(eq(UInt<4>("hb"), io_rs2_addr), regs_11, _GEN_42) @[Regfile.scala 85:{23,23}]
    node _GEN_44 = mux(eq(UInt<4>("hc"), io_rs2_addr), regs_12, _GEN_43) @[Regfile.scala 85:{23,23}]
    node _GEN_45 = mux(eq(UInt<4>("hd"), io_rs2_addr), regs_13, _GEN_44) @[Regfile.scala 85:{23,23}]
    node _GEN_46 = mux(eq(UInt<4>("he"), io_rs2_addr), regs_14, _GEN_45) @[Regfile.scala 85:{23,23}]
    node _GEN_47 = mux(eq(UInt<4>("hf"), io_rs2_addr), regs_15, _GEN_46) @[Regfile.scala 85:{23,23}]
    node _GEN_48 = mux(eq(UInt<5>("h10"), io_rs2_addr), regs_16, _GEN_47) @[Regfile.scala 85:{23,23}]
    node _GEN_49 = mux(eq(UInt<5>("h11"), io_rs2_addr), regs_17, _GEN_48) @[Regfile.scala 85:{23,23}]
    node _GEN_50 = mux(eq(UInt<5>("h12"), io_rs2_addr), regs_18, _GEN_49) @[Regfile.scala 85:{23,23}]
    node _GEN_51 = mux(eq(UInt<5>("h13"), io_rs2_addr), regs_19, _GEN_50) @[Regfile.scala 85:{23,23}]
    node _GEN_52 = mux(eq(UInt<5>("h14"), io_rs2_addr), regs_20, _GEN_51) @[Regfile.scala 85:{23,23}]
    node _GEN_53 = mux(eq(UInt<5>("h15"), io_rs2_addr), regs_21, _GEN_52) @[Regfile.scala 85:{23,23}]
    node _GEN_54 = mux(eq(UInt<5>("h16"), io_rs2_addr), regs_22, _GEN_53) @[Regfile.scala 85:{23,23}]
    node _GEN_55 = mux(eq(UInt<5>("h17"), io_rs2_addr), regs_23, _GEN_54) @[Regfile.scala 85:{23,23}]
    node _GEN_56 = mux(eq(UInt<5>("h18"), io_rs2_addr), regs_24, _GEN_55) @[Regfile.scala 85:{23,23}]
    node _GEN_57 = mux(eq(UInt<5>("h19"), io_rs2_addr), regs_25, _GEN_56) @[Regfile.scala 85:{23,23}]
    node _GEN_58 = mux(eq(UInt<5>("h1a"), io_rs2_addr), regs_26, _GEN_57) @[Regfile.scala 85:{23,23}]
    node _GEN_59 = mux(eq(UInt<5>("h1b"), io_rs2_addr), regs_27, _GEN_58) @[Regfile.scala 85:{23,23}]
    node _GEN_60 = mux(eq(UInt<5>("h1c"), io_rs2_addr), regs_28, _GEN_59) @[Regfile.scala 85:{23,23}]
    node _GEN_61 = mux(eq(UInt<5>("h1d"), io_rs2_addr), regs_29, _GEN_60) @[Regfile.scala 85:{23,23}]
    node _GEN_62 = mux(eq(UInt<5>("h1e"), io_rs2_addr), regs_30, _GEN_61) @[Regfile.scala 85:{23,23}]
    node _GEN_63 = mux(eq(UInt<5>("h1f"), io_rs2_addr), regs_31, _GEN_62) @[Regfile.scala 85:{23,23}]
    node _regs_io_rs2_addr = _GEN_63 @[Regfile.scala 85:23]
    node _io_rs2_data_T = mux(bypass_rs2, io_rd_data, _regs_io_rs2_addr) @[Regfile.scala 85:23]
    node _T = eq(io_rs1_addr, UInt<1>("h0")) @[Regfile.scala 88:22]
    node _GEN_64 = mux(_T, UInt<1>("h0"), _io_rs1_data_T) @[Regfile.scala 84:17 88:{31,45}]
    node _T_1 = eq(io_rs2_addr, UInt<1>("h0")) @[Regfile.scala 89:22]
    node _GEN_65 = mux(_T_1, UInt<1>("h0"), _io_rs2_data_T) @[Regfile.scala 85:17 89:{31,45}]
    node _T_2 = neq(io_rd_addr, UInt<1>("h0")) @[Regfile.scala 93:37]
    node _T_3 = and(io_reg_write, _T_2) @[Regfile.scala 93:23]
    node _regs_io_rd_addr = io_rd_data @[Regfile.scala 94:{26,26}]
    node _GEN_66 = mux(eq(UInt<1>("h0"), io_rd_addr), _regs_io_rd_addr, regs_0) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_67 = mux(eq(UInt<1>("h1"), io_rd_addr), _regs_io_rd_addr, regs_1) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_68 = mux(eq(UInt<2>("h2"), io_rd_addr), _regs_io_rd_addr, regs_2) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_69 = mux(eq(UInt<2>("h3"), io_rd_addr), _regs_io_rd_addr, regs_3) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_70 = mux(eq(UInt<3>("h4"), io_rd_addr), _regs_io_rd_addr, regs_4) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_71 = mux(eq(UInt<3>("h5"), io_rd_addr), _regs_io_rd_addr, regs_5) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_72 = mux(eq(UInt<3>("h6"), io_rd_addr), _regs_io_rd_addr, regs_6) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_73 = mux(eq(UInt<3>("h7"), io_rd_addr), _regs_io_rd_addr, regs_7) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_74 = mux(eq(UInt<4>("h8"), io_rd_addr), _regs_io_rd_addr, regs_8) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_75 = mux(eq(UInt<4>("h9"), io_rd_addr), _regs_io_rd_addr, regs_9) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_76 = mux(eq(UInt<4>("ha"), io_rd_addr), _regs_io_rd_addr, regs_10) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_77 = mux(eq(UInt<4>("hb"), io_rd_addr), _regs_io_rd_addr, regs_11) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_78 = mux(eq(UInt<4>("hc"), io_rd_addr), _regs_io_rd_addr, regs_12) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_79 = mux(eq(UInt<4>("hd"), io_rd_addr), _regs_io_rd_addr, regs_13) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_80 = mux(eq(UInt<4>("he"), io_rd_addr), _regs_io_rd_addr, regs_14) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_81 = mux(eq(UInt<4>("hf"), io_rd_addr), _regs_io_rd_addr, regs_15) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_82 = mux(eq(UInt<5>("h10"), io_rd_addr), _regs_io_rd_addr, regs_16) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_83 = mux(eq(UInt<5>("h11"), io_rd_addr), _regs_io_rd_addr, regs_17) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_84 = mux(eq(UInt<5>("h12"), io_rd_addr), _regs_io_rd_addr, regs_18) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_85 = mux(eq(UInt<5>("h13"), io_rd_addr), _regs_io_rd_addr, regs_19) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_86 = mux(eq(UInt<5>("h14"), io_rd_addr), _regs_io_rd_addr, regs_20) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_87 = mux(eq(UInt<5>("h15"), io_rd_addr), _regs_io_rd_addr, regs_21) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_88 = mux(eq(UInt<5>("h16"), io_rd_addr), _regs_io_rd_addr, regs_22) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_89 = mux(eq(UInt<5>("h17"), io_rd_addr), _regs_io_rd_addr, regs_23) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_90 = mux(eq(UInt<5>("h18"), io_rd_addr), _regs_io_rd_addr, regs_24) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_91 = mux(eq(UInt<5>("h19"), io_rd_addr), _regs_io_rd_addr, regs_25) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_92 = mux(eq(UInt<5>("h1a"), io_rd_addr), _regs_io_rd_addr, regs_26) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_93 = mux(eq(UInt<5>("h1b"), io_rd_addr), _regs_io_rd_addr, regs_27) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_94 = mux(eq(UInt<5>("h1c"), io_rd_addr), _regs_io_rd_addr, regs_28) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_95 = mux(eq(UInt<5>("h1d"), io_rd_addr), _regs_io_rd_addr, regs_29) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_96 = mux(eq(UInt<5>("h1e"), io_rd_addr), _regs_io_rd_addr, regs_30) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_97 = mux(eq(UInt<5>("h1f"), io_rd_addr), _regs_io_rd_addr, regs_31) @[Regfile.scala 71:19 94:{26,26}]
    node _GEN_98 = mux(_T_3, _GEN_66, regs_0) @[Regfile.scala 71:19 93:46]
    node _GEN_99 = mux(_T_3, _GEN_67, regs_1) @[Regfile.scala 71:19 93:46]
    node _GEN_100 = mux(_T_3, _GEN_68, regs_2) @[Regfile.scala 71:19 93:46]
    node _GEN_101 = mux(_T_3, _GEN_69, regs_3) @[Regfile.scala 71:19 93:46]
    node _GEN_102 = mux(_T_3, _GEN_70, regs_4) @[Regfile.scala 71:19 93:46]
    node _GEN_103 = mux(_T_3, _GEN_71, regs_5) @[Regfile.scala 71:19 93:46]
    node _GEN_104 = mux(_T_3, _GEN_72, regs_6) @[Regfile.scala 71:19 93:46]
    node _GEN_105 = mux(_T_3, _GEN_73, regs_7) @[Regfile.scala 71:19 93:46]
    node _GEN_106 = mux(_T_3, _GEN_74, regs_8) @[Regfile.scala 71:19 93:46]
    node _GEN_107 = mux(_T_3, _GEN_75, regs_9) @[Regfile.scala 71:19 93:46]
    node _GEN_108 = mux(_T_3, _GEN_76, regs_10) @[Regfile.scala 71:19 93:46]
    node _GEN_109 = mux(_T_3, _GEN_77, regs_11) @[Regfile.scala 71:19 93:46]
    node _GEN_110 = mux(_T_3, _GEN_78, regs_12) @[Regfile.scala 71:19 93:46]
    node _GEN_111 = mux(_T_3, _GEN_79, regs_13) @[Regfile.scala 71:19 93:46]
    node _GEN_112 = mux(_T_3, _GEN_80, regs_14) @[Regfile.scala 71:19 93:46]
    node _GEN_113 = mux(_T_3, _GEN_81, regs_15) @[Regfile.scala 71:19 93:46]
    node _GEN_114 = mux(_T_3, _GEN_82, regs_16) @[Regfile.scala 71:19 93:46]
    node _GEN_115 = mux(_T_3, _GEN_83, regs_17) @[Regfile.scala 71:19 93:46]
    node _GEN_116 = mux(_T_3, _GEN_84, regs_18) @[Regfile.scala 71:19 93:46]
    node _GEN_117 = mux(_T_3, _GEN_85, regs_19) @[Regfile.scala 71:19 93:46]
    node _GEN_118 = mux(_T_3, _GEN_86, regs_20) @[Regfile.scala 71:19 93:46]
    node _GEN_119 = mux(_T_3, _GEN_87, regs_21) @[Regfile.scala 71:19 93:46]
    node _GEN_120 = mux(_T_3, _GEN_88, regs_22) @[Regfile.scala 71:19 93:46]
    node _GEN_121 = mux(_T_3, _GEN_89, regs_23) @[Regfile.scala 71:19 93:46]
    node _GEN_122 = mux(_T_3, _GEN_90, regs_24) @[Regfile.scala 71:19 93:46]
    node _GEN_123 = mux(_T_3, _GEN_91, regs_25) @[Regfile.scala 71:19 93:46]
    node _GEN_124 = mux(_T_3, _GEN_92, regs_26) @[Regfile.scala 71:19 93:46]
    node _GEN_125 = mux(_T_3, _GEN_93, regs_27) @[Regfile.scala 71:19 93:46]
    node _GEN_126 = mux(_T_3, _GEN_94, regs_28) @[Regfile.scala 71:19 93:46]
    node _GEN_127 = mux(_T_3, _GEN_95, regs_29) @[Regfile.scala 71:19 93:46]
    node _GEN_128 = mux(_T_3, _GEN_96, regs_30) @[Regfile.scala 71:19 93:46]
    node _GEN_129 = mux(_T_3, _GEN_97, regs_31) @[Regfile.scala 71:19 93:46]
    io_rs1_data <= _GEN_64
    io_rs2_data <= _GEN_65
    regs_0 <= _GEN_98
    regs_1 <= _GEN_99
    regs_2 <= _GEN_100
    regs_3 <= _GEN_101
    regs_4 <= _GEN_102
    regs_5 <= _GEN_103
    regs_6 <= _GEN_104
    regs_7 <= _GEN_105
    regs_8 <= _GEN_106
    regs_9 <= _GEN_107
    regs_10 <= _GEN_108
    regs_11 <= _GEN_109
    regs_12 <= _GEN_110
    regs_13 <= _GEN_111
    regs_14 <= _GEN_112
    regs_15 <= _GEN_113
    regs_16 <= _GEN_114
    regs_17 <= _GEN_115
    regs_18 <= _GEN_116
    regs_19 <= _GEN_117
    regs_20 <= _GEN_118
    regs_21 <= _GEN_119
    regs_22 <= _GEN_120
    regs_23 <= _GEN_121
    regs_24 <= _GEN_122
    regs_25 <= _GEN_123
    regs_26 <= _GEN_124
    regs_27 <= _GEN_125
    regs_28 <= _GEN_126
    regs_29 <= _GEN_127
    regs_30 <= _GEN_128
    regs_31 <= _GEN_129

  module Alu :
    input clock : Clock
    input reset : UInt<1>
    input io_src1 : UInt<32>
    input io_src2 : UInt<32>
    input io_pc : UInt<32>
    input io_imm : UInt<32>
    input io_aluOp : UInt<5>
    output io_to_branch : UInt<1>
    output io_alu_result : UInt<32>
    output io_jump_addr : UInt<32>

    node shamt = bits(io_src2, 4, 0) @[Alu.scala 28:22]
    node src1_s = asSInt(io_src1) @[Alu.scala 29:24]
    node src2_s = asSInt(io_src2) @[Alu.scala 30:24]
    node _T = eq(UInt<1>("h1"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T = add(io_src1, io_src2) @[Alu.scala 36:42]
    node _alu_result_T_1 = tail(_alu_result_T, 1) @[Alu.scala 36:42]
    node _T_1 = eq(UInt<2>("h2"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_2 = sub(io_src1, io_src2) @[Alu.scala 37:42]
    node _alu_result_T_3 = tail(_alu_result_T_2, 1) @[Alu.scala 37:42]
    node _T_2 = eq(UInt<2>("h3"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_4 = and(io_src1, io_src2) @[Alu.scala 38:42]
    node _T_3 = eq(UInt<3>("h4"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_5 = or(io_src1, io_src2) @[Alu.scala 39:42]
    node _T_4 = eq(UInt<3>("h5"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_6 = xor(io_src1, io_src2) @[Alu.scala 40:42]
    node _T_5 = eq(UInt<3>("h6"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_7 = lt(src1_s, src2_s) @[Alu.scala 41:42]
    node _T_6 = eq(UInt<3>("h7"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_8 = dshl(io_src1, shamt) @[Alu.scala 42:42]
    node _T_7 = eq(UInt<4>("h8"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_9 = dshr(io_src1, shamt) @[Alu.scala 43:42]
    node _T_8 = eq(UInt<4>("h9"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_10 = dshr(src1_s, shamt) @[Alu.scala 44:42]
    node _alu_result_T_11 = asUInt(_alu_result_T_10) @[Alu.scala 44:52]
    node _T_9 = eq(UInt<5>("h10"), io_aluOp) @[Alu.scala 32:20]
    node _T_10 = eq(UInt<5>("h11"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_12 = add(io_pc, io_imm) @[Alu.scala 50:40]
    node _alu_result_T_13 = tail(_alu_result_T_12, 1) @[Alu.scala 50:40]
    node _T_11 = eq(UInt<4>("ha"), io_aluOp) @[Alu.scala 32:20]
    node _to_branch_T = eq(io_src1, io_src2) @[Alu.scala 57:29]
    node _jump_addr_T = add(io_pc, io_imm) @[Alu.scala 58:26]
    node _jump_addr_T_1 = tail(_jump_addr_T, 1) @[Alu.scala 58:26]
    node _T_12 = eq(UInt<4>("hb"), io_aluOp) @[Alu.scala 32:20]
    node _to_branch_T_1 = neq(io_src1, io_src2) @[Alu.scala 61:29]
    node _jump_addr_T_2 = add(io_pc, io_imm) @[Alu.scala 62:26]
    node _jump_addr_T_3 = tail(_jump_addr_T_2, 1) @[Alu.scala 62:26]
    node _T_13 = eq(UInt<4>("hc"), io_aluOp) @[Alu.scala 32:20]
    node _to_branch_T_2 = lt(src1_s, src2_s) @[Alu.scala 65:28]
    node _jump_addr_T_4 = add(io_pc, io_imm) @[Alu.scala 66:26]
    node _jump_addr_T_5 = tail(_jump_addr_T_4, 1) @[Alu.scala 66:26]
    node _T_14 = eq(UInt<4>("hd"), io_aluOp) @[Alu.scala 32:20]
    node _to_branch_T_3 = geq(src1_s, src2_s) @[Alu.scala 69:28]
    node _jump_addr_T_6 = add(io_pc, io_imm) @[Alu.scala 70:26]
    node _jump_addr_T_7 = tail(_jump_addr_T_6, 1) @[Alu.scala 70:26]
    node _T_15 = eq(UInt<4>("he"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_14 = add(io_pc, UInt<3>("h4")) @[Alu.scala 78:27]
    node _alu_result_T_15 = tail(_alu_result_T_14, 1) @[Alu.scala 78:27]
    node _jump_addr_T_8 = add(io_pc, io_imm) @[Alu.scala 80:27]
    node _jump_addr_T_9 = tail(_jump_addr_T_8, 1) @[Alu.scala 80:27]
    node _T_16 = eq(UInt<4>("hf"), io_aluOp) @[Alu.scala 32:20]
    node _alu_result_T_16 = add(io_pc, UInt<3>("h4")) @[Alu.scala 84:27]
    node _alu_result_T_17 = tail(_alu_result_T_16, 1) @[Alu.scala 84:27]
    node _jump_addr_T_10 = add(io_src1, io_imm) @[Alu.scala 86:30]
    node _jump_addr_T_11 = tail(_jump_addr_T_10, 1) @[Alu.scala 86:30]
    node _jump_addr_T_12 = not(UInt<32>("h1")) @[Alu.scala 86:43]
    node _jump_addr_T_13 = and(_jump_addr_T_11, _jump_addr_T_12) @[Alu.scala 86:40]
    node _T_17 = eq(UInt<1>("h0"), io_aluOp) @[Alu.scala 32:20]
    node _GEN_0 = mux(_T_16, _alu_result_T_17, UInt<32>("h0")) @[Alu.scala 32:20 84:18]
    node _GEN_1 = mux(_T_16, UInt<1>("h1"), UInt<1>("h0")) @[Alu.scala 32:20 85:18]
    node _GEN_2 = mux(_T_16, _jump_addr_T_13, UInt<32>("h0")) @[Alu.scala 32:20 86:18]
    node _GEN_3 = mux(_T_15, _alu_result_T_15, _GEN_0) @[Alu.scala 32:20 78:18]
    node _GEN_4 = mux(_T_15, UInt<1>("h1"), _GEN_1) @[Alu.scala 32:20 79:18]
    node _GEN_5 = mux(_T_15, _jump_addr_T_9, _GEN_2) @[Alu.scala 32:20 80:18]
    node _GEN_6 = mux(_T_14, _to_branch_T_3, _GEN_4) @[Alu.scala 32:20 69:17]
    node _GEN_7 = mux(_T_14, _jump_addr_T_7, _GEN_5) @[Alu.scala 32:20 70:17]
    node _GEN_8 = mux(_T_14, UInt<32>("h0"), _GEN_3) @[Alu.scala 32:20]
    node _GEN_9 = mux(_T_13, _to_branch_T_2, _GEN_6) @[Alu.scala 32:20 65:17]
    node _GEN_10 = mux(_T_13, _jump_addr_T_5, _GEN_7) @[Alu.scala 32:20 66:17]
    node _GEN_11 = mux(_T_13, UInt<32>("h0"), _GEN_8) @[Alu.scala 32:20]
    node _GEN_12 = mux(_T_12, _to_branch_T_1, _GEN_9) @[Alu.scala 32:20 61:17]
    node _GEN_13 = mux(_T_12, _jump_addr_T_3, _GEN_10) @[Alu.scala 32:20 62:17]
    node _GEN_14 = mux(_T_12, UInt<32>("h0"), _GEN_11) @[Alu.scala 32:20]
    node _GEN_15 = mux(_T_11, _to_branch_T, _GEN_12) @[Alu.scala 32:20 57:17]
    node _GEN_16 = mux(_T_11, _jump_addr_T_1, _GEN_13) @[Alu.scala 32:20 58:17]
    node _GEN_17 = mux(_T_11, UInt<32>("h0"), _GEN_14) @[Alu.scala 32:20]
    node _GEN_18 = mux(_T_10, _alu_result_T_13, _GEN_17) @[Alu.scala 32:20 50:31]
    node _GEN_19 = mux(_T_10, UInt<1>("h0"), _GEN_15) @[Alu.scala 32:20]
    node _GEN_20 = mux(_T_10, UInt<32>("h0"), _GEN_16) @[Alu.scala 32:20]
    node _GEN_21 = mux(_T_9, io_imm, _GEN_18) @[Alu.scala 32:20 49:31]
    node _GEN_22 = mux(_T_9, UInt<1>("h0"), _GEN_19) @[Alu.scala 32:20]
    node _GEN_23 = mux(_T_9, UInt<32>("h0"), _GEN_20) @[Alu.scala 32:20]
    node _GEN_24 = mux(_T_8, _alu_result_T_11, _GEN_21) @[Alu.scala 32:20 44:31]
    node _GEN_25 = mux(_T_8, UInt<1>("h0"), _GEN_22) @[Alu.scala 32:20]
    node _GEN_26 = mux(_T_8, UInt<32>("h0"), _GEN_23) @[Alu.scala 32:20]
    node _GEN_27 = mux(_T_7, _alu_result_T_9, _GEN_24) @[Alu.scala 32:20 43:31]
    node _GEN_28 = mux(_T_7, UInt<1>("h0"), _GEN_25) @[Alu.scala 32:20]
    node _GEN_29 = mux(_T_7, UInt<32>("h0"), _GEN_26) @[Alu.scala 32:20]
    node _GEN_30 = mux(_T_6, _alu_result_T_8, _GEN_27) @[Alu.scala 32:20 42:31]
    node _GEN_31 = mux(_T_6, UInt<1>("h0"), _GEN_28) @[Alu.scala 32:20]
    node _GEN_32 = mux(_T_6, UInt<32>("h0"), _GEN_29) @[Alu.scala 32:20]
    node _GEN_33 = mux(_T_5, _alu_result_T_7, _GEN_30) @[Alu.scala 32:20 41:31]
    node _GEN_34 = mux(_T_5, UInt<1>("h0"), _GEN_31) @[Alu.scala 32:20]
    node _GEN_35 = mux(_T_5, UInt<32>("h0"), _GEN_32) @[Alu.scala 32:20]
    node _GEN_36 = mux(_T_4, _alu_result_T_6, _GEN_33) @[Alu.scala 32:20 40:31]
    node _GEN_37 = mux(_T_4, UInt<1>("h0"), _GEN_34) @[Alu.scala 32:20]
    node _GEN_38 = mux(_T_4, UInt<32>("h0"), _GEN_35) @[Alu.scala 32:20]
    node _GEN_39 = mux(_T_3, _alu_result_T_5, _GEN_36) @[Alu.scala 32:20 39:31]
    node _GEN_40 = mux(_T_3, UInt<1>("h0"), _GEN_37) @[Alu.scala 32:20]
    node _GEN_41 = mux(_T_3, UInt<32>("h0"), _GEN_38) @[Alu.scala 32:20]
    node _GEN_42 = mux(_T_2, _alu_result_T_4, _GEN_39) @[Alu.scala 32:20 38:31]
    node _GEN_43 = mux(_T_2, UInt<1>("h0"), _GEN_40) @[Alu.scala 32:20]
    node _GEN_44 = mux(_T_2, UInt<32>("h0"), _GEN_41) @[Alu.scala 32:20]
    node _GEN_45 = mux(_T_1, _alu_result_T_3, _GEN_42) @[Alu.scala 32:20 37:31]
    node _GEN_46 = mux(_T_1, UInt<1>("h0"), _GEN_43) @[Alu.scala 32:20]
    node _GEN_47 = mux(_T_1, UInt<32>("h0"), _GEN_44) @[Alu.scala 32:20]
    node _GEN_48 = mux(_T, _alu_result_T_1, _GEN_45) @[Alu.scala 32:20 36:31]
    node _GEN_49 = mux(_T, UInt<1>("h0"), _GEN_46) @[Alu.scala 32:20]
    node _GEN_50 = mux(_T, UInt<32>("h0"), _GEN_47) @[Alu.scala 32:20]
    node to_branch = _GEN_49
    node alu_result = bits(_GEN_48, 31, 0)
    node jump_addr = _GEN_50
    io_to_branch <= to_branch @[Alu.scala 98:17]
    io_alu_result <= alu_result @[Alu.scala 97:17]
    io_jump_addr <= jump_addr @[Alu.scala 99:17]

  module DataMem :
    input clock : Clock
    input reset : UInt<1>
    input io_ctrlMemRead : UInt<1>
    input io_ctrlMemWrite : UInt<1>
    input io_addr : UInt<32>
    input io_data_in : UInt<32>
    output io_data_out : UInt<32>
    output io_peek_write : UInt<1>

    mem mem : @[DataMem.scala 23:20]
      data-type => UInt<32>
      depth => 1024
      read-latency => 1
      write-latency => 1
      reader => io_data_out_MPORT
      writer => MPORT
      read-under-write => undefined
    node index = dshr(io_addr, UInt<2>("h2")) @[DataMem.scala 29:25]
    node _T = bits(index, 9, 0)
    node _GEN_0 = validif(io_ctrlMemWrite, _T) @[DataMem.scala 32:27]
    node _GEN_1 = validif(io_ctrlMemWrite, clock) @[DataMem.scala 32:27]
    node _GEN_2 = mux(io_ctrlMemWrite, UInt<1>("h1"), UInt<1>("h0")) @[DataMem.scala 23:20 32:27]
    node _GEN_3 = validif(io_ctrlMemWrite, UInt<1>("h1")) @[DataMem.scala 32:27]
    node _GEN_4 = validif(io_ctrlMemWrite, io_data_in) @[DataMem.scala 32:27]
    node _GEN_5 = validif(UInt<1>("h1"), index) @[DataMem.scala 38:{48,48}]
    node _io_data_out_WIRE = _GEN_5 @[DataMem.scala 38:48]
    node _io_data_out_T = or(_io_data_out_WIRE, UInt<10>("h0")) @[DataMem.scala 38:48]
    node _io_data_out_T_1 = bits(_io_data_out_T, 9, 0) @[DataMem.scala 38:48]
    node _GEN_6 = mux(UInt<1>("h1"), UInt<1>("h1"), UInt<1>("h0")) @[DataMem.scala 23:20 38:{48,48}]
    node _GEN_7 = validif(UInt<1>("h1"), _io_data_out_T_1) @[DataMem.scala 38:{48,48}]
    node _GEN_8 = validif(UInt<1>("h1"), clock) @[DataMem.scala 38:{48,48}]
    node _io_data_out_T_2 = mux(io_ctrlMemRead, mem.io_data_out_MPORT.data, UInt<1>("h0")) @[DataMem.scala 38:23]
    node peek_write = _GEN_2
    io_data_out <= _io_data_out_T_2 @[DataMem.scala 38:17]
    io_peek_write <= peek_write @[DataMem.scala 37:19]
    mem.io_data_out_MPORT.addr <= _GEN_7
    mem.io_data_out_MPORT.en <= _GEN_6
    mem.io_data_out_MPORT.clk <= _GEN_8
    mem.MPORT.addr <= _GEN_0
    mem.MPORT.en <= _GEN_2
    mem.MPORT.clk <= _GEN_1
    mem.MPORT.data <= _GEN_4
    mem.MPORT.mask <= _GEN_3

  module Reg_IF_ID :
    input clock : Clock
    input reset : UInt<1>
    input io_in_pc : UInt<32>
    input io_in_inst : UInt<32>
    input io_stall : UInt<1>
    input io_flush : UInt<1>
    output io_out_pc : UInt<32>
    output io_out_inst : UInt<32>

    reg pc_if : UInt<32>, clock with :
      reset => (UInt<1>("h0"), pc_if) @[Reg_IF_ID.scala 19:24]
    reg inst_if : UInt<32>, clock with :
      reset => (UInt<1>("h0"), inst_if) @[Reg_IF_ID.scala 20:24]
    node _T = eq(io_stall, UInt<1>("h0")) @[Reg_IF_ID.scala 25:16]
    node _GEN_0 = mux(_T, io_in_pc, pc_if) @[Reg_IF_ID.scala 25:27 26:13 19:24]
    node _GEN_1 = mux(_T, io_in_inst, inst_if) @[Reg_IF_ID.scala 25:27 27:13 20:24]
    node _GEN_2 = mux(io_flush, UInt<1>("h0"), _GEN_0) @[Reg_IF_ID.scala 22:19 23:13]
    node _GEN_3 = mux(io_flush, UInt<1>("h0"), _GEN_1) @[Reg_IF_ID.scala 22:19 24:13]
    io_out_pc <= pc_if @[Reg_IF_ID.scala 30:15]
    io_out_inst <= inst_if @[Reg_IF_ID.scala 31:15]
    pc_if <= mux(reset, UInt<32>("h0"), _GEN_2) @[Reg_IF_ID.scala 19:{24,24}]
    inst_if <= mux(reset, UInt<32>("h0"), _GEN_3) @[Reg_IF_ID.scala 20:{24,24}]

  module Reg_ID_EX :
    input clock : Clock
    input reset : UInt<1>
    input io_stall : UInt<1>
    input io_flush : UInt<1>
    input io_in_ctrl_ctrlJump : UInt<1>
    input io_in_ctrl_ctrlBranch : UInt<1>
    input io_in_ctrl_ctrlRegWrite : UInt<1>
    input io_in_ctrl_ctrlMemRead : UInt<1>
    input io_in_ctrl_ctrlMemWrite : UInt<1>
    input io_in_ctrl_ctrlALUSrc : UInt<1>
    input io_in_ctrl_ctrlALUOp : UInt<5>
    input io_in_ctrl_ctrlMemToReg : UInt<1>
    input io_in_pc : UInt<32>
    input io_in_rs1_data : UInt<32>
    input io_in_rs2_data : UInt<32>
    input io_in_imm : UInt<32>
    input io_in_rd_addr : UInt<5>
    input io_in_rs1_addr : UInt<5>
    input io_in_rs2_addr : UInt<5>
    output io_out_ctrl_ctrlJump : UInt<1>
    output io_out_ctrl_ctrlBranch : UInt<1>
    output io_out_ctrl_ctrlRegWrite : UInt<1>
    output io_out_ctrl_ctrlMemRead : UInt<1>
    output io_out_ctrl_ctrlMemWrite : UInt<1>
    output io_out_ctrl_ctrlALUSrc : UInt<1>
    output io_out_ctrl_ctrlALUOp : UInt<5>
    output io_out_ctrl_ctrlMemToReg : UInt<1>
    output io_out_pc : UInt<32>
    output io_out_rs1_data : UInt<32>
    output io_out_rs2_data : UInt<32>
    output io_out_imm : UInt<32>
    output io_out_rd_addr : UInt<5>
    output io_out_rs1_addr : UInt<5>
    output io_out_rs2_addr : UInt<5>

    reg ctrl_id_ctrlJump : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlJump) @[Reg_ID_EX.scala 28:28]
    reg ctrl_id_ctrlBranch : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlBranch) @[Reg_ID_EX.scala 28:28]
    reg ctrl_id_ctrlRegWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlRegWrite) @[Reg_ID_EX.scala 28:28]
    reg ctrl_id_ctrlMemRead : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlMemRead) @[Reg_ID_EX.scala 28:28]
    reg ctrl_id_ctrlMemWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlMemWrite) @[Reg_ID_EX.scala 28:28]
    reg ctrl_id_ctrlALUSrc : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlALUSrc) @[Reg_ID_EX.scala 28:28]
    reg ctrl_id_ctrlALUOp : UInt<5>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlALUOp) @[Reg_ID_EX.scala 28:28]
    reg ctrl_id_ctrlMemToReg : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_id_ctrlMemToReg) @[Reg_ID_EX.scala 28:28]
    reg pc_id : UInt<32>, clock with :
      reset => (UInt<1>("h0"), pc_id) @[Reg_ID_EX.scala 29:28]
    reg rs1_data_id : UInt<32>, clock with :
      reset => (UInt<1>("h0"), rs1_data_id) @[Reg_ID_EX.scala 30:28]
    reg rs2_data_id : UInt<32>, clock with :
      reset => (UInt<1>("h0"), rs2_data_id) @[Reg_ID_EX.scala 31:28]
    reg imm_id : UInt<32>, clock with :
      reset => (UInt<1>("h0"), imm_id) @[Reg_ID_EX.scala 32:28]
    reg rd_addr_id : UInt<5>, clock with :
      reset => (UInt<1>("h0"), rd_addr_id) @[Reg_ID_EX.scala 33:28]
    reg rs1_addr_id : UInt<5>, clock with :
      reset => (UInt<1>("h0"), rs1_addr_id) @[Reg_ID_EX.scala 34:28]
    reg rs2_addr_id : UInt<5>, clock with :
      reset => (UInt<1>("h0"), rs2_addr_id) @[Reg_ID_EX.scala 35:28]
    node _T = eq(io_stall, UInt<1>("h0")) @[Reg_ID_EX.scala 46:16]
    node _GEN_0 = mux(_T, io_in_ctrl_ctrlMemToReg, ctrl_id_ctrlMemToReg) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_1 = mux(_T, io_in_ctrl_ctrlALUOp, ctrl_id_ctrlALUOp) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_2 = mux(_T, io_in_ctrl_ctrlALUSrc, ctrl_id_ctrlALUSrc) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_3 = mux(_T, io_in_ctrl_ctrlMemWrite, ctrl_id_ctrlMemWrite) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_4 = mux(_T, io_in_ctrl_ctrlMemRead, ctrl_id_ctrlMemRead) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_5 = mux(_T, io_in_ctrl_ctrlRegWrite, ctrl_id_ctrlRegWrite) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_6 = mux(_T, io_in_ctrl_ctrlBranch, ctrl_id_ctrlBranch) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_7 = mux(_T, io_in_ctrl_ctrlJump, ctrl_id_ctrlJump) @[Reg_ID_EX.scala 46:27 47:17 28:28]
    node _GEN_8 = mux(_T, io_in_pc, pc_id) @[Reg_ID_EX.scala 46:27 48:17 29:28]
    node _GEN_9 = mux(_T, io_in_rs1_data, rs1_data_id) @[Reg_ID_EX.scala 46:27 49:17 30:28]
    node _GEN_10 = mux(_T, io_in_rs2_data, rs2_data_id) @[Reg_ID_EX.scala 46:27 50:17 31:28]
    node _GEN_11 = mux(_T, io_in_imm, imm_id) @[Reg_ID_EX.scala 46:27 51:17 32:28]
    node _GEN_12 = mux(_T, io_in_rd_addr, rd_addr_id) @[Reg_ID_EX.scala 46:27 52:17 33:28]
    node _GEN_13 = mux(_T, io_in_rs1_addr, rs1_addr_id) @[Reg_ID_EX.scala 46:27 53:17 34:28]
    node _GEN_14 = mux(_T, io_in_rs2_addr, rs2_addr_id) @[Reg_ID_EX.scala 46:27 54:17 35:28]
    node _ctrl_id_WIRE_1_ctrlMemToReg = UInt<1>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_15 = mux(io_flush, _ctrl_id_WIRE_1_ctrlMemToReg, _GEN_0) @[Reg_ID_EX.scala 37:19 38:17]
    node _ctrl_id_WIRE_1_ctrlALUOp = UInt<5>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_16 = mux(io_flush, _ctrl_id_WIRE_1_ctrlALUOp, _GEN_1) @[Reg_ID_EX.scala 37:19 38:17]
    node _ctrl_id_WIRE_1_ctrlALUSrc = UInt<1>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_17 = mux(io_flush, _ctrl_id_WIRE_1_ctrlALUSrc, _GEN_2) @[Reg_ID_EX.scala 37:19 38:17]
    node _ctrl_id_WIRE_1_ctrlMemWrite = UInt<1>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_18 = mux(io_flush, _ctrl_id_WIRE_1_ctrlMemWrite, _GEN_3) @[Reg_ID_EX.scala 37:19 38:17]
    node _ctrl_id_WIRE_1_ctrlMemRead = UInt<1>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_19 = mux(io_flush, _ctrl_id_WIRE_1_ctrlMemRead, _GEN_4) @[Reg_ID_EX.scala 37:19 38:17]
    node _ctrl_id_WIRE_1_ctrlRegWrite = UInt<1>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_20 = mux(io_flush, _ctrl_id_WIRE_1_ctrlRegWrite, _GEN_5) @[Reg_ID_EX.scala 37:19 38:17]
    node _ctrl_id_WIRE_1_ctrlBranch = UInt<1>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_21 = mux(io_flush, _ctrl_id_WIRE_1_ctrlBranch, _GEN_6) @[Reg_ID_EX.scala 37:19 38:17]
    node _ctrl_id_WIRE_1_ctrlJump = UInt<1>("h0") @[Reg_ID_EX.scala 38:{32,32}]
    node _GEN_22 = mux(io_flush, _ctrl_id_WIRE_1_ctrlJump, _GEN_7) @[Reg_ID_EX.scala 37:19 38:17]
    node _GEN_23 = mux(io_flush, UInt<1>("h0"), _GEN_8) @[Reg_ID_EX.scala 37:19 39:17]
    node _GEN_24 = mux(io_flush, UInt<1>("h0"), _GEN_9) @[Reg_ID_EX.scala 37:19 40:17]
    node _GEN_25 = mux(io_flush, UInt<1>("h0"), _GEN_10) @[Reg_ID_EX.scala 37:19 41:17]
    node _GEN_26 = mux(io_flush, UInt<1>("h0"), _GEN_11) @[Reg_ID_EX.scala 37:19 42:17]
    node _GEN_27 = mux(io_flush, UInt<1>("h0"), _GEN_12) @[Reg_ID_EX.scala 37:19 43:17]
    node _GEN_28 = mux(io_flush, UInt<1>("h0"), _GEN_13) @[Reg_ID_EX.scala 37:19 44:17]
    node _GEN_29 = mux(io_flush, UInt<1>("h0"), _GEN_14) @[Reg_ID_EX.scala 37:19 45:17]
    node _ctrl_id_WIRE_ctrlJump = UInt<1>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    node _ctrl_id_WIRE_ctrlBranch = UInt<1>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    node _ctrl_id_WIRE_ctrlRegWrite = UInt<1>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    node _ctrl_id_WIRE_ctrlMemRead = UInt<1>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    node _ctrl_id_WIRE_ctrlMemWrite = UInt<1>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    node _ctrl_id_WIRE_ctrlALUSrc = UInt<1>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    node _ctrl_id_WIRE_ctrlALUOp = UInt<5>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    node _ctrl_id_WIRE_ctrlMemToReg = UInt<1>("h0") @[Reg_ID_EX.scala 28:{41,41}]
    io_out_ctrl_ctrlJump <= ctrl_id_ctrlJump @[Reg_ID_EX.scala 57:19]
    io_out_ctrl_ctrlBranch <= ctrl_id_ctrlBranch @[Reg_ID_EX.scala 57:19]
    io_out_ctrl_ctrlRegWrite <= ctrl_id_ctrlRegWrite @[Reg_ID_EX.scala 57:19]
    io_out_ctrl_ctrlMemRead <= ctrl_id_ctrlMemRead @[Reg_ID_EX.scala 57:19]
    io_out_ctrl_ctrlMemWrite <= ctrl_id_ctrlMemWrite @[Reg_ID_EX.scala 57:19]
    io_out_ctrl_ctrlALUSrc <= ctrl_id_ctrlALUSrc @[Reg_ID_EX.scala 57:19]
    io_out_ctrl_ctrlALUOp <= ctrl_id_ctrlALUOp @[Reg_ID_EX.scala 57:19]
    io_out_ctrl_ctrlMemToReg <= ctrl_id_ctrlMemToReg @[Reg_ID_EX.scala 57:19]
    io_out_pc <= pc_id @[Reg_ID_EX.scala 58:19]
    io_out_rs1_data <= rs1_data_id @[Reg_ID_EX.scala 59:19]
    io_out_rs2_data <= rs2_data_id @[Reg_ID_EX.scala 60:19]
    io_out_imm <= imm_id @[Reg_ID_EX.scala 61:19]
    io_out_rd_addr <= rd_addr_id @[Reg_ID_EX.scala 62:19]
    io_out_rs1_addr <= rs1_addr_id @[Reg_ID_EX.scala 64:19]
    io_out_rs2_addr <= rs2_addr_id @[Reg_ID_EX.scala 65:19]
    ctrl_id_ctrlJump <= mux(reset, _ctrl_id_WIRE_ctrlJump, _GEN_22) @[Reg_ID_EX.scala 28:{28,28}]
    ctrl_id_ctrlBranch <= mux(reset, _ctrl_id_WIRE_ctrlBranch, _GEN_21) @[Reg_ID_EX.scala 28:{28,28}]
    ctrl_id_ctrlRegWrite <= mux(reset, _ctrl_id_WIRE_ctrlRegWrite, _GEN_20) @[Reg_ID_EX.scala 28:{28,28}]
    ctrl_id_ctrlMemRead <= mux(reset, _ctrl_id_WIRE_ctrlMemRead, _GEN_19) @[Reg_ID_EX.scala 28:{28,28}]
    ctrl_id_ctrlMemWrite <= mux(reset, _ctrl_id_WIRE_ctrlMemWrite, _GEN_18) @[Reg_ID_EX.scala 28:{28,28}]
    ctrl_id_ctrlALUSrc <= mux(reset, _ctrl_id_WIRE_ctrlALUSrc, _GEN_17) @[Reg_ID_EX.scala 28:{28,28}]
    ctrl_id_ctrlALUOp <= mux(reset, _ctrl_id_WIRE_ctrlALUOp, _GEN_16) @[Reg_ID_EX.scala 28:{28,28}]
    ctrl_id_ctrlMemToReg <= mux(reset, _ctrl_id_WIRE_ctrlMemToReg, _GEN_15) @[Reg_ID_EX.scala 28:{28,28}]
    pc_id <= mux(reset, UInt<32>("h0"), _GEN_23) @[Reg_ID_EX.scala 29:{28,28}]
    rs1_data_id <= mux(reset, UInt<32>("h0"), _GEN_24) @[Reg_ID_EX.scala 30:{28,28}]
    rs2_data_id <= mux(reset, UInt<32>("h0"), _GEN_25) @[Reg_ID_EX.scala 31:{28,28}]
    imm_id <= mux(reset, UInt<32>("h0"), _GEN_26) @[Reg_ID_EX.scala 32:{28,28}]
    rd_addr_id <= mux(reset, UInt<5>("h0"), _GEN_27) @[Reg_ID_EX.scala 33:{28,28}]
    rs1_addr_id <= mux(reset, UInt<5>("h0"), _GEN_28) @[Reg_ID_EX.scala 34:{28,28}]
    rs2_addr_id <= mux(reset, UInt<5>("h0"), _GEN_29) @[Reg_ID_EX.scala 35:{28,28}]

  module Reg_EX_MEM :
    input clock : Clock
    input reset : UInt<1>
    input io_stall : UInt<1>
    input io_flush : UInt<1>
    input io_in_alu_result : UInt<32>
    input io_in_rs2_data : UInt<32>
    input io_in_rd_addr : UInt<5>
    input io_in_ctrl_ctrlJump : UInt<1>
    input io_in_ctrl_ctrlBranch : UInt<1>
    input io_in_ctrl_ctrlRegWrite : UInt<1>
    input io_in_ctrl_ctrlMemRead : UInt<1>
    input io_in_ctrl_ctrlMemWrite : UInt<1>
    input io_in_ctrl_ctrlALUSrc : UInt<1>
    input io_in_ctrl_ctrlALUOp : UInt<5>
    input io_in_ctrl_ctrlMemToReg : UInt<1>
    output io_out_alu_result : UInt<32>
    output io_out_rs2_data : UInt<32>
    output io_out_rd_addr : UInt<5>
    output io_out_ctrl_ctrlJump : UInt<1>
    output io_out_ctrl_ctrlBranch : UInt<1>
    output io_out_ctrl_ctrlRegWrite : UInt<1>
    output io_out_ctrl_ctrlMemRead : UInt<1>
    output io_out_ctrl_ctrlMemWrite : UInt<1>
    output io_out_ctrl_ctrlALUSrc : UInt<1>
    output io_out_ctrl_ctrlALUOp : UInt<5>
    output io_out_ctrl_ctrlMemToReg : UInt<1>

    reg alu_result_ex : UInt<32>, clock with :
      reset => (UInt<1>("h0"), alu_result_ex) @[Reg_EX_MEM.scala 24:34]
    reg rs2_data_ex : UInt<32>, clock with :
      reset => (UInt<1>("h0"), rs2_data_ex) @[Reg_EX_MEM.scala 25:34]
    reg rd_addr_ex : UInt<5>, clock with :
      reset => (UInt<1>("h0"), rd_addr_ex) @[Reg_EX_MEM.scala 26:34]
    reg ctrl_ex_ctrlJump : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlJump) @[Reg_EX_MEM.scala 27:34]
    reg ctrl_ex_ctrlBranch : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlBranch) @[Reg_EX_MEM.scala 27:34]
    reg ctrl_ex_ctrlRegWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlRegWrite) @[Reg_EX_MEM.scala 27:34]
    reg ctrl_ex_ctrlMemRead : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlMemRead) @[Reg_EX_MEM.scala 27:34]
    reg ctrl_ex_ctrlMemWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlMemWrite) @[Reg_EX_MEM.scala 27:34]
    reg ctrl_ex_ctrlALUSrc : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlALUSrc) @[Reg_EX_MEM.scala 27:34]
    reg ctrl_ex_ctrlALUOp : UInt<5>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlALUOp) @[Reg_EX_MEM.scala 27:34]
    reg ctrl_ex_ctrlMemToReg : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_ex_ctrlMemToReg) @[Reg_EX_MEM.scala 27:34]
    node _T = eq(io_stall, UInt<1>("h0")) @[Reg_EX_MEM.scala 34:16]
    node _is_bubble_T = eq(io_in_ctrl_ctrlRegWrite, UInt<1>("h0")) @[Reg_EX_MEM.scala 36:21]
    node _is_bubble_T_1 = eq(io_in_ctrl_ctrlMemWrite, UInt<1>("h0")) @[Reg_EX_MEM.scala 36:49]
    node _is_bubble_T_2 = and(_is_bubble_T, _is_bubble_T_1) @[Reg_EX_MEM.scala 36:46]
    node _is_bubble_T_3 = eq(io_in_ctrl_ctrlMemRead, UInt<1>("h0")) @[Reg_EX_MEM.scala 37:21]
    node _is_bubble_T_4 = and(_is_bubble_T_2, _is_bubble_T_3) @[Reg_EX_MEM.scala 36:74]
    node _is_bubble_T_5 = eq(io_in_ctrl_ctrlBranch, UInt<1>("h0")) @[Reg_EX_MEM.scala 37:48]
    node _is_bubble_T_6 = and(_is_bubble_T_4, _is_bubble_T_5) @[Reg_EX_MEM.scala 37:45]
    node _is_bubble_T_7 = eq(io_in_ctrl_ctrlJump, UInt<1>("h0")) @[Reg_EX_MEM.scala 37:74]
    node is_bubble = and(_is_bubble_T_6, _is_bubble_T_7) @[Reg_EX_MEM.scala 37:71]
    node _GEN_0 = mux(is_bubble, alu_result_ex, io_in_alu_result) @[Reg_EX_MEM.scala 39:21 43:23 48:23]
    node _GEN_1 = mux(is_bubble, ctrl_ex_ctrlMemToReg, io_in_ctrl_ctrlMemToReg) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_2 = mux(is_bubble, ctrl_ex_ctrlALUOp, io_in_ctrl_ctrlALUOp) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_3 = mux(is_bubble, ctrl_ex_ctrlALUSrc, io_in_ctrl_ctrlALUSrc) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_4 = mux(is_bubble, ctrl_ex_ctrlMemWrite, io_in_ctrl_ctrlMemWrite) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_5 = mux(is_bubble, ctrl_ex_ctrlMemRead, io_in_ctrl_ctrlMemRead) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_6 = mux(is_bubble, ctrl_ex_ctrlRegWrite, io_in_ctrl_ctrlRegWrite) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_7 = mux(is_bubble, ctrl_ex_ctrlBranch, io_in_ctrl_ctrlBranch) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_8 = mux(is_bubble, ctrl_ex_ctrlJump, io_in_ctrl_ctrlJump) @[Reg_EX_MEM.scala 39:21 44:23 49:23]
    node _GEN_9 = mux(is_bubble, rs2_data_ex, io_in_rs2_data) @[Reg_EX_MEM.scala 39:21 45:23 50:23]
    node _GEN_10 = mux(_T, _GEN_0, alu_result_ex) @[Reg_EX_MEM.scala 34:27 24:34]
    node _GEN_11 = mux(_T, _GEN_1, ctrl_ex_ctrlMemToReg) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_12 = mux(_T, _GEN_2, ctrl_ex_ctrlALUOp) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_13 = mux(_T, _GEN_3, ctrl_ex_ctrlALUSrc) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_14 = mux(_T, _GEN_4, ctrl_ex_ctrlMemWrite) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_15 = mux(_T, _GEN_5, ctrl_ex_ctrlMemRead) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_16 = mux(_T, _GEN_6, ctrl_ex_ctrlRegWrite) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_17 = mux(_T, _GEN_7, ctrl_ex_ctrlBranch) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_18 = mux(_T, _GEN_8, ctrl_ex_ctrlJump) @[Reg_EX_MEM.scala 34:27 27:34]
    node _GEN_19 = mux(_T, _GEN_9, rs2_data_ex) @[Reg_EX_MEM.scala 34:27 25:34]
    node _GEN_20 = mux(_T, io_in_rd_addr, rd_addr_ex) @[Reg_EX_MEM.scala 34:27 56:16 26:34]
    node _GEN_21 = mux(io_flush, UInt<1>("h0"), _GEN_10) @[Reg_EX_MEM.scala 29:19 30:23]
    node _GEN_22 = mux(io_flush, UInt<1>("h0"), _GEN_19) @[Reg_EX_MEM.scala 29:19 31:23]
    node _GEN_23 = mux(io_flush, UInt<1>("h0"), _GEN_20) @[Reg_EX_MEM.scala 29:19 32:23]
    node _ctrl_ex_WIRE_1_ctrlMemToReg = UInt<1>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_24 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlMemToReg, _GEN_11) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_1_ctrlALUOp = UInt<5>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_25 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlALUOp, _GEN_12) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_1_ctrlALUSrc = UInt<1>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_26 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlALUSrc, _GEN_13) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_1_ctrlMemWrite = UInt<1>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_27 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlMemWrite, _GEN_14) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_1_ctrlMemRead = UInt<1>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_28 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlMemRead, _GEN_15) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_1_ctrlRegWrite = UInt<1>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_29 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlRegWrite, _GEN_16) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_1_ctrlBranch = UInt<1>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_30 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlBranch, _GEN_17) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_1_ctrlJump = UInt<1>("h0") @[Reg_EX_MEM.scala 33:{38,38}]
    node _GEN_31 = mux(io_flush, _ctrl_ex_WIRE_1_ctrlJump, _GEN_18) @[Reg_EX_MEM.scala 29:19 33:23]
    node _ctrl_ex_WIRE_ctrlJump = UInt<1>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    node _ctrl_ex_WIRE_ctrlBranch = UInt<1>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    node _ctrl_ex_WIRE_ctrlRegWrite = UInt<1>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    node _ctrl_ex_WIRE_ctrlMemRead = UInt<1>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    node _ctrl_ex_WIRE_ctrlMemWrite = UInt<1>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    node _ctrl_ex_WIRE_ctrlALUSrc = UInt<1>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    node _ctrl_ex_WIRE_ctrlALUOp = UInt<5>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    node _ctrl_ex_WIRE_ctrlMemToReg = UInt<1>("h0") @[Reg_EX_MEM.scala 27:{47,47}]
    io_out_alu_result <= alu_result_ex @[Reg_EX_MEM.scala 59:21]
    io_out_rs2_data <= rs2_data_ex @[Reg_EX_MEM.scala 60:21]
    io_out_rd_addr <= rd_addr_ex @[Reg_EX_MEM.scala 61:21]
    io_out_ctrl_ctrlJump <= ctrl_ex_ctrlJump @[Reg_EX_MEM.scala 62:21]
    io_out_ctrl_ctrlBranch <= ctrl_ex_ctrlBranch @[Reg_EX_MEM.scala 62:21]
    io_out_ctrl_ctrlRegWrite <= ctrl_ex_ctrlRegWrite @[Reg_EX_MEM.scala 62:21]
    io_out_ctrl_ctrlMemRead <= ctrl_ex_ctrlMemRead @[Reg_EX_MEM.scala 62:21]
    io_out_ctrl_ctrlMemWrite <= ctrl_ex_ctrlMemWrite @[Reg_EX_MEM.scala 62:21]
    io_out_ctrl_ctrlALUSrc <= ctrl_ex_ctrlALUSrc @[Reg_EX_MEM.scala 62:21]
    io_out_ctrl_ctrlALUOp <= ctrl_ex_ctrlALUOp @[Reg_EX_MEM.scala 62:21]
    io_out_ctrl_ctrlMemToReg <= ctrl_ex_ctrlMemToReg @[Reg_EX_MEM.scala 62:21]
    alu_result_ex <= mux(reset, UInt<32>("h0"), _GEN_21) @[Reg_EX_MEM.scala 24:{34,34}]
    rs2_data_ex <= mux(reset, UInt<32>("h0"), _GEN_22) @[Reg_EX_MEM.scala 25:{34,34}]
    rd_addr_ex <= mux(reset, UInt<5>("h0"), _GEN_23) @[Reg_EX_MEM.scala 26:{34,34}]
    ctrl_ex_ctrlJump <= mux(reset, _ctrl_ex_WIRE_ctrlJump, _GEN_31) @[Reg_EX_MEM.scala 27:{34,34}]
    ctrl_ex_ctrlBranch <= mux(reset, _ctrl_ex_WIRE_ctrlBranch, _GEN_30) @[Reg_EX_MEM.scala 27:{34,34}]
    ctrl_ex_ctrlRegWrite <= mux(reset, _ctrl_ex_WIRE_ctrlRegWrite, _GEN_29) @[Reg_EX_MEM.scala 27:{34,34}]
    ctrl_ex_ctrlMemRead <= mux(reset, _ctrl_ex_WIRE_ctrlMemRead, _GEN_28) @[Reg_EX_MEM.scala 27:{34,34}]
    ctrl_ex_ctrlMemWrite <= mux(reset, _ctrl_ex_WIRE_ctrlMemWrite, _GEN_27) @[Reg_EX_MEM.scala 27:{34,34}]
    ctrl_ex_ctrlALUSrc <= mux(reset, _ctrl_ex_WIRE_ctrlALUSrc, _GEN_26) @[Reg_EX_MEM.scala 27:{34,34}]
    ctrl_ex_ctrlALUOp <= mux(reset, _ctrl_ex_WIRE_ctrlALUOp, _GEN_25) @[Reg_EX_MEM.scala 27:{34,34}]
    ctrl_ex_ctrlMemToReg <= mux(reset, _ctrl_ex_WIRE_ctrlMemToReg, _GEN_24) @[Reg_EX_MEM.scala 27:{34,34}]

  module Reg_MEM_WB :
    input clock : Clock
    input reset : UInt<1>
    input io_stall : UInt<1>
    input io_flush : UInt<1>
    input io_in_alu_result : UInt<32>
    input io_in_rd_addr : UInt<5>
    input io_in_ctrl_ctrlJump : UInt<1>
    input io_in_ctrl_ctrlBranch : UInt<1>
    input io_in_ctrl_ctrlRegWrite : UInt<1>
    input io_in_ctrl_ctrlMemRead : UInt<1>
    input io_in_ctrl_ctrlMemWrite : UInt<1>
    input io_in_ctrl_ctrlALUSrc : UInt<1>
    input io_in_ctrl_ctrlALUOp : UInt<5>
    input io_in_ctrl_ctrlMemToReg : UInt<1>
    output io_out_alu_result : UInt<32>
    output io_out_rd_addr : UInt<5>
    output io_out_ctrl_ctrlJump : UInt<1>
    output io_out_ctrl_ctrlBranch : UInt<1>
    output io_out_ctrl_ctrlRegWrite : UInt<1>
    output io_out_ctrl_ctrlMemRead : UInt<1>
    output io_out_ctrl_ctrlMemWrite : UInt<1>
    output io_out_ctrl_ctrlALUSrc : UInt<1>
    output io_out_ctrl_ctrlALUOp : UInt<5>
    output io_out_ctrl_ctrlMemToReg : UInt<1>

    reg alu_result_mem : UInt<32>, clock with :
      reset => (UInt<1>("h0"), alu_result_mem) @[Reg_MEM_WB.scala 21:35]
    reg rd_addr_mem : UInt<5>, clock with :
      reset => (UInt<1>("h0"), rd_addr_mem) @[Reg_MEM_WB.scala 22:35]
    reg ctrl_mem_ctrlJump : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlJump) @[Reg_MEM_WB.scala 23:35]
    reg ctrl_mem_ctrlBranch : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlBranch) @[Reg_MEM_WB.scala 23:35]
    reg ctrl_mem_ctrlRegWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlRegWrite) @[Reg_MEM_WB.scala 23:35]
    reg ctrl_mem_ctrlMemRead : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlMemRead) @[Reg_MEM_WB.scala 23:35]
    reg ctrl_mem_ctrlMemWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlMemWrite) @[Reg_MEM_WB.scala 23:35]
    reg ctrl_mem_ctrlALUSrc : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlALUSrc) @[Reg_MEM_WB.scala 23:35]
    reg ctrl_mem_ctrlALUOp : UInt<5>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlALUOp) @[Reg_MEM_WB.scala 23:35]
    reg ctrl_mem_ctrlMemToReg : UInt<1>, clock with :
      reset => (UInt<1>("h0"), ctrl_mem_ctrlMemToReg) @[Reg_MEM_WB.scala 23:35]
    node _T = eq(io_stall, UInt<1>("h0")) @[Reg_MEM_WB.scala 29:16]
    node _GEN_0 = mux(_T, io_in_alu_result, alu_result_mem) @[Reg_MEM_WB.scala 29:27 30:24 21:35]
    node _GEN_1 = mux(_T, io_in_rd_addr, rd_addr_mem) @[Reg_MEM_WB.scala 29:27 31:24 22:35]
    node _GEN_2 = mux(_T, io_in_ctrl_ctrlMemToReg, ctrl_mem_ctrlMemToReg) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_3 = mux(_T, io_in_ctrl_ctrlALUOp, ctrl_mem_ctrlALUOp) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_4 = mux(_T, io_in_ctrl_ctrlALUSrc, ctrl_mem_ctrlALUSrc) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_5 = mux(_T, io_in_ctrl_ctrlMemWrite, ctrl_mem_ctrlMemWrite) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_6 = mux(_T, io_in_ctrl_ctrlMemRead, ctrl_mem_ctrlMemRead) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_7 = mux(_T, io_in_ctrl_ctrlRegWrite, ctrl_mem_ctrlRegWrite) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_8 = mux(_T, io_in_ctrl_ctrlBranch, ctrl_mem_ctrlBranch) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_9 = mux(_T, io_in_ctrl_ctrlJump, ctrl_mem_ctrlJump) @[Reg_MEM_WB.scala 29:27 32:24 23:35]
    node _GEN_10 = mux(io_flush, UInt<1>("h0"), _GEN_0) @[Reg_MEM_WB.scala 25:19 26:24]
    node _GEN_11 = mux(io_flush, UInt<1>("h0"), _GEN_1) @[Reg_MEM_WB.scala 25:19 27:24]
    node _ctrl_mem_WIRE_1_ctrlMemToReg = UInt<1>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_12 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlMemToReg, _GEN_2) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_1_ctrlALUOp = UInt<5>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_13 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlALUOp, _GEN_3) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_1_ctrlALUSrc = UInt<1>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_14 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlALUSrc, _GEN_4) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_1_ctrlMemWrite = UInt<1>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_15 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlMemWrite, _GEN_5) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_1_ctrlMemRead = UInt<1>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_16 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlMemRead, _GEN_6) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_1_ctrlRegWrite = UInt<1>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_17 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlRegWrite, _GEN_7) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_1_ctrlBranch = UInt<1>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_18 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlBranch, _GEN_8) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_1_ctrlJump = UInt<1>("h0") @[Reg_MEM_WB.scala 28:{39,39}]
    node _GEN_19 = mux(io_flush, _ctrl_mem_WIRE_1_ctrlJump, _GEN_9) @[Reg_MEM_WB.scala 25:19 28:24]
    node _ctrl_mem_WIRE_ctrlJump = UInt<1>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    node _ctrl_mem_WIRE_ctrlBranch = UInt<1>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    node _ctrl_mem_WIRE_ctrlRegWrite = UInt<1>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    node _ctrl_mem_WIRE_ctrlMemRead = UInt<1>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    node _ctrl_mem_WIRE_ctrlMemWrite = UInt<1>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    node _ctrl_mem_WIRE_ctrlALUSrc = UInt<1>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    node _ctrl_mem_WIRE_ctrlALUOp = UInt<5>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    node _ctrl_mem_WIRE_ctrlMemToReg = UInt<1>("h0") @[Reg_MEM_WB.scala 23:{48,48}]
    io_out_alu_result <= alu_result_mem @[Reg_MEM_WB.scala 35:21]
    io_out_rd_addr <= rd_addr_mem @[Reg_MEM_WB.scala 36:21]
    io_out_ctrl_ctrlJump <= ctrl_mem_ctrlJump @[Reg_MEM_WB.scala 37:21]
    io_out_ctrl_ctrlBranch <= ctrl_mem_ctrlBranch @[Reg_MEM_WB.scala 37:21]
    io_out_ctrl_ctrlRegWrite <= ctrl_mem_ctrlRegWrite @[Reg_MEM_WB.scala 37:21]
    io_out_ctrl_ctrlMemRead <= ctrl_mem_ctrlMemRead @[Reg_MEM_WB.scala 37:21]
    io_out_ctrl_ctrlMemWrite <= ctrl_mem_ctrlMemWrite @[Reg_MEM_WB.scala 37:21]
    io_out_ctrl_ctrlALUSrc <= ctrl_mem_ctrlALUSrc @[Reg_MEM_WB.scala 37:21]
    io_out_ctrl_ctrlALUOp <= ctrl_mem_ctrlALUOp @[Reg_MEM_WB.scala 37:21]
    io_out_ctrl_ctrlMemToReg <= ctrl_mem_ctrlMemToReg @[Reg_MEM_WB.scala 37:21]
    alu_result_mem <= mux(reset, UInt<32>("h0"), _GEN_10) @[Reg_MEM_WB.scala 21:{35,35}]
    rd_addr_mem <= mux(reset, UInt<5>("h0"), _GEN_11) @[Reg_MEM_WB.scala 22:{35,35}]
    ctrl_mem_ctrlJump <= mux(reset, _ctrl_mem_WIRE_ctrlJump, _GEN_19) @[Reg_MEM_WB.scala 23:{35,35}]
    ctrl_mem_ctrlBranch <= mux(reset, _ctrl_mem_WIRE_ctrlBranch, _GEN_18) @[Reg_MEM_WB.scala 23:{35,35}]
    ctrl_mem_ctrlRegWrite <= mux(reset, _ctrl_mem_WIRE_ctrlRegWrite, _GEN_17) @[Reg_MEM_WB.scala 23:{35,35}]
    ctrl_mem_ctrlMemRead <= mux(reset, _ctrl_mem_WIRE_ctrlMemRead, _GEN_16) @[Reg_MEM_WB.scala 23:{35,35}]
    ctrl_mem_ctrlMemWrite <= mux(reset, _ctrl_mem_WIRE_ctrlMemWrite, _GEN_15) @[Reg_MEM_WB.scala 23:{35,35}]
    ctrl_mem_ctrlALUSrc <= mux(reset, _ctrl_mem_WIRE_ctrlALUSrc, _GEN_14) @[Reg_MEM_WB.scala 23:{35,35}]
    ctrl_mem_ctrlALUOp <= mux(reset, _ctrl_mem_WIRE_ctrlALUOp, _GEN_13) @[Reg_MEM_WB.scala 23:{35,35}]
    ctrl_mem_ctrlMemToReg <= mux(reset, _ctrl_mem_WIRE_ctrlMemToReg, _GEN_12) @[Reg_MEM_WB.scala 23:{35,35}]

  module ForwardingUnit :
    input clock : Clock
    input reset : UInt<1>
    input io_rs1_ex : UInt<5>
    input io_rs2_ex : UInt<5>
    input io_rd_mem : UInt<5>
    input io_reg_write_mem : UInt<1>
    input io_rd_wb : UInt<5>
    input io_reg_write_wb : UInt<1>
    output io_forward_a : UInt<2>
    output io_forward_b : UInt<2>

    node _T = neq(io_rd_mem, UInt<1>("h0")) @[Forwarding.scala 34:40]
    node _T_1 = and(io_reg_write_mem, _T) @[Forwarding.scala 34:27]
    node _T_2 = eq(io_rd_mem, io_rs1_ex) @[Forwarding.scala 34:61]
    node _T_3 = and(_T_1, _T_2) @[Forwarding.scala 34:48]
    node _T_4 = neq(io_rd_wb, UInt<1>("h0")) @[Forwarding.scala 40:43]
    node _T_5 = and(io_reg_write_wb, _T_4) @[Forwarding.scala 40:31]
    node _T_6 = eq(io_rd_wb, io_rs1_ex) @[Forwarding.scala 40:63]
    node _T_7 = and(_T_5, _T_6) @[Forwarding.scala 40:51]
    node _T_8 = neq(io_rd_mem, UInt<1>("h0")) @[Forwarding.scala 41:45]
    node _T_9 = and(io_reg_write_mem, _T_8) @[Forwarding.scala 41:32]
    node _T_10 = eq(io_rd_mem, io_rs1_ex) @[Forwarding.scala 41:66]
    node _T_11 = and(_T_9, _T_10) @[Forwarding.scala 41:53]
    node _T_12 = eq(_T_11, UInt<1>("h0")) @[Forwarding.scala 41:13]
    node _T_13 = and(_T_7, _T_12) @[Forwarding.scala 40:77]
    node _GEN_0 = mux(_T_13, UInt<1>("h1"), UInt<1>("h0")) @[Forwarding.scala 25:18 41:82 42:22]
    node _GEN_1 = mux(_T_3, UInt<2>("h2"), _GEN_0) @[Forwarding.scala 34:76 35:22]
    node _T_14 = neq(io_rd_mem, UInt<1>("h0")) @[Forwarding.scala 50:40]
    node _T_15 = and(io_reg_write_mem, _T_14) @[Forwarding.scala 50:27]
    node _T_16 = eq(io_rd_mem, io_rs2_ex) @[Forwarding.scala 50:61]
    node _T_17 = and(_T_15, _T_16) @[Forwarding.scala 50:48]
    node _T_18 = neq(io_rd_wb, UInt<1>("h0")) @[Forwarding.scala 54:43]
    node _T_19 = and(io_reg_write_wb, _T_18) @[Forwarding.scala 54:31]
    node _T_20 = eq(io_rd_wb, io_rs2_ex) @[Forwarding.scala 54:63]
    node _T_21 = and(_T_19, _T_20) @[Forwarding.scala 54:51]
    node _T_22 = neq(io_rd_mem, UInt<1>("h0")) @[Forwarding.scala 55:45]
    node _T_23 = and(io_reg_write_mem, _T_22) @[Forwarding.scala 55:32]
    node _T_24 = eq(io_rd_mem, io_rs2_ex) @[Forwarding.scala 55:66]
    node _T_25 = and(_T_23, _T_24) @[Forwarding.scala 55:53]
    node _T_26 = eq(_T_25, UInt<1>("h0")) @[Forwarding.scala 55:13]
    node _T_27 = and(_T_21, _T_26) @[Forwarding.scala 54:77]
    node _GEN_2 = mux(_T_27, UInt<1>("h1"), UInt<1>("h0")) @[Forwarding.scala 26:18 55:82 56:22]
    node _GEN_3 = mux(_T_17, UInt<2>("h2"), _GEN_2) @[Forwarding.scala 50:76 51:22]
    io_forward_a <= _GEN_1
    io_forward_b <= _GEN_3

  module Core :
    input clock : Clock
    input reset : UInt<1>
    output io_pc : UInt<32>
    output io_inst : UInt<32>
    output io_wb_result : UInt<32>
    output io_peek_write : UInt<1>
    output io_peek_addr : UInt<32>
    output io_peek_data : UInt<32>

    inst pc_handle of PCHandle @[Core.scala 24:27]
    inst inst_mem of InstMem @[Core.scala 25:26]
    inst decoder of Decoder @[Core.scala 26:25]
    inst reg_file of Regfile @[Core.scala 27:26]
    inst alu of Alu @[Core.scala 28:21]
    inst data_mem of DataMem @[Core.scala 29:26]
    inst if_id of Reg_IF_ID @[Core.scala 35:23]
    inst id_ex of Reg_ID_EX @[Core.scala 36:23]
    inst ex_mem of Reg_EX_MEM @[Core.scala 37:24]
    inst mem_wb of Reg_MEM_WB @[Core.scala 38:24]
    inst forwarding_unit of ForwardingUnit @[Core.scala 123:33]
    node _rs1_conflict_T = eq(decoder.io_regs_rs1_addr, id_ex.io_out_rd_addr) @[Core.scala 49:50]
    node _rs1_conflict_T_1 = neq(id_ex.io_out_rd_addr, UInt<1>("h0")) @[Core.scala 49:101]
    node rs1_conflict = and(_rs1_conflict_T, _rs1_conflict_T_1) @[Core.scala 49:76]
    node _rs2_conflict_T = eq(decoder.io_regs_rs2_addr, id_ex.io_out_rd_addr) @[Core.scala 50:50]
    node _rs2_conflict_T_1 = neq(id_ex.io_out_rd_addr, UInt<1>("h0")) @[Core.scala 50:101]
    node rs2_conflict = and(_rs2_conflict_T, _rs2_conflict_T_1) @[Core.scala 50:76]
    node _load_use_hazard_T = or(rs1_conflict, rs2_conflict) @[Core.scala 53:55]
    node load_use_hazard = and(id_ex.io_out_ctrl_ctrlMemRead, _load_use_hazard_T) @[Core.scala 53:38]
    node _reg_file_io_rd_data_T = mux(mem_wb.io_out_ctrl_ctrlMemToReg, data_mem.io_data_out, mem_wb.io_out_alu_result) @[Core.scala 90:31]
    node _forwarded_src1_T = eq(UInt<1>("h0"), forwarding_unit.io_forward_a) @[Mux.scala 81:61]
    node _forwarded_src1_T_1 = mux(_forwarded_src1_T, id_ex.io_out_rs1_data, id_ex.io_out_rs1_data) @[Mux.scala 81:58]
    node _forwarded_src1_T_2 = eq(UInt<1>("h1"), forwarding_unit.io_forward_a) @[Mux.scala 81:61]
    node _forwarded_src1_T_3 = mux(_forwarded_src1_T_2, reg_file.io_rd_data, _forwarded_src1_T_1) @[Mux.scala 81:58]
    node _forwarded_src1_T_4 = eq(UInt<2>("h2"), forwarding_unit.io_forward_a) @[Mux.scala 81:61]
    node forwarded_src1 = mux(_forwarded_src1_T_4, ex_mem.io_out_alu_result, _forwarded_src1_T_3) @[Mux.scala 81:58]
    node _forwarded_src2_T = eq(UInt<1>("h0"), forwarding_unit.io_forward_b) @[Mux.scala 81:61]
    node _forwarded_src2_T_1 = mux(_forwarded_src2_T, id_ex.io_out_rs2_data, id_ex.io_out_rs2_data) @[Mux.scala 81:58]
    node _forwarded_src2_T_2 = eq(UInt<1>("h1"), forwarding_unit.io_forward_b) @[Mux.scala 81:61]
    node _forwarded_src2_T_3 = mux(_forwarded_src2_T_2, reg_file.io_rd_data, _forwarded_src2_T_1) @[Mux.scala 81:58]
    node _forwarded_src2_T_4 = eq(UInt<2>("h2"), forwarding_unit.io_forward_b) @[Mux.scala 81:61]
    node forwarded_src2 = mux(_forwarded_src2_T_4, ex_mem.io_out_alu_result, _forwarded_src2_T_3) @[Mux.scala 81:58]
    node _alu_io_src2_T = mux(id_ex.io_out_ctrl_ctrlALUSrc, id_ex.io_out_imm, forwarded_src2) @[Core.scala 165:23]
    node _data_mem_io_ctrlMemRead_T = or(ex_mem.io_out_ctrl_ctrlMemRead, mem_wb.io_out_ctrl_ctrlMemToReg) @[Core.scala 194:63]
    node _io_wb_result_T = mux(mem_wb.io_out_ctrl_ctrlMemToReg, data_mem.io_data_out, mem_wb.io_out_alu_result) @[Core.scala 217:24]
    io_pc <= pc_handle.io_pc @[Core.scala 215:11]
    io_inst <= inst_mem.io_inst @[Core.scala 216:13]
    io_wb_result <= _io_wb_result_T @[Core.scala 217:18]
    io_peek_write <= data_mem.io_peek_write @[Core.scala 220:19]
    io_peek_addr <= data_mem.io_addr @[Core.scala 221:18]
    io_peek_data <= data_mem.io_data_in @[Core.scala 222:18]
    pc_handle.clock <= clock
    pc_handle.reset <= reset
    pc_handle.io_to_branch <= UInt<1>("h0") @[Core.scala 65:28]
    pc_handle.io_jump_addr <= UInt<32>("h0") @[Core.scala 66:28]
    pc_handle.io_stall <= load_use_hazard @[Core.scala 61:24]
    inst_mem.clock <= clock
    inst_mem.reset <= reset
    inst_mem.io_addr <= pc_handle.io_pc @[Core.scala 68:22]
    decoder.clock <= clock
    decoder.reset <= reset
    decoder.io_inst <= if_id.io_out_inst @[Core.scala 93:21]
    reg_file.clock <= clock
    reg_file.reset <= reset
    reg_file.io_rs1_addr <= decoder.io_regs_rs1_addr @[Core.scala 96:26]
    reg_file.io_rs2_addr <= decoder.io_regs_rs2_addr @[Core.scala 97:26]
    reg_file.io_rd_addr <= mem_wb.io_out_rd_addr @[Core.scala 89:25]
    reg_file.io_rd_data <= _reg_file_io_rd_data_T @[Core.scala 90:25]
    reg_file.io_reg_write <= mem_wb.io_out_ctrl_ctrlRegWrite @[Core.scala 88:27]
    alu.clock <= clock
    alu.reset <= reset
    alu.io_src1 <= forwarded_src1 @[Core.scala 161:17]
    alu.io_src2 <= _alu_io_src2_T @[Core.scala 165:17]
    alu.io_pc <= id_ex.io_out_pc @[Core.scala 175:15]
    alu.io_imm <= id_ex.io_out_imm @[Core.scala 176:16]
    alu.io_aluOp <= id_ex.io_out_ctrl_ctrlALUOp @[Core.scala 177:18]
    data_mem.clock <= clock
    data_mem.reset <= reset
    data_mem.io_ctrlMemRead <= _data_mem_io_ctrlMemRead_T @[Core.scala 194:29]
    data_mem.io_ctrlMemWrite <= ex_mem.io_out_ctrl_ctrlMemWrite @[Core.scala 195:30]
    data_mem.io_addr <= ex_mem.io_out_alu_result @[Core.scala 196:22]
    data_mem.io_data_in <= ex_mem.io_out_rs2_data @[Core.scala 197:25]
    if_id.clock <= clock
    if_id.reset <= reset
    if_id.io_in_pc <= pc_handle.io_pc @[Core.scala 74:20]
    if_id.io_in_inst <= inst_mem.io_inst @[Core.scala 75:22]
    if_id.io_stall <= load_use_hazard @[Core.scala 78:20]
    if_id.io_flush <= UInt<1>("h0") @[Core.scala 79:20]
    id_ex.clock <= clock
    id_ex.reset <= reset
    id_ex.io_stall <= UInt<1>("h0") @[Core.scala 104:20]
    id_ex.io_flush <= load_use_hazard @[Core.scala 105:20]
    id_ex.io_in_ctrl_ctrlJump <= decoder.io_ctrl_ctrlJump @[Core.scala 108:22]
    id_ex.io_in_ctrl_ctrlBranch <= decoder.io_ctrl_ctrlBranch @[Core.scala 108:22]
    id_ex.io_in_ctrl_ctrlRegWrite <= decoder.io_ctrl_ctrlRegWrite @[Core.scala 108:22]
    id_ex.io_in_ctrl_ctrlMemRead <= decoder.io_ctrl_ctrlMemRead @[Core.scala 108:22]
    id_ex.io_in_ctrl_ctrlMemWrite <= decoder.io_ctrl_ctrlMemWrite @[Core.scala 108:22]
    id_ex.io_in_ctrl_ctrlALUSrc <= decoder.io_ctrl_ctrlALUSrc @[Core.scala 108:22]
    id_ex.io_in_ctrl_ctrlALUOp <= decoder.io_ctrl_ctrlALUOp @[Core.scala 108:22]
    id_ex.io_in_ctrl_ctrlMemToReg <= decoder.io_ctrl_ctrlMemToReg @[Core.scala 108:22]
    id_ex.io_in_pc <= if_id.io_out_pc @[Core.scala 109:20]
    id_ex.io_in_rs1_data <= reg_file.io_rs1_data @[Core.scala 110:26]
    id_ex.io_in_rs2_data <= reg_file.io_rs2_data @[Core.scala 111:26]
    id_ex.io_in_imm <= decoder.io_imm @[Core.scala 112:21]
    id_ex.io_in_rd_addr <= decoder.io_regs_rd_addr @[Core.scala 113:25]
    id_ex.io_in_rs1_addr <= decoder.io_regs_rs1_addr @[Core.scala 100:26]
    id_ex.io_in_rs2_addr <= decoder.io_regs_rs2_addr @[Core.scala 101:26]
    ex_mem.clock <= clock
    ex_mem.reset <= reset
    ex_mem.io_stall <= UInt<1>("h0") @[Core.scala 180:21]
    ex_mem.io_flush <= UInt<1>("h0") @[Core.scala 181:21]
    ex_mem.io_in_alu_result <= alu.io_alu_result @[Core.scala 184:29]
    ex_mem.io_in_rs2_data <= forwarded_src2 @[Core.scala 185:27]
    ex_mem.io_in_rd_addr <= id_ex.io_out_rd_addr @[Core.scala 186:26]
    ex_mem.io_in_ctrl_ctrlJump <= id_ex.io_out_ctrl_ctrlJump @[Core.scala 187:23]
    ex_mem.io_in_ctrl_ctrlBranch <= id_ex.io_out_ctrl_ctrlBranch @[Core.scala 187:23]
    ex_mem.io_in_ctrl_ctrlRegWrite <= id_ex.io_out_ctrl_ctrlRegWrite @[Core.scala 187:23]
    ex_mem.io_in_ctrl_ctrlMemRead <= id_ex.io_out_ctrl_ctrlMemRead @[Core.scala 187:23]
    ex_mem.io_in_ctrl_ctrlMemWrite <= id_ex.io_out_ctrl_ctrlMemWrite @[Core.scala 187:23]
    ex_mem.io_in_ctrl_ctrlALUSrc <= id_ex.io_out_ctrl_ctrlALUSrc @[Core.scala 187:23]
    ex_mem.io_in_ctrl_ctrlALUOp <= id_ex.io_out_ctrl_ctrlALUOp @[Core.scala 187:23]
    ex_mem.io_in_ctrl_ctrlMemToReg <= id_ex.io_out_ctrl_ctrlMemToReg @[Core.scala 187:23]
    mem_wb.clock <= clock
    mem_wb.reset <= reset
    mem_wb.io_stall <= UInt<1>("h0") @[Core.scala 200:21]
    mem_wb.io_flush <= UInt<1>("h0") @[Core.scala 201:21]
    mem_wb.io_in_alu_result <= ex_mem.io_out_alu_result @[Core.scala 204:29]
    mem_wb.io_in_rd_addr <= ex_mem.io_out_rd_addr @[Core.scala 205:26]
    mem_wb.io_in_ctrl_ctrlJump <= ex_mem.io_out_ctrl_ctrlJump @[Core.scala 206:23]
    mem_wb.io_in_ctrl_ctrlBranch <= ex_mem.io_out_ctrl_ctrlBranch @[Core.scala 206:23]
    mem_wb.io_in_ctrl_ctrlRegWrite <= ex_mem.io_out_ctrl_ctrlRegWrite @[Core.scala 206:23]
    mem_wb.io_in_ctrl_ctrlMemRead <= ex_mem.io_out_ctrl_ctrlMemRead @[Core.scala 206:23]
    mem_wb.io_in_ctrl_ctrlMemWrite <= ex_mem.io_out_ctrl_ctrlMemWrite @[Core.scala 206:23]
    mem_wb.io_in_ctrl_ctrlALUSrc <= ex_mem.io_out_ctrl_ctrlALUSrc @[Core.scala 206:23]
    mem_wb.io_in_ctrl_ctrlALUOp <= ex_mem.io_out_ctrl_ctrlALUOp @[Core.scala 206:23]
    mem_wb.io_in_ctrl_ctrlMemToReg <= ex_mem.io_out_ctrl_ctrlMemToReg @[Core.scala 206:23]
    forwarding_unit.clock <= clock
    forwarding_unit.reset <= reset
    forwarding_unit.io_rs1_ex <= id_ex.io_out_rs1_addr @[Core.scala 126:31]
    forwarding_unit.io_rs2_ex <= id_ex.io_out_rs2_addr @[Core.scala 127:31]
    forwarding_unit.io_rd_mem <= ex_mem.io_out_rd_addr @[Core.scala 130:31]
    forwarding_unit.io_reg_write_mem <= ex_mem.io_out_ctrl_ctrlRegWrite @[Core.scala 131:38]
    forwarding_unit.io_rd_wb <= mem_wb.io_out_rd_addr @[Core.scala 134:30]
    forwarding_unit.io_reg_write_wb <= mem_wb.io_out_ctrl_ctrlRegWrite @[Core.scala 135:37]
