# AMBA Protocol Specification
  [AMBA APB Protocol Specification](https://developer.arm.com/documentation/ihi0024/latest/)      
  [AMBA AHB Protocol Specification](https://developer.arm.com/documentation/ihi0033/latest/)     
  [AMBA AXI and ACE Protocol Specification](https://developer.arm.com/documentation/ihi0022/latest)      
  [AMBA](https://developer.arm.com/Architectures/AMBA)      
  # APB  
  APB于1998年发行，后发行APB2，APB3（附加了Pready信号与Pslverr信号），APB4（Pprot Pstrb），APB5
  ## 简要介绍
  APB接口用于访问外围设备的可编程控制寄存器。一般通过使用APB桥接器连接到高速总线如AXI。
  特点：低成本。非流水线，是一个简单的同步协议。每次传输至少需要两个周期。      
  ## 信号描述
      PCLK      时钟  
      PRESETn   复位信号
      PADDR     地址总线 最多32bits
      PPROT     3bits 表示保护类型
      PSELx     片选
      PENABLE   使能
      PWRITE    1：写访问  0：读访问
      PWDATA    写周期数据总线 8/16/32bits
      PSTRB     写传输期间要更新的字节通道，每8位有一个写频闪，PSTRB[n]对应PWDATA[(8n + 7):(8n)]
      PREADY    由从机发出
      PRDATA    读数据总线 8/16/32bits
      PSLVERR   可被从机断言为high 提示错误
      PWAKEUP 
      PAUSER    用户请求属性 建议最大128bits
      PWUSER    用户写数据属性 建议最大DATA_WIDTH/2
      PRUSER    用户读取数据属性
      PBUSER    用户响应属性
      APB接口只有一个地址总线：PADDR
      APB协议有两个独立的数据总线，一个用于读数据，一个用于写数据。总线可以是8位、16位或32位宽。读写数据总线必须有相同的宽度。数据传输不能并发，因为读数据总线和写数据总线没有各自的握手信号。
  ## 传输
  ### 写传输
![RXEATAXX7%G42I)LAC9~9KF](https://user-images.githubusercontent.com/41823230/186177450-9e1f8764-e3d0-4e40-98ab-8e31c20fb5a8.png)         
T1:片选拉低 输入PADDR PWRITE PWDATA； T2：片选拉高 enable拉低后再拉高 等待ready开始写入 T3：写入       
![image](https://user-images.githubusercontent.com/41823230/186177398-fef238f4-1541-40a5-92f8-b31c9cc70c2e.png)           
一直等待ready拉高
  ### 写稀疏传输
  数据总线上的数据稀疏传输，数据每八位有一个写频点，PSTRB[n]对应于PWDATA[(8n + 7):(8n)]，读传输时，全为0
  ### 读传输
![image](https://user-images.githubusercontent.com/41823230/186182844-60583649-73d8-4b4f-962e-bff36617b434.png)        
传输时Pwrite拉低 表示读 使能先拉低后拉高等待从机ready接收数据
![image](https://user-images.githubusercontent.com/41823230/186182921-419b1cf0-4f02-4ae8-9e46-7993082ca92d.png)
  ### 错误响应
  PSLVERR只在APB传输的最后一个周期有效，即ready=1时
  #### 包含错误响应的写
  ![image](https://user-images.githubusercontent.com/41823230/186185030-8496e8fa-d4dd-4db6-b7ac-1d77e70b0389.png)
  #### 包含错误响应的读
  ![image](https://user-images.githubusercontent.com/41823230/186185164-a300f34d-5833-42cf-bc0f-4d5d03b2d35d.png)
  ### 保护
  防止非法传输的保护；主机使用prot[0]来指示处理模式，prot[1]用于需要对处理模式进行更大程度区分的系统，prot[2]指示事务是数据访问还是指令访问。
  ### 唤醒信号
  ## 工作状态
  ![image](https://user-images.githubusercontent.com/41823230/186187264-37f71fdf-b015-466c-8892-12f3b4d56c5c.png)
    IDLE   APB接口的默认状态
    SETUP  断言适当的选择信号PSELx 一个时钟周期内
    ACCESS Penable 拉高
  ## 接口优先级保护
  # AHB    
  # AXI 
