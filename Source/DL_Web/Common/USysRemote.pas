{*******************************************************************************
  ����: dmzn@163.com 2018-05-03
  ����: Զ��ҵ�����
*******************************************************************************}
unit USysRemote;

{$I Link.Inc}
interface

uses
  Windows, Classes, System.SysUtils, UClientWorker, UBusinessConst,
  UBusinessPacker, UManagerGroup, USysDB, USysConst;

function GetSerialNo(const nGroup,nObject: string;
 const nUseDate: Boolean = True): string;
//��ȡ���б��
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean = True;
 const nCredit: PDouble = nil): Double;
//�ͻ����ý��
function edit_shopclients(const nData: string): string;
//�����̳��û�
function getWXCustomerList(const nData: string): string;
//��ȡ�̳�ע���û��б�

implementation

//Date: 2018-05-03
//Parm: ����;����;����;���
//Desc: �����м���ϵ�ҵ���������
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TClient2MITWorker;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gMG.FObjectPool.Lock(TClientBusinessCommand) as TClient2MITWorker;
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      nWorker.WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nWorker);
  end;
end;

//Date: 2018-05-03
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TClient2MITWorker;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gMG.FObjectPool.Lock(TClientBusinessSaleBill) as TClient2MITWorker;
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      nWorker.WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nWorker);
  end;
end;

//Date: 2018-05-03
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessPurchaseOrder(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TClient2MITWorker;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gMG.FObjectPool.Lock(TClientBusinessPurchaseOrder) as TClient2MITWorker;
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      nWorker.WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nWorker);
  end;
end;

//Date: 2018-05-03
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TClient2MITWorker;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gMG.FObjectPool.Lock(TClientBusinessHardware) as TClient2MITWorker;
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      nWorker.WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nWorker);
  end;
end;


//Date: 2018-05-03
//Parm: ����;����;����;�����ַ;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessWechat(const nCmd: Integer; const nData,nExt,nSrvURL: string;
  const nOut: PWorkerWebChatData; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerWebChatData;
    nWorker: TClient2MITWorker;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FRemoteUL := nSrvURL;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gMG.FObjectPool.Lock(TClientBusinessWechat) as TClient2MITWorker;
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      nWorker.WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gMG.FObjectPool.Release(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-05-03
//Parm: ����;����;ʹ�����ڱ���ģʽ
//Desc: ����nGroup.nObject���ɴ��б��
function GetSerialNo(const nGroup,nObject: string;
 const nUseDate: Boolean): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nList.Values['Group'] := nGroup;
    nList.Values['Object'] := nObject;

    if nUseDate then
         nStr := sFlag_Yes
    else nStr := sFlag_No;

    if CallBusinessCommand(cBC_GetSerialNO, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

//Date: 2018-05-07
//Parm: �ͻ����;��������;���ý��
//Desc: ��ȡnCID�û��Ŀ��ý��,�������ö�򾻶�
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean;
 const nCredit: PDouble): Double;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nLimit then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  if CallBusinessCommand(cBC_GetCustomerMoney, nCID, nStr, @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    if Assigned(nCredit) then
      nCredit^ := StrToFloat(nOut.FExtParam);
    //xxxxx
  end else
  begin
    Result := 0;
    if Assigned(nCredit) then
      nCredit^ := 0;
    //xxxxx
  end;
end;

//Date: 2018-05-25
//Parm: �˻�����
//Desc: �����̳��û�
function edit_shopclients(const nData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  {$IFDEF Debug}
//  Result := sFlag_Yes;
//  Exit;
  {$ENDIF}

  if CallBusinessWechat(cBC_WX_edit_shopclients, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2018-05-27
//Parm: ����
//Desc: ��ȡ�̳�ע���˻��б�
function getWXCustomerList(const nData: string): string;
var nOut: TWorkerBusinessCommand;
{$IFDEF DEBUG}nList: TStrings;{$ENDIF}
begin
  {$IFDEF DEBUG}      // �ò���������
//  nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
//  nList.Values['BindID'] := 'id';
//  nList.Values['Name'] := 'name_A';
//  nList.Values['Phone'] := 'Phone';
//
//  Result := PackerEncodeStr(nList.Text);
//  nList.Values['Name'] := 'name_B';
//  Result := Result + #13#10 + PackerEncodeStr(nList.Text);
//
//  gMG.FObjectPool.Release(nList);
//  Sleep(2000);
//  Exit;
  {$ENDIF}

  if CallBusinessWechat(cBC_WX_getCustomerInfo, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

end.


