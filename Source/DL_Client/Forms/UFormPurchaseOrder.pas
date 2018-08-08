{*******************************************************************************
  作者: fendou116688@163.com 2015/9/19
  描述: 办理采购订单绑定磁卡
*******************************************************************************}
unit UFormPurchaseOrder;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel,
  dxSkinsCore, dxSkinsDefaultPainters, dxSkinsdxLCPainter;

type
  TfFormPurchaseOrder = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditMate: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditProvider: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxGroupLayout1Group2: TdxLayoutGroup;
    EditSalesMan: TcxTextEdit;
    dxlytmLayout1Item6: TdxLayoutItem;
    EditProject: TcxTextEdit;
    dxlytmLayout1Item7: TdxLayoutItem;
    EditArea: TcxTextEdit;
    dxlytmLayout1Item8: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    EditCardType: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    dxlytmLayout1Item61: TdxLayoutItem;
    Edt_PValue: TcxTextEdit;
    dxlytmLayout1Item62: TdxLayoutItem;
    Edt_MValue: TcxTextEdit;
    dxlytmLayout1Item63: TdxLayoutItem;
    Edt_MMan: TcxTextEdit;
    dxlytmLayout1Item64: TdxLayoutItem;
    Edt_PMan: TcxTextEdit;
    dxlytmLayout1Item65: TdxLayoutItem;
    Edt_Man: TcxTextEdit;
    dxlytmYSJZ: TdxLayoutItem;
    edt_YsJz: TcxTextEdit;
    dxlytgrpYSJZ: TdxLayoutGroup;
    dxlytmHYJz: TdxLayoutItem;
    cxlbl1: TcxLabel;
    dxlytgrphyjz: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Edt_PValueKeyPress(Sender: TObject; var Key: Char);
  protected
    { Protected declarations }
    FCardData, FListA: TStrings;
    //卡片数据
    FNewBillID: string;
    //新提单号
    FBuDanFlag: string;
    //补单标记
    procedure InitFormData;
    //初始化界面
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker, UFormCtrl,
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst;

var
  gForm: TfFormPurchaseOrder = nil;
  //全局使用

class function TfFormPurchaseOrder.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr: string;
    nP: PFormCommandParam;
    nBuDan : Boolean;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  nBuDan := nPopedom = 'MAIN_MF05';
  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  try
    CreateBaseFormItem(cFI_FormGetPOrderBase, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormPurchaseOrder.Create(Application) do
  try
    if nBuDan then //补单
    begin
      FBuDanFlag := sFlag_Yes;
      Height:= 455;                Caption := '采购补单';
    end
    else
    begin
      FBuDanFlag := sFlag_No;      Caption := '开采购单';
      Height:= 370;
      dxlytmLayout1Item61.Visible:= False; dxlytmLayout1Item62.Visible:= False; dxlytmLayout1Item63.Visible:= False;
      dxlytmLayout1Item64.Visible:= False; dxlytmLayout1Item65.Visible:= False;
    end;

    ActiveControl := EditTruck;

    FCardData.Text := PackerDecodeStr(nStr);
    InitFormData;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := FNewBillID
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPurchaseOrder.FormID: integer;
begin
  Result := cFI_FormOrder;
end;

procedure TfFormPurchaseOrder.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  FCardData := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormPurchaseOrder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FListA.Free;
  FCardData.Free;
end;

//Desc: 回车键
procedure TfFormPurchaseOrder.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditValue then
         BtnOK.Click
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

procedure TfFormPurchaseOrder.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

//------------------------------------------------------------------------------
procedure TfFormPurchaseOrder.InitFormData;
begin
  with FCardData do
  begin
    EditID.Text       := Values['SQ_ID'];
    EditProvider.Text := Values['SQ_ProName'];
    EditMate.Text     := Values['SQ_StockName'];
    EditSalesMan.Text := Values['SQ_SaleName'];
    EditArea.Text     := Values['SQ_Area'];
    EditProject.Text  := Values['SQ_Project'];
    //EditValue.Text    := Values['SQ_RestValue'];
    EditValue.Text    := '0.00';
  end;
end;

function TfFormPurchaseOrder.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True);
    nHint := '请填写有效的办理量';
    if not Result then Exit;

    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, StrToFloat(FCardData.Values['SQ_RestValue']),
              rtLE);
    nHint := '已超出可提货量';
  end;
