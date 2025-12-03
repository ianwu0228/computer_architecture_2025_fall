circuit Core :
  module PCHandle :
    input clock : Clock
    input reset : UInt<1>
    input io_to_branch : UInt<1>
    input io_jump_addr : UInt<32>
    output io_pc : UInt<32>

    reg pc : UInt<32>, clock with :
      reset => (UInt<1>("h0"), pc) @[PCHandle.scala 41:19]
    node _next_pc_T = add(pc, UInt<3>("h4")) @[PCHandle.scala 44:52]
    node _next_pc_T_1 = tail(_next_pc_T, 1) @[PCHandle.scala 44:52]
    node next_pc = mux(io_to_branch, io_jump_addr, _next_pc_T_1) @[PCHandle.scala 44:20]
    io_pc <= pc @[PCHandle.scala 47:9]
    pc <= mux(reset, UInt<32>("h0"), next_pc) @[PCHandle.scala 41:{19,19} 46:6]

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

    node opcode = bits(io_inst, 6, 0) @[Decoder.scala 183:20]
    node rd = bits(io_inst, 11, 7) @[Decoder.scala 184:20]
    node funct3 = bits(io_inst, 14, 12) @[Decoder.scala 185:20]
    node rs1 = bits(io_inst, 19, 15) @[Decoder.scala 186:20]
    node rs2 = bits(io_inst, 24, 20) @[Decoder.scala 187:20]
    node funct7 = bits(io_inst, 31, 25) @[Decoder.scala 188:20]
    node _T = eq(UInt<6>("h33"), opcode) @[Decoder.scala 213:18]
    node _T_1 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 220:22]
    node _io_ctrl_ctrlALUOp_T = eq(funct7, UInt<6>("h20")) @[Decoder.scala 221:56]
    node _io_ctrl_ctrlALUOp_T_1 = mux(_io_ctrl_ctrlALUOp_T, UInt<2>("h2"), UInt<1>("h1")) @[Decoder.scala 221:48]
    node _T_2 = eq(UInt<3>("h7"), funct3) @[Decoder.scala 220:22]
    node _T_3 = eq(UInt<3>("h6"), funct3) @[Decoder.scala 220:22]
    node _T_4 = eq(UInt<3>("h4"), funct3) @[Decoder.scala 220:22]
    node _T_5 = eq(UInt<2>("h2"), funct3) @[Decoder.scala 220:22]
    node _T_6 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 220:22]
    node _T_7 = eq(UInt<3>("h5"), funct3) @[Decoder.scala 220:22]
    node _io_ctrl_ctrlALUOp_T_2 = eq(funct7, UInt<6>("h20")) @[Decoder.scala 227:56]
    node _io_ctrl_ctrlALUOp_T_3 = mux(_io_ctrl_ctrlALUOp_T_2, UInt<4>("h9"), UInt<4>("h8")) @[Decoder.scala 227:48]
    node _io_ctrl_WIRE_ctrlALUOp = UInt<5>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_0 = mux(_T_7, _io_ctrl_ctrlALUOp_T_3, _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 191:11 220:22 227:42]
    node _GEN_1 = mux(_T_6, UInt<3>("h7"), _GEN_0) @[Decoder.scala 220:22 226:42]
    node _GEN_2 = mux(_T_5, UInt<3>("h6"), _GEN_1) @[Decoder.scala 220:22 225:42]
    node _GEN_3 = mux(_T_4, UInt<3>("h5"), _GEN_2) @[Decoder.scala 220:22 224:42]
    node _GEN_4 = mux(_T_3, UInt<3>("h4"), _GEN_3) @[Decoder.scala 220:22 223:42]
    node _GEN_5 = mux(_T_2, UInt<2>("h3"), _GEN_4) @[Decoder.scala 220:22 222:42]
    node _GEN_6 = mux(_T_1, _io_ctrl_ctrlALUOp_T_1, _GEN_5) @[Decoder.scala 220:22 221:42]
    node _T_8 = eq(UInt<5>("h13"), opcode) @[Decoder.scala 213:18]
    node _io_imm_T = bits(io_inst, 31, 20) @[Decoder.scala 237:26]
    node _io_imm_T_1 = bits(_io_imm_T, 11, 11) @[Decoder.scala 210:26]
    node _io_imm_T_2 = bits(_io_imm_T_1, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_3 = mux(_io_imm_T_2, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_4 = bits(_io_imm_T, 11, 0) @[Decoder.scala 210:38]
    node _io_imm_T_5 = cat(_io_imm_T_3, _io_imm_T_4) @[Cat.scala 31:58]
    node _T_9 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 239:22]
    node _T_10 = eq(UInt<2>("h2"), funct3) @[Decoder.scala 239:22]
    node _T_11 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 239:22]
    node _T_12 = eq(UInt<3>("h5"), funct3) @[Decoder.scala 239:22]
    node _io_ctrl_ctrlALUOp_T_4 = eq(funct7, UInt<6>("h20")) @[Decoder.scala 244:43]
    node _io_ctrl_ctrlALUOp_T_5 = mux(_io_ctrl_ctrlALUOp_T_4, UInt<4>("h9"), UInt<4>("h8")) @[Decoder.scala 244:35]
    node _GEN_7 = mux(_T_12, _io_ctrl_ctrlALUOp_T_5, _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 191:11 239:22 244:29]
    node _GEN_8 = mux(_T_11, UInt<3>("h7"), _GEN_7) @[Decoder.scala 239:22 242:42]
    node _GEN_9 = mux(_T_10, UInt<3>("h6"), _GEN_8) @[Decoder.scala 239:22 241:42]
    node _GEN_10 = mux(_T_9, UInt<1>("h1"), _GEN_9) @[Decoder.scala 239:22 240:42]
    node _T_13 = eq(UInt<2>("h3"), opcode) @[Decoder.scala 213:18]
    node _io_imm_T_6 = bits(io_inst, 31, 20) @[Decoder.scala 258:26]
    node _io_imm_T_7 = bits(_io_imm_T_6, 11, 11) @[Decoder.scala 210:26]
    node _io_imm_T_8 = bits(_io_imm_T_7, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_9 = mux(_io_imm_T_8, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_10 = bits(_io_imm_T_6, 11, 0) @[Decoder.scala 210:38]
    node _io_imm_T_11 = cat(_io_imm_T_9, _io_imm_T_10) @[Cat.scala 31:58]
    node _T_14 = eq(UInt<6>("h23"), opcode) @[Decoder.scala 213:18]
    node _immS_T = bits(io_inst, 31, 25) @[Decoder.scala 268:26]
    node _immS_T_1 = bits(io_inst, 11, 7) @[Decoder.scala 268:39]
    node immS = cat(_immS_T, _immS_T_1) @[Cat.scala 31:58]
    node _io_imm_T_12 = bits(immS, 11, 11) @[Decoder.scala 210:26]
    node _io_imm_T_13 = bits(_io_imm_T_12, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_14 = mux(_io_imm_T_13, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_15 = bits(immS, 11, 0) @[Decoder.scala 210:38]
    node _io_imm_T_16 = cat(_io_imm_T_14, _io_imm_T_15) @[Cat.scala 31:58]
    node _T_15 = eq(UInt<7>("h63"), opcode) @[Decoder.scala 213:18]
    node _immB_T = bits(io_inst, 31, 31) @[Decoder.scala 277:26]
    node _immB_T_1 = bits(io_inst, 7, 7) @[Decoder.scala 277:36]
    node _immB_T_2 = bits(io_inst, 30, 25) @[Decoder.scala 277:45]
    node _immB_T_3 = bits(io_inst, 11, 8) @[Decoder.scala 277:58]
    node immB_lo = cat(_immB_T_3, UInt<1>("h0")) @[Cat.scala 31:58]
    node immB_hi_hi = cat(_immB_T, _immB_T_1) @[Cat.scala 31:58]
    node immB_hi = cat(immB_hi_hi, _immB_T_2) @[Cat.scala 31:58]
    node immB = cat(immB_hi, immB_lo) @[Cat.scala 31:58]
    node _io_imm_T_17 = bits(immB, 12, 12) @[Decoder.scala 210:26]
    node _io_imm_T_18 = bits(_io_imm_T_17, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_19 = mux(_io_imm_T_18, UInt<19>("h7ffff"), UInt<19>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_20 = bits(immB, 12, 0) @[Decoder.scala 210:38]
    node _io_imm_T_21 = cat(_io_imm_T_19, _io_imm_T_20) @[Cat.scala 31:58]
    node _T_16 = eq(UInt<1>("h0"), funct3) @[Decoder.scala 280:22]
    node _T_17 = eq(UInt<1>("h1"), funct3) @[Decoder.scala 280:22]
    node _T_18 = eq(UInt<3>("h4"), funct3) @[Decoder.scala 280:22]
    node _T_19 = eq(UInt<3>("h5"), funct3) @[Decoder.scala 280:22]
    node _GEN_11 = mux(_T_19, UInt<4>("hd"), _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 191:11 280:22 284:42]
    node _GEN_12 = mux(_T_18, UInt<4>("hc"), _GEN_11) @[Decoder.scala 280:22 283:42]
    node _GEN_13 = mux(_T_17, UInt<4>("hb"), _GEN_12) @[Decoder.scala 280:22 282:42]
    node _GEN_14 = mux(_T_16, UInt<4>("ha"), _GEN_13) @[Decoder.scala 280:22 281:42]
    node _T_20 = eq(UInt<7>("h6f"), opcode) @[Decoder.scala 213:18]
    node _immJ_T = bits(io_inst, 31, 31) @[Decoder.scala 294:26]
    node _immJ_T_1 = bits(io_inst, 19, 12) @[Decoder.scala 294:36]
    node _immJ_T_2 = bits(io_inst, 20, 20) @[Decoder.scala 294:49]
    node _immJ_T_3 = bits(io_inst, 30, 21) @[Decoder.scala 294:59]
    node immJ_lo = cat(_immJ_T_3, UInt<1>("h0")) @[Cat.scala 31:58]
    node immJ_hi_hi = cat(_immJ_T, _immJ_T_1) @[Cat.scala 31:58]
    node immJ_hi = cat(immJ_hi_hi, _immJ_T_2) @[Cat.scala 31:58]
    node immJ = cat(immJ_hi, immJ_lo) @[Cat.scala 31:58]
    node _io_imm_T_22 = bits(immJ, 20, 20) @[Decoder.scala 210:26]
    node _io_imm_T_23 = bits(_io_imm_T_22, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_24 = mux(_io_imm_T_23, UInt<11>("h7ff"), UInt<11>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_25 = bits(immJ, 20, 0) @[Decoder.scala 210:38]
    node _io_imm_T_26 = cat(_io_imm_T_24, _io_imm_T_25) @[Cat.scala 31:58]
    node _T_21 = eq(UInt<7>("h67"), opcode) @[Decoder.scala 213:18]
    node _io_imm_T_27 = bits(io_inst, 31, 20) @[Decoder.scala 307:26]
    node _io_imm_T_28 = bits(_io_imm_T_27, 11, 11) @[Decoder.scala 210:26]
    node _io_imm_T_29 = bits(_io_imm_T_28, 0, 0) @[Bitwise.scala 74:15]
    node _io_imm_T_30 = mux(_io_imm_T_29, UInt<20>("hfffff"), UInt<20>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_31 = bits(_io_imm_T_27, 11, 0) @[Decoder.scala 210:38]
    node _io_imm_T_32 = cat(_io_imm_T_30, _io_imm_T_31) @[Cat.scala 31:58]
    node _T_22 = eq(UInt<6>("h37"), opcode) @[Decoder.scala 213:18]
    node _io_imm_T_33 = bits(io_inst, 31, 12) @[Decoder.scala 316:25]
    node _io_imm_T_34 = mux(UInt<1>("h0"), UInt<12>("hfff"), UInt<12>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_35 = cat(_io_imm_T_33, _io_imm_T_34) @[Cat.scala 31:58]
    node _T_23 = eq(UInt<5>("h17"), opcode) @[Decoder.scala 213:18]
    node _io_imm_T_36 = bits(io_inst, 31, 12) @[Decoder.scala 325:25]
    node _io_imm_T_37 = mux(UInt<1>("h0"), UInt<12>("hfff"), UInt<12>("h0")) @[Bitwise.scala 74:12]
    node _io_imm_T_38 = cat(_io_imm_T_36, _io_imm_T_37) @[Cat.scala 31:58]
    node _io_ctrl_WIRE_ctrlRegWrite = UInt<1>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_15 = mux(_T_23, UInt<1>("h1"), _io_ctrl_WIRE_ctrlRegWrite) @[Decoder.scala 191:11 213:18 323:28]
    node _GEN_16 = mux(_T_23, UInt<5>("h11"), _io_ctrl_WIRE_ctrlALUOp) @[Decoder.scala 191:11 213:18 324:28]
    node _GEN_17 = mux(_T_23, _io_imm_T_38, UInt<1>("h0")) @[Decoder.scala 195:10 213:18 325:14]
    node _GEN_18 = mux(_T_22, UInt<1>("h1"), _GEN_15) @[Decoder.scala 213:18 314:28]
    node _GEN_19 = mux(_T_22, UInt<5>("h10"), _GEN_16) @[Decoder.scala 213:18 315:28]
    node _GEN_20 = mux(_T_22, _io_imm_T_35, _GEN_17) @[Decoder.scala 213:18 316:14]
    node _io_ctrl_WIRE_ctrlJump = UInt<1>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_21 = mux(_T_21, UInt<1>("h1"), _io_ctrl_WIRE_ctrlJump) @[Decoder.scala 191:11 213:18 303:28]
    node _GEN_22 = mux(_T_21, UInt<1>("h1"), _GEN_18) @[Decoder.scala 213:18 304:28]
    node _io_ctrl_WIRE_ctrlALUSrc = UInt<1>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_23 = mux(_T_21, UInt<1>("h1"), _io_ctrl_WIRE_ctrlALUSrc) @[Decoder.scala 191:11 213:18 305:28]
    node _GEN_24 = mux(_T_21, UInt<4>("hf"), _GEN_19) @[Decoder.scala 213:18 306:28]
    node _GEN_25 = mux(_T_21, _io_imm_T_32, _GEN_20) @[Decoder.scala 213:18 307:14]
    node _GEN_26 = mux(_T_20, UInt<1>("h1"), _GEN_21) @[Decoder.scala 213:18 292:28]
    node _GEN_27 = mux(_T_20, UInt<1>("h1"), _GEN_22) @[Decoder.scala 213:18 293:28]
    node _GEN_28 = mux(_T_20, _io_imm_T_26, _GEN_25) @[Decoder.scala 213:18 295:14]
    node _GEN_29 = mux(_T_20, UInt<4>("he"), _GEN_24) @[Decoder.scala 213:18 296:25]
    node _GEN_30 = mux(_T_20, _io_ctrl_WIRE_ctrlALUSrc, _GEN_23) @[Decoder.scala 191:11 213:18]
    node _io_ctrl_WIRE_ctrlBranch = UInt<1>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_31 = mux(_T_15, UInt<1>("h1"), _io_ctrl_WIRE_ctrlBranch) @[Decoder.scala 191:11 213:18 276:26]
    node _GEN_32 = mux(_T_15, _io_imm_T_21, _GEN_28) @[Decoder.scala 213:18 278:14]
    node _GEN_33 = mux(_T_15, _GEN_14, _GEN_29) @[Decoder.scala 213:18]
    node _GEN_34 = mux(_T_15, _io_ctrl_WIRE_ctrlJump, _GEN_26) @[Decoder.scala 191:11 213:18]
    node _GEN_35 = mux(_T_15, _io_ctrl_WIRE_ctrlRegWrite, _GEN_27) @[Decoder.scala 191:11 213:18]
    node _GEN_36 = mux(_T_15, _io_ctrl_WIRE_ctrlALUSrc, _GEN_30) @[Decoder.scala 191:11 213:18]
    node _io_ctrl_WIRE_ctrlMemWrite = UInt<1>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_37 = mux(_T_14, UInt<1>("h1"), _io_ctrl_WIRE_ctrlMemWrite) @[Decoder.scala 191:11 213:18 265:28]
    node _GEN_38 = mux(_T_14, UInt<1>("h1"), _GEN_36) @[Decoder.scala 213:18 266:28]
    node _GEN_39 = mux(_T_14, UInt<1>("h1"), _GEN_33) @[Decoder.scala 213:18 267:28]
    node _GEN_40 = mux(_T_14, _io_imm_T_16, _GEN_32) @[Decoder.scala 213:18 269:14]
    node _GEN_41 = mux(_T_14, _io_ctrl_WIRE_ctrlBranch, _GEN_31) @[Decoder.scala 191:11 213:18]
    node _GEN_42 = mux(_T_14, _io_ctrl_WIRE_ctrlJump, _GEN_34) @[Decoder.scala 191:11 213:18]
    node _GEN_43 = mux(_T_14, _io_ctrl_WIRE_ctrlRegWrite, _GEN_35) @[Decoder.scala 191:11 213:18]
    node _GEN_44 = mux(_T_13, UInt<1>("h1"), _GEN_43) @[Decoder.scala 213:18 253:28]
    node _GEN_45 = mux(_T_13, UInt<1>("h1"), _GEN_38) @[Decoder.scala 213:18 254:28]
    node _io_ctrl_WIRE_ctrlMemRead = UInt<1>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_46 = mux(_T_13, UInt<1>("h1"), _io_ctrl_WIRE_ctrlMemRead) @[Decoder.scala 191:11 213:18 255:28]
    node _io_ctrl_WIRE_ctrlMemToReg = UInt<1>("h0") @[Decoder.scala 191:{26,26}]
    node _GEN_47 = mux(_T_13, UInt<1>("h1"), _io_ctrl_WIRE_ctrlMemToReg) @[Decoder.scala 191:11 213:18 256:28]
    node _GEN_48 = mux(_T_13, UInt<1>("h1"), _GEN_39) @[Decoder.scala 213:18 257:28]
    node _GEN_49 = mux(_T_13, _io_imm_T_11, _GEN_40) @[Decoder.scala 213:18 258:14]
    node _GEN_50 = mux(_T_13, _io_ctrl_WIRE_ctrlMemWrite, _GEN_37) @[Decoder.scala 191:11 213:18]
    node _GEN_51 = mux(_T_13, _io_ctrl_WIRE_ctrlBranch, _GEN_41) @[Decoder.scala 191:11 213:18]
    node _GEN_52 = mux(_T_13, _io_ctrl_WIRE_ctrlJump, _GEN_42) @[Decoder.scala 191:11 213:18]
    node _GEN_53 = mux(_T_8, UInt<1>("h1"), _GEN_44) @[Decoder.scala 213:18 235:28]
    node _GEN_54 = mux(_T_8, UInt<1>("h1"), _GEN_45) @[Decoder.scala 213:18 236:28]
    node _GEN_55 = mux(_T_8, _io_imm_T_5, _GEN_49) @[Decoder.scala 213:18 237:14]
    node _GEN_56 = mux(_T_8, _GEN_10, _GEN_48) @[Decoder.scala 213:18]
    node _GEN_57 = mux(_T_8, _io_ctrl_WIRE_ctrlMemRead, _GEN_46) @[Decoder.scala 191:11 213:18]
    node _GEN_58 = mux(_T_8, _io_ctrl_WIRE_ctrlMemToReg, _GEN_47) @[Decoder.scala 191:11 213:18]
    node _GEN_59 = mux(_T_8, _io_ctrl_WIRE_ctrlMemWrite, _GEN_50) @[Decoder.scala 191:11 213:18]
    node _GEN_60 = mux(_T_8, _io_ctrl_WIRE_ctrlBranch, _GEN_51) @[Decoder.scala 191:11 213:18]
    node _GEN_61 = mux(_T_8, _io_ctrl_WIRE_ctrlJump, _GEN_52) @[Decoder.scala 191:11 213:18]
    node _GEN_62 = mux(_T, UInt<1>("h1"), _GEN_53) @[Decoder.scala 213:18 218:28]
    node _GEN_63 = mux(_T, _GEN_6, _GEN_56) @[Decoder.scala 213:18]
    node _GEN_64 = mux(_T, _io_ctrl_WIRE_ctrlALUSrc, _GEN_54) @[Decoder.scala 191:11 213:18]
    node _GEN_65 = mux(_T, UInt<1>("h0"), _GEN_55) @[Decoder.scala 195:10 213:18]
    node _GEN_66 = mux(_T, _io_ctrl_WIRE_ctrlMemRead, _GEN_57) @[Decoder.scala 191:11 213:18]
    node _GEN_67 = mux(_T, _io_ctrl_WIRE_ctrlMemToReg, _GEN_58) @[Decoder.scala 191:11 213:18]
    node _GEN_68 = mux(_T, _io_ctrl_WIRE_ctrlMemWrite, _GEN_59) @[Decoder.scala 191:11 213:18]
    node _GEN_69 = mux(_T, _io_ctrl_WIRE_ctrlBranch, _GEN_60) @[Decoder.scala 191:11 213:18]
    node _GEN_70 = mux(_T, _io_ctrl_WIRE_ctrlJump, _GEN_61) @[Decoder.scala 191:11 213:18]
    io_ctrl_ctrlJump <= _GEN_70
    io_ctrl_ctrlBranch <= _GEN_69
    io_ctrl_ctrlRegWrite <= _GEN_62
    io_ctrl_ctrlMemRead <= _GEN_66
    io_ctrl_ctrlMemWrite <= _GEN_68
    io_ctrl_ctrlALUSrc <= _GEN_64
    io_ctrl_ctrlALUOp <= _GEN_63
    io_ctrl_ctrlMemToReg <= _GEN_67
    io_regs_rs1_addr <= rs1 @[Decoder.scala 192:20]
    io_regs_rs2_addr <= rs2 @[Decoder.scala 193:20]
    io_regs_rd_addr <= rd @[Decoder.scala 194:20]
    io_imm <= _GEN_65

  module Regfile :
    input clock : Clock
    input reset : UInt<1>
    input io_rs1_addr : UInt<5>
    input io_rs2_addr : UInt<5>
    output io_rs1_data : UInt<32>
    output io_rs2_data : UInt<32>
    input io_rd_addr : UInt<5>
    input io_wdata : UInt<32>
    input io_wen : UInt<1>

    reg regs_0 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_0) @[Regfile.scala 66:21]
    reg regs_1 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_1) @[Regfile.scala 66:21]
    reg regs_2 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_2) @[Regfile.scala 66:21]
    reg regs_3 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_3) @[Regfile.scala 66:21]
    reg regs_4 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_4) @[Regfile.scala 66:21]
    reg regs_5 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_5) @[Regfile.scala 66:21]
    reg regs_6 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_6) @[Regfile.scala 66:21]
    reg regs_7 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_7) @[Regfile.scala 66:21]
    reg regs_8 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_8) @[Regfile.scala 66:21]
    reg regs_9 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_9) @[Regfile.scala 66:21]
    reg regs_10 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_10) @[Regfile.scala 66:21]
    reg regs_11 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_11) @[Regfile.scala 66:21]
    reg regs_12 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_12) @[Regfile.scala 66:21]
    reg regs_13 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_13) @[Regfile.scala 66:21]
    reg regs_14 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_14) @[Regfile.scala 66:21]
    reg regs_15 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_15) @[Regfile.scala 66:21]
    reg regs_16 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_16) @[Regfile.scala 66:21]
    reg regs_17 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_17) @[Regfile.scala 66:21]
    reg regs_18 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_18) @[Regfile.scala 66:21]
    reg regs_19 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_19) @[Regfile.scala 66:21]
    reg regs_20 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_20) @[Regfile.scala 66:21]
    reg regs_21 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_21) @[Regfile.scala 66:21]
    reg regs_22 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_22) @[Regfile.scala 66:21]
    reg regs_23 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_23) @[Regfile.scala 66:21]
    reg regs_24 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_24) @[Regfile.scala 66:21]
    reg regs_25 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_25) @[Regfile.scala 66:21]
    reg regs_26 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_26) @[Regfile.scala 66:21]
    reg regs_27 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_27) @[Regfile.scala 66:21]
    reg regs_28 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_28) @[Regfile.scala 66:21]
    reg regs_29 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_29) @[Regfile.scala 66:21]
    reg regs_30 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_30) @[Regfile.scala 66:21]
    reg regs_31 : UInt<32>, clock with :
      reset => (UInt<1>("h0"), regs_31) @[Regfile.scala 66:21]
    node _T = neq(io_rd_addr, UInt<1>("h0")) @[Regfile.scala 69:30]
    node _T_1 = and(io_wen, _T) @[Regfile.scala 69:15]
    node _regs_io_rd_addr = io_wdata @[Regfile.scala 70:{22,22}]
    node _GEN_0 = mux(eq(UInt<1>("h0"), io_rd_addr), _regs_io_rd_addr, regs_0) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_1 = mux(eq(UInt<1>("h1"), io_rd_addr), _regs_io_rd_addr, regs_1) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_2 = mux(eq(UInt<2>("h2"), io_rd_addr), _regs_io_rd_addr, regs_2) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_3 = mux(eq(UInt<2>("h3"), io_rd_addr), _regs_io_rd_addr, regs_3) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_4 = mux(eq(UInt<3>("h4"), io_rd_addr), _regs_io_rd_addr, regs_4) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_5 = mux(eq(UInt<3>("h5"), io_rd_addr), _regs_io_rd_addr, regs_5) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_6 = mux(eq(UInt<3>("h6"), io_rd_addr), _regs_io_rd_addr, regs_6) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_7 = mux(eq(UInt<3>("h7"), io_rd_addr), _regs_io_rd_addr, regs_7) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_8 = mux(eq(UInt<4>("h8"), io_rd_addr), _regs_io_rd_addr, regs_8) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_9 = mux(eq(UInt<4>("h9"), io_rd_addr), _regs_io_rd_addr, regs_9) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_10 = mux(eq(UInt<4>("ha"), io_rd_addr), _regs_io_rd_addr, regs_10) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_11 = mux(eq(UInt<4>("hb"), io_rd_addr), _regs_io_rd_addr, regs_11) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_12 = mux(eq(UInt<4>("hc"), io_rd_addr), _regs_io_rd_addr, regs_12) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_13 = mux(eq(UInt<4>("hd"), io_rd_addr), _regs_io_rd_addr, regs_13) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_14 = mux(eq(UInt<4>("he"), io_rd_addr), _regs_io_rd_addr, regs_14) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_15 = mux(eq(UInt<4>("hf"), io_rd_addr), _regs_io_rd_addr, regs_15) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_16 = mux(eq(UInt<5>("h10"), io_rd_addr), _regs_io_rd_addr, regs_16) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_17 = mux(eq(UInt<5>("h11"), io_rd_addr), _regs_io_rd_addr, regs_17) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_18 = mux(eq(UInt<5>("h12"), io_rd_addr), _regs_io_rd_addr, regs_18) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_19 = mux(eq(UInt<5>("h13"), io_rd_addr), _regs_io_rd_addr, regs_19) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_20 = mux(eq(UInt<5>("h14"), io_rd_addr), _regs_io_rd_addr, regs_20) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_21 = mux(eq(UInt<5>("h15"), io_rd_addr), _regs_io_rd_addr, regs_21) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_22 = mux(eq(UInt<5>("h16"), io_rd_addr), _regs_io_rd_addr, regs_22) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_23 = mux(eq(UInt<5>("h17"), io_rd_addr), _regs_io_rd_addr, regs_23) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_24 = mux(eq(UInt<5>("h18"), io_rd_addr), _regs_io_rd_addr, regs_24) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_25 = mux(eq(UInt<5>("h19"), io_rd_addr), _regs_io_rd_addr, regs_25) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_26 = mux(eq(UInt<5>("h1a"), io_rd_addr), _regs_io_rd_addr, regs_26) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_27 = mux(eq(UInt<5>("h1b"), io_rd_addr), _regs_io_rd_addr, regs_27) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_28 = mux(eq(UInt<5>("h1c"), io_rd_addr), _regs_io_rd_addr, regs_28) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_29 = mux(eq(UInt<5>("h1d"), io_rd_addr), _regs_io_rd_addr, regs_29) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_30 = mux(eq(UInt<5>("h1e"), io_rd_addr), _regs_io_rd_addr, regs_30) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_31 = mux(eq(UInt<5>("h1f"), io_rd_addr), _regs_io_rd_addr, regs_31) @[Regfile.scala 66:21 70:{22,22}]
    node _GEN_32 = mux(_T_1, _GEN_0, regs_0) @[Regfile.scala 66:21 69:40]
    node _GEN_33 = mux(_T_1, _GEN_1, regs_1) @[Regfile.scala 66:21 69:40]
    node _GEN_34 = mux(_T_1, _GEN_2, regs_2) @[Regfile.scala 66:21 69:40]
    node _GEN_35 = mux(_T_1, _GEN_3, regs_3) @[Regfile.scala 66:21 69:40]
    node _GEN_36 = mux(_T_1, _GEN_4, regs_4) @[Regfile.scala 66:21 69:40]
    node _GEN_37 = mux(_T_1, _GEN_5, regs_5) @[Regfile.scala 66:21 69:40]
    node _GEN_38 = mux(_T_1, _GEN_6, regs_6) @[Regfile.scala 66:21 69:40]
    node _GEN_39 = mux(_T_1, _GEN_7, regs_7) @[Regfile.scala 66:21 69:40]
    node _GEN_40 = mux(_T_1, _GEN_8, regs_8) @[Regfile.scala 66:21 69:40]
    node _GEN_41 = mux(_T_1, _GEN_9, regs_9) @[Regfile.scala 66:21 69:40]
    node _GEN_42 = mux(_T_1, _GEN_10, regs_10) @[Regfile.scala 66:21 69:40]
    node _GEN_43 = mux(_T_1, _GEN_11, regs_11) @[Regfile.scala 66:21 69:40]
    node _GEN_44 = mux(_T_1, _GEN_12, regs_12) @[Regfile.scala 66:21 69:40]
    node _GEN_45 = mux(_T_1, _GEN_13, regs_13) @[Regfile.scala 66:21 69:40]
    node _GEN_46 = mux(_T_1, _GEN_14, regs_14) @[Regfile.scala 66:21 69:40]
    node _GEN_47 = mux(_T_1, _GEN_15, regs_15) @[Regfile.scala 66:21 69:40]
    node _GEN_48 = mux(_T_1, _GEN_16, regs_16) @[Regfile.scala 66:21 69:40]
    node _GEN_49 = mux(_T_1, _GEN_17, regs_17) @[Regfile.scala 66:21 69:40]
    node _GEN_50 = mux(_T_1, _GEN_18, regs_18) @[Regfile.scala 66:21 69:40]
    node _GEN_51 = mux(_T_1, _GEN_19, regs_19) @[Regfile.scala 66:21 69:40]
    node _GEN_52 = mux(_T_1, _GEN_20, regs_20) @[Regfile.scala 66:21 69:40]
    node _GEN_53 = mux(_T_1, _GEN_21, regs_21) @[Regfile.scala 66:21 69:40]
    node _GEN_54 = mux(_T_1, _GEN_22, regs_22) @[Regfile.scala 66:21 69:40]
    node _GEN_55 = mux(_T_1, _GEN_23, regs_23) @[Regfile.scala 66:21 69:40]
    node _GEN_56 = mux(_T_1, _GEN_24, regs_24) @[Regfile.scala 66:21 69:40]
    node _GEN_57 = mux(_T_1, _GEN_25, regs_25) @[Regfile.scala 66:21 69:40]
    node _GEN_58 = mux(_T_1, _GEN_26, regs_26) @[Regfile.scala 66:21 69:40]
    node _GEN_59 = mux(_T_1, _GEN_27, regs_27) @[Regfile.scala 66:21 69:40]
    node _GEN_60 = mux(_T_1, _GEN_28, regs_28) @[Regfile.scala 66:21 69:40]
    node _GEN_61 = mux(_T_1, _GEN_29, regs_29) @[Regfile.scala 66:21 69:40]
    node _GEN_62 = mux(_T_1, _GEN_30, regs_30) @[Regfile.scala 66:21 69:40]
    node _GEN_63 = mux(_T_1, _GEN_31, regs_31) @[Regfile.scala 66:21 69:40]
    node _io_rs1_data_T = eq(io_rs1_addr, UInt<1>("h0")) @[Regfile.scala 74:34]
    node _GEN_64 = validif(eq(UInt<1>("h0"), io_rs1_addr), regs_0) @[Regfile.scala 74:{21,21}]
    node _GEN_65 = mux(eq(UInt<1>("h1"), io_rs1_addr), regs_1, _GEN_64) @[Regfile.scala 74:{21,21}]
    node _GEN_66 = mux(eq(UInt<2>("h2"), io_rs1_addr), regs_2, _GEN_65) @[Regfile.scala 74:{21,21}]
    node _GEN_67 = mux(eq(UInt<2>("h3"), io_rs1_addr), regs_3, _GEN_66) @[Regfile.scala 74:{21,21}]
    node _GEN_68 = mux(eq(UInt<3>("h4"), io_rs1_addr), regs_4, _GEN_67) @[Regfile.scala 74:{21,21}]
    node _GEN_69 = mux(eq(UInt<3>("h5"), io_rs1_addr), regs_5, _GEN_68) @[Regfile.scala 74:{21,21}]
    node _GEN_70 = mux(eq(UInt<3>("h6"), io_rs1_addr), regs_6, _GEN_69) @[Regfile.scala 74:{21,21}]
    node _GEN_71 = mux(eq(UInt<3>("h7"), io_rs1_addr), regs_7, _GEN_70) @[Regfile.scala 74:{21,21}]
    node _GEN_72 = mux(eq(UInt<4>("h8"), io_rs1_addr), regs_8, _GEN_71) @[Regfile.scala 74:{21,21}]
    node _GEN_73 = mux(eq(UInt<4>("h9"), io_rs1_addr), regs_9, _GEN_72) @[Regfile.scala 74:{21,21}]
    node _GEN_74 = mux(eq(UInt<4>("ha"), io_rs1_addr), regs_10, _GEN_73) @[Regfile.scala 74:{21,21}]
    node _GEN_75 = mux(eq(UInt<4>("hb"), io_rs1_addr), regs_11, _GEN_74) @[Regfile.scala 74:{21,21}]
    node _GEN_76 = mux(eq(UInt<4>("hc"), io_rs1_addr), regs_12, _GEN_75) @[Regfile.scala 74:{21,21}]
    node _GEN_77 = mux(eq(UInt<4>("hd"), io_rs1_addr), regs_13, _GEN_76) @[Regfile.scala 74:{21,21}]
    node _GEN_78 = mux(eq(UInt<4>("he"), io_rs1_addr), regs_14, _GEN_77) @[Regfile.scala 74:{21,21}]
    node _GEN_79 = mux(eq(UInt<4>("hf"), io_rs1_addr), regs_15, _GEN_78) @[Regfile.scala 74:{21,21}]
    node _GEN_80 = mux(eq(UInt<5>("h10"), io_rs1_addr), regs_16, _GEN_79) @[Regfile.scala 74:{21,21}]
    node _GEN_81 = mux(eq(UInt<5>("h11"), io_rs1_addr), regs_17, _GEN_80) @[Regfile.scala 74:{21,21}]
    node _GEN_82 = mux(eq(UInt<5>("h12"), io_rs1_addr), regs_18, _GEN_81) @[Regfile.scala 74:{21,21}]
    node _GEN_83 = mux(eq(UInt<5>("h13"), io_rs1_addr), regs_19, _GEN_82) @[Regfile.scala 74:{21,21}]
    node _GEN_84 = mux(eq(UInt<5>("h14"), io_rs1_addr), regs_20, _GEN_83) @[Regfile.scala 74:{21,21}]
    node _GEN_85 = mux(eq(UInt<5>("h15"), io_rs1_addr), regs_21, _GEN_84) @[Regfile.scala 74:{21,21}]
    node _GEN_86 = mux(eq(UInt<5>("h16"), io_rs1_addr), regs_22, _GEN_85) @[Regfile.scala 74:{21,21}]
    node _GEN_87 = mux(eq(UInt<5>("h17"), io_rs1_addr), regs_23, _GEN_86) @[Regfile.scala 74:{21,21}]
    node _GEN_88 = mux(eq(UInt<5>("h18"), io_rs1_addr), regs_24, _GEN_87) @[Regfile.scala 74:{21,21}]
    node _GEN_89 = mux(eq(UInt<5>("h19"), io_rs1_addr), regs_25, _GEN_88) @[Regfile.scala 74:{21,21}]
    node _GEN_90 = mux(eq(UInt<5>("h1a"), io_rs1_addr), regs_26, _GEN_89) @[Regfile.scala 74:{21,21}]
    node _GEN_91 = mux(eq(UInt<5>("h1b"), io_rs1_addr), regs_27, _GEN_90) @[Regfile.scala 74:{21,21}]
    node _GEN_92 = mux(eq(UInt<5>("h1c"), io_rs1_addr), regs_28, _GEN_91) @[Regfile.scala 74:{21,21}]
    node _GEN_93 = mux(eq(UInt<5>("h1d"), io_rs1_addr), regs_29, _GEN_92) @[Regfile.scala 74:{21,21}]
    node _GEN_94 = mux(eq(UInt<5>("h1e"), io_rs1_addr), regs_30, _GEN_93) @[Regfile.scala 74:{21,21}]
    node _GEN_95 = mux(eq(UInt<5>("h1f"), io_rs1_addr), regs_31, _GEN_94) @[Regfile.scala 74:{21,21}]
    node _regs_io_rs1_addr = _GEN_95 @[Regfile.scala 74:21]
    node _io_rs1_data_T_1 = mux(_io_rs1_data_T, UInt<1>("h0"), _regs_io_rs1_addr) @[Regfile.scala 74:21]
    node _io_rs2_data_T = eq(io_rs2_addr, UInt<1>("h0")) @[Regfile.scala 75:34]
    node _GEN_96 = validif(eq(UInt<1>("h0"), io_rs2_addr), regs_0) @[Regfile.scala 75:{21,21}]
    node _GEN_97 = mux(eq(UInt<1>("h1"), io_rs2_addr), regs_1, _GEN_96) @[Regfile.scala 75:{21,21}]
    node _GEN_98 = mux(eq(UInt<2>("h2"), io_rs2_addr), regs_2, _GEN_97) @[Regfile.scala 75:{21,21}]
    node _GEN_99 = mux(eq(UInt<2>("h3"), io_rs2_addr), regs_3, _GEN_98) @[Regfile.scala 75:{21,21}]
    node _GEN_100 = mux(eq(UInt<3>("h4"), io_rs2_addr), regs_4, _GEN_99) @[Regfile.scala 75:{21,21}]
    node _GEN_101 = mux(eq(UInt<3>("h5"), io_rs2_addr), regs_5, _GEN_100) @[Regfile.scala 75:{21,21}]
    node _GEN_102 = mux(eq(UInt<3>("h6"), io_rs2_addr), regs_6, _GEN_101) @[Regfile.scala 75:{21,21}]
    node _GEN_103 = mux(eq(UInt<3>("h7"), io_rs2_addr), regs_7, _GEN_102) @[Regfile.scala 75:{21,21}]
    node _GEN_104 = mux(eq(UInt<4>("h8"), io_rs2_addr), regs_8, _GEN_103) @[Regfile.scala 75:{21,21}]
    node _GEN_105 = mux(eq(UInt<4>("h9"), io_rs2_addr), regs_9, _GEN_104) @[Regfile.scala 75:{21,21}]
    node _GEN_106 = mux(eq(UInt<4>("ha"), io_rs2_addr), regs_10, _GEN_105) @[Regfile.scala 75:{21,21}]
    node _GEN_107 = mux(eq(UInt<4>("hb"), io_rs2_addr), regs_11, _GEN_106) @[Regfile.scala 75:{21,21}]
    node _GEN_108 = mux(eq(UInt<4>("hc"), io_rs2_addr), regs_12, _GEN_107) @[Regfile.scala 75:{21,21}]
    node _GEN_109 = mux(eq(UInt<4>("hd"), io_rs2_addr), regs_13, _GEN_108) @[Regfile.scala 75:{21,21}]
    node _GEN_110 = mux(eq(UInt<4>("he"), io_rs2_addr), regs_14, _GEN_109) @[Regfile.scala 75:{21,21}]
    node _GEN_111 = mux(eq(UInt<4>("hf"), io_rs2_addr), regs_15, _GEN_110) @[Regfile.scala 75:{21,21}]
    node _GEN_112 = mux(eq(UInt<5>("h10"), io_rs2_addr), regs_16, _GEN_111) @[Regfile.scala 75:{21,21}]
    node _GEN_113 = mux(eq(UInt<5>("h11"), io_rs2_addr), regs_17, _GEN_112) @[Regfile.scala 75:{21,21}]
    node _GEN_114 = mux(eq(UInt<5>("h12"), io_rs2_addr), regs_18, _GEN_113) @[Regfile.scala 75:{21,21}]
    node _GEN_115 = mux(eq(UInt<5>("h13"), io_rs2_addr), regs_19, _GEN_114) @[Regfile.scala 75:{21,21}]
    node _GEN_116 = mux(eq(UInt<5>("h14"), io_rs2_addr), regs_20, _GEN_115) @[Regfile.scala 75:{21,21}]
    node _GEN_117 = mux(eq(UInt<5>("h15"), io_rs2_addr), regs_21, _GEN_116) @[Regfile.scala 75:{21,21}]
    node _GEN_118 = mux(eq(UInt<5>("h16"), io_rs2_addr), regs_22, _GEN_117) @[Regfile.scala 75:{21,21}]
    node _GEN_119 = mux(eq(UInt<5>("h17"), io_rs2_addr), regs_23, _GEN_118) @[Regfile.scala 75:{21,21}]
    node _GEN_120 = mux(eq(UInt<5>("h18"), io_rs2_addr), regs_24, _GEN_119) @[Regfile.scala 75:{21,21}]
    node _GEN_121 = mux(eq(UInt<5>("h19"), io_rs2_addr), regs_25, _GEN_120) @[Regfile.scala 75:{21,21}]
    node _GEN_122 = mux(eq(UInt<5>("h1a"), io_rs2_addr), regs_26, _GEN_121) @[Regfile.scala 75:{21,21}]
    node _GEN_123 = mux(eq(UInt<5>("h1b"), io_rs2_addr), regs_27, _GEN_122) @[Regfile.scala 75:{21,21}]
    node _GEN_124 = mux(eq(UInt<5>("h1c"), io_rs2_addr), regs_28, _GEN_123) @[Regfile.scala 75:{21,21}]
    node _GEN_125 = mux(eq(UInt<5>("h1d"), io_rs2_addr), regs_29, _GEN_124) @[Regfile.scala 75:{21,21}]
    node _GEN_126 = mux(eq(UInt<5>("h1e"), io_rs2_addr), regs_30, _GEN_125) @[Regfile.scala 75:{21,21}]
    node _GEN_127 = mux(eq(UInt<5>("h1f"), io_rs2_addr), regs_31, _GEN_126) @[Regfile.scala 75:{21,21}]
    node _regs_io_rs2_addr = _GEN_127 @[Regfile.scala 75:21]
    node _io_rs2_data_T_1 = mux(_io_rs2_data_T, UInt<1>("h0"), _regs_io_rs2_addr) @[Regfile.scala 75:21]
    node _regs_WIRE_0 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_1 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_2 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_3 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_4 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_5 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_6 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_7 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_8 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_9 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_10 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_11 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_12 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_13 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_14 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_15 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_16 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_17 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_18 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_19 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_20 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_21 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_22 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_23 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_24 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_25 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_26 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_27 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_28 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_29 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_30 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    node _regs_WIRE_31 = UInt<32>("h0") @[Regfile.scala 66:{29,29}]
    io_rs1_data <= _io_rs1_data_T_1 @[Regfile.scala 74:15]
    io_rs2_data <= _io_rs2_data_T_1 @[Regfile.scala 75:15]
    regs_0 <= mux(reset, _regs_WIRE_0, _GEN_32) @[Regfile.scala 66:{21,21}]
    regs_1 <= mux(reset, _regs_WIRE_1, _GEN_33) @[Regfile.scala 66:{21,21}]
    regs_2 <= mux(reset, _regs_WIRE_2, _GEN_34) @[Regfile.scala 66:{21,21}]
    regs_3 <= mux(reset, _regs_WIRE_3, _GEN_35) @[Regfile.scala 66:{21,21}]
    regs_4 <= mux(reset, _regs_WIRE_4, _GEN_36) @[Regfile.scala 66:{21,21}]
    regs_5 <= mux(reset, _regs_WIRE_5, _GEN_37) @[Regfile.scala 66:{21,21}]
    regs_6 <= mux(reset, _regs_WIRE_6, _GEN_38) @[Regfile.scala 66:{21,21}]
    regs_7 <= mux(reset, _regs_WIRE_7, _GEN_39) @[Regfile.scala 66:{21,21}]
    regs_8 <= mux(reset, _regs_WIRE_8, _GEN_40) @[Regfile.scala 66:{21,21}]
    regs_9 <= mux(reset, _regs_WIRE_9, _GEN_41) @[Regfile.scala 66:{21,21}]
    regs_10 <= mux(reset, _regs_WIRE_10, _GEN_42) @[Regfile.scala 66:{21,21}]
    regs_11 <= mux(reset, _regs_WIRE_11, _GEN_43) @[Regfile.scala 66:{21,21}]
    regs_12 <= mux(reset, _regs_WIRE_12, _GEN_44) @[Regfile.scala 66:{21,21}]
    regs_13 <= mux(reset, _regs_WIRE_13, _GEN_45) @[Regfile.scala 66:{21,21}]
    regs_14 <= mux(reset, _regs_WIRE_14, _GEN_46) @[Regfile.scala 66:{21,21}]
    regs_15 <= mux(reset, _regs_WIRE_15, _GEN_47) @[Regfile.scala 66:{21,21}]
    regs_16 <= mux(reset, _regs_WIRE_16, _GEN_48) @[Regfile.scala 66:{21,21}]
    regs_17 <= mux(reset, _regs_WIRE_17, _GEN_49) @[Regfile.scala 66:{21,21}]
    regs_18 <= mux(reset, _regs_WIRE_18, _GEN_50) @[Regfile.scala 66:{21,21}]
    regs_19 <= mux(reset, _regs_WIRE_19, _GEN_51) @[Regfile.scala 66:{21,21}]
    regs_20 <= mux(reset, _regs_WIRE_20, _GEN_52) @[Regfile.scala 66:{21,21}]
    regs_21 <= mux(reset, _regs_WIRE_21, _GEN_53) @[Regfile.scala 66:{21,21}]
    regs_22 <= mux(reset, _regs_WIRE_22, _GEN_54) @[Regfile.scala 66:{21,21}]
    regs_23 <= mux(reset, _regs_WIRE_23, _GEN_55) @[Regfile.scala 66:{21,21}]
    regs_24 <= mux(reset, _regs_WIRE_24, _GEN_56) @[Regfile.scala 66:{21,21}]
    regs_25 <= mux(reset, _regs_WIRE_25, _GEN_57) @[Regfile.scala 66:{21,21}]
    regs_26 <= mux(reset, _regs_WIRE_26, _GEN_58) @[Regfile.scala 66:{21,21}]
    regs_27 <= mux(reset, _regs_WIRE_27, _GEN_59) @[Regfile.scala 66:{21,21}]
    regs_28 <= mux(reset, _regs_WIRE_28, _GEN_60) @[Regfile.scala 66:{21,21}]
    regs_29 <= mux(reset, _regs_WIRE_29, _GEN_61) @[Regfile.scala 66:{21,21}]
    regs_30 <= mux(reset, _regs_WIRE_30, _GEN_62) @[Regfile.scala 66:{21,21}]
    regs_31 <= mux(reset, _regs_WIRE_31, _GEN_63) @[Regfile.scala 66:{21,21}]

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

    node shamt = bits(io_src2, 4, 0) @[Alu.scala 68:22]
    node src1_s = asSInt(io_src1) @[Alu.scala 69:24]
    node src2_s = asSInt(io_src2) @[Alu.scala 70:24]
    node _T = eq(UInt<1>("h1"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T = add(io_src1, io_src2) @[Alu.scala 76:42]
    node _alu_result_T_1 = tail(_alu_result_T, 1) @[Alu.scala 76:42]
    node _T_1 = eq(UInt<2>("h2"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_2 = sub(io_src1, io_src2) @[Alu.scala 77:42]
    node _alu_result_T_3 = tail(_alu_result_T_2, 1) @[Alu.scala 77:42]
    node _T_2 = eq(UInt<2>("h3"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_4 = and(io_src1, io_src2) @[Alu.scala 78:42]
    node _T_3 = eq(UInt<3>("h4"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_5 = or(io_src1, io_src2) @[Alu.scala 79:42]
    node _T_4 = eq(UInt<3>("h5"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_6 = xor(io_src1, io_src2) @[Alu.scala 80:42]
    node _T_5 = eq(UInt<3>("h6"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_7 = lt(src1_s, src2_s) @[Alu.scala 81:42]
    node _T_6 = eq(UInt<3>("h7"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_8 = dshl(io_src1, shamt) @[Alu.scala 82:42]
    node _T_7 = eq(UInt<4>("h8"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_9 = dshr(io_src1, shamt) @[Alu.scala 83:42]
    node _T_8 = eq(UInt<4>("h9"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_10 = dshr(src1_s, shamt) @[Alu.scala 84:42]
    node _alu_result_T_11 = asUInt(_alu_result_T_10) @[Alu.scala 84:52]
    node _T_9 = eq(UInt<5>("h10"), io_aluOp) @[Alu.scala 72:20]
    node _T_10 = eq(UInt<5>("h11"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_12 = add(io_pc, io_imm) @[Alu.scala 90:40]
    node _alu_result_T_13 = tail(_alu_result_T_12, 1) @[Alu.scala 90:40]
    node _T_11 = eq(UInt<4>("ha"), io_aluOp) @[Alu.scala 72:20]
    node _to_branch_T = eq(io_src1, io_src2) @[Alu.scala 97:29]
    node _jump_addr_T = add(io_pc, io_imm) @[Alu.scala 98:26]
    node _jump_addr_T_1 = tail(_jump_addr_T, 1) @[Alu.scala 98:26]
    node _T_12 = eq(UInt<4>("hb"), io_aluOp) @[Alu.scala 72:20]
    node _to_branch_T_1 = neq(io_src1, io_src2) @[Alu.scala 101:29]
    node _jump_addr_T_2 = add(io_pc, io_imm) @[Alu.scala 102:26]
    node _jump_addr_T_3 = tail(_jump_addr_T_2, 1) @[Alu.scala 102:26]
    node _T_13 = eq(UInt<4>("hc"), io_aluOp) @[Alu.scala 72:20]
    node _to_branch_T_2 = lt(src1_s, src2_s) @[Alu.scala 105:28]
    node _jump_addr_T_4 = add(io_pc, io_imm) @[Alu.scala 106:26]
    node _jump_addr_T_5 = tail(_jump_addr_T_4, 1) @[Alu.scala 106:26]
    node _T_14 = eq(UInt<4>("hd"), io_aluOp) @[Alu.scala 72:20]
    node _to_branch_T_3 = geq(src1_s, src2_s) @[Alu.scala 109:28]
    node _jump_addr_T_6 = add(io_pc, io_imm) @[Alu.scala 110:26]
    node _jump_addr_T_7 = tail(_jump_addr_T_6, 1) @[Alu.scala 110:26]
    node _T_15 = eq(UInt<4>("he"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_14 = add(io_pc, UInt<3>("h4")) @[Alu.scala 118:27]
    node _alu_result_T_15 = tail(_alu_result_T_14, 1) @[Alu.scala 118:27]
    node _jump_addr_T_8 = add(io_pc, io_imm) @[Alu.scala 120:27]
    node _jump_addr_T_9 = tail(_jump_addr_T_8, 1) @[Alu.scala 120:27]
    node _T_16 = eq(UInt<4>("hf"), io_aluOp) @[Alu.scala 72:20]
    node _alu_result_T_16 = add(io_pc, UInt<3>("h4")) @[Alu.scala 124:27]
    node _alu_result_T_17 = tail(_alu_result_T_16, 1) @[Alu.scala 124:27]
    node _jump_addr_T_10 = add(io_src1, io_imm) @[Alu.scala 126:30]
    node _jump_addr_T_11 = tail(_jump_addr_T_10, 1) @[Alu.scala 126:30]
    node _jump_addr_T_12 = not(UInt<32>("h1")) @[Alu.scala 126:43]
    node _jump_addr_T_13 = and(_jump_addr_T_11, _jump_addr_T_12) @[Alu.scala 126:40]
    node _T_17 = eq(UInt<1>("h0"), io_aluOp) @[Alu.scala 72:20]
    node _GEN_0 = mux(_T_16, _alu_result_T_17, UInt<32>("h0")) @[Alu.scala 124:18 72:20]
    node _GEN_1 = mux(_T_16, UInt<1>("h1"), UInt<1>("h0")) @[Alu.scala 125:18 72:20]
    node _GEN_2 = mux(_T_16, _jump_addr_T_13, UInt<32>("h0")) @[Alu.scala 126:18 72:20]
    node _GEN_3 = mux(_T_15, _alu_result_T_15, _GEN_0) @[Alu.scala 118:18 72:20]
    node _GEN_4 = mux(_T_15, UInt<1>("h1"), _GEN_1) @[Alu.scala 119:18 72:20]
    node _GEN_5 = mux(_T_15, _jump_addr_T_9, _GEN_2) @[Alu.scala 120:18 72:20]
    node _GEN_6 = mux(_T_14, _to_branch_T_3, _GEN_4) @[Alu.scala 109:17 72:20]
    node _GEN_7 = mux(_T_14, _jump_addr_T_7, _GEN_5) @[Alu.scala 110:17 72:20]
    node _GEN_8 = mux(_T_14, UInt<32>("h0"), _GEN_3) @[Alu.scala 72:20]
    node _GEN_9 = mux(_T_13, _to_branch_T_2, _GEN_6) @[Alu.scala 105:17 72:20]
    node _GEN_10 = mux(_T_13, _jump_addr_T_5, _GEN_7) @[Alu.scala 106:17 72:20]
    node _GEN_11 = mux(_T_13, UInt<32>("h0"), _GEN_8) @[Alu.scala 72:20]
    node _GEN_12 = mux(_T_12, _to_branch_T_1, _GEN_9) @[Alu.scala 101:17 72:20]
    node _GEN_13 = mux(_T_12, _jump_addr_T_3, _GEN_10) @[Alu.scala 102:17 72:20]
    node _GEN_14 = mux(_T_12, UInt<32>("h0"), _GEN_11) @[Alu.scala 72:20]
    node _GEN_15 = mux(_T_11, _to_branch_T, _GEN_12) @[Alu.scala 72:20 97:17]
    node _GEN_16 = mux(_T_11, _jump_addr_T_1, _GEN_13) @[Alu.scala 72:20 98:17]
    node _GEN_17 = mux(_T_11, UInt<32>("h0"), _GEN_14) @[Alu.scala 72:20]
    node _GEN_18 = mux(_T_10, _alu_result_T_13, _GEN_17) @[Alu.scala 72:20 90:31]
    node _GEN_19 = mux(_T_10, UInt<1>("h0"), _GEN_15) @[Alu.scala 72:20]
    node _GEN_20 = mux(_T_10, UInt<32>("h0"), _GEN_16) @[Alu.scala 72:20]
    node _GEN_21 = mux(_T_9, io_imm, _GEN_18) @[Alu.scala 72:20 89:31]
    node _GEN_22 = mux(_T_9, UInt<1>("h0"), _GEN_19) @[Alu.scala 72:20]
    node _GEN_23 = mux(_T_9, UInt<32>("h0"), _GEN_20) @[Alu.scala 72:20]
    node _GEN_24 = mux(_T_8, _alu_result_T_11, _GEN_21) @[Alu.scala 72:20 84:31]
    node _GEN_25 = mux(_T_8, UInt<1>("h0"), _GEN_22) @[Alu.scala 72:20]
    node _GEN_26 = mux(_T_8, UInt<32>("h0"), _GEN_23) @[Alu.scala 72:20]
    node _GEN_27 = mux(_T_7, _alu_result_T_9, _GEN_24) @[Alu.scala 72:20 83:31]
    node _GEN_28 = mux(_T_7, UInt<1>("h0"), _GEN_25) @[Alu.scala 72:20]
    node _GEN_29 = mux(_T_7, UInt<32>("h0"), _GEN_26) @[Alu.scala 72:20]
    node _GEN_30 = mux(_T_6, _alu_result_T_8, _GEN_27) @[Alu.scala 72:20 82:31]
    node _GEN_31 = mux(_T_6, UInt<1>("h0"), _GEN_28) @[Alu.scala 72:20]
    node _GEN_32 = mux(_T_6, UInt<32>("h0"), _GEN_29) @[Alu.scala 72:20]
    node _GEN_33 = mux(_T_5, _alu_result_T_7, _GEN_30) @[Alu.scala 72:20 81:31]
    node _GEN_34 = mux(_T_5, UInt<1>("h0"), _GEN_31) @[Alu.scala 72:20]
    node _GEN_35 = mux(_T_5, UInt<32>("h0"), _GEN_32) @[Alu.scala 72:20]
    node _GEN_36 = mux(_T_4, _alu_result_T_6, _GEN_33) @[Alu.scala 72:20 80:31]
    node _GEN_37 = mux(_T_4, UInt<1>("h0"), _GEN_34) @[Alu.scala 72:20]
    node _GEN_38 = mux(_T_4, UInt<32>("h0"), _GEN_35) @[Alu.scala 72:20]
    node _GEN_39 = mux(_T_3, _alu_result_T_5, _GEN_36) @[Alu.scala 72:20 79:31]
    node _GEN_40 = mux(_T_3, UInt<1>("h0"), _GEN_37) @[Alu.scala 72:20]
    node _GEN_41 = mux(_T_3, UInt<32>("h0"), _GEN_38) @[Alu.scala 72:20]
    node _GEN_42 = mux(_T_2, _alu_result_T_4, _GEN_39) @[Alu.scala 72:20 78:31]
    node _GEN_43 = mux(_T_2, UInt<1>("h0"), _GEN_40) @[Alu.scala 72:20]
    node _GEN_44 = mux(_T_2, UInt<32>("h0"), _GEN_41) @[Alu.scala 72:20]
    node _GEN_45 = mux(_T_1, _alu_result_T_3, _GEN_42) @[Alu.scala 72:20 77:31]
    node _GEN_46 = mux(_T_1, UInt<1>("h0"), _GEN_43) @[Alu.scala 72:20]
    node _GEN_47 = mux(_T_1, UInt<32>("h0"), _GEN_44) @[Alu.scala 72:20]
    node _GEN_48 = mux(_T, _alu_result_T_1, _GEN_45) @[Alu.scala 72:20 76:31]
    node _GEN_49 = mux(_T, UInt<1>("h0"), _GEN_46) @[Alu.scala 72:20]
    node _GEN_50 = mux(_T, UInt<32>("h0"), _GEN_47) @[Alu.scala 72:20]
    node to_branch = _GEN_49
    node alu_result = bits(_GEN_48, 31, 0)
    node jump_addr = _GEN_50
    io_to_branch <= to_branch @[Alu.scala 138:17]
    io_alu_result <= alu_result @[Alu.scala 137:17]
    io_jump_addr <= jump_addr @[Alu.scala 139:17]

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
    input io_stall : UInt<1>
    input io_flush : UInt<1>
    input io_in_pc : UInt<32>
    input io_in_inst : UInt<32>
    output io_out_pc : UInt<32>
    output io_out_inst : UInt<32>

    reg reg_pc : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_pc) @[Reg_IF_ID.scala 21:20]
    reg reg_inst : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_inst) @[Reg_IF_ID.scala 21:20]
    node _T = eq(io_stall, UInt<1>("h0")) @[Reg_IF_ID.scala 25:16]
    node _GEN_0 = mux(_T, io_in_inst, reg_inst) @[Reg_IF_ID.scala 21:20 25:27 26:9]
    node _GEN_1 = mux(_T, io_in_pc, reg_pc) @[Reg_IF_ID.scala 21:20 25:27 26:9]
    node _reg_WIRE_1_inst = UInt<32>("h0") @[Reg_IF_ID.scala 24:{24,24}]
    node _GEN_2 = mux(io_flush, _reg_WIRE_1_inst, _GEN_0) @[Reg_IF_ID.scala 23:19 24:9]
    node _reg_WIRE_1_pc = UInt<32>("h0") @[Reg_IF_ID.scala 24:{24,24}]
    node _GEN_3 = mux(io_flush, _reg_WIRE_1_pc, _GEN_1) @[Reg_IF_ID.scala 23:19 24:9]
    node _reg_WIRE_pc = UInt<32>("h0") @[Reg_IF_ID.scala 21:{33,33}]
    node _reg_WIRE_inst = UInt<32>("h0") @[Reg_IF_ID.scala 21:{33,33}]
    io_out_pc <= reg_pc @[Reg_IF_ID.scala 29:10]
    io_out_inst <= reg_inst @[Reg_IF_ID.scala 29:10]
    reg_pc <= mux(reset, _reg_WIRE_pc, _GEN_3) @[Reg_IF_ID.scala 21:{20,20}]
    reg_inst <= mux(reset, _reg_WIRE_inst, _GEN_2) @[Reg_IF_ID.scala 21:{20,20}]

  module Reg_ID_EX :
    input clock : Clock
    input reset : UInt<1>
    input io_stall : UInt<1>
    input io_flush : UInt<1>
    input io_in_pc : UInt<32>
    input io_in_rs1_data : UInt<32>
    input io_in_rs2_data : UInt<32>
    input io_in_imm : UInt<32>
    input io_in_regs_rs1_addr : UInt<5>
    input io_in_regs_rs2_addr : UInt<5>
    input io_in_regs_rd_addr : UInt<5>
    input io_in_ctrl_ctrlJump : UInt<1>
    input io_in_ctrl_ctrlBranch : UInt<1>
    input io_in_ctrl_ctrlRegWrite : UInt<1>
    input io_in_ctrl_ctrlMemRead : UInt<1>
    input io_in_ctrl_ctrlMemWrite : UInt<1>
    input io_in_ctrl_ctrlALUSrc : UInt<1>
    input io_in_ctrl_ctrlALUOp : UInt<5>
    input io_in_ctrl_ctrlMemToReg : UInt<1>
    output io_out_pc : UInt<32>
    output io_out_rs1_data : UInt<32>
    output io_out_rs2_data : UInt<32>
    output io_out_imm : UInt<32>
    output io_out_regs_rs1_addr : UInt<5>
    output io_out_regs_rs2_addr : UInt<5>
    output io_out_regs_rd_addr : UInt<5>
    output io_out_ctrl_ctrlJump : UInt<1>
    output io_out_ctrl_ctrlBranch : UInt<1>
    output io_out_ctrl_ctrlRegWrite : UInt<1>
    output io_out_ctrl_ctrlMemRead : UInt<1>
    output io_out_ctrl_ctrlMemWrite : UInt<1>
    output io_out_ctrl_ctrlALUSrc : UInt<1>
    output io_out_ctrl_ctrlALUOp : UInt<5>
    output io_out_ctrl_ctrlMemToReg : UInt<1>

    reg reg_pc : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_pc) @[Reg_IF_ID.scala 51:20]
    reg reg_rs1_data : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_rs1_data) @[Reg_IF_ID.scala 51:20]
    reg reg_rs2_data : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_rs2_data) @[Reg_IF_ID.scala 51:20]
    reg reg_imm : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_imm) @[Reg_IF_ID.scala 51:20]
    reg reg_regs_rs1_addr : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_regs_rs1_addr) @[Reg_IF_ID.scala 51:20]
    reg reg_regs_rs2_addr : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_regs_rs2_addr) @[Reg_IF_ID.scala 51:20]
    reg reg_regs_rd_addr : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_regs_rd_addr) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlJump : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlJump) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlBranch : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlBranch) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlRegWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlRegWrite) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlMemRead : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlMemRead) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlMemWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlMemWrite) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlALUSrc : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlALUSrc) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlALUOp : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlALUOp) @[Reg_IF_ID.scala 51:20]
    reg reg_ctrl_ctrlMemToReg : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlMemToReg) @[Reg_IF_ID.scala 51:20]
    node _T = eq(io_stall, UInt<1>("h0")) @[Reg_IF_ID.scala 55:16]
    node _GEN_0 = mux(_T, io_in_ctrl_ctrlMemToReg, reg_ctrl_ctrlMemToReg) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_1 = mux(_T, io_in_ctrl_ctrlALUOp, reg_ctrl_ctrlALUOp) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_2 = mux(_T, io_in_ctrl_ctrlALUSrc, reg_ctrl_ctrlALUSrc) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_3 = mux(_T, io_in_ctrl_ctrlMemWrite, reg_ctrl_ctrlMemWrite) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_4 = mux(_T, io_in_ctrl_ctrlMemRead, reg_ctrl_ctrlMemRead) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_5 = mux(_T, io_in_ctrl_ctrlRegWrite, reg_ctrl_ctrlRegWrite) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_6 = mux(_T, io_in_ctrl_ctrlBranch, reg_ctrl_ctrlBranch) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_7 = mux(_T, io_in_ctrl_ctrlJump, reg_ctrl_ctrlJump) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_8 = mux(_T, io_in_regs_rd_addr, reg_regs_rd_addr) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_9 = mux(_T, io_in_regs_rs2_addr, reg_regs_rs2_addr) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_10 = mux(_T, io_in_regs_rs1_addr, reg_regs_rs1_addr) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_11 = mux(_T, io_in_imm, reg_imm) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_12 = mux(_T, io_in_rs2_data, reg_rs2_data) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_13 = mux(_T, io_in_rs1_data, reg_rs1_data) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _GEN_14 = mux(_T, io_in_pc, reg_pc) @[Reg_IF_ID.scala 51:20 55:27 56:9]
    node _reg_WIRE_1_ctrl_ctrlMemToReg = UInt<1>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_15 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlMemToReg, _GEN_0) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_ctrl_ctrlALUOp = UInt<5>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_16 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlALUOp, _GEN_1) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_ctrl_ctrlALUSrc = UInt<1>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_17 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlALUSrc, _GEN_2) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_ctrl_ctrlMemWrite = UInt<1>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_18 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlMemWrite, _GEN_3) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_ctrl_ctrlMemRead = UInt<1>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_19 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlMemRead, _GEN_4) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_ctrl_ctrlRegWrite = UInt<1>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_20 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlRegWrite, _GEN_5) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_ctrl_ctrlBranch = UInt<1>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_21 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlBranch, _GEN_6) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_ctrl_ctrlJump = UInt<1>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_22 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlJump, _GEN_7) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_regs_rd_addr = UInt<5>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_23 = mux(io_flush, _reg_WIRE_1_regs_rd_addr, _GEN_8) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_regs_rs2_addr = UInt<5>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_24 = mux(io_flush, _reg_WIRE_1_regs_rs2_addr, _GEN_9) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_regs_rs1_addr = UInt<5>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_25 = mux(io_flush, _reg_WIRE_1_regs_rs1_addr, _GEN_10) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_imm = UInt<32>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_26 = mux(io_flush, _reg_WIRE_1_imm, _GEN_11) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_rs2_data = UInt<32>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_27 = mux(io_flush, _reg_WIRE_1_rs2_data, _GEN_12) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_rs1_data = UInt<32>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_28 = mux(io_flush, _reg_WIRE_1_rs1_data, _GEN_13) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_1_pc = UInt<32>("h0") @[Reg_IF_ID.scala 54:{24,24}]
    node _GEN_29 = mux(io_flush, _reg_WIRE_1_pc, _GEN_14) @[Reg_IF_ID.scala 53:19 54:9]
    node _reg_WIRE_pc = UInt<32>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_rs1_data = UInt<32>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_rs2_data = UInt<32>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_imm = UInt<32>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_regs_rs1_addr = UInt<5>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_regs_rs2_addr = UInt<5>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_regs_rd_addr = UInt<5>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlJump = UInt<1>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlBranch = UInt<1>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlRegWrite = UInt<1>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlMemRead = UInt<1>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlMemWrite = UInt<1>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlALUSrc = UInt<1>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlALUOp = UInt<5>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    node _reg_WIRE_ctrl_ctrlMemToReg = UInt<1>("h0") @[Reg_IF_ID.scala 51:{33,33}]
    io_out_pc <= reg_pc @[Reg_IF_ID.scala 59:10]
    io_out_rs1_data <= reg_rs1_data @[Reg_IF_ID.scala 59:10]
    io_out_rs2_data <= reg_rs2_data @[Reg_IF_ID.scala 59:10]
    io_out_imm <= reg_imm @[Reg_IF_ID.scala 59:10]
    io_out_regs_rs1_addr <= reg_regs_rs1_addr @[Reg_IF_ID.scala 59:10]
    io_out_regs_rs2_addr <= reg_regs_rs2_addr @[Reg_IF_ID.scala 59:10]
    io_out_regs_rd_addr <= reg_regs_rd_addr @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlJump <= reg_ctrl_ctrlJump @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlBranch <= reg_ctrl_ctrlBranch @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlRegWrite <= reg_ctrl_ctrlRegWrite @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlMemRead <= reg_ctrl_ctrlMemRead @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlMemWrite <= reg_ctrl_ctrlMemWrite @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlALUSrc <= reg_ctrl_ctrlALUSrc @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlALUOp <= reg_ctrl_ctrlALUOp @[Reg_IF_ID.scala 59:10]
    io_out_ctrl_ctrlMemToReg <= reg_ctrl_ctrlMemToReg @[Reg_IF_ID.scala 59:10]
    reg_pc <= mux(reset, _reg_WIRE_pc, _GEN_29) @[Reg_IF_ID.scala 51:{20,20}]
    reg_rs1_data <= mux(reset, _reg_WIRE_rs1_data, _GEN_28) @[Reg_IF_ID.scala 51:{20,20}]
    reg_rs2_data <= mux(reset, _reg_WIRE_rs2_data, _GEN_27) @[Reg_IF_ID.scala 51:{20,20}]
    reg_imm <= mux(reset, _reg_WIRE_imm, _GEN_26) @[Reg_IF_ID.scala 51:{20,20}]
    reg_regs_rs1_addr <= mux(reset, _reg_WIRE_regs_rs1_addr, _GEN_25) @[Reg_IF_ID.scala 51:{20,20}]
    reg_regs_rs2_addr <= mux(reset, _reg_WIRE_regs_rs2_addr, _GEN_24) @[Reg_IF_ID.scala 51:{20,20}]
    reg_regs_rd_addr <= mux(reset, _reg_WIRE_regs_rd_addr, _GEN_23) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlJump <= mux(reset, _reg_WIRE_ctrl_ctrlJump, _GEN_22) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlBranch <= mux(reset, _reg_WIRE_ctrl_ctrlBranch, _GEN_21) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlRegWrite <= mux(reset, _reg_WIRE_ctrl_ctrlRegWrite, _GEN_20) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlMemRead <= mux(reset, _reg_WIRE_ctrl_ctrlMemRead, _GEN_19) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlMemWrite <= mux(reset, _reg_WIRE_ctrl_ctrlMemWrite, _GEN_18) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlALUSrc <= mux(reset, _reg_WIRE_ctrl_ctrlALUSrc, _GEN_17) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlALUOp <= mux(reset, _reg_WIRE_ctrl_ctrlALUOp, _GEN_16) @[Reg_IF_ID.scala 51:{20,20}]
    reg_ctrl_ctrlMemToReg <= mux(reset, _reg_WIRE_ctrl_ctrlMemToReg, _GEN_15) @[Reg_IF_ID.scala 51:{20,20}]

  module Reg_EX_MEM :
    input clock : Clock
    input reset : UInt<1>
    input io_stall : UInt<1>
    input io_flush : UInt<1>
    input io_in_pc : UInt<32>
    input io_in_alu_res : UInt<32>
    input io_in_rs2_data : UInt<32>
    input io_in_regs_rs1_addr : UInt<5>
    input io_in_regs_rs2_addr : UInt<5>
    input io_in_regs_rd_addr : UInt<5>
    input io_in_ctrl_ctrlJump : UInt<1>
    input io_in_ctrl_ctrlBranch : UInt<1>
    input io_in_ctrl_ctrlRegWrite : UInt<1>
    input io_in_ctrl_ctrlMemRead : UInt<1>
    input io_in_ctrl_ctrlMemWrite : UInt<1>
    input io_in_ctrl_ctrlALUSrc : UInt<1>
    input io_in_ctrl_ctrlALUOp : UInt<5>
    input io_in_ctrl_ctrlMemToReg : UInt<1>
    output io_out_pc : UInt<32>
    output io_out_alu_res : UInt<32>
    output io_out_rs2_data : UInt<32>
    output io_out_regs_rs1_addr : UInt<5>
    output io_out_regs_rs2_addr : UInt<5>
    output io_out_regs_rd_addr : UInt<5>
    output io_out_ctrl_ctrlJump : UInt<1>
    output io_out_ctrl_ctrlBranch : UInt<1>
    output io_out_ctrl_ctrlRegWrite : UInt<1>
    output io_out_ctrl_ctrlMemRead : UInt<1>
    output io_out_ctrl_ctrlMemWrite : UInt<1>
    output io_out_ctrl_ctrlALUSrc : UInt<1>
    output io_out_ctrl_ctrlALUOp : UInt<5>
    output io_out_ctrl_ctrlMemToReg : UInt<1>

    reg reg_pc : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_pc) @[Reg_IF_ID.scala 80:20]
    reg reg_alu_res : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_alu_res) @[Reg_IF_ID.scala 80:20]
    reg reg_rs2_data : UInt<32>, clock with :
      reset => (UInt<1>("h0"), reg_rs2_data) @[Reg_IF_ID.scala 80:20]
    reg reg_regs_rs1_addr : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_regs_rs1_addr) @[Reg_IF_ID.scala 80:20]
    reg reg_regs_rs2_addr : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_regs_rs2_addr) @[Reg_IF_ID.scala 80:20]
    reg reg_regs_rd_addr : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_regs_rd_addr) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlJump : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlJump) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlBranch : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlBranch) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlRegWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlRegWrite) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlMemRead : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlMemRead) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlMemWrite : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlMemWrite) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlALUSrc : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlALUSrc) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlALUOp : UInt<5>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlALUOp) @[Reg_IF_ID.scala 80:20]
    reg reg_ctrl_ctrlMemToReg : UInt<1>, clock with :
      reset => (UInt<1>("h0"), reg_ctrl_ctrlMemToReg) @[Reg_IF_ID.scala 80:20]
    node _T = eq(io_stall, UInt<1>("h0")) @[Reg_IF_ID.scala 84:16]
    node _GEN_0 = mux(_T, io_in_ctrl_ctrlMemToReg, reg_ctrl_ctrlMemToReg) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_1 = mux(_T, io_in_ctrl_ctrlALUOp, reg_ctrl_ctrlALUOp) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_2 = mux(_T, io_in_ctrl_ctrlALUSrc, reg_ctrl_ctrlALUSrc) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_3 = mux(_T, io_in_ctrl_ctrlMemWrite, reg_ctrl_ctrlMemWrite) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_4 = mux(_T, io_in_ctrl_ctrlMemRead, reg_ctrl_ctrlMemRead) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_5 = mux(_T, io_in_ctrl_ctrlRegWrite, reg_ctrl_ctrlRegWrite) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_6 = mux(_T, io_in_ctrl_ctrlBranch, reg_ctrl_ctrlBranch) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_7 = mux(_T, io_in_ctrl_ctrlJump, reg_ctrl_ctrlJump) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_8 = mux(_T, io_in_regs_rd_addr, reg_regs_rd_addr) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_9 = mux(_T, io_in_regs_rs2_addr, reg_regs_rs2_addr) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_10 = mux(_T, io_in_regs_rs1_addr, reg_regs_rs1_addr) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_11 = mux(_T, io_in_rs2_data, reg_rs2_data) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_12 = mux(_T, io_in_alu_res, reg_alu_res) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _GEN_13 = mux(_T, io_in_pc, reg_pc) @[Reg_IF_ID.scala 80:20 84:27 85:9]
    node _reg_WIRE_1_ctrl_ctrlMemToReg = UInt<1>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_14 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlMemToReg, _GEN_0) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_ctrl_ctrlALUOp = UInt<5>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_15 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlALUOp, _GEN_1) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_ctrl_ctrlALUSrc = UInt<1>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_16 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlALUSrc, _GEN_2) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_ctrl_ctrlMemWrite = UInt<1>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_17 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlMemWrite, _GEN_3) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_ctrl_ctrlMemRead = UInt<1>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_18 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlMemRead, _GEN_4) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_ctrl_ctrlRegWrite = UInt<1>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_19 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlRegWrite, _GEN_5) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_ctrl_ctrlBranch = UInt<1>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_20 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlBranch, _GEN_6) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_ctrl_ctrlJump = UInt<1>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_21 = mux(io_flush, _reg_WIRE_1_ctrl_ctrlJump, _GEN_7) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_regs_rd_addr = UInt<5>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_22 = mux(io_flush, _reg_WIRE_1_regs_rd_addr, _GEN_8) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_regs_rs2_addr = UInt<5>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_23 = mux(io_flush, _reg_WIRE_1_regs_rs2_addr, _GEN_9) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_regs_rs1_addr = UInt<5>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_24 = mux(io_flush, _reg_WIRE_1_regs_rs1_addr, _GEN_10) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_rs2_data = UInt<32>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_25 = mux(io_flush, _reg_WIRE_1_rs2_data, _GEN_11) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_alu_res = UInt<32>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_26 = mux(io_flush, _reg_WIRE_1_alu_res, _GEN_12) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_1_pc = UInt<32>("h0") @[Reg_IF_ID.scala 83:{24,24}]
    node _GEN_27 = mux(io_flush, _reg_WIRE_1_pc, _GEN_13) @[Reg_IF_ID.scala 82:19 83:9]
    node _reg_WIRE_pc = UInt<32>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_alu_res = UInt<32>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_rs2_data = UInt<32>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_regs_rs1_addr = UInt<5>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_regs_rs2_addr = UInt<5>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_regs_rd_addr = UInt<5>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlJump = UInt<1>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlBranch = UInt<1>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlRegWrite = UInt<1>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlMemRead = UInt<1>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlMemWrite = UInt<1>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlALUSrc = UInt<1>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlALUOp = UInt<5>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    node _reg_WIRE_ctrl_ctrlMemToReg = UInt<1>("h0") @[Reg_IF_ID.scala 80:{33,33}]
    io_out_pc <= reg_pc @[Reg_IF_ID.scala 88:10]
    io_out_alu_res <= reg_alu_res @[Reg_IF_ID.scala 88:10]
    io_out_rs2_data <= reg_rs2_data @[Reg_IF_ID.scala 88:10]
    io_out_regs_rs1_addr <= reg_regs_rs1_addr @[Reg_IF_ID.scala 88:10]
    io_out_regs_rs2_addr <= reg_regs_rs2_addr @[Reg_IF_ID.scala 88:10]
    io_out_regs_rd_addr <= reg_regs_rd_addr @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlJump <= reg_ctrl_ctrlJump @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlBranch <= reg_ctrl_ctrlBranch @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlRegWrite <= reg_ctrl_ctrlRegWrite @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlMemRead <= reg_ctrl_ctrlMemRead @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlMemWrite <= reg_ctrl_ctrlMemWrite @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlALUSrc <= reg_ctrl_ctrlALUSrc @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlALUOp <= reg_ctrl_ctrlALUOp @[Reg_IF_ID.scala 88:10]
    io_out_ctrl_ctrlMemToReg <= reg_ctrl_ctrlMemToReg @[Reg_IF_ID.scala 88:10]
    reg_pc <= mux(reset, _reg_WIRE_pc, _GEN_27) @[Reg_IF_ID.scala 80:{20,20}]
    reg_alu_res <= mux(reset, _reg_WIRE_alu_res, _GEN_26) @[Reg_IF_ID.scala 80:{20,20}]
    reg_rs2_data <= mux(reset, _reg_WIRE_rs2_data, _GEN_25) @[Reg_IF_ID.scala 80:{20,20}]
    reg_regs_rs1_addr <= mux(reset, _reg_WIRE_regs_rs1_addr, _GEN_24) @[Reg_IF_ID.scala 80:{20,20}]
    reg_regs_rs2_addr <= mux(reset, _reg_WIRE_regs_rs2_addr, _GEN_23) @[Reg_IF_ID.scala 80:{20,20}]
    reg_regs_rd_addr <= mux(reset, _reg_WIRE_regs_rd_addr, _GEN_22) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlJump <= mux(reset, _reg_WIRE_ctrl_ctrlJump, _GEN_21) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlBranch <= mux(reset, _reg_WIRE_ctrl_ctrlBranch, _GEN_20) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlRegWrite <= mux(reset, _reg_WIRE_ctrl_ctrlRegWrite, _GEN_19) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlMemRead <= mux(reset, _reg_WIRE_ctrl_ctrlMemRead, _GEN_18) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlMemWrite <= mux(reset, _reg_WIRE_ctrl_ctrlMemWrite, _GEN_17) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlALUSrc <= mux(reset, _reg_WIRE_ctrl_ctrlALUSrc, _GEN_16) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlALUOp <= mux(reset, _reg_WIRE_ctrl_ctrlALUOp, _GEN_15) @[Reg_IF_ID.scala 80:{20,20}]
    reg_ctrl_ctrlMemToReg <= mux(reset, _reg_WIRE_ctrl_ctrlMemToReg, _GEN_14) @[Reg_IF_ID.scala 80:{20,20}]

  module Core :
    input clock : Clock
    input reset : UInt<1>
    output io_pc : UInt<32>
    output io_inst : UInt<32>
    output io_wb_result : UInt<32>
    output io_peek_write : UInt<1>
    output io_peek_addr : UInt<32>
    output io_peek_data : UInt<32>

    inst pc_handle of PCHandle @[Core.scala 26:25]
    inst inst_mem of InstMem @[Core.scala 27:25]
    inst decoder of Decoder @[Core.scala 28:25]
    inst reg_file of Regfile @[Core.scala 29:25]
    inst alu of Alu @[Core.scala 30:25]
    inst data_mem of DataMem @[Core.scala 31:25]
    inst if_id of Reg_IF_ID @[Core.scala 42:24]
    inst id_ex of Reg_ID_EX @[Core.scala 65:24]
    inst ex_mem of Reg_EX_MEM @[Core.scala 92:25]
    inst mem_wb of Reg_EX_MEM @[Core.scala 122:25]
    node alu_src2 = mux(id_ex.io_out_ctrl_ctrlALUSrc, id_ex.io_out_imm, id_ex.io_out_rs2_data) @[Core.scala 84:21]
    reg delayedMemRead : UInt<1>, clock with :
      reset => (UInt<1>("h0"), delayedMemRead) @[Core.scala 113:32]
    node wb_data = mux(mem_wb.io_out_ctrl_ctrlMemToReg, data_mem.io_data_out, mem_wb.io_out_rs2_data) @[Core.scala 144:20]
    node if_id_in_pc = pc_handle.io_pc @[Core.scala 43:22 44:17]
    node if_id_in_inst = inst_mem.io_inst @[Core.scala 43:22 45:17]
    node id_ex_in_pc = if_id.io_out_pc @[Core.scala 66:22 68:22]
    node id_ex_in_rs1_data = reg_file.io_rs1_data @[Core.scala 66:22 69:22]
    node id_ex_in_rs2_data = reg_file.io_rs2_data @[Core.scala 66:22 70:22]
    node id_ex_in_imm = decoder.io_imm @[Core.scala 66:22 71:22]
    node id_ex_in_regs_rs1_addr = decoder.io_regs_rs1_addr @[Core.scala 66:22 72:22]
    node id_ex_in_regs_rs2_addr = decoder.io_regs_rs2_addr @[Core.scala 66:22 72:22]
    node id_ex_in_regs_rd_addr = decoder.io_regs_rd_addr @[Core.scala 66:22 72:22]
    node id_ex_in_ctrl_ctrlJump = decoder.io_ctrl_ctrlJump @[Core.scala 66:22 73:22]
    node id_ex_in_ctrl_ctrlBranch = decoder.io_ctrl_ctrlBranch @[Core.scala 66:22 73:22]
    node id_ex_in_ctrl_ctrlRegWrite = decoder.io_ctrl_ctrlRegWrite @[Core.scala 66:22 73:22]
    node id_ex_in_ctrl_ctrlMemRead = decoder.io_ctrl_ctrlMemRead @[Core.scala 66:22 73:22]
    node id_ex_in_ctrl_ctrlMemWrite = decoder.io_ctrl_ctrlMemWrite @[Core.scala 66:22 73:22]
    node id_ex_in_ctrl_ctrlALUSrc = decoder.io_ctrl_ctrlALUSrc @[Core.scala 66:22 73:22]
    node id_ex_in_ctrl_ctrlALUOp = decoder.io_ctrl_ctrlALUOp @[Core.scala 66:22 73:22]
    node id_ex_in_ctrl_ctrlMemToReg = decoder.io_ctrl_ctrlMemToReg @[Core.scala 66:22 73:22]
    node ex_mem_in_pc = id_ex.io_out_pc @[Core.scala 93:23 95:22]
    node ex_mem_in_alu_res = alu.io_alu_result @[Core.scala 93:23 96:22]
    node ex_mem_in_rs2_data = id_ex.io_out_rs2_data @[Core.scala 93:23 97:22]
    node ex_mem_in_regs_rs1_addr = id_ex.io_out_regs_rs1_addr @[Core.scala 93:23 98:22]
    node ex_mem_in_regs_rs2_addr = id_ex.io_out_regs_rs2_addr @[Core.scala 93:23 98:22]
    node ex_mem_in_regs_rd_addr = id_ex.io_out_regs_rd_addr @[Core.scala 93:23 98:22]
    node ex_mem_in_ctrl_ctrlJump = id_ex.io_out_ctrl_ctrlJump @[Core.scala 93:23 99:22]
    node ex_mem_in_ctrl_ctrlBranch = id_ex.io_out_ctrl_ctrlBranch @[Core.scala 93:23 99:22]
    node ex_mem_in_ctrl_ctrlRegWrite = id_ex.io_out_ctrl_ctrlRegWrite @[Core.scala 93:23 99:22]
    node ex_mem_in_ctrl_ctrlMemRead = id_ex.io_out_ctrl_ctrlMemRead @[Core.scala 93:23 99:22]
    node ex_mem_in_ctrl_ctrlMemWrite = id_ex.io_out_ctrl_ctrlMemWrite @[Core.scala 93:23 99:22]
    node ex_mem_in_ctrl_ctrlALUSrc = id_ex.io_out_ctrl_ctrlALUSrc @[Core.scala 93:23 99:22]
    node ex_mem_in_ctrl_ctrlALUOp = id_ex.io_out_ctrl_ctrlALUOp @[Core.scala 93:23 99:22]
    node ex_mem_in_ctrl_ctrlMemToReg = id_ex.io_out_ctrl_ctrlMemToReg @[Core.scala 93:23 99:22]
    node mem_wb_in_pc = ex_mem.io_out_pc @[Core.scala 123:23 126:22]
    node mem_wb_in_mem_data = UInt<32>("h0") @[Core.scala 123:23 132:22]
    node mem_wb_in_alu_res = ex_mem.io_out_alu_res @[Core.scala 123:23 127:22]
    node mem_wb_in_regs_rs1_addr = ex_mem.io_out_regs_rs1_addr @[Core.scala 123:23 128:22]
    node mem_wb_in_regs_rs2_addr = ex_mem.io_out_regs_rs2_addr @[Core.scala 123:23 128:22]
    node mem_wb_in_regs_rd_addr = ex_mem.io_out_regs_rd_addr @[Core.scala 123:23 128:22]
    node mem_wb_in_ctrl_ctrlJump = ex_mem.io_out_ctrl_ctrlJump @[Core.scala 123:23 129:22]
    node mem_wb_in_ctrl_ctrlBranch = ex_mem.io_out_ctrl_ctrlBranch @[Core.scala 123:23 129:22]
    node mem_wb_in_ctrl_ctrlRegWrite = ex_mem.io_out_ctrl_ctrlRegWrite @[Core.scala 123:23 129:22]
    node mem_wb_in_ctrl_ctrlMemRead = ex_mem.io_out_ctrl_ctrlMemRead @[Core.scala 123:23 129:22]
    node mem_wb_in_ctrl_ctrlMemWrite = ex_mem.io_out_ctrl_ctrlMemWrite @[Core.scala 123:23 129:22]
    node mem_wb_in_ctrl_ctrlALUSrc = ex_mem.io_out_ctrl_ctrlALUSrc @[Core.scala 123:23 129:22]
    node mem_wb_in_ctrl_ctrlALUOp = ex_mem.io_out_ctrl_ctrlALUOp @[Core.scala 123:23 129:22]
    node mem_wb_in_ctrl_ctrlMemToReg = ex_mem.io_out_ctrl_ctrlMemToReg @[Core.scala 123:23 129:22]
    io_pc <= pc_handle.io_pc @[Core.scala 158:16]
    io_inst <= inst_mem.io_inst @[Core.scala 159:16]
    io_wb_result <= wb_data @[Core.scala 160:16]
    io_peek_write <= data_mem.io_peek_write @[Core.scala 163:17]
    io_peek_addr <= data_mem.io_addr @[Core.scala 164:17]
    io_peek_data <= data_mem.io_data_in @[Core.scala 165:17]
    pc_handle.clock <= clock
    pc_handle.reset <= reset
    pc_handle.io_to_branch <= UInt<1>("h0") @[Core.scala 36:26]
    pc_handle.io_jump_addr <= UInt<32>("h0") @[Core.scala 37:26]
    inst_mem.clock <= clock
    inst_mem.reset <= reset
    inst_mem.io_addr <= pc_handle.io_pc @[Core.scala 39:20]
    decoder.clock <= clock
    decoder.reset <= reset
    decoder.io_inst <= if_id.io_out_inst @[Core.scala 57:19]
    reg_file.clock <= clock
    reg_file.reset <= reset
    reg_file.io_rs1_addr <= decoder.io_regs_rs1_addr @[Core.scala 59:24]
    reg_file.io_rs2_addr <= decoder.io_regs_rs2_addr @[Core.scala 60:24]
    reg_file.io_rd_addr <= mem_wb.io_out_regs_rd_addr @[Core.scala 151:23]
    reg_file.io_wdata <= wb_data @[Core.scala 152:23]
    reg_file.io_wen <= mem_wb.io_out_ctrl_ctrlRegWrite @[Core.scala 150:23]
    alu.clock <= clock
    alu.reset <= reset
    alu.io_src1 <= id_ex.io_out_rs1_data @[Core.scala 86:16]
    alu.io_src2 <= alu_src2 @[Core.scala 87:16]
    alu.io_pc <= id_ex.io_out_pc @[Core.scala 88:16]
    alu.io_imm <= id_ex.io_out_imm @[Core.scala 89:16]
    alu.io_aluOp <= id_ex.io_out_ctrl_ctrlALUOp @[Core.scala 90:16]
    data_mem.clock <= clock
    data_mem.reset <= reset
    data_mem.io_ctrlMemRead <= delayedMemRead @[Core.scala 114:28]
    data_mem.io_ctrlMemWrite <= ex_mem.io_out_ctrl_ctrlMemWrite @[Core.scala 118:28]
    data_mem.io_addr <= ex_mem.io_out_alu_res @[Core.scala 119:28]
    data_mem.io_data_in <= ex_mem.io_out_rs2_data @[Core.scala 120:28]
    if_id.clock <= clock
    if_id.reset <= reset
    if_id.io_stall <= UInt<1>("h0") @[Core.scala 47:18]
    if_id.io_flush <= UInt<1>("h0") @[Core.scala 48:18]
    if_id.io_in_pc <= if_id_in_pc @[Core.scala 49:18]
    if_id.io_in_inst <= if_id_in_inst @[Core.scala 49:18]
    id_ex.clock <= clock
    id_ex.reset <= reset
    id_ex.io_stall <= UInt<1>("h0") @[Core.scala 75:18]
    id_ex.io_flush <= UInt<1>("h0") @[Core.scala 76:18]
    id_ex.io_in_pc <= id_ex_in_pc @[Core.scala 77:18]
    id_ex.io_in_rs1_data <= id_ex_in_rs1_data @[Core.scala 77:18]
    id_ex.io_in_rs2_data <= id_ex_in_rs2_data @[Core.scala 77:18]
    id_ex.io_in_imm <= id_ex_in_imm @[Core.scala 77:18]
    id_ex.io_in_regs_rs1_addr <= id_ex_in_regs_rs1_addr @[Core.scala 77:18]
    id_ex.io_in_regs_rs2_addr <= id_ex_in_regs_rs2_addr @[Core.scala 77:18]
    id_ex.io_in_regs_rd_addr <= id_ex_in_regs_rd_addr @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlJump <= id_ex_in_ctrl_ctrlJump @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlBranch <= id_ex_in_ctrl_ctrlBranch @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlRegWrite <= id_ex_in_ctrl_ctrlRegWrite @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlMemRead <= id_ex_in_ctrl_ctrlMemRead @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlMemWrite <= id_ex_in_ctrl_ctrlMemWrite @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlALUSrc <= id_ex_in_ctrl_ctrlALUSrc @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlALUOp <= id_ex_in_ctrl_ctrlALUOp @[Core.scala 77:18]
    id_ex.io_in_ctrl_ctrlMemToReg <= id_ex_in_ctrl_ctrlMemToReg @[Core.scala 77:18]
    ex_mem.clock <= clock
    ex_mem.reset <= reset
    ex_mem.io_stall <= UInt<1>("h0") @[Core.scala 101:19]
    ex_mem.io_flush <= UInt<1>("h0") @[Core.scala 102:19]
    ex_mem.io_in_pc <= ex_mem_in_pc @[Core.scala 103:19]
    ex_mem.io_in_alu_res <= ex_mem_in_alu_res @[Core.scala 103:19]
    ex_mem.io_in_rs2_data <= ex_mem_in_rs2_data @[Core.scala 103:19]
    ex_mem.io_in_regs_rs1_addr <= ex_mem_in_regs_rs1_addr @[Core.scala 103:19]
    ex_mem.io_in_regs_rs2_addr <= ex_mem_in_regs_rs2_addr @[Core.scala 103:19]
    ex_mem.io_in_regs_rd_addr <= ex_mem_in_regs_rd_addr @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlJump <= ex_mem_in_ctrl_ctrlJump @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlBranch <= ex_mem_in_ctrl_ctrlBranch @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlRegWrite <= ex_mem_in_ctrl_ctrlRegWrite @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlMemRead <= ex_mem_in_ctrl_ctrlMemRead @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlMemWrite <= ex_mem_in_ctrl_ctrlMemWrite @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlALUSrc <= ex_mem_in_ctrl_ctrlALUSrc @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlALUOp <= ex_mem_in_ctrl_ctrlALUOp @[Core.scala 103:19]
    ex_mem.io_in_ctrl_ctrlMemToReg <= ex_mem_in_ctrl_ctrlMemToReg @[Core.scala 103:19]
    delayedMemRead <= mux(reset, UInt<1>("h0"), ex_mem.io_out_ctrl_ctrlMemRead) @[Core.scala 113:{32,32,32}]
    mem_wb.clock <= clock
    mem_wb.reset <= reset
    mem_wb.io_stall <= UInt<1>("h0") @[Core.scala 135:19]
    mem_wb.io_flush <= UInt<1>("h0") @[Core.scala 136:19]
    mem_wb.io_in_pc <= mem_wb_in_pc @[Core.scala 137:19]
    mem_wb.io_in_alu_res <= mem_wb_in_mem_data @[Core.scala 137:19]
    mem_wb.io_in_rs2_data <= mem_wb_in_alu_res @[Core.scala 137:19]
    mem_wb.io_in_regs_rs1_addr <= mem_wb_in_regs_rs1_addr @[Core.scala 137:19]
    mem_wb.io_in_regs_rs2_addr <= mem_wb_in_regs_rs2_addr @[Core.scala 137:19]
    mem_wb.io_in_regs_rd_addr <= mem_wb_in_regs_rd_addr @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlJump <= mem_wb_in_ctrl_ctrlJump @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlBranch <= mem_wb_in_ctrl_ctrlBranch @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlRegWrite <= mem_wb_in_ctrl_ctrlRegWrite @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlMemRead <= mem_wb_in_ctrl_ctrlMemRead @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlMemWrite <= mem_wb_in_ctrl_ctrlMemWrite @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlALUSrc <= mem_wb_in_ctrl_ctrlALUSrc @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlALUOp <= mem_wb_in_ctrl_ctrlALUOp @[Core.scala 137:19]
    mem_wb.io_in_ctrl_ctrlMemToReg <= mem_wb_in_ctrl_ctrlMemToReg @[Core.scala 137:19]
