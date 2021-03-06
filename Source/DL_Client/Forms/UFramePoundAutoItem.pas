{*******************************************************************************
  作者: dmzn@163.com 2014-10-20
  描述: 自动称重通道项
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
    //卡片类型
    FLEDContent: string;
    //显示屏内容
    FIsWeighting, FIsSaving, FIsChkPoundStatus : Boolean;
    //称重标识,保存标识
    FPoundTunnel: PPTTunnelItem;
    //磅站通道
    FLastGS,FLastBT,FLastBQ: Int64;
    //上次活动
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //称重数据
    FLastCardDone: Int64;
    FLastCard, FCardTmp, FLastReader, FxLastReader, FLastTruckNo: string;
    //上次卡号, 临时卡号, 读卡器编号
    FSampleIndex: Integer;
    FValueSamples: array of Double;
    //数据采样
    FBarrierGate: Boolean;
    //是否采用道闸
    FEmptyPoundInit, FDoneEmptyPoundInit: Int64;
    //空磅计时,过磅保存后空磅
    FEmptyPoundIdleLong, FEmptyPoundIdleShort: Int64;
    Ftip : Boolean;
  private
    function ChkPoundStatus:Boolean;
    function ChkBillStatus(nLid:string):Boolean;
    function ChkOrderStatus(nLid:string):Boolean;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //界面数据
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //设置状态
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //关联通道
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //读取磅重
    procedure LoadBillItems(const nCard: string);
    //读取交货单
    procedure InitSamples;
    procedure AddSample(const nValue: Double);
    function IsValidSamaple: Boolean;
    //处理采样
    function SavePoundSale: Boolean;
    function SavePoundData: Boolean;
    //保存称重
    procedure WriteLog(nEvent: string);
    //记录日志
    procedure PlayVoice(const nStrtext: string);
    //播放语音
    procedure LEDDisplay(const nContent: string);
    //LED显示
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //子类继承
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //属性相关
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
  gSysLoger.AddLog(TfFrameAutoPoundItem, '自动称重业务', nEvent);
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
      else WriteSysLog('未设置读卡器标示、未有车辆刷卡过磅前将不能执行手动抬杆');
    except
      Application.MessageBox('提示：SetReader.ini 读取错误！','系统提示',MB_OK);
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
  //关闭表头端口
  inherited;
end;

function RoundFloat(f: double; i: integer): double;       //四舍五入
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
  ef := StrToFloat(FloatToStr(f)); //防止浮点运算的误差
  result := StrToFloat(FormatFloat(s, ef));
end;

//Desc: 设置运行状态图标
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
    //清理多余

    Lines.Add(DateTime2Str(Now) + #9 + nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;
//------------------------------------------------------------------------------
//Desc: 更新运行状态
procedure TfFrameAutoPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageGS, GetTickCount - FLastGS > 5 * 1000);
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: 关闭红绿灯
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

//Desc: 设置通道
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
        nHint := '检查地磅：连接地磅表头失败，请联系管理员检查硬件连接';
        WriteSysLog(nHint);
        PlayVoice(nHint);
      end;

      for nIdx:= 0 to 5 do
      begin
        Sleep(500);  Application.ProcessMessages;
        if StrToFloatDef(Trim(EditValue.Text), -1) > 0.12 then
        begin
          Result:= False;
          nHint := '检查地磅：地磅称重重量 %s ,不能进行称重作业';
          nhint := Format(nHint, [EditValue.Text]);
          WriteSysLog(nHint);

          PlayVoice(FLastTruckNo+' 当前地磅不在称重状态、相关车辆及人员请下榜');
          Break;
        end;
      end;
    except  on E: Exception do
      begin
        WriteSysLog(Format('磅站 %s.%s : 检查地磅状态 %s', [FPoundTunnel.FID,
                                                 FPoundTunnel.FName, E.Message]));
      end;
    end;
  finally
    FIsChkPoundStatus:= False;
    SetUIData(True);
  end;
end;

//Desc: 重置界面数据
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
          //关闭表头端口
        except  on E: Exception do
          begin
            WriteSysLog(Format('磅站 %s.%s : 关闭表头 %s', [FPoundTunnel.FID, FPoundTunnel.FName, E.Message]));
          end;
        end;

        Timer_ReadCard.Enabled := True;
        //启动读卡
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
    //已称过重量或销售,禁用临时模式
    RadioCC.Enabled := FID <> '';
    //只有销售有出厂模式

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //可输入项调整

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //可输入量调整

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
         nStr := '销售并单'
    else nStr := '销售';

    if FCardUsed=sFlag_Provide then nStr := '供应'
    else if FCardUsed=sFlag_DuanDao then nStr := '短倒';

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      EditMemo.Text := nStr + '称皮重';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '称毛重';
    end;
  end else
  begin
    if RadioLS.Checked then
      EditMemo.Text := '车辆临时称重';
    //xxxxx

    if RadioPD.Checked then
      EditMemo.Text := '车辆配对称重';
    //xxxxx
  end;
end;

//Date: 2014-09-19
//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TfFrameAutoPoundItem.LoadBillItems(const nCard: string);
var nRet: Boolean;
    nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nStr,nHint, nVoice, nSql, nPos: string;
begin
  nStr := Format('读取到卡号[ %s ],开始执行业务.', [nCard]);
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
    nVoice := '读取磁卡信息失败,请联系工作人员处理';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;
  FLastTruckNo:= nBills[0].FTruck;

  {$IFDEF SWTC}  //声威铜川工厂 门卫室管控车辆是否能上磅  校正库底装车车辆多次过磅状态
  if ChkBillStatus(nBills[0].FID)or(ChkOrderStatus(nBills[0].FID)) then
  begin
    nStr:= Format('订单 %s 车辆 %s、已被门卫室禁止上磅、请联系门卫室',
                                [nBills[0].FID, nBills[0].FTruck]);
    WriteSysLog(nStr);
    PlayVoice(nBills[0].FTruck + ' 当前不能过磅、请联系门卫室工作人员');
    Exit;
  end;
  {$ENDIF}


  {$IFDEF ChkSaleCardInTimeOut}      // 销售进厂超时检查
  if (FCardUsed=sFlag_Sale) and (nBills[0].FNextStatus = sFlag_TruckBFP) then
  begin
    GetSaleCardInTimeDiff(nBills[0].FID,nBills[0].FMinuteDate);
    if IsSaleCardInTimeOut(nBills[0].FMinuteDate) then
    begin
      nVoice := '您未在规定时间内进厂,请联系开票室重新开单';
      PlayVoice(nVoice);
      WriteLog(nVoice);
      SetUIData(True);
      Exit;
    end;
  end;
  {$ENDIF}

  {$IFDEF RemoteSnap}
  if chk1.Checked then
  if not VerifySnapTruck(FLastReader, nBills[0], nHint, nPos) then
  begin
    nVoice := '%s 车牌识别失败,请移动车辆或联系工作人员';
    nVoice := Format(nVoice, [nBills[0].FTruck]);

    WriteSysLog('识别结果 ' + nVoice);
    RemoteSnapDisPlay(nPos, nHint,sFlag_No);
    WriteSysLog(nHint);
//    PlayVoice(nHint);
//    SetUIData(True);
//    Exit;
  end
  else
  begin
    if nHint <> '' then
    begin
      RemoteSnapDisPlay(nPos, nHint,sFlag_No);
      WriteSysLog('车牌验证通过 '+nHint);
    end;
  end;
  {$ENDIF}
  //车牌匹配检查
                       
  nHint := '';
  nInt := 0;
                       
  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //状态校正
    {$IFDEF AllowMultiM}
    if (FStatus = sFlag_TruckBFM)And(FCardUsed=sFlag_Sale)  then
    begin
      FNextStatus := sFlag_TruckBFM;
      //销售允许多次过重
      AdjustBillStatus(FID);
      WriteSysLog(Format('车辆 %s 再次过毛重 ', [FTruck] ));
    end;
    {$ENDIF}

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //可称重状态判定

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s  ]  ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;

    nVoice := '车辆 %s 不能过磅,应该去 %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //车辆状态异常

    nHint := '该车辆当前不能过磅,详情如下: ' + #13#10#13#10 + nHint;
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
      //该标记有特殊用途

      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //累计量

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
    nStr := '磅站[ %s.%s ]: 车辆 %s 需等待 %d 秒后才能过磅';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            FUIData.FTruck, FPoundTunnel.FCardInterval - nInt]);
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;
  //指定时间内车辆禁止过磅

  InitSamples;
  //初始化样本

  try
    if not FPoundTunnel.FUserInput then
    if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
           OnPoundDataEvent, True) then
    begin
      nHint := '连接地磅表头失败，请联系管理员检查硬件连接';
      WriteSysLog(nHint);

      nVoice := nHint;
      PlayVoice(nVoice);

      SetUIData(True);
      Exit;
    end;
  except  on E: Exception do
      begin
        WriteSysLog(Format('磅站 %s.%s : 开启读取地磅数据 %s', [FPoundTunnel.FID,
                                                 FPoundTunnel.FName, E.Message]));
      end;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  //停止读卡,开始称重

  if FBarrierGate then
  begin
    {$IFDEF ZZSJ}
    if (FUIData.FStatus = sFlag_TruckIn) or
       (FUIData.FStatus = sFlag_TruckBFP) then
    begin
      nStr := '[n1]%s刷卡成功请上磅,并熄火停车,进厂请系好安全带,戴好安全帽';
      nStr := Format(nStr, [FUIData.FTruck]);
    end;
    {$ELSE}
    nStr := '[n1]%s刷卡成功请上磅,并熄火停车';
    nStr := Format(nStr, [FUIData.FTruck]);
    {$ENDIF}

    if Chk2.Checked then nStr:= '刷卡成功';
    PlayVoice(nStr);
    //读卡成功，语音提示

    {$IFNDEF DEBUG}
    OpenDoorByReader(FLastReader);
    //打开主道闸
    {$ENDIF}
  end;
  //车辆上磅
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

