//----------------------------------- 通用 -------------------------------------
{.$DEFINE DEBUG}
//调试模式

{.$DEFINE TrialVersion}
//试用版本

{$DEFINE UseReport}
//报表支持

{.$DEFINE RandomID}
//使用随机编号

{$DEFINE cxLibrary42}
//Ver4.2编译环境

{.$DEFINE EnableBackupDB}
//备用数据库支持
{.$DEFINE EnableDoubleDB}
//双数据库支持

//---------------------------------- 中间件 ------------------------------------
{.$DEFINE ClientMon}
//进程守护客户端

{$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式

//通用中间件
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {.$DEFINE ChannelPool}
  //启用通道支持
  {.$DEFINE AutoChannel}
  //启用通道平衡
  {.$DEFINE SAP}
  //启用SAP支持
  {.$DEFINE ClientMon}
  //支持守护服务
{$ENDIF}

//--------------------------------- 特定系统 -----------------------------------
{.$DEFINE COMMON}
//通用版本

{$DEFINE SWAS}
//特定系统

//山西声威
{$IFDEF SWTC}


  {$DEFINE PoundOpenBackGate}
  //过磅异常倒车下磅

  {$DEFINE UseUTFDecode}
  //使用UTF解包函数

  {.$DEFINE ChkCardFHTime}  
  // 声威泾阳工厂  时间控制散装放灰 
  {$DEFINE FixLoad}
  // 地磅控制散装放灰 	
  {$DEFINE ChkPopedomPrintHYD}
  // 检查随车打印化验单特权 

  {$DEFINE CreateBillByICCard}
  //销售单开单强制依据身份证（铜川、安塞）

  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE TTCEM100}
  //自动收卡票箱
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHeGeZheng}  
  //出厂打印合格证
  {$DEFINE HeGeZhengSimpleData}
  //使用简单合格证数据(无检验结果)
  {.$DEFINE PrintHuaYanDan}
  //随车开单时打化验单
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {$DEFINE SanPreHK}
  //散装开单时预合卡
  {.$DEFINE AutoPoundInManual}
  //自动称重人工干预异常
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE NoShowPriceChange}
  //不显示价格调整提示
  {.$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
  {$DEFINE MicroMsg}
  //使用微信
  {$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {.$DEFINE PrintHY}
  //出厂打印化验单
{$ENDIF}


{$IFDEF SWAS}

  {.$DEFINE PoundOpenBackGate}
  //过磅异常倒车下磅

  {$DEFINE PurchaseOrderChkJingZhong}
  //原料开单必须录入原始净重（安塞）

  {$DEFINE AICMPrintHGZ}
  //自助机开单打合格证
  {$DEFINE UseUTFDecode}
  //使用UTF解包函数

  {.$DEFINE ChkCardFHTime}  
  // 声威泾阳工厂  时间控制散装放灰 
  {$DEFINE FixLoad}
  // 地磅控制散装放灰 	
  {$DEFINE ChkPopedomPrintHYD}
  // 检查随车打印化验单特权 

  {$DEFINE CreateBillByICCard}
  //销售单开单强制依据身份证（铜川、安塞）

  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE TTCEM100}
  //自动收卡票箱
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHeGeZheng}
  {$DEFINE HeGeZhengSimpleData}
  //使用简单合格证数据(无检验结果)
  {$DEFINE PrintHuaYanDan}
  //随车开单时打合格证、化验单
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {$DEFINE SanPreHK}
  //散装开单时预合卡
  {.$DEFINE AutoPoundInManual}
  //自动称重人工干预异常
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE NoShowPriceChange}
  //不显示价格调整提示
  {.$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
  {$DEFINE MicroMsg}
  //使用微信
  {$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {.$DEFINE PrintHY}
  //出厂打印化验单
{$ENDIF}


//新乡春江
{$IFDEF XXCJ}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE TTCEM100}
  //自动收卡票箱
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE PrintHYEach}
  //随车开化验单
  {.$DEFINE PrintHeGeZheng}
  {$DEFINE PrintHuaYanDan}
  //随车开单时打合格证、化验单
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {$DEFINE SanPreHK}
  //散装开单时预合卡
  {.$DEFINE AutoPoundInManual}
  //自动称重人工干预异常
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE NoShowPriceChange}
  //不显示价格调整提示
  {.$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
  {$DEFINE MicroMsg}
  //使用微信
  {$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE PrintHY}
  //出厂打印化验单`
{$ENDIF}

//郑州上街
{$IFDEF ZZSJ}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHeGeZheng}
  {$DEFINE PrintHuaYanDan}
  //随车开单时打合格证、化验单
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {$DEFINE SanPreHK}
  //散装开单时预合卡
  {.$DEFINE AutoPoundInManual}
  //自动称重人工干预异常
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE NoShowPriceChange}
  //不显示价格调整提示
  {$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
  {$DEFINE MicroMsg}
  //使用微信
  {$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE AutoProId}
  //自动生成供应商编号
  {$DEFINE PrintHY}
  //出厂打印化验单
  {$DEFINE BFLED}
  //磅房小屏
  {$DEFINE BDAUDIT}
  //补单审核
{$ENDIF}

//辽宁营口
{$IFDEF LNYK}
  {$DEFINE COMMON}
{$ENDIF}

//当阳骨料
{$IFDEF DYGL}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE PrintGLF}
  //打印过路费
  {$DEFINE TruckInNow}
  //开单立即进厂,需要采用厂内排队模式
  {$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
  {$DEFINE ChangeBillWhenPriceAdjust}
  //纸卡调价时修改已提货单据价格
{$ENDIF}

//如东海鑫
{$IFDEF RDHX}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //华益读头
{$ENDIF}

//新安中联
{$IFDEF XAZL}
  {$DEFINE UseERP_K3}
  //使用k3
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE VerifyK3Stock}
  //开单时验证品种
  {$DEFINE MicroMsg}
  //微信支持
  {$DEFINE BlueCard}
  //蓝卡抬杆
{$ENDIF}

//济源中联
{$IFDEF JYZL}
  {$DEFINE UseERP_K3}
  //使用k3
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE VerifyK3Stock}
  //开单时验证品种
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE PrintBillMoney}
  //打印时显金额
  {$DEFINE HR1847}
  //北京科瑞车检
{$ENDIF}

//云南红塔
{$IFDEF YNHT}
  {$DEFINE UseERP_K3}
  //使用k3
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE PrintBillMoney}
  //打印时显金额
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE UseK3SalePlan}
  //K3销售计划
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE NoShowPriceChange}
  //不显示价格调整提示
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {$DEFINE AutoPoundInManual}
  //自动称重人工干预异常
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHeGeZheng}
  {.$DEFINE PrintHuaYanDan}
  //随车开单时打合格证、化验单
  {$DEFINE HeGeZhengSimpleData}
  //使用简单合格证数据(无检验结果)
  {.$DEFINE UseUTFDecode}
  //使用UTF解包函数
  {$DEFINE MicroMsg}
  //使用微信
{$ENDIF}

