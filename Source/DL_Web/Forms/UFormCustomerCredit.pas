{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 信用变动
*******************************************************************************}
unit UFormCustomerCredit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, UFormBase, uniDateTimePicker, uniEdit, uniGUIClasses, uniMultiItem,
  uniComboBox, uniLabel, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormCustomerCredit = class(TfFormBase)
    Label1: TUniLabel;
    Label2: TUniLabel;
    EditSaleMan: TUniComboBox;
    EditCus: TUniComboBox;
    Label3: TUniLabel;
    EditCredit: TUniEdit;
    Label4: TUniLabel;
    Label5: TUniLabel;
    EditEnd: TUniDateTimePicker;
    Label6: TUniLabel;
    Label7: TUniLabel;
    EditMemo: TUniEdit;
    unlbl1: TUniLabel;
    cbb_VarMan: TUniComboBox;
    procedure EditSaleManChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
    //设置参数
  end;

  TFormCusCreditResult = procedure (const nCusID: string) of object;
  //结果回调

procedure ShowCusCreditForm(const nCusID: string;
  const nResult: TFormCusCreditResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  ULibFun, USysBusiness, USysDB;

//Date: 2018-05-07
//Parm: 客户编号;结果回调
//Desc: 显示信用变动窗口
procedure ShowCusCreditForm(const nCusID: string;
  const nResult: TFormCusCreditResult);
var nForm: TUniForm;
    nParm: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormCustomerCredit', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormCustomerCredit do
  begin
    nParm.FCommand := cCmd_EditData;
    nParm.FParamA := nCusID;
    SetParam(nParm);

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(FParam.FParamA);
        //xxxxx
      end);
  end;
end;

function TfFormCustomerCredit.SetParam(const nParam: TFormCommandParam): Boolean;
var nStr: string;
    nQuery: TADOQuery;
begin
  ActiveControl := EditCredit;
  Result := inherited SetParam(nParam);
  EditEnd.DateTime := Date() + 1;

  LoadSaleMan(EditSaleMan.Items);
  //*********
  LoadVerifyMan(cbb_VarMan.Items);
  //*********
  if nParam.FCommand <> cCmd_EditData then Exit;

  nQuery := nil;
  with TStringHelper do
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select C_ID,C_Name,C_SaleMan From %s Where C_ID=''%s''';
    nStr := Format(nStr, [sTable_Customer, nParam.FParamA);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      nStr := FieldByName('C_SaleMan').AsString;
      EditSaleMan.ItemIndex := StrListIndex(nStr, EditSaleMan.Items, 0, '.');

      nStr := FieldByName('C_ID').AsString + '.' +
              FieldByName('C_Name').AsString;
      //xxxxxx

      if EditCus.Items.IndexOf(nStr) < 0 then
        EditCus.Items.Add(nStr);
      EditCus.Text := nStr;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Desc: 业务员变更,选择客户
procedure TfFormCustomerCredit.EditSaleManChange(Sender: TObject);
var nStr: string;
begin
  nStr := GetIDFromBox(EditSaleMan);
  if nStr = '' then
  begin
    EditCus.Items.Clear;
    Exit;
  end;

  nStr := Format('C_SaleMan=''%s''', [nStr);
  LoadCustomer(EditCus.Items, nStr);
end;

function TfFormCustomerCredit.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditCus then
  begin
    Result := EditCus.ItemIndex >= 0;
    nHint := '请选择有效的客户';
  end

  else if Sender = EditCredit then
  begin
    Result := TStringHelper.IsNumber(EditCredit.Text, True);
    nHint := '请填写有效的金额';
  end

  else if Sender = EditEnd then
  begin
    Result := EditEnd.DateTime > Now;
    nHint := '有效期应大于当前日期';
  end

  else if (Sender = cbb_VarMan) then
  begin
    Result := (cbb_VarMan.Text<>'');
    nHint := '需要填写审核人';
  end;

end;

procedure TfFormCustomerCredit.BtnOKClick(Sender: TObject);
begin
  if IsDataValid and SaveCustomerCredit(GetIDFromBox(EditCus), EditMemo.Text,
     StrToFloat(EditCredit.Text), EditEnd.DateTime, cbb_VarMan.Text) then
  begin
    ModalResult := mrOk;
    ShowMessage('提交授信申请成功');
  end;
end;

initialization
  RegisterClass(TfFormCustomerCredit);
end.
