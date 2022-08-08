//`timescale 1ns/1ps


`include "tinyriscv_soc_top.v"

module top_tb;

reg clk;
reg rst,
    over,succ,
    halted_ind,
    uart_debug_pin,uart_tx_pin,uart_rx_pin,
    jtag_TCK,jtag_TMS,jtag_TDI,jtag_TDO,
    spi_miso,spi_mosi,spi_ss,spi_clk;
logic [1:0] gpio;

    
tinyriscv_soc_top dut(
             .clk(clk),
             .rst(rst),
             .over(over),         // 测试是否完成信号
             .succ(succ),         // 测试是否成功信号
             .halted_ind(halted_ind),  // jtag是否已经halt住CPU信号
             .uart_debug_pin(uart_debug_pin), // 串口下载使能引脚
             .uart_tx_pin(uart_tx_pin), // UART发送引脚
             .uart_rx_pin(uart_rx_pin),  // UART接收引脚
             .gpio(gpio),    // GPIO引脚
             .jtag_TCK(jtag_TCK),     // JTAG TCK引脚
             .jtag_TMS(jtag_TMS),     // JTAG TMS引脚
             .jtag_TDI(jtag_TDI),     // JTAG TDI引脚
             .jtag_TDO(jtag_TDO),    // JTAG TDO引脚
             .spi_miso(spi_miso),     // SPI MISO引脚
             .spi_mosi(spi_mosi),    // SPI MOSI引脚
             .spi_ss(spi_ss),      // SPI SS引脚
             .spi_clk(spi_clk)      // SPI CLK引脚
    );

initial begin
   clk = 0;
   forever begin
      #10 clk = ~clk;
   end
end

initial begin
   rst = 1'b1;
   #10 rst = 1'b0;
   $finish;
end

initial begin
   
end


endmodule
