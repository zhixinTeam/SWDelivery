unit UFrameQueryOrderHD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels, StdCtrls,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  dxLayoutControl, cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, ComCtrls, ToolWin, Menus;

type
  TfFrameQueryOrderHD = class(TfFrameNormal)
    cxView_Mx: TcxGridDBTableView;
    dxlytm_1: TdxLayoutItem;
    Edt_Customer: TcxButtonEdit;
    dxlytm_2: TdxLayoutItem;
    Edt_Stock: TcxButtonEdit;
    dxlytm_Date: TdxLayoutItem;
    Edt_Date: TcxButtonEdit;
    pmPMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    procedure Edt_EditCustomerPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Edt_DatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxView1CustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo;
      var ADone: Boolean);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Edt_CustomerKeyPress(Sender: TObject; var Key: Char);
    procedure Edt_StockKeyPress(Sender: TObject; var Key: Char);
    procedure ToolBar1Click(Sender: TObject);
  private
    { Private declarations }
    nScrPos, nTopPos:Integer;
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //条件
    FLastRecID : string;
  private
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;

    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
    procedure AfterInitFormData; override;
    procedure UPDateAdoData(nMark:string);
  public
    { Public declarations }
    class function FrameID: integer; override;  end;

var
  fFrameQueryOrderHD: TfFrameQueryOrderHD;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness, UFormBase,
  UBusinessConst, USysConst, USysDB, UDataModule;

class function TfFrameQueryOrderHD.FrameID: integer;
begin
  Result := cFI_FrameOrderDtlHDQuery;
end;

