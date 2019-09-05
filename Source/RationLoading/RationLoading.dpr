program RationLoading;

uses
  Forms,
  main in 'main.pas' {FormMain},
  UFrame in 'UFrame.pas' {Frame1: TFrame},
  PLCController in 'PLCController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
