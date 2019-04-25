{*******************************************************************************
  作者: dmzn@163.com 2018-04-24
  描述: 修改用户密码
*******************************************************************************}
unit UFormChangePwd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, UFormBase, uniGUIClasses, uniEdit, uniLabel, uniPanel,
  uniGUIBaseClasses, uniButton;

type
  TfFormChangePwd = class(TfFormBase)
    UniLabel1: TUniLabel;
    EditOld: TUniEdit;
    UniLabel2: TUniLabel;
    EditAgain: TUniEdit;
    UniLabel3: TUniLabel;
    EditNew: TUniEdit;
    procedure UniFormCreate(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  MainModule, USysDB, USysBusiness;

procedure TfFormChangePwd.UniFormCreate(Sender: TObject);
begin
  inherited;
  EditOld.SetFocus;
end;

procedure TfFormChangePwd.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if EditOld.Text <> UniMainModule.FUserConfig.FUserPwd then
  begin
    ShowMessage('旧密码不匹配');
    Exit;
  end;

  if (EditNew.Text = '') or (EditNew.Text <> EditAgain.Text) then
  begin
    ShowMessage('两次输入的密码不匹配');
    Exit;
  end;

  nStr := 'Update %s Set U_Password=''%s'' Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, EditNew.Text,
                        UniMainModule.FUserConfig.FUserID);
  DBExecute(nStr);

  UniMainModule.FUserConfig.FUserPwd := EditNew.Text;
  ModalResult := mrOk;
  ShowMessage('密码修改成功');
end;

initialization
  RegisterClass(TfFormChangePwd);
end.
