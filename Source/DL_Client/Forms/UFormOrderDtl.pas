{*******************************************************************************
作者: fendou116688@163.com 2016/10/31
描述: 采购明细管理
*******************************************************************************}
unit UFormOrderDtl;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, cxGraphics, cxControls, cxLookAndFeels, NativeXml,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutControl, cxCheckBox,
  cxLabel, StdCtrls, cxMaskEdit, cxDropDownEdit, cxMCListBox, cxMemo,
  cxTextEdit, cxButtonEdit, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter;

type
  TfFormOrderDtl = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditMemo: TcxMemo;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditPValue: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditMValue: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    EditProID: TcxButtonEdit;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditProName: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    EditStock: TcxButtonEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayoutControl1Item7: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    EditKZValue: TcxTextEdit;
    dxLayoutControl1Item12: TdxLayoutItem;
    EditCheck: TcxCheckBox;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxlytmLayoutControl1Item13: TdxLayoutItem;
    Edt_OrderBase: TcxButtonEdit;
    dxlytmLayoutControl1Item131: TdxLayoutItem;
    edt_YSR: TcxTextEdit;
    dxLayoutControl1Group6: TdxLayoutGroup;
    dxLayoutControl1Item13: TdxLayoutItem;
    UnPlace: TcxComboBox;
    dxLayoutControl1Item14: TdxLayoutItem;
    YSStatus: TcxComboBox;
    dxLayoutControl1Group7: TdxLayoutGroup;
    dxLayoutControl1Item15: TdxLayoutItem;
    UnType: TcxComboBox;
    dxLayoutControl1Group8: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditStockKeyPress(Sender: TObject; var Key: Char);
    procedure Edt_OrderBasePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FOrderID,FDetailID,FOldOrderBaseNo, FOldOrder, FNewOrder: string;
    //单据标识
    FOrderBase : TStrings;
    procedure InitFormData(const nID: string);
    //载入数据
    function SetData(Sender: TObject; const nData: string): Boolean;
    //数据相关
    function GetProPk(nProId : string): string;
    function GetMaterailPk(nMId : string): string;
    function GetOrderDtlInfo(nId : string): string;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UAdjustForm, USysBusiness,
  USysGrid, USysDB, USysConst, UBusinessPacker;

var
  gForm: TfFormOrderDtl = nil;
  //全局使用

