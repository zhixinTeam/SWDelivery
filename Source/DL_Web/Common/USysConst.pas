{*******************************************************************************
  作者: dmzn@ylsoft.com 2018-03-15
  描述: 项目通用常,变量定义单元
*******************************************************************************}
unit USysConst;

interface

uses
  SysUtils, Classes, Data.DB, uniPageControl;

const
  cSBar_Date            = 0;                         //日期面板索引
  cSBar_Time            = 1;                         //时间面板索引
  cSBar_User            = 2;                         //用户面板索引
  cRecMenuMax           = 5;                         //最近使用导航区最大条目数

  {*Command*}
  cCmd_RefreshData      = $0002;                     //刷新数据
  cCmd_ViewSysLog       = $0003;                     //系统日志

  cCmd_ModalResult      = $1001;                     //Modal窗体
  cCmd_FormClose        = $1002;                     //关闭窗口
  cCmd_AddData          = $1003;                     //添加数据
  cCmd_EditData         = $1005;                     //修改数据
  cCmd_ViewData         = $1006;                     //查看数据
  cCmd_GetData          = $1007;                     //选择数据

type
  TAdoConnectionType = (ctMain, ctWork);
  //连接类型

  PAdoConnectionData = ^TAdoConnectionData;
  TAdoConnectionData = record
    FConnUser : string;                              //用户设置连接字符串
    FConnStr  : string;                              //系统有效连接字符串
  end;
  //连接对象数据

  TFactoryItem = record
    FFactoryID  : string;                            //工厂编号
    FFactoryName: string;                            //工厂名称
    FMITServURL : string;                            //业务服务
    FHardMonURL : string;                            //硬件守护
    FWechatURL  : string;                            //微信服务
    FDBWorkOn   : string;                            //工作数据库
  end;

  TFactoryItems = array of TFactoryItem;
  //工厂列表

  PSysParam = ^TSysParam;
  TSysParam = record
    FProgID     : string;                            //程序标识
    FAppTitle   : string;                            //程序标题栏提示
    FMainTitle  : string;                            //主窗体标题
    FHintText   : string;                            //提示文本
    FCopyRight  : string;                            //主窗体提示内容

    FUserID     : string;                            //用户标识
    FUserName   : string;                            //当前用户
    FUserPwd    : string;                            //用户口令
    FGroupID    : string;                            //所在组
    FIsAdmin    : Boolean;                           //是否管理员

    FLocalIP    : string;                            //本机IP
    FLocalMAC   : string;                            //本机MAC
    FLocalName  : string;                            //本机名称
    FOSUser     : string;                            //操作系统
    FUserAgent  : string;                            //浏览器类型
    FFactory    : Integer;                           //所属工厂索引
  end;
  //系统参数

  TServerParam = record
    FPort       : Integer;                           //服务端口
    FExtJS      : string;                            //ext脚本目录
    FUniJS      : string;                            //uni脚本目录
    FDBMain     : string;                            //主数据库连接
  end;

  TModuleItemType = (mtFrame, mtForm);
  //模块类型

  PMenuModuleItem = ^TMenuModuleItem;
  TMenuModuleItem = record
    FMenuID: string;                                 //菜单名称
    FModule: string;                                 //模块类型
    FTabSheet: TUniTabSheet;                         //所在页面
    FItemType: TModuleItemType;                      //模块类型
  end;

  TMenuModuleItems = array of TMenuModuleItem;       //模块列表

  PFormCommandParam = ^TFormCommandParam;
  TFormCommandParam = record
    FCommand: integer;                               //命令
    FParamA: Variant;
    FParamB: Variant;
    FParamC: Variant;
    FParamD: Variant;
    FParamE: Variant;                                //参数A-E
  end;

  TFormModalResult = reference to  procedure(const nResult: Integer;
    const nParam: PFormCommandParam = nil);
  //模式窗体结果回调

  //----------------------------------------------------------------------------
  PMenuItemData = ^TMenuItemData;
  TMenuItemData = record
    FProgID: string;                                 //程序标识
    FEntity: string;                                 //实体标识
    FMenuID: string;                                 //菜单标识
    FPMenu: string;                                  //上级菜单
    FTitle: string;                                  //菜单标题
    FImgIndex: integer;                              //图标索引
    FFlag: string;                                   //附加参数(下划线..)
    FAction: string;                                 //菜单动作
    FFilter: string;                                 //过滤条件
    FNewOrder: Single;                               //创建序列
    FLangID: string;                                 //语言标识
  end;

  TMenuItems = array of TMenuItemData;
  //菜单列表

  TPopedomItemData = record
    FItem: string;                                   //对象
    FPopedom: string;                                //权限
  end;
  TPopedomItems = array of TPopedomItemData;

  TPopedomGroupItem = record
    FID: string;                                     //组标识
    FName: string;                                   //组名称
    FDesc: string;                                   //组描述
    FUser: TStrings;                                 //所属用户
    FPopedom: TPopedomItems;                         //权限列表
  end;

  TPopedomGroupItems = array of TPopedomGroupItem;
  //权限列表

  //----------------------------------------------------------------------------
  TDictFormatStyle = (fsNone, fsFixed, fsSQL, fsCheckBox);
  //格式化方式: 固定数据,数据库数据

  PDictFormatItem = ^TDictFormatItem;
  TDictFormatItem = record
    FStyle: TDictFormatStyle;                        //方式
    FData: string;                                   //数据
    FFormat: string;                                 //格式化
    FExtMemo: string;                                //扩展数据
  end;

  PDictDBItem = ^TDictDBItem;
  TDictDBItem = record
    FTable: string;                                  //表名
    FField: string;                                  //字段
    FIsKey: Boolean;                                 //主键

    FType: TFieldType;                               //数据类型
    FWidth: integer;                                 //字段宽度
    FDecimal: integer;                               //小数位
    FLocked : Boolean;
  end;

  TDictFooterKind = (fkNone, fkSum, fkMin, fkMax, fkCount, fkAverage);
  //统计类型: 无,合计,最小,最大,数目,平均值
  TDictFooterPosition = (fpNone, fpFooter, fpGroup, fpAll);
  //合计位置: 页脚,分组,两者都有

  PDictGroupFooter = ^TDictGroupFooter;
  TDictGroupFooter = record
    FDisplay: string;                               //显示文本
    FFormat: string;                                //格式化
    FKind: TDictFooterKind;                         //合计类型
    FPosition: TDictFooterPosition;                 //合计位置
  end;

  PDictItemData = ^TDictItemData;
  TDictItemData = record
    FItemID: integer;                               //标识
    FTitle: string;                                 //标题
    FAlign: TAlignment;                             //对齐
    FWidth: integer;                                //宽度
    FIndex: integer;                                //顺序
    FVisible: Boolean;                              //可见
    FLangID: string;                                //语言
    FDBItem: TDictDBItem;                           //数据库
    FFormat: TDictFormatItem;                       //格式化
    FFooter: TDictGroupFooter;                      //页脚合计
  end;
  TDictItems = array of TDictItemData;

  PEntityItemData = ^TEntityItemData;
  TEntityItemData = record
    FEntity: string;                                //实体标记
    FTitle: string;                                 //实体名称
    FDictItem: TDictItems;                          //字典数据,一组TDictItemData
  end;

  TEntityItems = array of TEntityItemData;
  //实体列表

  //----------------------------------------------------------------------------
  TStockItem = record
    FID: string;                                    //编号
    FName: string;                                  //名称
    FType: string;                                  //类型
    FSelected: Boolean;                             //被选中
  end;

  TStockItems = array of TStockItem;
  //物料列表

