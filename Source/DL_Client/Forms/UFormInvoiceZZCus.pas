{*******************************************************************************
  ����: dmzn@163.com 2011-02-11
  ����: ��ָ���ͻ�����
*******************************************************************************}
unit UFormInvoiceZZCus;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxRadioGroup, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, Menus, cxButtons, cxCheckBox;

type
  TfFormInvoiceZZCus = class(TfFormNormal)
    dxLayout1Item12: TdxLayoutItem;
    EditMemo: TcxMemo;
    EditWeek: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    cxLevel1: TcxGridLevel;
    cxGrid1: TcxGrid;
    dxLayout1Item5: TdxLayoutItem;
    cxView1: TcxGridTableView;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    cxColumn2: TcxGridColumn;
    cxColumn3: TcxGridColumn;
    cxColumn1: TcxGridColumn;
    cxColumn0: TcxGridColumn;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure EditCusPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FLastInterval: Cardinal;
    //�ϴ�ִ��
    FNowYear,FNowWeek,FWeekName: string;
    //���ڲ���
    procedure InitFormData;
    //��������
    procedure ShowNowWeek;
    //��ʾ����
    procedure ShowHintText(const nText: string);
    //��ʾ����
    procedure ZZ_Cus(const nNeedCombine: Boolean);
    //���˲���
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormBase, UMgrControl, UDataModule, UFormCtrl, USysDB,
  USysConst, USysBusiness, USysGrid;


type
  PCustomerItem = ^TCustomerItem;
  TCustomerItem = record
    FChecked: Boolean;
    FCusID: string;
    FCusName: string;
    FSaleMan: string;
  end;

  TCustomerItems = class(TcxCustomDataSource)
  private
    FOwner: TForm;
    FDataList: TList;
  protected
    procedure ClearData(const nFree: Boolean);
    //������Դ
    function GetRecordCount: Integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle;
     AItemHandle: TcxDataItemHandle): Variant; override;
    procedure SetValue(ARecordHandle: TcxDataRecordHandle;
     AItemHandle: TcxDataItemHandle; const AValue: Variant); override;
     //��д����
  public
    constructor Create(AOwner: TForm);
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadCustomers(const nWhere: string = '');
    //��ȡ�ͻ�
    property Customers: TList read FDataList;
    //�������
  end;

var
  gCustomers: TCustomerItems = nil;
  //ȫ��ʹ��

constructor TCustomerItems.Create(AOwner: TForm);
begin
  FOwner := AOwner;
  FDataList := TList.Create;
end;

destructor TCustomerItems.Destroy;
begin
  ClearData(True);
  inherited;
end;

procedure TCustomerItems.ClearData(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FDataList.Count - 1 downto 0 do
  begin
    Dispose(PCustomerItem(FDataList[nIdx]));
    FDataList.Delete(nIdx);
  end;

  if nFree then
    FDataList.Free;
  //xxxxx
end;

//Desc: ��ȡ�ͻ�
procedure TCustomerItems.LoadCustomers(const nWhere: string);
var nStr: string;
    nItem: PCustomerItem;
begin
  nStr := 'Select C_ID,C_Name,S_Name From %s' +
          ' Left Join %s On S_ID=C_SaleMan %s ' +
          'Order By C_PY';
  nStr := Format(nStr, [sTable_Customer, sTable_Salesman, nWhere]);

  ClearData(False);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
         Exit
    else First;

    while not Eof do
    begin
      New(nItem);
      FDataList.Add(nItem);

      nItem.FChecked := False;
      nItem.FCusID := Fields[0].AsString;
      nItem.FCusName := Fields[1].AsString;
      nItem.FSaleMan := Fields[2].AsString;
      Next;
    end;
  end;
end;

function TCustomerItems.GetRecordCount: Integer;
begin
  Result := FDataList.Count;
end;

function TCustomerItems.GetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle): Variant;
var nColumn: Integer;
    nItem: PCustomerItem;
begin
  nColumn := GetDefaultItemID(Integer(AItemHandle));
  nItem := FDataList[Integer(ARecordHandle)];

  case nColumn of
    0: Result := nItem.FChecked;
    1: Result := nItem.FSaleMan;
    2: Result := nItem.FCusID;
    3: Result := nItem.FCusName;
  end;
end;

procedure TCustomerItems.SetValue(ARecordHandle: TcxDataRecordHandle;
  AItemHandle: TcxDataItemHandle; const AValue: Variant);
