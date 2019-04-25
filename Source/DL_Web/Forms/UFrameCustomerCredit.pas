{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 客户信用管理
*******************************************************************************}
unit UFrameCustomerCredit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, UFrameBase, Vcl.Menus,
  uniMainMenu, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniSplitter,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, Vcl.Controls,
  Vcl.Forms, uniGUIBaseClasses, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameCustomerCredit = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
    procedure EditCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure BtnEditClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
  private
    { Private declarations }
    procedure OnCusCredit(const nCusID: string);
    procedure OnCreditDetail(const nChanged: Boolean);
    //信用变动
  public
    { Public declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, UManagerGroup,
  USysBusiness, USysDB, USysConst, UFormCustomerCredit, UFormCreditDetail;

function TfFrameCustomerCredit.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    Result := 'Select cus.*,A_CreditLimit,S_Name From $Cus cus ' +
      ' Left Join $CA ca On ca.A_CID=cus.C_ID ' +
      ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ';
    //xxxxx

    if nWhere = '' then
    begin
      Result := Result + 'Where (A_CreditLimit <> 0) Or (cus.C_ID In (' +
             ' Select distinct(C_CusID) From $CC Where C_Verify=''$NO'')) ';
      //xxxxx
    end else
    begin
      Result := Result + ' Where (' + nWhere + ')';
    end;

    if (Not UniMainModule.FUserConfig.FIsAdmin) then
    begin
      if HasPopedom2(sPopedom_ViewMYCusData, FPopedom) then
        Result := Result + 'And (sm.S_Name='''+ UniMainModule.FUserConfig.FUserID +''')';
    end;
    //*****************

    Result := MacroValue(Result, [MI('$Cus', sTable_Customer),
              MI('$CA', sTable_CusAccount), MI('$SM', sTable_Salesman),
              MI('$CC', sTable_CusCredit), MI('$NO', sFlag_No));
    Result := Result + ' Order By C_ID';
  end;
end;

procedure TfFrameCustomerCredit.EditCustomerKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameCustomerCredit.OnCusCredit(const nCusID: string);
begin
  InitFormData(FWhere);
end;

//Desc: 信用变动
procedure TfFrameCustomerCredit.BtnEditClick(Sender: TObject);
var nStr: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
       nStr := ClientDS.FieldByName('C_ID').AsString
  else nStr := '';

  ShowCusCreditForm(nStr, OnCusCredit);
  //xxxxx
end;

//------------------------------------------------------------------------------
procedure TfFrameCustomerCredit.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameCustomerCredit.OnCreditDetail(const nChanged: Boolean);
begin
  if nChanged then InitFormData(FWhere);
end;

procedure TfFrameCustomerCredit.MenuItemN1Click(Sender: TObject);
var nStr: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    nStr := ClientDS.FieldByName('C_ID').AsString;
    ShowCreditDetailForm(nStr, FPopedom, OnCreditDetail);
  end;
end;

initialization
  RegisterClass(TfFrameCustomerCredit);
end.