function TfFrameAutoPoundItem.ChkOrderStatus(nLid:string):Boolean;
VAR nSql : string;
begin
  nSql := 'Select * From %s Where D_ID=''%s'' And D_Refuse=''Y'' ';
  nSql := Format(nSql, [sTable_OrderDtl , nLid]);
  with FDM.QueryTemp(nSql) do
  begin
    Result:= RecordCount > 0
  end;
end;

//------------------------------------------------------------------------------
//Desc: 由定时读取交货单
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
    WriteLog('正在读取磁卡号.');
    {$IFNDEF DEBUG}
    nCard := Trim(ReadPoundCard(FPoundTunnel.FID, FLastReader));
    {$ENDIF}

    if nCard = '' then Exit;
    if nCard <> FLastCard then
         nDoneTmp := 0
    else nDoneTmp := FLastCardDone;
    //新卡时重置

    
    Ftip:= False;    FxLastReader:= FLastReader;
    {$IFDEF DEBUG}
    nStr := '磅站 %s.%s : 读取到新卡号::: %s =>旧卡号::: %s';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            nCard, FLastCard]);
    WriteSysLog(nStr);
    {$ENDIF}

    nLast := Trunc((GetTickCount - nDoneTmp) / 1000);
    if (nDoneTmp <> 0) and (nLast < FPoundTunnel.FCardInterval)  then
    begin
      nStr := '磅站 %s.%s : 磁卡 %s 需等待 %d 秒后才能过磅';
      nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
              nCard, FPoundTunnel.FCardInterval - nLast]);
      WriteSysLog(nStr);
      Exit;
    end;
    IF not chk3.Checked then
    if Not ChkPoundStatus then Exit;
    //检查地磅状态 如不为空磅，则喊话 退出称重

    FCardTmp := nCard;
    EditBill.Text := nCard;
    LoadBillItems(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('磅站 %s.%s : 加载订单 ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //错误则重置
    end;
  end;
end;

//Desc: 保存销售
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
      WriteLog('请先称量皮重');
      Exit;
    end;

    nNet := GetTruckEmptyValue(FUIData.FTruck);
    nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

    if (nNet > 0) and (Abs(nVal) > gSysParam.FPoundSanF) then
    begin
      {$IFDEF AutoPoundInManual}
      nStr := '车辆[%s]实时皮重误差较大,请通知司机检查车厢';
      nStr := Format(nStr, [FUIData.FTruck]);
      PlayVoice(nStr);

      nStr := '车辆[ %s ]实时皮重误差较大,详情如下:' + #13#10#13#10 +
              '※.实时皮重: %.2f吨' + #13#10 +
              '※.历史皮重: %.2f吨' + #13#10 +
              '※.误差量: %.2f公斤' + #13#10#13#10 +
              '是否继续保存?';
      nStr := Format(nStr, [FUIData.FTruck, FUIData.FPData.FValue,
              nNet, nVal]);
      if not QueryDlg(nStr, sAsk) then Exit;
      {$ELSE}
      nStr := '车辆[ %s ]实时皮重误差较大,详情如下:' + #13#10 +
              '※.实时皮重: %.2f吨' + #13#10 +
              '※.历史皮重: %.2f吨' + #13#10 +
              '※.误差量: %.2f公斤' + #13#10 +
              '允许过磅,请选是;禁止过磅,请选否.';
      nStr := Format(nStr, [FUIData.FTruck, FUIData.FPData.FValue,
              nNet, nVal]);

      if not VerifyManualEventRecord(FUIData.FID + sFlag_ManualB, nStr,
        sFlag_Yes, False) then
      begin
        AddManualEventRecord(FUIData.FID + sFlag_ManualB, FUIData.FTruck, nStr,
            sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepDaTing, True);
        WriteSysLog(nStr);

        nStr := '[n1]%s皮重超出预警,请下磅联系开票员处理后再次过磅';
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
      WriteLog('请先称量毛重');
      Exit;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    nNet := FUIData.FMData.FValue;
    nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;


    WriteLog(Format('单号：%s 毛重：%.2f 吨 皮重：%.2f 吨 净重：%.2f 公斤  样品 %s ',
                          [FBillItems[0].FID, FUIData.FMData.FValue, FUIData.FPData.FValue, nVal, FBillItems[0].FIsSample]));

    if (nNet > 0) and (Abs(nVal)<= gSysParam.FEmpTruckWc) and (FBillItems[0].FIsSample<>sFlag_Yes) then
    begin
      // 判断为空车出厂
      WriteLog(Format('单号：%s 非样品订单、净重：%.2f 公斤 符合空车出厂条件 予以空车出厂标示',
                          [FBillItems[0].FID, nVal]));
      FBillItems[0].FYSValid:= 'Y';
      //*****************
      nStrSql := 'UPDate %s Set L_EmptyOut=''Y'' Where L_Id=''%s''  ';
      nStrSql := Format(nStrSql, [sTable_Bill, FBillItems[0].FID]);
      FDM.ExecuteSQL(nStrSql);
    end;


    if FBillItems[0].FYSValid <> sFlag_Yes then //判断是否空车出厂
    begin
      if FUIData.FPData.FValue > FUIData.FMData.FValue then
      begin
        WriteLog('皮重应小于毛重');
        Exit;
      end;

      nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
      //净重
      nVal := nNet * 1000 - FInnerData.FValue * 1000;
      //与开票量误差(公斤)

      with gSysParam,FBillItems[0] do
      begin
        {$IFDEF DaiStepWuCha}
        if FType = sFlag_Dai then
        begin
          GetPoundAutoWuCha(FPoundDaiZ, FPoundDaiF, FInnerData.FValue);
          //计算误差
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

        {$IFDEF ShowDaiWuChaLog}
        if (FType = sFlag_Dai) then
        WriteSysLog('袋装称重：'+ Format('%s %s 开单量: %.2f吨 装车量: %.2f吨 误差量: %.2f公斤 误差标准：%g, %g',
                            [FId, FTruck, FInnerData.FValue, nNet, nVal, FPoundDaiZ, FPoundDaiF]));
        {$ENDIF}

        if ({$IFDEF SampleNoWuChaChk}(FBillItems[0].FIsSample<>sFlag_Yes)and{$ENDIF}   // 样品不做误差校验 （泾阳）
            (FType = sFlag_Dai) and (
            ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
            ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF)))) then
        begin
          {$IFDEF AutoPoundInManual}
          nStr := '车辆[%s]实际装车量误差较大，请通知司机点验包数';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);

          nStr := '车辆[ %s ]实际装车量误差较大,详情如下:' + #13#10#13#10 +
                  '※.开单量: %.2f吨' + #13#10 +
                  '※.装车量: %.2f吨' + #13#10 +
                  '※.误差量: %.2f公斤';

          if FDaiWCStop then
          begin
            nStr := nStr + #13#10#13#10 + '请通知司机点验包数.';
            nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);

            ShowDlg(nStr, sHint);
            Exit;
          end else
          begin
            nStr := nStr + #13#10#13#10 + '是否继续保存?';
            nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);
            if not QueryDlg(nStr, sAsk) then Exit;
          end;
          {$ELSE}
          nStr := '车辆[ %s ]实际装车量误差较大,详情如下:' + #13#10 +
                  '※.开单量: %.2f吨' + #13#10 +
                  '※.装车量: %.2f吨' + #13#10 +
                  '※.误差量: %.2f公斤' + #13#10 +
                  '检测完毕后,请点确认重新过磅.';
          nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);

          if not VerifyManualEventRecord(FID + sFlag_ManualC, nStr) then
          begin
            AddManualEventRecord(FID + sFlag_ManualC, FTruck, nStr,
              sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepJianZhuang, True);
            WriteSysLog(nStr);

            nStr := '车辆[n1]%s净重[n2]%.2f吨,开票量[n2]%.2f吨,'+
                    '误差量[n2]%.2f公斤,请去包装点包';
            nStr := Format(nStr, [FTruck, nNet, FInnerData.FValue, nVal]);
            PlayVoice(nStr);

            nStr := GetTruckNO(FTruck) + '请去包装点包';
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
          nStr := '车辆[n1]%s[p500]净重[n2]%.2f吨[p500]开票量[n2]%.2f吨,请卸货';
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
        nStr := '车辆[n1]%s[p500]空车出厂超差[n2]%.2f公斤,请司机联系司磅管理员检查车厢';
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
    
                          WriteSysLog(Format('自动称重 品种：%s 毛重：%.2f 皮重：%.2f ', [FUIData.FStockName, FMData.FValue, FPData.FValue]));
                          
    FPoundID := sFlag_Yes;
    //标记该项有称重数据
    Result := SaveLadingBills(FNextStatus, FBillItems, FPoundTunnel);
    //保存称重
  end;
