unit MIT_Service_Invk;

{----------------------------------------------------------------------------}
{ This unit was automatically generated by the RemObjects SDK after reading  }
{ the RODL file associated with this project .                               }
{                                                                            }
{ Do not modify this unit manually, or your changes will be lost when this   }
{ unit is regenerated the next time you compile the project.                 }
{----------------------------------------------------------------------------}

{$I RemObjects.inc}

interface

uses
  {vcl:} Classes,
  {RemObjects:} uROXMLIntf, uROServer, uROServerIntf, uROTypes, uROClientIntf,
  {Generated:} MIT_Service_Intf;

type
  TSrvConnection_Invoker = class(TROInvoker)
  private
  protected
  public
    constructor Create; override;
  published
    procedure Invoke_Action(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
  end;

  TSrvBusiness_Invoker = class(TROInvoker)
  private
  protected
  public
    constructor Create; override;
  published
    procedure Invoke_Action(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
  end;

  TSrvNC_Invoker = class(TROInvoker)
  private
  protected
  public
    constructor Create; override;
  published
    procedure Invoke_Action(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
  end;

implementation

uses
  {RemObjects:} uRORes, uROClient;

{ TSrvConnection_Invoker }

constructor TSrvConnection_Invoker.Create;
begin
  inherited Create;
  FAbstract := False;
end;

procedure TSrvConnection_Invoker.Invoke_Action(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
{ function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean; }
var
  nFunName: AnsiString;
  nData: AnsiString;
  lResult: Boolean;
begin
  try
    __Message.Read('nFunName', TypeInfo(AnsiString), nFunName, []);
    __Message.Read('nData', TypeInfo(AnsiString), nData, []);

    lResult := (__Instance as ISrvConnection).Action(nFunName, nData);

    __Message.InitializeResponseMessage(__Transport, 'MIT_Service', 'SrvConnection', 'ActionResponse');
    __Message.Write('Result', TypeInfo(Boolean), lResult, []);
    __Message.Write('nData', TypeInfo(AnsiString), nData, []);
    __Message.Finalize;
    __Message.UnsetAttributes(__Transport);

  finally
  end;
end;

{ TSrvBusiness_Invoker }

constructor TSrvBusiness_Invoker.Create;
begin
  inherited Create;
  FAbstract := False;
end;

procedure TSrvBusiness_Invoker.Invoke_Action(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
{ function Action(const nFunName: AnsiString; var nData: AnsiString): Boolean; }
var
  nFunName: AnsiString;
  nData: AnsiString;
  lResult: Boolean;
begin
  try
    __Message.Read('nFunName', TypeInfo(AnsiString), nFunName, []);
    __Message.Read('nData', TypeInfo(AnsiString), nData, []);

    lResult := (__Instance as ISrvBusiness).Action(nFunName, nData);

    __Message.InitializeResponseMessage(__Transport, 'MIT_Service', 'SrvBusiness', 'ActionResponse');
    __Message.Write('Result', TypeInfo(Boolean), lResult, []);
    __Message.Write('nData', TypeInfo(AnsiString), nData, []);
    __Message.Finalize;
    __Message.UnsetAttributes(__Transport);

  finally
  end;
end;

{ TSrvNC_Invoker }

constructor TSrvNC_Invoker.Create;
begin
  inherited Create;
  FAbstract := False;
end;

procedure TSrvNC_Invoker.Invoke_Action(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
{ procedure Action(const nFunName: Widestring; var nData: Widestring); }
var
  nFunName: Widestring;
  nData: Widestring;
begin
  try
    __Message.Read('nFunName', TypeInfo(Widestring), nFunName, []);
    __Message.Read('nData', TypeInfo(Widestring), nData, []);

    (__Instance as ISrvNC).Action(nFunName, nData);

    __Message.InitializeResponseMessage(__Transport, 'MIT_Service', 'SrvNC', 'ActionResponse');
    __Message.Write('nData', TypeInfo(Widestring), nData, []);
    __Message.Finalize;
    __Message.UnsetAttributes(__Transport);

  finally
  end;
end;

initialization
end.
