program DLWeb;

uses
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  UFormMain in 'UFormMain.pas' {fFormMain: TUniForm},
  UFormBase in 'Forms\UFormBase.pas' {fFormBase: TUniForm},
  UFormChangePwd in 'Forms\UFormChangePwd.pas' {fFormChangePwd: TUniForm},
  UFormLogin in 'Forms\UFormLogin.pas' {fFormLogin: TUniLoginForm},
  USysModule in 'Common\USysModule.pas',
  USysBusiness in 'Common\USysBusiness.pas',
  USysConst in 'Common\USysConst.pas',
  USysFun in 'Common\USysFun.pas',
  UFrameBase in 'Forms\UFrameBase.pas' {fFrameBase: TUniFrame},
  USysRemote in 'Common\USysRemote.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
