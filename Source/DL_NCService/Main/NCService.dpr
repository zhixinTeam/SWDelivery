program NCService;

{$IFDEF GenRODL}
  {.#ROGEN:..\Common\MIT_Service.rodl}
{$ENDIF}

uses
  FastMM4,
  uROComInit,
  Windows,
  Forms,
  ULibFun,
  UMITConst,
  UROModule in '..\Forms\UROModule.pas' {ROModule: TDataModule},
  UDataModule in '..\Forms\UDataModule.pas' {FDM: TDataModule},
  UFormMain in '..\Forms\UFormMain.pas' {fFormMain},
  UFormBase in '..\Forms\UFormBase.pas' {BaseForm},
  UFrameBase in '..\Forms\UFrameBase.pas' {fFrameBase: TFrame},
  UFrameSummary in '..\Forms\UFrameSummary.pas' {fFrameSummary: TFrame},
  UFrameRunLog in '..\Forms\UFrameRunLog.pas' {fFrameRunLog: TFrame},
  UFrameConfig in '..\Forms\UFrameConfig.pas' {fFrameConfig: TFrame},
  UFrameParam in '..\Forms\UFrameParam.pas' {fFrameParam: TFrame},
  UFormPack in '..\Forms\UFormPack.pas' {fFormPack},
  UFormParamDB in '..\Forms\UFormParamDB.pas' {fFormParamDB},
  UFormParamSAP in '..\Forms\UFormParamSAP.pas' {fFormParamSAP},
  UFormPerform in '..\Forms\UFormPerform.pas' {fFormPerform},
  UFormServiceURL in '..\Forms\UFormServiceURL.pas' {fFormServiceURL},
  UFramePlugs in '..\Forms\UFramePlugs.pas' {fFramePlugs: TFrame},
  UFrameStatus in '..\Forms\UFrameStatus.pas' {fFrameStatus: TFrame},
  UNCStatusChkThread in '..\Common\UNCStatusChkThread.pas';

{$R *.res}
{$R RODLFile.RES}

begin
  InitSystemEnvironment;
  //��ʼ�����л���
  ActionSysParameter(True);
  //����ϵͳ������Ϣ
  
  if not IsValidConfigFile(gPath + sConfigFile, gSysParam.FProgID) then
  begin
    ShowDlg(sInvalidConfig, sHint, GetDesktopWindow); Exit;
  end; //�����ļ����Ķ�

  Application.Initialize;
  Application.HelpFile := '';
  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TROModule, ROModule);
  Application.CreateForm(TfFormMain, fFormMain);
  Application.Run;
end.