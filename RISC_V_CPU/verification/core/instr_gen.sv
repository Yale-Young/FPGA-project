class instr_gen;

typedef enum{
    ADD,   SUB,     SLL,   SLT,   SLTU,   XOR,   SRL,   SRA,   OR,   AND,
    MUL,  MULH,  MULHSU, MULHU,    DIV,  DIVU,   REM,  REMU,
    LB,     LH,      LW,   LBU,    LHU,  ADDI,SLTI,SLTIU,XORI,ORI,ANDI,
    FENCE,FENCEI,ECALL,EBREAK,CSRRW,CSRRS,CSRRC,CSRRWI,CSSRRSI,CSRRCI,
    SB,SH,SW,BEQ,BNE,BLT,BGE,BLTU,BGEU,LUI,AUIPC,JAL,JALR,POP,MRET,RET
  }instr_type;

int size_all;
int ww[];
rand bit[31:0]  pc[];
rand bit[4:0]   rs1[];
rand bit[4:0]   rs2[];
rand bit[4:0]   rd[];
rand bit[31:0]  imm[];
rand bit[11:0]  csr[];
rand instr_type it[];


//size
constraint size_a{
    rs1.size == size_all;
    rs2.size == size_all;
    rd.size  == size_all;
    imm.size == size_all;
    it.size  == size_all;
    csr.size == size_all;
}
//weight
constraint www{
  foreach(it[i]){
      it[i] dist {
      0:=ww[0],1:=ww[1],2:=ww[2],3:=ww[3],4:=ww[4],5:=ww[5],6:=ww[6],7:=ww[7],8:=ww[8],9:=ww[9],10:=ww[10],11:=ww[11],12:=ww[12],13:=ww[13],14:=ww[14],15:=ww[15],16:=ww[16],17:=ww[17],18:=ww[18],19:=ww[19],20:=ww[20],21:=ww[21],22:=ww[22],23:=ww[23],24:=ww[24],25:=ww[25],26:=ww[26],27:=ww[27],28:=ww[28],29:=ww[29],30:=ww[30],31:=ww[31],32:=ww[32],33:=ww[33],34:=ww[34],35:=ww[35],36:=ww[36],37:=ww[37],38:=ww[38],39:=ww[39],40:=ww[40],41:=ww[41],42:=ww[42],43:=ww[43],44:=ww[44],45:=ww[45],46:=ww[46],47:=ww[47],48:=ww[48],49:=ww[49],50:=ww[50],51:=ww[51],52:=ww[52],53:=ww[53],54:=ww[54],55:=ww[55],56:=ww[56],57:=ww[57]
      };
  }
}
constraint csrr{
    foreach(csr[i])
    csr[i] inside {12'hc00,12'hc80,12'h305,12'h342,12'h341,12'h304,12'h300,12'h340};
}
//内容
constraint opcode_{
    foreach(it[i]){
          //R type
          (it[i] == 0) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b000,rd[i],7'b0110011};//add
          (it[i] == 1) -> pc[i] == {7'b0100000,rs2[i],rs1[i],3'b000,rd[i],7'b0110011};//sub
          (it[i] == 2) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b001,rd[i],7'b0110011};//sll
          (it[i] == 3) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b010,rd[i],7'b0110011};//slt
          (it[i] == 4) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b011,rd[i],7'b0110011};//sltu
          (it[i] == 5) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b100,rd[i],7'b0110011};//xor
          (it[i] == 6) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b101,rd[i],7'b0110011};//srl
          (it[i] == 7) -> pc[i] == {7'b0100000,rs2[i],rs1[i],3'b101,rd[i],7'b0110011};//sra
          (it[i] == 8) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b110,rd[i],7'b0110011};//or
          (it[i] == 9) -> pc[i] == {7'b0000000,rs2[i],rs1[i],3'b111,rd[i],7'b0110011};//and
          
          (it[i] == 10) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b000,rd[i],7'b0110011};//mul
          (it[i] == 11) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b001,rd[i],7'b0110011};
          (it[i] == 12) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b010,rd[i],7'b0110011};
          (it[i] == 13) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b011,rd[i],7'b0110011};
          (it[i] == 14) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b100,rd[i],7'b0110011};
          (it[i] == 15) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b101,rd[i],7'b0110011};
          (it[i] == 16) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b110,rd[i],7'b0110011};
          (it[i] == 17) -> pc[i] == {7'b0000001,rs2[i],rs1[i],3'b111,rd[i],7'b0110011};
          //I type
          (it[i] == 18) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b000,rd[i],7'b0000011};//lb
          (it[i] == 19) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b001,rd[i],7'b0000011};//lh
          (it[i] == 20) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b010,rd[i],7'b0000011};//lw
          (it[i] == 21) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b100,rd[i],7'b0000011};//lbu
          (it[i] == 22) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b101,rd[i],7'b0000011};//lhu
          
          (it[i] == 23) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b000,rd[i],7'b0010011};//addi
          (it[i] == 24) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b010,rd[i],7'b0010011};//slti
          (it[i] == 25) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b011,rd[i],7'b0010011};//sltiu
          (it[i] == 26) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b100,rd[i],7'b0010011};//xori
          (it[i] == 27) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b110,rd[i],7'b0010011};//ori
          (it[i] == 28) -> pc[i] ==  {imm[i][11:0],rs1[i],3'b111,rd[i],7'b0010011};//andi
          
          (it[i] == 29) -> pc[i] == {7'b0000000,imm[i][4:0],rs1[i],3'b001,rd[i],7'b0010011};//slli
          (it[i] == 30) -> pc[i] == {7'b0000000,imm[i][4:0],rs1[i],3'b101,rd[i],7'b0010011};//srli
          (it[i] == 31) -> pc[i] == {7'b0100000,imm[i][4:0],rs1[i],3'b101,rd[i],7'b0010011};//srai
          
          (it[i] == 32) -> pc[i] == {4'b0000,imm[i][7:0],20'b0000_0000_0000_0000_1111};//fence
          (it[i] == 33) -> pc[i] == {32'b0000_0000_0000_0000_0001_0000_0000_1111};//fencei
          
          (it[i] == 34) -> pc[i] == {32'b0000_0000_0000_0000_0000_0000_0111_0011};//ecall
          (it[i] == 35) -> pc[i] == {32'b0000_0000_0001_0000_0000_0000_0111_0011};//ebreak
          (it[i] == 36) -> pc[i] == {csr[i],rs1[i],3'b001,rd[i],7'b1110011};//csrrw
          (it[i] == 37) -> pc[i] == {csr[i],rs1[i],3'b010,rd[i],7'b1110011};//csrrs
          (it[i] == 38) -> pc[i] == {csr[i],rs1[i],3'b011,rd[i],7'b1110011};//csrrc
          (it[i] == 39) -> pc[i] == {csr[i],imm[i][4:0],3'b101,rd[i],7'b1110011};//csrrwi
          (it[i] == 40) -> pc[i] == {csr[i],imm[i][4:0],3'b110,rd[i],7'b1110011};//csrrsi
          (it[i] == 41) -> pc[i] == {csr[i],imm[i][4:0],3'b111,rd[i],7'b1110011};//csrrci
          //s type
          (it[i] == 42) -> pc[i] == {imm[i][11:5],rs2[i],rs1[i],3'b000,imm[i][4:0],7'b0100011};//sb
          (it[i] == 43) -> pc[i] == {imm[i][11:5],rs2[i],rs1[i],3'b001,imm[i][4:0],7'b0100011};//sh
          (it[i] == 44) -> pc[i] == {imm[i][11:5],rs2[i],rs1[i],3'b010,imm[i][4:0],7'b0100011};//sw
          //B
          (it[i] == 45) -> pc[i] == {imm[i][12],imm[i][10:5],rs2[i],rs1[i],3'b000,imm[i][4:1],imm[i][11],7'b1100011};//beq
          (it[i] == 46) -> pc[i] == {imm[i][12],imm[i][10:5],rs2[i],rs1[i],3'b001,imm[i][4:1],imm[i][11],7'b1100011};//bne
          (it[i] == 47) -> pc[i] == {imm[i][12],imm[i][10:5],rs2[i],rs1[i],3'b100,imm[i][4:1],imm[i][11],7'b1100011};//blt
          (it[i] == 48) -> pc[i] == {imm[i][12],imm[i][10:5],rs2[i],rs1[i],3'b101,imm[i][4:1],imm[i][11],7'b1100011};//bge
          (it[i] == 49) -> pc[i] == {imm[i][12],imm[i][10:5],rs2[i],rs1[i],3'b110,imm[i][4:1],imm[i][11],7'b1100011};//bltu
          (it[i] == 50) -> pc[i] == {imm[i][12],imm[i][10:5],rs2[i],rs1[i],3'b111,imm[i][4:1],imm[i][11],7'b1100011};//bgeu
          
          (it[i] == 51) -> pc[i] == {imm[i][31:12],rd[i],7'b0110111};//lui
          (it[i] == 52) -> pc[i] == {imm[i][31:12],rd[i],7'b0010111};//auipc
          (it[i] == 53) -> pc[i] == {imm[i][20],imm[i][10:1],imm[i][11],imm[i][19:12],rd[i],7'b1101111};//jal
          (it[i] == 54) -> pc[i] == {imm[i][11:0],rs1[i],3'b000,rd[i],7'b1100111};//jalr
          (it[i] == 55) -> pc[i] == {32'h00000001};//pop
          (it[i] == 56) -> pc[i] == {32'h30200073};//mret
          (it[i] == 57) -> pc[i] == {32'h00008067};//ret
    }
}

function new(int size,int w[]);
    this.pc = new[size];
    this.size_all = size;
    this.ww = w;
endfunction

endclass
