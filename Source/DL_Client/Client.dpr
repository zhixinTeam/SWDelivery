program Client;

uses
  FastMM4,
  Forms,
  Windows,
  ULibFun,
  USysFun,
  UsysConst,
  UDataModule in 'Forms\UDataModule.pas' {FDM: TDataModule},
  UFormMain in 'Forms\UFormMain.pas' {fMainForm},
  UFrameBase in 'Forms\UFrameBase.pas' {BaseFrame: TBaseFrame},
  UFormBase in 'Forms\UFormBase.pas' {BaseForm},
  UFrameNormal in 'Forms\UFrameNormal.pas' {fFrameNormal: TFrame},
  UFormNormal in 'Forms\UFormNormal.pas' {fFormNormal},
  UFrameQueryOrderHD in 'Forms\UFrameQueryOrderHD.pas' {fFrameQueryOrderHD: TFrame},
  UFramePurOrderImport in 'Forms\UFramePurOrderImport.pas' {fFramePurOrderImport: TFrame},
  UFormCustomerInitEdit in 'Forms\UFormCustomerInitEdit.pas' {fFormCustomerInitEdit},
  UFrameMsgLog in 'Forms\UFrameMsgLog.pas' {fFrameMsgLog: TFrame},
  UFormCtlCusbd in 'Forms\UFormCtlCusbd.pas' {fFormCtlCusbd},
  UFrameQuerySyncOrderForNC in 'Forms\UFrameQuerySyncOrderForNC.pas' {fFrameQuerySyncOrderForNC: TFrame},
  UFromUPDateBindBillZhiKa in 'Forms\UFromUPDateBindBillZhiKa.pas' {fFormUPDateBindBillZhika},
  UFramQueryNcZhiKaLog in 'Forms\UFramQueryNcZhiKaLog.pas' {fFrameQueryNcZhiKaLog: TFrame},
  UFrameQueryCusZhikaInfo in 'Forms\UFrameQueryCusZhikaInfo.pas' {fFrameQueryCusZhiKa: TFrame},
  UFramePrinterJS in 'Forms\UFramePrinterJS.pas' {fFramePrinterJS: TFrame},
  UFromPrinterJs in 'Forms\UFromPrinterJs.pas' {fFormPrinterJs};

{$R *.res}
var
  gMutexHwnd: Hwnd;
  //������

begin
  gMutexHwnd := CreateMutex(nil, True, 'RunSoft_ZX_Delivery');
  //����������
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    ReleaseMutex(gMutexHwnd);
    CloseHandle(gMutexHwnd); Exit;
  end; //����һ��ʵ��

  InitSystemEnvironment;
  //��ʼ�����л���
  LoadSysParameter;
  //����ϵͳ������Ϣ

  if not IsValidConfigFile(gPath + sConfigFile, gSysParam.FProgID) then
  begin
    ShowDlg(sInvalidConfig, sHint, GetDesktopWindow); Exit;
  end; //�����ļ����Ķ�
  
  Application.Initialize;
  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TfMainForm, fMainForm);
  Application.CreateForm(TfFormCustomerInitEdit, fFormCustomerInitEdit);
  Application.CreateForm(TfFormCtlCusbd, fFormCtlCusbd);
  Application.CreateForm(TfFormUPDateBindBillZhika, fFormUPDateBindBillZhika);
  Application.CreateForm(TfFormPrinterJs, fFormPrinterJs);
  Application.Run;

  ReleaseMutex(gMutexHwnd);
  CloseHandle(gMutexHwnd);
end.
