{*******************************************************************************
  作者: dmzn@163.com 2018-05-03
  描述: 客户端业务处理工作对象
*******************************************************************************}
unit UClientWorker;

interface

uses
  Windows, SysUtils, Classes, UMgrChannel, UBusinessConst, UBusinessPacker,
  UClientPacker, UManagerGroup, ULibFun;

type
  TClient2MITWorker = class(TObject)
  protected
    function GetPacker: TBusinessPackerBase; virtual;
    function GetRemoteWorker: string; virtual; abstract;
    function GetFixedServiceURL: string; virtual; abstract;
    //子类方法
    function ErrDescription(const nCode,nDesc: string;
      const nInclude: TStringHelper.TStringArray): string;
    //错误描述
    function MITWork(var nData: string): Boolean;
    //执行业务
  public
    function WorkActive(const nIn, nOut: Pointer): Boolean;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TClientWorkerQueryField = class(TClient2MITWorker)
  public
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessCommand = class(TClient2MITWorker)
  public
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessSaleBill = class(TClient2MITWorker)
  public
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessPurchaseOrder = class(TClient2MITWorker)
  public
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessHardware = class(TClient2MITWorker)
  public
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessWechat = class(TClient2MITWorker)
  public
    function GetPacker: TBusinessPackerBase; override;
    function GetRemoteWorker: string; override;
    function GetFixedServiceURL: string; override;
  end;

implementation

uses
  uniGUImForm, uniGUIApplication, MainModule, MIT_Service_Intf, USysDB,
  USysBusiness, USysConst;

procedure TClient2MITWorker.WriteLog(const nEvent: string);
begin
  UniApplication.UniSession.Log(nEvent);
end;

//Date: 2018-05-03
//Desc: 默认封包器
function TClient2MITWorker.GetPacker: TBusinessPackerBase;
begin
  Result := gMG.FObjectPool.Lock(TMITBusinessCommand) as TBusinessPackerBase;
end;

