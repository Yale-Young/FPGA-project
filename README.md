# FPGA-project
    项目结构FPGA-project
                ├─mcdf
                ├─RISC_CPU
                │  ├─design
                │  └─verification
                ├─RISC_V_CPU
                │  ├─design
                │  │  ├─core
                │  │  ├─debug
                │  │  ├─perips
                │  │  ├─soc
                │  │  └─utils
                │  └─verification
                └─SIFT_Sobel
                    ├─design
                    └─result
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
<div align="center"><img src="https://user-images.githubusercontent.com/41823230/177723406-e3e15e1c-9ad9-4fa2-b6d7-e6655300a38a.png"  width="50%"></img><br><div align="center">原理图(详看大图)</div></div>
<br>
外设：addr_decode : 根据地址选通ram or rom； ram可读可写 rom仅读

### 验证部分


## Project_rv: tiny_risc_v_cpu by [liangkangnan](https://gitee.com/liangkangnan/tinyriscv)

### 设计部分
设计需求：三级流水线，即取指，译码，执行，支持RV32IM指令集等  rv内容参见 [rv中文手册](http://riscvbook.com/chinese/RISC-V-Reader-Chinese-v2p1.pdf)
```
          32bits RV32I基础整数指令集(47条) 扩展硬件乘法器：(R) : mul mulh mulhsu mulhu div divu rem remu
          R: func-7      rs2-5 rs1-5 func-3  rd-5         opcode-7  寄存器-寄存器操作   add sub sll slt sltu xor srl sra or and 
          I: imm-12            rs1-5 func-3  rd-5         opcode-7  短立即数计算和访存load  lb lh lw lbu lhu addi slti sltiu xori ori andi fence fence.i ecall ebreak csrrw csrrs csrrc csrrwi cssrrsi csrrci
          S: imm-7       rs2-5 rs1-5 func-3  imm-5        opcode-7  访存store           sb sh sw 
          B: imm-1 imm-6 rs2-5 rs1-5 func-3  imm-4 imm-1  opcode-7  条件跳转            beq bne blt bge bltu bgeu
          U: imm-20                          rd-5         opcode-7  长立即数            lui auipc
          J: imm-1 imm-10 imm-1 imm-8        rd-5         opcode-7  无条件跳转          jal jalr
```
tinyriscv.v 结构分析

```
// tinyriscv处理器核顶层模块
module tinyriscv(
    input wire clk,
    input wire rst,
    output wire[`MemAddrBus] rib_ex_addr_o,    // 读、写外设的地址
    input wire[`MemBus] rib_ex_data_i,         // 从外设读取的数据
    output wire[`MemBus] rib_ex_data_o,        // 写入外设的数据
    output wire rib_ex_req_o,                  // 访问外设请求
    output wire rib_ex_we_o,                   // 写外设标志
    output wire[`MemAddrBus] rib_pc_addr_o,    // 取指地址
    input wire[`MemBus] rib_pc_data_i,         // 取到的指令内容
    input wire[`RegAddrBus] jtag_reg_addr_i,   // jtag模块读、写寄存器的地址
    input wire[`RegBus] jtag_reg_data_i,       // jtag模块写寄存器数据
    input wire jtag_reg_we_i,                  // jtag模块写寄存器标志
    output wire[`RegBus] jtag_reg_data_o,      // jtag模块读取到的寄存器数据
    input wire rib_hold_flag_i,                // 总线暂停标志
    input wire jtag_halt_flag_i,               // jtag暂停标志
    input wire jtag_reset_flag_i,              // jtag复位PC标志
    input wire[`INT_BUS] int_i                 // 中断信号
    );


    // pc寄存器: 重置->`CpuResetAddr | jump: pc-> jump_addr_i | hold: pc->pc | else : pc + 4 按字节取址
    pc_reg u_pc_reg(.clk(clk),.rst(rst),.jtag_reset_flag_i(jtag_reset_flag_i),.pc_o(pc_pc_o),.hold_flag_i(ctrl_hold_flag_o),.jump_flag_i(ctrl_jump_flag_o),.jump_addr_i(ctrl_jump_addr_o));

    // 控制模块: 发出跳转、暂停流水线信号 优先级：jump | exhold | clinthold 暂停流水线 -> ribhold暂停pc -> jtag 暂停流水线
    ctrl u_ctrl(.rst(rst),.jump_flag_i(ex_jump_flag_o),.jump_addr_i(ex_jump_addr_o),.hold_flag_ex_i(ex_hold_flag_o),.hold_flag_rib_i(rib_hold_flag_i),.hold_flag_o(ctrl_hold_flag_o),.hold_flag_clint_i(clint_hold_flag_o),.jump_flag_o(ctrl_jump_flag_o),.jump_addr_o(ctrl_jump_addr_o),.jtag_halt_flag_i(jtag_halt_flag_i));

    // 通用r1r2寄存器读写操作: 原子写r1,r2  并行读r1,r2 优先级 ex -> jtag 输出寄存器值
    regs u_regs(.clk(clk),.rst(rst),.we_i(ex_reg_we_o),.waddr_i(ex_reg_waddr_o),.wdata_i(ex_reg_wdata_o),.raddr1_i(id_reg1_raddr_o),.rdata1_o(regs_rdata1_o),.raddr2_i(id_reg2_raddr_o),.rdata2_o(regs_rdata2_o),.jtag_we_i(jtag_reg_we_i),.jtag_addr_i(jtag_reg_addr_i),.jtag_data_i(jtag_reg_data_i),.jtag_data_o(jtag_reg_data_o)
);

    // 状态控制寄存器：读写 优先级 ex -> clint 从ex和中断clint获得读写寄存器地址和数据 再输出全局中断等   
    状态寄存器包括：mtvec（保存发生异常时处理器需要跳转到的地址），mcause（指示发生异常的种类），mepc（指向发生异常的指令），mie（指出处理器目前能处理和必须忽略的中断），mstatus（保存全局中断使能，以及许多其他的状态），mscratch（暂时存放一个字大小的数据）;
    优先ex写入状态，然后clint，读为并行读；
    csr_reg u_csr_reg(.clk(clk),.rst(rst),.we_i(ex_csr_we_o),.raddr_i(id_csr_raddr_o),.waddr_i(ex_csr_waddr_o),.data_i(ex_csr_wdata_o),.data_o(csr_data_o),.global_int_en_o(csr_global_int_en_o),.clint_we_i(clint_we_o),.clint_raddr_i(clint_raddr_o),.clint_waddr_i(clint_waddr_o),.clint_data_i(clint_data_o),.clint_data_o(csr_clint_data_o),.clint_csr_mtvec(csr_clint_csr_mtvec),.clint_csr_mepc(csr_clint_csr_mepc),.clint_csr_mstatus(csr_clint_csr_mstatus));

    // 传递指令给译码器：包括指令地址和指令内容 外设中断信号
    if_id u_if_id(.clk(clk),.rst(rst),.inst_i(rib_pc_data_i),.inst_addr_i(pc_pc_o),.int_flag_i(int_i),.int_flag_o(if_int_flag_o),.hold_flag_i(ctrl_hold_flag_o),.inst_o(if_inst_o),.inst_addr_o(if_inst_addr_o)
);

    // 指令解码器：传入指令地址32和内容32 寄存器1&2&csr的数据 根据后七位判断指令类型 输出寄存器操作 除以下特殊指令,均 读写地址置零 写标志置零
    INST_TYPE_I   : 0010011  func3 ：[立即数&rs1加、比较、异或、与、移位]addi slti sltiu xori ori andi slli sri 获取操作数(符号位扩展) 设置读rs1和写rd: o
    INST_TYPE_R_M : 0110011  func7 ：R/M func3 : [rs1&rs2加、比较、异或、与、移位]add_sub sll slt sltu xor sr or and 获取操作数 设置读rs1&2和写rd: o / func3 : [rs1&2乘、高位乘、有无符号乘]mul mulhu mulh mulhsu 获取操作数 设置读rs1&2和写rd：[rs1&2除法、无符号除法、求余、无符号余]div divu rem remu 获取操作数 设置读rs1&2和写rd: o
    INST_TYPE_L   : 0000011  func3 : [字节、半字、字加载offset & rs1]lb lh lw lbu lhu 获取操作数(符号位扩展) 设置读rs1和写rd:o
    INST_TYPE_S   : 0100011  func3 : [存rs2字节、字、半字至内存地址rs1+offset]sb sw sh 获取操作数off rs1 设置读rs1&2:o
    INST_TYPE_B   : 1100011  func3 : [r1r2相等、不等、小于、大于时pc分支offset]beq bne blt bge bltu bgeu 获取操作数rs1&2 跳转操作数pcaddr-off 设置读rs1&2:o 
    INST_JAL      : 1101111  跳转并链接 rd off ；x[rd] = pc+4; pc += sext(offset) 暂存下条指令，并跳转offset  获取操作数pc 4 跳转操作数pc off 写rd 
    INST_JALR     : 1100111  跳转并寄存器链接 t =pc+4; pc=(x[rs1]+sext(offset))&~1; x[rd]=t 暂存下条指令，并跳转offset 获取操作数pc 4 跳转rs1 off 写rd
    INST_LUI      : 0110111  高位立即数加载 x[rd] = sext(immediate[31:12] << 12) 操作数 {inst_i[31:12], 12'b0} 写入rd
    INST_AUIPC    : 0010111  PC加立即数 x[rd] = pc + sext(immediate[31:12] << 12)  操作数 pc {inst_i[31:12], 12'b0} 写入rd
    INST_NOP_OP   : 0000001  空 同默认
    INST_FENCE    : 0001111  同步内存和 I/O  跳转操作数pc 4
    INST_CSR      : 1110011  func3 : [读后写、读后置位(CSRs[csr] | x[rs1])、读后清除控制状态寄存器]csrrw csrrs crsrc 设置读rs1 写rd csr可写: csrrwi csrrsi csrrci 写rd csr可写:o
    id u_id(.rst(rst),.inst_i(if_inst_o),.inst_addr_i(if_inst_addr_o),.reg1_rdata_i(regs_rdata1_o),.reg2_rdata_i(regs_rdata2_o),.ex_jump_flag_i(ex_jump_flag_o),.reg1_raddr_o(id_reg1_raddr_o),.reg2_raddr_o(id_reg2_raddr_o),.inst_o(id_inst_o),.inst_addr_o(id_inst_addr_o),.reg1_rdata_o(id_reg1_rdata_o),.reg2_rdata_o(id_reg2_rdata_o),.reg_we_o(id_reg_we_o),.reg_waddr_o(id_reg_waddr_o),.op1_o(id_op1_o),.op2_o(id_op2_o),.op1_jump_o(id_op1_jump_o),.op2_jump_o(id_op2_jump_o),.csr_rdata_i(csr_data_o),.csr_raddr_o(id_csr_raddr_o),.csr_we_o(id_csr_we_o),.csr_rdata_o(id_csr_rdata_o),.csr_waddr_o(id_csr_waddr_o));

    // 从译码器传参给执行器：pc和内容 通用、csr寄存器写标志、读写地址 四个操作数：计算和跳转 
    id_ex u_id_ex(.clk(clk),.rst(rst),.inst_i(id_inst_o),.inst_addr_i(id_inst_addr_o),.reg_we_i(id_reg_we_o),.reg_waddr_i(id_reg_waddr_o),.reg1_rdata_i(id_reg1_rdata_o),.reg2_rdata_i(id_reg2_rdata_o),.hold_flag_i(ctrl_hold_flag_o),.inst_o(ie_inst_o),.inst_addr_o(ie_inst_addr_o),.reg_we_o(ie_reg_we_o),.reg_waddr_o(ie_reg_waddr_o),.reg1_rdata_o(ie_reg1_rdata_o),.reg2_rdata_o(ie_reg2_rdata_o),.op1_i(id_op1_o),.op2_i(id_op2_o),.op1_jump_i(id_op1_jump_o),.op2_jump_i(id_op2_jump_o),.op1_o(ie_op1_o),.op2_o(ie_op2_o),.op1_jump_o(ie_op1_jump_o),.op2_jump_o(ie_op2_jump_o),.csr_we_i(id_csr_we_o),.csr_waddr_i(id_csr_waddr_o),.csr_rdata_i(id_csr_rdata_o),.csr_we_o(ie_csr_we_o),.csr_waddr_o(ie_csr_waddr_o),.csr_rdata_o(ie_csr_rdata_o));

    // 执行！根据指令 与内存 除法器 通用寄存器 csr寄存器 控制器交互
    1.指令分解 数据预处理 sr移位 操作数计算 乘法运算temp
    2.处理乘法:计算操作数  除法指令：控制start busy 等与除法器交互
    3.执行 
    ex u_ex(.rst(rst),.inst_i(ie_inst_o),.inst_addr_i(ie_inst_addr_o),.reg_we_i(ie_reg_we_o),.reg_waddr_i(ie_reg_waddr_o),.reg1_rdata_i(ie_reg1_rdata_o),.reg2_rdata_i(ie_reg2_rdata_o),.op1_i(ie_op1_o),.op2_i(ie_op2_o),.op1_jump_i(ie_op1_jump_o),.op2_jump_i(ie_op2_jump_o),.mem_rdata_i(rib_ex_data_i),.mem_wdata_o(ex_mem_wdata_o),.mem_raddr_o(ex_mem_raddr_o),.mem_waddr_o(ex_mem_waddr_o),.mem_we_o(ex_mem_we_o).mem_req_o(ex_mem_req_o),.reg_wdata_o(ex_reg_wdata_o),.reg_we_o(ex_reg_we_o),.reg_waddr_o(ex_reg_waddr_o),.hold_flag_o(ex_hold_flag_o),.jump_flag_o(ex_jump_flag_o),.jump_addr_o(ex_jump_addr_o),.int_assert_i(clint_int_assert_o),.int_addr_i(clint_int_addr_o),.div_ready_i(div_ready_o),.div_result_i(div_result_o),.div_busy_i(div_busy_o),.div_reg_waddr_i(div_reg_waddr_o),.div_start_o(ex_div_start_o),.div_dividend_o(ex_div_dividend_o),.div_divisor_o(ex_div_divisor_o),.div_op_o(ex_div_op_o),.div_reg_waddr_o(ex_div_reg_waddr_o),.csr_we_i(ie_csr_we_o),.csr_waddr_i(ie_csr_waddr_o),.csr_rdata_i(ie_csr_rdata_o),.csr_wdata_o(ex_csr_wdata_o),.csr_we_o(ex_csr_we_o),.csr_waddr_o(ex_csr_waddr_o));

    // 除法器 试商法实现32位整数除法 每次除法运算至少需要33个时钟周期才能完成 输入start 输出busy/ready 四个状态 idle start calc end
    div u_div(.clk(clk),.rst(rst),.dividend_i(ex_div_dividend_o),.divisor_i(ex_div_divisor_o),.start_i(ex_div_start_o),.op_i(ex_div_op_o),.reg_waddr_i(ex_div_reg_waddr_o),.result_o(div_result_o),.ready_o(div_ready_o),.busy_o(div_busy_o),.reg_waddr_o(div_reg_waddr_o));

    // clint 核心中断控制 输入 : 中断输入信号 指令 跳转 除法器开始信号 流水线暂停信号  状态寄存器状态 全局中断  输出：中断标志和入口地址 流水线暂停标志 读写状态寄存器
    双状态机  中断状态 Idle  SYNC_ASSERT同步中断 ASYNC_ASSERT异步中断  MRET  寄存器写状态： 将mepc寄存器的值设为当前指令地址，写中断产生的原因，关闭全局中断，中断返回
    执行阶段的指令为除法指令，则先不处理同步中断，等除法指令执行完再处理
    clint u_clint(.clk(clk),.rst(rst),.int_flag_i(if_int_flag_o),.inst_i(id_inst_o),.inst_addr_i(id_inst_addr_o),.jump_flag_i(ex_jump_flag_o),.jump_addr_i(ex_jump_addr_o),.hold_flag_i(ctrl_hold_flag_o),.div_started_i(ex_div_start_o),.data_i(csr_clint_data_o),.csr_mtvec(csr_clint_csr_mtvec),.csr_mepc(csr_clint_csr_mepc),.csr_mstatus(csr_clint_csr_mstatus),.we_o(clint_we_o),.waddr_o(clint_waddr_o),.raddr_o(clint_raddr_o),.data_o(clint_data_o),.hold_flag_o(clint_hold_flag_o),.global_int_en_i(csr_global_int_en_o),.int_addr_o(clint_int_addr_o),.int_assert_o(clint_int_assert_o));

```


---
tinyriscv_soc_top.v 结构分析
```
// tinyriscv soc顶层模块 - 内核连接外设
    // tinyriscv处理器核模块例化
    tinyriscv u_tinyriscv(.clk(clk),.rst(rst),.rib_ex_addr_o(m0_addr_i),.rib_ex_data_i(m0_data_o),.rib_ex_data_o(m0_data_i),.rib_ex_req_o(m0_req_i),.rib_ex_we_o(m0_we_i),.rib_pc_addr_o(m1_addr_i),.rib_pc_data_i(m1_data_o),.jtag_reg_addr_i(jtag_reg_addr_o),.jtag_reg_data_i(jtag_reg_data_o),.jtag_reg_we_i(jtag_reg_we_o),.jtag_reg_data_o(jtag_reg_data_i),.rib_hold_flag_i(rib_hold_flag_o),.jtag_halt_flag_i(jtag_halt_req_o),.jtag_reset_flag_i(jtag_reset_req_o),.int_i(int_flag));

    // rom模块例化
    rom u_rom(.clk(clk),.rst(rst),.we_i(s0_we_o),.addr_i(s0_addr_o),.data_i(s0_data_o),.data_o(s0_data_i));
    // ram模块例化
    ram u_ram(.clk(clk),.rst(rst),.we_i(s1_we_o),.addr_i(s1_addr_o),.data_i(s1_data_o),.data_o(s1_data_i));
    // timer模块例化
    timer timer_0(.clk(clk),.rst(rst),.data_i(s2_data_o),.addr_i(s2_addr_o),.we_i(s2_we_o),.data_o(s2_data_i),.int_sig_o(timer0_int));
    // uart模块例化
    uart uart_0(.clk(clk),.rst(rst),.we_i(s3_we_o),.addr_i(s3_addr_o),.data_i(s3_data_o),.data_o(s3_data_i),.tx_pin(uart_tx_pin),.rx_pin(uart_rx_pin));
    // io0
    assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;
    assign io_in[0] = gpio[0];
    // io1
    assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;
    assign io_in[1] = gpio[1];
    // gpio模块例化
    gpio gpio_0(.clk(clk),.rst(rst),.we_i(s4_we_o),.addr_i(s4_addr_o),.data_i(s4_data_o),.data_o(s4_data_i),.io_pin_i(io_in),.reg_ctrl(gpio_ctrl),.reg_data(gpio_data)
    );
    // spi模块例化
    spi spi_0(.clk(clk),.rst(rst),.data_i(s5_data_o),.addr_i(s5_addr_o),.we_i(s5_we_o),.data_o(s5_data_i),.spi_mosi(spi_mosi),.spi_miso(spi_miso),.spi_ss(spi_ss),.spi_clk(spi_clk));

    // RISC-V Internal Bus 使用case根据优先级连接输入输出端口
    rib u_rib(.clk(clk),.rst(rst),

        // master 0 interface
        .m0_addr_i(m0_addr_i),.m0_data_i(m0_data_i),.m0_data_o(m0_data_o),.m0_req_i(m0_req_i),.m0_we_i(m0_we_i),
        // master 1 interface
        .m1_addr_i(m1_addr_i),.m1_data_i(`ZeroWord),.m1_data_o(m1_data_o),.m1_req_i(`RIB_REQ),.m1_we_i(`WriteDisable),
        // master 2 interface
        .m2_addr_i(m2_addr_i),.m2_data_i(m2_data_i),.m2_data_o(m2_data_o),.m2_req_i(m2_req_i),.m2_we_i(m2_we_i),
        // master 3 interface
        .m3_addr_i(m3_addr_i),.m3_data_i(m3_data_i),.m3_data_o(m3_data_o),.m3_req_i(m3_req_i),.m3_we_i(m3_we_i),
        // slave 0 interface
        .s0_addr_o(s0_addr_o),.s0_data_o(s0_data_o),.s0_data_i(s0_data_i),.s0_we_o(s0_we_o),
        // slave 1 interface
        .s1_addr_o(s1_addr_o),.s1_data_o(s1_data_o),.s1_data_i(s1_data_i),.s1_we_o(s1_we_o),
        // slave 2 interface
        .s2_addr_o(s2_addr_o),.s2_data_o(s2_data_o),.s2_data_i(s2_data_i),.s2_we_o(s2_we_o),
        // slave 3 interface
        .s3_addr_o(s3_addr_o),.s3_data_o(s3_data_o),.s3_data_i(s3_data_i),.s3_we_o(s3_we_o),
        // slave 4 interface
        .s4_addr_o(s4_addr_o),.s4_data_o(s4_data_o),.s4_data_i(s4_data_i),.s4_we_o(s4_we_o),
        // slave 5 interface
        .s5_addr_o(s5_addr_o),.s5_data_o(s5_data_o),.s5_data_i(s5_data_i),.s5_we_o(s5_we_o),
        .hold_flag_o(rib_hold_flag_o));
    // 串口下载模块例化
    uart_debug u_uart_debug(.clk(clk),.rst(rst),.debug_en_i(uart_debug_pin),.req_o(m3_req_i),.mem_we_o(m3_we_i),.mem_addr_o(m3_addr_i),.mem_wdata_o(m3_data_i),.mem_rdata_i(m3_data_o));

    // jtag模块例化
    jtag_top #(.DMI_ADDR_BITS(6),.DMI_DATA_BITS(32),.DMI_OP_BITS(2)) u_jtag_top(.clk(clk),.jtag_rst_n(rst),.jtag_pin_TCK(jtag_TCK),.jtag_pin_TMS(jtag_TMS),.jtag_pin_TDI(jtag_TDI),.jtag_pin_TDO(jtag_TDO),.reg_we_o(jtag_reg_we_o),.reg_addr_o(jtag_reg_addr_o),.reg_wdata_o(jtag_reg_data_o),.reg_rdata_i(jtag_reg_data_i),.mem_we_o(m2_we_i),.mem_addr_o(m2_addr_i),.mem_wdata_o(m2_data_i),.mem_rdata_i(m2_data_o),.op_req_o(m2_req_i),.halt_req_o(jtag_halt_req_o),.reset_req_o(jtag_reset_req_o));







```







### 验证部分
#### core部分
##### pc寄存器 
测试1500条指令，验证了暂停，跳转，和pc+4的功能   
编译指令：make comp  仿真： ./simv -gui 查看覆盖率：make cov    
代码覆盖率：![image](https://user-images.githubusercontent.com/41823230/181457407-6f0ba203-851e-48e1-b192-470741600fcd.png)
条件覆盖率为2/3是一条|语句未完全判断   
功能覆盖率：![image](https://user-images.githubusercontent.com/41823230/181457512-4f16c88f-fdc1-4e64-82c8-293ece9af197.png)
rst，jump，hold，inst addr 均为100%；   
##### regs 通用寄存器
测试了优先级判断，寄存器读写（含零寄存器5'b0），jtag的寄存器读写操作     
结果比较方法：`result = (get_actual.jdata===tmp_tran.jdata)&&(get_actual.data===tmp_tran.data);//包含不定态，要用===`    
测试结果： ` Compare SUCCESSFULLY` ![@`J7BRQXJ5 PO)A_P%@LR3R](https://user-images.githubusercontent.com/41823230/181702991-d1764697-4da9-485b-8bf3-c4d998941783.png)
代码覆盖率：![image](https://user-images.githubusercontent.com/41823230/181703091-bf25ec7c-761f-4cbc-8db5-5bb461f02319.png)
功能覆盖率：![image](https://user-images.githubusercontent.com/41823230/181703168-842f4638-f1fc-4f5c-b875-53e824166ee4.png)
##### tiny_cpu
只测试指令执行和pc跳转功能 有两种思路：    
1.在transaction中直接生成随机指令      
会生成大量非法指令，很难达到覆盖率要求，例如使用15000条随机指令，代码覆盖率仅有60%，状态机覆盖率更是只有35%，所以有必要开发一个随机指令合法生成平台    
![image](https://user-images.githubusercontent.com/41823230/183327205-f30a2a0d-5ee2-4a75-a484-a86c5466f040.png)

2.搭建随机指令生成平台

#### bus部分
##### rib总线

##### ram
##### rom
##### spi
##### gpio
##### timer
##### uart













