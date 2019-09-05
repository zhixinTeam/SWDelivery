unit UFromPrinterJs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter, cxContainer, cxEdit, cxTextEdit, dxLayoutControl,
  StdCtrls;

type
  TfFormPrinterJs = class(TfFormNormal)
    dxlytmLayout1Item3: TdxLayoutItem;
    edt_Edit1: TcxTextEdit;
    dxlytmLayout1Item31: TdxLayoutItem;
    edt_Edit11: TcxTextEdit;
    dxlytmLayout1Item32: TdxLayoutItem;
    edt_Edit12: TcxTextEdit;
    dxLayout1Group3: TdxLayoutGroup;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    class function CreateForm(const nPopedom: string = '';const nParam: Pointer = nil):
                                                          TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormPrinterJs: TfFormPrinterJs;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysPopedom, USysBusiness, USysDB, USysGrid, USysConst,
  UFormWait;


class function TfFormPrinterJs.FormID: integer;
begin
  Result := cFI_FormPrinterJs;
end;

class function TfFormPrinterJs.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;

  with TfFormPrinterJs.Create(Application) do
  begin
    try
      if Assigned(nParam) then
      with PFormCommandParam(nParam)^ do
      begin
        FCommand := cCmd_ModalResult;
        FParamA := ShowModal;
      end
      else ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure TfFormPrinterJs.BtnOKClick(Sender: TObject);
var nStr, nPrinter : string;
    nTotNum, nTipNum : Integer;
begin
  nPrinter:= Trim(edt_Edit1.Text);
  nTotNum:= 65;
  nTipNum:= 3;

  if nPrinter='' then
  begin
    ShowMsg('请填写打印机名称', sHint);
    Exit;
  end;

  try
    nStr := 'Insert Into %s(P_PrinterName,P_TotalNum,P_TipNum) Select ''%s'', %d, %d ';
    nStr := Format(nStr, [sTable_PrintTotle, nPrinter, nTotNum, nTipNum]);
    FDM.ExecuteSQL(nStr);

    ModalResult := mrOk;
    ShowMsg('已添加打印机计数', sHint);
  except
    ShowMsg('操作失败、请重试', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPrinterJs, TfFormPrinterJs.FormID);


end.
