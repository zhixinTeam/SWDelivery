{*******************************************************************************
  ����: dmzn@163.com 2014-10-20
  ����: �Զ�����ͨ����
*******************************************************************************}
unit UFramePoundAutoItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, UFrameBase, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  UTransEdit, ExtCtrls, cxRadioGroup, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, ULEDFont, DateUtils, dxSkinsCore,
  dxSkinsDefaultPainters;

type
  TfFrameAutoPoundItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    ImageGS: TImage;
    Label16: TLabel;
    Label17: TLabel;
    ImageBT: TImage;
    Label18: TLabel;
    ImageBQ: TImage;
    ImageOff: TImage;
    ImageOn: TImage;
    HintLabel: TcxLabel;
    EditTruck: TcxComboBox;
    EditMID: TcxComboBox;
    EditPID: TcxComboBox;
    EditMValue: TcxTextEdit;
    EditPValue: TcxTextEdit;
    EditJValue: TcxTextEdit;
    Timer1: TTimer;
    EditBill: TcxComboBox;
    EditZValue: TcxTextEdit;
    GroupBox2: TGroupBox;
    RadioPD: TcxRadioButton;
    RadioCC: TcxRadioButton;
    EditMemo: TcxTextEdit;
    EditWValue: TcxTextEdit;
    RadioLS: TcxRadioButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    Timer2: TTimer;
    Timer_ReadCard: TTimer;
    TimerDelay: TTimer;
    MemoLog: TZnTransMemo;
    Timer_SaveFail: TTimer;
    chk1: TCheckBox;
    btn1: TButton;
    cxlbl1: TcxLabel;
    edt1: TEdit;
    btn2: TButton;
    chk2: TCheckBox;
    chk3: TCheckBox;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer_ReadCardTimer(Sender: TObject);
    procedure TimerDelayTimer(Sender: TObject);
    procedure Timer_SaveFailTimer(Sender: TObject);
    procedure EditBillKeyPress(Sender: TObject; var Key: Char);
    procedure HintLabelClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
    FCardUsed, FZLValue: string;
    //��Ƭ����
    FLEDContent: string;
    //��ʾ������
    FIsWeighting, FIsSaving, FIsChkPoundStatus : Boolean;
    //���ر�ʶ,�����ʶ
    FPoundTunnel: PPTTunnelItem;
    //��վͨ��
    FLastGS,FLastBT,FLastBQ: Int64;
    //�ϴλ
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //��������
    FLastCardDone: Int64;
    FLastCard, FCardTmp, FLastReader, FxLastReader, FLastTruckNo: string;
    //�ϴο���, ��ʱ����, ���������
    FSampleIndex: Integer;
    FValueSamples: array of Double;
    //���ݲ���
    FBarrierGate: Boolean;
    //�Ƿ���õ�բ
    FEmptyPoundInit, FDoneEmptyPoundInit: Int64;
    //�հ���ʱ,���������հ�
    FEmptyPoundIdleLong, FEmptyPoundIdleShort: Int64;
    Ftip : Boolean;
  private
    function ChkPoundStatus:Boolean;
    function ChkBillStatus(nLid:string):Boolean;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //��������
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //����״̬
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //����ͨ��
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //��ȡ����
    procedure LoadBillItems(const nCard: string);
    //��ȡ������
    procedure InitSamples;
    procedure AddSample(const nValue: Double);
    function IsValidSamaple: Boolean;
    //�������
    function SavePoundSale: Boolean;
    function SavePoundData: Boolean;
    //�������
    procedure WriteLog(nEvent: string);
    //��¼��־
    procedure PlayVoice(const nStrtext: string);
    //��������
    procedure LEDDisplay(const nContent: string);
    //LED��ʾ
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //����̳�
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //�������
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UFormBase, {$IFDEF HR1847}UKRTruckProber,{$ELSE}UMgrTruckProbe,{$ENDIF}
  UMgrRemoteVoice, UMgrVoiceNet, UDataModule, USysBusiness, UMgrLEDDisp,
  USysLoger, USysConst, USysDB, IniFiles;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFrameAutoPoundItem.FrameID: integer;
begin
  Result := 0;
end;

procedure WriteSysLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameAutoPoundItem, '�Զ�����ҵ��', nEvent);
end;

procedure TfFrameAutoPoundItem.OnCreateFrame;
var nReaderIni : TIniFile;
begin
  inherited;
  FPoundTunnel := nil;
  FIsWeighting := False;  
  {$IFDEF HandleTunnel}
  try
    try
      if FileExists(ExtractFilePath(Paramstr(0)) + 'SetReader.ini') then
      begin
        nReaderIni:= TIniFile.Create(ExtractFilePath(Paramstr(0)) + 'SetReader.ini');
        FxLastReader:= nReaderIni.Readstring('Info','Reader','');
      end
      else WriteSysLog('δ���ö�������ʾ��δ�г���ˢ������ǰ������ִ���ֶ�̧��');
    except
      Application.MessageBox('��ʾ��SetReader.ini ��ȡ����','ϵͳ��ʾ',MB_OK);
    end;
  finally
    nReaderIni.Destroy;
  end;

  btn1.Visible:= True;
  btn2.Visible:= True;
  {$ENDIF}
  {$IFNDEF CQJJ}
  chk2.Visible:= False;
  {$ENDIF}
  {$IFNDEF RemoteSnap}
  chk1.Visible:= False;
  {$ENDIF}
  {$IFNDEF SWTC}
  chk3.Visible:= False;
  {$ENDIF}

  FLEDContent := '';
  FEmptyPoundInit := 0;
end;

procedure TfFrameAutoPoundItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //�رձ�ͷ�˿�
  inherited;
