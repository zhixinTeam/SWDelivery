{*******************************************************************************
  ����: dmzn@163.com 2012-4-22
  ����: Ӳ������ҵ��
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam, DB, TypInfo,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue, UMgrBasisWeight,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrHardHelper, U02NReader, UMgrERelay, UMgrRemotePrint, UFormCtrl,
  UMgrLEDDisp, UMgrRFID102, UBlueReader, UMgrTTCEM100, UMgrTruckProbe,
  {$IFDEF HKVDVR}UMgrCamera, {$ENDIF} UMgrRemoteSnap, UMgrVoiceNet,
  UMgrSendCardNo;

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
//���¿��ŵ����ͷ
procedure WhenBasisWeightStatusChange(const nTunnel: PBWTunnel);
//����װ��״̬�ı�

procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
//Ʊ�������
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���¿���
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���ų�ʱ
procedure WhenBusinessMITSharedDataIn(const nData: string);
//ҵ���м����������
function GetJSTruck(const nTruck,nBill: string): string;
//��ȡ��������ʾ����
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//����������


{$IFDEF HKVDVR}
procedure WhenCaptureFinished(const nPtr: Pointer);
//����ͼƬ
{$ENDIF}

function VerifySnapTruck(const nTruck,nBill,nPos: string;var nResult: string): Boolean;
//����ʶ��



implementation                       

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor;

const
  sPost_In   = 'in';
  sPost_Out  = 'out';

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
function CallBusinessCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2015-08-06
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessPurchaseOrder(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessPurchaseOrder);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2018-04-25
//Parm: ����;����;����;���
//Desc: �����м���ϵĶ̵����ݶ���
function CallBusinessDuanDao(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessDuanDao);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-16
//Parm: ����;����;����;���
//Desc: ����Ӳ���ػ��ϵ�ҵ�����
function CallHardwareCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_HardwareCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '�ֳ����������', nEvent);
end;

//Date: 2018-04-25
//Parm: �ſ���;��λ;�̵����б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ķ̵����б�
function GetDuanDaoItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2019-03-12
//Parm: ͨ����;��ʾ��Ϣ;���ƺ�
//Desc: ��nTunnel��С������ʾ��Ϣ
procedure ShowLEDHint(const nTunnel: string; nHint: string;
  const nTruck: string = '');
begin
  if nTruck <> '' then
    nHint := nTruck + StringOfChar(' ', 12 - Length(nTruck)) + nHint;
  //xxxxx
  
  if Length(nHint) > 24 then
    nHint := Copy(nHint, 1, 24);
  gERelayManager.ShowTxt(nTunnel, nHint);
end;

