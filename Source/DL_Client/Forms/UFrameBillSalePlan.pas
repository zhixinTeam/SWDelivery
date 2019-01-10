{*******************************************************************************
  作者:  2018-08-20
  描述: 查询水销售品种限量  客户限量
*******************************************************************************}
unit UFrameBillSalePlan;

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
  TfFrameBillSalePlan = class(TfFrameNormal)
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    cxLevel2: TcxGridLevel;
    cxView2: TcxGridDBTableView;
    DataSource2: TDataSource;
    SQLNo1: TADOQuery;
    N7: TMenuItem;
    Edt_StockName: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
    procedure BtnRefreshClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);

  private
    { Private declarations }
  protected
    FWhereA : string;
    //未开条件
    FStart,FEnd: TDate;
    //时间区间
    FQueryAll: Boolean;
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
class function TfFrameBillSalePlan.FrameID: integer;
begin
  Result := cFI_FrameBillSalePlan;
end;

procedure TfFrameBillSalePlan.OnCreateFrame;
begin
  inherited;
  FQueryAll := True;
  InitDateRange(Name, FStart, FEnd);
  cxGrid1.ActiveLevel := cxLevel1;
end;

procedure TfFrameBillSalePlan.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameBillSalePlan.OnLoadGridConfig(const nIni: TIniFile);
begin
  cxGrid1.ActiveLevel := cxLevel1;
  cxGrid1ActiveTabChanged(cxGrid1, cxGrid1.ActiveLevel);

  gSysEntityManager.BuildViewColumn(cxView2, 'MAIN_DXLMX');
  InitTableView(Name, cxView2, nIni);
end;

procedure TfFrameBillSalePlan.OnSaveGridConfig(const nIni: TIniFile);
begin
  SaveUserDefineTableView(Name, cxView2, nIni);
end;

procedure TfFrameBillSalePlan.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
begin
  nDefault := False;

  if FQueryAll or (cxGrid1.ActiveLevel=cxLevel1) then
  begin
    nStr := ' Select * From  $SalePlanStock  Where 1=1 ';
    if FWhere <> '' then
      nStr := nStr + ' And (' + FWhere + ')';
    //xxxxx

    nStr := MacroValue(nStr, [MI('$SalePlanStock', sTable_SalePlanStock)]);
    FDM.QueryData(SQLQuery, nStr);
  end;

  if FQueryAll or (cxGrid1.ActiveLevel=cxLevel2) then
  begin
    nStr := ' Select * From $SalePlanCustomer Where 1=1 ';

    if FWhere <> '' then
        nStr := nStr + ' And (' + FWhere + ')';

    nStr := MacroValue(nStr, [MI('$SalePlanCustomer', sTable_SalePlanCustomer)]);
    //xxxxx

    FDM.QueryData(SQLNo1, nStr);
  end;

  FQueryAll := False;
end;

//------------------------------------------------------------------------------
procedure TfFrameBillSalePlan.cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
  ALevel: TcxGridLevel);
begin

end;

//Desc: 刷新
procedure TfFrameBillSalePlan.BtnRefreshClick(Sender: TObject);
begin
  FWhere := '';
  FQueryAll := True;
  InitFormData(FWhere);
end;

