{*******************************************************************************
  作者:  2018-07-14
  描述: 销售品种统计日报 （单日）
*******************************************************************************}
unit UFrameQueryStockOddDays;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles, System.StrUtils,
  UFrameBase, uniChart, uniPanel, uniSplitter, uniButton, uniBitBtn, uniEdit, System.DateUtils,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, uniDateTimePicker,
  uniGUITypes, uniGUIRegClasses, uniGUIForm, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameQueryStockOddDays = class(TfFrameBase)
    Label3: TUniLabel;
    Splitter1: TUniSplitter;
    EdtSearchTime: TUniDateTimePicker;
    Chart1: TUniChart;
    Series1: TUniLineSeries;
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

procedure TfFrameQueryStockOddDays.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  EdtSearchTime.DateTime:= Now;
  FSearchDate := EdtSearchTime.DateTime;
end;

procedure TfFrameQueryStockOddDays.OnDestroyFrame(const nIni: TIniFile);
begin
  nIni.WriteInteger(ClassName, 'ChartHeight', Chart1.Height);
end;

procedure TfFrameQueryStockOddDays.ArrangeColum;
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

        nstr:= FieldName;
        if Pos('Day', nstr)>0 then
          GroupHeader:= '日统计'
        else if Pos('Month', nstr)>0 then
          GroupHeader:= '月统计'
        else if Pos('Year', nstr)>0 then
          GroupHeader:= '年统计'
        else GroupHeader:= '';
      end;
    end;
  finally
    DBGridMain.Columns.EndUpdate;
  end;
end;

procedure TfFrameQueryStockOddDays.AfterInitFormData;
begin
  ArrangeColum;
end;

function TfFrameQueryStockOddDays.InitFormDataSQL(const nWhere: string): string;
var nStr : string;
begin
  FSearchDate := EdtSearchTime.DateTime;
  //********************
  with TStringHelper, TDateTimeHelper do
  begin
    nStr   := 'Select  Case when a.L_StockName=''(低碱)熟料'' then ''V'' else a.L_Type end L_Type, a.L_StockName, ISNULL(c.Value, 0) DayValue, CONVERT(decimal(15,2), ISNULL(c.L_Price, 0)) DayPrice, ISNULL(c.L_Money, 0) DayMoney,  ' +
                          'ISNULL(b.Value, 0) MonthValue, CONVERT(decimal(15,2), ISNULL(b.L_Price, 0)) MonthPrice, ISNULL(b.L_Money, 0) MonthMoney,    ' +
                          'a.Value YearValue, CONVERT(decimal(15,2), a.L_Price) YearPrice, a.L_Money YearMoney From (      ' +
              '        Select L_Type, L_StockName, AVG(L_Price) L_Price, SUM(L_Value) as Value, Sum(L_Value * L_Price) as L_Money From $Bill ' +
              '        Where (L_OutFact>=''$YearSTime'' and L_OutFact <''$ETime'')    ' +
              '        Group  by  L_Type, L_StockName) a     ' +
              '        left Join (      ' +
              '        Select L_Type, L_StockName,  AVG(L_Price) L_Price, SUM(L_Value) as Value, Sum(L_Value * L_Price) as L_Money From $Bill ' +
              '        Where (L_OutFact>=''$MounthSTime'' and L_OutFact <''$ETime'')     ' +
              '        Group  by  L_Type, L_StockName) b On a.L_StockName=b.L_StockName   ' +
              '        left Join (    ' +
              '        Select L_Type, L_StockName,  AVG(L_Price) L_Price, SUM(L_Value) as Value, Sum(L_Value * L_Price) as L_Money From $Bill  ' +
              '        Where (L_OutFact>=''$DaySTime'' and L_OutFact <''$ETime'')   ' +
              '        Group  by  L_Type, L_StockName) c On a.L_StockName=c.L_StockName  ' +
              '        Order  by  a.L_Type, b.L_StockName Desc  ';

    Result := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$YearSTime', FormatDateTime('yyyy-01-01 00:00:00', FSearchDate)),
                                  MI('$MounthSTime', FormatDateTime('yyyy-MM-01 00:00:00', FSearchDate)),
                                  MI('$DaySTime', FormatDateTime('yyyy-MM-DD 00:00:00', FSearchDate)),
                                  MI('$ETime', Date2Str(FSearchDate + 1))]);
    //xxxxx
  end;
end;

procedure TfFrameQueryStockOddDays.OnDateFilter(const nStart,nEnd: TDate);
begin
  InitFormData(FWhere);
end;

//Desc: 日期筛选
initialization
  RegisterClass(TfFrameQueryStockOddDays);
end.
