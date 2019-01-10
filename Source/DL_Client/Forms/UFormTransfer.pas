{*******************************************************************************
作者: fendou116688@163.com 2016/2/26
描述: 短倒业务办理磁卡
*******************************************************************************}
unit UFormTransfer;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxButtonEdit, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinsdxLCPainter;

type
  TfFormTransfer = class(TfFormNormal)
    EditMate: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditMID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditDC: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    EditDR: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    chk1: TCheckBox;
    chk2: TCheckBox;
    dxlytmLayout1Item10: TdxLayoutItem;
    cbbDstAddr: TcxComboBox;
    dxlytmLayout1Item101: TdxLayoutItem;
    cbbSrcAddr: TcxComboBox;
    chk3: TCheckBox;
    dxlytmLayout1Item6: TdxLayoutItem;
    Edt_Num: TcxTextEdit;
    procedure BtnOKClick(Sender: TObject);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure EditDCPropertiesChange(Sender: TObject);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure chk3Click(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormCtrl, UBusinessPacker,
  USysDB, USysConst, UAdjustForm, USysBusiness;

type
  TMateItem = record
    FID   : string;
    FName : string;
  end;

var
  gMateItems: array of TMateItem;
  //品种列表

class function TfFormTransfer.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
    nP := nParam
  else New(nP);

  with TfFormTransfer.Create(Application) do
  try
    InitFormData;
    cbbSrcAddr.Properties.Items.Clear;;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTransfer.FormID: integer;
begin
  Result := cFI_FormTransBase;
end;

procedure TfFormTransfer.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nList: TStrings;
    KDValue : Double;
    nP: TFormCommandParam;
    nStr, nStock, nStockName, nSql : string;
begin
  if (Trim(EditTruck.Text)='')or(Trim(EditMID.Text)='')or(Trim(EditMate.Text)='')  then
  begin
    ShowMsg('短倒单据信息填写不完整，请认真填写后操作', sHint);
    Exit;
  end;
//  if chk3.Checked and chk2.Checked then
//  begin
//    ShowMsg('厂内短倒不能为销售类型，请认真填写后操作', sHint);
//    Exit;
//  end;
//  if chk3.Checked and chk1.Checked And not chk2.Checked then
//  begin
//    ShowMsg('非厂内短倒销售类型，不能为固定卡, 请认真填写后操作', sHint);
//    Exit;
//  end;
  if chk3.Checked then
  begin
    nStr:= 'Select * From S_ZTLines Where Z_Stock ='''+Trim(EditMate.Text)+'''';

    with FDM.QueryTemp(nStr) do
    begin
      if Active then
      if RecordCount=0 then
      begin
        ShowMsg('该物料暂未设置放料装车线、请重新选择 ', sHint);
        Exit;
      end;
    end;

    KDValue:= StrToFloatDef(Trim(Edt_Num.Text), -1);
    if (KDValue<=0) then
    begin
      ShowMsg('请填写放料吨数', sHint);
      Exit;
    end;
  end;

  if EditMID.ItemIndex >=0 then
  begin
    nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);
    nStock := gMateItems[nIdx].FID;
    nStockName := gMateItems[nIdx].FName;
  end  else
  begin
    nStock := Trim(EditMID.Text);
    nStockName := Trim(EditMate.Text);
  end;  

  nList := TStringList.Create;
  try
    with nList do
    begin
      Values['Truck'] := Trim(EditTruck.Text);
      Values['SrcAddr'] := Trim(cbbSrcAddr.Text);
      Values['DestAddr']  := Trim(cbbDstAddr.Text);
      Values['StockNo'] := nStock;
      Values['StockName'] := nStockName;
      Values['Value'] := FloatToStr(KDValue);

      if chk1.Checked then Values['CType'] := 'G'
      else Values['CType'] := 'L';

      if chk2.Checked then Values['IsNei'] := 'Y'
      else Values['IsNei'] := 'N';

      if chk3.Checked then Values['IsSale'] := 'Y'
      else Values['IsSale'] := 'N';
    end;

    nStr := SaveDDBases(PackerEncodeStr(nList.Text));
    //call mit bus
    if nStr = '' then Exit;

    {$IFDEF TransferRFID}
    nP.FParamA := Trim(EditTruck.Text);
    CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    SaveDDCard(nStr, 'H' + nP.FParamB);
    //电子标签前加一个H，用于远距离读卡控制
    {$ELSE}
    SetBillCard(nStr, EditTruck.Text, True, sFlag_DuanDao);
    //办理磁卡
    {$ENDIF}

    nSql:= ' UPDate P_TransBase Set B_PDate=T_PrePTime, B_PMan=T_PrePMan, B_PValue=T_PrePValue From S_Truck ' +
           ' Where B_Truck=T_Truck And T_PrePUse=''%s'' And B_ID=''%s''';
    nSql:= Format(nSql, [sFlag_Yes, nStr]);
    FDM.ExecuteSQL(nSql);
    // 更新Base表预置皮重车辆 皮重信息

    ModalResult := mrOk;
  finally
    FreeAndNil(nList);
  end;
end;

procedure TfFormTransfer.InitFormData;
var nStr: string;
    nInt, nIdx: Integer;
begin
  nStr :='Select D_ParamB M_ID, D_Value M_Name From %s Where D_ParamA=0.2 '+
         'Union '+
         'Select M_Id, M_Name From %s Where M_IsNei=''%s''';

  nStr := Format(nStr, [sTable_SysDict, sTable_Materails, sFlag_Yes]);

  EditMID.Properties.Items.Clear;
  SetLength(gMateItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gMateItems, RecordCount);

    nInt := 0;
    nIdx := 0;
    First;

    while not Eof do
    begin
      with gMateItems[nIdx] do
      begin
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        EditMID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;

    EditMID.ItemIndex := nInt;
    EditMate.Text := gMateItems[nInt].FName;
  end;

  nStr := 'A_PlaceId=Select A_PlaceId, A_PlaceName From %s Order BY R_ID DESC';
  nStr := Format(nStr, [sTable_AuxInfo]);
  FDM.FillStringsData(EditDC.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDC, False);

  FDM.FillStringsData(EditDR.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDR, False);
end;

procedure TfFormTransfer.EditMIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditMID.Focused) or (EditMID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);
  EditMate.Text := gMateItems[nIdx].FName;
end;

procedure TfFormTransfer.EditDCPropertiesChange(Sender: TObject);
var nStr: string;
    nCom: TcxComboBox;
begin
  nCom := Sender as TcxComboBox;
  nStr := nCom.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(nCom)) + 1);

  if Sender = EditDC then
    cbbSrcAddr.Text := nStr
  else if Sender = EditDR then
    cbbDstAddr.Text := nStr;
  //xxxxx
end;

procedure TfFormTransfer.EditTruckKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    Perform(WM_NEXTDLGCTL, 0, 0);
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

procedure TfFormTransfer.chk3Click(Sender: TObject);
begin
  dxlytmLayout1Item6.Visible:= chk3.Checked;
  Edt_Num.Visible:= chk3.Checked;
end;

initialization
  gControlManager.RegCtrl(TfFormTransfer, TfFormTransfer.FormID);
end.