procedure TfFrameBillSalePlan.N1Click(Sender: TObject);
var nStNo, nStName : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStNo := SQLQuery.FieldByName('S_StockNo').AsString;
    nStName := SQLQuery.FieldByName('S_StockName').AsString;

    FWhere := ' C_StockNo='''+nStNo+''' ';
    cxGrid1.ActiveLevel := cxLevel2;
    InitFormData(FWhere);
  end;
end;

procedure TfFrameBillSalePlan.cxView1DblClick(Sender: TObject);
begin
  N1Click(Self);
end;

procedure TfFrameBillSalePlan.EditTruckPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  FWhereA:= '';
  if (Sender = Edt_StockName) and (cxGrid1.ActiveLevel= cxLevel1) then
  begin
    EditCus.Text := '';
  end;

  EditCus.Text := Trim(EditCus.Text);
  if EditCus.Text <> '' then
  begin
    cxGrid1.ActiveLevel:= cxLevel2;

    FWhereA := ' C_CusName like ''%%%s%%''' ;
    FWhere := Format(FWhereA, [ EditCus.Text]);
  end;

  Edt_StockName.Text := Trim(Edt_StockName.Text);
  if Edt_StockName.Text <> '' then
  begin
    if cxGrid1.ActiveLevel= cxLevel2 then
    begin
      if EditCus.Text <> '' then
        FWhere := FWhere + ' And C_StockName like ''%' + Edt_StockName.Text + '%'''

      else FWhere := ' C_StockName like ''%' + Edt_StockName.Text + '%''';
    end
    else  FWhere := ' S_StockName like ''%' + Edt_StockName.Text + '%''';
    //xxxxxx
  end;

  InitFormData(FWhere);
end;

procedure TfFrameBillSalePlan.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  if cxGrid1.ActiveLevel = cxLevel1 then
    nParam.FParamA := 'Stock'
  else nParam.FParamA := 'Customer';

  CreateBaseFormItem(cFI_FormBillSalePlan, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) then
  begin
    BtnRefresh.Click;
  end;
end;

procedure TfFrameBillSalePlan.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
    nStr : string;
begin
  if cxGrid1.ActiveLevel = cxLevel1 then
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  if cxGrid1.ActiveLevel = cxLevel2 then
  if cxView2.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  if cxGrid1.ActiveLevel = cxLevel1 then
  begin
    nParam.FParamA := 'Stock';
    nParam.FParamB := SQLQuery.FieldByName('R_ID').AsString;
    nParam.FParamC := SQLQuery.FieldByName('S_StockNo').AsString+'.'+SQLQuery.FieldByName('S_StockName').AsString;
    nParam.FParamD := SQLQuery.FieldByName('S_Value').AsString;
    nParam.FParamE := SQLQuery.FieldByName('S_ProhibitCreateBill').AsString;
    ///  是否禁止未设置供应计划客户开单
  end
  else
  begin
    nParam.FParamA := 'Customer';
    nParam.FParamB := SQLNo1.FieldByName('R_ID').AsString;
    nParam.FParamC := SQLNo1.FieldByName('C_StockNo').AsString+'.'+SQLNo1.FieldByName('C_StockName').AsString;
    nStr:= SQLNo1.FieldByName('C_SManNo').AsString+'@';
    nParam.FParamD := nStr + SQLNo1.FieldByName('C_CusNo').AsString+'.'+SQLNo1.FieldByName('C_CusName').AsString;
    nParam.FParamE := SQLNo1.FieldByName('C_MaxValue').AsString;
  end;

  CreateBaseFormItem(cFI_FormBillSalePlan, PopedomItem, @nParam);
  if (nParam.FCommand = cCmd_ModalResult) then
  begin
    BtnRefresh.Click;
  end;
end;

procedure TfFrameBillSalePlan.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxGrid1.ActiveLevel = cxLevel1 then
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要操作的记录', sHint); Exit;
  end;

  if cxGrid1.ActiveLevel = cxLevel2 then
  if cxView2.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要操作的记录', sHint); Exit;
  end;

  if not QueryDlg('确定要删除该供应设置么', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    if cxGrid1.ActiveLevel = cxLevel1 then
    begin
      nStr := SQLQuery.FieldByName('R_ID').AsString;
      nSQL := 'Delete From %s Where R_ID=''%s''';
      nSQL := Format(nSQL, [sTable_SalePlanStock, nStr]);
    end
    else
    begin
      nStr := SQLNo1.FieldByName('R_ID').AsString;
      nSQL := 'Delete From %s Where R_ID=''%s''';
      nSQL := Format(nSQL, [sTable_SalePlanCustomer, nStr]);
    end;

    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    BtnRefresh.Click;
    ShowMsg('已成功删除记录', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除记录失败', '未知错误');
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBillSalePlan, TfFrameBillSalePlan.FrameID);
end.
