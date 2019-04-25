{*******************************************************************************
  ����: dmzn@163.com 2009-7-22
  ����: �泵�����鵥
*******************************************************************************}
unit UFrameHYData_Each;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, UFrameNormal, UDataModule, UFormBase, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, Menus, dxLayoutControl, cxTextEdit, cxMaskEdit,
  cxButtonEdit, ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinscxPCPainter, dxSkinsdxLCPainter;

type
  TfFrameHYData_Each = class(TfFrameNormal)
    EditDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    cxLevel2: TcxGridLevel;
    cxView2: TcxGridDBTableView;
    QueryNo: TADOQuery;
    DataSource2: TDataSource;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditStock: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
    procedure cxView2DblClick(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //ʱ������
    FLoadNo: Boolean;
    FWhereHas,FWhereNo: string;
    //��ѯ����
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    {*���ຯ��*}
    procedure AfterInitFormData; override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); override;
    {*��������*}
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    procedure OnSaveGridConfig(const nIni: TIniFile); override;
    {*�������*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, USysFun, USysConst, USysDB, USysDataDict, USysGrid, UMgrControl,
  USysBusiness, UFormDateFilter;

class function TfFrameHYData_Each.FrameID: integer;
begin
  Result := cFI_FrameStockHY_Each;
end;

procedure TfFrameHYData_Each.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameHYData_Each.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameHYData_Each.OnLoadGridConfig(const nIni: TIniFile);
begin
  inherited;
  if BtnAdd.Enabled then
       BtnAdd.Tag := 10
  else BtnAdd.Tag := 0;

  if BtnEdit.Enabled then
       BtnEdit.Tag := 10
  else BtnEdit.Tag := 0;

  if BtnDel.Enabled then
       BtnDel.Tag := 10
  else BtnDel.Tag := 0;

  FWhereNo := '';
  FWhereHas := '';
  FLoadNo := True;

  cxGrid1.ActiveLevel := cxLevel1;
  gSysEntityManager.BuildViewColumn(cxView2, 'NO_HUAYAN');
  InitTableView(Name, cxView2, nIni);
end;

procedure TfFrameHYData_Each.OnSaveGridConfig(const nIni: TIniFile);
begin
  inherited;
  SaveUserDefineTableView(Name, cxView2, nIni);
end;

//Desc: �������ݵ�����
procedure TfFrameHYData_Each.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr,nSQL: string;
begin
  nDefault := False;
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  nSQL := 'Select C_Name,C_PY,L_Stock,E_HyNo,Sum(E_Value) as E_Values From %s te ' +
          ' Left Join %s b On b.L_ID=te.E_Bill ' +
          ' Left Join %s cus On cus.C_ID=b.L_Custom ' +
          'Where E_HyNo Is Not Null Group By C_Name,C_PY,L_Stock,E_HyNo';
  nSQL := Format(nSQL, [sTable_TruckLogExt, sTable_Bill, sTable_Customer]);

  nStr := 'Select b.*,hy.* From ($Bill) b ' +
          ' Left Join $HY hy On hy.H_No=b.E_HyNo';
  //xxxxx

  if FWhereHas = '' then
       nStr := nStr + ' Where (H_ReportDate>=''$Start'' and H_ReportDate<''$End'')'
  else nStr := nStr + ' Where (' + FWhereHas + ')';

  nSQL := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan), MI('$Bill', nSQL),
          MI('$Start', Date2Str(FStart)), MI('$End', Date2Str(FEnd+1)));
  FDM.QueryData(SQLQuery, nSQL);

  //--------------------------------------------------------------------------
  if not FLoadNo then Exit;
  //��ˢ��δ��

  nStr := 'Select te.*,C_Name,C_PY,T_BFMTime From $TE te ' +
          ' Left Join $Bill b On b.L_ID=te.E_Bill '+
          ' Left Join $Cus cus On cus.C_ID=b.L_Custom ' +
          ' Left Join $TL tl On tl.T_ID=te.E_TID ' +
          'Where E_HyNo Is Null and E_HyID Is Null';
  //xxxxx

  if FWhereNo = '' then
       nStr := nStr + ' And (T_BFMTime>=''$Start'' and T_BFMTime<''$End'')'
  else nStr := nStr + ' And (' + FWhereHas + ')';

  nSQL := MacroValue(nStr, [MI('$TE', sTable_TruckLogExt), MI('$Bill', sTable_Bill),
          MI('$Cus', sTable_Customer), MI('$TL', sTable_TruckLog),
          MI('$Start', Date2Str(FStart)), MI('$End', Date2Str(FEnd+1))]);
  FDM.QueryData(QueryNo, nSQL);