end;

//------------------------------------------------------------------------------
//Desc: 原材料或临时
function TfFrameAutoPoundItem.SavePoundData: Boolean;
var nNextStatus, nSql: string;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      WriteLog('皮重应小于毛重 P:'+FloatToStr(FUIData.FPData.FValue)+' M:'+FloatToStr(FUIData.FMData.FValue));
      PlayVoice('皮重应小于毛重');
      Exit;
    end;
  end;
                            WriteSysLog(Format('自动称重 品种：%s  毛重：%.2f  皮重：%.2f', [FUIData.FStockName,
                                                                      FUIData.FMData.FValue, FUIData.FPData.FValue]));

  nNextStatus := FBillItems[0].FNextStatus;
  //暂存过磅状态

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //复制用户界面数据

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    FPData.FValue:= RoundFloat(FPData.FValue, 2);
    FMData.FValue:= RoundFloat(FMData.FValue, 2);
    ///******  优化称重精度为 小数点后 2 位

    //**************************************************************************
    ///   无需验收品种 二次过磅时   直接标记为验收
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
                (FYSValid<>sflag_Yes) then  // 原料二次称重拒收情况 将执行毛重=皮重 拒收流程
    begin
      WriteSysLog(Format('订单 %s 被拒收', [FID]));
      FPData.FValue:= FMData.FValue;
    end;

    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  if FCardUsed = sFlag_Provide then
       Result := SavePurchaseOrders(nNextStatus, FBillItems,FPoundTunnel)
  else Result := SaveDuanDaoItems(nNextStatus, FBillItems, FPoundTunnel);
  //保存称重
