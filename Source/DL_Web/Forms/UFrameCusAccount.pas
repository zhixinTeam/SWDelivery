{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 客户账户查询
*******************************************************************************}
unit UFrameCusAccount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, UFrameBase, uniEdit,
  uniLabel, Data.DB, System.IniFiles, Vcl.Menus, uniMainMenu, Datasnap.DBClient,
  uniSplitter, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar,
  Vcl.Controls, Vcl.Forms, uniGUIBaseClasses;

type
  TfFrameCusAccount = class(TfFrameBase)
    Label1: TUniLabel;
    EditCustomer: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItem1: TUniMenuItem;
    MenuItemN2: TUniMenuItem;
    MenuItem3: TUniMenuItem;
    MenuItem2: TUniMenuItem;
    procedure EditCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  UManagerGroup, ULibFun, USysBusiness, USysDB, USysConst;

procedure TfFrameCusAccount.OnCreateFrame(const nIni: TIniFile);
begin
  MenuItem3.Enabled := UniMainModule.FUserConfig.FIsAdmin;
end;

function TfFrameCusAccount.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper,TDateTimeHelper do
  begin
    Result := 'Select ca.*,cus.*,S_Name as C_SaleName,' +
      '(A_InitMoney + A_InMoney-A_OutMoney-A_Compensation-A_FreezeMoney) As A_YuE ' +
      'From $CA ca ' +
      ' Left Join $Cus cus On cus.C_ID=ca.A_CID ' +
      ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ';
    //xxxxx

    if nWhere = '' then
         Result := Result + 'Where IsNull(C_XuNi, '''')<>''$Yes'''
    else Result := Result + 'Where (' + nWhere + ')';

    Result := MacroValue(Result, [MI('$CA', sTable_CusAccount),
              MI('$Cus', sTable_Customer), MI('$SM', sTable_Salesman),
              MI('$Yes', sFlag_Yes)]);
    //xxxxx
  end;
end;

procedure TfFrameCusAccount.EditCustomerKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'C_PY like ''%%%s%%'' Or C_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end
end;

//------------------------------------------------------------------------------
procedure TfFrameCusAccount.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 快捷菜单
procedure TfFrameCusAccount.MenuItem1Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('C_XuNi=''%s''', [sFlag_Yes]);
   20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

//Desc: 校正客户资金
procedure TfFrameCusAccount.MenuItem3Click(Sender: TObject);
var nStr,nCID: string;
    nVal: Double;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  if DBGridMain.SelectedRows.Count < 1 then Exit;
  nList := nil;
  nQuery := nil;

  with TStringHelper,TFloatHelper do
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nQuery := LockDBQuery(FDBType);
    nCID := ClientDS.FieldByName('A_CID').AsString;

    nStr := 'Select Sum(L_Money) from (' +
            '  select L_Value * L_Price as L_Money from %s' +
            '  where L_OutFact Is not Null And L_CusID = ''%s'') t';
    nStr := Format(nStr, [sTable_Bill, nCID]);

    with DBQuery(nStr, nQuery) do
    begin
      nVal := Float2Float(Fields[0].AsFloat, cPrecision, True);
      nStr := 'Update %s Set A_OutMoney=%.2f Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nVal, nCID]);
      nList.Add(nStr);
    end;

    nStr := 'Select Sum(L_Money) from (' +
            '  select L_Value * L_Price as L_Money from %s' +
            '  where L_OutFact Is Null And L_CusID = ''%s'') t';
    nStr := Format(nStr, [sTable_Bill, nCID]);

    with DBQuery(nStr, nQuery) do
    begin
      nVal := Float2Float(Fields[0].AsFloat, cPrecision, True);
      nStr := 'Update %s Set A_FreezeMoney=%.2f Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nVal, nCID]);
      nList.Add(nStr);
    end;

    DBExecute(nList, nQuery);
    InitFormData(FWhere);
    ShowMessage('校正完毕');
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFrameCusAccount);
end.
