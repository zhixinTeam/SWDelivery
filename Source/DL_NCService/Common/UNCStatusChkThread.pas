unit UNCStatusChkThread;

interface

uses
  Classes, SysUtils, UMITConst, UBusinessConst, USysDB, UMgrDBConn, ULibFun,
  USysLoger, UWorkerBussinessNC;

type
  TNCStatusChkThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

  end;

var
  gTNCStatusChker: TNCStatusChkThread = nil;

implementation


{ TNCStatusChkThread }

function DateTimeToMilliseconds(const ADateTime: TDateTime): Int64;
var
  LTimeStamp: TTimeStamp;
begin
  LTimeStamp := DateTimeToTimeStamp(ADateTime);
  Result := LTimeStamp.Date;
  Result := (Result * MSecsPerDay) + LTimeStamp.Time;
end;

function xMinutesBetween(const ANow, AThen: TDateTime): Int64;
begin
  Result := (DateTimeToMilliseconds(ANow) - DateTimeToMilliseconds(AThen))
    div (MSecsPerSec * SecsPerMin);
end;

function xSecsBetween(const ANow, AThen: TDateTime): Int64;
begin
  Result := (DateTimeToMilliseconds(ANow) - DateTimeToMilliseconds(AThen))
    div (MSecsPerSec);
end;

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TNCStatusChkThread, 'NC×´Ì¬¼à²â', nMsg);
end;

procedure TNCStatusChkThread.Execute;
var nStr : string;
    LastTime : TDateTime;
    nOut: TWorkerBusinessCommand;
begin
  LastTime:= Now;
  while not Terminated do
  try
    if xSecsBetween(Now, LastTime)>5 then
    begin          WriteLog('¼ì²âNC·þÎñ×´Ì¬');
      TBusWorkerBusinessNC.CallMe(cBC_NcStatusChk, '','',@nOut);
      LastTime:= Now;
    end;
  except on E:Exception do
    begin
      WriteLog(E.Message);
    end
  end;
end;

constructor TNCStatusChkThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := False;
end;

destructor TNCStatusChkThread.Destroy;
begin
  inherited;
end;



initialization
  gTNCStatusChker := nil;
finalization
  FreeAndNil(gTNCStatusChker);
end.



end.
 