end;

//Desc: 读取表头数据
procedure TfFrameAutoPoundItem.OnPoundDataEvent(const nValue: Double);
begin
  try
    if FIsSaving then Exit;
    //正在保存。。。

    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站 %s.%s : %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

//Desc: 处理表头数据
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
    //检查地磅状态
    if not FIsWeighting then Exit;
    //不在称重中
    if gSysParam.FIsManual then Exit;
    //手动时无效

    if nValue < FPoundTunnel.FPort.FMinValue then //空磅
    begin
      if FEmptyPoundInit = 0 then
        FEmptyPoundInit := GetTickCount;
      nInt := GetTickCount - FEmptyPoundInit;

      if (nInt > FEmptyPoundIdleLong * 1000) then
      begin  //上磅时间,延迟重置
        FIsWeighting :=False;
        Timer_SaveFail.Enabled := True;

        WriteSysLog('刷卡后司机无响应,退出称重.');
        Exit;
      end
      else
      begin
        if ((FEmptyPoundIdleLong * 1000 - nInt)<=20) And not Ftip then
        begin
          Ftip:= True;
          nStr:= Format('车辆 %s 请在 20 秒内上磅.', [FUIData.FTruck, FUIData.FValue]);
          PlayVoice(nStr);
        end;
      end;


      if (nInt > FEmptyPoundIdleShort * 1000) and   //保证空磅
         (FDoneEmptyPoundInit>0) and (GetTickCount-FDoneEmptyPoundInit>nInt) then
      begin
        FIsWeighting :=False;
        Timer_SaveFail.Enabled := True;

        WriteSysLog('司机已下磅,退出称重.');
        Exit;
      end;
      //上次保存成功后,空磅超时,认为车辆下磅

      Exit;
    end else
    begin
      FEmptyPoundInit := 0;
      if FDoneEmptyPoundInit > 0 then
        FDoneEmptyPoundInit := GetTickCount;
      //车辆称重完毕后，未下磅
    end;

    AddSample(nValue);
    if not IsValidSamaple then Exit;
    //样本验证不通过

    if Length(FBillItems) < 1 then Exit;
    //无称重数据

    if (FCardUsed = sFlag_Provide)or(FCardUsed = sFlag_DuanDao) then            // 采购、短倒单
    begin
      if FInnerData.FPData.FValue > 0 then
      begin
        if nValue <= FInnerData.FPData.FValue then
        begin
          FUIData.FPData := FInnerData.FMData;
          FUIData.FMData := FInnerData.FPData;

          FUIData.FPData.FValue := nValue;
          FUIData.FNextStatus := sFlag_TruckBFP;                                //WriteSysLog('称重  切换为称皮重');
          //切换为称皮重
        end else
        begin
          FUIData.FPData := FInnerData.FPData;
          FUIData.FMData := FInnerData.FMData;

          FUIData.FMData.FValue := nValue;
          FUIData.FNextStatus := sFlag_TruckBFM;
          //切换为称毛重
        end;
      end else FUIData.FPData.FValue := nValue;
    end else
    if FBillItems[0].FNextStatus = sFlag_TruckBFP then
         FUIData.FPData.FValue := nValue
    else FUIData.FMData.FValue := nValue;

    SetUIData(False);
    //更新界面

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
      nStr := '车辆未停到位,请移动车辆.';
      PlayVoice(nStr);
      LEDDisplay(nStr);

      InitSamples;
      Exit;
    end;

