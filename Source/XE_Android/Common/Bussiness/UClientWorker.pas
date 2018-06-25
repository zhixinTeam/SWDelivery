{*******************************************************************************
  ����: dmzn@163.com 2011-10-22
  ����: �ͻ���ҵ����������
*******************************************************************************}
unit UClientWorker;

interface

uses
  SysUtils, Classes, UBusinessWorker, UBusinessConst, UBusinessPacker,
  FMX.Dialogs, System.Types, System.UITypes, Soap;

const
  sFlag_ForceHint  = 'Bus_HintMsg';               //ǿ����ʾ

type
  TDynamicStrArray = array of string;
  //�ַ�������

  TClient2MITWorker = class(TBusinessWorkerBase)
  protected
    FListA,FListB: TStrings;
    //�ַ��б�
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

  TClientWorkerQueryField = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TClientBusinessCommand = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessSaleBill = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TClientBusinessPurchaseOrder = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

  TClientBusinessHardware = class(TClient2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL: string; override;
  end;

implementation
uses FMX.PlatForm.Android,FMX.Forms;

     //Date: 2010-3-5
//Parm: �ַ���;����;���Դ�Сд
//Desc: ����nStr��nArray�е�����λ��
function StrArrayIndex(const nStr: string; const nArray: TDynamicStrArray;
  const nIgnoreCase: Boolean = True): integer;
var nIdx: integer;
    nRes: Boolean;
begin
  Result := -1;
  for nIdx:=Low(nArray) to High(nArray) do
  begin
    if nIgnoreCase then
         nRes := CompareText(nStr, nArray[nIdx]) = 0
    else nRes := nStr = nArray[nIdx];

    if nRes then
    begin
      Result := nIdx; Exit;
    end;
  end;
end;

constructor TClient2MITWorker.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TClient2MITWorker.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: ���;����
//Desc: ִ��ҵ�񲢶��쳣������
function TClient2MITWorker.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nParam: string;
    nArray: TDynamicStrArray;
begin
  with PBWDataBase(nIn)^ do
  begin
    nParam := FParam;
    FPacker.InitData(nIn, True, False);

    with FFrom, gSysParam do
    begin
      FUser   := FOperator;
      FIP     := FHostIP;
      FMAC    := FHostMAC;
      FTime   := Now;
      FKpLong := 0;
    end;
  end;

  nStr := FPacker.PackIn(nIn);
  Result := MITWork(nStr);

  if not Result then
  begin
    if Pos(sParam_NoHintOnError, nParam) < 1 then
    begin
      ShowMessage(nStr);
    end else PBWDataBase(nOut)^.FErrDesc := nStr;
    
    Exit;
  end;
  
  FPacker.UnPackOut(nStr, nOut);
  with PBWDataBase(nOut)^ do
  begin
    nStr := 'User:[ %s ] FUN:[ %s ] TO:[ %s ] KP:[ %d ]';
    nStr := Format(nStr, ['', FunctionName, FVia.FIP,
             0]);

    Result := FResult;
    if Result then
    begin
      if FErrCode = sFlag_ForceHint then
      begin
        nStr := 'ҵ��ִ�гɹ�,��ʾ��Ϣ����: ' + #13#10#13#10 + FErrDesc;
        ShowMessage(nStr);
      end;

      Exit;
    end;

    if Pos(sParam_NoHintOnError, nParam) < 1 then
    begin
      SetLength(nArray, 0);

      nStr := 'ҵ��ִ���쳣,��������: ' + #13#10#13#10 +

              ErrDescription(FErrCode, FErrDesc, nArray) +

              '������������������Ƿ���Ч,����ϵ����Ա!' + #32#32#32;
      ShowMessage(nStr);
    end;
  end;
end;

//Date: 2012-3-20
//Parm: ����;����
//Desc: ��ʽ����������
function TClient2MITWorker.ErrDescription(const nCode, nDesc: string;
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
function TClient2MITWorker.GetFixedServiceURL: string;
begin
  Result := '';
end;

//Date: 2012-3-9
//Parm: �������
//Desc: ����MITִ�о���ҵ��
function TClient2MITWorker.MITWork(var nData: string): Boolean;
var nSvr: SrvBusiness;
    nStr: string;
    FAction: SrvBusiness___Action;
    FActionResponse:SrvBusiness___ActionResponse;
begin
  Result := False;

  nStr := GetFixedServiceURL;
  nSvr := GetSrvBusiness(True, nStr, nil);
  if not Assigned(nSvr) then ShowMessage( '��ȡ��ַʧ��');

  FAction := SrvBusiness___Action.Create;
  try
    FAction.nData    := nData;
    FAction.nFunName := GetFlagStr(cWorker_GetMITName);

    FActionResponse := nSvr.Action(FAction);

    Result := FActionResponse.Result;
    nData  := FActionResponse.nData;
  finally
    FreeAndNil(FAction);
    FreeAndNil(FActionResponse);
  end;
end;

//------------------------------------------------------------------------------
class function TClientWorkerQueryField.FunctionName: string;
begin
  Result := sCLI_GetQueryField;
end;

function TClientWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
   cWorker_GetMITName    : Result := sBus_GetQueryField;
  end;
end;

//------------------------------------------------------------------------------
class function TClientBusinessCommand.FunctionName: string;
begin
  Result := sCLI_BusinessCommand;
end;

function TClientBusinessCommand.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessCommand;
  end;
end;

function TClientBusinessCommand.GetFixedServiceURL: string;
var nStrURL: string;
begin
  nStrURL := 'http://%s:%d/Soap?service=SrvBusiness';
  Result  := Format(nStrURL, [gSysParam.FServIP, gSysParam.FServPort]);
end;

//------------------------------------------------------------------------------
class function TClientBusinessSaleBill.FunctionName: string;
begin
  Result := sCLI_BusinessSaleBill;
end;

function TClientBusinessSaleBill.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessSaleBill;
  end;
end;

//------------------------------------------------------------------------------
class function TClientBusinessPurchaseOrder.FunctionName: string;
begin
  Result := sCLI_BusinessPurchaseOrder;
end;

function TClientBusinessPurchaseOrder.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessPurchaseOrder;
  end;
end;

function TClientBusinessPurchaseOrder.GetFixedServiceURL: string;
var nStrURL: string;
begin
  nStrURL := 'http://%s:%d/Soap?service=SrvBusiness';
  Result  := Format(nStrURL, [gSysParam.FServIP, gSysParam.FServPort]);
end;

//------------------------------------------------------------------------------
class function TClientBusinessHardware.FunctionName: string;
begin
  Result := sCLI_HardwareCommand;
end;

function TClientBusinessHardware.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_HardwareCommand;
  end;
end;

function TClientBusinessHardware.GetFixedServiceURL: string;
begin
  Result := '';
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TClientWorkerQueryField);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessCommand);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessSaleBill);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessHardware);
  gBusinessWorkerManager.RegisteWorker(TClientBusinessPurchaseOrder);
end.
