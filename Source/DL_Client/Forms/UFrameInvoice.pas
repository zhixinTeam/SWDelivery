{*******************************************************************************
  ����: dmzn@163.com 2010-01-24
  ����: ��Ʊ����
*******************************************************************************}
unit UFrameInvoice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, cxLookAndFeels,
  cxLookAndFeelPainters, UBitmapPanel, cxSplitter;

type
  TfFrameInvoice = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxView1DblClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //ʱ������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    {*���ຯ��*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, USysBusiness, UDataModule,
  UFormDateFilter, UFormInvoiceK, UFormBase;

class function TfFrameInvoice.FrameID: integer;
begin
  Result := cFI_FrameSaleInvoice;
end;

procedure TfFrameInvoice.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameInvoice.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: �ر�
procedure TfFrameInvoice.BtnExitClick(Sender: TObject);
begin
  if not IsBusy then
  begin      
    CloseInvoiceInfoForm; Close;
  end;  
end;

//------------------------------------------------------------------------------
//Desc: ���ݲ�ѯSQL
function TfFrameInvoice.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select inv.*,W_Name From $Inv inv ' +
            ' Left Join $Week On W_NO=inv.I_Week ';

  if nWhere = '' then
       Result := Result + 'Where (I_InDate>=''$S'' And I_InDate<''$E'')'
  else Result := Result + 'Where ( ' + nWhere + ' )';

  Result := MacroValue(Result, [MI('$Inv', sTable_Invoice),
            MI('$Week', sTable_InvoiceWeek),
            MI('$S', Date2Str(FStart)), MI('$E', Date2Str(FEnd+1))]);
  //xxxxx
end;

//Desc: ���
procedure TfFrameInvoice.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormSaleInvoice, PopedomItem, @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: ���Ϸ�Ʊ
procedure TfFrameInvoice.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ���ϵķ�Ʊ��¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('I_ID').AsString;
  if not QueryDlg('ȷ��Ҫ���ϱ��Ϊ[ ' + nStr + ' ]�ķ�Ʊ��?', sAsk) then Exit;

  nSQL := SQLQuery.FieldByName('I_Week').AsString;
  if (nSQL <> '') and IsNextWeekEnable(nSQL) then
  begin
    ShowMsg('��Ʊ���������ѽ���', sHint); Exit;
  end;

  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'Update %s Set I_Status=''%s'' Where I_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Invoice, sFlag_InvInvalid, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Select Sum(D_DisMoney) From %s ' +
            ' Left Join %s On D_Invoice=I_ID ' +
            'Where I_ID=''%s'' And I_Status=''%s''';
    nSQL := Format(nSQL, [sTable_Invoice, sTable_InvoiceDtl, nStr, sFlag_InvHasUsed]);

    with FDM.QueryTemp(nSQL) do
    if Fields[0].AsFloat <> 0 then
    begin
      nStr := Format('���Ϸ�Ʊ[ %s ]ʱ�ۿ۷���', [nStr]);
      if not SaveCompensation(SQLQuery.FieldByName('I_SaleID').AsString,
        SQLQuery.FieldByName('I_CusID').AsString,
        SQLQuery.FieldByName('I_Customer').AsString, '�����ۿ�', nStr,
        Fields[0].AsFloat) then raise Exception.Create('');
    end;            

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('ָ����Ʊ������', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('����ʧ��', sError);
  end;
end;

//Desc: �鿴��Ʊ
procedure TfFrameInvoice.cxView1DblClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('I_ID').AsString;
    ShowInvoiceInfoForm(nStr);
  end;
end;

//Desc: ִ�в�ѯ
procedure TfFrameInvoice.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then exit;

    FWhere := 'I_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then exit;

    FWhere := 'I_CusID like ''%%%s%%'' Or I_Customer like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ����ɸѡ
procedure TfFrameInvoice.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFrameInvoice, TfFrameInvoice.FrameID);
end.
