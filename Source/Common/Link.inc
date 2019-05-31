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

{$DEFINE RemObjects}

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
//特定系统       SWJY  SWTC  SWAS  SWYL  SWFX      CQJJ

//陕西声威集团 铜川工厂
{$IFDEF SWTC}
  {.$DEFINE OnleBF}
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE NCPurchase}
  {$DEFINE NCSale}
  {$DEFINE ProberMidChk} // 车检4通道光栅检查 (磅2端+磅中间)
  {$DEFINE BasisWeight}
  //启用定量装车
  {$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛重
  {$DEFINE PRINT3dHY}
  {$DEFINE DelNotInBill} // 调价删除未进厂单据 
  {.$DEFINE NCSale}	// NC销售开关
  {$DEFINE DelBillNeedReson}
  {$DEFINE ChkSaleCardInTimeOut}
  {$DEFINE MsgPoundVoice} //通知磅房虚拟读卡器
  {$DEFINE SXSW}
  //声威批次号  年月日 + 水泥批次号
  {$DEFINE RemoteSnap}
  //车牌识别  磅房

  {$DEFINE PoundRoundJZ}
  // 磅房随机净重  路政

  {$DEFINE SalePlanCheck}
  //销售计划限量检查
  {$DEFINE PurchaseOrderChkJingZhong}
  //原料开单必须录入原始净重（安塞）
  {$DEFINE PoundOpenBackGate}
  //过磅异常倒车下磅

  {.$DEFINE UseUTFDecode}
  //使用UTF解包函数
  {.$DEFINE ChkCardFHTime}  
  // 声威泾阳工厂  时间控制散装放灰 
  {.$DEFINE FixLoad}
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
  {.$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE USE_NC}
  //订单量使用订单金额-已发金额
  {.$DEFINE PrintHY}
  //出厂打印化验单
{$ENDIF}


//声威安塞工厂
{$IFDEF SWAS}
  {$DEFINE NCPurchase}
  {$DEFINE NCSale}	// NC销售开关
  {$DEFINE ChkPurTruc}
  {$DEFINE PoundMPrintOrder}
  //二次过磅后打印出厂小票
  {$DEFINE SalePlanCheck}
  //销售计划限量检查
  {$DEFINE DelBillNeedReson}
  {$DEFINE CheckTruckNo}
  //开单检查是否输入的车号有正在进行中的单子做2次提醒
  {$DEFINE ChkSaleCardInTimeOut}
  {$DEFINE MsgPoundVoice} //通知磅房虚拟读卡器
  {$DEFINE SXSW}
  //声威批次号  年月日 + 水泥批次号
  {.$DEFINE PoundOpenBackGate}
  //过磅异常倒车下磅
  {$DEFINE SendMorefactoryStock}
  //发多个分厂品种并对应打印分厂单据

  {$DEFINE PurchaseOrderChkJingZhong}
  //原料开单必须录入原始净重（安塞）

  {$DEFINE AICMPrintHGZ}
  //自助机开单打合格证
  {.$DEFINE UseUTFDecode}
  //使用UTF解包函数

  {.$DEFINE ChkCardFHTime}  
  // 声威泾阳工厂  时间控制散装放灰 
  {$DEFINE FixLoad}
  // 地磅控制散装放灰 	
  {$DEFINE ChkPopedomPrintHYD}
  // 检查随车打印化验单特权 

  {$DEFINE CreateBillByICCard}
  //销售单开单强制依据身份证（铜川、安塞）

  {$DEFINE CreateBillCreateHYEach}
  //销售单开单开化验单
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
  {$DEFINE HeGeZhengSimpleData}
  //使用简单合格证数据(无检验结果)
  {.$DEFINE PrintHuaYanDan}
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
  {.$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE USE_NC}
  //订单量使用订单金额-已发金额
  {.$DEFINE PrintHY}
  //出厂打印化验单
{$ENDIF}


//声威泾阳工厂
{$IFDEF SWJY}
  {$DEFINE NCPurchase}
  {$DEFINE NCSale}	// NC销售开关
  {$DEFINE DelBillNeedReson}
  {$DEFINE SXSW}
  //声威批次号  年月日 + 水泥批次号
  {$DEFINE PurchaseOrderChkJingZhong}
  //原料开单必须录入原始净重
  {$DEFINE SalePlanCheck}
  //销售计划限量检查
  {$DEFINE CheckTruckNo} //开单检查车号有正在进行中的单子做2次提醒
  {$DEFINE ChkSaleCardInTimeOut}  // 检查车辆进出时间
  {$DEFINE ChkCardFHTime}	//放灰时间检查
  {$DEFINE DuanDaoCanFH}     //短倒模式销售骨料 泾阳工厂	
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
  {.$DEFINE PrintHuaYanDan}
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
  {$DEFINE USE_NC}
  //订单量使用订单金额-已发金额
  {.$DEFINE PrintHY}
  //出厂打印化验单
{$ENDIF}


//声威榆林工厂
{$IFDEF SWYL}
  {$DEFINE NCPurchase}
  {$DEFINE NCSale}	// NC销售开关
  {$DEFINE SXSW}
  //声威批次号  年月日 + 水泥批次号
  {$DEFINE SendMorefactoryStock}
  //发多个分厂品种并对应打印分厂单据
  {$DEFINE SalePlanCheck}
  //销售计划限量检查
  {$DEFINE PurchaseOrderChkJingZhong}
  //原料开单必须录入原始净重（安塞）

  {.$DEFINE UseUTFDecode}
  //使用UTF解包函数

  {.$DEFINE ChkCardFHTime}  
  // 声威泾阳工厂  时间控制散装放灰 
  {$DEFINE FixLoad}
  // 地磅控制散装放灰 	
  {$DEFINE ChkPopedomPrintHYD}
  // 检查随车打印化验单特权 

  {$DEFINE CreateBillByICCard}
  //销售单开单强制依据身份证（铜川、安塞）
  {$DEFINE DelBillNeedReson}

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
  {.$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE USE_NC}
  //订单量使用订单金额-已发金额
  {.$DEFINE PrintHY}
  //出厂打印化验单
{$ENDIF}


//声威凤县工厂
{$IFDEF SWFX}
  {$DEFINE NCPurchase}
  {$DEFINE NCSale}	// NC销售开关
  {$DEFINE ChkZTMatch}
  //检查同组通道装车状态
  {.$DEFINE SetStdValue}
  //打印2张提货单 （一张真实数据、一张标准数据）
  {$DEFINE SXSW}
  //声威批次号  年月日 + 水泥批次号
  {$DEFINE SalePlanCheck}
  //销售计划限量检查
  {$DEFINE PurchaseOrderChkJingZhong}
  //原料开单必须录入原始净重（安塞）

  {.$DEFINE UseUTFDecode}
  //使用UTF解包函数

  {.$DEFINE ChkCardFHTime}  
  // 声威泾阳工厂  时间控制散装放灰 	
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


//重庆金九集团 工厂
{$IFDEF CQJJ}
  {.$DEFINE PRINT3dHY}
  {$DEFINE SXSW}
  //声威批次号  年月日 + 水泥批次号
  {.$DEFINE RemoteSnap}
  //车牌识别  磅房
  {.$DEFINE PoundRoundJZ}
  // 磅房随机净重  路政
  {$DEFINE ProberShow}
  //磅房净重发送小屏
  {$DEFINE HandleTunnel}
  //磅房显示抬杆按钮可点击
  {$DEFINE PoundTipsWeight}
  //语音提示皮、净重
  {$DEFINE ChangeBillWhenPriceAdjust}
  //纸卡调价时修改已提货单据价格

  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE SalePlanCheck}
  //销售计划限量检查
  {.$DEFINE PurchaseOrderChkJingZhong}
  //原料开单必须录入原始净重（安塞）
  {$DEFINE PoundOpenBackGate}
  //过磅异常倒车下磅

  {.$DEFINE UseUTFDecode}
  //使用UTF解包函数
  {$DEFINE DelBillNeedReson}

  {.$DEFINE ChkCardFHTime}  
  // 声威泾阳工厂  时间控制散装放灰 
  {.$DEFINE FixLoad}
  // 地磅控制散装放灰 	
  {$DEFINE ChkPopedomPrintHYD}
  // 检查随车打印化验单特权 

  {.$DEFINE CreateBillByICCard}
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
  {.$DEFINE PrintHeGeZheng}  
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
  {$DEFINE BFLED}
  //磅房小屏
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

