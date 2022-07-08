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
<div align="center"><img src="https://user-images.githubusercontent.com/41823230/177723406-e3e15e1c-9ad9-4fa2-b6d7-e6655300a38a.png"  width="50%"></img><br><div align="center">原理图(详看大图)</div></div>
<br>
外设：addr_decode : 根据地址选通ram or rom； ram可读可写 rom仅读

### 验证部分


## Project_rv: tiny_risc_v_cpu by [liangkangnan](https://gitee.com/liangkangnan/tinyriscv)

### 设计部分
设计需求：三级流水线，即取指，译码，执行，支持RV32IM指令集等  参见 [rv手册](http://riscvbook.com/chinese/RISC-V-Reader-Chinese-v2p1.pdf)
```
          32bits RV32I基础整数指令集(47条) 扩展硬件乘法器：(R) : mul mulh mulhsu mulhu div divu rem remu
          R: func-7      rs2-5 rs1-5 func-3  rd-5         opcode-7  寄存器-寄存器操作   add sub sll slt sltu xor srl sra or and 
          I: imm-12            rs1-5 func-3  rd-5         opcode-7  短立即数和访存load  lb lh lw lbu lhu addi slti sltiu xori ori andi fence fence.i ecall ebreak csrrw csrrs csrrc csrrwi cssrrsi csrrci
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


    // pc寄存器: 重置->`CpuResetAddr | jump: pc-> jump_addr_i | hold: pc->pc | else : pc + 4
    pc_reg u_pc_reg(.clk(clk),.rst(rst),.jtag_reset_flag_i(jtag_reset_flag_i),.pc_o(pc_pc_o),.hold_flag_i(ctrl_hold_flag_o),.jump_flag_i(ctrl_jump_flag_o),.jump_addr_i(ctrl_jump_addr_o));

    // 控制模块: 发出跳转、暂停流水线信号 优先级：jump | exhold | clinthold 暂停流水线 -> ribhold暂停pc -> jtag 暂停流水线
    ctrl u_ctrl(.rst(rst),.jump_flag_i(ex_jump_flag_o),.jump_addr_i(ex_jump_addr_o),.hold_flag_ex_i(ex_hold_flag_o),.hold_flag_rib_i(rib_hold_flag_i),.hold_flag_o(ctrl_hold_flag_o),.hold_flag_clint_i(clint_hold_flag_o),.jump_flag_o(ctrl_jump_flag_o),.jump_addr_o(ctrl_jump_addr_o),.jtag_halt_flag_i(jtag_halt_flag_i));

    // 寄存器操作: 原子写r1,r2  并行读r1,r2
    regs u_regs(.clk(clk),.rst(rst),.we_i(ex_reg_we_o),.waddr_i(ex_reg_waddr_o),.wdata_i(ex_reg_wdata_o),.raddr1_i(id_reg1_raddr_o),.rdata1_o(regs_rdata1_o),.raddr2_i(id_reg2_raddr_o),.rdata2_o(regs_rdata2_o),.jtag_we_i(jtag_reg_we_i),.jtag_addr_i(jtag_reg_addr_i),.jtag_data_i(jtag_reg_data_i),.jtag_data_o(jtag_reg_data_o)
);

    // csr_reg模块例化
    csr_reg u_csr_reg(.clk(clk),.rst(rst),.we_i(ex_csr_we_o),.raddr_i(id_csr_raddr_o),.waddr_i(ex_csr_waddr_o),.data_i(ex_csr_wdata_o),.data_o(csr_data_o),.global_int_en_o(csr_global_int_en_o),.clint_we_i(clint_we_o),.clint_raddr_i(clint_raddr_o),.clint_waddr_i(clint_waddr_o),.clint_data_i(clint_data_o),.clint_data_o(csr_clint_data_o),.clint_csr_mtvec(csr_clint_csr_mtvec),.clint_csr_mepc(csr_clint_csr_mepc),.clint_csr_mstatus(csr_clint_csr_mstatus));

    // if_id模块例化
    if_id u_if_id(.clk(clk),.rst(rst),.inst_i(rib_pc_data_i),.inst_addr_i(pc_pc_o),.int_flag_i(int_i),.int_flag_o(if_int_flag_o),.hold_flag_i(ctrl_hold_flag_o),.inst_o(if_inst_o),.inst_addr_o(if_inst_addr_o)
);

    // 指令解码器
    id u_id(.rst(rst),.inst_i(if_inst_o),.inst_addr_i(if_inst_addr_o),.reg1_rdata_i(regs_rdata1_o),.reg2_rdata_i(regs_rdata2_o),.ex_jump_flag_i(ex_jump_flag_o),.reg1_raddr_o(id_reg1_raddr_o),.reg2_raddr_o(id_reg2_raddr_o),.inst_o(id_inst_o),.inst_addr_o(id_inst_addr_o),.reg1_rdata_o(id_reg1_rdata_o),.reg2_rdata_o(id_reg2_rdata_o),.reg_we_o(id_reg_we_o),.reg_waddr_o(id_reg_waddr_o),.op1_o(id_op1_o),.op2_o(id_op2_o),.op1_jump_o(id_op1_jump_o),.op2_jump_o(id_op2_jump_o),.csr_rdata_i(csr_data_o),.csr_raddr_o(id_csr_raddr_o),.csr_we_o(id_csr_we_o),.csr_rdata_o(id_csr_rdata_o),.csr_waddr_o(id_csr_waddr_o));

    // id_ex模块例化
    id_ex u_id_ex(.clk(clk),.rst(rst),.inst_i(id_inst_o),.inst_addr_i(id_inst_addr_o),.reg_we_i(id_reg_we_o),.reg_waddr_i(id_reg_waddr_o),.reg1_rdata_i(id_reg1_rdata_o),.reg2_rdata_i(id_reg2_rdata_o),.hold_flag_i(ctrl_hold_flag_o),.inst_o(ie_inst_o),.inst_addr_o(ie_inst_addr_o),.reg_we_o(ie_reg_we_o),.reg_waddr_o(ie_reg_waddr_o),.reg1_rdata_o(ie_reg1_rdata_o),.reg2_rdata_o(ie_reg2_rdata_o),.op1_i(id_op1_o),.op2_i(id_op2_o),.op1_jump_i(id_op1_jump_o),.op2_jump_i(id_op2_jump_o),.op1_o(ie_op1_o),.op2_o(ie_op2_o),.op1_jump_o(ie_op1_jump_o),.op2_jump_o(ie_op2_jump_o),.csr_we_i(id_csr_we_o),.csr_waddr_i(id_csr_waddr_o),.csr_rdata_i(id_csr_rdata_o),.csr_we_o(ie_csr_we_o),.csr_waddr_o(ie_csr_waddr_o),.csr_rdata_o(ie_csr_rdata_o));

    // ex模块例化
    ex u_ex(.rst(rst),.inst_i(ie_inst_o),.inst_addr_i(ie_inst_addr_o),.reg_we_i(ie_reg_we_o),.reg_waddr_i(ie_reg_waddr_o),.reg1_rdata_i(ie_reg1_rdata_o),.reg2_rdata_i(ie_reg2_rdata_o),.op1_i(ie_op1_o),.op2_i(ie_op2_o),.op1_jump_i(ie_op1_jump_o),.op2_jump_i(ie_op2_jump_o),.mem_rdata_i(rib_ex_data_i),.mem_wdata_o(ex_mem_wdata_o),.mem_raddr_o(ex_mem_raddr_o),.mem_waddr_o(ex_mem_waddr_o),.mem_we_o(ex_mem_we_o).mem_req_o(ex_mem_req_o),.reg_wdata_o(ex_reg_wdata_o),.reg_we_o(ex_reg_we_o),.reg_waddr_o(ex_reg_waddr_o),.hold_flag_o(ex_hold_flag_o),.jump_flag_o(ex_jump_flag_o),.jump_addr_o(ex_jump_addr_o),.int_assert_i(clint_int_assert_o),.int_addr_i(clint_int_addr_o),.div_ready_i(div_ready_o),.div_result_i(div_result_o),.div_busy_i(div_busy_o),.div_reg_waddr_i(div_reg_waddr_o),.div_start_o(ex_div_start_o),.div_dividend_o(ex_div_dividend_o),.div_divisor_o(ex_div_divisor_o),.div_op_o(ex_div_op_o),.div_reg_waddr_o(ex_div_reg_waddr_o),.csr_we_i(ie_csr_we_o),.csr_waddr_i(ie_csr_waddr_o),.csr_rdata_i(ie_csr_rdata_o),.csr_wdata_o(ex_csr_wdata_o),.csr_we_o(ex_csr_we_o),.csr_waddr_o(ex_csr_waddr_o));

    // div模块例化
    div u_div(.clk(clk),.rst(rst),.dividend_i(ex_div_dividend_o),.divisor_i(ex_div_divisor_o),.start_i(ex_div_start_o),.op_i(ex_div_op_o),.reg_waddr_i(ex_div_reg_waddr_o),.result_o(div_result_o),.ready_o(div_ready_o),.busy_o(div_busy_o),.reg_waddr_o(div_reg_waddr_o));

    // clint模块例化
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

    // RISC-V Internal Bus
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