//Date: 2018-04-25
//Parm: ��λ;�̵����б�
//Desc: ����nPost��λ�ϵĶ̵�������
function SaveDuanDaoItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessDuanDao(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;


//Date: 2012-3-23
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���
//Desc: ��ȡ�ſ�ʹ������
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���;��λ;�ɹ����б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingOrders(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2015-08-06
//Parm: ��λ;�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ�������
function SaveLadingOrders(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: �¼�����;��λ��ʶ
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gDisplayManager.Display(nPost, nEvent);
  gSysLoger.AddLog(THardwareHelper, 'Ӳ���ػ�����', nEvent);
end;

//Date: 2018-03-28
//Parm: ��λ
//Desc: ��ѯDICT�����λ�Ƿ��䱸������
function GetHasVoice(const nPost: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  Result := False;
  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select * From %s Where D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, nPost]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      if FieldByName('D_ParamB').AsString = sFlag_Yes then
        Result := True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2017-10-16
//Parm: ����;��λ;ҵ��ɹ�
//Desc: �����Ÿ�����
procedure MakeGateSound(const nText,nPost: string; const nSucc: Boolean);
var nStr: string;
    nInt: Integer;
begin
  if nPost='' then Exit;
  try
    if gNetVoiceHelper=nil then Exit;
    if nSucc then
         nInt := 2
    else nInt := 3;

    //gHKSnapHelper.Display(nPost, nText, nInt);
    //С����ʾ

    //if GetHasVoice(nPost) then
      gNetVoiceHelper.PlayVoice(nText, nPost);
    //��������
    //WriteHardHelperLog(Format('��������[%s %s]', [nPost ,nText]));
  except
    on nErr: Exception do
    begin
      nStr := '����[ %s ]����ʧ��,����: %s';
      nStr := Format(nStr, [nPost, nErr.Message]);
      WriteHardHelperLog(nStr);
    end;
  end;
end;

procedure BlueOpenDoor(const nReader: string);
var nIdx: Integer;
begin
  nIdx := 0;
  if nReader <> '' then
  while nIdx < 5 do
  begin
    if gHardwareHelper.ConnHelper then
         gHardwareHelper.OpenDoor(nReader)
    {$IFDEF BlueCard}
    else gHYReaderManager.OpenDoor(nReader);
    {$ELSE}
    else gHYReaderManager.OpenDoor(nReader);
    {$ENDIF}

    Inc(nIdx);
  end;
end;

//Date: 2012-4-22
//Parm: ����
//Desc: ��nCard���н���
procedure MakeTruckIn(const nCard,nReader: string; const nDB: PDBWorker);
var nStr,nStrx,nTruck,nCardType: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nRet: Boolean;
begin
  if gTruckQueueManager.IsTruckAutoIn and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    Exit;
  end; //ͬ��ͷͬ��,��2�����ڲ������ν���ҵ��.

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if nCardType = sFlag_Provide then
        nRet := GetLadingOrders(nCard, sFlag_TruckIn, nTrucks)

  else if nCardType = sFlag_DuanDao then
        nRet := GetDuanDaoItems(nCard, sFlag_TruckIn, nTrucks)

  else  nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks);


  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    {$IFDEF ChkSaleCardInTimeOut}
    if (FMINUTEDate>gTruckQueueManager.SaleCardInTimeDiff)and
                  (gTruckQueueManager.SaleCardInTimeDiff>0) and
                  (nCardType = sFlag_Sale) then
    begin
      nStr := '����[ %s ]����ʱ��൱ǰ %d �ѳ��涨ʱ�� %d ,����ˢ����Ч.';
      nStr := Format(nStr, [FTruck, FMINUTEDate, gTruckQueueManager.SaleCardInTimeDiff]);

      //  ����ʱ��������ʱ�䳬ʱ ��Ȼ����ܾ�
      nStrx := 'UPDate %s Set L_Status=''N'', L_NextStatus='''' Where L_ID=''%s''';
      nStrx := Format(nStrx, [sTable_Bill, FID]);
      gDBConnManager.ExecSQL(nStrx);
      //***************** //  �Զ����������֪ͨ�������������
      {$IFDEF MsgPoundVoice}
      IF (gTruckQueueManager.IsTruckAutoIn) then
      begin
        gHardwareHelper.SetCardLastDone(nCard, nReader);
        gHardwareHelper.SetReaderCard(nReader, nCard);
      end;
      {$ENDIF}

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
    {$ENDIF}

    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //δ����,���ѽ���

    {$IFDEF SWAS}        // ������ �Զ����� ��װ��ë��ʧ�ܺ�ذ�ж�ϻ�װ����Ҫ�Ӱ��Ϲ�  or(FStatus = sFlag_TruckFH)
    IF ((FStatus = sFlag_TruckZT)) and (gTruckQueueManager.IsTruckAutoIn) then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end;
    {$ENDIF}

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],����ˢ����Ч.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      if gTruckQueueManager.TruckReInfactFobidden(nTrucks[0].FTruck) then
      begin
        BlueOpenDoor(nReader);
        //̧��

        nStr := '����[ %s ]�ٴ�̧�˲���.';
        nStr := Format(nStr, [nTrucks[0].FTruck]);
        WriteHardHelperLog(nStr, sPost_In);
      end;
    end;

    if nCardType = sFlag_DuanDao then
    begin
      nStr := '%s����';
      nStr := Format(nStr, [nTrucks[0].FTruck]);
      WriteHardHelperLog(nStr, sPost_In);
      gDisplayManager.Display(nReader, nStr);
    end;

    Exit;
  end;

  if nCardType <> sFlag_Sale then
  begin
    if nCardType = sFlag_Provide then
      nRet := SaveLadingOrders(sFlag_TruckIn, nTrucks)

    else if nCardType = sFlag_DuanDao then
      nRet := SaveDuanDaoItems(sFlag_TruckIn, nTrucks)

    else nRet := False;
    //xxxxx

    if not nRet then
    begin
      nStr := '����[ %s ]��������ʧ��.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;

    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      BlueOpenDoor(nReader);
      //̧��
    end;

    nStr := '%s�ſ�[%s]����̧�˳ɹ�';
    nStr := Format(nStr, [BusinessToStr(nCardType), nCard]);
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;
  //�ɹ��ſ�ֱ��̧��

  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ʱ����(����ģʽ)
  try
    SyncLock.Enter;
    nStr := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nInt := TruckInLine(nStr, PLineItem(Lines[nIdx]).FTrucks);
      if nInt >= 0 then
      begin
        nPLine := Lines[nIdx];
        //nPTruck := nPLine.FTrucks[nInt];
        Break;
      end;
    end;

    if not Assigned(nPLine) then
    begin
      nStr := '����[ %s ]û���ڵ��ȶ�����.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;

  if not SaveLadingBills(sFlag_TruckIn, nTrucks) then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if gTruckQueueManager.IsTruckAutoIn then
  begin
    gHardwareHelper.SetCardLastDone(nCard, nReader);
    gHardwareHelper.SetReaderCard(nReader, nCard);

    {$IFDEF SWTC}       // ͭ�����ϳ�����Ҫ̧�� ��������ͨ���Զ�����
    IF nReader='HY192168099063' then
      BlueOpenDoor(nReader);
    {$ENDIF}
  end else
  begin
    BlueOpenDoor(nReader);                   WriteHardHelperLog(nReader+' ִ��̧��');
    //̧��
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ģʽ,����ʱ�󶨵���(һ���൥)
  try
    SyncLock.Enter;
    nTruck := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nPLine := Lines[nIdx];
      nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

      if nInt < 0 then Continue;
      nPTruck := nPLine.FTrucks[nInt];

      nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
      nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
              nPTruck.FBill]);
      //xxxxx

      gDBConnManager.WorkerExec(nDB, nStr);
      //��ͨ��
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2012-4-22
//Parm: ����;��ͷ;��ӡ��;���鵥��ӡ��
//Desc: ��nCard���г���
function MakeTruckOut(const nCard,nReader,nPrinter: string;
 const nHYPrinter: string = ''): Boolean;
