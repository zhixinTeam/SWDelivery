{*******************************************************************************
  作者: 2018-07-17
  描述: 客户信用审核
*******************************************************************************}
unit UFrameCustomerCreditVarify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, UFrameBase, Vcl.Menus, uniGUITypes,
  uniMainMenu, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniSplitter, Graphics,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, Vcl.Controls,
  Vcl.Forms, uniGUIBaseClasses, frxClass, frxExportPDF, frxDBSet;

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
    procedure DBGridMainDblClick(Sender: TObject);
    procedure DBGridMainDrawColumnCell(Sender: TObject; ACol, ARow: Integer;
      Column: TUniDBGridColumn; Attribs: TUniCellAttribs);
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
  USysBusiness, USysDB, USysConst, UFormCreditDetailVerify;

function TfFrameCustomerCreditVarify.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    Result := 'Select a.*, C_Name C_CusName, c.R_ID V_RId, V_CreditID, V_PreFxMan, V_Verify, V_VerMan, V_VerDate, V_Memo From $CusCredit a ' +
              'Left  Join $Customer b On C_ID=C_CusID ' +
              'Left  Join $CusCreditVerify c On V_CreditID=C_CreditID ' +
              'Where V_VerMan=''$VerMan'' ';  // And V_Verify=''U''
    //xxxxx

    if nWhere <> '' then
    begin
      Result := Result + ' And (' + nWhere + ')';
    end;

    Result := MacroValue(Result, [MI('$CusCredit', sTable_CusCredit),  MI('$Customer', sTable_Customer),
                                  MI('$CusCreditVerify', sTable_CusCreditVif),
                                  MI('$VerMan', UniMainModule.FUserConfig.FUserID));
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
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text);
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
    MenuItemN1Click(Self);
  //xxxxx
end;

//------------------------------------------------------------------------------
procedure TfFrameCustomerCreditVarify.DBGridMainDblClick(Sender: TObject);
begin
  MenuItemN1Click(self);
end;

procedure TfFrameCustomerCreditVarify.DBGridMainDrawColumnCell(Sender: TObject;
  ACol, ARow: Integer; Column: TUniDBGridColumn; Attribs: TUniCellAttribs);
begin
  if ClientDS.FieldByName('V_Verify').AsString='N' then
  begin
    Attribs.Font.Color := $C0C0C0;
    //Attribs.Color := clWhite;
  end
  else if ClientDS.FieldByName('V_Verify').AsString='U' then
  begin
    Attribs.Font.Color := $ffcc00;
    //Attribs.Color := clWhite;
  end;
end;

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
var nCusId, nCrdVifId, nCusName, nMoney, nEndDate, nVRId: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    if ClientDS.FieldByName('V_Verify').AsString<>'U' then
    begin
      ShowMessage('该申请已处理，不能进行再次审核');
      Exit;
    end;

    //*************************************************************
    nCusId := ClientDS.FieldByName('C_CusID').AsString;
    nCrdVifId:= ClientDS.FieldByName('C_CreditID').AsString;
    nCusName := ClientDS.FieldByName('C_CusName').AsString;
    nMoney   := ClientDS.FieldByName('C_Money').AsString;
    nEndDate := FormatDateTime('yyyy-MM-dd hh:nn:ss', ClientDS.FieldByName('C_End').AsDateTime);
    nVRId    := ClientDS.FieldByName('V_RId').AsString;

    ShowCreditDetailVerifyForm(nCusId, nCrdVifId, nCusName, nMoney, nEndDate,
                                              nVRId, OnCreditDetail);
  end;
end;

initialization
  RegisterClass(TfFrameCustomerCreditVarify);
end.
