{*******************************************************************************
  ����: dmzn@163.com 2011-1-26
  ����: ���߷�Ʊ
*******************************************************************************}
unit UFrameInvoiceK;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, Menus,
  cxLookAndFeels, cxLookAndFeelPainters, UBitmapPanel, cxSplitter;

type
  TfFrameInvoiceK = class(TfFrameNormal)
    EditWeek: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    cxTextEdit6: TcxTextEdit;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PMenu1Popup(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnExitClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FNowYear,FNowWeek,FWeekName: string;
    //��ǰ����
    procedure OnCreateFrame; override;
    procedure OnLoadPopedom; override;
    {*���ຯ��*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
    procedure LoadDefaultWeek;
    //Ĭ������
    function GetVal(const nRow: Integer; const nField: string): string;
    //��ȡ����
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysConst, USysDB, UDataModule, USysPopedom,
  UFormWait, USysDataDict, USysGrid, UFormBase, UFormDateFilter, UFormInvoiceK;

class function TfFrameInvoiceK.FrameID: integer;
begin
  Result := cFI_FrameMakeInvoice;
end;

procedure TfFrameInvoiceK.OnCreateFrame;
begin
  inherited;
  LoadDefaultWeek;
end;

//Desc: ��ȡȨ��
procedure TfFrameInvoiceK.OnLoadPopedom;
var nStr: string;
    nIni: TIniFile;
begin
  if not gSysParam.FIsAdmin then
  begin
    nStr := gPopedomManager.FindUserPopedom(gSysParam.FUserID, PopedomItem);
    BtnAdd.Enabled := Pos(sPopedom_Add, nStr) > 0;
    BtnEdit.Enabled := Pos(sPopedom_Edit, nStr) > 0;
    BtnDel.Enabled := Pos(sPopedom_Delete, nStr) > 0;
    BtnPrint.Enabled := Pos(sPopedom_Print, nStr) > 0;
    BtnPreview.Enabled := Pos(sPopedom_Preview, nStr) > 0;
    BtnExport.Enabled := Pos(sPopedom_Export, nStr) > 0;
  end;

  Visible := False;
  Application.ProcessMessages;
  ShowWaitForm(ParentForm, '��ȡ����');

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    gSysEntityManager.BuildViewColumn(cxView1, 'MAIN_C08');
    //��ʼ����ͷ
    InitTableView(Name, cxView1, nIni);
    //��ʼ������˳��
    OnLoadGridConfig(nIni);
    //������չ��ʼ��
    InitFormData;
    //��ʼ������
  finally
    nIni.Free;
    Visible := True;
    CloseWaitForm;
  end;
end;

procedure TfFrameInvoiceK.BtnExitClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nP.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormViewInvoices, '', @nP);
  end;

  inherited;
end;

//------------------------------------------------------------------------------
//Desc: ���ݲ�ѯSQL
function TfFrameInvoiceK.InitFormDataSQL(const nWhere: string): string;
var nInt: Integer;
    nStr,nWeek: string;
begin
  if (FNowYear = '') and (FNowWeek = '') then
  begin
    Result := '';
    EditWeek.Text := '��ѡ���������'; Exit;
  end else
  begin
    nStr := '���:[ %s ] ����:[ %s ]';
    EditWeek.Text := Format(nStr, [FNowYear, FWeekName]);

    if FNowWeek = '' then
    begin
      nWeek := 'Where (W_Begin>=''$S'' and ' +
               'W_Begin<''$E'') or (W_End>=''$S'' and W_End<''$E'') ' +
               'Order By W_Begin';
      nInt := StrToInt(FNowYear);
      
      nWeek := MacroValue(nWeek, [MI('$W', sTable_InvoiceWeek),
              MI('$S', IntToStr(nInt)), MI('$E', IntToStr(nInt+1))]);
      //xxxxx
    end else
    begin
      nWeek := Format('Where R_Week=''%s''', [FNowWeek]);
    end;
  end;

  Result := 'Select req.*,(R_ReqValue-R_KValue) as R_Need,W_Name From $Req req ' +
            ' Left Join $Week On W_NO=req.R_Week ';
  //xxxxx
  
  if nWhere = '' then
       Result := Result + nWeek
  else Result := Result + 'Where ( ' + nWhere + ' )';

  Result := MacroValue(Result, [MI('$Req', sTable_InvoiceReq),
            MI('$Week', sTable_InvoiceWeek)]);
  //xxxxx
end;

//Desc: ִ�в�ѯ
procedure TfFrameInvoiceK.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'R_CusID Like ''%%%s%%'' Or R_Customer Like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ����Ĭ������
procedure TfFrameInvoiceK.LoadDefaultWeek;
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
end;

procedure TfFrameInvoiceK.EditDatePropertiesButtonClick(Sender: TObject;
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
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ȡnRow��nField�ֶε�����
function TfFrameInvoiceK.GetVal(const nRow: Integer; const nField: string): string;
var nVal: Variant;
begin
  nVal := cxView1.DataController.GetValue(
            cxView1.Controller.SelectedRows[nRow].RecordIndex,
            cxView1.GetColumnByFieldName(nField).Index);
  //xxxxx

  if VarIsNull(nVal) then
       Result := ''
  else Result := nVal;
end;

//Desc: �˵���Ч��
procedure TfFrameInvoiceK.PMenu1Popup(Sender: TObject);
begin
  N1.Enabled := BtnAdd.Enabled;
end;

//Desc: ��ѯδ��
procedure TfFrameInvoiceK.N3Click(Sender: TObject);
begin
  FWhere := 'R_ReqValue<>R_KValue';
  InitFormData(FWhere);
end;

//Desc: �鿴�ѿ���Ʊ��ϸ
procedure TfFrameInvoiceK.N4Click(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount = 1 then
  begin
    nP.FCommand := cCmd_ViewData;
    nP.FParamA := SQLQuery.FieldByName('R_CusID').AsString;
    nP.FParamB := SQLQuery.FieldByName('R_Type').AsString;
    nP.FParamC := SQLQuery.FieldByName('R_Stock').AsString;
    nP.FParamD := SQLQuery.FieldByName('R_Price').AsString;
    CreateBaseFormItem(cFI_FormViewInvoices, '', @nP);
  end;
end;

//Desc: ����Ʊ
procedure TfFrameInvoiceK.BtnAddClick(Sender: TObject);
var nList: TList;
    nVal: Double;
    nIdx,nCount: integer;
    nParam: TKInvoiceParam;
    nItem: PInvoiceDataItem;
    nStr,nCus,nCusID,nSaleID: string;
begin
  nCount := cxView1.DataController.GetSelectedCount - 1;
  if nCount < 0 then
  begin
    ShowMsg('��ѡ�����Ʊ�ļ�¼', sHint); Exit;
  end;

  if FNowWeek = '' then
  begin
    ShowMsg('��ѡ����Ч������', sHint); Exit;
  end;

  nList := TList.Create;
  try
    nCus := GetVal(0, 'R_Customer');
    nCusID := GetVal(0, 'R_CusID');
    nSaleID := GetVal(0, 'R_SaleID');

    for nIdx:=0 to nCount do
    begin
      nStr := GetVal(nIdx, 'R_CusID');
      if CompareText(nStr, nCusID) <> 0 then
      begin
        nStr := GetVal(nIdx, 'R_Customer');
        if CompareText(nStr, nCus) = 0 then
        begin
          nStr := GetVal(nIdx, 'R_ID');
          nStr := Format('��¼[ %s ]������ͻ�ͬ��,���ͻ���Ų�ͬ,' +
                  '���ܿ���ͬһ�ŷ�Ʊ��!', [nStr]);
          //same name
        end else
        begin
          nStr := Format('�ͻ�[ %s ]��[ %s ]���ܿ���ͬһ�ŷ�Ʊ��!', [nStr, nCus]);
        end;

        ShowDlg(nStr, sHint, Handle); Exit;
      end;
      
      nStr := GetVal(nIdx, 'R_SaleID');;
      if nStr <> nSaleID then
      begin
        nStr := 'ҵ��Ա[ %s ]��[ %s ]���ܿ���ͬһ�ŷ�Ʊ��!';
        nStr := Format(nStr, [GetVal(nIdx, 'R_SaleMan'), GetVal(0, 'R_SaleMan')]);
        ShowDlg(nStr, sHint, Handle); Exit;
      end;

      nVal := StrToFloat(GetVal(nIdx, 'R_ReqValue')) -
              StrToFloat(GetVal(nIdx, 'R_KValue'));
      if nVal <= 0 then Continue;
      //����δ��

      New(nItem);
      nList.Add(nItem);
      
      with nItem^ do
      begin
        FValue := nVal;
        FKValue:= FValue;

        FRecordID := GetVal(nIdx, 'R_ID');
        FStockType := GetVal(nIdx, 'R_Type');
        FStockName := GetVal(nIdx, 'R_Stock');
        
        FPrice := StrToFloat(GetVal(nIdx, 'R_Price'));
        FKPrice := StrToFloat(GetVal(nIdx, 'R_KPrice'));         
        FZPrice := FPrice - FKPrice;
      end;
    end;

    with nParam do
    begin
      nParam.FWeek := FNowWeek;
      nParam.FFlag := sFlag_InvRequst;


      FCusID := nCusID;
      FCustomer := nCus;
      FSaleID := nSaleID;
      FSaleMan := GetVal(0, 'R_SaleMan');
    end; //param for k-invoice
    
    if (nList.Count > 0) and ShowSaleKInvioceForm(nList, @nParam) then
    begin
      InitFormData(FWhere);
    end;
  finally
    nCount := nList.Count - 1;
    for nIdx:=0 to nCount do
      Dispose(PInvoiceDataItem(nList[nIdx]));
    nList.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameInvoiceK, TfFrameInvoiceK.FrameID);
end.
