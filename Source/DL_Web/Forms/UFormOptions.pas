{*******************************************************************************
  作者: dmzn@163.com 2018-05-12
  描述: 参数选项
*******************************************************************************}
unit UFormOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, UFormBase, uniGUIClasses, uniCheckBox, uniPanel,
  uniGUIBaseClasses, uniButton;

type
  TfFormOptions = class(TfFormBase)
    CheckColumnAdjust: TUniCheckBox;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication;

procedure TfFormOptions.OnCreateForm(Sender: TObject);
begin
  CheckColumnAdjust.Checked := UniMainModule.FGridColumnAdjust;
end;

procedure TfFormOptions.BtnOKClick(Sender: TObject);
begin
  UniMainModule.FGridColumnAdjust := CheckColumnAdjust.Checked;
  ModalResult := mrOk;
end;

initialization
  RegisterClass(TfFormOptions);
end.
