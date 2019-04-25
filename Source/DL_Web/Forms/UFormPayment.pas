{*******************************************************************************
  作者: dmzn@163.com 2018-05-08
  描述: 退出系统
*******************************************************************************}
unit UFormPayment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, UFormBase, uniMemo, uniEdit, uniGUIClasses, uniMultiItem,
  uniComboBox, uniLabel, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormPayment = class(TfFormBase)
    Label2: TUniLabel;
    Label1: TUniLabel;
    EditSaleMan: TUniComboBox;
    EditCus: TUniComboBox;
    Panel1: TUniSimplePanel;
    Label3: TUniLabel;
    EditIn: TUniEdit;
    EditOut: TUniEdit;
    Label4: TUniLabel;
    Label5: TUniLabel;
    Label6: TUniLabel;
    Panel2: TUniSimplePanel;
    Label7: TUniLabel;
    EditType: TUniComboBox;
    Label8: TUniLabel;
    EditMoney: TUniEdit;
    Label9: TUniLabel;
    Label10: TUniLabel;
    EditDesc: TUniMemo;
    procedure BtnOKClick(Sender: TObject);
    procedure EditSaleManChange(Sender: TObject);
    procedure EditCusChange(Sender: TObject);
    procedure EditCusKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure LoadCustomerData(const nCusID: string);
  public
    { Public declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

procedure ShowPaymentForm(const nCusID: string; nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  ULibFun, USysBusiness, USysDB, UFormGetCustomer;

procedure ShowPaymentForm(const nCusID: string; nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormPayment', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormPayment do
  begin
    if nCusID = '' then
         ActiveControl := EditCus
    else ActiveControl := EditMoney;

    LoadSaleMan(EditSaleMan.Items);
    LoadSysDictItem(sFlag_PaymentItem, EditType.Items);

    if nCusID <> '' then
      LoadCustomerData(nCusID);
    //load data

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
        begin
          FParam.FParamD := EditMoney.Text;
          nResult(Result, @FParam);
        end;
      end);
  end;
end;

procedure TfFormPayment.LoadCustomerData(const nCusID: string);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  with TStringHelper do
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select A_CID,A_InMoney,A_OutMoney,C_Name,C_SaleMan From %s ' +
            ' Left Join %s on C_ID=A_CID ' +
            'Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, sTable_Customer, nCusID);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      EditIn.Text := Format('%.2f', [FieldByName('A_InMoney').AsFloat);
      EditOut.Text := Format('%.2f', [FieldByName('A_OutMoney').AsFloat);

      FParam.FParamC := FieldByName('C_SaleMan').AsString;
      nIdx := StrListIndex(FParam.FParamC, EditSaleMan.Items, 0, '.');

      if (nIdx >= 0) and (EditSaleMan.ItemIndex <> nIdx) then
      begin
        EditSaleMan.ItemIndex := nIdx;
        EditSaleManChange(nil);
      end;

      FParam.FParamA := FieldByName('A_CID').AsString;
      FParam.FParamB := FieldByName('C_Name').AsString;
      nStr := FParam.FParamA + '.' + FParam.FParamB;

      if EditCus.Items.IndexOf(nStr) < 0 then
        EditCus.Items.Add(nStr);
      //xxxxx

      nStr := FieldByName('A_CID').AsString;
      nIdx := StrListIndex(nStr, EditCus.Items, 0, '.');

      if (nIdx >= 0) and (EditCus.ItemIndex <> nIdx) then
        EditCus.ItemIndex := nIdx;
      //xxxxx
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Desc: 业务员变更,更新客户列表
procedure TfFormPayment.EditSaleManChange(Sender: TObject);
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

//Desc: 客户变更,更新客户信息
procedure TfFormPayment.EditCusChange(Sender: TObject);
var nStr: string;
begin
  nStr := GetIDFromBox(EditCus);
  if nStr <> '' then
    LoadCustomerData(nStr);
  //xxxxx
end;

//Desc: 选择客户
procedure TfFormPayment.EditCusKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nIdx: Integer;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    ShowGetCustomerForm(GetNameFromBox(EditCus),
      procedure(const nResult: Integer; const nParam: PFormCommandParam)
      begin
        nStr := Trim(nParam.FParamC + '.' + nParam.FParamD); //saleman: id.name
        if (nStr <> '.') and (EditSaleMan.Items.IndexOf(nStr) < 0) then
          EditSaleMan.Items.Add(nStr);
        EditSaleMan.ItemIndex := EditSaleMan.Items.IndexOf(nStr);

        nStr := nParam.FParamA + '.' + nParam.FParamB; //cus: id.name
        if EditCus.Items.IndexOf(nStr) < 0 then
          EditCus.Items.Add(nStr);
        //xxxxx

        nIdx := EditCus.Items.IndexOf(nStr);
        if EditCus.ItemIndex <> nIdx then
        begin
          EditCus.ItemIndex := nIdx;
          EditCusChange(nil);
        end;
      end
    );
  end;
end;

function TfFormPayment.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditCus then
  begin
    Result := EditCus.ItemIndex > -1;
    nHint := '请选择有效的客户';
  end else

  if Sender = EditType then
  begin
    Result := Trim(EditType.Text) <> '';
    nHint := '请填写付款方式';
  end else

  if Sender = EditMoney then
  begin
    with TStringHelper,TFloatHelper do
    Result := IsNumber(EditMoney.Text, True) and
              (Float2PInt(StrToFloat(EditMoney.Text), cPrecision) <> 0);
    nHint := '请填写有效的金额';
  end;
end;

procedure TfFormPayment.BtnOKClick(Sender: TObject);
begin
  if IsDataValid then
  begin
    SaveCustomerPayment(FParam.FParamA, FParam.FParamB, FParam.FParamC,
      sFlag_MoneyHuiKuan, EditType.Text, EditDesc.Text,
      StrToFloat(EditMoney.Text),
      procedure(const nResult: Integer; const nParam: PFormCommandParam)
      begin
        ModalResult := mrOk;
        ShowMessage('回款操作成功')
      end, True);
    //done
  end;
end;

initialization
  RegisterClass(TfFormPayment);
end.