procedure TfFrameQueryOrderHD.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameQueryOrderHD.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameQueryOrderHD.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  //*************
  Edt_Date.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := ' Select od.R_Id, D_ID, O_BID, O_Truck, D_OID, D_MValue, D_PValue, D_KZValue,(D_MValue-D_PValue-ISNULL(D_KZValue, 0)) as D_NetWeight, '+
                  'DATEPART(DAY, D_OutFact) DayD, CONVERT(varchar(11), D_OutFact, 120) Day, D_IsMark, * '+
            ' From $OrderDtl od Inner Join $Order oo on od.D_OID=oo.O_ID ';

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (D_OutFact>=''$S'' and D_OutFact <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;
  //Result := Result + ' Group  By DATEPART(DAY, D_OutFact) Order By DATEPART(DAY, D_OutFact) ';
  Result := Result + '  Order  by DayD, D_ID ';

  Result := MacroValue(Result, [MI('$OrderDtl', sTable_OrderDtl),
                                MI('$Order', sTable_Order),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

procedure TfFrameQueryOrderHD.AfterInitFormData;
begin            
  //cxView1.Controller.Scroll(sbVertical, scTrack, nScrPos);
  cxView1.Controller.TopRowIndex:= nTopPos;
  cxView1.Controller.FocusedRowIndex:= nScrPos ;
end;

procedure TfFrameQueryOrderHD.Edt_EditCustomerPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nStr:string;
begin
  FWhere:= '1=1';
  begin
    Edt_Customer.Text := Trim(Edt_Customer.Text);
    if Edt_Customer.Text = '' then Exit;

    nStr:= 'D_ProName = ''%s''';
    FWhere:= FWhere+' And '+ Format(nStr, [Edt_Customer.Text]);
  end;

  begin
    Edt_Stock.Text := Trim(Edt_Stock.Text);
    if Edt_Stock.Text = '' then Exit;

    nStr := 'D_StockName = ''%s''';
    FWhere:= FWhere+' And '+ Format(nStr, [Edt_Stock.Text]);
  end;
  InitFormData(FWhere);
end;

procedure TfFrameQueryOrderHD.Edt_DatePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

procedure TfFrameQueryOrderHD.cxView1CustomDrawCell(
  Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
// if (trim(AViewInfo.RecordViewInfo.GridRecord.Values[4]) = 'HTT')
//    and (AViewInfo.Item.ID = 4) //确定到某一列，如果不加确定是某行底色

  if (AViewInfo.GridRecord.Values[TcxGridDBTableView(Sender).GetColumnByFieldName('D_IsMark').Index])='1' then
      ACanvas.Canvas.Font.Color := $C0C0C0;
end;

procedure TfFrameQueryOrderHD.UPDateAdoData(nMark:string);
begin
end;

procedure TfFrameQueryOrderHD.N1Click(Sender: TObject);
var nRId, nStr: string;
    nIdx : Integer;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRId := SQLQuery.FieldByName('R_Id').AsString;
    FLastRecID:= SQLQuery.FieldByName('D_ID').AsString;
    nScrPos:= cxView1.Controller.FocusedRowIndex;
    nTopPos:= cxView1.Controller.TopRowIndex;

    nStr := 'UPDate %s Set D_IsMark=1, D_HDMan=''%s''  Where R_ID=''%s''';
    nStr := Format(nStr, [sTable_OrderDtl, gSysParam.FUserName, nRId]);

    FDM.ExecuteSQL(nStr);

    nStr:= Format('%s 设置采购单标记为  已核对 ', [gSysParam.FUserName]);
    FDM.WriteSysLog(sFlag_BillItem, '', nStr, False);
    ShowMsg('已设置成功、【已核对】', sHint);
    BtnRefresh.Click;
  end;
end;

procedure TfFrameQueryOrderHD.N2Click(Sender: TObject);
var nRId, nHDMan, nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRId  := SQLQuery.FieldByName('R_Id').AsString;
    nHDMan:= SQLQuery.FieldByName('D_HDMan').AsString;

    FLastRecID:= SQLQuery.FieldByName('D_ID').AsString;
    nScrPos:= cxView1.Controller.FocusedRowIndex;
    nTopPos:= cxView1.Controller.TopRowIndex;
    //***************************
    if nHDMan=gSysParam.FUserName then
    begin
      nStr := 'UPDate %s Set D_IsMark=0 Where R_ID=''%s''';
      nStr := Format(nStr, [sTable_OrderDtl, nRId]);

      FDM.ExecuteSQL(nStr);            

      nStr:= Format('%s 设置采购单标记为  取消已核对 ', [gSysParam.FUserName]);
      FDM.WriteSysLog(sFlag_BillItem, '', nStr, False);
      ShowMsg('已设置成功、 【取消已核对】', sHint);
      BtnRefresh.Click;
    end
    else ShowMsg('该订单非 您审核、您无权取消', sHint);
  end;
end;

procedure TfFrameQueryOrderHD.Edt_CustomerKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  if (Sender = Edt_Customer) then
  begin
    if (Key = Char(VK_SPACE)) then
    begin
      Key := #0;
      nP.FParamA := Edt_Customer.Text;
      CreateBaseFormItem(cFI_FormGetProvider, '', @nP);

      if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
        Edt_Customer.Text := nP.FParamC;
      Edt_Customer.SelectAll;
    end
    else if (Key = Char(VK_RETURN)) then
    begin
      Edt_EditCustomerPropertiesButtonClick(Self, 0);
    end;

  end;
end;

procedure TfFrameQueryOrderHD.Edt_StockKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  if (Sender = Edt_Stock) then
  begin
    if (Key = Char(VK_SPACE)) then
    begin
      Key := #0;
      nP.FParamA := Edt_Stock.Text;
      CreateBaseFormItem(cFI_FormGetMeterail, '', @nP);

      if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
        Edt_Stock.Text := nP.FParamC;
      Edt_Stock.SelectAll;
    end
    else if (Key = Char(VK_RETURN)) then
    begin
      Edt_EditCustomerPropertiesButtonClick(Self, 0);
    end;

  end;
end;

procedure TfFrameQueryOrderHD.ToolBar1Click(Sender: TObject);
var nxxx: Integer;
begin
  nxxx:= 300;
  //cxView1.Controller.Scroll(sbVertical, scTrack, nxxx);
  //cxView1.Controller.ScrollBarPos;
end;

initialization
  gControlManager.RegCtrl(TfFrameQueryOrderHD, TfFrameQueryOrderHD.FrameID);

end.
