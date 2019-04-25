unit UFromUPDateBindBillZhiKa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxLabel, cxTextEdit, cxMaskEdit, cxButtonEdit;

type
  TfFormUPDateBindBillZhika = class(TfFormNormal)
    dxLayout1Item3: TdxLayoutItem;
    Edt_NCOrder: TcxButtonEdit;
    cxlbl_NewCus: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item5: TdxLayoutItem;
    cxlbl_ZhiKa: TcxLabel;
    dxLayout1Item6: TdxLayoutItem;
    cxlbl_NewPrice: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    cxlbl_NewStock: TcxLabel;
    dxLayout1Item8: TdxLayoutItem;
    cxlbll_Cus: TcxLabel;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item9: TdxLayoutItem;
    cxlbl_NewZhiKa: TcxLabel;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Item10: TdxLayoutItem;
    cxlbll_Stock: TcxLabel;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Item11: TdxLayoutItem;
    cxlbll_Price: TcxLabel;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Item12: TdxLayoutItem;
    cxlbl_YF: TcxLabel;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Item13: TdxLayoutItem;
    cxlbl_NewYF: TcxLabel;
    dxLayout1Group7: TdxLayoutGroup;
    procedure EditCustomerPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFormUPDateBindBillZhika: TfFormUPDateBindBillZhika;

implementation

{$R *.dfm}


class function TfFormUPDateBindBillZhika.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nBool: Boolean;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  with TfFormUPDateBindBillZhika.Create(Application) do
  try


    ShowModal;
  finally
    Free;
  end;
end;

class function TfFormUPDateBindBillZhika.FormID: integer;
begin
  Result := cFI_FormBill;
end;

procedure TfFormUPDateBindBillZhika.EditCustomerPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
    nP: PFormCommandParam;
begin
  try
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);

    CreateBaseFormItem(cFI_FormGetZhika, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then
      Exit;

    cxlbl_NewZhiKa:= nP.FParamB;
    cxlbl_NewCus := nP.FParamC;
  finally
    Dispose(nP);
  end;
end;

end.
