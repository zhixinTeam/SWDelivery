{*******************************************************************************
  ����: dmzn@163.com 2018-04-25
  ����: �˳�ϵͳ
*******************************************************************************}
unit UFormExit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, UFormBase, uniLabel, uniGUIClasses, uniPanel,
  uniGUIBaseClasses, uniButton;

type
  TfFormExit = class(TfFormBase)
    UniLabel1: TUniLabel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication;

procedure TfFormExit.BtnOKClick(Sender: TObject);
begin
  UniSession.Terminate('ע���ɹ�');
  ModalResult := mrOk;
end;

initialization
  RegisterClass(TfFormExit);
end.