var nStr,nCardType: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
begin
  Result := False;
  nCardType := '';
  try
    if not GetCardUsed(nCard, nCardType) then Exit;

    if nCardType = sFlag_Provide then
      nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks) else
    if nCardType = sFlag_Sale then
      nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
    if nCardType = sFlag_DuanDao then
      nRet := GetDuanDaoItems(nCard, sFlag_TruckOut, nTrucks) else nRet := False;

    if not nRet then
    begin
      nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
      nStr := Format(nStr, [nCard]);

      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;

    if Length(nTrucks) < 1 then
    begin
      nStr := '�ſ�[ %s ]û����Ҫ��������.';
      nStr := Format(nStr, [nCard]);

      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;

    for nIdx:=Low(nTrucks) to High(nTrucks) do
    with nTrucks[nIdx] do
    begin
      if FNextStatus = sFlag_TruckOut then Continue;
      nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
      nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;

    if nCardType = sFlag_Provide then
      nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks) else
    if nCardType = sFlag_Sale then
      nRet := SaveLadingBills(sFlag_TruckOut, nTrucks) else
    if nCardType = sFlag_DuanDao then
      nRet := SaveDuanDaoItems(sFlag_TruckOut, nTrucks);

    if not nRet then
    begin
      nStr := '����[ %s ]��������ʧ��.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_Out);
      Exit;
    end;

    if nReader <> '' then
      BlueOpenDoor(nReader); //̧��
    Result := True;

    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      {$IFDEF PrintBillMoney}
      if CallBusinessCommand(cBC_GetZhiKaMoney,nTrucks[nIdx].FZhiKa,'',@nOut) then
           nStr := #8 + nOut.FData
      else nStr := #8 + '0';
      {$ELSE}
      nStr := '';
      {$ENDIF}

      {$IFDEF PoundMPrintOrder}
      // ������������ ԭ�ϳ�ж�Ϻ���ش�Ʊ�������ٴ�Ʊ
      if nCardType = sFlag_Provide then Exit;
      {$ENDIF}

      nStr := nStr + #7 + nCardType;
      //�ſ�����
      if nHYPrinter <> '' then
        nStr := nStr + #6 + nHYPrinter;
      //���鵥��ӡ��

      if nPrinter = '' then
           gRemotePrinter.PrintBill(nTrucks[nIdx].FID + nStr)
      else gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #9 + nPrinter + nStr);

      WriteHardHelperLog(Format('��Ӵ�ӡ���񣬵��ţ�%s', [(nTrucks[nIdx].FID)]));
    end; //��ӡ����
  except on Ex:Exception do
    begin
      WriteHardHelperLog(Ex.Message);
    end;
  end;
end;

//Date: 2012-10-19
//Parm: ����;��ͷ
//Desc: ��⳵���Ƿ��ڶ�����,�����Ƿ�̧��
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker);
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫͨ����բ�ĳ���.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '����[ %s ]���ڶ���,��ֹͨ����բ.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  BlueOpenDoor(nReader);
  //̧��

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //�������ʱ��,�������򽫲��ٽк�.
  end;
end;

//Date: 2012-4-22
//Parm: ��ͷ����
//Desc: ��nReader�����Ŀ��������嶯��
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr,nCard: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived����.');
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select C_Card From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nCard := Fields[0].AsString;
    end else
    begin
      nStr := Format('�ſ���[ %s ]ƥ��ʧ��.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;

    try
      if nReader.FType = rtIn then
      begin
        MakeTruckIn(nCard, nReader.FID, nDBConn);
      end else

      if nReader.FType = rtOut then
      begin
        if Assigned(nReader.FOptions) then
             nStr := nReader.FOptions.Values['HYPrinter']
        else nStr := '';
        MakeTruckOut(nCard, nReader.FID, nReader.FPrinter, nStr);
      end else

      if nReader.FType = rtGate then
      begin
        if nReader.FID <> '' then
          BlueOpenDoor(nReader.FID);
        //̧��
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nCard, nReader.FID, nDBConn);
        //̧��
      end;
    except
      On E:Exception do
      begin
        WriteHardHelperLog(E.Message);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2014-10-25
//Parm: ��ͷ����
//Desc: �����ͷ�ſ�����
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('�����ǩ %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  if nReader.FVirtual then
  begin
    case nReader.FVType of
      rt900 :gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
      rt02n :g02NReader.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard);
    end;
  end else g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
end;

procedure WhenBlueReaderCardArrived(nHost: TBlueReaderHost; nCard: TBlueReaderCard);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('���������� %s:%s', [nHost.FReaderID, nCard.FCard]));
  {$ENDIF}

  gHardwareHelper.SetReaderCard(nHost.FReaderID, nCard.FCard, False);
end;


//Date: 2019-03-12
//Parm: ��������;����
//Desc: ����nBill״̬д��nValue����
function SavePoundData(const nTunnel: PBWTunnel; const nValue: Double): Boolean;
var nStr, nStatus: string;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  try
    Result := False;
    nStr := 'Select L_Status,L_Value,L_PValue From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nTunnel.FBill]);
     
    with gDBConnManager.SQLQuery(nStr, nDBConn) do
    begin
      if RecordCount < 1 then
      begin
        WriteNearReaderLog(Format('������[ %s ]�Ѷ�ʧ', [nTunnel.FBill]));
        Exit;
      end;

      nStatus := FieldByName('L_Status').AsString;
      if nStatus = sFlag_TruckIn then //Ƥ��
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckBFP),
                SF('L_NextStatus', sFlag_TruckFH),
                SF('L_LadeTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', nValue, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_IsBasisWeightWithPM', sFlag_Yes)
          	 ], sTable_Bill, SF('L_ID', nTunnel.FBill), False);
        gDBConnManager.WorkerExec(nDBConn, nStr);

        gBasisWeightManager.SetTruckPValue(nTunnel.FID, nValue);
        //����ͨ��Ƥ��, ȷ�ϰ�������
      end else
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', nValue, sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_IsBasisWeightWithPM', sFlag_Yes)
          		], sTable_Bill, SF('L_ID', nTunnel.FBill), False);
        gDBConnManager.WorkerExec(nDBConn, nStr);
      end; //�Ż�״̬,ֻ��������,����ʱ���㾻��
    end;

    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;   