end;

function RoundFloat(f: double; i: integer): double;       //��������
var
  s: string;
  ef: Extended;
begin
  if f = 0 then begin
    Result := 0;
    Exit;
  end;
  s := '#.' + StringOfChar('0', i);
  if s = '#.' then s := '#';
  ef := StrToFloat(FloatToStr(f)); //��ֹ������������
  result := StrToFloat(FormatFloat(s, ef));
end;

//Desc: ��������״̬ͼ��
procedure TfFrameAutoPoundItem.SetImageStatus(const nImage: TImage;
  const nOff: Boolean);
begin
  if nOff then
  begin
    if nImage.Tag <> cFlag_OFF then
    begin
      nImage.Tag := cFlag_OFF;
      nImage.Picture.Bitmap := ImageOff.Picture.Bitmap;
    end;
  end else
  begin
    if nImage.Tag <> cFlag_ON then
    begin
      nImage.Tag := cFlag_ON;
      nImage.Picture.Bitmap := ImageOn.Picture.Bitmap;
    end;
  end;
end;

procedure TfFrameAutoPoundItem.WriteLog(nEvent: string);
var nInt: Integer;
begin
  with MemoLog do
  try
    Lines.BeginUpdate;
    if Lines.Count > 20 then
     for nInt:=1 to 10 do
      Lines.Delete(0);
    //�������

    Lines.Add(DateTime2Str(Now) + #9 + nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;
//------------------------------------------------------------------------------
//Desc: ��������״̬
procedure TfFrameAutoPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageGS, GetTickCount - FLastGS > 5 * 1000);
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: �رպ��̵�
procedure TfFrameAutoPoundItem.Timer2Timer(Sender: TObject);
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;

  {$IFNDEF MITTruckProber}
    {$IFDEF HR1847}
    gKRMgrProber.TunnelOC(FPoundTunnel.FID,False);
    {$ELSE}
    gProberManager.TunnelOC(FPoundTunnel.FID,False);
    {$ENDIF}
  {$ENDIF}
end;

//Desc: ����ͨ��
procedure TfFrameAutoPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FBarrierGate := False;
  FEmptyPoundIdleLong := -1;
  FEmptyPoundIdleShort:= -1;

  FPoundTunnel := nTunnel;
  SetUIData(True);

  if Assigned(FPoundTunnel.FOptions) then
  with FPoundTunnel.FOptions do
  begin
    FBarrierGate := Values['BarrierGate'] = sFlag_Yes;
    FEmptyPoundIdleLong := StrToInt64Def(Values['EmptyIdleLong'], 60);
    FEmptyPoundIdleShort:= StrToInt64Def(Values['EmptyIdleShort'], 5);
  end;
end;

function TfFrameAutoPoundItem.ChkPoundStatus:Boolean;
var nIdx:Integer;
    nHint : string;
begin
  Result:= True;
  try
    try
      FIsChkPoundStatus:= True;
      if not FPoundTunnel.FUserInput then
      if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
             OnPoundDataEvent, True) then
      begin
        nHint := '���ذ������ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
        WriteSysLog(nHint);
        PlayVoice(nHint);
      end;

      for nIdx:= 0 to 5 do
      begin
        Sleep(500);  Application.ProcessMessages;
        if StrToFloatDef(Trim(EditValue.Text), -1) > 0.12 then
        begin
          Result:= False;
          nHint := '���ذ����ذ��������� %s ,���ܽ��г�����ҵ';
          nhint := Format(nHint, [EditValue.Text]);
          WriteSysLog(nHint);

          PlayVoice(FLastTruckNo+' ��ǰ�ذ����ڳ���״̬����س�������Ա���°�');
          Break;
        end;
      end;
    except  on E: Exception do
      begin
        WriteSysLog(Format('��վ %s.%s : ���ذ�״̬ %s', [FPoundTunnel.FID,
                                                 FPoundTunnel.FName, E.Message]));
      end;
    end;
  finally
    FIsChkPoundStatus:= False;
    SetUIData(True);
  end;
end;

//Desc: ���ý�������
procedure TfFrameAutoPoundItem.SetUIData(const nReset,nOnlyData: Boolean);
var nStr: string;
    nInt: Integer;
    nVal: Double;
    nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    //init

    with nItem do
    begin
      FPModel := sFlag_PoundPD;
      FFactory := gSysParam.FFactNum;
    end;

    FUIData := nItem;
    FInnerData := nItem;
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    FIsSaving    := False;
    FEmptyPoundInit := 0;


      if not FIsWeighting then
      begin
        try
          gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
          //�رձ�ͷ�˿�
        except  on E: Exception do
          begin
            WriteSysLog(Format('��վ %s.%s : �رձ�ͷ %s', [FPoundTunnel.FID, FPoundTunnel.FName, E.Message]));
          end;
        end;

        Timer_ReadCard.Enabled := True;
        //��������
        Ftip:= False;
      end;
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditMValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);

    if (FValue > 0) and (FMData.FValue > 0) and (FPData.FValue > 0) then
    begin
      nVal := FMData.FValue - FPData.FValue;
      EditJValue.Text := Format('%.2f', [nVal]);
      EditWValue.Text := Format('%.2f', [FValue - nVal]);
    end else
    begin
      EditJValue.Text := '0.00';
      EditWValue.Text := '0.00';
    end;

    RadioPD.Checked := FPModel = sFlag_PoundPD;
    RadioCC.Checked := FPModel = sFlag_PoundCC;
    RadioLS.Checked := FPModel = sFlag_PoundLS;

    RadioLS.Enabled := (FPoundID = '') and (FID = '');
    //�ѳƹ�����������,������ʱģʽ
    RadioCC.Enabled := FID <> '';
    //ֻ�������г���ģʽ

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //�����������

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //������������

    if FTruck = '' then
    begin
      EditMemo.Text := '';
      Exit;
    end;
  end;

  nInt := Length(FBillItems);
  if nInt > 0 then
  begin
    if nInt > 1 then
         nStr := '���۲���'
    else nStr := '����';

    if FCardUsed=sFlag_Provide then nStr := '��Ӧ'
    else if FCardUsed=sFlag_DuanDao then nStr := '�̵�';

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      EditMemo.Text := nStr + '��Ƥ��';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '��ë��';
    end;
  end else
  begin
    if RadioLS.Checked then
      EditMemo.Text := '������ʱ����';
    //xxxxx

    if RadioPD.Checked then
      EditMemo.Text := '������Գ���';
    //xxxxx
  end;
