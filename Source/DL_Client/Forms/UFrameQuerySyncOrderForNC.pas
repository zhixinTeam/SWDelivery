unit UFrameQuerySyncOrderForNC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, StdCtrls,
  cxRadioGroup, dxLayoutControl, ADODB, cxLabel, UBitmapPanel, cxSplitter,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, IniFiles,
  cxGridTableView, cxGridDBTableView, cxGrid, ComCtrls, ToolWin,
  cxTextEdit, cxMaskEdit, cxButtonEdit, Menus, cxButtons;

type
  TfFrameQuerySyncOrderForNC = class(TfFrameNormal)
    dxLayout1Item1: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item2: TdxLayoutItem;
    Radio1: TcxRadioButton;
    dxLayout1Item3: TdxLayoutItem;
    Radio2: TcxRadioButton;
    dxLayout1Item4: TdxLayoutItem;
    Radio3: TcxRadioButton;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    btn1: TcxButton;
    dxlytmLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Radio1Click(Sender: TObject);
    procedure Radio3Click(Sender: TObject);
    procedure mniN1Click(Sender: TObject);
    procedure EditCustomerPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure btn1Click(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
    FStart, FEnd: TDate;
    FTimeS, FTimeE: TDate;
    //时间区间
    FJBWhere, FBillOutTime, FOrderOutTime, FBillCus, FOrderCus: string;
  private
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    procedure GetDate;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameQuerySyncOrderForNC: TfFrameQuerySyncOrderForNC;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness, UFormBase,
  UBusinessConst, USysConst, USysDB, UDataModule;

class function TfFrameQuerySyncOrderForNC.FrameID: integer;
begin
  Result := cFI_FrameSyncOrderForNC;
end;

procedure TfFrameQuerySyncOrderForNC.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  if (not gSysParam.FIsAdmin) then
  begin
    btn1.Visible:= False;
    BtnDel.Visible:= False;
  end;

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameQuerySyncOrderForNC.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameQuerySyncOrderForNC.OnLoadGridConfig(const nIni: TIniFile);
var i,nCount: Integer;
begin               {
  with cxView1.DataController.Summary do
  begin
    nCount := FooterSummaryItems.Count - 1;
    for i:=0 to nCount do
      FooterSummaryItems[i].OnGetText := SummaryItemsGetText;
    //绑定事件

    nCount := DefaultGroupSummaryItems.Count - 1;
    for i:=0 to nCount do
      DefaultGroupSummaryItems[i].OnGetText := SummaryItemsGetText;
    //绑定事件
  end;              }

  inherited;
end;

//------------------------------------------------------------------------------
function TfFrameQuerySyncOrderForNC.InitFormDataSQL(const nWhere: string): string;
const nFields1 = ' x.R_ID, N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum, N_ErrorMsg, L_CusID CusId,'+
                       'L_CusName CusName, L_OutFact OutFact, L_Value Value, L_Truck ';
      nFields2 = ' x.R_ID, N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum, N_ErrorMsg, D_ProID CusId, '+
                       'D_ProName CusName, D_OutFact OutFact, D_Value Value, D_Truck ';
var nStr, nWherex, nTableName : string;
begin
  FEnableBackDB := True;
  nTableName:= sTable_UPLoadOrderNc;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select $Field1 From $UPLoadOrderNc x ' +
            'Left Join $Bill On L_ID=N_OrderNo ' +
            'Where N_Type=''S'' And $where $W1 $BCus ' +
            'Union   ' +
            'Select $Field2 From $UPLoadOrderNc x ' +
            'Left Join $OrderDtl On D_ID=N_OrderNo ' +
            'Where N_Type=''P'' And $where $W2 $OrderCus ';

  if Trim(EditCustomer.Text)<>'' then
  begin
    FBillCus := Format(' And (L_CusPY like ''%%%s%%'' or N_OrderNo = ''%s'')', [Trim(EditCustomer.Text), Trim(EditCustomer.Text)]);
    FOrderCus:= Format(' And (D_ProName like ''%%%s%%'' or N_OrderNo = ''%s'')', [Trim(EditCustomer.Text), Trim(EditCustomer.Text)]);
  end
  else
  begin
    FBillCus := '';
    FOrderCus:= '';
  end;

  if Radio1.Checked then
  begin
    nWherex := ' N_Status= -1 ';
    //xxxxx
  end
  else if Radio2.Checked then
  begin
    nWherex := ' N_Status= 1 ';
    //xxxxx
  end
  else
  begin
    nTableName:= sTable_UPLoadOrderNcHistory;
    nWherex := ' N_Status= 0 ';
    //xxxxx
  end;

  Result := MacroValue(Result, [MI('$UPLoadOrderNc', nTableName),
                                MI('$Bill', sTable_Bill), MI('$Field1', nFields1),
                                MI('$Field2', nFields2),
                                MI('$W1', FBillOutTime),MI('$W2', FOrderOutTime),
                                MI('$BCus', FBillCus),MI('$OrderCus', FOrderCus),
                                MI('$OrderDtl', sTable_OrderDtl),
                                MI('$where', nWherex)] );
  Result:= Result + nWhere;
  //xxxxx
end;                               

procedure TfFrameQuerySyncOrderForNC.GetDate;
var nS, nE : string;
begin
  nS := FormatDateTime('yyyy-MM-dd HH:mm:ss', FStart);
  nE := FormatDateTime('yyyy-MM-dd HH:mm:ss', FEnd + 1);

  FBillOutTime := Format(' And (L_OutFact>=''%s'' And L_OutFact<''%s'')', [nS, nE]);
  FOrderOutTime := Format(' And (D_OutFact>=''%s'' And D_OutFact<''%s'')', [nS, nE]);
end;

procedure TfFrameQuerySyncOrderForNC.EditDatePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nS, nE : string;
begin
  if ShowDateFilterForm(FStart, FEnd) then
  begin
    GetDate;
    InitFormData('');
  end;
end;

procedure TfFrameQuerySyncOrderForNC.Radio1Click(Sender: TObject);
begin
  FBillOutTime:= ''; FOrderOutTime:= ''; cxGrid1.PopupMenu:= pmPMenu1;
  InitFormData(FWhere);
end;

procedure TfFrameQuerySyncOrderForNC.Radio3Click(Sender: TObject);
begin
  GetDate; cxGrid1.PopupMenu:= nil;
  InitFormData(FWhere);
end;

procedure TfFrameQuerySyncOrderForNC.mniN1Click(Sender: TObject);
var nRId, nStr: string;
    nIdx : Integer;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRId:= SQLQuery.FieldByName('R_Id').AsString;

    nStr := 'UPDate %s Set N_Status=-1, N_SyncNum=0  Where R_ID=''%s''';
    nStr := Format(nStr, [sTable_UPLoadOrderNc, nRId]);
    FDM.ExecuteSQL(nStr);

    nStr:= Format('%s 设置单据 %s 再次上传NC', [gSysParam.FUserName, nRId]);
    FDM.WriteSysLog(sFlag_BillItem, '', nStr, False);
    ShowMsg('已设置成功、稍后将再次上传NC', sHint);
    BtnRefresh.Click;
  end;
end;

procedure TfFrameQuerySyncOrderForNC.EditCustomerPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    InitFormData(FWhere);
  end;
end;

procedure TfFrameQuerySyncOrderForNC.btn1Click(Sender: TObject);
var nStr : string;
    nReStatus:Boolean;
begin
  nReStatus:= False;
  if not QueryDlg('确认要进入离线模式么（离线模式将暂停上传采购、销售出厂单到NC系统）?', sAsk) then Exit;
  try
    nReStatus:= ChkNcStatus('', nStr);
  except
  end;
  if Not nReStatus then
  begin
    ShowMessage('将进入离线模式、离线模式下【发货量、发货时长将会有所限制】');

    nStr := 'UPDate Sys_Dict Set D_Value=''OffLine'', D_ParamB=Convert(Varchar(19),GetDate(),121) '+
            'Where D_Memo=''NCServiceStatus'' And D_Name=''SysParam'' ';
    FDM.ExecuteSQL(nStr);

    nStr := '切换系统进入离线模式 [ %s ].';
    nStr := Format(nStr, [FormatDateTime('yyyy-MM-dd HH:mm:ss', Now)]);
    FDM.WriteSysLog('SysItemsInfo', FormatDateTime('yyyy-MM-dd HH:mm:ss', Now), nStr, False);
  end
  else ShowMessage('当前连接NC系统正常、不能进入离线模式');
end;

procedure TfFrameQuerySyncOrderForNC.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('N_OrderNo').AsString;
    nStr := Format('确定要删除该同步记录么[ %s ]吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_UPLoadOrderNc, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameQuerySyncOrderForNC, TfFrameQuerySyncOrderForNC.FrameID);

end.