end;

//Date: 2019-03-11
//Parm: ����װ��ͨ��
//Desc: ��nTunnel״̬�ı�ʱ,����ҵ��
procedure WhenBasisWeightStatusChange(const nTunnel: PBWTunnel);
var nStr, nTruck, nVoiceTips, nVoiceID: string;
begin
  if nTunnel.FStatusNew = bsProcess then
  begin
    if nTunnel.FWeightMax > 0 then
         nStr := Format('%.2f/%.2f', [nTunnel.FWeightMax, nTunnel.FValTunnel])
    else nStr := Format('%.2f/%.2f', [nTunnel.FValue, nTunnel.FValTunnel]);

    ShowLEDHint(nTunnel.FID, nStr, nTunnel.FParams.Values['Truck']);
    Exit;
  end;

  case nTunnel.FStatusNew of
   bsInit      : WriteNearReaderLog('��ʼ��:' + nTunnel.FID);
   bsNew       : WriteNearReaderLog('�����:' + nTunnel.FID);
   bsStart     : WriteNearReaderLog('��ʼ����:' + nTunnel.FID);
   bsClose     : WriteNearReaderLog('���عر�:' + nTunnel.FID);
   bsDone      : WriteNearReaderLog('�������:' + nTunnel.FID);
   bsStable    : WriteNearReaderLog('����ƽ��:' + nTunnel.FID);
  end; //log

  if nTunnel.FStatusNew = bsClose then
  begin
    ShowLEDHint(nTunnel.FID, 'װ��ҵ��ر�', nTunnel.FParams.Values['Truck']);
    WriteNearReaderLog(nTunnel.FID+'��װ��ҵ��ر�');

    gBasisWeightManager.SetParam(nTunnel.FID, 'CanFH', sFlag_No);
    //֪ͨDCS�ر�װ��
    Exit;
  end;

  nVoiceID:= '';  nTruck:= '';
  nVoiceID:= nTunnel.FTunnel.FOptions.Values['VoiceCard'];
  nTruck  := nTunnel.FParams.Values['Truck'];                               
  if nTunnel.FStatusNew = bsDone then
  begin
    {$IFDEF BasisWeightWithPM}
    ShowLEDHint(nTunnel.FID, 'װ�������ȴ��������');
                                                                    MakeGateSound(nTruck+'װ����ɡ���ȴ��������', nVoiceID, False);

    WriteNearReaderLog(Format('%s %s װ����ɵȴ��������', [nTunnel.FID, nTruck]));
    {$ELSE}
    ShowLEDHint(nTunnel.FID, 'װ����� ���°�');
    WriteNearReaderLog(Format('%s %s װ�����', [nTunnel.FID, nTruck]));
                                                                    MakeGateSound(nTruck+'װ����ɡ����°�', nVoiceID, False);

    gProberManager.OpenTunnel(nTunnel.FID + '_Z');
    //�򿪵�բ
    {$ENDIF}

    gERelayManager.LineClose(nTunnel.FID);
    //ֹͣװ��
    gBasisWeightManager.SetParam(nTunnel.FID, 'CanFH', sFlag_No);
    //֪ͨDCS�ر�װ��
    Exit;
  end;

  if nTunnel.FStatusNew = bsStable then
  begin
    {$IFNDEF BasisWeightWithPM}
    Exit; //�ǿ�׼���,����������
    {$ENDIF}

    if (not gProberManager.IsTunnelOK(nTunnel.FID))
      {$IFDEF ProberMidChk} or gProberManager.IsTunnelOK(nTunnel.FID+'MID') {$ENDIF}
       then
    begin
      nTunnel.FStableDone := False;
      //���������¼�
      ShowLEDHint(nTunnel.FID, '����δͣ��λ ���ƶ�����');
                                                                    //MakeGateSound(nTruck+'δͣ��λ ���ƶ�����', nVoiceID, False);
      Exit;
    end;

    ShowLEDHint(nTunnel.FID, '����ƽ��׼���������');
    WriteNearReaderLog(nTunnel.FID+'������ƽ��׼���������');
                                   
    if SavePoundData(nTunnel, nTunnel.FValHas) then
    begin
      gBasisWeightManager.SetParam(nTunnel.FID, 'CanFH', sFlag_Yes);
      //��ӿɷŻұ��

      if nTunnel.FWeightDone then
      begin
        ShowLEDHint(nTunnel.FID, 'ë�ر���������°�.');            MakeGateSound(nTruck+'ë�ر���������°�', nVoiceID, False);
        WriteNearReaderLog(Format('%s %s ë�ر������', [nTunnel.FID, nTruck]));
        gProberManager.OpenTunnel(nTunnel.FID + '_Z');
      end else
      begin
        ShowLEDHint(nTunnel.FID, '���������ȴ�װ��.');
        WriteNearReaderLog(Format('%s %s ������ϡ��ȴ�װ��', [nTunnel.FID, nTruck]));
                                                                    MakeGateSound(nTruck+'��ȴ�װ��', nVoiceID, False);
      end;
    end else
    begin
      nTunnel.FStableDone := False;
      //���������¼�
      ShowLEDHint(nTunnel.FID, '���ر���ʧ������ϵ������Ա');       MakeGateSound(nTruck+'���ر���ʧ������ϵ������Ա', nVoiceID, False);
      WriteNearReaderLog(Format('%s %s ����ʧ�ܡ������ԱЭ��', [nTunnel.FID, nTruck]));
    end;
  end;
