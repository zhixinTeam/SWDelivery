{*******************************************************************************
  ����: fendou116688@163.com 2015/8/10
  ����: �ɹ�������ѯ
*******************************************************************************}
unit UFrameOrderDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels, NativeXml,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxCheckBox, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxSkinsdxLCPainter;

type
  TfFrameOrderDetail = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Check1: TcxCheckBox;
    N4: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Check1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
  private
    { Private declarations }
    function GetOrderDtlInfo(nId: string): string;
    function GetProviderPk(nPid: string; Var nProPk:string):Boolean;
    function GetMaterailPK(nMid: string; Var nMtlPk:string):Boolean;
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //ʱ������
    FJBWhere: string;
    //��������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //��ѯSQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UDataModule, UFormBase;

class function TfFrameOrderDetail.FrameID: integer;
begin
  Result := cFI_FrameOrderDetail;
end;

procedure TfFrameOrderDetail.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameOrderDetail.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameOrderDetail.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select *,(D_MValue-D_PValue-IsNull(D_KZValue, 0)) as D_NetWeight ' +
            'From $OD od Left Join $OO oo on od.D_OID=oo.O_ID ';
  //xxxxxx

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (D_InTime>=''$S'' and D_InTime <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  if Check1.Checked then
       Result := MacroValue(Result, [MI('$OD', sTable_OrderDtlBak)])
  else Result := MacroValue(Result, [MI('$OD', sTable_OrderDtl)]);

  Result := MacroValue(Result, [MI('$OD', sTable_OrderDtl),MI('$OO', sTable_Order),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;


//Desc: ����ɸѡ
procedure TfFrameOrderDetail.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameOrderDetail.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'D_ProPY like ''%%%s%%'' Or D_ProName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'oo.O_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'od.D_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ���Ӱ��ѯ
procedure TfFrameOrderDetail.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(D_InTime>=''%s'' and D_InTime <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/8/13
//Parm: 
//Desc: ��ѯδ���
procedure TfFrameOrderDetail.N2Click(Sender: TObject);
begin
  inherited;
  try
    FJBWhere := '(D_OutFact Is Null)';
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

function TfFrameOrderDetail.GetProviderPk(nPid: string; Var nProPk:string):Boolean;
var nStr : string;
begin
  Result:= False;
  try
    nStr := 'Select * From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_Provider, nPid]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount > 0 then
      begin
        nProPk:= FieldByName('P_PKPro').AsString;
        Result:= True;
      end;
    end;
  finally
  end;
end;

function TfFrameOrderDetail.GetMaterailPK(nMid: string; Var nMtlPk:string):Boolean;
var nStr : string;
begin
  Result:= False;
  try
    nStr := 'Select * From %s Where M_ID=''%s''';
    nStr := Format(nStr, [sTable_Materails, nMid]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount > 0 then
      begin
        nMtlPk:= FieldByName('M_PK').AsString;
        Result:= True;
      end;
    end;
  finally
  end;
end;

function TfFrameOrderDetail.GetOrderDtlInfo(nId : string): string;
var nStr, nProPk, nMtlPk, nBid, nBPKDtl: string;
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

        if not GetProviderPk(FieldByName('B_ProId').AsString, nProPk) then
          Exit;
        if not GetMaterailPK(FieldByName('O_StockNo').AsString, nMtlPk) then
          Exit;
        nBid := FieldByName('B_NCOrderNo').AsString;
        nBPKDtl := FieldByName('B_PKDtl').AsString;
        //***********
        FListB.Values['Proc'] := 'delete';
        FListB.Values['CreateTime'] := FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('O_Date').AsDateTime);
        FListB.Values['ProPk'] := nProPk;
        FListB.Values['creator'] := FieldByName('O_Man').AsString;
        FListB.Values['OutFact'] := FieldByName('D_OutFact').AsString;
        FListB.Values['BID'] := nBid;
        FListB.Values['OID'] := FieldByName('O_ID').AsString;
        FListB.Values['ORID'] := FieldByName('ORID').AsString;
        FListB.Values['DID'] := FieldByName('D_ID').AsString;
        FListB.Values['Value'] := FieldByName('D_Value').AsString;

        FListB.Values['StockPK'] := nMtlPk;
        FListB.Values['PkDtl'] := nBPKDtl;
        FListB.Values['CarrierPK'] := nProPk;                              // ������PK
        FListB.Values['KFTime'] := FieldByName('O_KFtime').AsString;       // ��ʱ��
        FListB.Values['KFValue'] := FieldByName('O_YJZValue').AsString;    // ����
        FListB.Values['MDate'] := FieldByName('D_MDate').AsString;
        FListB.Values['MValue'] := FieldByName('D_MValue').AsString;
        FListB.Values['PValue'] := FieldByName('D_PValue').AsString;
        FListB.Values['KZValue'] := FieldByName('D_KZValue').AsString;

        Result:= EncodeBase64(FListB.Text);

    end;
  finally
    FListB.Free;
  end;
end;


//------------------------------------------------------------------------------
//Date: 2015/8/13
//Parm:
//Desc: ɾ��δ��ɼ�¼
procedure TfFrameOrderDetail.N3Click(Sender: TObject);
var nStr, nSQL, nP, nID, nOrderID, nCardType, nMsg, nData, nStockNo: string;
    nOutFact : Boolean;
    nIdx: Integer;
    nVal, nFreeze: Double;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nID := SQLQuery.FieldByName('D_ID').AsString;
    if not QueryDlg('ȷ��ɾ���òɹ�����ô?', sAsk) then Exit;

    nP       := SQLQuery.FieldByName('D_MDate').AsString;
    nOrderID := SQLQuery.FieldByName('D_OID').AsString;
    nCardType:= SQLQuery.FieldByName('O_CType').AsString;
    nStockNo := SQLQuery.FieldByName('D_StockNo').AsString;

    nFreeze  := SQLQuery.FieldByName('O_Value').AsFloat;
    nVal     := SQLQuery.FieldByName('D_NetWeight').AsFloat;

    {$IFDEF NCPurchase}
    /// ����Ƿ��Ѿ�ͬ��NC  ��ͬ������֪ͨNC ����ɾ��
    nStr := 'Select * From %s Where M_ID=''%s'' And ISNULL(M_Pk, '''')<>'''' ';
    nStr := Format(nStr, [sTable_Materails, nStockNo, sTable_Materails]);
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount>0 then
      begin
          nStr:= 'Select N_OrderNo, N_Status From %s Where N_OrderNo=''%s'' And N_Status=0 ' +
                 'Union  ' +
                 'Select N_OrderNo, N_Status From %s Where N_OrderNo=''%s'' And N_Status=0 ';

          nStr:= Format(nStr, [sTable_UPLoadOrderNc, nID, sTable_UPLoadOrderNcHistory, nID);
          with FDM.QueryTemp(nStr) do
          begin
            if RecordCount>0 then
            begin
              nData:= GetOrderDtlInfo(nID);
              if Not SendDeleteOrderDtlMsgToNc(nData, nMsg) then
              begin
                ShowMsg('ɾ��ʧ��', sError);
                Exit;
              end;
            end;
          end;
      end;
    end;
    {$ENDIF}

    if nP <> '' then
         nOutFact := True
    else nOutFact := False;

    nStr := Format('Select * From %s Where 1<>1', [sTable_OrderDtl]);
    //only for fields
    nP := '';

    with FDM.QueryTemp(nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
      if (Fields[nIdx].DataType <> ftAutoInc) and
         (Pos('D_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��
      System.Delete(nP, Length(nP), 1);
    end;

    FDM.ADOConn.BeginTrans;
    try
      if nOutFact then
      begin
        nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue-$Val ' +
                'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'')';
        nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                MI('$Order', sTable_Order),MI('$ID', nOrderID),
                MI('$Val', FloatToStr(nVal))]);
        FDM.ExecuteSQL(nSQL);
        //������������
      end else
      begin
        if nCardType = sFlag_OrderCardL then
        begin
          nSQL := 'Update $OrderBase Set B_FreezeValue=B_FreezeValue-$FreezeVal  ' +
                  'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'') and '+
                  'B_Value>0';

          nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                  MI('$Order', sTable_Order),MI('$ID', nOrderID),
                  MI('$FreezeVal', FloatToStr(nFreeze))]);
          FDM.ExecuteSQL(nSQL);

          nSQL := 'Update $Order Set O_Value=0.00 Where O_ID=''$ID''';
          nSQL := MacroValue(nSQL, [MI('$Order', sTable_Order),MI('$ID', nOrderID)]);
          FDM.ExecuteSQL(nSQL);
          //��ֹ���ν���ɾ���ظ�������
        end;
      end;

      nStr := 'Insert Into $DB($FL,D_DelMan,D_DelDate) ' +
              'Select $FL,''$User'',$Now From $DL Where D_ID=''$ID''';
      nStr := MacroValue(nStr, [MI('$DB', sTable_OrderDtlBak),
              MI('$FL', nP), MI('$User', gSysParam.FUserID),
              MI('$Now', sField_SQLServer_Now),
              MI('$DL', sTable_OrderDtl), MI('$ID', nID)]);
      FDM.ExecuteSQL(nStr);

      nStr := 'Delete From %s Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_OrderDtl, nID]);
      FDM.ExecuteSQL(nStr);

      FDM.ADOConn.CommitTrans;
      InitFormData(FWhere);
      ShowMsg('ɾ�����', sHint);

      try
        SaveWebOrderDelMsg(nID,sFlag_Provide);
      except
      end;
      //����ɾ������

    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('ɾ��ʧ��', sError);
    end;
  end;

  InitFormData('');
end;

procedure TfFrameOrderDetail.Check1Click(Sender: TObject);
begin
  inherited;
  InitFormData(FWhere);
end;

procedure TfFrameOrderDetail.N4Click(Sender: TObject);
var nStr: String;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('D_ID').AsString;
    PrintOrderReport(nStr, False);
  end;
end;

procedure TfFrameOrderDetail.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA  := SQLQuery.FieldByName('D_ID').AsString;
    nP.FParamB  := SQLQuery.FieldByName('D_OID').AsString;

    CreateBaseFormItem(cFI_FormOrderDtl, '', @nP);
  end;
  EditTruckPropertiesButtonClick(EditCustomer, 0);
end;

initialization
  gControlManager.RegCtrl(TfFrameOrderDetail, TfFrameOrderDetail.FrameID);
end.
