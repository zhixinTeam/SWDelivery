unit UFormCustomerInitEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinsdxLCPainter, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit;

type
  TfFormCustomerInitEdit = class(TfFormNormal)
    dxlytm_InitMoney: TdxLayoutItem;
    Edt_InitMoney: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    cxlbl1: TcxLabel;
    dxlytmLayout1Item31: TdxLayoutItem;
    Edt_CusId: TcxTextEdit;
    dxlytm_Cus: TdxLayoutItem;
    edt_CusName: TcxTextEdit;
    procedure BtnOKClick(Sender: TObject);
    procedure Edt_InitMoneyKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = ''; const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormCustomerInitEdit: TfFormCustomerInitEdit;

implementation

{$R *.dfm}

uses
  ULibFun, UFormBase, UMgrControl, UAdjustForm, USysDB, USysConst, USysBusiness,
  UDataModule;


class function TfFormCustomerInitEdit.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
    nP := nParam
  else New(nP);

  with TfFormCustomerInitEdit.Create(Application) do
  try
    Edt_CusId.Text:= nP.FParamA;
    edt_CusName.Text:= nP.FParamB;

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormCustomerInitEdit.FormID: integer;
begin
  Result := cFI_FormCusInitEdit;
end;

procedure TfFormCustomerInitEdit.BtnOKClick(Sender: TObject);
var nStr : string;
begin
  if (Trim(edt_CusName.Text)='')or(Trim(Edt_CusId.Text)='') then
  begin
    ShowMsg('客户无效、请选择客户后操作', sHint);
    Exit;
  end;

  if Trim(Edt_InitMoney.Text)='' then
  begin
    ShowMsg('请填写客户期初金额', sHint);
    Exit;
  end;

  begin
    nStr := 'UPDate %s Set A_InitMoney=''%s''  Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, Trim(Edt_InitMoney.Text), Trim(Edt_CusId.Text)]);

    FDM.ExecuteSQL(nStr);
    ShowMsg('操作成功', sHint);
    Close;
  end;
end;

procedure TfFormCustomerInitEdit.Edt_InitMoneyKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in [#8, #13, #127, '.', '-', '0'..'9', #22, #17]) then
    Key := #0;

  if Key=#13 then BtnOK.Click;
end;

procedure TfFormCustomerInitEdit.FormShow(Sender: TObject);
begin
  Edt_InitMoney.SetFocus;
end;

procedure TfFormCustomerInitEdit.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then BtnOK.Click;
end;

initialization
  gControlManager.RegCtrl(TfFormCustomerInitEdit, TfFormCustomerInitEdit.FormID);
end.