//    {$IFDEF SanPoundChKJZ}
//    if FUIData.FValue>StrToFloatDef(edt1.Text, 49) then
//    begin
//      nCanSave:= False;
//      WriteSysLog(Format('车辆 %s 净重 %.2f 已超规定上限,称重无效.', [FUIData.FTruck, FUIData.FValue]));
//
//      nStr := '车辆当前净重'+Format(' %.2f ', [FUIData.FValue])+'已超规定上限、本次称重无效、请倒车下磅.';
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
        {$IFDEF PoundTipsWeight}      // 出厂提示净重    进厂皮重
        if  (FCardUsed = sFlag_Sale) then
        if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
        begin
          nJVal:= 0;
          nJVal:= FUIData.FMData.FValue - FUIData.FPData.FValue;
          //PlayVoice(Format('[ %s ]净重 %.2f 吨', [FUIData.FTruck, nJVal]));
          FZLValue:= Format('[ %s ]净重 %.2f 吨', [FUIData.FTruck, nJVal]);
        end
        else if (FUIData.FPData.FValue > 0) then
        begin
          //PlayVoice(Format('[ %s ]皮重 %.2f 吨', [FUIData.FTruck, FUIData.FPData.FValue]));
          FZLValue:= Format('[ %s ]皮重 %.2f 吨', [FUIData.FTruck, FUIData.FPData.FValue]);
        end;
        {$ENDIF}

        if (FCardUsed = sFlag_Sale) and (FBillItems[0].FType = sFlag_Dai)
           and (FBillItems[0].FNextStatus = sFlag_TruckBFM) then
          nStr := GetTruckNO(FUIData.FTruck) + '票重:' +
                  GetValue(StrToFloatDef(EditZValue.Text,0))
        else
          nStr := GetTruckNO(FUIData.FTruck) + '重量:' + GetValue(nValue);
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

        nStr := '本次称重无效,请下磅后联系开票室工作人员帮您处理';
        {$IFDEF PoundOpenBackGate}
        nStr := nStr + ',请倒车下磅';
        {$ENDIF}
        PlayVoice(nStr);
        LEDDisplay(nStr);
        WriteSysLog(Format('车辆 %s 称重无效,请核对该订单所属单位资金情况、可能为信用到期或实际账户资金不足.', [FUIData.FTruck]));
      end;
    end;

    if FBarrierGate then
    begin
      sFlag_OPenDoor:= sFlag_No;   //默认打开副道闸
      {$IFDEF PoundOpenBackGate}
      if (not nRet) then  //and (FUIData.FType = sFlag_Dai)
      begin
        sFlag_OPenDoor:=  sFlag_Yes;
        //特殊情况过磅失败打开主道闸(后杆)
      end;
      {$ENDIF}

      OpenDoorByReader(FLastReader, sFlag_OPenDoor);
      //打开道闸
    end;
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站 %s.%s : %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

