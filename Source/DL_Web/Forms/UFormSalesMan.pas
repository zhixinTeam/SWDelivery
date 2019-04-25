{*******************************************************************************
  作者: dmzn@163.com 2018-05-08
  描述: 客户管理
*******************************************************************************}
unit UFormSalesMan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, uniGUITypes, UFormBase, uniCheckBox, uniMemo, uniLabel,
  uniGUIClasses, uniEdit, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormSalesMan = class(TfFormBase)
    EditName: TUniEdit;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    EditArea: TUniEdit;
    EditMemo: TUniMemo;
    UniLabel13: TUniLabel;
    UniLabel6: TUniLabel;
    EditPhone: TUniEdit;
    Check1: TUniCheckBox;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysRemote, USysDB;

function TfFormSalesMan.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  ActiveControl := EditName;
  Result := inherited SetParam(nParam);

  case nParam.FCommand of
   cCmd_AddData:
    begin
      FParam.FParamA := '';
      InitFormData('');
    end;
   cCmd_EditData:
    begin
      BtnOK.Enabled := False;
      InitFormData(FParam.FParamA);
    end;
  end;
end;

//Date: 2018-05-08
//Parm: 编号
//Desc: 载入nID业务员的信息到界面
procedure TfFormSalesMan.InitFormData(const nID: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  if nID <> '' then
  try
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Salesman, nID);

    nQuery := LockDBQuery(ctWork);
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      BtnOK.Enabled := True;
      First;

      EditName.Text    := FieldByName('S_Name').AsString;
      EditPhone.Text   := FieldByName('S_Phone').AsString;
      EditArea.Text    := FieldByName('S_Area').AsString;
      EditMemo.Text    := FieldByName('S_Memo').AsString;
      Check1.Checked   := FieldByName('S_InValid').AsString = sFlag_Yes;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormSalesMan.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nList: TStrings;
begin
  EditName.Text := Trim(EditName.Text);
  if EditName.Text = '' then
  begin
    EditName.SetFocus;
    ShowMessage('请填写业务员名称'); Exit;
  end;

  nList := nil;
  with TSQLBuilder,TStringHelper do
  try
    if FParam.FCommand = cCmd_AddData then
    begin
      nID := GetSerialNo(sFlag_BusGroup, sFlag_SaleMan, False);
      if nID = '' then Exit;      
    end else nID := '';
    //new id

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nStr := SF('R_ID', FParam.FParamA, sfVal);

    nStr := MakeSQLByStr([
      SF_IF([SF('S_ID', nID), '', FParam.FCommand = cCmd_AddData),
      SF('S_Name', EditName.Text),
      SF('S_PY', GetPinYin(EditName.Text)),
      SF('S_Phone', EditPhone.Text),
      SF('S_Area', EditArea.Text),
      SF('S_Memo', EditMemo.Text),

      SF_IF([SF('S_InValid', sFlag_Yes),
             SF('S_InValid', sFlag_No), Check1.Checked)
      //xxxxx
      , sTable_Salesman, nStr, FParam.FCommand = cCmd_AddData);
    nList.Add(nStr);

    DBExecute(nList, nil, FDBType);
    ModalResult := mrOk;
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

initialization
  RegisterClass(TfFormSalesMan);
end.
