{*******************************************************************************
  ����: dmzn@163.com 2011-01-23
  ����: ��Ʊ����
*******************************************************************************}
unit UFormInvoice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, dxLayoutControl, StdCtrls, cxControls, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxRadioGroup;

type
  TfFormInvoice = class(TfFormNormal)
    dxLayout1Item12: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayout1Item3: TdxLayoutItem;
    Radio1: TcxRadioButton;
    dxLayout1Item5: TdxLayoutItem;
    Radio2: TcxRadioButton;
    dxLayout1Item6: TdxLayoutItem;
    EditNo: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditStart: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditEnd: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure Radio2Click(Sender: TObject);
  private
    { Private declarations }
    FHasAdd: Boolean;
    //�Ƿ����
    procedure InitFormData(const nID: string);
    //��������
    procedure ShowHintText(const nText: string);
    //��ʾ����
    function AddInvoice(const nID: string): Boolean;
    //��ӷ�Ʊ
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UFormBase, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  USysBusiness;

class function TfFormInvoice.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  nP := nParam;
  if nP.FCommand <> cCmd_AddData then Exit;

  with TfFormInvoice.Create(Application) do
  try
    Caption := '��Ʊ - ¼��';
    InitFormData('');

    FHasAdd := False;
    ShowModal;

    nP.FCommand := cCmd_ModalResult;
    if FHasAdd then nP.FParamA := mrOk;
  finally
    Free;
  end;
end;

class function TfFormInvoice.FormID: integer;
begin
  Result := cFI_FormSaleInvoice;
end;

procedure TfFormInvoice.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormInvoice.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormInvoice.InitFormData(const nID: string);
begin
  Radio2Click(nil);
  //set focused
end;

procedure TfFormInvoice.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' :::->> ' + nText);     
end;

procedure TfFormInvoice.Radio2Click(Sender: TObject);
begin
  EditNo.Enabled := Radio1.Checked;
  EditStart.Enabled := Radio2.Checked;
  EditEnd.Enabled := Radio2.Checked;

  if Radio1.Checked then ActiveControl := EditNo;
  if Radio2.Checked then ActiveControl := EditStart;
end;

//Desc: ��ӱ��ΪnID�ķ�Ʊ
function TfFormInvoice.AddInvoice(const nID: string): Boolean;
var nStr,nLID: string;
begin
  Result := False;
  nLID := StrWithWidth(nID, 8, 2, '0');
  try
    nStr := 'Insert Into %s(I_ID,I_Status,I_InMan,I_InDate) Values(''%s'',' +
            '''%s'', ''%s'', %s)';
    nStr := Format(nStr, [sTable_Invoice, nLID, sFlag_InvNormal,
            gSysParam.FUserID, FDM.SQLServerNow]);

    FDM.ExecuteSQL(nStr);
    Result := True;
  except
    nStr := 'Select Count(*) From %s Where I_ID=''%s''';
    nStr := Format(nStr, [sTable_Invoice, nLID]);

    if FDM.QueryTemp(nStr).Fields[0].AsInteger > 0 then
         nStr := '���Ϊ[ %s ]�ķ�Ʊ�Ѵ���!'
    else nStr := '���Ϊ[ %s ]�ķ�Ʊ�޷�д�����ݿ�!';
    ShowHintText(Format(nStr, [nLID]));
  end;
end;

//Desc: ��ӷ�Ʊ
procedure TfFormInvoice.BtnOKClick(Sender: TObject);
var nOK: Boolean;
    nStr: string;
    i,nCount: integer;
begin
  if Radio1.Checked then
  begin
    EditNo.Text := Trim(EditNo.Text);
    if EditNo.Text = '' then
    begin
      EditNo.SetFocus;
      ShowMsg('��������Ч�ı��', sHint); Exit;
    end;

    FHasAdd := AddInvoice(EditNo.Text);
    if FHasAdd then ModalResult := mrOk;
    Exit;
  end;

  if Radio2.Checked then
  begin
    if not IsNumber(EditStart.Text, False) then
    begin
      EditStart.SetFocus;
      ShowMsg('��������Ч�ı��', '����ֵ'); Exit;
    end;

    if not IsNumber(EditEnd.Text, False) then
    begin
      EditEnd.SetFocus;
      ShowMsg('��������Ч�ı��', '����ֵ'); Exit;
    end;

    i := StrToInt(EditStart.Text);
    nCount := StrToInt(EditEnd.Text);

    nStr := Format('����ӷ�Ʊ[ %d ]��,���Ժ�...', [nCount - i + 1]);
    ShowHintText(nStr);

    for i:=i to nCount do
    begin
      nOK := AddInvoice(IntToStr(i));
      if not FHasAdd then FHasAdd := nOK;
      if BtnOK.Enabled then BtnOK.Enabled := nOK;
    end;

    if BtnOK.Enabled then
    begin
      ModalResult := mrOk;
      ShowMsg('��Ʊ��ӳɹ�', sHint);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormInvoice, TfFormInvoice.FormID);
end.
