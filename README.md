# FPGA-project
---
## Project_init: risc_cpu by 夏宇闻
### 设计部分
设计需求：操作符： 

                  HLT(暂停+2)                     nop<br>
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
*  1. rd,ir_load置高：从rom读指令到指令寄存器ir 3'opcdoe 5'ir_addr
*  2. inc_pc和rd，load_ir置高，ir_addr送至pc ，并且继续读rom的八位指令数据（低八位）'8ir_addr  获得一条完整指令
*  3. 空操作 全置0
*  4. 判断是否HLT？要暂停，输出hlt标志halt，inc_pc pc+1 ： 不暂停，inc_pc pc+1
*  5. JMP: load_pc pc->ir_addr;   ADD ||AND || XOR || LDA: rd=1;   STO: data_ena=1,累加器输出;  other: 00;
*  6. ADD||AND||XOR||LDA: load_acc,rd=1, 与累加器输出的值计算;  SKZ&&zero=1: pc+1; JMP: inc_pc 上升沿 load_pc pc->ir_addr ; STO：wr datactl 将数据写入地址处;other: 00;
*  7. STO: datactl=1;  ADD||AND||XOR||LDA: rd=1; 空操作，持续读写数据
*  8. SKZ&&zero=1: inc_pc pc+1;
*/
machine m_machine(.inc_pc(inc_pc),.load_acc(load_acc),.load_pc(load_pc),.rd(rd),.wr(wr),.load_ir(load_ir),.clk1(clk1),.datactl_ena(data_ena),.halt(halt),.zero(zero),.ena(contr_ena),.opcode(opcode));

```
![image](https://user-images.githubusercontent.com/41823230/177723406-e3e15e1c-9ad9-4fa2-b6d7-e6655300a38a.png)

### 验证部分

