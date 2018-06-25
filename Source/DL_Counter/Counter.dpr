program Counter;

uses
  FastMM4,
  Windows,
  Forms,
  UFormMain in 'UFormMain.pas' {fFormMain},
  UFrameJS in 'UFrameJS.pas' {fFrameCounter: TFrame},
  UFormLog in 'UFormLog.pas' {fFormLog},
  USysConst in 'USysConst.pas',
  UFormCard in 'UFormCard.pas' {fFormCard};

{$R *.res}

var
  gMutexHwnd: Hwnd;
  //������

begin
  gMutexHwnd := CreateMutex(nil, True, 'RunSoft_HX_Counter');
  //����������
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    ReleaseMutex(gMutexHwnd);
    CloseHandle(gMutexHwnd); Exit;
  end; //����һ��ʵ��

  Application.Initialize;
  Application.CreateForm(TfFormMain, fFormMain);
  Application.Run;

  ReleaseMutex(gMutexHwnd);
  CloseHandle(gMutexHwnd);
end.