end;

//Date: 2014-09-19
//Parm: �ſ��򽻻�����
//Desc: ��ȡnCard��Ӧ�Ľ�����
procedure TfFrameAutoPoundItem.LoadBillItems(const nCard: string);
var nRet: Boolean;
    nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nStr,nHint, nVoice, nSql: string;
begin
  nStr := Format('��ȡ������[ %s ],��ʼִ��ҵ��.', [nCard]);
  WriteLog(nStr);

  FCardUsed := GetCardUsed(nCard);
  if FCardUsed = sFlag_Provide then
     nRet := GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_DuanDao then
     nRet := GetDuanDaoItems(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_Sale then
     nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills) else nRet := False;

  if (not nRet) or (Length(nBills) < 1)
  then
  begin
    nVoice := '��ȡ�ſ���Ϣʧ��,����ϵ������Ա����';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;
  FLastTruckNo:= nBills[0].FTruck;

  {$IFDEF SWTC}  //����ͭ������ �����ҹܿس����Ƿ����ϰ�  У�����װ��������ι���״̬
  if ChkBillStatus(nBills[0].FID) then
  begin
    nStr:= Format('���� %s ���� %s���ѱ������ҽ�ֹ�ϰ�������ϵ������',
                                [nBills[0].FID, nBills[0].FTruck]);
    WriteSysLog(nStr);
    PlayVoice(nBills[0].FTruck + ' ��ǰ���ܹ���������ϵ�����ҹ�����Ա');
    Exit;
  end;
  {$ENDIF}


  {$IFDEF ChkSaleCardInTimeOut}      // ���۽�����ʱ���
  if (FCardUsed=sFlag_Sale) and (nBills[0].FNextStatus = sFlag_TruckBFP) then
  begin
    GetSaleCardInTimeDiff(nBills[0].FID,nBills[0].FMinuteDate);
    if IsSaleCardInTimeOut(nBills[0].FMinuteDate) then
    begin
      nVoice := '��δ�ڹ涨ʱ���ڽ���,����ϵ��Ʊ�����¿���';
      PlayVoice(nVoice);
      WriteLog(nVoice);
      SetUIData(True);
      Exit;
    end;
  end;
  {$ENDIF}

  {$IFDEF RemoteSnap}
  if chk1.Checked then
  if not VerifySnapTruck(FLastReader, nBills[0], nHint) then
  begin
    nVoice := '%s����ʶ��ʧ��,���ƶ���������ϵ������Ա';
    nVoice := Format(nVoice, [nBills[0].FTruck]);

    WriteSysLog('ʶ���� ' + nVoice);
//    PlayVoice(nHint);
//    LEDDisplay('����ʶ��ʧ��,���ƶ�����');
//    WriteSysLog(nHint);
//    SetUIData(True);
//    Exit;
  end
  else
  begin
    if nHint <> '' then
      WriteSysLog('������֤ͨ�� '+nHint);
  end;
  {$ENDIF}
  //����ƥ����
                       
  nHint := '';
  nInt := 0;
                       
  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //״̬У��
    {$IFDEF AllowMultiM}
    if (FStatus = sFlag_TruckBFM)And(FCardUsed=sFlag_Sale)  then
    begin
      FNextStatus := sFlag_TruckBFM;
      //���������ι���
      AdjustBillStatus(nBills[nIdx].FID);
    end;
    {$ENDIF}

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //�ɳ���״̬�ж�

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s  ]  ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;

    nVoice := '���� %s ���ܹ���,Ӧ��ȥ %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //����״̬�쳣

    nHint := '�ó�����ǰ���ܹ���,��������: ' + #13#10#13#10 + nHint;
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;

  EditBill.Properties.Items.Clear;
  SetLength(FBillItems, nInt);
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if FSelected then
    begin
      FPoundID := '';
      //�ñ����������;

      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //�ۼ���

      EditBill.Properties.Items.Add(FID);
      FBillItems[nInt] := nBills[nIdx];
      Inc(nInt);
    end;
  end;

  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData;
  SetUIData(False);

  nInt := GetTruckLastTime(FUIData.FTruck);
  if (nInt > 0) and (nInt < FPoundTunnel.FCardInterval) then
  begin
    nStr := '��վ[ %s.%s ]: ���� %s ��ȴ� %d �����ܹ���';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            FUIData.FTruck, FPoundTunnel.FCardInterval - nInt]);
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;
  //ָ��ʱ���ڳ�����ֹ����

  InitSamples;
  //��ʼ������

  try
    if not FPoundTunnel.FUserInput then
    if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
           OnPoundDataEvent, True) then
    begin
      nHint := '���ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
      WriteSysLog(nHint);

      nVoice := nHint;
      PlayVoice(nVoice);

      SetUIData(True);
      Exit;
    end;
  except  on E: Exception do
      begin
        WriteSysLog(Format('��վ %s.%s : ������ȡ�ذ����� %s', [FPoundTunnel.FID,
                                                 FPoundTunnel.FName, E.Message]));
      end;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  //ֹͣ����,��ʼ����

  if FBarrierGate then
  begin
    {$IFDEF ZZSJ}
    if (FUIData.FStatus = sFlag_TruckIn) or
       (FUIData.FStatus = sFlag_TruckBFP) then
    begin
      nStr := '[n1]%sˢ���ɹ����ϰ�,��Ϩ��ͣ��,������ϵ�ð�ȫ��,���ð�ȫñ';
      nStr := Format(nStr, [FUIData.FTruck]);
    end;
    {$ELSE}
    nStr := '[n1]%sˢ���ɹ����ϰ�,��Ϩ��ͣ��';
    nStr := Format(nStr, [FUIData.FTruck]);
    {$ENDIF}

    if Chk2.Checked then nStr:= 'ˢ���ɹ�';
    PlayVoice(nStr);
    //�����ɹ���������ʾ

    {$IFNDEF DEBUG}
    OpenDoorByReader(FLastReader);
    //������բ
    {$ENDIF}
  end;
  //�����ϰ�
end;

function TfFrameAutoPoundItem.ChkBillStatus(nLid:string):Boolean;
VAR nSql : string;
begin
  nSql := 'Select * From %s Where L_ID=''%s'' And L_Refuse=''Y'' ';
  nSql := Format(nSql, [sTable_Bill , nLid]);
  with FDM.QueryTemp(nSql) do
  begin
    Result:= RecordCount > 0
  end;
end;
//------------------------------------------------------------------------------
//Desc: �ɶ�ʱ��ȡ������
procedure TfFrameAutoPoundItem.Timer_ReadCardTimer(Sender: TObject);
var nStr,nCard: string;
    nLast, nDoneTmp: Int64;
begin
  if gSysParam.FIsManual then Exit;
  Timer_ReadCard.Tag := Timer_ReadCard.Tag + 1;   Sleep(200);
  if Timer_ReadCard.Tag < 10 then Exit;

  Timer_ReadCard.Tag := 0;
  if FIsWeighting then Exit;

  try
    WriteLog('���ڶ�ȡ�ſ���.');
    {$IFNDEF DEBUG}
    nCard := Trim(ReadPoundCard(FPoundTunnel.FID, FLastReader));
    {$ENDIF}

    if nCard = '' then Exit;
    if nCard <> FLastCard then
         nDoneTmp := 0
    else nDoneTmp := FLastCardDone;
    //�¿�ʱ����

    
    Ftip:= False;    FxLastReader:= FLastReader;
    {$IFDEF DEBUG}
    nStr := '��վ %s.%s : ��ȡ���¿���::: %s =>�ɿ���::: %s';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            nCard, FLastCard]);
    WriteSysLog(nStr);
    {$ENDIF}

    nLast := Trunc((GetTickCount - nDoneTmp) / 1000);
    if (nDoneTmp <> 0) and (nLast < FPoundTunnel.FCardInterval)  then
    begin
      nStr := '��վ %s.%s : �ſ� %s ��ȴ� %d �����ܹ���';
      nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
              nCard, FPoundTunnel.FCardInterval - nLast]);
      WriteSysLog(nStr);
      Exit;
    end;
    IF not chk3.Checked then
    if Not ChkPoundStatus then Exit;
    //���ذ�״̬ �粻Ϊ�հ����򺰻� �˳�����

    FCardTmp := nCard;
    EditBill.Text := nCard;
    LoadBillItems(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('��վ %s.%s : ���ض��� ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //����������
    end;
  end;
end;

//Desc: ��������
function TfFrameAutoPoundItem.SavePoundSale: Boolean;
var nStr, nStrSql: string;
    nVal,nNet, nEmptyValue: Double;
begin
  Result := False;
  //init

  if FBillItems[0].FNextStatus = sFlag_TruckBFP then
  begin
    if FUIData.FPData.FValue <= 0 then
    begin
      WriteLog('���ȳ���Ƥ��');
      Exit;
    end;

    nNet := GetTruckEmptyValue(FUIData.FTruck);
    nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

    if (nNet > 0) and (Abs(nVal) > gSysParam.FPoundSanF) then
    begin
      {$IFDEF AutoPoundInManual}
      nStr := '����[%s]ʵʱƤ�����ϴ�,��֪ͨ˾����鳵��';
      nStr := Format(nStr, [FUIData.FTruck]);
      PlayVoice(nStr);

      nStr := '����[ %s ]ʵʱƤ�����ϴ�,��������:' + #13#10#13#10 +
              '��.ʵʱƤ��: %.2f��' + #13#10 +
              '��.��ʷƤ��: %.2f��' + #13#10 +
              '��.�����: %.2f����' + #13#10#13#10 +
              '�Ƿ��������?';
      nStr := Format(nStr, [FUIData.FTruck, FUIData.FPData.FValue,
              nNet, nVal]);
      if not QueryDlg(nStr, sAsk) then Exit;
      {$ELSE}
      nStr := '����[ %s ]ʵʱƤ�����ϴ�,��������:' + #13#10 +
              '��.ʵʱƤ��: %.2f��' + #13#10 +
              '��.��ʷƤ��: %.2f��' + #13#10 +
              '��.�����: %.2f����' + #13#10 +
              '�������,��ѡ��;��ֹ����,��ѡ��.';
      nStr := Format(nStr, [FUIData.FTruck, FUIData.FPData.FValue,
              nNet, nVal]);

      if not VerifyManualEventRecord(FUIData.FID + sFlag_ManualB, nStr,
        sFlag_Yes, False) then
      begin
        AddManualEventRecord(FUIData.FID + sFlag_ManualB, FUIData.FTruck, nStr,
            sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepDaTing, True);
        WriteSysLog(nStr);

        nStr := '[n1]%sƤ�س���Ԥ��,���°���ϵ��ƱԱ������ٴι���';
        nStr := Format(nStr, [FUIData.FTruck]);
        PlayVoice(nStr);
        Exit;
      end;
      {$ENDIF}
    end;
  end else
  begin
    if FUIData.FMData.FValue <= 0 then
    begin
      WriteLog('���ȳ���ë��');
      Exit;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    nNet := FUIData.FMData.FValue;
    nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

    if (nNet > 0) and (Abs(nVal)<= gSysParam.FEmpTruckWc) and (FBillItems[0].FIsSample<>sFlag_Yes) then
    begin
      // �ж�Ϊ�ճ�����
      WriteLog(Format('���ţ�%s ����Ʒ���������أ�%.2f ���� ���Ͽճ��������� ���Կճ�������ʾ',
                          [FBillItems[0].FID, nVal]));
      FBillItems[0].FYSValid:= 'Y';
      //*****************
      nStrSql := 'UPDate %s Set L_EmptyOut=''Y'' Where L_Id=''%s''  ';
      nStrSql := Format(nStrSql, [sTable_Bill, FBillItems[0].FID]);
      FDM.ExecuteSQL(nStrSql);
    end;


    if FBillItems[0].FYSValid <> sFlag_Yes then //�ж��Ƿ�ճ�����
    begin
      if FUIData.FPData.FValue > FUIData.FMData.FValue then
      begin
        WriteLog('Ƥ��ӦС��ë��');
        Exit;
      end;

      nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
      //����
      nVal := nNet * 1000 - FInnerData.FValue * 1000;
      //�뿪Ʊ�����(����)

      with gSysParam,FBillItems[0] do
      begin
        {$IFDEF DaiStepWuCha}
        if FType = sFlag_Dai then
        begin
          GetPoundAutoWuCha(FPoundDaiZ, FPoundDaiF, FInnerData.FValue);
          //�������
        end;
        {$ELSE}
        if FDaiPercent and (FType = sFlag_Dai) then
        begin
          if nVal > 0 then
               FPoundDaiZ := Float2Float(FInnerData.FValue * FPoundDaiZ_1 * 1000,
                                         cPrecision, False)
          else FPoundDaiF := Float2Float(FInnerData.FValue * FPoundDaiF_1 * 1000,
                                         cPrecision, False);
        end;
        {$ENDIF}

        {$IFDEF SWJY}
        if (FType = sFlag_Dai) then
        WriteSysLog('��װ���أ�'+ Format('%s %s ������: %.2f�� װ����: %.2f�� �����: %.2f���� ����׼��%g, %g',
                            [FId, FTruck, FInnerData.FValue, nNet, nVal, FPoundDaiZ, FPoundDaiF]));
        {$ENDIF}

        if ((FType = sFlag_Dai) and (
            ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
            ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF)))) then
        begin
          {$IFDEF AutoPoundInManual}
          nStr := '����[%s]ʵ��װ�������ϴ���֪ͨ˾���������';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);

          nStr := '����[ %s ]ʵ��װ�������ϴ�,��������:' + #13#10#13#10 +
                  '��.������: %.2f��' + #13#10 +
                  '��.װ����: %.2f��' + #13#10 +
                  '��.�����: %.2f����';

          if FDaiWCStop then
          begin
            nStr := nStr + #13#10#13#10 + '��֪ͨ˾���������.';
            nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);

            ShowDlg(nStr, sHint);
            Exit;
          end else
          begin
            nStr := nStr + #13#10#13#10 + '�Ƿ��������?';
            nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);
            if not QueryDlg(nStr, sAsk) then Exit;
          end;
          {$ELSE}
          nStr := '����[ %s ]ʵ��װ�������ϴ�,��������:' + #13#10 +
                  '��.������: %.2f��' + #13#10 +
                  '��.װ����: %.2f��' + #13#10 +
                  '��.�����: %.2f����' + #13#10 +
                  '�����Ϻ�,���ȷ�����¹���.';
          nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);

          if not VerifyManualEventRecord(FID + sFlag_ManualC, nStr) then
          begin
            AddManualEventRecord(FID + sFlag_ManualC, FTruck, nStr,
              sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepJianZhuang, True);
            WriteSysLog(nStr);

            nStr := '����[n1]%s����[n2]%.2f��,��Ʊ��[n2]%.2f��,'+
                    '�����[n2]%.2f����,��ȥ��װ���';
            nStr := Format(nStr, [FTruck, nNet, FInnerData.FValue, nVal]);
            PlayVoice(nStr);

            nStr := GetTruckNO(FTruck) + '��ȥ��װ���';
            LEDDisplay(nStr);

            {$IFDEF ProberShow}
              {$IFDEF MITTruckProber}
              ProberShowTxt(FPoundTunnel.FID, nStr);
              {$ELSE}
              gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
              {$ENDIF}
            {$ENDIF}
            Exit;
          end;
          {$ENDIF}
        end;

        if (FType = sFlag_San) and IsStrictSanValue and
           FloatRelation(FValue, nNet, rtLess, cPrecision) then
        begin
          nStr := '����[n1]%s[p500]����[n2]%.2f��[p500]��Ʊ��[n2]%.2f��,��ж��';
          nStr := Format(nStr, [FTruck, Float2Float(nNet, cPrecision, True),
                  Float2Float(FValue, cPrecision, True)]);
          WriteSysLog(nStr);
          PlayVoice(nStr);
          Exit;
        end;
      end;
    end
    else
    begin
      nNet := FUIData.FMData.FValue;
      nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

      if (nNet > 0) and (Abs(nVal) > gSysParam.FEmpTruckWc) then
      begin
        nVal := nVal - gSysParam.FEmpTruckWc;
        nStr := '����[n1]%s[p500]�ճ���������[n2]%.2f����,��˾����ϵ˾������Ա��鳵��';
        nStr := Format(nStr, [FBillItems[0].FTruck, Float2Float(nVal, cPrecision, True)]);
        WriteSysLog(nStr);
        PlayVoice(nStr);
        Exit;
      end;
    end;
  end;

  with FBillItems[0] do
  begin
    FPModel := FUIData.FPModel;
    FFactory := gSysParam.FFactNum;

    with FPData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := RoundFloat(FUIData.FPData.FValue, 2);
      FOperator := gSysParam.FUserID;
    end;

    with FMData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := RoundFloat(FUIData.FMData.FValue, 2);
      FOperator := gSysParam.FUserID;
    end;
    
                          WriteSysLog(Format('�Զ����� Ʒ�֣�%s ë�أ�%.2f Ƥ�أ�%.2f ', [FUIData.FStockName, FMData.FValue, FPData.FValue]));
                          
    FPoundID := sFlag_Yes;
    //��Ǹ����г�������
    Result := SaveLadingBills(FNextStatus, FBillItems, FPoundTunnel);
    //�������
  end;