end;

//Date: 2018-01-08
//Parm: ����һ������
//Desc: ��������һ��������Ϣ
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var {$IFDEF DEBUG}nStr: string;{$ENDIF}
    nRetain: Boolean;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '����һ����������'  + nItem.FID + ' ::: ' + nItem.FCard;
  WriteHardHelperLog(nStr);
  {$ENDIF}

  try
    if not nItem.FVirtual then Exit;
    if nItem.FVType = rtOutM100 then
    begin
      nRetain := MakeTruckOut(nItem.FCard, nItem.FVReader, nItem.FVPrinter,
                              nItem.FVHYPrinter);
      //xxxxx
    end else
    begin
      gHardwareHelper.SetReaderCard(nItem.FVReader, nItem.FCard, False);
    end;
  finally
    gSysLoger.AddLog(T02NReader, '�ֳ����������', Format('���������ͣ�%s ��Ƭ���գ�%s',
          [GetEnumName(TypeInfo(TM100ReaderVType),Ord(nItem.FVType)), BoolToStr(nRetain, True)]));

    gM100ReaderManager.DealtWithCard(nItem, nRetain)
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-24
//Parm: ����;ͨ��;�Ƿ����Ⱥ�˳��;��ʾ��Ϣ
//Desc: ���nTuck�Ƿ������nTunnelװ��
function IsTruckInQueue(const nTruck,nTunnel: string; const nQueued: Boolean;
 var nHint: string; var nPTruck: PTruckItem; var nPLine: PLineItem;
 const nStockType: string = ''): Boolean;
var i,nIdx,nInt: Integer;
    nLineItem: PLineItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if (nIdx < 0) and (nStockType <> '') and (
       ((nStockType = sFlag_Dai) and IsDaiQueueClosed) or
       ((nStockType = sFlag_San) and IsSanQueueClosed)) then
    begin
      for i:=Lines.Count - 1 downto 0 do
      begin
        if Lines[i] = nPLine then Continue;
        nLineItem := Lines[i];
        nInt := TruckInLine(nTruck, nLineItem.FTrucks);

        if nInt < 0 then Continue;
        //���ڵ�ǰ����
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //ˢ��������е�Ʒ�ֲ�ƥ��

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //Ų���������µ�

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '����[ %s ]��������[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //��װ�ص�����

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]����[ %s ]������.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
    nPTruck.FStockName := nPLine.FName;
    //ͬ��������
    Result := True;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: ͨ����;������;
//Desc: ��nTunnel�ϴ�ӡnBill��α��
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nStr: string;
    nTask: Int64;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;
  if not gMultiJSManager.CountEnable then Exit;

  nTask := gTaskMonitor.AddTask('UHardBusiness.PrintBillCode', cTaskTimeoutLong);
  //to mon
  
  if not CallHardwareCommand(cBC_PrintCode, nBill, nTunnel, @nOut) then
  begin
    nStr := '��ͨ��[ %s ]���ͷ�Υ����ʧ��,����: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;������;��������
//Desc: ����nTunnel�ĳ�������������
function TruckStartJS(const nTruck,nTunnel,nBill: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]�Ѳ��ڶ���.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;

    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon
      
      gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nPTruck.FDai, True);
      gTaskMonitor.DelTask(nTask);
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: ��������
//Desc: ��ѯnBill�ϵ���װ��
function GetHasDai(const nBill: string): Integer;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  if not gMultiJSManager.ChainEnable then
  begin
    Result := 0;
    Exit;
  end;

  Result := gMultiJSManager.GetJSDai(nBill);
  if Result > 0 then Exit;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select T_Total From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsInteger;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingDai(const nCard: string; nTunnel: string);
var nStr: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := 'ͨ��[ %s ]װ����,ҵ����Ч.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;

    function IsGroupJSRun: Boolean;     // ���ͬһ����ͨ���Ƿ���������ҵ�ģ�ͬһ��Ƥ��ͬһ�����)
    var nField : TField;
        nTmp, nChkTunnel : string;
        nWorker, nxWorker: PDBWorker;
    begin
      WriteNearReaderLog('ͬ��ͨ����� ����.');
      Result:= False;   nWorker := nil;
      if nTunnel = '' then Exit;
      nStr := 'Select * From %s Where Z_Tunnel=''%s''';
      nStr := Format(nStr, [sTable_ZTMatch, nTunnel]);
      try
        with gDBConnManager.SQLQuery(nStr, nWorker) do
        if RecordCount > 0 then
        begin
          nField := FindField('Z_Group');
          if Assigned(nField) then nTmp := nField.AsString;
        end;

        if nTmp<>'' then
        begin
          //nxWorker := nil;
          nStr := 'Select * From %s Where Z_Group=''%s''';
          nStr := Format(nStr, [sTable_ZTMatch, nTmp]);
          with gDBConnManager.WorkerQuery(nWorker, nStr) do
          while not Eof do
          begin
            nField := FindField('Z_Tunnel');
            if Assigned(nField) then nChkTunnel := nField.AsString;

            if nChkTunnel = '' then Result:= True
            else Result := gMultiJSManager.IsJSRun(nChkTunnel);

            if Result then
            begin
              WriteNearReaderLog('ͨ��[ ' + nTunnel + ' ] ���ڷ���Ϊ: '+nTmp + ' �÷�����Ͻװ���� '+
                            nChkTunnel+' ������ҵ�����ܾ���������ҵ����' );
              Break;
            end;

            Next;
          end;
        end;
      finally
        gDBConnManager.ReleaseConnection(nWorker);
        //gDBConnManager.ReleaseConnection(nxWorker);
      end;
    end;
