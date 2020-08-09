{*******************************************************************************
  ����: 2018/11/16
  ����: NCҵ�����
*******************************************************************************}
unit UWorkerClientNC;

interface

uses
  Windows, SysUtils, Classes, UMgrChannel, UChannelChooser, UBusinessWorker,
  UBusinessConst, UBusinessPacker, ULibFun;

type
  TClient2NCWorker = class(TBusinessWorkerBase)
  protected
    FListA,FListB: TStrings;
    //�ַ��б�
    procedure WriteLog(const nEvent: string);
    //��¼��־
    function ErrDescription(const nCode,nDesc: string;
      const nInclude: TDynamicStrArray): string;
    //��������
    function MITWork(var nData: string): Boolean;
    //ִ��ҵ��
    function GetFixedServiceURL: string; virtual;
    //�̶���ַ
  public
    constructor Create; override;
    destructor destroy; override;
    //�����ͷ�
    function DoWork(const nIn, nOut: Pointer): Boolean; override;
    //ִ��ҵ��
  end;

  TClientBusinessNC = class(TClient2NCWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

function CallRemoteWorker(const nCLIWorkerName: string; const nData,nExt: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer;const nRemoteUL: string=''): Boolean;
//����Զ�̷������ 
implementation

uses
  UFormWait, Forms, USysLoger, UMITConst, MIT_Service_Intf;

//Date: 2014-09-15
//Parm: ����;����;����;����;���
//Desc: ���ص���ҵ�����
function CallRemoteWorker(const nCLIWorkerName: string; const nData,nExt: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer;const nRemoteUL: string=''): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FBase.FParam := nRemoteUL;

    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nWorker := gBusinessWorkerManager.LockWorker(nCLIWorkerName);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-11
//Parm: ��־����
//Desc: ��¼��־
procedure TClient2NCWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(ClassType, '�ͻ�ҵ�����', nEvent);
end;

constructor TClient2NCWorker.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TClient2NCWorker.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: ���;����
//Desc: ִ��ҵ�񲢶��쳣������
function TClient2NCWorker.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nParam: string;
    nArray: TDynamicStrArray;
begin
  with PBWDataBase(nIn)^,gSysParam do
  begin
    nParam := FParam;
    FPacker.InitData(nIn, True, False);

    with FFrom do
    begin
      FUser   := 'MIT';
      FIP     := FLocalIP;
      FMAC    := FLocalMAC;
      FTime   := Now;
      FKpLong := GetTickCount;
    end;
  end;

  nStr := FPacker.PackIn(nIn);
  Result := MITWork(nStr);

  if not Result then
  begin
    PWorkerBusinessCommand(nOut).FData := nStr;
    WriteLog(nStr);
    Exit;
  end;
end;

//Date: 2012-3-20
//Parm: ����;����
//Desc: ��ʽ����������
function TClient2NCWorker.ErrDescription(const nCode, nDesc: string;
  const nInclude: TDynamicStrArray): string;
var nIdx: Integer;
begin
  FListA.Text := StringReplace(nCode, #9, #13#10, [rfReplaceAll]);
  FListB.Text := StringReplace(nDesc, #9, #13#10, [rfReplaceAll]);

  if FListA.Count <> FListB.Count then
  begin
    Result := '��.����: ' + nCode + #13#10 +
              '   ����: ' + nDesc + #13#10#13#10;
  end else Result := '';

  for nIdx:=0 to FListA.Count - 1 do
  if (Length(nInclude) = 0) or (StrArrayIndex(FListA[nIdx], nInclude) > -1) then
  begin
    Result := Result + '��.����: ' + FListA[nIdx] + #13#10 +
                       '   ����: ' + FListB[nIdx] + #13#10#13#10;
  end;
end;

//Desc: ǿ��ָ�������ַ
function TClient2NCWorker.GetFixedServiceURL: string;
begin
  Result := '';
end;

//Date: 2012-3-9
//Parm: �������
//Desc: ����MITִ�о���ҵ��
function TClient2NCWorker.MITWork(var nData: string): Boolean;
var nChannel: PChannelItem;
begin
  Result := False;
  nChannel := nil;
  try
    nChannel := gChannelManager.LockChannel(cBus_Channel_Business);
    if not Assigned(nChannel) then
    begin
      nData := '����NC����ʧ��(BUS-NC No Channel).';
      Exit;
    end;

    with nChannel^ do
    while True do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvBusiness.Create(FMsg, FHttp);
      //xxxxx

      if GetFixedServiceURL = '' then
           FHttp.TargetURL := gChannelChoolser.ActiveURL
      else FHttp.TargetURL := GetFixedServiceURL;

      Result := ISrvBusiness(FChannel).Action(GetFlagStr(cWorker_GetMITName),
                                              nData);
      //call mit funciton
      Break;
    except
      on E :Exception do
      begin
        if (GetFixedServiceURL <> '') or
           (gChannelChoolser.GetChannelURL = FHttp.TargetURL) then
        begin
          nData := Format('%s(BY %s ).', [E.Message, gSysParam.FLocalName]);
          WriteLog('Function:[ ' + FunctionName + ' ' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    gChannelManager.ReleaseChannel(nChannel);
  end;
end;

//------------------------------------------------------------------------------
class function TClientBusinessNC.FunctionName: string;
begin
  Result := sCLI_BusinessNC;
end;

function TClientBusinessNC.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessNC;
  end;
end;

function TClientBusinessNC.GetFixedServiceURL: string;
var nStr:string;
begin
  Result := gSysParam.FNcURL;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TClientBusinessNC, sPlug_ModuleBus);
end.
