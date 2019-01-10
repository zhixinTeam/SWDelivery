{*******************************************************************************
  作者: 2018-07-16
  描述: 采购品种统计日报 （单日）
*******************************************************************************}
unit UFrameQueryPurchaseStockOddDays;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles, System.StrUtils,
  UFrameBase, uniChart, uniPanel, uniSplitter, uniButton, uniBitBtn, uniEdit, System.DateUtils,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, uniDateTimePicker,
  uniGUITypes, uniGUIRegClasses, uniGUIForm, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameQueryPurchaseStockOddDays = class(TfFrameBase)
    Label3: TUniLabel;
    Splitter1: TUniSplitter;
    EdtSearchTime: TUniDateTimePicker;
    Chart1: TUniChart;
    Series1: TUniLineSeries;
    UnLbl1: TUniLabel;
    procedure EdtSearchTimeChange(Sender: TObject);
  private
    { Private declarations }
    FSearchDate : TDate;
    //时间
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
    procedure ArrangeColum;
    procedure AfterInitFormData; override;
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, UManagerGroup,
  USysBusiness, USysDB, USysConst, UFormDateFilter;


function GetLeftStr(SubStr, Str: string): string;
begin
   Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
end;

procedure TfFrameQueryPurchaseStockOddDays.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  FSearchDate := Now;
  EdtSearchTime.DateTime:= FSearchDate;
end;

procedure TfFrameQueryPurchaseStockOddDays.OnDestroyFrame(const nIni: TIniFile);
begin
  nIni.WriteInteger(ClassName, 'ChartHeight', Chart1.Height);
end;

procedure TfFrameQueryPurchaseStockOddDays.ArrangeColum;
var nIdx : Integer;
    nstr : string;
begin
  DBGridMain.Columns.BeginUpdate;
  try
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

procedure TfFrameQueryPurchaseStockOddDays.EdtSearchTimeChange(Sender: TObject);
begin
  FSearchDate:= EdtSearchTime.DateTime;
  InitFormData(FWhere);
end;

procedure TfFrameQueryPurchaseStockOddDays.AfterInitFormData;
begin
  ArrangeColum;
end;

function TfFrameQueryPurchaseStockOddDays.InitFormDataSQL(const nWhere: string): string;
var nStr : string;
begin
  FSearchDate:= EdtSearchTime.DateTime;
  with TStringHelper, TDateTimeHelper do
  begin
    nStr   := 'Select a.D_StockName, a.D_Value D_YearValue, ISNULL(YearRecNum, 0) YearRecNum, '+
                      'ISNULL(b.D_Value, 0) D_MonthValue, ISNULL(MonthRecNum, 0) MonthRecNum, '+
                      'ISNULL(c.D_Value, 0) D_DayValue, ISNULL(DayRecNum, 0) DayRecNum  ' +
                      'From (    ' +
              '	Select D_StockName, SUM(ISNULL(D_Value, 0)) D_Value, COUNT(*) YearRecNum   ' +
              '	From $OrderDtl   ' +
              '	Where D_DelMan is Null And (D_OutFact>=''$YearSTime'' and D_OutFact <''$ETime'')   ' +
              '	Group  by D_StockName) a  ' +
              'Left Join (   ' +
              '	Select D_StockName, SUM(ISNULL(D_Value, 0)) D_Value, COUNT(*) MonthRecNum   ' +
              '	From $OrderDtl   ' +
              '	Where D_DelMan is Null And (D_OutFact>=''$MounthSTime'' and D_OutFact <''$ETime'')   ' +
              '	Group  by D_StockName) b On a.D_StockName= b.D_StockName   ' +
              'Left Join (   ' +
              '	Select D_StockName, SUM(ISNULL(D_Value, 0)) D_Value, COUNT(*) DayRecNum    ' +
              '	From $OrderDtl    ' +
              '	Where D_DelMan is Null And (D_OutFact>=''$DaySTime'' and D_OutFact <''$ETime'')  ' +
              '	Group  by D_StockName) c On a.D_StockName= c.D_StockName   ' +
              'Order  by a.D_StockName ';

    Result := MacroValue(nStr, [MI('$OrderDtl', sTable_OrderDtl), MI('$YearSTime', FormatDateTime('yyyy-01-01 00:00:00', FSearchDate)),
                                  MI('$MounthSTime', FormatDateTime('yyyy-MM-01 00:00:00', FSearchDate)),
                                  MI('$DaySTime', FormatDateTime('yyyy-MM-DD 00:00:00', FSearchDate)),
                                  MI('$ETime', Date2Str(FSearchDate + 1))]);
    //xxxxx
  end;
end;

procedure TfFrameQueryPurchaseStockOddDays.OnDateFilter(const nStart,nEnd: TDate);
begin
  InitFormData(FWhere);
end;

//Desc: 日期筛选
initialization
  RegisterClass(TfFrameQueryPurchaseStockOddDays);
end.
