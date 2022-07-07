# FPGA-project
---
## Project_init: risc_cpu by 夏宇闻
### 设计部分
设计需求：操作符：HLT(暂停) SKZ(为零转移) ADD(直接寻址数+累加器) AND(直接寻指数&累加器) XOR(直接寻指数^累加器) LDA(读：直接寻址数->累加器) STO(写：累加器->直接寻址数) JMP(无条件跳转) 
modules: cpu.v
```
module cpu(
      input clk,reset,
      output halt,rd,wr,
      output [12:0] addr,
      inout [7:0] data);
      
      wire [2:0] opcode;
      wire [12:0] ir_addr,pc_addr;
      wire [7:0] alu_out,accum;
      wire zero,inc_pc,load_acc,load_pc,load_ir,data_ena,contr_ena;

clk_gen m_clk_gen(.clk(clk),.clk1(clk1),.fetch(fetch),.alu_clk(alu_clk),.reset(reset));
                      
register m_register(.data(data),.ena(load_ir),.rst(reset),.clk1(clk1),.opc_iraddr({opcode,ir_addr}));
                        
accum m_accum(.data(alu_out),.ena(load_acc),.clk1(clk1),.rst(reset),.accum(accum));
                  
alu m_alu(.data(data),.accum(accum),.alu_clk(alu_clk),.opcode(opcode),.alu_out(alu_out),.zero(zero));
              
machinectl m_machinectl(.ena(contr_ena),.fetch(fetch),.rst(reset));
                            
machine m_machine(.inc_pc(inc_pc),.load_acc(load_acc),.load_pc(load_pc),.rd(rd),.wr(wr),.load_ir(load_ir),.clk1(clk1),.datactl_ena(data_ena),.halt(halt),.zero(zero),.ena(contr_ena),.opcode(opcode));
                      
datactl m_datactl(.in(alu_out),.data_ena(data_ena),.data(data));
                      
adr m_adr(.fetch(fetch),.ir_addr(ir_addr),.pc_addr(pc_addr),.addr(addr));
              
counter m_counter(.ir_addr(ir_addr),.load(load_pc),.clock(inc_pc),.rst(reset),.pc_addr(pc_addr));
```
![image](https://user-images.githubusercontent.com/41823230/177723406-e3e15e1c-9ad9-4fa2-b6d7-e6655300a38a.png)

### 验证部分