//------------------------------------------------------------------------------
var
  gPath: string;                                     //程序所在路径
  gSysParam:TSysParam;                               //程序环境参数
  gServerParam: TServerParam;                        //服务器参数

  gAllFactorys: TFactoryItems;                       //系统有效工厂列表
  gAllPopedoms: TPopedomGroupItems;                  //权限列表
  gAllEntitys: TEntityItems;                         //数据字典实体列表

  gAllUsers: TList;                                  //已登录用户列表
  gAllMenus: TMenuItems;                             //系统有效菜单
  gMenuModule: TList = nil;                          //菜单模块映射表

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'DMZN';                      //默认标识
  sAppTitle           = 'DMZN';                      //程序标题
  sMainCaption        = 'DMZN';                      //主窗口标题

  sHint               = '提示';                      //对话框标题
  sWarn               = '警告';                      //==
  sAsk                = '询问';                      //询问对话框
  sError              = '未知错误';                  //错误对话框

  sDate               = '日期:【%s】';               //任务栏日期
  sTime               = '时间:【%s】';               //任务栏时间
  sUser               = '用户:【%s】';               //任务栏用户

  sLogDir             = 'Logs\';                     //日志目录
  sLogExt             = '.log';                      //日志扩展名
  sLogField           = #9;                          //记录分隔符

  sImageDir           = 'Images\';                   //图片目录
  sReportDir          = 'Report\';                   //报表目录
  sBackupDir          = 'Backup\';                   //备份目录
  sBackupFile         = 'Bacup.idx';                 //备份索引
  sCameraDir          = 'Camera\';                   //抓拍目录

  sConfigFile         = 'Config.Ini';                //主配置文件
  sConfigSec          = 'Config';                    //主配置小节
  sVerifyCode         = ';Verify:';                  //校验码标记

  sFormConfig         = 'FormInfo.ini';              //窗体配置
  sSetupSec           = 'Setup';                     //配置小节
  sDBConfig           = 'DBConn.ini';                //数据连接
  sDBConfig_bk        = 'isbk';                      //备份库

  sExportExt          = '.txt';                      //导出默认扩展名
  sExportFilter       = '文本(*.txt)|*.txt|所有文件(*.*)|*.*';
                                                     //导出过滤条件 

  sInvalidConfig      = '配置文件无效或已经损坏';    //配置文件无效
  sCloseQuery         = '确定要退出程序吗?';         //主窗口退出

  sWebFlag           = 'web';                        //菜单标识
  sCheckFlag          = '√';                         ///选中标记
  sEvent_StrGridColumnResize = 'StrGridColResize';   //表格调整列表

