unit SrvNC_Impl;

{----------------------------------------------------------------------------}
{ This unit was automatically generated by the RemObjects SDK after reading  }
{ the RODL file associated with this project .                               }
{                                                                            }
{ This is where you are supposed to code the implementation of your objects. }
{----------------------------------------------------------------------------}

{$I RemObjects.inc}

interface

uses
  Classes, SysUtils, uROServer, MIT_Service_Intf;

type
  { TSrvNC }
  TSrvNC = class(TRORemotable, ISrvNC)
  private
    FEvent: string;
    FTaskID: Int64;
    procedure WriteLog(const nLog: string);
  protected
    { ISrvNC methods }
    function Action(const nFunName: Widestring; var nData: Widestring): Boolean;
  end;

implementation

uses
  UROModule, UBusinessWorker, UTaskMonitor, USysLoger, UMITConst;


procedure TSrvNC.WriteLog(const nLog: string);
begin
  gSysLoger.AddLog(TSrvNC, 'Webƽ̨�������', nLog);
end;

//Date: 2012-3-7
//Parm: ������;[in]����,[out]�������
//Desc: ִ����nDataΪ������nFunName����
function TSrvNC.Action(const nFunName: Widestring; var nData: Widestring): Boolean;
var nWorker: TBusinessWorkerBase;
    nStrx:string;
begin
  FEvent := Format('TSrvNC.Action( %s )', ['Bus_BusinessNC']);
  FTaskID := gTaskMonitor.AddTask(FEvent, 10 * 1000);
  //new task

  nWorker := nil;   nStrx:= '';
  try
    Result:= ((nFunName='BD0001') or (nFunName='BD0002') or (nFunName='BD0003') or
      (nFunName='BD0004') or (nFunName='BD0005') or (nFunName='BD0006') or (nFunName='BD0007'));

    if Pos('"'+nFunName+'"', nData)=0 then
    begin
      nData:= '<?xml version="1.0" encoding="utf-8"?>' +
              '<Info><DataRow><Pk>null</Pk><Message>ָ����XML billtype��Ҫһ�¡������������</Message>'+


    end;

    if Result then
    begin
      nWorker := gBusinessWorkerManager.LockWorker('Bus_BusinessNC');
      try
        if nWorker.FunctionName = '' then
        begin
          nStrx := '����ʧ��(Worker Is Null).';
          Result := False;
          Exit;
        end;
        nStrx:= nData;
        Result := nWorker.WorkActive(nStrx);
        //do action
        nData:= nStrx;

        with ROModule.LockModuleStatus^ do
        try
          FNumWebChat := FNumWebChat + 1;
        finally
          ROModule.ReleaseStatusLock;
        end;
      except
        on E:Exception do
        begin
          Result := False;
          nData := E.Message;
          WriteLog('Function:[ ServiceForNC ]' + E.Message);

          with ROModule.LockModuleStatus^ do
          try
            FNumActionError := FNumActionError + 1;
          finally
            ROModule.ReleaseStatusLock;
          end;
        end;
      end;
    end;

    if (not Result) and (Pos(#10#13, nData) < 1) then
    begin
      nData := Format('[ ServiceForNC ]: %s', [nData]);
      //xxxxx
    end;
  finally
    gTaskMonitor.DelTask(FTaskID);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

end.