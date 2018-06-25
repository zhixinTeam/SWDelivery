{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 开提货单
*******************************************************************************}
unit UFrameBill;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu, uniButton,
  uniBitBtn, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses,
  uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, uniGUIBaseClasses;

type
  TfFrameBill = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    Label1: TUniLabel;
    EditBill: TUniEdit;
    Label4: TUniLabel;
    EditTruck: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
    MenuItemN2: TUniMenuItem;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    //创建释放
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, UManagerGroup,
  USysBusiness, USysDB, USysConst, UFormDateFilter;

procedure TfFrameBill.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  FUseDate := True;
  InitDateRange(ClassName, FStart, FEnd);
end;

procedure TfFrameBill.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

//Desc: 过滤字段
function TfFrameBill.FilterColumnField: string;
begin
  if HasPopedom2(sPopedom_ViewPrice, FPopedom) then
       Result := ''
  else Result := 'L_Price';
end;

function TfFrameBill.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

    Result := 'Select * From $Bill ';
    //提货单

    if (nWhere = '') or FUseDate then
    begin
      Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'')';
      nStr := ' And ';
    end else nStr := ' Where ';

    if nWhere <> '' then
      Result := Result + nStr + '(' + nWhere + ')';
    //xxxxx

    Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
              MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
    //xxxxx
  end;
end;

procedure TfFrameBill.AfterInitFormData;
begin
  FUseDate := True;
end;

//Desc: 日期筛选
procedure TfFrameBill.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameBill.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

procedure TfFrameBill.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FUseDate := Length(EditBill.Text) <= 3;
    FWhere := 'L_ID like ''%' + EditBill.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FUseDate := Length(EditTruck.Text) <= 3;
    FWhere := Format('L_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameBill.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 快捷菜单
procedure TfFrameBill.MenuItemN1Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('(L_Status=''%s'')', [sFlag_BillNew]);
   20: FWhere := 'L_OutFact Is Null'
   else Exit;
  end;

  FUseDate := False;
  InitFormData(FWhere);
end;

initialization
  RegisterClass(TfFrameBill);
end.