begin
  WriteNearReaderLog('ͨ��[ ' + nTunnel + ' ]: MakeTruckLadingDai����.');

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫջ̨�������.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
    if IsJSRun then Exit;
  end;

  {$IFDEF ChkZTMatch}
  if IsGroupJSRun then Exit;
  {$ENDIF}
  
  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //���ͨ��

  nStr := '';
  nInt := 0;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then Inc(nInt); //ˢ��ͨ����Ӧ�Ľ�����
      Continue;
    end;

    FSelected := False;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '��װ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '����[ %s ]ջ̨���ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);
  Exit;
end;

//Date: 2012-4-25
//Parm: ����;ͨ��
//Desc: ��ȨnTruck��nTunnel�����Ż�
procedure TruckStartFH(const nTruck: PTruckItem; const nTunnel: string);
var nStr,nTmp,nCardUse: string;
   nField: TField;
   nWorker: PDBWorker;
begin
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select * From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck.FTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nField := FindField('T_Card');
      if Assigned(nField) then nTmp := nField.AsString;

      nField := FindField('T_CardUse');
      if Assigned(nField) then nCardUse := nField.AsString;

      if nCardUse = sFlag_No then
        nTmp := '';
      //xxxxx
    end;

    g02NReader.SetRealELabel(nTunnel, nTmp);
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;


  gERelayManager.LineOpen(nTunnel);
  //�򿪷Ż�

  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nTruck.FValue);
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);
  //xxxxx

  WriteNearReaderLog('����ͨ�� '+nTunnel+' С������ʾ���ݣ� '+nStr);
  gERelayManager.ShowTxt(nTunnel, nStr);
  //��ʾ����
end;

//Date: 2019-03-12
//Parm: ����;ͨ��;Ƥ��
//Desc: ��ȨnTruck��nTunnel�����Ż�
procedure TruckStartFHEx(const nTruck: PTruckItem; const nTunnel: string;
 const nLading: TLadingBillItem);
var nStr: string;
begin
  gERelayManager.LineOpen(nTunnel);
  //��ʼ�Ż�

  nStr := Format('Truck=%s', [nTruck.FTruck]);
  gBasisWeightManager.StartWeight(nTunnel, nTruck.FBill, nTruck.FValue,
    nLading.FPData.FValue, nStr);
  //��ʼ����װ��

  if nLading.FStatus <> sFlag_TruckIn then
    gBasisWeightManager.SetParam(nTunnel, 'CanFH', sFlag_Yes);
  //��ӿɷŻұ��
end;

{$IFDEF ChkCardFHTime}      // ���Ż�ʱ���
//Date: 2018-4-25
//Parm: �������
//Desc: ��鿨Ƭ��Ч�Ż�ʱ��
function IsCardCanFH(nTHNo: string):Boolean;
var nStr, nTmp: string;
   nField: TField;
   nWorker: PDBWorker;
begin
  Result:= False;
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select *, DATEDIFF(MINUTE, T_InLadeFirst, GETDATE()) LadeTime From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nTHNo]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nField := FindField('LadeTime');

      if Assigned(nField) then
        if nField.AsInteger<9 then
        begin
          Result:= True;
        end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2018-4-25
//Parm: �������
//Desc: ��ǵ�һ��ˢ�� �Ż�ʱ��
procedure MarkCardFHTime(nTHNo: string);
var nStr : string;
   nField: TField;
   nWorker: PDBWorker;
begin
  nWorker := nil;
  try
    nStr := 'Select * From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nTHNo]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nField := FindField('T_InLadeFirst');

      if Assigned(nField) then
        if nField.AsString='1900-01-01' then
        begin
          nStr := 'UPDate %s Set T_InLadeFirst=GETDATE() Where T_Bill=''%s''';
          nStr := Format(nStr, [sTable_ZTTrucks, nTHNo]);
          gDBConnManager.ExecSQL(nStr);
        end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

{$ENDIF}

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingSan(const nCard,nTunnel: string);
var nStr: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan����.');
  {$ENDIF}

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ�Żҳ���.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //δװ����װ

    {$IFDEF AllowMultiM}
    if FStatus = sFlag_TruckBFM then
      FStatus := sFlag_TruckFH;
    //���غ��������ٴ�װ�� ����ι��أ�
    {$ENDIF}

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷��Ż�.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '�뻻��װ��';
    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //���ͨ��

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin                                                                         
    {$IFDEF ChkCardFHTime}      // ��⵱ǰ�����״ηŻ�ʱ���
    if not IsCardCanFH(nTrucks[0].FID) then
    begin
      gERelayManager.LineClose(nTunnel);

      nIdx := Length(nTrucks[0].FTruck);
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '��ƬʧЧ';
      gERelayManager.ShowTxt(nTunnel, nStr);
      WriteNearReaderLog(nStr);
      Exit;
    end;
    {$ENDIF}

    nStr := 'ɢװ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    TruckStartFH(nPTruck, nTunnel);
    
    {$IFDEF FixLoad}
    WriteNearReaderLog('��������װ��::'+nTunnel+'@'+nCard);
    //���Ϳ��ź�ͨ���ŵ�����װ��������
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    {$ENDIF}

    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '����[ %s ]�ŻҴ����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  {$IFDEF ChkCardFHTime}   // ����Ƿ��״ηŻ� �����������״ηŻ�ʱ��
    MarkCardFHTime(nTrucks[0].FID);
  {$ENDIF}

  TruckStartFH(nPTruck, nTunnel);
  //ִ�зŻ�
  {$IFDEF FixLoad}
  WriteNearReaderLog('��������װ��::'+nTunnel+'@'+nCard);
  //���Ϳ��ź�ͨ���ŵ�����װ��������
  gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
  {$ENDIF}
