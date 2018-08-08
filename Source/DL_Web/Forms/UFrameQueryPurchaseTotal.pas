{*******************************************************************************
  作者: 2018-07-17
  描述: 采购统计
*******************************************************************************}
unit UFrameQueryPurchaseTotal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu,
  uniRadioButton, uniButton, uniBitBtn, uniEdit, uniLabel, Data.DB,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, uniGUIBaseClasses;

type
  TfFrameQueryPurchaseTotal = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    procedure OnDateFilter(const nStart,nEnd: TDate);
    procedure OnDateTimeFilter(const nStart,nEnd: TDate);
    //日期筛选
    procedure ArrangeColum;
    procedure AfterInitFormData; override;
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, UManagerGroup,
  USysBusiness, USysDB, USysConst, UFormDateFilter;

procedure TfFrameQueryPurchaseTotal.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  with TDateTimeHelper do
  begin
    FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
    FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  end;

  FJBWhere := '';
  InitDateRange(ClassName, FStart, FEnd);
end;

procedure TfFrameQueryPurchaseTotal.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

//Desc: 过滤字段
function TfFrameQueryPurchaseTotal.FilterColumnField: string;
begin
  if HasPopedom2(sPopedom_ViewPrice, FPopedom) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

procedure TfFrameQueryPurchaseTotal.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFrameQueryPurchaseTotal.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

    Result := 'Select D_ProName, D_StockName, SUM(D_Value) D_Value From $POrderDtl ' +
              'Where  D_OutFact>=''$StartTime'' And D_OutFact<''$EndTime'' ';
    //xxxxx

    //--------------------------------------------------------------------------
    if FJBWhere <> '' then
    begin
      Result := Result + ' And ' + FJBWhere;
    end;

    Result := Result + 'Group  By D_ProName, D_StockName Order  By D_ProName, D_StockName';

    Result := MacroValue(Result, [MI('$POrderDtl', sTable_OrderDtl),
              MI('$StartTime', Date2Str(FStart)), MI('$EndTime', Date2Str(FEnd + 1))]);
    //xxxxx
  end;
end;

//Desc: 日期筛选
procedure TfFrameQueryPurchaseTotal.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameQueryPurchaseTotal.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if (EditCustomer.Text = '') then Exit;
    //按品种合计时无法查询客户

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameQueryPurchaseTotal.ArrangeColum;
var nIdx : Integer;
begin
  try
    DBGridMain.Columns.BeginUpdate;

    DBGridMain.Grouping.FieldName:= 'D_ProName';
    //*********
    for nIdx := 0 to DBGridMain.Columns.Count-1 do
    begin
      with DBGridMain.Columns[nIdx] do
      begin
        Sortable:= not DBGridMain.Grouping.Enabled;
      end;
    end;
  finally
    DBGridMain.Columns.EndUpdate;
  end;
end;

procedure TfFrameQueryPurchaseTotal.AfterInitFormData;
begin
  ArrangeColum;
end;

procedure TfFrameQueryPurchaseTotal.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameQueryPurchaseTotal.MenuItemN1Click(Sender: TObject);
begin
  ShowDateFilterForm(FTimeS, FTimeE, OnDateTimeFilter, True)
end;

procedure TfFrameQueryPurchaseTotal.OnDateTimeFilter(const nStart,nEnd: TDate);
begin
  with TDateTimeHelper do
  try
    FTimeS := nStart;
    FTimeE := nEnd;

    FJBWhere := '(D_OutFact>=''%s'' and D_OutFact <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE),
                sFlag_BillPick, sFlag_BillPost]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

initialization
  RegisterClass(TfFrameQueryPurchaseTotal);
end.
