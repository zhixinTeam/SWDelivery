{*******************************************************************************
  ����: dmzn@163.com 2011-01-26
  ����: ����Ʊ
*******************************************************************************}
unit UFormInvoiceK;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, cxGraphics, dxLayoutControl, cxMemo, cxTextEdit,
  cxMCListBox, cxDropDownEdit, cxCalendar, cxContainer, cxEdit, cxMaskEdit,
  cxButtonEdit, StdCtrls, cxControls, cxLookAndFeels, cxLookAndFeelPainters;

type
  PInvoiceDataItem = ^TInvoiceDataItem;
  TInvoiceDataItem = record
    FRecordID: string;    //��¼ 
    FStockType: string;   //����
    FStockName: string;   //Ʒ��
    FPrice: Double;       //�����
    FKPrice: Double;      //��Ʊ��
    FZPrice: Double;      //�ۿۼ�

    FValue: Double;       //������
    FKValue: Double;      //�ѿ��� 
  end;

  PKInvoiceParam = ^TKInvoiceParam;
  TKInvoiceParam = record
    FWeek: string;        //��Ʊ����
    FFlag: string;        //��Ʊ���(����,�ճ���)

    FSaleID: string;      //ҵ��Ա��
    FSaleMan: string;     //ҵ��Ա��
    FCusID: string;       //�ͻ����
    FCustomer: string;    //�ͻ�����
  end;

  TfFormInvoiceK = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditMemo: TcxMemo;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditInvoice: TcxComboBox;
    dxLayoutControl1Item3: TdxLayoutItem;
    EditMoney: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    EditZheKou: TcxTextEdit;
    dxLayoutControl1Item4: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditPrice: TcxTextEdit;
    dxLayoutControl1Item5: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    ListDetail: TcxMCListBox;
    dxLayoutControl1Item7: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    dxLayoutControl1Group7: TdxLayoutGroup;
    EditZK: TcxTextEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    dxLayoutControl1Group6: TdxLayoutGroup;
    EditCus: TcxTextEdit;
    dxLayoutControl1Item12: TdxLayoutItem;
    EditSale: TcxTextEdit;
    dxLayoutControl1Item13: TdxLayoutItem;
    dxLayoutControl1Group9: TdxLayoutGroup;
    dxLayoutControl1Group3: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListDetailClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditValueFocusChanged(Sender: TObject);
  private
    { Private declarations }
    FDataItem: TList;
    //������
    FParam: PKInvoiceParam;
    //ѡ��
    FDetailIndex: Integer;
    //��ϸ����
    procedure InitFormData(const nData: TList);
    procedure LoadDetailList(const nData: TList);
    procedure LoadInvoice(const nID: string);
    //��������
  public
    { Public declarations }
  end;

procedure ClearInvoiceDataItemList(const nList: TList; const nFree: Boolean);
function ShowSaleKInvioceForm(const nData: TList; nParam: PKInvoiceParam): Boolean;
procedure ShowInvoiceInfoForm(const nID: string);
procedure CloseInvoiceInfoForm;
//��ں���

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, USysGrid, USysDB, USysConst,
  USysFun, USysBusiness;

var
  gForm: TfFormInvoiceK = nil;
  //global use

//Desc: ����nData����Ʊ
function ShowSaleKInvioceForm(const nData: TList; nParam: PKInvoiceParam): Boolean;
begin
  with TfFormInvoiceK.Create(Application) do
  begin
    Caption := '����Ʊ';
    FParam := nParam;
    FDataItem := nData;

    InitFormData(nData);
    Result := ShowModal = mrOk;
    Free;
  end;
end;

procedure ShowInvoiceInfoForm(const nID: string);
begin
  if not Assigned(gForm) then
  begin
    gForm := TfFormInvoiceK.Create(Application);
    with gForm do
    begin
      Caption := '��Ʊ - ��ϸ';
      FormStyle := fsStayOnTop;
      BtnOK.Visible := False;
      FDataItem := TList.Create;
    end;
  end;

  gForm.LoadInvoice(nID);
  if not gForm.Showing then gForm.Show;
end;

procedure CloseInvoiceInfoForm;
begin
  FreeAndNil(gForm);
end;

//Desc: �����б�
procedure ClearInvoiceDataItemList(const nList: TList; const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    Dispose(PInvoiceDataItem(nList[nIdx]));
    nList.Delete(nIdx);
  end;

  if nFree then nList.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormInvoiceK.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FDetailIndex := -1;
  //no item
  
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, ListDetail, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormInvoiceK.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, ListDetail);
  finally
    nIni.Free;
  end;

  Action := caFree;
  if not (fsModal in FormState) then
  begin
    gForm := nil;
    ClearInvoiceDataItemList(FDataItem, True);
  end;
