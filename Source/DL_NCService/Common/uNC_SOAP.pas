// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://61.185.114.170:65/uapws/service/uapbd?wsdl
// Encoding : UTF-8
// Version  : 1.0
// (2018-11-21 15:14:16 - 1.33.2.5)
// ************************************************************************ //

unit uNC_SOAP;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"
  // !:BusinessException - "http://pub.vo.nc/BusinessException"



  // ************************************************************************ //
  // Namespace : http://service.ncitf.itf.nc/IDataReceive
  // soapAction: urn:receiveData
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : IDataReceiveSOAP11Binding
  // service   : IDataReceive
  // port      : IDataReceiveSOAP11port_http
  // URL       : http://61.185.114.170:65/uapws/service/uapbd
  // ************************************************************************ //
  IDataReceivePortType = interface(IInvokable)
  ['{0BF75C5A-D31D-C0C6-3FF8-6C9FA7DE3980}']
    function  receiveData(const string_: WideString; const string1: WideString; const string2: WideString): WideString; stdcall;
  end;

function GetIDataReceivePortType(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IDataReceivePortType;


implementation

function GetIDataReceivePortType(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IDataReceivePortType;
const
  defWSDL = 'http://61.185.114.170:65/uapws/service/uapbd?wsdl';
  defURL  = 'http://61.185.114.170:65/uapws/service/uapbd';
  defSvc  = 'IDataReceive';
  defPrt  = 'IDataReceiveSOAP11port_http';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IDataReceivePortType);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  InvRegistry.RegisterInterface(TypeInfo(IDataReceivePortType), 'http://service.ncitf.itf.nc/IDataReceive', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IDataReceivePortType), 'urn:receiveData');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IDataReceivePortType), ioDefault);
  InvRegistry.RegisterExternalParamName(TypeInfo(IDataReceivePortType), 'receiveData', 'string_', 'string');

end.