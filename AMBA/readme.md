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
---
  # AHB    
  ## 简要介绍
  AMBA AHB是一种适合高性能综合设计的总线接口。功能，包括:•burst传输•单时钟边缘操作•非三态实现•可配置的数据总线宽度•可配置的地址总线宽度。       
  可接入 主机 、从机、桥
  AHB lite  AHB5
  ## 信号描述
      全局信号：
            HCLK       时钟
            HRESETn    复位
      主机产生的信号：
            HADDR      地址线 位宽10~64bits 
            HBUEST     指示burst传输类型  位宽为0/3bits
            HMASTLOCK  
            HPROT      保护控制 0/4/7bits
            HSIZE      传输大小 3bits
            HNONSEC    提示是否为安全传输
            HEXCL      指示是否为访问序列
            HMASTER    主机标识，每个主机唯一，建议0~8bits
            HTRANS     2bits 指示传输类型：idle busy NONSEQUENTIAL SEQUENTIAL
            HWDATA     写数据总线 8/16/32/64/128/256/512/1024bits
            HWSTRB     写频闪
            HWRITE     传输方向设定，1：写，0：读
      从机产生的信号：
            HRDATA     发给多路复用器 读数据总线 8/6/32/64/128/256/512/1024 bits 
            HREADYOUT  to 多路 1：表示总线上传输完成 0： 延长传输
            HRESP      发给多路选择器提供关于传输状态的附加信息 0：ok  1：error
            HEXOKAY    发给多路选择器表示独占传输的成功或失败
      译码器产生的信号：
            HSELx      输出到不同从机，监视HREADY判断传输是否可行
      多路选择器输出信号：
            HRDATA     由译码器选择，发给主机
            HREADY     发给主机和从机
            HRESP      发给主机
            HEXOKAY    发给主机
  ## 传输
  ### 基本传输
  ![image](https://user-images.githubusercontent.com/41823230/186308789-6bb15cc1-4d4b-421d-9c90-ee59535ee814.png)
传输分为两个阶段：A:地址传输（一个周期）；B:数据传输（可能多个周期，由ready控制）        
Hwrite 区分读还是写  地址信号无需在数据阶段保持 所以可以流水线控制
  ### 传输类型
  HTRANS[1:0]控制传输类型：
          00: IDLE   表示不需要传输
          01：BUSY   使得主机能在burst中插入Idle，延迟一个周期传输，只有未定义长度的突发才能将BUSY传输作为突发的最后一个周期，
          10：NONSEQ 指示单次 或者burst的第一次传输
          11：SEQ    burst传输连续传输
  ### 锁定传输
  主机断言锁定总线，只读写一个地址      
  ![image](https://user-images.githubusercontent.com/41823230/186326779-8b233170-7870-45e3-9064-112386a51395.png)
  ### 传输大小
  HSIZE[2:0]   000: 8   001：16 .... 111: 1024
  ### 写闪频
  可选
  ### burst
HBURST[2:0]控制burst传输的类型 节拍数由hburst控制，传输大小由hsize控制
0b000   SINGLE   单传输
0b001   INCR     未定义长度的递增burst
0b010   WRAP4    4拍 wrap burst
0b011   INCR4    4拍 递增 burst
0b100   WRAP8    8-beat wrapping burst
0b101   INCR8    8-beat incrementing burst
0b110   WRAP16   16-beat wrapping burst
0b111   INCR16   16-beat incrementing burst       
![image](https://user-images.githubusercontent.com/41823230/186331505-037c7516-c73b-4638-b8da-0c8ddd2bf851.png)
![image](https://user-images.githubusercontent.com/41823230/186331577-c60685cb-8850-4c5d-b9e5-831d12a4d4d1.png)
![image](https://user-images.githubusercontent.com/41823230/186331629-5176ff80-e468-49d4-a54b-bccedc017040.png)
![image](https://user-images.githubusercontent.com/41823230/186331684-d6847ce8-7c07-4653-b66a-2648b7d08a3a.png)
![image](https://user-images.githubusercontent.com/41823230/186331731-c759c4ee-1494-450b-8af2-31b332ee2452.png)
![image](https://user-images.githubusercontent.com/41823230/186331858-88cd4704-9faf-4ed9-84ec-2c50ff1dab04.png)
![image](https://user-images.githubusercontent.com/41823230/186331886-5d85cf24-0487-4b51-9ce8-93ca8f43342a.png)
![image](https://user-images.githubusercontent.com/41823230/186331910-40ce8521-2f66-4c4a-ae61-e9161d5b18d4.png)
![image](https://user-images.githubusercontent.com/41823230/186331949-3a861ce5-9291-4f80-9c7a-72b400fabe4f.png)
![image](https://user-images.githubusercontent.com/41823230/186331973-09c6b32a-cbf9-49bb-93e2-f2071cee5dae.png)
  ## 总线互连
  ![image](https://user-images.githubusercontent.com/41823230/186332539-da53eebc-d2ad-4daf-bb84-f4453af06069.png)
  ![image](https://user-images.githubusercontent.com/41823230/186332512-4eb48a6d-ee9b-4ddb-bfe3-51f7eeb98be9.png)

  ## 从属响应
  ![image](https://user-images.githubusercontent.com/41823230/186332645-2868c069-6cf4-48e7-95e1-e9983aa70272.png)

  ## 数据总线
  HWDATA        
  HRDATA
  ## 时钟和复位
  
  ## 信号有效性
  必须一直有效：• HTRANS
• HADDR
• HSEL
• HMASTLOCK
• HREADY
• HREADYOUT
• HRESP
  ## 原子性
  # AXI 
