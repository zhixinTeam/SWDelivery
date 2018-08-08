{*******************************************************************************
  作者: dmzn@163.com 2018-03-15
  描述: 系统全局控制模块
*******************************************************************************}
unit ServerModule;

interface

uses
  Classes, SysUtils, Data.Win.ADODB, uniGUIServer, uniGUITypes, UManagerGroup,
  ULibFun;

type
  TUniServerModule = class(TUniGUIServerModule)
    procedure UniGUIServerModuleBeforeInit(Sender: TObject);
    procedure UniGUIServerModuleBeforeShutdown(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure FirstInit; override;
  public
    { Public declarations }
  end;

function UniServerModule: TUniServerModule;
//入口函数

implementation

{$R *.dfm}

uses
  UniGUIVars, USysFun, USysConst, USysBusiness, UDataReport;

function UniServerModule: TUniServerModule;
begin
  Result:=TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;

procedure TUniServerModule.UniGUIServerModuleBeforeInit(Sender: TObject);
begin
  InitSystemEnvironment;
  //初始化系统环境
  LoadSysParameter();
  //载入系统配置参数

  if not TApplicationHelper.IsValidConfigFile(gPath + sConfigFile,
    gSysParam.FProgID) then
  begin
    raise Exception.Create(sInvalidConfig);
    //配置文件被改动
  end;

  Title := gSysParam.FAppTitle;
  //程序标题
  Port := gServerParam.FPort;
  //服务端口

  with gServerParam do
  begin
    FExtJS := ReplaceGlobalPath(FExtJS);
    FUniJS := ReplaceGlobalPath(FUniJS);
    Logger.AddLog('TUniServerModule', FExtJS);

    if DirectoryExists(FExtJS) then
      ExtRoot := FExtJS;
    //xxxxx

    if DirectoryExists(FUniJS) then
      UniRoot := FUniJS;
    //xxxxx
  end;

  AutoCoInitialize := True;
  //自动初始化COM对象
  RegObjectPoolTypes;
  //注册对象池对象
  ReloadSystemMemory(False);
  //初始化缓存数据
end;

procedure TUniServerModule.UniGUIServerModuleBeforeShutdown(Sender: TObject);
begin
  gMG.FObjectPool.RegistMe(False);
  //关闭对象池
end;

initialization
  RegisterServerModuleClass(TUniServerModule);
end.