end;

procedure TfFormInvoiceK.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormInvoiceK.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2009-10-12
//Parm: ����Ʊ��ϸ
//Desc: ����nData��ϸ������
procedure TfFormInvoiceK.InitFormData(const nData: TList);
var nStr: string;
begin
  EditCus.Text := FParam.FCustomer;
  EditSale.Text := FParam.FSaleMan;
  LoadDetailList(nData);

  if EditInvoice.Properties.Items.Count < 1 then
  begin
    nStr := 'Select I_ID From %s Where I_Status=''%s'' Order By I_ID';
    nStr := Format(nStr, [sTable_Invoice, sFlag_InvNormal]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        EditInvoice.Properties.Items.Add(Fields[0].AsString);
        Next;
      end;
    end;
  end;
end;

//Desc: ���뿪Ʊ��ϸ
procedure TfFormInvoiceK.LoadDetailList(const nData: TList);
var nStr: string;
    nV,nZ: Double;
    i,nCount,nIdx: integer;
begin
  nIdx := ListDetail.ItemIndex;
  ListDetail.Items.BeginUpdate;
  try
    nV := 0; nZ := 0;
    ListDetail.Items.Clear;
    nCount := nData.Count - 1;

    for i:=0 to nCount do
    with PInvoiceDataItem(nData[i])^ do
    begin
      nV := nV + FKPrice * FKValue;
      nZ := nZ + Float2Float(FZPrice * FKValue, cPrecision, False);

      nStr := CombinStr([FStockName, Format('%.2f', [FPrice]),
              Format('%.2f', [FKPrice]), Format('%.2f', [FValue]),
              Format('%.2f', [FKValue])], ListDetail.Delimiter);
      ListDetail.Items.Add(nStr);
    end;

    EditMoney.Text := Format('%.2f', [nV]);
    EditZheKou.Text := Format('%.2f', [nZ]);
  finally
    ListDetail.Items.EndUpdate;
    ListDetail.ItemIndex := nIdx;
  end;
end;

//Desc: ����nID��Ʊ����ϸ
procedure TfFormInvoiceK.LoadInvoice(const nID: string);
var nStr: string;
    nItem: PInvoiceDataItem;
begin
  nStr := 'Select I_SaleMan,I_Customer,I_Memo From %s Where I_ID=''%s''';
  nStr := Format(nStr, [sTable_Invoice, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    EditInvoice.Properties.ReadOnly := True;
    EditInvoice.Properties.DropDownListStyle := lsEditList;
    EditInvoice.Text := nID;

    EditSale.Text := Fields[0].AsString;
    EditCus.Text := Fields[1].AsString;
    EditMemo.Text := Fields[2].AsString;
  end else Exit;

  ClearInvoiceDataItemList(FDataItem, False);
  nStr := 'Select * From %s Where D_Invoice=''%s''';
  nStr := Format(nStr, [sTable_InvoiceDtl, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      New(nItem);
      FDataItem.Add(nItem);

      with nItem^ do
      begin
        FStockType := FieldByName('D_Type').AsString;
        FStockName := FieldByName('D_Stock').AsString;
        FPrice := FieldByName('D_Price').AsFloat;
        FKPrice := FieldByName('D_KPrice').AsFloat;
        FZPrice := FieldByName('D_DisCount').AsFloat;
        FValue := FieldByName('D_Value').AsFloat;
        FKValue := FValue;
      end;

      Next;
    end;
  end;

  LoadDetailList(FDataItem);
end;

//Desc: ��ʾ��ϸ
procedure TfFormInvoiceK.ListDetailClick(Sender: TObject);
var nIdx: Integer;
begin
  nIdx := ListDetail.ItemIndex;
  if nIdx < 0 then Exit;

  with PInvoiceDataItem(FDataItem[nIdx])^ do
  begin
    EditStock.Text := FStockName;
    EditPrice.Text := Format('%.2f', [FKPrice]);
    EditValue.Text := Format('%.2f', [FKValue]);
    EditZK.Text := Format('%.2f', [FZPrice * FKValue]);

    FDetailIndex := nIdx;
    //��ϸ������
  end;
end;

//Desc: ��������
procedure TfFormInvoiceK.EditValueFocusChanged(Sender: TObject);
var nVal: Double;
begin
  if FDetailIndex < 0 then Exit;
  if EditValue.IsFocused then Exit;
  if not IsNumber(EditValue.Text, True) then Exit;

  nVal := Float2Float(StrToFloat(EditValue.Text), cPrecision, False);
  if nVal < 0 then Exit;
  if PInvoiceDataItem(FDataItem[FDetailIndex]).FKValue = nVal then Exit;

  with PInvoiceDataItem(FDataItem[FDetailIndex])^ do
  begin
    if nVal > Float2Float(FValue, cPrecision, False) then
    begin
      ShowMsg('�ѳ����ɿ�Ʊ����', sHint); Exit;
    end;

    FKValue := nVal;
    EditZK.Text := Format('%.2f', [FZPrice * FKValue]);
    LoadDetailList(FDataItem);
  end;
end;

//Desc: ��������
procedure TfFormInvoiceK.BtnOKClick(Sender: TObject);
var nVal: Double;
    nStr,nSQL: string;
    i,nCount: integer;
begin
  if EditInvoice.ItemIndex < 0 then
  begin
    EditInvoice.SetFocus;
    ShowMsg('��ѡ����Ч�ķ�Ʊ��', sHint); Exit;
  end;

  nSQL := 'Select Count(*) From %s Where I_ID=''%s'' And I_Status=''%s''';
  nSQL := Format(nSQL, [sTable_Invoice, EditInvoice.Text, sFlag_InvNormal]);

  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger < 1 then
  begin
    EditInvoice.SetFocus;
    ShowMsg('�÷�Ʊ����Ч', sHint); Exit;
  end;

  if Float2PInt(StrToFloat(EditMoney.Text), cPrecision) <= 0 then
  begin
    ShowMsg('��Ʊ��Ϊ��,���ñ���!', sHint); Exit;
  end;

  if StrToFloat(EditZheKou.Text) <> 0 then
  begin
    nStr := '�ͻ�[ %s ]���ۿ�,��Ϊ���˻������ʽ�[ %s ]Ԫ.' + #13#10 +
            'Ҫ������?';
    nStr := Format(nStr, [EditCus.Text, EditZheKou.Text]);
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  FDM.ADOConn.BeginTrans;
  with FParam^ do
  try
    nSQL := MakeSQLByStr([Format('I_Week=''%s''', [FParam.FWeek]),
            Format('I_CusID=''%s''', [FCusID]),
            Format('I_Customer=''%s''', [FCustomer]),
            Format('I_SaleID=''%s''', [FSaleID]),
            Format('I_SaleMan=''%s''', [FSaleMan]),
            Format('I_Status=''%s''', [sFlag_InvHasUsed]),
            Format('I_Flag=''%s''', [FParam.FFlag]),
            Format('I_OutMan=''%s''', [gSysParam.FUserID]),
            Format('I_OutDate=%s', [FDM.SQLServerNow]),
            Format('I_Memo=''%s''', [EditMemo.Text])],
            sTable_Invoice, Format('I_ID=''%s''', [EditInvoice.Text]), False);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Insert Into %s(D_Invoice, D_Type, D_Stock, D_Price, D_Value,' +
            'D_KPrice, D_DisCount, D_DisMoney) Values(''%s'', ''$Type'', ' +
            '''$Stock'', $Price, $Value, $KPrice, $ZK, $ZMon)';
    nSQL := Format(nSQL, [sTable_InvoiceDtl, EditInvoice.Text]);

    nCount := FDataItem.Count - 1;
    for i:=0 to nCount do
    with PInvoiceDataItem(FDataItem[i])^ do
    begin
      nVal := Float2Float(FZPrice * FKValue, cPrecision, False);
      //�ۿ۽��

      nStr := MacroValue(nSQL, [MI('$Type', FStockType),
              MI('$Stock', FStockName), MI('$Price', FloatToStr(FPrice)),
              MI('$Value', FloatToStr(FKValue)), MI('$KPrice', FloatToStr(FKPrice)),
              MI('$ZK', FloatToStr(FZPrice)), MI('$ZMon', FloatToStr(nVal))]);
      FDM.ExecuteSQL(nStr);
    end;

    nSQL := 'Update %s Set R_KValue=R_KValue+$Value Where R_ID=$ID';
    nSQL := Format(nSQL, [sTable_InvoiceReq, FParam.FWeek]);
    //���������ѿ�

    nCount := FDataItem.Count - 1;
    for i:=0 to nCount do
    with PInvoiceDataItem(FDataItem[i])^ do
    begin
      nStr := MacroValue(nSQL, [MI('$Value', FloatToStr(FKValue)),
                                MI('$ID', FRecordID)]);
      FDM.ExecuteSQL(nStr);
    end;

    nVal := StrToFloat(EditZheKou.Text);
    nVal := -nVal;
    //���������ۿ��෴

    if nVal <> 0 then
    begin
      nStr := Format('����Ʊ[ %s ]ʱ�ۿ۷���', [EditInvoice.Text]);
      if not SaveCompensation(FSaleID, FCusID, FCustomer, '�����ۿ�',
        nStr, nVal) then raise Exception.Create('');
    end;

    FDM.ADOConn.CommitTrans;
    ModalResult := mrOk;
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('��������ʧ��', sError);
  end;
end;

end.
