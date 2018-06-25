{*******************************************************************************
  ����: dmzn@163.com 2010-01-24
  ����: ��Ʊ��ϸ
*******************************************************************************}
unit UFrameInvoiceDtl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxDropDownEdit, Menus;

type
  TfFrameInvoiceDtl = class(TfFrameNormal)
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditWeek: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    procedure EditWeekPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCusPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FNowYear,FNowWeek,FWeekName: string;
    //��ǰ����
    procedure OnCreateFrame; override;
    {*���ຯ��*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
    procedure LoadDefaultWeek;
    //Ĭ������
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormDateFilter,
  UFormBase;

class function TfFrameInvoiceDtl.FrameID: integer;
begin
  Result := cFI_FrameSaleJS;
end;

procedure TfFrameInvoiceDtl.OnCreateFrame;
begin
  inherited;
  LoadDefaultWeek;
end;

//------------------------------------------------------------------------------
//Desc: ���ݲ�ѯSQL
function TfFrameInvoiceDtl.InitFormDataSQL(const nWhere: string): string;
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
      nWeek := Format('Where I_Week=''%s''', [FNowWeek]);
    end;
  end;

  Result := 'Select inv.*,dtl.*,D_Value*D_KPrice as D_Money,W_Name From $Inv inv ' +
            ' Left Join $Dtl dtl On dtl.D_Invoice=inv.I_ID ' +
            ' Left Join $Week On W_NO=inv.I_Week ';
  //xxxxx
  
  if nWhere = '' then
       Result := Result + nWeek
  else Result := Result + 'Where ( ' + nWhere + ' )';

  Result := MacroValue(Result, [MI('$Inv', sTable_Invoice),
            MI('$Dtl', sTable_InvoiceDtl), MI('$Week', sTable_InvoiceWeek)]);
  //xxxxx
end;

//Desc: ����Ĭ������
procedure TfFrameInvoiceDtl.LoadDefaultWeek;
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

procedure TfFrameInvoiceDtl.EditWeekPropertiesButtonClick(Sender: TObject;
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

//Desc: ��ѯ
procedure TfFrameInvoiceDtl.EditCusPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'I_CusID Like ''%%%s%%'' Or I_Customer Like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameInvoiceDtl, TfFrameInvoiceDtl.FrameID);
end.
