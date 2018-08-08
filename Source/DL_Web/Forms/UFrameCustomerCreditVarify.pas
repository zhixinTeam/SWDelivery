{*******************************************************************************
  作者: 2018-07-17
  描述: 客户信用审核
*******************************************************************************}
unit UFrameCustomerCreditVarify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, UFrameBase, Vcl.Menus,
  uniMainMenu, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniSplitter,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, Vcl.Controls,
  Vcl.Forms, uniGUIBaseClasses;

type
  TfFrameCustomerCreditVarify = class(TfFrameBase)
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

function TfFrameCustomerCreditVarify.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    Result := 'Select a.*, C_Name C_CusName From $CusCredit a ' +
              'Left  Join S_Customer b On C_ID=C_CusID ' +
              'Where C_Verify=''N'' And C_VerDate Is Null And C_VerMan1=''$VerMan'' '+
                    'or C_VerMan2=''$VerMan'' or C_VerMan3=''$VerMan'' ';
    //xxxxx

    if nWhere <> '' then
    begin
      Result := Result + ' And (' + nWhere + ')';
    end;

    Result := MacroValue(Result, [MI('$CusCredit', sTable_CusCredit),
                                  MI('$VerMan', UniMainModule.FUserConfig.FUserID)]);
    Result := Result + ' Order By C_Date Desc';
  end;
end;

procedure TfFrameCustomerCreditVarify.EditCustomerKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameCustomerCreditVarify.OnCusCredit(const nCusID: string);
begin
  InitFormData(FWhere);
end;

//Desc: 信用变动
procedure TfFrameCustomerCreditVarify.BtnEditClick(Sender: TObject);
var nStr: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
       nStr := ClientDS.FieldByName('C_ID').AsString
  else nStr := '';

  ShowCusCreditForm(nStr, OnCusCredit);
  //xxxxx
end;

//------------------------------------------------------------------------------
procedure TfFrameCustomerCreditVarify.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameCustomerCreditVarify.OnCreditDetail(const nChanged: Boolean);
begin
  if nChanged then InitFormData(FWhere);
end;

procedure TfFrameCustomerCreditVarify.MenuItemN1Click(Sender: TObject);
var nStr: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    nStr := ClientDS.FieldByName('C_ID').AsString;
    ShowCreditDetailForm(nStr, FPopedom, OnCreditDetail);
  end;
end;

initialization
  RegisterClass(TfFrameCustomerCreditVarify);
end.
