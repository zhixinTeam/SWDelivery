{*******************************************************************************
  作者: dmzn@163.com 2018-04-25
  描述: 客户管理
*******************************************************************************}
unit UFormCustomer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, uniGUITypes, UFormBase, uniMemo, uniMultiItem, uniComboBox,
  uniLabel, uniGUIClasses, uniEdit, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormCutomer = class(TfFormBase)
    EditName: TUniEdit;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    EditFaRen: TUniEdit;
    UniLabel3: TUniLabel;
    EditAddr: TUniEdit;
    UniLabel4: TUniLabel;
    EditLiXiRen: TUniEdit;
    EditSaleMan: TUniComboBox;
    UniLabel8: TUniLabel;
    UniLabel9: TUniLabel;
    EditBank: TUniComboBox;
    UniLabel10: TUniLabel;
    EditAccount: TUniEdit;
    UniLabel11: TUniLabel;
    EditCredit: TUniEdit;
    UniLabel12: TUniLabel;
    EditMemo: TUniMemo;
    UniLabel13: TUniLabel;
    UniLabel14: TUniLabel;
    UniLabel6: TUniLabel;
    UniLabel5: TUniLabel;
    EditFax: TUniEdit;
    EditPhone: TUniEdit;
    EditTax: TUniEdit;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
    function GetSaleManID: string;
    //业务员号
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysRemote, USysDB;

function TfFormCutomer.SetParam(const nParam: TFormCommandParam): Boolean;
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

//Date: 2018-05-03
//Parm: 供应商编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormCutomer.InitFormData(const nID: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  if EditSaleMan.Items.Count < 1 then
    LoadSaleMan(EditSaleMan.Items);
  LoadSysDictItem(sFlag_BankItem, EditBank.Items);

  nQuery := nil;
  if nID <> '' then
  try
    nStr := 'Select cus.*,A_CreditLimit From %s cus' +
            ' Left Join %s On A_CID=C_ID ' +
            'Where cus.R_ID=%s';
    nStr := Format(nStr, [sTable_Customer, sTable_CusAccount, nID);

    nQuery := LockDBQuery(ctWork);
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      BtnOK.Enabled := True;
      First;

      EditName.Text    := FieldByName('C_Name').AsString;
      EditFaRen.Text   := FieldByName('C_FaRen').AsString;
      EditAddr.Text    := FieldByName('C_Addr').AsString;
      EditLiXiRen.Text := FieldByName('C_LiXiRen').AsString;
      EditPhone.Text   := FieldByName('C_Phone').AsString;
      EditFax.Text     := FieldByName('C_Fax').AsString;
      EditTax.Text     := FieldByName('C_Tax').AsString;
      EditBank.Text    := FieldByName('C_Bank').AsString;
      EditAccount.Text := FieldByName('C_Account').AsString;
      EditCredit.Text  := FieldByName('A_CreditLimit').AsString;
      EditMemo.Text    := FieldByName('C_Memo').AsString;

      nStr := FieldByName('C_SaleMan').AsString;
      with TStringHelper do
        EditSaleMan.ItemIndex := StrListIndex(nStr, EditSaleMan.Items, 0, '.');
      //xxxxx
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

function TfFormCutomer.GetSaleManID: string;
begin
  Result := EditSaleMan.Text;
  Result := Copy(Result, 1, Pos('.', Result) - 1);
end;

procedure TfFormCutomer.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nBool: Boolean;
    nList: TStrings;
begin
  EditName.Text := Trim(EditName.Text);
  if EditName.Text = '' then
  begin
    EditName.SetFocus;
    ShowMessage('请填写客户名称'); Exit;
  end;

  nList := nil;
  with TSQLBuilder,TStringHelper do
  try
    nBool := FParam.FCommand <> cCmd_EditData;
    if  nBool then
    begin
      nID := GetSerialNo(sFlag_BusGroup, sFlag_Customer, False);
      if nID = '' then Exit;      
    end else nID := '';
    //new id

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nStr := SF('R_ID', FParam.FParamA, sfVal);

    nStr := MakeSQLByStr([
      SF_IF([SF('C_ID', nID), '', nBool),
      SF_IF([SF('C_XuNi', sFlag_No), '', nBool),

      SF('C_Name', EditName.Text),
      SF('C_PY', GetPinYin(EditName.Text)),
      SF('C_FaRen', EditFaRen.Text),
      SF('C_Addr', EditAddr.Text),
      SF('C_LiXiRen', EditLiXiRen.Text),
      SF('C_Phone', EditPhone.Text),
      SF('C_Fax', EditFax.Text),
      SF('C_Tax', EditTax.Text),
      SF('C_Bank', EditBank.Text),
      SF('C_Account', EditAccount.Text),
      SF('C_Memo', EditMemo.Text),
      SF('C_SaleMan', GetSaleManID())
      , sTable_Customer, nStr, FParam.FCommand = cCmd_AddData);
    nList.Add(nStr);

    if nID <> '' then
    begin
      nStr := 'Insert Into %s(A_CID,A_Date) Values(''%s'', %s)';
      nStr := Format(nStr, [sTable_CusAccount, nID, sField_SQLServer_Now);
      nList.Add(nStr);
    end;

    DBExecute(nList, nil, FDBType);
    ModalResult := mrOk;
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

initialization
  RegisterClass(TfFormCutomer);
end.