var nColumn: Integer;
    nItem: PCustomerItem;
begin
  nColumn := GetDefaultItemID(Integer(AItemHandle));
  nItem := FDataList[Integer(ARecordHandle)];

  case nColumn of
    0: nItem.FChecked := AValue;
  end;
end;

//------------------------------------------------------------------------------
class function TfFormInvoiceZZCus.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  nP := nParam;
  if nP.FCommand <> cCmd_AddData then Exit;

  with TfFormInvoiceZZCus.Create(Application) do
  try
    if not Assigned(gCustomers) then
      gCustomers := TCustomerItems.Create(nil);
    cxView1.DataController.CustomDataSource := gCustomers;

    Caption := '����(ָ���ͻ�)';
    InitFormData;

    gCustomers.LoadCustomers;
    gCustomers.DataChanged;
    //fill customers

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
    FreeAndNil(gCustomers);
  end;
end;

class function TfFormInvoiceZZCus.FormID: integer;
begin
  Result := cFI_FormSaleZZCus;
end;

procedure TfFormInvoiceZZCus.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    InitTableView(Name, cxView1, nIni);

    cxView1.OptionsBehavior.ImmediateEditor := True;
    TcxCheckBoxProperties(cxColumn0.Properties).ReadOnly := False;
  finally
    nIni.Free;
  end;
end;