end;

//Date: 2019-03-12
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�г�������
procedure MakeTruckWeightFirst(const nCard,nTunnel: string;nVoiceID:string='');
var nStr: string;
    nIdx: Integer;
    nPound: TBWTunnel;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckWeightFirst����.');
  {$ENDIF}                                                 

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    ShowLEDHint(nTunnel, '��ȡ��������Ϣʧ��');
    MakeGateSound(nStr, nVoiceID, False);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫװ�ϳ���.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    ShowLEDHint(nTunnel, 'û����Ҫװ�ϳ���');
    MakeGateSound(nStr, nVoiceID, False);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FStatus = sFlag_TruckNone then
    begin
      ShowLEDHint(nTunnel, '�����ˢ��', nTrucks[0].FTruck);
      MakeGateSound(Format('%s �뵽������ˢ��', [nTrucks[0].FTruck]), nVoiceID, False);
      Exit;
    end;
  end;

  if gBasisWeightManager.IsTunnelBusy(nTunnel, @nPound) and
     (nPound.FBill <> nTrucks[0].FID) then //ͨ��æ
  begin
    if nPound.FValTunnel = 0 then //ǰ�����°�
    begin
      nStr := Format('%s ��ȴ�ǰ��', [nTrucks[0].FTruck]);
      ShowLEDHint(nTunnel, nStr);
      MakeGateSound(nStr, nVoiceID, False);
      Exit;
    end;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);

    nStr := Format('%s �뻻��װ��', [nTrucks[0].FTruck]);
    ShowLEDHint(nTunnel, '�뻻��װ��', nTrucks[0].FTruck);
    MakeGateSound(nStr, nVoiceID, False);
    Exit;
  end; //���ͨ��

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    nStr := '����[ %s ]ˢ��,�ȴ���Ƥ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    nStr := Format('�� %s �ϰ�����Ƥ��', [nTrucks[0].FTruck]);
    ShowLEDHint(nTunnel, nStr);
    MakeGateSound(nStr, nVoiceID, False);
  end else
  begin
    if nPound.FValTunnel > 0 then
         nStr := '�� %s �ϰ�װ��'
    else nStr := '�� %s ��ʼװ��';

    nStr := Format(nStr, [nTrucks[0].FTruck]);
    ShowLEDHint(nTunnel, nStr, nTrucks[0].FTruck);
    MakeGateSound(nStr, nVoiceID, False);
  end;

  TruckStartFHEx(nPTruck, nTunnel, nTrucks[0]);
  //ִ�зŻ�
end;

