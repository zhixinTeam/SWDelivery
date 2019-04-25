{*******************************************************************************
  ����: dmzn@163.com 2015-01-16
  ����: ���ε�������
*******************************************************************************}
unit UFormBatcodeJ;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls, cxMaskEdit, cxDropDownEdit, cxLabel,
  dxSkinsCore, dxSkinsDefaultPainters, dxSkinsdxLCPainter;

type
  TfFormBatcode = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditPrefix: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditStock: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    EditInc: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditBase: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item8: TdxLayoutItem;
    EditLen: TcxTextEdit;
    Check1: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    EditLow: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditHigh: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    Check2: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item14: TdxLayoutItem;
    dxLayout1Group7: TdxLayoutGroup;
    cxLabel2: TcxLabel;
    dxLayout1Item15: TdxLayoutItem;
    dxLayout1Group8: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Item17: TdxLayoutItem;
    dxLayout1Group9: TdxLayoutGroup;
    EditWeek: TcxTextEdit;
    dxLayout1Item18: TdxLayoutItem;
    dxLayout1Group10: TdxLayoutGroup;
    cxLabel4: TcxLabel;
    dxLayout1Item19: TdxLayoutItem;
    dxLayout1Group11: TdxLayoutGroup;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    Check3: TcxCheckBox;
    dxLayout1Group4: TdxLayoutGroup;
    dxlytm_Fact: TdxLayoutItem;
    cbb_Factory: TcxComboBox;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FRecordID: string;
    //��¼���
    procedure LoadFormData(const nID: string);
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //��֤����
    procedure LoadStockFactory;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UAdjustForm, UFormCtrl, USysDB, USysConst;

class function TfFormBatcode.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormBatcode.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '���� - ���';
      FRecordID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '���� - �޸�';
      FRecordID := nP.FParamA;
    end;

    {$IFDEF SetStdMValue}
    dxlytm_Fact.caption:= '';
    cbb_Factory.Visible:= False;
    {$endif}

    {$IFDEF SendMorefactoryStock}
    dxlytm_Fact.Visible:= False;
    {$ENDIF}

    if dxlytm_Fact.Visible then
      LoadStockFactory;
      
    LoadFormData(FRecordID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBatcode.FormID: integer;
begin
  Result := cFI_FormBatch;
end;

procedure TfFormBatcode.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ReleaseCtrlData(Self);
end;

// ���ؿ�������
procedure TfFormBatcode.LoadStockFactory;
var nStr: string;
    i,nIdx: integer;
begin
  cbb_Factory.Clear;
  cbb_Factory.Properties.Items.Clear;
  nStr := ' Select * From Sys_Dict Where D_Name=''BillFromFactory''';
  //��չ��Ϣ

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
        nStr := FieldByName('D_Value').AsString;
        cbb_Factory.Properties.Items.Add(nStr);
        Next;
    end;
  end;
end;

procedure TfFormBatcode.LoadFormData(const nID: string);
var nStr: string;
begin
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=0 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  FDM.FillStringsData(EditStock.Properties.Items, nStr, -1, '.');
  AdjustCXComboBoxItem(EditStock, False);

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_StockBatcode, nID]);
    FDM.QueryTemp(nStr);

    with FDM.SqlTemp do
    begin
      nStr := FieldByName('B_SendFactory').AsString;
      SetCtrlData(cbb_Factory, nStr);
      nStr := FieldByName('B_Stock').AsString;
      SetCtrlData(EditStock, nStr);

      EditName.Text := FieldByName('B_Name').AsString;
      EditBase.Text := FieldByName('B_Base').AsString;
      EditLen.Text := FieldByName('B_Length').AsString;

      EditPrefix.Text := FieldByName('B_Prefix').AsString;
      Check3.Checked := FieldByName('B_UseYear').AsString = sFlag_Yes;

      EditInc.Text := FieldByName('B_Incement').AsString;
      Check1.Checked := FieldByName('B_UseDate').AsString = sFlag_Yes;

      EditValue.Text := FieldByName('B_Value').AsString;
      EditLow.Text := FieldByName('B_Low').AsString;
      EditHigh.Text := FieldByName('B_High').AsString;
      EditWeek.Text := FieldByName('B_Interval').AsString;
      Check2.Checked := FieldByName('B_AutoNew').AsString = sFlag_Yes;
    end;
  end;

  EditStock.SelLength := 0;
  EditStock.SelStart := 1;
  ActiveControl := EditPrefix;
