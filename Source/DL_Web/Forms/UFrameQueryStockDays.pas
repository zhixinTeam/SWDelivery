{*******************************************************************************
  作者: dmzn@163.com 2018-05-21
  描述: 按品种统计月报 （每日）
*******************************************************************************}
unit UFrameQueryStockDays;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles, System.StrUtils,
  UFrameBase, uniChart, uniPanel, uniSplitter, uniButton, uniBitBtn, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

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

procedure TfFrameQueryStockDays.ArrangeColum;
var nIdx, nDay : Integer;
begin
  try
    DBGridMain.Columns.BeginUpdate;

    for nIdx := 0 to DBGridMain.Columns.Count-1 do
      if Pos('日', DBGridMain.Columns[nIdx.Title.Caption)>0 then
      begin
        nDay:= StrToIntDef(GetLeftStr('日', DBGridMain.Columns[nIdx.Title.Caption), -1);
        if FEnd<now  then
        begin
          DBGridMain.Columns[nIdx.Visible:= True;
        end
        else
        begin
          if nDay>StrToIntDef(FormatDateTime('dd',Now), -1) then
            DBGridMain.Columns[nIdx.Visible:= False
          else DBGridMain.Columns[nIdx.Visible:= True;
        end;
      end;
  finally
    DBGridMain.Columns.EndUpdate;
  end;
end;

procedure TfFrameQueryStockDays.AfterInitFormData;
begin
  ArrangeColum;
end;

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
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd));
    nF1 := '';
    nF2 := '';

    for nIdx := 1 to 31 do
    begin
      nF1 := nF1 + Format('Sum(L_Day%d)  As L_Day%d', [nIdx, nIdx);
      if nIdx < 31 then nF1 := nF1 + ',';

      nStr := 'case L_Days when %d then Sum(L_Value) else 0 end as L_Day%d';
      nF2 := nF2 + Format(nStr, [nIdx, nIdx);
      if nIdx < 31 then nF2 := nF2 + ',';
    end;

    Result := 'Select L_Type, L_StockNo,L_StockName,$F1 From (' +
      ' Select Case when L_StockName like ''%熟%'' then ''U、熟料'' when L_StockName like ''%骨料%'' then ''V、骨料'' '+
                    'when L_StockName like ''%袋%'' then ''D、袋装'' '+
              '      when L_StockName like ''%散%'' then ''S、散装'' else L_Type end L_Type, L_StockNo,L_StockName,$F2 From (' +
      '  Select L_Type, L_StockNo,L_StockName,L_Value,DATEPART(day,L_OutFact) as L_Days ' +
      '  From $Bill Where L_OutFact>=''$ST'' And L_OutFact<''$ED''' +
      '	 ) t2 Group By L_Type, L_StockNo,L_StockName,L_Days ' +
      ') t1 Group By L_Type, L_StockNo,L_StockName ';         //with rollup
    //xxxxx

    Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
              MI('$F1', nF1), MI('$F2', nF2),
              MI('$ST', Date2Str(FStart)), MI('$ED', Date2Str(FEnd+1)));

    //添加汇总
//    Result := 'Select case when (tl1.L_Type IS not NULL)and(tl1.L_StockNo IS not NULL)and(tl1.L_StockName IS not NULL)  then tl1.L_StockName ' +
//                  'else (case when (tl1.L_Type IS not NULL)and(tl1.L_StockNo IS not NULL)and(tl1.L_StockName IS NULL) then ''小计: ''  ' +
//                  'else case when (tl1.L_Type IS not NULL)and(tl1.L_StockNo IS NULL)and(tl1.L_StockName IS NULL) then ''品类小计: '' else   ' +
//                  'case when (tl1.L_Type IS NULL)and(tl1.L_StockNo IS NULL)and(tl1.L_StockName IS NULL) then ''合计: '' else '''' end end end ) end L_StockName, '+

      Result := 'Select tl1.*, tl2.本月累计, tl2.本年累计 From ( '+ Result + ' )  tl1 '+
              'Left Join (  '+
              'Select c.L_Type, c.L_StockName, ISNULL(b.Value, 0) 本月累计, c.Value 本年累计 From ( '+
              '	Select L_Type, L_StockName, SUM(ISNULL(L_Value, 0)) as Value  From S_Bill b '+
              '	Where (L_OutFact>='''+FormatDateTime('YYYY-01-01 00:00:00', FStart)+''' and L_OutFact <='''+FormatDateTime('YYYY-MM-DD 23:59:59', FEnd)+''') '+
              '	Group  by  L_Type, L_StockName) c  '+
              '	left Join (   '+
              '	Select L_Type, L_StockName, SUM(ISNULL(L_Value, 0)) as Value  From S_Bill b '+
              '	Where (L_OutFact>='''+FormatDateTime('YYYY-MM-01 00:00:00', FStart)+''' and L_OutFact <='''+FormatDateTime('YYYY-MM-DD 23:59:59', FEnd)+''') '+
              '	Group  by  L_Type, L_StockName) b On c.L_StockName=b.L_StockName '+
              ') tl2 On tl1.L_StockName= tl2.L_StockName  Order  by  tl1.L_Type Desc, tl1.L_StockName ASC ';
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
    nStr := Format('L_Day%d', [nIdx);
    Series1.Add(ClientDS.FieldByName(nStr).AsFloat, IntToStr(nIdx));
  end;
end;

initialization
  RegisterClass(TfFrameQueryStockDays);
end.
