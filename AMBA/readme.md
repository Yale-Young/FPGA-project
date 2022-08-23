# AMBA Protocol Specification
  [AMBA APB Protocol Specification](https://developer.arm.com/documentation/ihi0024/latest/)      
  [AMBA AHB Protocol Specification](https://developer.arm.com/documentation/ihi0033/latest/)     
  [AMBA AXI and ACE Protocol Specification](https://developer.arm.com/documentation/ihi0022/latest)      
  [AMBA](https://developer.arm.com/Architectures/AMBA)      
  # APB  
  APB于1998年发行，后发行APB2，APB3（附加了Pready信号与Pslverr信号），APB4（Pprot Pstrb），APB5
  ## 简要介绍
  低成本。非流水线，是一个简单的同步协议。每次传输至少需要两个周期才能完成。       
  APB接口用于访问外围设备的可编程控制寄存器。
  APB外设通常使用APB桥接器连接到主存系统。例如，从AXI到APB的桥接可以用来将许多APB外设连接到一个AXI内存系统。
  APB传输由APB桥接发起。APB桥也可以被称为请求者。外围设备接口响应请求。APB外设也可以被称为Completer。该规范将使用请求程序和完成程序。
  ## 信号描述
  ## 传输
  ## 工作状态
  ## 接口优先级保护
  # AHB    
  # AXI 
