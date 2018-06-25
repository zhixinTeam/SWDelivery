{*******************************************************************************
  作者: dmzn@163.com 2018-05-06
  描述: 纸卡冻结
*******************************************************************************}
unit UFormZhiKaFreeze;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, uniGUIForm,
  uniGUITypes, UFormBase, uniBasicGrid, uniStringGrid, uniRadioButton,
  uniGUIClasses, uniCheckBox, uniPanel, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniButton;

type
  TfFormZKFreeze = class(TfFormBase)
    Panel1: TUniSimplePanel;
    Check1: TUniCheckBox;
    Check2: TUniCheckBox;
    Radio1: TUniRadioButton;
    Radio2: TUniRadioButton;
    Grid1: TUniStringGrid;
    procedure BtnOKClick(Sender: TObject);
    procedure Check1Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData;
    function GetSelectStocks: string;
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
  end;

  TFormZKFreeResult = procedure (const nStocks: string) of object;
  //结果回调

function ShowZKFreezeForm(const nResult: TFormZKFreeResult): Boolean;
//入口函数

implementation

{$R *.dfm}

uses
  Vcl.Grids, Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication,
  ULibFun, USysBusiness, USysDB, USysConst;

const
  giID    = 0;
  giMemo  = 1;
  giName  = 2;
  giCheck = 3;
  giType  = 4;
  //grid info:表格列数据描述

//Date: 2018-05-06
//Desc: 显示按品种冻结窗口
function ShowZKFreezeForm(const nResult: TFormZKFreeResult): Boolean;
var nForm: TUniForm;
begin
  Result := False;
  nForm := SystemGetForm('TfFormZKFreeze', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormZKFreeze do
  begin
    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(GetSelectStocks);
        //xxxxx
      end);
    Result := True;
  end;
end;

procedure TfFormZKFreeze.OnCreateForm(Sender: TObject);
begin
  with Grid1 do
  begin
    FixedCols := 3;
    RowCount := 0;
    ColCount := 5;
    Options := [goVertLine,goHorzLine,goEditing,goFixedColClick];
  end;

  UserDefineStringGrid(Name, Grid1, True);
  InitFormData;
  //load data
end;

procedure TfFormZKFreeze.OnDestroyForm(Sender: TObject);
begin
  UserDefineStringGrid(Name, Grid1, False);
end;

procedure TfFormZKFreeze.InitFormData;
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select D_Memo as S_Type,D_ParamB as S_NO,D_Value as S_Name From %s ' +
            'Where D_Name=''%s'' Order By D_Memo ASC,D_Value ASC';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      Grid1.RowCount := RecordCount;
      nIdx := 0;
      First;

      while not Eof do
      begin
        nStr := FieldByName('S_Type').AsString;
        if nStr = sFlag_Dai then
             Grid1.Cells[giMemo, nIdx] := 'D.袋装'
        else Grid1.Cells[giMemo, nIdx] := 'S.散装';

        Grid1.Cells[giType, nIdx] := nStr;
        Grid1.Cells[giID, nIdx] := FieldByName('S_NO').AsString;
        Grid1.Cells[giName, nIdx] := FieldByName('S_Name').AsString;

        Inc(nIdx);
        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormZKFreeze.Grid1Click(Sender: TObject);
begin
  if Grid1.Col = giCheck then
  begin
    if Grid1.Cells[giCheck, Grid1.Row] = sCheckFlag then
         Grid1.Cells[giCheck, Grid1.Row] := ''
    else Grid1.Cells[giCheck, Grid1.Row] := sCheckFlag;
  end;
end;

procedure TfFormZKFreeze.Check1Click(Sender: TObject);
var nIdx,nTag: Integer;
begin
  nTag := TComponent(Sender).Tag;
  for nIdx := Grid1.RowCount-1 downto 0 do
  begin
    case nTag of
     10:
      begin
        if Grid1.Cells[giType, nIdx] = sFlag_Dai then
          if Check1.Checked then
               Grid1.Cells[giCheck, nIdx] := sCheckFlag
          else Grid1.Cells[giCheck, nIdx] := '';
        //xxxxx
      end;
     20:
      begin
        if Grid1.Cells[giType, nIdx] = sFlag_San then
          if Check2.Checked then
               Grid1.Cells[giCheck, nIdx] := sCheckFlag
          else Grid1.Cells[giCheck, nIdx] := '';
        //xxxxx
      end;
    end;
  end;
end;

function TfFormZKFreeze.GetSelectStocks: string;
var nIdx: Integer;
begin
  Result := '';
  for nIdx := Grid1.RowCount-1 downto 0 do
   if Grid1.Cells[giCheck, nIdx] = sCheckFlag then
    if Result = '' then
         Result := '''' + Grid1.Cells[giID, nIdx] + ''''
    else Result := Result + ',''' + Grid1.Cells[giID, nIdx] + ''''
  //xxxxx
end;

procedure TfFormZKFreeze.BtnOKClick(Sender: TObject);
var nStr,nStock: string;
begin
  nStock := GetSelectStocks;
  if nStock = '' then
  begin
    ShowMessage('请选择有效的水泥品种.');
    Exit;
  end;

  nStr := '确定要%s所有包含被选中品种的纸卡吗?';
  if Radio1.Checked then
       nStr := Format(nStr, ['冻结'])
  else nStr := Format(nStr, ['解冻']);

  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      //cancel

      if Radio1.Checked then
      begin
        nStr := 'Update $ZK Set Z_TJStatus=''$Frz'' Where Z_ID In (' +
                'Select D_ZID From $Dtl Where D_StockNo In ($Stock)) and ' +
                'IsNull(Z_InValid,'''')<>''$Yes'' And Z_ValidDays>$Now';
        //tjing
      end else
      begin
        nStr := 'Update $ZK Set Z_TJStatus=''$Ovr'' Where Z_ID In (' +
                'Select D_ZID From $Dtl Where D_StockNo In ($Stock)) and ' +
                'Z_TJStatus=''$Frz''';
        //jtover
      end;

      with TStringHelper do
      nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$Stock', nStock),
              MI('$Dtl', sTable_ZhiKaDtl), MI('$Frz', sFlag_TJing),
              MI('$Ovr', sFlag_TJOver), MI('$Yes', sFlag_Yes),
              MI('$Now', sField_SQLServer_Now)]);
      //xxxxx

      DBExecute(nStr, nil, FDBType);
      ModalResult := mrOk;
    end);
  //xxxxx
end;

initialization
  RegisterClass(TfFormZKFreeze);
end.