procedure TfFrameAutoPoundItem.TimerDelayTimer(Sender: TObject);
begin
  try
    TimerDelay.Enabled := False;
    WriteSysLog(Format('对车辆 %s 称重完毕.', [FUIData.FTruck]));
    {$IFDEF CQJJ}
    PlayVoice('称重完毕,'+FZLValue+' 请下榜');
    {$ELSE}
    PlayVoice(#9 + FUIData.FTruck);
    //播放语音
    {$ENDIF}

    FLastCard     := FCardTmp;
    FLastCardDone := GetTickCount;
    FDoneEmptyPoundInit := GetTickCount;
    //保存状态

    if not FBarrierGate then
      FIsWeighting := False;
    //磅上无道闸时，即时过磅完毕

    {$IFDEF MITTruckProber}
        TunnelOC(FPoundTunnel.FID, True);
    {$ELSE}
      {$IFDEF HR1847}
      gKRMgrProber.TunnelOC(FPoundTunnel.FID, True);
      {$ELSE}
      gProberManager.TunnelOC(FPoundTunnel.FID, True);
      {$ENDIF}
    {$ENDIF} //开红绿灯

    {$IFDEF SWTC}
    WriteSysLog('已开红绿灯、下一状态：'+FUIData.FNextStatus);
    if (FUIData.FNextStatus = sFlag_TruckBFM)and(FCardUsed = sFlag_Sale) then
      PlayVoice('绿灯亮起后,请将卡片放入收卡票箱、为您打印单据后出厂');
    {$ENDIF}

    Timer2.Enabled := True;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站 %s.%s : %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 初始化样本
procedure TfFrameAutoPoundItem.InitSamples;
var nIdx: Integer;
begin
  SetLength(FValueSamples, FPoundTunnel.FSampleNum);
  FSampleIndex := Low(FValueSamples);

  for nIdx:=High(FValueSamples) downto FSampleIndex do
    FValueSamples[nIdx] := 0;
  //xxxxx
end;

//Desc: 添加采样
procedure TfFrameAutoPoundItem.AddSample(const nValue: Double);
begin
  FValueSamples[FSampleIndex] := nValue;
  Inc(FSampleIndex);

  if FSampleIndex >= FPoundTunnel.FSampleNum then
    FSampleIndex := Low(FValueSamples);
  //循环索引
end;

//Desc: 验证采样是否稳定
function TfFrameAutoPoundItem.IsValidSamaple: Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;

  for nIdx:=FPoundTunnel.FSampleNum-1 downto 1 do
  begin
    if FValueSamples[nIdx] < 0.02 then Exit;
    //样本不完整

    nVal := Trunc(FValueSamples[nIdx] * 1000 - FValueSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FPoundTunnel.FSampleFloat then Exit;
    //浮动值过大
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
      WriteSysLog(Format('磅站 %s.%s : %s', [FPoundTunnel.FID,
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
