{*******************************************************************************
  作者: dmzn@163.com 2018-07-03
  描述: 纸卡审核
*******************************************************************************}
unit UFormZhiKaVerify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, Data.Win.ADODB, UFormBase, uniCheckBox, uniGUIClasses, uniEdit,
  uniLabel, uniPanel, uniGUIBaseClasses, uniButton, uniBasicGrid, uniStringGrid;

type
  TfFormZhiKaVerify = class(TfFormBase)
    Label2: TUniLabel;
    Label1: TUniLabel;
    EditZK: TUniEdit;
    EditName: TUniEdit;
    Label10: TUniLabel;
    EditCustomer: TUniEdit;
    Grid1: TUniStringGrid;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadZhiKaData(const nZhiKa: string);
    //加载数据
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
  end;

procedure ShowZKVerifyForm(const nZhiKa: string; nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, uniGUIForm, Vcl.Grids, UManagerGroup,
  ULibFun, USysBusiness, USysRemote, USysDB;

const
  giName    = 0;
  giLow     = 1;
  giPrice   = 2;
  giHigh    = 3;
  //grid info:表格列数据描述

type
  TStocPrice = record
    FID,FName: string;       //物料
    FPrice: Double;          //单价
    FLow,FHigh: Double;      //区间
  end;

var
  gStocks: array of TStocPrice;

procedure ShowZKVerifyForm(const nZhiKa: string; nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormZhiKaVerify', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormZhiKaVerify do
  begin
    BtnOK.Enabled := False;
    LoadZhiKaData(nZhiKa);

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        nResult(Result, @FParam);
      end);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormZhiKaVerify.OnCreateForm(Sender: TObject);
begin
  with Grid1 do
  begin
    FixedCols := 1;
    RowCount := 0;
    ColCount := 4;
    Options := [goVertLine,goHorzLine, goColSizing, goEditing,goFixedColClick];
  end;

  UserDefineStringGrid(Name, Grid1, True);
end;

procedure TfFormZhiKaVerify.OnDestroyForm(Sender: TObject);
begin
  UserDefineStringGrid(Name, Grid1, False);
end;

procedure TfFormZhiKaVerify.LoadZhiKaData(const nZhiKa: string);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  with TStringHelper do
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select Z_Name,Z_Verified,C_Name From %s ' +
            ' Left Join %s on C_ID=Z_Customer ' +
            'Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, nZhiKa]);

    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount < 1 then
      begin
        nStr := Format('纸卡[ %s ]已丢失.', [nZhiKa]);
        ShowMessage(nStr);
        Exit;
      end;

      EditZK.Text := nZhiKa;
      FParam.FParamA := nZhiKa;
      EditName.Text := FieldByName('Z_Name').AsString;
      EditCustomer.Text := FieldByName('C_Name').AsString;

      nStr := FieldByName('Z_Verified').AsString;
      if nStr = sFlag_Yes then
      begin
        BtnOK.Caption := '已审核';
        Exit;
      end;
    end;

    SetLength(gStocks, 0);
    nStr := 'Select D_StockNo,D_StockName,D_Price From %s Where D_ZID=''%s''';
    nStr := Format(nStr, [sTable_ZhikaDtl, nZhiKa]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(gStocks, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with gStocks[nIdx] do
        begin
          FID := FieldByName('D_StockNo').AsString;
          FName := FieldByName('D_StockName').AsString;
          FPrice := FieldByName('D_Price').AsFloat;

          FLow := 0;
          FHigh := 0;
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    if Length(gStocks) < 1  then Exit; //no data
    ReleaseDBQuery(nQuery); //释放远程
    nQuery := nil;
    nQuery := LockDBQuery(ctMain);

    nStr := 'Select R_StockNo,R_Low,R_High From %s Where R_Valid=''%s''';
    nStr := Format(nStr, [sTable_PriceRule, sFlag_Yes]);
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr := FieldByName('R_StockNo').AsString;
        for nIdx := Low(gStocks) to High(gStocks) do
        if gStocks[nIdx].FID = nStr then
        begin
          gStocks[nIdx].FLow := FieldByName('R_Low').AsFloat;
          gStocks[nIdx].FHigh := FieldByName('R_High').AsFloat;
          Break;
        end;

        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;

  BtnOK.Enabled := True;
  Grid1.RowCount := Length(gStocks);

  for nIdx := Low(gStocks) to High(gStocks) do
  begin
    Grid1.Cells[giName, nIdx] := gStocks[nIdx].FName;
    Grid1.Cells[giLow, nIdx] := Format('%.2f', [gStocks[nIdx].FLow]);
    Grid1.Cells[giPrice, nIdx] := Format('%.2f', [gStocks[nIdx].FPrice]);
    Grid1.Cells[giHigh, nIdx] := Format('%.2f', [gStocks[nIdx].FHigh]);
  end;
end;

procedure TfFormZhiKaVerify.BtnOKClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  nStr := '';
  for nIdx := Low(gStocks) to High(gStocks) do
  with gStocks[nIdx],TFloatHelper do
  begin
    if (FLow > 0) and FloatRelation(FLow, FPrice, rtGreater, cPrecision) then
    begin
      nStr := nStr + Format('※.品种[ %s ]价格低于下限.', [FName]) + #13#10;
    end;

    if (FHigh > 0) and FloatRelation(FHigh, FPrice, rtLess, cPrecision) then
    begin
      nStr := nStr + Format('※.品种[ %s ]价格高于上限.', [FName]) + #13#10;
    end;
  end;

  if nStr <> '' then
  begin
    nStr := '价格审核无法通过,原因如下:' + #13#10#13#10 + nStr;
    ShowMessage(nStr);
    Exit;
  end;

  with TSQLBuilder do
  nStr := MakeSQLByStr([SF('Z_Verified', sFlag_Yes),
       SF('Z_VerifyMan', UniMainModule.FUserConfig.FUserID),
       SF('Z_VerifyDate', sField_SQLServer_Now, sfVal)
       ], sTable_ZhiKa, SF('Z_ID', FParam.FParamA), False);
  //xxxxx

  DBExecute(nStr, nil, FDBType);
  ModalResult := mrOk;
end;

initialization
  RegisterClass(TfFormZhiKaVerify);
end.
