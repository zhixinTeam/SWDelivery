{*******************************************************************************
  作者: dmzn@163.com 2018-05-28
  描述: 添加修改权限组
*******************************************************************************}
unit UFormPopedomGroup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  uniGUITypes, uniGUIForm, USysConst, UFormBase, uniCheckBox, uniLabel,
  uniGUIClasses, uniEdit, uniPanel, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses,
  uniButton;

type
  TfFormPopedomGroup = class(TfFormBase)
    EditName: TUniEdit;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    EditDesc: TUniEdit;
    Check1: TUniCheckBox;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
  end;

procedure ShowPopedomGroupForm(const nGroup: string;
  const nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication,
  UManagerGroup, ULibFun, USysBusiness, USysDB;

//Date: 2018-05-28
//Parm: 客户编号;结果回调
//Desc: 显示权限组窗口
procedure ShowPopedomGroupForm(const nGroup: string;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormPopedomGroup', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormPopedomGroup do
  begin
    if nGroup = '' then
         FParam.FCommand := cCmd_AddData
    else FParam.FCommand := cCmd_EditData;
    FParam.FParamA := nGroup;

    BtnOK.Enabled := nGroup = '';
    InitFormData(nGroup);

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(mrOk, @FParam);
      end);
    //xxxxx
  end;
end;

procedure TfFormPopedomGroup.OnCreateForm(Sender: TObject);
begin
  FDBType := ctMain;
  ActiveControl := EditName;
end;

procedure TfFormPopedomGroup.InitFormData(const nID: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  if nID <> '' then   
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select * From %s Where G_ID=%s';
    nStr := Format(nStr, [sTable_Group, nID);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      EditName.Text := FieldByName('G_NAME').AsString;
      EditDesc.Text := FieldByName('G_DESC').AsString;

      Check1.Checked := FieldByName('G_CANDEL').AsInteger = 0;
      BtnOK.Enabled := True;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormPopedomGroup.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nBool: Boolean;
    nQuery: TADOQuery;
begin
  EditName.Text := Trim(EditName.Text);
  if EditName.Text = '' then
  begin
    ShowMessage('请输入组名称');
    Exit;
  end;

  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    nBool := FParam.FCommand <> cCmd_EditData;

    if nBool then
    begin
      nStr := 'Select Max(G_ID)+1 From ' + sTable_Group;
      nID := DBQuery(nStr, nQuery).Fields[0.AsString;
      FParam.FParamA := nID;
    end else nID := FParam.FParamA;

    with TSQLBuilder do
    nStr := MakeSQLByStr([
      SF_IF([SF('G_ID', nID, sfVal), '', nBool),
      SF_IF([SF('G_CANDEL', 0, sfVal),
             SF('G_CANDEL', 1, sfVal), Check1.Checked),
      //xxxxx

      SF('G_NAME', EditName.Text), SF('G_DESC', EditDesc.Text),
      SF('G_PROGID', gSysParam.FProgID), SF('G_Flag', sWebFlag)
      , sTable_Group, SF('G_ID', nID, sfVal), nBool);
    //xxxxx

    DBExecute(nStr, nQuery);
    ModalResult := mrOk;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormPopedomGroup);
end.