implementation

//------------------------------------------------------------------------------
//Desc: 添加菜单模块映射项
procedure AddMenuModuleItem(const nMenu,nModule: string;
 const nType: TModuleItemType = mtFrame);
var nItem: PMenuModuleItem;
begin
  New(nItem);
  gMenuModule.Add(nItem);

  nItem.FMenuID := nMenu;
  nItem.FModule := nModule;
  nItem.FTabSheet := nil;
  nItem.FItemType := nType;
end;

//Desc: 菜单模块映射表
procedure InitMenuModuleList;
begin
  gMenuModule := TList.Create;

  AddMenuModuleItem('MAIN_A05', 'TfFormChangePwd', mtForm);
  AddMenuModuleItem('MAIN_A06', 'TfFormOptions', mtForm);
  AddMenuModuleItem('MAIN_A07', 'TfFramePopedom');
  AddMenuModuleItem('MAIN_SYSCLOSE', 'TfFormExit', mtForm);

  AddMenuModuleItem('MAIN_B01', '');
  AddMenuModuleItem('MAIN_B02', 'TfFrameCustomer');
  AddMenuModuleItem('MAIN_B03', 'TfFrameSalesMan');
  AddMenuModuleItem('MAIN_B04', 'TfFrameContract');
  AddMenuModuleItem('MAIN_B05', 'TfFramePriceRule');

  AddMenuModuleItem('MAIN_C02', 'TfFramePayment');
  AddMenuModuleItem('MAIN_C03', 'TfFrameCustomerCredit');
  AddMenuModuleItem('MAIN_CSH01', 'TfFrameCustomerCreditVarify');
  AddMenuModuleItem('MAIN_C06', 'TfFrameInvoiceWeek');
  AddMenuModuleItem('MAIN_C08', 'TfFrameInvoiceZZ');

  AddMenuModuleItem('MAIN_D01', 'TfFormZhiKa', mtForm);
  AddMenuModuleItem('MAIN_D05', 'TfFrameZhiKa');
  AddMenuModuleItem('MAIN_D06', 'TfFrameBill');

  AddMenuModuleItem('MAIN_K03', 'TfFrameHYData');

  AddMenuModuleItem('MAIN_L01', 'TfFrameTruckQuery');
  AddMenuModuleItem('MAIN_L02', 'TfFrameCusAccount');
  AddMenuModuleItem('MAIN_L03', 'TfFrameCusInOutMoney');
  AddMenuModuleItem('MAIN_L05', 'TfFrameQueryDiapatch');
  AddMenuModuleItem('MAIN_L06', 'TfFrameQuerySaleDetail');
  AddMenuModuleItem('MAIN_L07', 'TfFrameQuerySaleTotal');
  AddMenuModuleItem('MAIN_L08', 'TfFrameZhiKaDetail');
  AddMenuModuleItem('MAIN_L09', 'TfFrameInvoiceSettle');
  AddMenuModuleItem('MAIN_L10', 'TfFrameOrderDetail');
  AddMenuModuleItem('MAIN_L11', 'TfFrameQueryStockDays');
  AddMenuModuleItem('MAIN_L12', 'TfFrameCusReceivable');
  AddMenuModuleItem('MAIN_L13', 'TfFrameCusTotalMoney');
  AddMenuModuleItem('MAIN_L14', 'TfFrameQueryStockOddDays');
  AddMenuModuleItem('MAIN_L15', 'TfFrameCusReceivableTotal');
  AddMenuModuleItem('MAIN_L16', 'TfFrameQueryPurchaseStockOddDays');
  AddMenuModuleItem('MAIN_L17', 'TfFrameQueryPurchaseTotal');
end;

//Desc: 清理模块列表
procedure ClearMenuModuleList;
var nIdx: integer;
begin
  for nIdx:=gMenuModule.Count - 1 downto 0 do
  begin
    Dispose(PMenuModuleItem(gMenuModule[nIdx]));
    gMenuModule.Delete(nIdx);
  end;

  FreeAndNil(gMenuModule);
end;

initialization
  SetLength(gAllFactorys, 0);
  SetLength(gAllMenus, 0);
  SetLength(gAllPopedoms, 0);
  SetLength(gAllEntitys, 0);

  InitMenuModuleList;
  gAllUsers := TList.Create;
finalization
  FreeAndNil(gAllUsers);
  ClearMenuModuleList;
end.


