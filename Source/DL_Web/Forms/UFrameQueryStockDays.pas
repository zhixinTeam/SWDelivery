{*******************************************************************************
  作者: dmzn@163.com 2018-05-21
  描述: 按品种统计日报
*******************************************************************************}
unit UFrameQueryStockDays;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  UFrameBase, uniChart, uniPanel, uniSplitter, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses;

type
  TfFrameQueryStockDays = class(TfFrameBase)
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    Splitter1: TUniSplitter;
    Chart1: TUniChart;
    Series1: TUniLineSeries;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure DBGridMainDblClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    //时间区间
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
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

procedure TfFrameQueryStockDays.OnCreateFrame(const nIni: TIniFile);
var nY,nM,nD: Word;
begin
  inherited;
  DecodeDate(Date(), nY, nM, nD);
  FStart := EncodeDate(nY, nM, 1);

  if nM < 12 then
       FEnd := EncodeDate(nY, nM+1, 1) - 1
  else FEnd := EncodeDate(nY+1, 1, 1) - 1;

  nY := nIni.ReadInteger(ClassName, 'ChartHeight', 0);
  if nY < 100 then nY := 100;
  Chart1.Height := nY;
end;

procedure TfFrameQueryStockDays.OnDestroyFrame(const nIni: TIniFile);
begin
  nIni.WriteInteger(ClassName, 'ChartHeight', Chart1.Height);
end;

function TfFrameQueryStockDays.InitFormDataSQL(const nWhere: string): string;
var nStr,nF1,nF2: string;
    nIdx: Integer;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    nF1 := '';
    nF2 := '';

    for nIdx := 1 to 31 do
    begin
      nF1 := nF1 + Format('Sum(L_Day%d)  As L_Day%d', [nIdx, nIdx]);
      if nIdx < 31 then nF1 := nF1 + ',';

      nStr := 'case L_Days when %d then Sum(L_Value) else 0 end as L_Day%d';
      nF2 := nF2 + Format(nStr, [nIdx, nIdx]);
      if nIdx < 31 then nF2 := nF2 + ',';
    end;

    Result := 'Select L_StockNo,L_StockName,$F1 From (' +
      ' Select L_StockNo,L_StockName,$F2 From (' +
      '  Select L_StockNo,L_StockName,L_Value,DATEPART(day,L_OutFact) as L_Days ' +
      '  From $Bill Where L_OutFact>=''$ST'' And L_OutFact<''$ED''' +
      '	 ) t2 Group By L_StockNo,L_StockName,L_Days ' +
      ') t1 Group By L_StockNo,L_StockName';
    //xxxxx

    Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
              MI('$F1', nF1), MI('$F2', nF2),
              MI('$ST', Date2Str(FStart)), MI('$ED', Date2Str(FEnd+1))]);
    //xxxxx
  end;
end;

procedure TfFrameQueryStockDays.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameQueryStockDays.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

//Desc: 双击绘制图标
procedure TfFrameQueryStockDays.DBGridMainDblClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  if (not ClientDS.Active) or (ClientDS.RecordCount < 1) then Exit;
  //no data

  with Chart1 do
  begin
    Title.Text.Text := '品种: ' + ClientDS.FieldByName('L_StockName').AsString;
    Series1.Clear;
  end;

  for nIdx := 1 to 31 do
  begin
    nStr := Format('L_Day%d', [nIdx]);
    Series1.Add(ClientDS.FieldByName(nStr).AsFloat, IntToStr(nIdx));
  end;
end;

initialization
  RegisterClass(TfFrameQueryStockDays);
end.