//Date: 2018-05-03
//Parm: 入参;出参
//Desc: 执行业务并对异常做处理
function TClient2MITWorker.WorkActive(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nParam: string;
    nWorkTimeInit: Int64;
    nPack: TBusinessPackerBase;
    nArray: TStringHelper.TStringArray;
begin
  nPack := nil;
  try
    nPack := GetPacker();
    //get packer

    with PBWDataBase(nIn)^ do
    begin
      nParam := FParam;
      nPack.InitData(nIn, True, False);

      with FFrom,UniMainModule.FUserConfig do
      begin
        FUser   := FUserID;
        FIP     := FLocalIP;
        FMAC    := FLocalMAC;

        FTime   := Now();
        FKpLong := GetTickCount;
        nWorkTimeInit := FKpLong;
      end;
    end;

    nStr := nPack.PackIn(nIn);
    Result := MITWork(nStr);

    if not Result then
    begin
      if Pos(sParam_NoHintOnError, nParam) < 1 then
      begin
        UniMainModule.FMainForm.ShowMessage(nStr);
        //show dialog
      end else PBWDataBase(nOut)^.FErrDesc := nStr;
    
      Exit;
    end;

    nPack.UnPackOut(nStr, nOut);
    with PBWDataBase(nOut)^,UniMainModule.FUserConfig do
    begin
      nStr := 'User:[ %s ] FUN:[ %s ] TO:[ %s ] KP:[ %d ]';
      nStr := Format(nStr, [FUserID, ClassName(), FVia.FIP,
              GetTickCount - nWorkTimeInit]);
      WriteLog(nStr);

      Result := FResult;
      if Result then
      begin
        if FErrCode = sFlag_ForceHint then
        begin
          nStr := '业务执行成功,提示信息如下: ' + #13#10#13#10 + FErrDesc;
          UniMainModule.FMainForm.ShowMessage(nStr);
        end;

        Exit;
      end;

      if Pos(sParam_NoHintOnError, nParam) < 1 then
      begin
        SetLength(nArray, 0);

        nStr := '业务执行异常,描述如下: ' + #13#10#13#10 +

                ErrDescription(FErrCode, FErrDesc, nArray) +

                '请检查输入参数、操作是否有效,或联系管理员!' + #32#32#32;
        UniMainModule.FMainForm.ShowMessage(nStr);
      end;
    end;
  finally
    gMG.FObjectPool.Release(nPack);
  end;
end;

//Date: 2018-05-03
//Parm: 代码;描述
//Desc: 格式化错误描述
function TClient2MITWorker.ErrDescription(const nCode, nDesc: string;
  const nInclude: TStringHelper.TStringArray): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := nil;
  nListB := nil;
  try
    nListA := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nListB := gMG.FObjectPool.Lock(TStrings) as TStrings;
    //lock object

    nListA.Text := StringReplace(nCode, #9, #13#10, [rfReplaceAll]);
    nListB.Text := StringReplace(nDesc, #9, #13#10, [rfReplaceAll]);

    if nListA.Count <> nListB.Count then
    begin
      Result := '※.代码: ' + nCode + #13#10 +
                '   描述: ' + nDesc + #13#10#13#10;
    end else Result := '';

    for nIdx:=0 to nListA.Count - 1 do
    if (Length(nInclude) = 0) or
       (TStringHelper.StrArrayIndex(nListA[nIdx], nInclude) > -1) then
    begin
      Result := Result + '※.代码: ' + nListA[nIdx] + #13#10 +
                         '   描述: ' + nListB[nIdx] + #13#10#13#10;
    end;
  finally
    gMG.FObjectPool.Release(nListA);
    gMG.FObjectPool.Release(nListB);
  end;
end;

//Date: 2018-05-03
//Parm: 入参数据
//Desc: 连接MIT执行具体业务
function TClient2MITWorker.MITWork(var nData: string): Boolean;
var nBuffer: AnsiString;
    nChannel: PChannelItem;
begin
  Result := False;
  nChannel := nil;
  try
    nChannel := gMG.FChannelManager.LockChannel(cBus_Channel_Business);
    if not Assigned(nChannel) then
    begin
      nData := '连接MIT服务失败(BUS-MIT No Channel).';
      Exit;
    end;

    with nChannel^ do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvBusiness.Create(FMsg, FHttp);
      FHttp.TargetURL := GetFixedServiceURL;

      nBuffer := AnsiString(nData);
      Result := ISrvBusiness(FChannel).Action(AnsiString(GetRemoteWorker), nBuffer);
      nData := string(nBuffer);
      //call mit funciton
    except
      on nErr:Exception do
      begin
        nData := Format('%s(BY %s ).', [nErr.Message, gSysParam.FAppTitle]);
        WriteLog('Function:[ ' + ClassName() + ' ]' + nErr.Message);
      end;
    end;
  finally
    gMG.FChannelManager.ReleaseChannel(nChannel);
  end;
end;

//------------------------------------------------------------------------------
function TClientWorkerQueryField.GetRemoteWorker: string;
begin
  Result := sBus_GetQueryField;
end;

function TClientWorkerQueryField.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FMITServURL;
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
function TClientBusinessCommand.GetRemoteWorker: string;
begin
  Result := sBus_BusinessCommand;
end;

function TClientBusinessCommand.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FMITServURL;
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
function TClientBusinessSaleBill.GetRemoteWorker: string;
begin
  Result := sBus_BusinessSaleBill;
end;

function TClientBusinessSaleBill.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FMITServURL;
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
function TClientBusinessPurchaseOrder.GetRemoteWorker: string;
begin
  Result := sBus_BusinessPurchaseOrder;
end;

function TClientBusinessPurchaseOrder.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FMITServURL;
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
function TClientBusinessHardware.GetRemoteWorker: string;
begin
  Result := sBus_HardwareCommand;
end;

function TClientBusinessHardware.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FHardMonURL;
  finally
    GlobalSyncRelease;
  end;
end;

//------------------------------------------------------------------------------
function TClientBusinessWechat.GetPacker: TBusinessPackerBase;
begin
  Result := gMG.FObjectPool.Lock(TMITBusinessWebChat) as TBusinessPackerBase;
end;

function TClientBusinessWechat.GetRemoteWorker: string;
begin
  Result := sBus_BusinessWebchat;
end;

function TClientBusinessWechat.GetFixedServiceURL: string;
begin
  GlobalSyncLock;
  try
    Result := gAllFactorys[UniMainModule.FUserConfig.FFactory].FWechatURL;
  finally
    GlobalSyncRelease;
  end;
end;

initialization
  with gMG.FObjectPool do
  begin
    NewClass(TClientBusinessCommand,
      function(var nData: Pointer): TObject
      begin
        Result := TClientBusinessCommand.Create;
      end);
    //xxxxx

    NewClass(TClientBusinessSaleBill,
      function(var nData: Pointer): TObject
      begin
        Result := TClientBusinessSaleBill.Create;
      end);
    //xxxxx

    NewClass(TClientBusinessPurchaseOrder,
      function(var nData: Pointer): TObject
      begin
        Result := TClientBusinessPurchaseOrder.Create;
      end);
    //xxxxx

    NewClass(TClientBusinessHardware,
      function(var nData: Pointer): TObject
      begin
        Result := TClientBusinessHardware.Create;
      end);
    //xxxxx

    NewClass(TClientBusinessWechat,
      function(var nData: Pointer): TObject
      begin
        Result := TClientBusinessWechat.Create;
      end);
    //xxxxx
  end;
end.