//Date: 2018-6-4
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�ж̵�װ������ ��������ʽ�������ϣ�
procedure MakeTruckLadingDuanDaoSan(const nCard,nTunnel: string);
var nStr: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  WriteNearReaderLog('����̵��Żҿ���');
  if not GetDuanDaoItems(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '[�̵�]  ��ȡ�ſ�[ %s ]�̵��ŻҶ�����Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '[�̵�]  �ſ�[ %s ]û����Ҫ�Żҳ���.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //δװ����װ

    nStr := '[�̵�]  ɢװ����[ %s ]��һ״̬Ϊ:[ %s ],�޷��Ż�.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '�뻻��װ��';
    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //���ͨ��

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := '[�̵�]  ɢװ����[ %s] �ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    TruckStartFH(nPTruck, nTunnel);
    Exit;
  end;

  if not SaveDuanDaoItems(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '[�̵�]  ����[ %s ]�ŻҴ����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  TruckStartFH(nPTruck, nTunnel);
  //ִ�зŻ�
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard�µ�������������
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
var nStr, nCardType: string;
begin
  if nHost.FType = rtOnce then
  begin
    if nHost.FFun = rfOut then
    begin
      if Assigned(nHost.FOptions) then
           nStr := nHost.FOptions.Values['HYPrinter']
      else nStr := '';
      MakeTruckOut(nCard, '', nHost.FPrinter, nStr);
    end else MakeTruckLadingDai(nCard, nHost.FTunnel);
  end else

  if nHost.FType = rtKeep then
  begin
    {$IFDEF DuanDaoCanFH}
      nCardType := '';
      if not GetCardUsed(nCard, nCardType) then
        MakeTruckLadingSan(nCard, nHost.FTunnel)
      else
      begin
        if nCardType = sFlag_DuanDao then
            MakeTruckLadingDuanDaoSan(nCard, nHost.FTunnel)
        else
            MakeTruckLadingSan(nCard, nHost.FTunnel);
      end;
    {$ELSE}
      //----------------------------
      {$IFDEF BasisWeightWithPM}
        if Assigned(nHost.FOptions) then
        begin
          if nHost.FOptions.Values['IsBasisWeight'] = sFlag_Yes then
          begin
            MakeTruckWeightFirst(nCard, nHost.FTunnel, nHost.FOptions.Values['VoiceCard']);

            gBasisWeightManager.SetParam(nHost.FTunnel, 'LEDText', nHost.FLEDText, True);
            //���Ӳ���
            Exit;
          end;
        end;

        MakeTruckLadingSan(nCard, nHost.FTunnel);
      {$ELSE}
      MakeTruckLadingSan(nCard, nHost.FTunnel);
      {$ENDIF}
    {$ENDIF}
  end;
end;


//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard��ʱ����������
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut�˳�.');
  {$ENDIF}

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);

  {$IFDEF FixLoad}
  WriteHardHelperLog('ֹͣ����װ��::'+nHost.FTunnel+'@Close');
  //���Ϳ��ź�ͨ���ŵ�����װ��������
  gSendCardNo.SendCardNo(nHost.FTunnel+'@Close');
  {$ENDIF}
  
  if nHost.FETimeOut then
       gERelayManager.ShowTxt(nHost.FTunnel, '���ӱ�ǩ������Χ')
  else gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
  Sleep(100);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: �ſ���
//Desc: ��nCardNo���Զ�����(ģ���ͷˢ��)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader: string;
begin
  if gTruckQueueManager.IsTruckAutoOut then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //ģ��ˢ��
  end;
end;

//Date: 2012-12-16
//Parm: ��������
//Desc: ����ҵ���м����Ӳ���ػ��Ľ�������
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('�յ�Bus_MITҵ������:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

//Date: 2015-01-14
//Parm: ���ƺ�;������
//Desc: ��ʽ��nBill��������Ҫ��ʾ�ĳ��ƺ�
function GetJSTruck(const nTruck,nBill: string): string;
var nStr: string;
    nLen: Integer;
    nWorker: PDBWorker;
begin
  Result := nTruck;
  if nBill = '' then Exit;

  {$IFDEF LNYK}
  nWorker := nil;
  try
    nStr := 'Select L_StockNo From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := UpperCase(Fields[0].AsString);
      if nStr <> 'BPC-02' then Exit;
      //ֻ����32.5(b)

      nLen := cMultiJS_Truck - 2;
      Result := 'B-' + Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;   
  {$ENDIF}
end;

//Date: 2013-07-17
//Parm: ������ͨ��
//Desc: ����nTunnel�������
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
var nStr: string;
    nDai: Word;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nDai := nTunnel.FHasDone - nTunnel.FLastSaveDai;
  if nDai <= 0 then Exit;
  //invalid dai num

  if nTunnel.FLastBill = '' then Exit;
  //invalid bill

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nTunnel.FLastBill;
    nList.Values['Dai'] := IntToStr(nDai);

    nStr := PackerEncodeStr(nList.Text);
    CallHardwareCommand(cBC_SaveCountData, nStr, '', @nOut)
  finally
    nList.Free;
  end;
end;

{$IFDEF HKVDVR}
procedure WhenCaptureFinished(const nPtr: Pointer);
var nStr: string;
    nDS: TDataSet;
    nPic: TPicture;
    nDBConn: PDBWorker;
    nErrNum, nRID: Integer;
    nCapture: PCameraFrameCapture;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenCaptureFinished����.');
  {$ENDIF}

  nCapture :=  PCameraFrameCapture(nPtr);
  if not FileExists(nCapture.FCaptureName) then Exit;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nDBConn.FConn.BeginTrans;
    try
      nStr := MakeSQLByStr([
              SF('P_ID', nCapture.FCaptureFix),
              //SF('P_Name', nCapture.FCaptureName),
              SF('P_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Picture, '', True);
      //xxxxx

      if gDBConnManager.WorkerExec(nDBConn, nStr) < 1 then Exit;

      nStr := 'Select Max(%s) From %s';
      nStr := Format(nStr, ['R_ID', sTable_Picture]);
      with gDBConnManager.WorkerQuery(nDBConn, nStr) do
        nRID := Fields[0].AsInteger;

      nStr := 'Select P_Picture From %s Where R_ID=%d';
      nStr := Format(nStr, [sTable_Picture, nRID]);
      nDS := gDBConnManager.WorkerQuery(nDBConn, nStr);

      nPic := nil;
      try
        nPic := TPicture.Create;
        nPic.LoadFromFile(nCapture.FCaptureName);

        SaveDBImage(nDS, 'P_Picture', nPic.Graphic);
        FreeAndNil(nPic);
      except
        if Assigned(nPic) then nPic.Free;
      end;

      DeleteFile(nCapture.FCaptureName);
      nDBConn.FConn.CommitTrans;
    except
      nDBConn.FConn.RollbackTrans;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;
{$ENDIF}

function VerifySnapTruck(const nTruck,nBill,nPos: string; var nResult: string): Boolean;
var nList: TStrings;
    nOut: TWorkerBusinessCommand;
    nID: string;
begin
  if nBill = '' then
    nID := nTruck + FormatDateTime('YYMMDD',Now)
  else
    nID := nBill;
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Truck'] := nTruck;
    nList.Values['Bill'] := nID;
    nList.Values['Pos'] := nPos;

    Result := CallBusinessCommand(cBC_VerifySnapTruck, nList.Text, '', @nOut);
    nResult := nOut.FData;
  finally
    nList.Free;
  end;
end;


end.
