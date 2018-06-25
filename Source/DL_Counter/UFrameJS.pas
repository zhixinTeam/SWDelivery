{*******************************************************************************
  ����: dmzn@163.com 2012-4-29
  ����: ��������
*******************************************************************************}
unit UFrameJS;

{$I Link.Inc}
{$I js_inc.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrCodePrinter, ULibFun, USysConst, UFormWait, UFormInputbox,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  ExtCtrls, cxLabel, cxGraphics, cxControls;

type
  TfFrameCounter = class(TFrame)
    GroupBox1: TGroupBox;
    LabelHint: TcxLabel;
    EditTruck: TLabeledEdit;
    EditDai: TLabeledEdit;
    BtnStart: TButton;
    BtnClear: TButton;
    EditTon: TLabeledEdit;
    Timer1: TTimer;
    BtnPause: TButton;
    EditCode: TLabeledEdit;
    procedure BtnClearClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure EditTonChange(Sender: TObject);
    procedure EditTonDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FBill: string;
    //������
    FDaiNum: Integer;
    //װ����
    FPeerWeight: Integer;
    //����
    FTunnel: PMultiJSTunnel;
    //����ͨ��
    procedure SaveCountResult(const nProcess: Boolean);
    //�������
    constructor Create(AOwner: TComponent); override;
    //��ʼ��
  end;

implementation

{$R *.dfm}

constructor TfFrameCounter.Create(AOwner: TComponent);
begin
  inherited;
  FBill := '';
  BtnPause.Enabled := True;
  
  {$IFDEF USE_MIT}
  EditTruck.ReadOnly := True;
  {$ELSE}
  EditTruck.ReadOnly := False;
  {$ENDIF}
end;

procedure TfFrameCounter.SaveCountResult(const nProcess: Boolean);
var nDai: Integer;
begin
  if IsNumber(LabelHint.Caption, False) then
       nDai := StrToInt(LabelHint.Caption)
  else nDai := 0;

  if (FBill <> '') and (nDai > 0) then
  try
    BtnClear.Enabled := False;
    if nProcess then
      ShowWaitForm(Application.MainForm, '�������');
    SaveTruckCountData(FBill, nDai);
  finally
    BtnClear.Enabled := True;
    if nProcess then CloseWaitForm;
  end;
end;

procedure TfFrameCounter.BtnClearClick(Sender: TObject);
begin
  BtnClear.Enabled := False;
  try
    if Assigned(Sender) then
    begin
      {$IFDEF USE_MIT}
      if not StopJS(FTunnel.FID) then Exit;
      {$ELSE}
      if not gMultiJSManager.DelJS(FTunnel.FID) then Exit;
      if not BtnStart.Enabled then
        SaveCountResult(True);
      //��������
      {$ENDIF}

      Sleep(500);
      //for delay
      FBill := '' ;
      LabelHint.Caption := '0';

      EditTruck.Text := '';
      EditDai.Text := '';
      EditTon.Text := '';

      EditDai.Enabled := True;
      EditTon.Enabled := True;
      BtnStart.Enabled := True;
      BtnPause.Enabled := True;
    end;
  finally 
    BtnClear.Enabled := True;
  end;
end;

procedure TfFrameCounter.BtnStartClick(Sender: TObject);
var nHint: string;
    nInt: Integer;
begin
  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then
  begin
    ShowDlg('��ˢ�¶��л�ȡ������Ϣ', sHint);
    Exit;
  end;

  if (not IsNumber(EditDai.Text, False)) or (StrToInt(EditDai.Text) <= 0) then
  begin
    ShowDlg('���������', sHint);
    Exit;
  end;

  BtnStart.Enabled := False;
  //disabled
  ShowWaitForm(Application.MainForm, '���������', True);
  try
    Sleep(200);
    //for delay
    
    {$IFDEF USE_MIT}
    if not PrintBillCode(FTunnel.FID, FBill, nHint) then
    begin
      CloseWaitForm;
      Application.ProcessMessages;

      ShowDlg(nHint, sWarn);
      Exit;
    end;
    {$ELSE}
    if not gCodePrinterManager.PrintCode(FTunnel.FID, Trim(EditCode.Text), nHint) then
    begin
      CloseWaitForm;
      Application.ProcessMessages;

      ShowDlg(nHint, sWarn);
      Exit;
    end;  
    {$ENDIF}

    nInt := StrToInt(EditDai.Text);
    {$IFDEF USE_MIT}
    ShowWaitForm(nil, '���Ӽ�����');
    StartJS(FTunnel.FID, EditTruck.Text, FBill, nInt);
    {$ELSE}
    if not gMultiJSManager.AddJS(FTunnel.FID, EditTruck.Text, '', nInt) then
      Exit;
    {$ENDIF}

    Timer1.Enabled := True;
    //����
  finally
    CloseWaitForm;
    BtnStart.Enabled := True;
  end;

  EditDai.Enabled := False;
  EditTon.Enabled := False;
  BtnStart.Enabled := False;

  {$IFNDEF USE_MIT}
  BtnPause.Enabled := True;
  {$ENDIF}
end;

procedure TfFrameCounter.EditTonDblClick(Sender: TObject);
var nStr: string;
begin
  nStr := IntToStr(FPeerWeight);
  if not ShowInputBox('���������: ', sHint, nStr) then Exit;

  if IsNumber(nStr, False) and (StrToInt(nStr) > 0) then
       FPeerWeight := StrToInt(nStr)
  else ShowMsg('����Ϊ����0������', sHint);
end;

procedure TfFrameCounter.EditTonChange(Sender: TObject);
var nVal: Double;
begin
  if not EditTon.Focused then Exit;
  if FPeerWeight < 1 then FPeerWeight := 50;
  if not IsNumber(EditTon.Text, True) then Exit;

  nVal := StrToFloat(EditTon.Text) * 1000 / FPeerWeight;
  EditDai.Text := IntToStr(Trunc(nVal));
end;

procedure TfFrameCounter.Timer1Timer(Sender: TObject);
begin
  if (not BtnStart.Enabled) and IsNumber(LabelHint.Caption, False) then
  begin
    FDaiNum := StrToInt(LabelHint.Caption);
    if StrToInt(EditDai.Text) <> FDaiNum then Exit;

    Timer1.Enabled := False;
    {$IFDEF USE_MIT}
    BtnClearClick(nil);
    {$ELSE}
    BtnClear.Click;
    {$ENDIF}
    ShowMsg('װ�����', sHint);
  end;
end;

procedure TfFrameCounter.BtnPauseClick(Sender: TObject);
begin
  {$IFDEF USE_MIT}
  PauseJS(FTunnel.FID);
  {$ELSE}
  gMultiJSManager.PauseJS(FTunnel.FID);
  {$ENDIF}

  Sleep(500);
  //for delay
  //BtnStart.Enabled := True;
end;

end.
