unit UShowOrderInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UAndroidFormBase, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, System.Character,
  UMITPacker,UClientWorker,UBusinessConst,USysBusiness,UMainFrom, FMX.ListBox;

type
  TFrmShowOrderInfo = class(TfrmFormBase)
    Label6: TLabel;
    tmrGetOrder: TTimer;
    BtnCancel: TSpeedButton;
    BtnOK: TSpeedButton;
    EditKZValue: TEdit;
    Label10: TLabel;
    Label8: TLabel;
    lblTruck: TLabel;
    lblMate: TLabel;
    Label4: TLabel;
    lblProvider: TLabel;
    lblID: TLabel;
    Label1: TLabel;
    lbl1: TLabel;
    cbb_Place: TComboBox;
    lbl2: TLabel;
    rb_ZX: TRadioButton;
    rb_RGXH: TRadioButton;
    lbl3: TLabel;
    cbb_KZMemo: TComboBox;
    chk_JuShou: TCheckBox;
    procedure tmrGetOrderTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure EditKZValueKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure chk_JuShouChange(Sender: TObject);
  private
    { Private declarations }
    procedure LoadPlaceInfo;
  public
    { Public declarations }
  end;

var
  gCardNO: string;
  FrmShowOrderInfo: TFrmShowOrderInfo;

implementation
var
  gOrders: TLadingBillItems;

{$R *.fmx}

procedure TFrmShowOrderInfo.BtnCancelClick(Sender: TObject);
begin
  inherited;
  MainForm.Show;
  Self.Hide;
end;

procedure TFrmShowOrderInfo.BtnOKClick(Sender: TObject);
begin
  inherited;
  if cbb_Place.ItemIndex=-1 then
  begin
    ShowMessage('��ѡ��ж���ص�');
    Exit;
  end;

  if ( not rb_ZX.IsChecked)and( not rb_RGXH.IsChecked) then
  begin
    ShowMessage('��ѡ��ж����ʽ');
    Exit;
  end;
  ///********************
  ///
  if Length(gOrders)>0 then
  with gOrders[0] do
  begin
    FPlace:= cbb_Place.items[cbb_Place.ItemIndex];     //ж���ص�

    if rb_ZX.IsChecked then
      FUnloadingType:= '��ж'
    else FUnloadingType:= '�˹�ж��';
    //ж����ʽ

    FKZValue := StrToFloatDef(EditKZValue.Text, 0);
    FMemo       := cbb_KZMemo.items[cbb_KZMemo.ItemIndex];           //���ӱ�ע

    if chk_JuShou.IsChecked then
      FYSValid:= 'N'         //����
    else FYSValid:= 'Y';     //�ջ�

    if SavePurchaseOrders('X', gOrders) then
    begin
      ShowMessage('�����ɹ�');
      MainForm.Show;
    end
    else ShowMessage('����ʧ��');
  end;
end;

procedure TFrmShowOrderInfo.chk_JuShouChange(Sender: TObject);
begin
  EditKZValue.Text:= '0';
end;

procedure TFrmShowOrderInfo.EditKZValueKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  // ֻ���������ֻ�����ַ�
  if not KeyChar.IsNumber and not KeyChar.IsControl then
  begin
    KeyChar := Char(0);
    Key := 0;
  end;
end;

procedure TFrmShowOrderInfo.FormActivate(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  EditKZValue.Text := '0.00';

  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
  cbb_KZMemo.ItemIndex:= 0;
end;

procedure TFrmShowOrderInfo.LoadPlaceInfo;
begin
end;

procedure TFrmShowOrderInfo.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  {if Key = vkHardwareBack then//������������ؼ�
  begin
    MessageDlg('ȷ���˳���', System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbOK, System.UITypes.TMsgDlgBtn.mbCancel], -1,

      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOK then BtnCancelClick(Self);
      end
      );
      //�˳�����

    Key := 0;//����ģ���Ȼ����Ҳ���˳�
    Exit;
  end;    }
end;

procedure TFrmShowOrderInfo.FormShow(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  EditKZValue.Text := '0.00';

  BtnOK.Enabled := False;
  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
end;

procedure TFrmShowOrderInfo.tmrGetOrderTimer(Sender: TObject);
var nIdx, nInt: Integer;
    nStr : string;
begin
  tmrGetOrder.Enabled := False;

  if not GetPurchaseOrders(gCardNO, 'X', gOrders) then
  begin
    BtnCancelClick(Self);
    Exit;
  end;

  nInt := 0;
  for nIdx := Low(gOrders) to High(gOrders) do
  with gOrders[nIdx] do
  begin
    FSelected := (FNextStatus='X') or (FNextStatus='M');
    if FSelected then Inc(nInt);
  end;

  if nInt<1 then
  begin
    nStr := '�ſ�[%s]����Ҫ���ճ���';
    nStr := Format(nStr, [gCardNo]);

    ShowMessage(nStr);
    Exit;
  end;

  with gOrders[0] do
  begin
    lblID.Text       := FID;
    lblProvider.Text := FCusName;
    lblMate.Text     := FStockName;
    lblTruck.Text    := FTruck;

    EditKZValue.Text := FloatToStr(FKZValue);
  end;

  BtnOK.Enabled := True;
end;

end.