end;

//Desc: 保存
procedure TfFormPurchaseOrder.BtnOKClick(Sender: TObject);
var nOrder, nCardType, nSQL: string;
begin
  if not IsDataValid then Exit;
  //check valid

  if FBuDanFlag=sflag_yes then
  begin
    if (StrToFloatDef(Trim((Edt_PValue.Text)), 0)<=0)or(StrToFloatDef(Trim((Edt_MValue.Text)), 0)<=0) then
    begin
      ShowMsg('请认真输入皮、毛重量数据', sHint);
      Exit;
    end;
  end;

  {$IFDEF PurchaseOrderChkJingZhong}
  IF (StrToFloatDef(Trim((edt_YsJz.Text)), 0)<=0) then
  begin
    ShowMsg('请输入原始净重、才能开单', sHint);
    Exit;
  end;
  {$ENDIF}

  with FListA do
  begin
    Clear;
    Values['SQID']          := FCardData.Values['SQ_ID'];

    Values['Area']          := FCardData.Values['SQ_Area'];
    Values['Truck']         := Trim(EditTruck.Text);
    Values['Project']       := FCardData.Values['SQ_Project'];

    nCardType               := GetCtrlData(EditCardType);
    Values['CardType']      := nCardType;

    Values['SaleID']        := FCardData.Values['SQ_SaleID'];
    Values['SaleMan']       := FCardData.Values['SQ_SaleName'];

    Values['ProviderID']    := FCardData.Values['SQ_ProID'];
    Values['ProviderName']  := FCardData.Values['SQ_ProName'];

    Values['StockNO']       := FCardData.Values['SQ_StockNo'];
    Values['StockName']     := FCardData.Values['SQ_StockName'];

    Values['BuDan'] := FBuDanFlag;

    if nCardType='L' then
          Values['Value']   := EditValue.Text
    else  Values['Value']   := '0.00';

    Values['YJZValue'] := edt_YsJz.Text;     // 原始净重
    //*******
    if FBuDanFlag=sflag_yes then
    begin
      Values['Man']    := Edt_Man.Text;
      Values['MMan']   := Edt_MMan.Text;
      Values['PMan']   := Edt_PMan.Text;
      Values['MValue'] := Edt_MValue.Text;
      Values['PValue'] := Edt_PValue.Text;
    end;
  end;

  nOrder := SaveOrder(PackerEncodeStr(FListA.Text));
  if nOrder='' then Exit;

  if nCardType = 'L' then
    PrintRCOrderReport(nOrder, True);
  //临时卡提示打印入厂  

  nSQL := MakeSQLByStr([
              SF('O_YJZValue', edt_YsJz.Text)
              ], sTable_Order, SF('O_ID', nOrder), False);
  FDM.ExecuteSQL(nSQL);
  // 更新原始净重

  if (FBuDanFlag <> sFlag_Yes) then
    SetOrderCard(nOrder, FListA.Values['Truck'], True);
  //办理磁卡

  if (FBuDanFlag <> sFlag_Yes) then
    ModalResult := mrOK;
  ShowMsg('采购订单保存成功', sHint);
end;

procedure TfFormPurchaseOrder.Edt_PValueKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in [#8, #13, #127, '.', '0'..'9', #22, #17]) then
    Key := #0;
end;

initialization
  gControlManager.RegCtrl(TfFormPurchaseOrder, TfFormPurchaseOrder.FormID);
end.