end;

//------------------------------------------------------------------------------
//Desc: ԭ���ϻ���ʱ
function TfFrameAutoPoundItem.SavePoundData: Boolean;
var nNextStatus, nSql: string;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      WriteLog('Ƥ��ӦС��ë�� P:'+FloatToStr(FUIData.FPData.FValue)+' M:'+FloatToStr(FUIData.FMData.FValue));
      PlayVoice('Ƥ��ӦС��ë��');
      Exit;
    end;
  end;
                            WriteSysLog(Format('�Զ����� Ʒ�֣�%s  ë�أ�%.2f  Ƥ�أ�%.2f', [FUIData.FStockName,
                                                                      FUIData.FMData.FValue, FUIData.FPData.FValue]));

  nNextStatus := FBillItems[0].FNextStatus;
  //�ݴ����״̬

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    FPData.FValue:= RoundFloat(FPData.FValue, 2);
    FMData.FValue:= RoundFloat(FMData.FValue, 2);
    ///******  �Ż����ؾ���Ϊ С����� 2 λ

    //**************************************************************************
    ///   ��������Ʒ�� ���ι���ʱ   ֱ�ӱ��Ϊ����
    {
    if ((FMData.FValue>0)and(FPData.FValue>0)) then
    begin
      nSql := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s'' ';
      nSql := Format(nSql, [sTable_SysDict, sFlag_NoYSStock, FStockName]);

      with FDM.QueryTemp(nSql) do
      if RecordCount > 0 then
      begin
        FYSValid:= 'Y';
        nSQL := ' UPDate P_OrderDtl Set D_YSResult=''Y'', D_YMan=''AutoYS'' Where D_ID='''+FID+'''';
        FDM.ExecuteSQL(nSQL);
      end;
    end;         }
    //**************************************************************************

    if FCardUsed = sFlag_Provide then
    if ((FMData.FValue>0)and(FPData.FValue>0))and
                (FYSValid<>sflag_Yes) then  // ԭ�϶��γ��ؾ������ ��ִ��ë��=Ƥ�� ��������
    begin
      WriteSysLog(Format('���� %s ������', [FID]));
      FPData.FValue:= FMData.FValue;
    end;

    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  if FCardUsed = sFlag_Provide then
       Result := SavePurchaseOrders(nNextStatus, FBillItems,FPoundTunnel)
  else Result := SaveDuanDaoItems(nNextStatus, FBillItems, FPoundTunnel);
  //�������
end;

//Desc: ��ȡ��ͷ����
procedure TfFrameAutoPoundItem.OnPoundDataEvent(const nValue: Double);
begin
  try
    if FIsSaving then Exit;
    //���ڱ��档����

    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ %s.%s : %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

//Desc: �����ͷ����
procedure TfFrameAutoPoundItem.OnPoundData(const nValue: Double);
var nRet, nCanSave: Boolean;
    nInt: Int64;
    nStr, sFlag_OPenDoor: string;
    nJVal : Double;
begin
  FLastBT := GetTickCount;   nCanSave:= True;
  EditValue.Text := Format('%.2f', [nValue]);

  try
    if FIsChkPoundStatus  then Exit;
    //���ذ�״̬
    if not FIsWeighting then Exit;
    //���ڳ�����
    if gSysParam.FIsManual then Exit;
    //�ֶ�ʱ��Ч

    if nValue < FPoundTunnel.FPort.FMinValue then //�հ�
    begin
      if FEmptyPoundInit = 0 then
        FEmptyPoundInit := GetTickCount;
      nInt := GetTickCount - FEmptyPoundInit;

      if (nInt > FEmptyPoundIdleLong * 1000) then
      begin  //�ϰ�ʱ��,�ӳ�����
        FIsWeighting :=False;
        Timer_SaveFail.Enabled := True;

        WriteSysLog('ˢ����˾������Ӧ,�˳�����.');
        Exit;
      end
      else
      begin
        if ((FEmptyPoundIdleLong * 1000 - nInt)<=20) And not Ftip then
        begin
          Ftip:= True;
          nStr:= Format('���� %s ���� 20 �����ϰ�.', [FUIData.FTruck, FUIData.FValue]);
          PlayVoice(nStr);
        end;
      end;


      if (nInt > FEmptyPoundIdleShort * 1000) and   //��֤�հ�
         (FDoneEmptyPoundInit>0) and (GetTickCount-FDoneEmptyPoundInit>nInt) then
      begin
        FIsWeighting :=False;
        Timer_SaveFail.Enabled := True;

        WriteSysLog('˾�����°�,�˳�����.');
        Exit;
      end;
      //�ϴα���ɹ���,�հ���ʱ,��Ϊ�����°�

      Exit;
    end else
    begin
      FEmptyPoundInit := 0;
      if FDoneEmptyPoundInit > 0 then
        FDoneEmptyPoundInit := GetTickCount;
      //����������Ϻ�δ�°�
    end;

    AddSample(nValue);
    if not IsValidSamaple then Exit;
    //������֤��ͨ��

    if Length(FBillItems) < 1 then Exit;
    //�޳�������

    if (FCardUsed = sFlag_Provide)or(FCardUsed = sFlag_DuanDao) then            // �ɹ����̵���
    begin
      if FInnerData.FPData.FValue > 0 then
      begin
        if nValue <= FInnerData.FPData.FValue then
        begin
          FUIData.FPData := FInnerData.FMData;
          FUIData.FMData := FInnerData.FPData;

          FUIData.FPData.FValue := nValue;
          FUIData.FNextStatus := sFlag_TruckBFP;                                //WriteSysLog('����  �л�Ϊ��Ƥ��');
          //�л�Ϊ��Ƥ��
        end else
        begin
          FUIData.FPData := FInnerData.FPData;
          FUIData.FMData := FInnerData.FMData;

          FUIData.FMData.FValue := nValue;
          FUIData.FNextStatus := sFlag_TruckBFM;
          //�л�Ϊ��ë��
        end;
      end else FUIData.FPData.FValue := nValue;
    end else
    if FBillItems[0].FNextStatus = sFlag_TruckBFP then
         FUIData.FPData.FValue := nValue
    else FUIData.FMData.FValue := nValue;

    SetUIData(False);
    //���½���

    {$IFDEF MITTruckProber}
      if not IsTunnelOK(FPoundTunnel.FID) then
    {$ELSE}
      {$IFDEF HR1847}
      if not gKRMgrProber.IsTunnelOK(FPoundTunnel.FID) then
      {$ELSE}
      if not gProberManager.IsTunnelOK(FPoundTunnel.FID) then
      {$ENDIF}
    {$ENDIF}
    begin
      nStr := '����δͣ��λ,���ƶ�����.';
      PlayVoice(nStr);
      LEDDisplay(nStr);

      InitSamples;
      Exit;
    end;

//    {$IFDEF SanPoundChKJZ}
//    if FUIData.FValue>StrToFloatDef(edt1.Text, 49) then
//    begin
//      nCanSave:= False;
//      WriteSysLog(Format('���� %s ���� %.2f �ѳ��涨����,������Ч.', [FUIData.FTruck, FUIData.FValue]));
//
//      nStr := '������ǰ����'+Format(' %.2f ', [FUIData.FValue])+'�ѳ��涨���ޡ����γ�����Ч���뵹���°�.';
//      PlayVoice(nStr);
//    end;
//    {$ENDIF}

    if nCanSave then
    begin
      FIsSaving := True;   FZLValue:= '';
      if FCardUsed = sFlag_Sale then
           nRet := SavePoundSale
      else nRet := SavePoundData;

      if nRet then
      begin
        {$IFDEF PoundTipsWeight}      // ������ʾ����    ����Ƥ��
        if  (FCardUsed = sFlag_Sale) then
        if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
        begin
          nJVal:= 0;
          nJVal:= FUIData.FMData.FValue - FUIData.FPData.FValue;
          //PlayVoice(Format('[ %s ]���� %.2f ��', [FUIData.FTruck, nJVal]));
          FZLValue:= Format('[ %s ]���� %.2f ��', [FUIData.FTruck, nJVal]);
        end
        else if (FUIData.FPData.FValue > 0) then
        begin
          //PlayVoice(Format('[ %s ]Ƥ�� %.2f ��', [FUIData.FTruck, FUIData.FPData.FValue]));
          FZLValue:= Format('[ %s ]Ƥ�� %.2f ��', [FUIData.FTruck, FUIData.FPData.FValue]);
        end;
        {$ENDIF}

        if (FCardUsed = sFlag_Sale) and (FBillItems[0].FType = sFlag_Dai)
           and (FBillItems[0].FNextStatus = sFlag_TruckBFM) then
          nStr := GetTruckNO(FUIData.FTruck) + 'Ʊ��:' +
                  GetValue(StrToFloatDef(EditZValue.Text,0))
        else
          nStr := GetTruckNO(FUIData.FTruck) + '����:' + GetValue(nValue);
        //LEDDisplay(nStr);

        {$IFDEF ProberShow}
          {$IFDEF MITTruckProber}
          ProberShowTxt(FPoundTunnel.FID, nStr);
          {$ELSE}
          gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
          {$ENDIF}
        {$ENDIF}

        TimerDelay.Enabled := True;
      end
      else
      begin
        Timer_SaveFail.Enabled := True;

        nStr := '���γ�����Ч,���°�����ϵ��Ʊ�ҹ�����Ա��������';
        {$IFDEF PoundOpenBackGate}
        nStr := nStr + ',�뵹���°�';
        {$ENDIF}
        PlayVoice(nStr);
        LEDDisplay(nStr);
        WriteSysLog(Format('���� %s ������Ч,��˶Ըö���������λ�ʽ����������Ϊ���õ��ڻ�ʵ���˻��ʽ���.', [FUIData.FTruck]));
      end;
    end;

    if FBarrierGate then
    begin
      sFlag_OPenDoor:= sFlag_No;   //Ĭ�ϴ򿪸���բ
      {$IFDEF PoundOpenBackGate}
      if (not nRet) then  //and (FUIData.FType = sFlag_Dai)
      begin
        sFlag_OPenDoor:=  sFlag_Yes;
        //�����������ʧ�ܴ�����բ(���)
      end;
      {$ENDIF}

      OpenDoorByReader(FLastReader, sFlag_OPenDoor);
      //�򿪵�բ
    end;
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ %s.%s : %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

procedure TfFrameAutoPoundItem.TimerDelayTimer(Sender: TObject);
begin
  try
    TimerDelay.Enabled := False;
    WriteSysLog(Format('�Գ��� %s �������.', [FUIData.FTruck]));
    {$IFDEF CQJJ}
    PlayVoice('�������,'+FZLValue+' ���°�');
    {$ELSE}
    PlayVoice(#9 + FUIData.FTruck);
    //��������
    {$ENDIF}

    FLastCard     := FCardTmp;
    FLastCardDone := GetTickCount;
    FDoneEmptyPoundInit := GetTickCount;
    //����״̬

    if not FBarrierGate then
      FIsWeighting := False;
    //�����޵�բʱ����ʱ�������

    {$IFDEF MITTruckProber}
        TunnelOC(FPoundTunnel.FID, True);
    {$ELSE}
      {$IFDEF HR1847}
      gKRMgrProber.TunnelOC(FPoundTunnel.FID, True);
      {$ELSE}
      gProberManager.TunnelOC(FPoundTunnel.FID, True);
      {$ENDIF}
    {$ENDIF} //�����̵�

    {$IFDEF SWTC}
    WriteSysLog('�ѿ����̵ơ���һ״̬��'+FUIData.FNextStatus);
    if (FUIData.FNextStatus = sFlag_TruckBFM)and(FCardUsed = sFlag_Sale) then
      PlayVoice('�̵������,�뽫��Ƭ�����տ�Ʊ�䡢Ϊ����ӡ���ݺ����');
    {$ENDIF}

    Timer2.Enabled := True;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ %s.%s : %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ������
procedure TfFrameAutoPoundItem.InitSamples;
var nIdx: Integer;
begin
  SetLength(FValueSamples, FPoundTunnel.FSampleNum);
  FSampleIndex := Low(FValueSamples);

  for nIdx:=High(FValueSamples) downto FSampleIndex do
    FValueSamples[nIdx] := 0;
  //xxxxx
end;

//Desc: ��Ӳ���
procedure TfFrameAutoPoundItem.AddSample(const nValue: Double);
begin
  FValueSamples[FSampleIndex] := nValue;
  Inc(FSampleIndex);

  if FSampleIndex >= FPoundTunnel.FSampleNum then
    FSampleIndex := Low(FValueSamples);
  //ѭ������
end;

//Desc: ��֤�����Ƿ��ȶ�
function TfFrameAutoPoundItem.IsValidSamaple: Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;

  for nIdx:=FPoundTunnel.FSampleNum-1 downto 1 do
  begin
    if FValueSamples[nIdx] < 0.02 then Exit;
    //����������

    nVal := Trunc(FValueSamples[nIdx] * 1000 - FValueSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FPoundTunnel.FSampleFloat then Exit;
    //����ֵ����
  end;

  Result := True;
end;

procedure TfFrameAutoPoundItem.PlayVoice(const nStrtext: string);
begin
  {$IFNDEF DEBUG}
  if (Assigned(FPoundTunnel.FOptions)) and
     (CompareText('NET', FPoundTunnel.FOptions.Values['Voice']) = 0) then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);
  {$ENDIF}
end;

procedure TfFrameAutoPoundItem.Timer_SaveFailTimer(Sender: TObject);
begin
  inherited;
  try
    FDoneEmptyPoundInit := GetTickCount;
    Timer_SaveFail.Enabled := False;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ %s.%s : %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

procedure TfFrameAutoPoundItem.EditBillKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key = #13 then
  try
    Key := #0;
    EditBill.Text := Trim(EditBill.Text);

    if FIsWeighting or EditBill.Properties.ReadOnly or
       (EditBill.Text = '') then
    begin
      SwitchFocusCtrl(ParentForm, True);
      Exit;
    end;

    {$IFDEF DEBUG}
    FCardTmp := EditBill.Text;
    LoadBillItems(EditBill.Text);
    {$ENDIF}
  finally
    EditBill.Enabled := True;
  end;
end;

procedure TfFrameAutoPoundItem.LEDDisplay(const nContent: string);
begin
  {$IFDEF BFLED}
  WriteSysLog(Format('LEDDisplay:%s.%s', [FPoundTunnel.FID, nContent]));
  if Assigned(FPoundTunnel.FOptions) And
     (UpperCase(FPoundTunnel.FOptions.Values['LEDEnable'])='Y') then
  begin
    if FLEDContent = nContent then Exit;
    FLEDContent := nContent;
    gDisplayManager.Display(FPoundTunnel.FID, nContent);
  end;
  {$ENDIF}
end;

procedure TfFrameAutoPoundItem.HintLabelClick(Sender: TObject);
begin
  //FLastReader:= 'VY192168099065';
  //LoadBillItems('001881154551');
end;

procedure TfFrameAutoPoundItem.btn1Click(Sender: TObject);
begin
  if FxLastReader='' then Exit;
  OpenDoorByReader(FxLastReader, 'N');
end;
                                  
procedure TfFrameAutoPoundItem.btn2Click(Sender: TObject);
begin
  if FxLastReader='' then Exit;
  OpenDoorByReader(FxLastReader, 'Y');
end;

end.