end;

procedure TfFormBatcode.EditStockPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
begin
  nStr := EditStock.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(EditStock) + '.'));
  EditName.Text := nStr;
end;

function TfFormBatcode.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
begin
  Result := True;

  dxlytm_Fact.Visible:= False;
  {$IFDEF SendMorefactoryStock}
  dxlytm_Fact.Visible:= True;
  if Sender = cbb_Factory then
  begin
    Result := cbb_Factory.ItemIndex >= 0;
    nHint := '��ѡ����������';
    if not Result then Exit;
  end;
  {$endif}
  
  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex >= 0;
    nHint := '��ѡ������';
    if not Result then Exit;

    nStr := 'Select R_ID From %s Where B_Stock=''%s''';
      {$IFDEF SendMorefactoryStock}
       nStr := nStr + ' And B_SendFactory='''+GetCtrlData(cbb_Factory)+'''';
      {$endif}
    nStr := Format(nStr, [sTable_StockBatcode, GetCtrlData(EditStock)]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      Result := FRecordID = Fields[0].AsString;
      nHint := '�����ϵı�������Ѵ���';
    end;
  end else

  if Sender = EditBase then
  begin
    Result := IsNumber(EditBase.Text, False);
    nHint := '���������';
  end else

  if Sender = EditInc then
  begin
    Result := IsNumber(EditInc.Text, False);
    nHint := '����������';
  end else

  if Sender = EditLen then
  begin
    Result := IsNumber(EditLen.Text, False);
    nHint := '�����볤��';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text) > 0);
    nHint := '����������';
  end else

  if Sender = EditLow then
  begin
    Result := IsNumber(EditLow.Text, True) and (StrToFloat(EditLow.Text) >= 0);
    nHint := '�����볬������';
  end else

  if Sender = EditHigh then
  begin
    Result := IsNumber(EditHigh.Text, True) and (StrToFloat(EditHigh.Text) >= 0);
    nHint := '�����볬������';
  end else

  if Sender = EditWeek then
  begin
    Result := IsNumber(EditWeek.Text, False) and (StrToFloat(EditWeek.Text) >= 0);
    nHint := '����������ֵ';
  end;
end;

//Desc: ����
procedure TfFormBatcode.BtnOKClick(Sender: TObject);
var nStr,nU,nN,nY: string;
begin
  if not IsDataValid then Exit;
  //��֤��ͨ��

  if Check1.Checked then
       nU := sFlag_Yes
  else nU := sFlag_No;

  if Check2.Checked then
       nN := sFlag_Yes
  else nN := sFlag_No;

  if Check3.Checked then
       nY := sFlag_Yes
  else nY := sFlag_No;                             

  if FRecordID = '' then
       nStr := ''
  else nStr := SF('R_ID', FRecordID, sfVal);

  nStr := MakeSQLByStr([SF('B_Stock', GetCtrlData(EditStock)),
          SF('B_Name', EditName.Text),
          SF('B_Prefix', EditPrefix.Text),
          SF('B_UseYear', nY),
          SF('B_Base', EditBase.Text, sfVal),
          SF('B_Length', EditLen.Text, sfVal),
          SF('B_Incement', EditInc.Text, sfVal),
          SF('B_UseDate', nU),

          {$IFDEF SendMorefactoryStock}           // ���������ݿ���������ȡ���� ����
          SF('B_SendFactory', GetCtrlData(cbb_Factory)),
          {$ENDIF}

          SF('B_Value', EditValue.Text, sfVal),
          SF('B_Low', EditLow.Text, sfVal),
          SF('B_High', EditHigh.Text, sfVal),
          SF('B_Interval', EditWeek.Text, sfVal),
          SF('B_AutoNew', nN),
          SF('B_LastDate', sField_SQLServer_Now, sfVal)
          ], sTable_StockBatcode, nStr, FRecordID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('���α���ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormBatcode, TfFormBatcode.FormID);
end.
