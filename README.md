# FPGA-project
    项目结构FPGA-project
                ├─RISC_CPU
                │  ├─design
                │  └─verification
                └─RISC_V_CPU
                    ├─design
                    └─verification
---
## Project_init: risc_cpu by 夏宇闻
### 设计部分
设计需求：操作符： 

                  HLT(暂停+2)                     nop
                  SKZ(为零转移+2/+4)    
                  ADD(直接寻址数+累加器+2)        （<operand>）+ Acc => Acc
                  AND(直接寻指数&累加器+2)        （<operand>）And Acc => Acc
                  XOR(直接寻指数^累加器+2)        （<operand>）Xor Acc => Acc
                  LDA(读：直接寻址数->累加器+2)   （<operand>）=> Acc
                  STO(写：累加器->直接寻址数+2)    Acc =>(<operand>)
                  JMP(无条件跳转)                  <operand> => PC
                  

modules: cpu.v
```
//head
module cpu(    input clk,reset,         output halt,rd,wr,  output [12:0] addr,       inout [7:0] data);
      wire [2:0] opcode;
      wire [12:0] ir_addr,pc_addr;
      wire [7:0] alu_out,accum;
      wire zero,inc_pc,load_acc,load_pc,load_ir,data_ena,contr_ena;
//时钟生成：输出三个周期：clk1：clk的反相；fetch：clk的八分频；alu_clk: 8周期内只有一次；指令周期为八个机器周期
clk_gen m_clk_gen(.clk(clk),.clk1(clk1),.fetch(fetch),.alu_clk(alu_clk),.reset(reset));

//指令寄存器ir：取指 读两次data  输出 3'opcdoe 12'ir_addr
register m_register(.data(data),.ena(load_ir),.rst(reset),.clk1(clk1),.opc_iraddr({opcode,ir_addr}));

//累加器：存放结果data存至 reg[7:0]accum
accum m_accum(.data(alu_out),.ena(load_acc),.clk1(clk1),.rst(reset),.accum(accum));

//算数运算逻辑单元：alu_clk控制:根据操作数进行运算; zero为标志位：accum如果是全0则1；LDA 输出data，其他仍为accum
alu m_alu(.data(data),.accum(accum),.alu_clk(alu_clk),.opcode(opcode),.alu_out(alu_out),.zero(zero));

//数据控制器：控制累加器输出状态：高阻/输出
datactl m_datactl(.in(alu_out),.data_ena(data_ena),.data(data));

//地址多路器：选择地址：指令周期：前四周期从rom中读(输出pc地址)；后四周期对ram写(输出指令中的地址)
adr m_adr(.fetch(fetch),.ir_addr(ir_addr),.pc_addr(pc_addr),.addr(addr));

//程序计数器：pc从13'b0开始读或load到ir_addr 上升沿有效
counter m_counter(.ir_addr(ir_addr),.load(load_pc),.clock(inc_pc),.rst(reset),.pc_addr(pc_addr));

//在fetch上升沿时刻，如果rst是高，那就enable为低，否则就正常工作
machinectl m_machinectl(.ena(contr_ena),.fetch(fetch),.rst(reset));

//输入opcode和标志位zero 输出各种  指令周期：
/**
*  1. rd=1,load_ir=1：从rom读指令到指令寄存器ir 3'opcdoe 5'ir_addr
*  2. inc_pc=1, rd=1，load_ir=1，pc+1，继续读rom的八位指令数据（低八位）'8ir_addr  获得一条完整指令
*  3. nop 00
*  4. HLT: 暂停，halt=1，inc_pc=1, pc+1; other: inc_pc=1, pc+1
*  5. JMP: load_pc=1 ;                      ADD||AND||XOR||LDA: rd=1;               STO: datactl=1;                                                 other: 00;
*  6. JMP: load_pc=1,inc_pc=1,pc->ir_addr;  ADD||AND||XOR||LDA: load_acc=1,rd=1;    STO：wr=1 datactl=1,->ram;   SKZ&&zero=1: inc_pc=1,pc+1;        other: 00;
*  7.                                       ADD||AND||XOR||LDA: rd=1;               STO: datactl=1; 
*  8.                                                                                                            SKZ&&zero=1: inc_pc=1,pc+1;
*/
machine m_machine(.inc_pc(inc_pc),.load_acc(load_acc),.load_pc(load_pc),.rd(rd),.wr(wr),.load_ir(load_ir),.clk1(clk1),.datactl_ena(data_ena),.halt(halt),.zero(zero),.ena(contr_ena),.opcode(opcode));

```
![image](https://user-images.githubusercontent.com/41823230/177723406-e3e15e1c-9ad9-4fa2-b6d7-e6655300a38a.png)
外设：addr_decode : 根据地址选通ram or rom； ram可读可写 rom仅读

### 验证部分


## Project_rv: tiny_risc_v_cpu by [liangkangnan](https://gitee.com/liangkangnan/tinyriscv)

### 设计部分
设计需求：三级流水线，即取指，译码，执行，支持RV32IM指令集等
```
          R: func-7      rs2-5 rs1-5 func-3  rd-5         opcode-7  寄存器
          I: imm-12            rs1-5 func-3  rd-5         opcode-7  短立即数
          S: imm-7       rs2-5 rs1-5 func-3  imm-5        opcode-7  内存
          B: imm-1 imm-6 rs2-5 rs1-5 func-3  imm-4 imm-1  opcode-7  条件跳转
          U: imm-20                          rd-5         opcode-7  高位立即数
          J: imm-1 imm-10 imm-1 imm-8        rd-5         opcode-7  无条件跳转
```

### 验证部分
