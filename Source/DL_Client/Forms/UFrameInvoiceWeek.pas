{*******************************************************************************
  ����: dmzn@163.com 2011-01-23
  ����: ��Ʊ��������
*******************************************************************************}
unit UFrameInvoiceWeek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameInvoiceWeek = class(TfFrameNormal)
    EditName: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditDesc: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditSName: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditSID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxView1FocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    {*ʱ������*}
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
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness,
  UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameInvoiceWeek.FrameID: integer;
begin
  Result := cFI_FrameInvoiceWeek;
end;

procedure TfFrameInvoiceWeek.OnCreateFrame;
var nY,nM,nD: Word;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);

  if FStart = FEnd then
  begin
    DecodeDate(FStart, nY, nM, nD);
    FStart := EncodeDate(nY, 1, 1);
    FEnd := EncodeDate(nY+1, 1, 1) - 1;
  end;
end;

procedure TfFrameInvoiceWeek.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//------------------------------------------------------------------------------
//Desc: ���ݲ�ѯSQL
function TfFrameInvoiceWeek.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select * From $Week ';

  if nWhere = '' then
       Result := Result + 'Where (W_Date>=''$S'' and W_Date <''$E'')'
  else Result := Result + 'Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$Week', sTable_InvoiceWeek),
            MI('$S', Date2Str(FStart)), MI('$E', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//Desc: ���
procedure TfFrameInvoiceWeek.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormInvoiceWeek, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFrameInvoiceWeek.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('W_NO').AsString;
  CreateBaseFormItem(cFI_FormInvoiceWeek, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFrameInvoiceWeek.BtnDelClick(Sender: TObject);
var nStr,nID: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nID := SQLQuery.FieldByName('W_Name').AsString;
  nStr := Format('ȷ��Ҫɾ������Ϊ[ %s ]�ļ�¼��?', [nID]);
  if not QueryDlg(nStr, sAsk) then Exit;

  nID := SQLQuery.FieldByName('W_NO').AsString;
  nStr := 'Select Count(*) From %s Where I_Week=''%s'' And I_Status=''%s''';
  nStr := Format(nStr, [sTable_Invoice, nID, sFlag_InvHasUsed]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nStr := '����[ %d ]�ŷ�Ʊ�ڱ������ڿ���,ɾ������ʧ��!';
      nStr := Format(nStr, [Fields[0].AsInteger]);
      ShowDlg(nStr, sHint); Exit;
    end;
  end else
  begin
    ShowMsg('��ȡ����״̬ʧ��', sHint); Exit;
  end;

  nStr := 'Delete From %s Where W_NO=''%s''';
  nStr := Format(nStr, [sTable_InvoiceWeek, nID]);
  FDM.ExecuteSQL(nStr);

  InitFormData(FWhere);
  ShowMsg('��¼��ɾ��', sHint);
end;

//Desc: ִ�в�ѯ
procedure TfFrameInvoiceWeek.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'W_NO like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'W_Name like ''%' + EditName.Text + '%''';
    InitFormData(FWhere);
  end;
end;

//Desc: ����ɸѡ
procedure TfFrameInvoiceWeek.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

procedure TfFrameInvoiceWeek.cxView1FocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if FShowDetailInfo and Assigned(APrevFocusedRecord) then
  begin
    EditSID.Text := SQLQuery.FieldByName('W_NO').AsString;
    EditSName.Text := SQLQuery.FieldByName('W_Name').AsString;
    EditDesc.Text := Format('%s �� %s', [
            Date2Str(SQLQuery.FieldByName('W_Begin').AsDateTime),
            Date2Str(SQLQuery.FieldByName('W_End').AsDateTime)]);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameInvoiceWeek, TfFrameInvoiceWeek.FrameID);
end.