class function TfFormOrderDtl.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
  
   cCmd_EditData:
    with TfFormOrderDtl.Create(Application) do
    begin
      FDetailID := nP.FParamA;
      FOrderID  := nP.FParamB;
      Caption := '采购过磅单 - 修改';

      InitFormData(FDetailID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;

   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormOrderDtl.Create(Application);
        with gForm do
        begin
          Caption := '采购过磅单 - 查看';
          FormStyle := fsStayOnTop;

          BtnOK.Visible := False;
        end;
      end;

      with gForm  do
      begin
        FDetailID := nP.FParamA;
        FOrderID  := nP.FParamB;
        InitFormData(FDetailID);
        if not Showing then Show;
      end;
    end;
    
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end; 
end;

class function TfFormOrderDtl.FormID: integer;
begin
  Result := cFI_FormOrderDtl;
end;

//------------------------------------------------------------------------------
function GetLeftStr(SubStr, Str: string): string;
begin
   Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
end;

function GetRightStr(SubStr, Str: string): string;
var
   i: integer;
begin
   i := pos(SubStr, Str);
   if i > 0 then
     Result := Copy(Str
       , i + Length(SubStr)
       , Length(Str) - i - Length(SubStr) + 1)
   else
     Result := '';
end;

procedure TfFormOrderDtl.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  FOrderBase := TStringList.Create;
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  ResetHintAllForm(Self, 'D', sTable_OrderDtl);
  //重置表名称
end;

procedure TfFormOrderDtl.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  gForm := nil;
  FOrderBase.Free;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormOrderDtl.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormOrderDtl.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 设置数据
function TfFormOrderDtl.SetData(Sender: TObject; const nData: string): Boolean;
begin
  Result := False;
end;

//Date: 2009-6-2
//Parm: 供应商编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormOrderDtl.InitFormData(const nID: string);
var nStr, nTem: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s ' +
            ' Left Join %s On D_OID=O_ID ' +
            'Where D_ID=''%s''';
    nStr := Format(nStr, [sTable_OrderDtl, sTable_Order, nID]);
    LoadDataToCtrl(FDM.QueryTemp(nStr), Self, '', SetData);
    FOldOrderBaseNo:= Edt_OrderBase.Text;
    FOldOrder:= Format('%s %s 皮重 %s 毛重 %s 扣杂 %s', [
             Edt_OrderBase.Text, EditTruck.Text, EditPValue.Text,EditMValue.Text, EditKZValue.Text]);
    IF EditKZValue.Text='' then EditKZValue.Text:= '0';
    with FDM.QueryTemp(nStr) do
    begin
      if FieldByName('D_YSResult').AsString='Y' then
        YSStatus.ItemIndex:= 0
      else YSStatus.ItemIndex:= 1;

      nTem:= FieldByName('D_UnloadPlace').AsString;
      UnPlace.ItemIndex:= UnPlace.Properties.Items.IndexOf(nTem);

      nTem:= FieldByName('D_UnloadType').AsString;
      UnType.ItemIndex:= UnType.Properties.Items.IndexOf(nTem);
    end;
  end;
end;

function TfFormOrderDtl.GetProPk(nProId : string): string;
var nStr : string;
begin
  Result:= '';

  nStr := 'Select * From %s Where P_ID=''%s'' ';
  nStr := Format(nStr, [sTable_Provider, nProId]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
      Result:= FieldByName('P_PKPro').AsString;
  end;
end;

function TfFormOrderDtl.GetMaterailPk(nMId : string): string;
var nStr : string;
begin
  Result:= '';

  nStr := 'Select * From %s Where M_ID=''%s'' ';
  nStr := Format(nStr, [sTable_Materails, nMId]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
      Result:= FieldByName('M_PK').AsString;
  end;
end;

function TfFormOrderDtl.GetOrderDtlInfo(nId : string): string;
var nStr, nProPk, nMtlPk, nBid, nBPKDtl, nProId, nStockID: string;
    FListB : TStrings;
begin
  Result:= '';  FListB:= TStringList.Create;
  ///*********************************************************************
  nStr := 'Select *, b.R_ID ORID From %s a Left Join %s b On B_ID=O_BID Left Join %s c On O_ID=D_OID ' + 'Where D_ID=''%s'' ';
  nStr := Format(nStr, [sTable_OrderBase, sTable_Order, sTable_OrderDtl, nId]);
  try
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then Exit;

      First;
      FListB.Clear;

      nBid := FieldByName('B_NCOrderNo').AsString;
      nBPKDtl := FieldByName('B_PKDtl').AsString;

      nProId  := FieldByName('B_ProID').AsString;
      nStockID:= FieldByName('B_StockNo').AsString;
      //***********
      FListB.Values['Proc'] := 'delete';
      FListB.Values['CreateTime'] := FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('O_Date').AsDateTime);
      FListB.Values['creator'] := FieldByName('O_Man').AsString;
      FListB.Values['OutFact'] := FieldByName('D_OutFact').AsString;
      FListB.Values['BID'] := nBid;
      FListB.Values['OID'] := FieldByName('O_ID').AsString;
      FListB.Values['ORID'] := FieldByName('ORID').AsString;
      FListB.Values['DID'] := FieldByName('D_ID').AsString;
      FListB.Values['Value'] := FieldByName('D_Value').AsString;

      FListB.Values['PkDtl'] := nBPKDtl;                            // 承运商PK
      FListB.Values['KFTime'] := FieldByName('O_KFtime').AsString;       // 矿发时间
      FListB.Values['KFValue'] := FieldByName('O_YJZValue').AsString;    // 矿发量
      FListB.Values['MDate'] := FieldByName('D_MDate').AsString;
      FListB.Values['MValue'] := FieldByName('D_MValue').AsString;
      FListB.Values['PValue'] := FieldByName('D_PValue').AsString;
      FListB.Values['KZValue'] := FieldByName('D_KZValue').AsString;
    end;

    nProPk:= GetProPk(nProId);
    nMtlPk:= GetMaterailPk(nStockID);

    FListB.Values['ProPk'] := nProPk;
    FListB.Values['StockPK'] := nMtlPk;
    FListB.Values['CarrierPK'] := nProPk;

    Result:= EncodeBase64(FListB.Text);
  finally
    FListB.Free;
  end;
end;

//Desc: 保存数据
procedure TfFormOrderDtl.BtnOKClick(Sender: TObject);
var nSQL, nStr, nMsg, nData, nS, nY: string;
    nNeedSync : Boolean;
    nVal : Double;
begin
  nVal := StrToFloatDef(EditMValue.Text, 0)-StrToFloatDef(EditPValue.Text, 0)-StrToFloatDef(EditKZValue.Text, 0);
  IF nVal<0 then
  begin
    ShowMsg('操作失败：请检查毛重、皮重、扣杂是否正确', sError);
    Exit;
  end;
                       {
  nStr := 'Select N_OrderNo, N_Status From %s Where N_OrderNo=''%s'' And N_Status=0 ' +
          'Union  ' +
          'Select N_OrderNo, N_Status From %s Where N_OrderNo=''%s'' And N_Status=0 ';

  nStr := Format(nStr, [sTable_UPLoadOrderNc, FDetailID, sTable_UPLoadOrderNcHistory, FDetailID]);
  with FDM.QueryTemp(nStr) do
  begin
    nNeedSync:= (RecordCount > 0);
    if RecordCount > 0 then
    begin
      nData := GetOrderDtlInfo(FDetailID);
      if nData<>'' then
      if not SendDeleteOrderDtlMsgToNc(nData, nMsg) then
      begin
        ShowMsg('操作失败：' + nMsg, sError);
        Exit;
      end;

      nSQL := 'Insert Into S_UPLoadOrderNcHistory(N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum) ' +
              '  Select ''%s'', ''P'', 0, ''Delete'', 1 ';
      nSQL := Format(nSQL, [FDetailID]);
      FDM.ExecuteSQL(nSQL);
    end;                      
  end;          }

  if YSStatus.ItemIndex=0 then nY:= 'Y' else nY:= 'N';

  nSQL := MakeSQLByForm(Self, sTable_OrderDtl, SF('D_ID', FDetailID), False);
  FDM.ADOConn.BeginTrans;
  try
    nS:= Format(', D_UnloadPlace=''%s'', D_UnloadType=''%s'', D_YMan=''%s'', D_YSResult=''%s'' ',
                [Trim(UnPlace.Text), Trim(UnType.Text), Trim(edt_YSR.Text), nY]);
    nSQL := GetLeftStr(',O_BID',nSQL) + nS +
          ' Where ' +GetRightStr('Where',nSQL);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'UPDate P_OrderDtl Set D_Value=D_MValue-D_PValue-D_PValue-D_KZValue Where ' +GetRightStr('Where',nSQL);
    FDM.ExecuteSQL(nSQL);

    nSQL := MakeSQLByStr([SF('P_CusID', EditProID.Text),
            SF('P_CusName', EditProName.Text),
            SF('P_MID', EditStock.Text),
            SF('P_MName', EditStockName.Text),
            SF('P_Truck', EditTruck.Text),
            SF('P_PValue', StrToFloatDef(EditPValue.Text, 0), sfVal),
            SF('P_MValue', StrToFloatDef(EditMValue.Text, 0), sfVal)
            ], sTable_PoundLog, SF('P_Order', FDetailID), False);
    FDM.ExecuteSQL(nSQL);
    //更新磅单

    if EditCheck.Checked and (FOrderID <> '') then
    begin
      nSQL := MakeSQLByStr([SF('O_ProID', EditProID.Text),
              SF('O_ProName', EditProName.Text),
              SF('O_ProPY', GetPinYinOfStr(EditProName.Text)),
              SF('O_StockNo', EditStock.Text),
              SF('O_StockName', EditStockName.Text),
              SF('O_BID', Edt_OrderBase.Text),
              SF('O_Truck', EditTruck.Text)
              ], sTable_Order, SF('O_ID', FOrderID), False);
      FDM.ExecuteSQL(nSQL);
    end;


    nSQL := 'UPDate $OrderBase Set B_SentValue=B_SentValue+$Val Where B_ID =''$ID'' ';
    nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                              MI('$ID', Trim(Edt_OrderBase.Text)),MI('$Val', FloatToStr(nVal))]);
    FDM.ExecuteSQL(nSQL);

    nSQL:= Format('Delete S_UPLoadOrderNc Where N_OrderNo=''%s'' ', [FDetailID]);
    FDM.ExecuteSQL(nSQL);

    IF nY<>'N' then
    begin
      nSQL:= Format('Insert into S_UPLoadOrderNc(N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum) '+
                    'Select ''%s'',''P'',-1,''add'',0 ', [FDetailID]);
      FDM.ExecuteSQL(nSQL);
    end;

    FNewOrder:= Format('%s %s 皮重 %s 毛重 %s 扣杂 %s', [
             Edt_OrderBase.Text, EditTruck.Text, EditPValue.Text,EditMValue.Text, EditKZValue.Text]);
    nStr:= Format(' %s 修改采购单 调整前[ %s ] 调整后[ %s ]',
                  [gSysParam.FUserName, FOldOrder, FNewOrder]);
    FDM.WriteSysLog(sFlag_BillItem, '', nStr, False);

    FDM.ADOConn.CommitTrans;
    ModalResult := mrOK;
    ShowMsg('修改成功、稍后将上传NC系统、请留意上传状态', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('数据保存失败', '未知原因');
  end;
end;

procedure TfFormOrderDtl.EditStockKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditStock then
    begin
      CreateBaseFormItem(cFI_FormGetMeterail, '', @nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

      EditStock.Text := nP.FParamB;
      EditStockName.Text := nP.FParamC;
    end

    else if Sender = EditProID then
    begin
      CreateBaseFormItem(cFI_FormGetProvider, '', @nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

      EditProID.Text := nP.FParamB;
      EditProName.Text := nP.FParamC;
    end

    else if Sender = EditTruck then
    begin
      CreateBaseFormItem(cFI_FormGetTruck, '', @nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

      EditTruck.Text := nP.FParamB;
    end;
  end;
end;

procedure TfFormOrderDtl.Edt_OrderBasePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  try
    nP.FParamA:= 'Edit';
    CreateBaseFormItem(cFI_FormGetPOrderBase, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    FOrderBase.Text := PackerDecodeStr(nP.FParamB);

    Edt_OrderBase.Text:= FOrderBase.Values['SQ_ID'];
    EditStock.Text    := FOrderBase.Values['SQ_StockNO'];
    EditStockName.Text:= FOrderBase.Values['SQ_StockName'];
    EditProID.Text    := FOrderBase.Values['SQ_ProID'];
    EditProName.Text  := FOrderBase.Values['SQ_ProName'];
  finally
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormOrderDtl, TfFormOrderDtl.FormID);
end.
