{*******************************************************************************
  ����: dmzn@163.com 2010-3-16
  ����: �泵�����鵥
*******************************************************************************}
unit UFormHYData_Each;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, ComCtrls, cxListView, Menus,
  cxLookAndFeels, cxLookAndFeelPainters, cxMCListBox;

type
  THYTruckItem = record
    FBill: string;              //������
    FTruck: string;             //���ƺ�
    FStockNO: string;           //ˮ����
    FStockName: string;         //ˮ������
    FCusID: string;             //�ͻ����
    FCusName: string;           //�ͻ�����
    FValue: Double;             //�����
    FTime: TDateTime;           //���ʱ��
  end;

  TfFormHYData_Each = class(TfFormNormal)
    dxLayout1Item4: TdxLayoutItem;
    EditCard: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    TruckList1: TcxMCListBox;
    dxLayout1Item9: TdxLayoutItem;
    ParamList1: TcxMCListBox;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Item10: TdxLayoutItem;
    EditLading: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditLDate: TcxDateEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditRDate: TcxDateEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditReporter: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    EditStockNo: TcxButtonEdit;
    dxLayout1Item15: TdxLayoutItem;
    EditItem: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    EditValue: TcxTextEdit;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TruckList1Click(Sender: TObject);
    procedure ParamList1Click(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditStockNoPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    { Protected declarations }
    FTrucks: array of THYTruckItem;
    //�������
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //��֤����
    procedure InitFormData(const nCard,nTruck: string);
    //��������
    procedure LoadBillData(const nCard,nTruck: string);
    //��ȡ������
    function LoadStockRecord(const nID: string): Boolean;
    //�����¼
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, UFormBase, UMgrControl, USysGrid,
  USysDB, USysConst, USysBusiness, UDataModule, UFormInputbox;

class function TfFormHYData_Each.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
  begin
    nP := nParam;
    if nP.FCommand <> cCmd_AddData then Exit;
  end else nP := nil;

  with TfFormHYData_Each.Create(Application) do
  try
    Caption := '�����鵥';
    if Assigned(nP) then
    begin
      InitFormData(nP.FParamA, nP.FParamB);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
    end else
    begin
      InitFormData('', '');
      ShowModal;
    end;
  finally
    Free;
  end;
end;

class function TfFormHYData_Each.FormID: integer;
begin
  Result := cFI_FormStockHY_Each;
end;

procedure TfFormHYData_Each.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, TruckList1, nIni);
    LoadMCListBoxConfig(Name, ParamList1, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormHYData_Each.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, TruckList1, nIni);
    SaveMCListBoxConfig(Name, ParamList1, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ������
procedure TfFormHYData_Each.InitFormData(const nCard,nTruck: string);
begin
  EditLDate.Date := FDM.ServerNow;
  EditRDate.Date := EditLDate.Date + Str2Time('0:00:02');
  
  dxGroup1.AlignHorz := ahClient;
  EditReporter.Text := gSysParam.FUserID;

  if (nCard = '') and (nTruck = '') then
       ActiveControl := EditCard
  else LoadBillData(nCard, nTruck);
end;

//Date: 2011-1-16
//Parm: ֽ����;������¼
//Desc: �����ʶΪnZK��ֽ����Ϣ
procedure TfFormHYData_Each.LoadBillData(const nCard,nTruck: string);
var nStr: string;
    nIdx: Integer;
begin
  EditCard.Text := nCard;
  EditTruck.Text := nTruck;

  TruckList1.Clear;
  SetLength(FTrucks, 0);

  nStr := 'Select L_ID,L_CusID,H_CusName,L_Truck,L_StockNo,L_StockName,' +
          'L_Value,L_Date From $Bill ';
  //xxxxx

  if nTruck <> '' then
     nStr := nStr + ' Where L_Truck=''$TK'' And L_HYDan Is Null';
  //xxxxx

  if nCard <> '' then
     nStr := nStr + ' Where L_Card=''$CD'' And L_HYDan Is Null';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill),
          MI('$TK', nTruck), MI('$CD', nCard)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nCard <> '' then
        ShowMsg('��Ч�Ĵſ���', sHint);
      //xxxxx

      if nTruck <> '' then
        ShowMsg('�ó�����Ҫ����', sHint);
      Exit;
    end;

    SetLength(FTrucks, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      with FTrucks[nIdx] do
      begin
        FBill      := FieldByName('L_ID').AsString;
        FTruck     := FieldByName('L_Truck').AsString;
        FStockNO   := FieldByName('L_StockNo').AsString;
        FStockName := FieldByName('L_StockName').AsString;
        FCusID     := FieldByName('L_CusID').AsString;
        FCusName   := FieldByName('H_CusName').AsString;
        FValue     := FieldByName('L_Value').AsFloat;
        FTime      := FieldByName('L_Date').AsDateTime;
      end;

      Inc(nIdx);
      Next;
    end;

    for nIdx:=Low(FTrucks) to High(FTrucks) do
    with FTrucks[nIdx] do
    begin
      nStr := CombinStr([FTruck, FStockName + ' ',
              Format('%.2f', [FValue]),
              DateTime2Str(FTime)], TruckList1.Delimiter);
      TruckList1.Items.Add(nStr);
    end;
  end;
end;

procedure TfFormHYData_Each.EditCardPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr: string;
begin
  EditCard.Text := Trim(EditCard.Text);
  if EditCard.Text = '' then
  begin
    EditCard.SetFocus;
    ShowMsg('����д�ſ���', sHint); Exit;
  end;

  TruckList1.Clear;
  LoadBillData(EditCard.Text, '');
end;

procedure TfFormHYData_Each.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr: string;
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then
  begin
    EditTruck.SetFocus;
    ShowMsg('�����복�ƺ�', sHint); Exit;
  end;

  TruckList1.Clear;
  LoadBillData('', EditTruck.Text);
end;

//Desc: ѡ���¼
procedure TfFormHYData_Each.TruckList1Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  EditStockNo.Clear;
  ParamList1.Clear;

  if TruckList1.ItemIndex > -1 then
  with FTrucks[TruckList1.ItemIndex] do
  begin
    EditStockNo.Text := FStockNo;
    EditStockNo.Properties.ReadOnly := True;

    nStr := '';
    for nIdx:=Low(FLadingID) to High(FLadingID) do
     if nStr = '' then
          nStr := FLadingID[nIdx]
     else nStr := nStr + ',' + FLadingID[nIdx];
    EditLading.Text := nStr;
    EditLDate.Date := FLadTime;
  end;
end;

procedure TfFormHYData_Each.EditStockNoPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_ViewData;
  nP.FParamA := Trim(EditNo.Text);
  CreateBaseFormItem(cFI_FormGetStockNo, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    EditNo.Text := nP.FParamB;
    LoadStockRecord(EditNo.Text);
  end;
end;

//Desc: ����ˮ����ΪnID�ļ����¼
function TfFormHYData_Each.LoadStockRecord(const nID: string): Boolean;
var nStr: string;
begin
  Result := False;
  ParamList1.Clear;

  nStr := 'Select Top 1 * From %s Where R_serialNo=''%s'' Order By R_ID DESC';
  nStr := Format(nStr, [sTable_StockRecord, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
    First;

    nStr := '����þ' + ParamList1.Delimiter + FieldByName('R_MgO').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '��������' + ParamList1.Delimiter + FieldByName('R_SO3').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '��ʧ��' + ParamList1.Delimiter + FieldByName('R_ShaoShi').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '������' + ParamList1.Delimiter + FieldByName('R_CL').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := 'ϸ��' + ParamList1.Delimiter + FieldByName('R_XiDu').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '���' + ParamList1.Delimiter + FieldByName('R_ChouDu').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '���' + ParamList1.Delimiter + FieldByName('R_Jian').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '������' + ParamList1.Delimiter + FieldByName('R_BuRong').AsString + ' ';
    ParamList1.Items.Add(nStr);
    
    nStr := '�ȱ����' + ParamList1.Delimiter + FieldByName('R_BiBiao').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '����ʱ��' + ParamList1.Delimiter + FieldByName('R_ChuNing').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '����ʱ��' + ParamList1.Delimiter + FieldByName('R_ZhongNing').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '������' + ParamList1.Delimiter + FieldByName('R_AnDing').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);

    nStr := '����1(3D)' + ParamList1.Delimiter + FieldByName('R_3DZhe1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '����2(3D)' + ParamList1.Delimiter + FieldByName('R_3DZhe2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '����3(3D)' + ParamList1.Delimiter + FieldByName('R_3DZhe3').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);
    
    nStr := '����1(28D)' + ParamList1.Delimiter + FieldByName('R_28Zhe1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '����2(28D)' + ParamList1.Delimiter + FieldByName('R_28Zhe2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '����3(28D)' + ParamList1.Delimiter + FieldByName('R_28Zhe3').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);

    nStr := '��ѹ1(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ2(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ3(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa3').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ4(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa4').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ5(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa5').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ6(3D)' + ParamList1.Delimiter + FieldByName('R_3DYa6').AsString + ' ';
    ParamList1.Items.Add(nStr);

    nStr := '-' + ParamList1.Delimiter + '-';
    ParamList1.Items.Add(nStr);
    
    nStr := '��ѹ1(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya1').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ2(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya2').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ3(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya3').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ4(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya4').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ5(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya5').AsString + ' ';
    ParamList1.Items.Add(nStr);
    nStr := '��ѹ6(28D)' + ParamList1.Delimiter + FieldByName('R_28Ya6').AsString + ' ';
    ParamList1.Items.Add(nStr);
  end;
end;

//Desc: �����Ŀ
procedure TfFormHYData_Each.ParamList1Click(Sender: TObject);
var nStr: string;
    nPos: integer;
begin
  if ParamList1.ItemIndex > -1 then
  begin
    nStr := ParamList1.Items[ParamList1.ItemIndex];
    nPos := Pos(ParamList1.Delimiter, nStr);

    EditItem.Text := Copy(nStr, 1, nPos - 1);
    System.Delete(nStr, 1, nPos);
    EditValue.Text := nStr;
  end;
end;

function TfFormHYData_Each.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nStr: string;
begin
  Result := True;

  if Sender = TruckList1 then
  begin
    Result := TruckList1.ItemIndex > -1;
    nHint := '��ѡ���������';
  end else

  if Sender = EditRDate then
  begin
    Result := EditRDate.Date >= EditLDate.Date;
    nHint := '��������Ӧ�����������';
  end else

  if Sender = EditReporter then
  begin
    EditReporter.Text := Trim(EditReporter.Text);
    Result := EditReporter.Text <> '';
    nHint := '����д��Ч�ı�����';
  end else

  if Sender = EditStockNo then
  begin
    nStr := 'Select Count(*) From %s Where R_serialNo=''%s''';
    nStr := Format(nStr, [sTable_StockRecord, EditStockNo.Text]);

    with FDM.QueryTemp(nStr) do
    begin
      Result := (RecordCount > 0) and (Fields[0].AsInteger > 0);
      nHint := '��Ч��ˮ����';
    end;
  end;
end;

//Desc: ����
procedure TfFormHYData_Each.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nIdx: Integer;
begin
  if not IsDataValid then Exit;
  nID := GetSerialNo(sFlag_BusGroup, sFlag_HYDan, True);
  if nID = '' then Exit;

  FDM.ADOConn.BeginTrans;
  try
    with FTrucks[TruckList1.ItemIndex] do
    begin
      nStr := MakeSQLByStr([SF('H_No', nID);
              SF('H_SerialNo'), EditStockNo.Text],
              SF('H_Truck', FTruck),
              SF('H_Value', FValue, sfVal),
              SF('H_BillDate', DateTime2Str(EditLDate.Date)),
              SF('H_ReportDate', DateTime2Str(EditRDate.Date)),
              SF('H_Reporter', EditReporter.Text),
              SF('H_EachTruck', sFlag_Yes)]
              sTable_StockHuaYan, '', True);
      FDM.ExecuteSQL(nStr);

      nStr := 'Update %s Set L_HYDan=''%s'' Where L_ID=%d';
      nStr := Format(nStr, [stable, nID, nIdx]);
      FDM.ExecuteSQL(nStr);
    end;

    FDM.ADOConn.CommitTrans;
    //xxxxx
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('���鵥����ʧ��', sHint); Exit;
  end;

  nStr := Format('''%s''', [nID]);
  PrintHuaYanReport_Each(nStr, True);
  PrintHeGeReport_Each(nStr, True);

  ModalResult := mrOk;
  ShowMsg('���鵥�ѳɹ�����', sHint);   
end;

initialization
  gControlManager.RegCtrl(TfFormHYData_Each, TfFormHYData_Each.FormID);
end.
