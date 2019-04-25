{*******************************************************************************
  作者: dmzn@163.com 2018-05-28
  描述: 添加修改用户
*******************************************************************************}
unit UFormPopedomUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  uniGUITypes, uniGUIForm, USysConst, UFormBase, uniCheckBox, uniLabel,
  uniGUIClasses, uniEdit, uniPanel, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses,
  uniButton, uniMultiItem, uniComboBox;

type
  TfFormPopedomUser = class(TfFormBase)
    EditName: TUniEdit;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    EditPwd: TUniEdit;
    UniLabel3: TUniLabel;
    EditMail: TUniEdit;
    UniLabel4: TUniLabel;
    EditPhone: TUniEdit;
    UniLabel5: TUniLabel;
    EditGroup: TUniComboBox;
    Chk_VerifyCredit: TUniCheckBox;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
  end;

procedure ShowPopedomUserForm(const nUser: string;
  const nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication,
  UManagerGroup, ULibFun, USysBusiness, USysDB;

//Date: 2018-05-28
//Parm: 客户编号;结果回调
//Desc: 显示微信关联窗口
procedure ShowPopedomUserForm(const nUser: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormPopedomUser', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormPopedomUser do
  begin
    if nUser = '' then
         FParam.FCommand := cCmd_AddData
    else FParam.FCommand := cCmd_EditData;
    FParam.FParamA := nUser;

    BtnOK.Enabled := nUser = '';
    InitFormData(nUser);

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(mrOk, @FParam);
      end);
    //xxxxx
  end;
end;

procedure TfFormPopedomUser.OnCreateForm(Sender: TObject);
begin
  FDBType := ctMain;
  ActiveControl := EditName;
end;

procedure TfFormPopedomUser.InitFormData(const nID: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  with TStringHelper do
  try
    EditName.ReadOnly := nID<>'';
    EditGroup.BeginUpdate;
    EditGroup.Clear;
    nQuery := LockDBQuery(FDBType);

    nStr := 'Select G_ID,G_NAME From %s ' +
            'Where G_Flag Like ''%%%s%%'' Order By G_ID';
    nStr := Format(nStr, [sTable_Group, sWebFlag);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr := Fields[0.AsString + '.' + Fields[1.AsString;
        EditGroup.Items.Add(nStr);
        Next;
      end;
    end;

    if nID <> '' then
    begin
      nStr := 'Select * From %s Where U_Name=''%s''';
      nStr := Format(nStr, [sTable_User, nID);

      with DBQuery(nStr, nQuery) do
      if RecordCount > 0 then
      begin
        EditName.Text := FieldByName('U_Name').AsString;
        EditPwd.Text := FieldByName('U_Password').AsString;
        EditMail.Text := FieldByName('U_Mail').AsString;
        EditPhone.Text := FieldByName('U_Phone').AsString;

        nStr := FieldByName('U_Group').AsString;
        EditGroup.ItemIndex := StrListIndex(nStr, EditGroup.Items, 0, '.');
        Chk_VerifyCredit.Checked:= StrToBoolDef(FieldByName('U_VerifyCredit').AsString, False);

        BtnOK.Enabled := True;
      end;
    end;
  finally
    EditGroup.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormPopedomUser.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nBool: Boolean;
    nQuery: TADOQuery;
begin
  EditName.Text := Trim(EditName.Text);
  if EditName.Text = '' then
  begin
    ShowMessage('请输入用户名称');
    Exit;
  end;

  if EditGroup.ItemIndex < 0 then
  begin
    ShowMessage('请选择有效的权限组');
    Exit;
  end;

  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    nBool := FParam.FCommand <> cCmd_EditData;

    if nBool then
    begin
      nStr := 'Select Count(*) From %s Where U_Name=''%s''';
      nStr := Format(nStr, [sTable_User, EditName.Text);

      with DBQuery(nStr, nQuery) do
      if Fields[0.AsInteger > 0 then
      begin
        nStr := '用户[ %s 已存在,请填写其它名字';
        nStr := Format(nStr, [EditName.Text);
        ShowMessage(nStr); Exit;
      end;
      FParam.FParamA := EditName.Text;
    end else nID := FParam.FParamA;

    with TSQLBuilder do
    nStr := MakeSQLByStr([
      SF('U_Name', EditName.Text), SF('U_Password', EditPwd.Text),
      SF('U_Mail', EditMail.Text), SF('U_Phone', EditPhone.Text),
      SF('U_VerifyCredit', BoolToStr(Chk_VerifyCredit.Checked)),
      SF('U_Group', GetIDFromBox(EditGroup), sfVal)
      , sTable_User, SF('U_Name', nID), nBool);
    //xxxxx

    DBExecute(nStr, nQuery);
    ModalResult := mrOk;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormPopedomUser);
end.
