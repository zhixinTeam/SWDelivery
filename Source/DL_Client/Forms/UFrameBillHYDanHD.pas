{*******************************************************************************
  作者:  2018-08-06
  描述: 查询水泥回单统计 明细
*******************************************************************************}
unit UFrameBillHYDanHD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  IniFiles, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, cxTextEdit, Menus,
  dxLayoutControl, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxSkinsdxLCPainter;

type
  TfFrameBillHYDanHD = class(TfFrameNormal)
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    cxLevel2: TcxGridLevel;
    cxView2: TcxGridDBTableView;
    DataSource2: TDataSource;
    SQLNo1: TADOQuery;
    N7: TMenuItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
    procedure BtnRefreshClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);

  private
    { Private declarations }
  protected
    FWhereNo: string;
    //未开条件
    FStart,FEnd: TDate;
    //时间区间
    FQueryHas,FQueryNo: Boolean;
    //查询开关
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    procedure OnSaveGridConfig(const nIni: TIniFile); override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysBusiness, UBusinessConst, UFormBase, USysDataDict,
  UDataModule, UFormDateFilter, UForminputbox, USysConst, USysDB, USysGrid;

//------------------------------------------------------------------------------
class function TfFrameBillHYDanHD.FrameID: integer;
begin
  Result := cFI_FrameBillHYDanHD;
end;

procedure TfFrameBillHYDanHD.OnCreateFrame;
begin
  inherited;
  FWhereNo := '';
  FQueryNo := True;
  FQueryHas := True;
  InitDateRange(Name, FStart, FEnd);
  cxGrid1.ActiveLevel := cxLevel1;
end;

procedure TfFrameBillHYDanHD.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameBillHYDanHD.OnLoadGridConfig(const nIni: TIniFile);
begin
  cxGrid1.ActiveLevel := cxLevel1;
  cxGrid1ActiveTabChanged(cxGrid1, cxGrid1.ActiveLevel);

  gSysEntityManager.BuildViewColumn(cxView2, 'MAIN_KHDMX');
  InitTableView(Name, cxView2, nIni);
end;

procedure TfFrameBillHYDanHD.OnSaveGridConfig(const nIni: TIniFile);
begin
  SaveUserDefineTableView(Name, cxView2, nIni);
end;

procedure TfFrameBillHYDanHD.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
begin
  nDefault := False;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  if FQueryHas then
  begin
    nStr := ' Select Min(L_OutFact) L_OutFact, L_StockName, SUM(L_Value) L_Value, L_HYDan From $Bill  ' +
            ' Where L_OutFact>=''$S'' and L_OutFact<''$End'' And L_DelMan is Null ';

    if FWhere <> '' then
      nStr := nStr + ' And (' + FWhere + ')';

    nStr := nStr + ' Group by L_StockName, L_HYDan   ' +
                   ' Order by L_OutFact, L_HYDan ';
    //xxxxx

    nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
    FDM.QueryData(SQLQuery, nStr);
  end;

  if not FQueryNo then Exit;
  nStr := ' Select * From $Bill Where L_OutFact>=''$S'' and L_OutFact<''$End''  ' +
          ' And L_DelMan is Null ';

  if FWhereNo <> '' then
      nStr := nStr + ' And (' + FWhereNo + ')';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill),
          MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  FDM.QueryData(SQLNo1, nStr);
end;

//------------------------------------------------------------------------------
procedure TfFrameBillHYDanHD.cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
  ALevel: TcxGridLevel);
begin
  BtnEdit.Enabled := (BtnEdit.Tag > 0) and (cxGrid1.ActiveView = cxView1);
  BtnDel.Enabled := (BtnDel.Tag > 0) and (cxGrid1.ActiveView = cxView1);
end;

//Desc: 刷新
procedure TfFrameBillHYDanHD.BtnRefreshClick(Sender: TObject);
begin
  FWhere := '';
  FWhereNo := '';
  FQueryNo := True;
  FQueryHas := True;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameBillHYDanHD.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

procedure TfFrameBillHYDanHD.N1Click(Sender: TObject);
var nStName, nHYDan : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStName := SQLQuery.FieldByName('L_StockName').AsString;
    nHYDan  := SQLQuery.FieldByName('L_HYDan').AsString;

    FQueryNo := True;
    FQueryHas := False;

    FWhereNo := ' L_StockName='''+nStName+''' And L_HYDan='''+nHYDan+'''  ';
    InitFormData(FWhere);
    cxGrid1.ActiveLevel := cxLevel2;
  end;
end;

procedure TfFrameBillHYDanHD.cxView1DblClick(Sender: TObject);
begin
  N1Click(Self);
end;

procedure TfFrameBillHYDanHD.EditTruckPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' or L_CusName like ''%%%s%%''' ;
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    FWhereNo := FWhere;
    
    FQueryNo := True;
    FQueryHas := True;
    InitFormData(FWhere);

    if SQLNo1.RecordCount > 0 then
      cxGrid1.ActiveLevel := cxLevel2 else
    if SQLQuery.RecordCount > 0 then
      cxGrid1.ActiveLevel := cxLevel1;
    //xxxxxx
  end else

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FQueryNo := True;
    FQueryHas := True;

    FWhere := 'L_ID like ''%' + EditBill.Text + '%''';
    FWhereNo := FWhere;
    InitFormData(FWhere);

    if SQLNo1.RecordCount > 0 then
      cxGrid1.ActiveLevel := cxLevel2 else
    if SQLQuery.RecordCount > 0 then
      cxGrid1.ActiveLevel := cxLevel1;
    //xxxxxx
  end else
  
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FQueryNo := True;
    FQueryHas := True;

    FWhere := 'L_Truck like ''%' + EditTruck.Text + '%''';
    FWhereNo := FWhere;
    InitFormData(FWhere);

    if SQLNo1.RecordCount > 0 then
      cxGrid1.ActiveLevel := cxLevel2 else
    if SQLQuery.RecordCount > 0 then
      cxGrid1.ActiveLevel := cxLevel1;
    //xxxxxx
  end;

end;

initialization
  gControlManager.RegCtrl(TfFrameBillHYDanHD, TfFrameBillHYDanHD.FrameID);
end.