end;

procedure TfFrameHYData_Each.AfterInitFormData;
begin
  FLoadNo := True;
  cxGrid1ActiveTabChanged(nil, nil);
end;

//Desc: ���ư�ť
procedure TfFrameHYData_Each.cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
  ALevel: TcxGridLevel);
begin
  if gSysParam.FIsAdmin or (BtnDel.Tag > 0) then
    BtnDel.Enabled := (cxGrid1.ActiveView = cxView1) and SQLQuery.Active;
end;

//------------------------------------------------------------------------------
//Desc: ˢ��
procedure TfFrameHYData_Each.BtnRefreshClick(Sender: TObject);
begin
  FWhereHas := '';
  FWhereNo := '';

  FLoadNo := True;
  InitFormData();
end;

//Desc: ���
procedure TfFrameHYData_Each.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FParamA := '';
  nP.FParamB := '';
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormStockHY_Each, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData;
  end;
end;

//Desc: ɾ��
procedure TfFrameHYData_Each.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('H_ID').AsString;
  if not QueryDlg('ȷ��Ҫɾ�����Ϊ[ ' + nStr + ' ]�Ļ��鵥��', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'Delete From %s Where H_ID=%s';
    nSQL := Format(nSQL, [sTable_StockHuaYan, nStr]);
    FDM.ExecuteSQL(nSQL);

    nStr := SQLQuery.FieldByName('H_No').AsString;
    nSQL := 'Update %s Set E_HyID=null,E_HYNo=null Where E_HYNo=''%s''';
    nSQL := Format(nSQL, [sTable_TruckLogExt, nStr]);
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    InitFormData();
    ShowMsg('��¼�ѳɹ�ɾ��', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('�����¼ɾ��ʧ��', sError);
  end;
end;

//Desc: ����ɸѡ
procedure TfFrameHYData_Each.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then BtnRefreshClick(nil);
end;

//Desc: ��ѯ
procedure TfFrameHYData_Each.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhereHas := 'H_ID=' + EditID.Text;
    FLoadNo := False;
    InitFormData();
  end else

  if Sender = EditStock then
  begin
    EditStock.Text := Trim(EditStock.Text);
    if EditStock.Text = '' then Exit;

    FWhereHas := Format('H_SerialNo Like ''%%%s%%''', [EditStock.Text]);
    FLoadNo := False;
    InitFormData();
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhereHas := 'C_Name like ''%%%s%%'' Or C_PY Like ''%%%s%%''';
    FWhereHas := Format(FWhereHas, [EditCustomer.Text, EditCustomer.Text]);
    FWhereNo := FWhereHas;
    InitFormData();
  end;
end;

//Desc: ����
procedure TfFrameHYData_Each.cxView2DblClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView2.DataController.GetSelectedCount > 0 then
  begin
    nP.FParamA := QueryNo.FieldByName('E_ZID').AsString;
    nP.FParamB := QueryNo.FieldByName('E_TID').AsString;
  end else Exit;

  if not BtnAdd.Enabled then Exit;
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormStockHY_Each, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ݲ˵�
procedure TfFrameHYData_Each.PMenu1Popup(Sender: TObject);
begin
  N1.Enabled := cxView1.DataController.GetSelectedCount > 0;
  N2.Enabled := N1.Enabled;
end;

//Desc: ���鵥
procedure TfFrameHYData_Each.N1Click(Sender: TObject);
var nStr: string;
begin
  nStr := SQLQuery.FieldByName('H_No').AsString;
  nStr := Format('''%s''', [nStr]);
  PrintHuaYanReport_Each(nStr, False);
end;

//Desc: �ϸ�֤
procedure TfFrameHYData_Each.N2Click(Sender: TObject);
var nStr: string;
begin
  nStr := SQLQuery.FieldByName('H_No').AsString;
  nStr := Format('''%s''', [nStr]);
  PrintHeGeReport_Each(nStr, False);
end;

initialization
  gControlManager.RegCtrl(TfFrameHYData_Each, TfFrameHYData_Each.FrameID);
end.