procedure TfFormInvoiceZZCus.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveUserDefineTableView(Name, cxView1, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormInvoiceZZCus.ShowNowWeek;
begin
  if FNowWeek = '' then
       EditWeek.Text := '��ѡ���������'
  else EditWeek.Text := Format('%s ���:[ %s ]', [FWeekName, FNowYear]);

  EditWeek.SelStart := 0;
  EditWeek.SelLength := 0;
  Application.ProcessMessages;
end;

procedure TfFormInvoiceZZCus.InitFormData;
var nP: TFormCommandParam;
begin
  FNowYear := '';
  FNowWeek := '';
  FWeekName := '';
  nP.FCommand := cCmd_GetData;
  
  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  nP.FParamE := sFlag_Yes;
  CreateBaseFormItem(cFI_FormInvGetWeek, PopedomItem, @nP);

  if nP.FCommand = cCmd_ModalResult then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;
  end;

  ShowNowWeek;
end;

//Desc: ѡ��ǰ��ͼ������
procedure TfFormInvoiceZZCus.N4Click(Sender: TObject);
var nItem: PCustomerItem;
    i,nCount,nIdx: Integer;
begin
  nItem := nil;
  nCount := cxView1.ViewData.RowCount - 1;

  for i:=0 to nCount do
  begin
    nIdx := cxView1.ViewData.Rows[i].RecordIndex;
    nItem := gCustomers.Customers[nIdx];

    case TComponent(Sender).Tag of
     10: nItem.FChecked := True;
     20: nItem.FChecked := False;
     30: nItem.FChecked := not nItem.FChecked;
    end;
  end;

  if Assigned(nItem) then gCustomers.DataChanged;
end;

//Desc: ����ѡ��
procedure TfFormInvoiceZZCus.N3Click(Sender: TObject);
var nStr: string;
    i,nLen: Integer;
    nList: TStrings;
    nItem: PCustomerItem;
begin
  with TSaveDialog.Create(Application) do
  try
    Title := '��������';
    DefaultExt := '.zzc';
    Filter := '���˿ͻ�(*.zzc)|*.zzc';
    Options := Options + [ofOverwritePrompt];

    if Execute then
         nStr := FileName
    else Exit;
  finally
    Free;
  end;

  nList := TStringList.Create;
  try
    nLen := gCustomers.Customers.Count - 1;
    for i:=0 to nLen do
    begin
      nItem := gCustomers.Customers[i];
      if nItem.FChecked then nList.Add(nItem.FCusID);
    end;

    nList.SaveToFile(nStr);
    ShowMsg('����ɹ�', sHint);
  finally
    nList.Free;
  end;
end;

//Desc: ����ѡ��
procedure TfFormInvoiceZZCus.N1Click(Sender: TObject);
var nStr: string;
    nList: TStrings;
    i,nLen: Integer;
    nItem: PCustomerItem;
begin
  with TSaveDialog.Create(Application) do
  try
    Title := '��������';
    Filter := '���˿ͻ�(*.zzc)|*.zzc';
    Options := Options + [ofFileMustExist];

    if Execute then
         nStr := FileName
    else Exit;
  finally
    Free;
  end;

  nList := TStringList.Create;
  try
    nList.LoadFromFile(nStr);
    nLen := gCustomers.Customers.Count - 1;

    for i:=0 to nLen do
    begin
      nItem := gCustomers.Customers[i];
      nItem.FChecked := nList.IndexOf(nItem.FCusID) > -1;
    end;

    gCustomers.DataChanged;
  finally
    nList.Free;
  end;
end;

procedure TfFormInvoiceZZCus.EditCusPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr: string;
begin
  EditCus.Text := Trim(EditCus.Text);
  if EditCus.Text = '' then Exit;

  nStr := 'Where C_PY Like ''%%%s%%'' Or C_Name Like ''%%%s%%''';
  nStr := Format(nStr, [EditCus.Text, EditCus.Text]);
  
  gCustomers.LoadCustomers(nStr);
  gCustomers.DataChanged;
end;

//------------------------------------------------------------------------------
procedure TfFormInvoiceZZCus.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
  Application.ProcessMessages;

  if GetTickCount - FLastInterval < 500 then
    Sleep(375);
  FLastInterval := GetTickCount;
end;

procedure TfFormInvoiceZZCus.EditWeekPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_GetData;
  nP.FParamA := FNowYear;
  nP.FParamB := FNowWeek;
  CreateBaseFormItem(cFI_FormInvGetWeek, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    FNowYear := nP.FParamB;
    FNowWeek := nP.FParamC;
    FWeekName := nP.FParamD;
  end;

  ShowNowWeek;
end;

//Desc: ׼�����˿ͻ�
function PrepareZZCustomer: Boolean;
var nStr: string;
    i,nLen,nNum: Integer;
    nItem: PCustomerItem;
begin
  nStr := 'Delete From ' + sTable_DataTemp;
  FDM.ExecuteSQL(nStr);

  nNum := 0;
  nLen := gCustomers.Customers.Count - 1;

  for i:=0 to nLen do
  begin
    nItem := gCustomers.Customers[i];
    if not nItem.FChecked then Continue;

    nStr := 'Insert Into %s(T_SysID) Values(''%s'')';
    nStr := Format(nStr, [sTable_DataTemp, nItem.FCusID]);
    FDM.ExecuteSQL(nStr); Inc(nNum);
  end;

  Result := nNum > 0;
end;

//Desc: ��ʼ����
procedure TfFormInvoiceZZCus.BtnOKClick(Sender: TObject);
var nStr: string;
    nInt: Integer;
begin
  if FNowWeek = '' then
  begin
    EditWeek.SetFocus;
    ShowMsg('��ѡ����Ч������', sHint); Exit;
  end;

  if not IsWeekValid(FNowWeek, nStr) then
  begin
    EditWeek.SetFocus;
    ShowMsg(nStr, sHint); Exit;
  end;

  if IsNextWeekEnable(FNowWeek) then
  begin
    nStr := '�������ѽ���,ϵͳ��ֹ�ٴ�����!';
    ShowDlg(nStr, sHint); Exit;
  end;

  nInt := IsPreWeekOver(FNowWeek);
  if nInt > 0 then
  begin
    nStr := Format('��ǰ���ڻ���[ %d ]��δ�������,���ȴ���!', [nInt]);
    ShowDlg(nStr, sHint); Exit;
  end;

  if IsWeekHasEnable(FNowWeek) then
  begin
    nStr := '�������������˿ɼ�¼,ͬ�ͻ����ݿ��ܻᱻ����.' + #13#10 +
            'Ҫ������?';
    if not QueryDlg(nStr, sAsk) then Exit;

    nInt := 10;
  end else nInt := 0;

  nStr := '�ò���������Ҫһ��ʱ��,�����ĵȺ�.' + #13#10 +
          'Ҫ������?';
  if not QueryDlg(nStr, sAsk) then Exit;

  if not PrepareZZCustomer then
  begin
    ShowMsg('��ѡ����Ч�Ŀͻ�', sHint); Exit;
  end;
  //no valid customer

  BtnOK.Enabled := False;
  try
    EditMemo.Clear;          
    ZZ_Cus(nInt > 0);
  except
    on E:Exception do
    begin
      BtnOK.Enabled := True;
      ShowHintText(E.Message); Exit;
    end;
  end;

  FDM.ADOConn.BeginTrans;
  try
    if nInt > 0 then
    begin
      nStr := 'Delete From %s Where R_Week=''%s'' And ' +
              'R_CusID In (Select T_SysID From %s)';
      nStr := Format(nStr, [sTable_InvoiceReq, FNowWeek, sTable_DataTemp]);
      FDM.ExecuteSQL(nStr);
    end;

    nStr := 'Insert Into %s(R_Week,R_CusID,R_Customer,R_SaleID,R_SaleMan,' +
            'R_Type,R_Stock,R_Price,R_Value,R_PreHasK,R_ReqValue,R_KPrice,' +
            'R_KValue,R_KOther,R_Man,R_Date) ' +
            ' Select R_Week,R_CusID,R_Customer,R_SaleID,R_SaleMan,' +
            ' R_Type,R_Stock,R_Price,R_Value,R_PreHasK,R_ReqValue,R_KPrice,' +
            ' R_KValue,R_KOther,R_Man,R_Date From %s';
    //move into normal table

    nStr := Format(nStr, [sTable_InvoiceReq, sTable_InvReqtemp]);
    FDM.ExecuteSQL(nStr);

    nStr := '�û�[ %s ]������[ %s ]ִ�����˲���.';
    nStr := Format(nStr, [gSysParam.FUserID, FWeekName]);
    FDM.WriteSysLog(sFlag_CommonItem, FNowWeek, nStr, False);

    FDM.ADOConn.CommitTrans;      
    ModalResult := mrOk;
    ShowMsg('���˲������', sHint);
  except
    on E:Exception do
    begin
      BtnOK.Enabled := True;
      FDM.ADOConn.RollbackTrans;
      ShowHintText(E.Message);
    end;
  end;
end;

//Desc: ִ������
procedure TfFormInvoiceZZCus.ZZ_Cus(const nNeedCombine: Boolean);
var nStr,nSQL: string;
begin
  nStr := 'Delete From ' + sTable_InvReqtemp;
  FDM.ExecuteSQL(nStr);
  //�����ʱ��

  nSQL := 'Select L_SaleID,L_CusID,L_Type,L_StockName,L_Price,' +
          'Sum(L_Value) as L_Value,L_SaleMan,L_CusName From $Bill ' +
          'Where  L_OutFact Is Not Null And L_CusID In (Select T_SysID From $Tmp) ' +
          'Group By L_SaleID,L_SaleMan,L_CusID,L_CusName,L_Type,L_StockName,L_Price';
  nSQL := MacroValue(nSQL, [MI('$Bill', sTable_Bill), MI('$Yes', sFlag_Yes),
          MI('$Tmp', sTable_DataTemp)]);
  //ͬ�ͻ�ͬƷ��ͬ���ۺϲ�

  nStr := 'Select ''$W'' As R_Week,''$Man'' As R_Man,$Now As R_Date,' +
          'b.* From ($Bill) b ';
  nSQL := MacroValue(nStr, [MI('$W', FNowWeek), MI('$Bill', nSQL),
           MI('$Man', gSysParam.FUserID), MI('$Now', FDM.SQLServerNow)]);
  //�ϲ���Ч����

  nStr := 'Insert Into %s(R_Week,R_Man,R_Date,R_SaleID,R_CusID,' +
          'R_Type,R_Stock,R_Price,R_Value,R_SaleMan,R_Customer) Select * From (%s) t';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('��ʼ����ͻ��������...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('�ͻ���������������!');

  //----------------------------------------------------------------------------
  nSQL := 'Select I_CusID,I_SaleID,D_Type,D_Stock,D_Price,Sum(D_Value) As D_Value From' +
          '( Select * From $Dtl Left Join $Inv On I_ID=D_Invoice ' +
          '  Where I_Status=''$Use'' And I_Week<>''$W''' +
          ') inv Group By I_CusID,I_SaleID,D_Type,D_Stock,D_Price';
  nSQL := MacroValue(nSQL, [MI('$Dtl', sTable_InvoiceDtl), MI('$W', FNowWeek),
          MI('$Inv', sTable_Invoice), MI('$Use', sFlag_InvHasUsed)]);
  //�Ǳ����ڵ����з�Ʊ

  nStr := 'Update %s Set R_PreHasK=D_Value From (%s) t ' +
          'Where I_CusID=R_CusID And I_SaleID=R_SaleID And D_Type=R_Type And ' +
          'D_Stock=R_Stock And D_Price=R_Price';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('��ʼ����ͻ�������֮ǰ�ܿ�Ʊ��...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('�ͻ�������֮ǰ�ܿ�Ʊ���������!');

  //----------------------------------------------------------------------------
  {+2011.02.15: ��ʱδʹ�÷�����
  nSQL := 'Select I_CusID,D_Type,D_Stock,D_Price,Sum(D_Value) As D_Value From' +
          '( Select * From $Dtl Left Join $Inv On I_ID=D_Invoice ' +
          '  Where I_Status=''$Use'' And I_Week=''$W'' And ' +
          '  IsNull(I_Flag,'''')<>''$Req''' +
          ') inv Group By I_CusID,D_Type,D_Stock,D_Price';
  nSQL := MacroValue(nSQL, [MI('$Dtl', sTable_InvoiceDtl), MI('$W', FNowWeek),
          MI('$Inv', sTable_Invoice), MI('$Use', sFlag_InvHasUsed),
          MI('$Req', sFlag_InvRequst)]);
  //�����ڵķ���������

  nStr := 'Update %s Set R_KOther=D_Value From (%s) t ' +
          'Where I_CusID=R_CusID And D_Type=R_Type And D_Stock=R_Stock And ' +
          'D_Price=R_Price';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('��ʼ����ͻ������ڷ������ѿ�Ʊ��...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('�ͻ������ڷ������ѿ�Ʊ���������!');
  }
  //----------------------------------------------------------------------------
  nSQL := 'Select I_CusID,I_SaleID,D_Type,D_Stock,D_Price,Sum(D_Value) As D_Value From' +
          '( Select * From $Dtl Left Join $Inv On I_ID=D_Invoice ' +
          '  Where I_Status=''$Use'' And I_Week=''$W'' And I_Flag=''$Req''' +
          ') inv Group By I_CusID,I_SaleID,D_Type,D_Stock,D_Price';
  nSQL := MacroValue(nSQL, [MI('$Dtl', sTable_InvoiceDtl), MI('$W', FNowWeek),
          MI('$Inv', sTable_Invoice), MI('$Use', sFlag_InvHasUsed),
          MI('$Req', sFlag_InvRequst)]);
  //�����ڵ���������

  nStr := 'Update %s Set R_KValue=D_Value From (%s) t ' +
          'Where I_CusID=R_CusID And I_SaleID=R_SaleID And D_Type=R_Type And ' +
          'D_Stock=R_Stock And D_Price=R_Price';
  nStr := Format(nStr, [sTable_InvReqtemp, nSQL]);

  ShowHintText('��ʼ����ͻ������������ѿ�Ʊ��...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('�ͻ������������ѿ�Ʊ���������!');

  //----------------------------------------------------------------------------
  if nNeedCombine then
  begin
    nSQL := 'Update $T Set $T.R_KPrice=$R.R_KPrice,$T.R_ReqValue=$T.R_Value-' +
            '$T.R_PreHasK-$T.R_KOther From $R Where $R.R_Week=''$W'' And ' +
            '$T.R_CusID=$R.R_CusID And $T.R_SaleID=$R.R_SaleID And ' +
            '$T.R_Type=$R.R_Type And $T.R_Stock=$R.R_Stock And $T.R_Price=$R.R_Price';
    nStr := MacroValue(nSQL, [MI('$T', sTable_InvReqtemp),
            MI('$R', sTable_InvoiceReq), MI('$W', FNowWeek)]);
    //xxxxx

    ShowHintText('��ʼ�ϲ��ϴ���������...');
    FDM.ExecuteSQL(nStr);
    ShowHintText('�ϲ��ϴ������������!');
  end;

  nSQL := 'Update %s Set R_KPrice=R_Price,R_ReqValue=R_Value-' +
          'IsNull(R_PreHasK,0)-IsNull(R_KOther,0) ' +
          'Where IsNull(R_KPrice,0)=0 Or IsNull(R_ReqValue,0)=0';
  nStr := Format(nSQL, [sTable_InvReqtemp]);

  ShowHintText('��ʼ�ϲ���������...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('���ݺϲ����!');
  
  nStr := 'Delete From %s Where IsNull(R_ReqValue,0)=0';
  nStr := Format(nStr, [sTable_InvReqtemp]);

  ShowHintText('��ʼ������ʱ��Ч����...');
  FDM.ExecuteSQL(nStr);
  ShowHintText('��Ч�����������!');
end;

initialization
  gControlManager.RegCtrl(TfFormInvoiceZZCus, TfFormInvoiceZZCus.FormID);
end.
