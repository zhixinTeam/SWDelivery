{*******************************************************************************
  ����: dmzn@163.com 2012-4-29
  ����: ��������
*******************************************************************************}
unit USysConst;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, UBusinessPacker, UBusinessWorker, UBusinessConst,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UClientWorker, UMITPacker, UWaitItem, ULibFun, USysDB, USysLoger;

type
  TSysParam = record
    FUserID     : string;                            //�û���ʶ
    FUserName   : string;                            //��ǰ�û�
    FUserPwd    : string;                            //�û�����
    FGroupID    : string;                            //������
    FIsAdmin    : Boolean;                           //�Ƿ����Ա
    FIsNormal   : Boolean;                           //�ʻ��Ƿ�����

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    FHardMonURL : string;                            //Ӳ���ػ�
    FWechatURL  : string;                            //΢��ҵ��

    FIsEncode   : Boolean;                           //�Ƿ���Ҫ��������
  end;
  //ϵͳ����

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //���
    FName     : string;      //����
    FStock    : string;      //Ʒ��
    FWeight   : Integer;     //����
    FValid    : Boolean;     //�Ƿ���Ч
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //���ƺ�
    FLine     : string;      //ͨ��
    FBill     : string;      //�����
    FValue    : Double;      //�����
    FDai      : Integer;     //����
    FTotal    : Integer;     //����
    FInFact   : Boolean;     //�Ƿ����
    FIsRun    : Boolean;     //�Ƿ�����    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

  TMITReader = class(TThread)
  private
    FList: TStrings;
    FWaiter: TWaitObject;
    //�ȴ�����
    FTunnel: TMultiJSTunnel;
    FOnData: TMultiJSEvent;
  protected
    procedure DoSync;
    procedure Execute; override;
  public
    constructor Create(AEvent: TMultiJSEvent);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gMITReader: TMITReader = nil;                      //�м����ȡ

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//��ȡ��������
function RemoteExecuteSQL(const nSQL: string): Boolean;
//Զ��д���ݿ�
function SaveTruckCountData(const nBill: string; nDaiNum: Integer): Boolean;
//���潻�����������
function StartJS(const nTunnel,nTruck,nBill: string; nDai: Integer): Boolean;
function PauseJS(const nTunnel: string): Boolean;
function StopJS(const nTunnel: string): Boolean;
//���������ҵ��
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
//�������������������

//------------------------------------------------------------------------------
resourceString
  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = 'δ֪����';                  //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������
  sFormConfig         = 'FormInfo.ini';              //��������
  sPConfigFile        = 'PConfig.Ini';               //�����ؿ���

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

implementation

constructor TMITReader.Create(AEvent: TMultiJSEvent);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOnData := AEvent;
  FList := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2 * 1000;
end;

destructor TMITReader.Destroy;
begin
  FWaiter.Free;
  FList.Free;  
  inherited;
end;

procedure TMITReader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMITReader.Execute;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    nWorker := nil;
    try
      nIn.FCommand := cBC_JSGetStatus;
      nIn.FBase.FParam := sParam_NoHintOnError;
      
      nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
      if not nWorker.WorkActive(@nIn, @nOut) then Continue;

      FList.Text := nOut.FData;
      if Assigned(FOnData) then
        Synchronize(DoSync);
      //xxxxx
    finally
      gBusinessWorkerManager.RelaseWorker(nWorker);
    end;
  except
    on E:Exception do
    begin
      gSysLoger.AddLog(E.Message);
    end;
  end;
end;

procedure TMITReader.DoSync;
var nIdx: Integer;
begin
  for nIdx:=0 to FList.Count - 1 do
  begin
    FTunnel.FID := FList.Names[nIdx];
    if not IsNumber(FList.Values[FTunnel.FID], False) then Continue;

    FTunnel.FHasDone := StrToInt(FList.Values[FTunnel.FID]);
    FOnData(@FTunnel);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-25
//Parm: ͨ��;����
//Desc: ��ȡ������������
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings; 
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nIn.FData := sFlag_Yes
    else nIn.FData := sFlag_No;

    nIn.FCommand := cBC_GetQueueData;
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);

    Result := nWorker.WorkActive(@nIn, @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-4-27
//Parm: SQL���
//Desc: Զ��ִ��nSQL
function RemoteExecuteSQL(const nSQL: string): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := cBC_RemoteExecSQL;
    nIn.FData := PackerEncodeStr(nSQL);

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-4-30
//Parm: ������;����
//Desc: ����nBill�ļ������
function SaveTruckCountData(const nBill: string; nDaiNum: Integer): Boolean;
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nList := nil;
  nWorker := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nBill;
    nList.Values['Dai'] := IntToStr(nDaiNum);

    nIn.FCommand := cBC_SaveCountData;
    nIn.FBase.FParam := sParam_NoHintOnError;
    nIn.FData := PackerEncodeStr(nList.Text);

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nList.Free;
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2013-07-21
//Parm: ͨ��;����;������;����
//Desc: ����һ���µļ���
function StartJS(const nTunnel,nTruck,nBill: string; nDai: Integer): Boolean;
var nList: TStrings;
    nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nList := nil;
  nWorker := nil;
  try
    nList := TStringList.Create;
    with nList do
    begin
      Values['Tunnel'] := nTunnel;
      Values['Truck']  := nTruck;
      Values['Bill']   := nBill;
      Values['DaiNum']    := IntToStr(nDai);
    end;

    nIn.FCommand := cBC_JSStart;
    nIn.FBase.FParam := sParam_NoHintOnError;
    nIn.FData := nList.Text;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    nList.Free;
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2013-07-17
//Parm: ͨ����
//Desc: ��ͣnTunnel����
function PauseJS(const nTunnel: string): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := cBC_JSPause;
    nIn.FData := nTunnel;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2013-07-17
//Parm: ͨ����
//Desc: ֹͣnTunnel����
function StopJS(const nTunnel: string): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := cBC_JSStop;
    nIn.FData := nTunnel;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-9-14
//Parm: ͨ����;������;��ʾ
//Desc: ��nTunnel����������ʹ�ӡnBill����
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nIn: TWorkerBusinessCommand;
    nOut: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    with nIn do
    begin
      FCommand := cBC_PrintCode;
      FData := nBill;
      FExtParam := nTunnel;
      FBase.FParam := sParam_NoHintOnError;
    end;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    Result := nWorker.WorkActive(@nIn, @nOut);

    if not Result then
      nHint := nOut.FBase.FErrDesc;
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

end.
