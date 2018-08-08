{*******************************************************************************
  ����: dmzn@163.com 2018-03-15
  ����: ϵͳȫ�ֿ���ģ��
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
//��ں���

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
  //��ʼ��ϵͳ����
  LoadSysParameter();
  //����ϵͳ���ò���

  if not TApplicationHelper.IsValidConfigFile(gPath + sConfigFile,
    gSysParam.FProgID) then
  begin
    raise Exception.Create(sInvalidConfig);
    //�����ļ����Ķ�
  end;

  Title := gSysParam.FAppTitle;
  //�������
  Port := gServerParam.FPort;
  //����˿�

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
  //�Զ���ʼ��COM����
  RegObjectPoolTypes;
  //ע�����ض���
  ReloadSystemMemory(False);
  //��ʼ����������
end;

procedure TUniServerModule.UniGUIServerModuleBeforeShutdown(Sender: TObject);
begin
  gMG.FObjectPool.RegistMe(False);
  //�رն����
end;

initialization
  RegisterServerModuleClass(TUniServerModule);
end.
