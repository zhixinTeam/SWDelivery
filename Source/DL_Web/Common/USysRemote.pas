{*******************************************************************************
  作者: dmzn@163.com 2018-05-03
  描述: 远程业务调用
*******************************************************************************}
unit USysRemote;

{$I Link.Inc}
interface

uses
  Windows, Classes, System.SysUtils, UClientWorker, UBusinessConst,
  UBusinessPacker, UManagerGroup, USysDB, USysConst;

function GetSerialNo(const nGroup,nObject: string;
 const nUseDate: Boolean = True): string;
//获取串行编号
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean = True;
 const nCredit: PDouble = nil): Double;
//客户可用金额
function edit_shopclients(const nData: string): string;
//新增商城用户
function getWXCustomerList(const nData: string): string;
//获取商城注册用户列表

implementation

//Date: 2018-05-03
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的业务命令对象
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
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
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
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
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
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
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
//Parm: 命令;数据;参数;服务地址;输出
//Desc: 调用中间件上的销售单据对象
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
//Parm: 分组;对象;使用日期编码模式
//Desc: 依据nGroup.nObject生成串行编号
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
//Parm: 客户编号;包含信用;信用金额
//Desc: 获取nCID用户的可用金额,包含信用额或净额
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
//Parm: 账户数据
//Desc: 新增商城用户
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
//Parm: 参数
//Desc: 读取商城注册账户列表
function getWXCustomerList(const nData: string): string;
var nOut: TWorkerBusinessCommand;
{$IFDEF DEBUG}nList: TStrings;{$ENDIF}
begin
  {$IFDEF DEBUG}      // 该部分有问题
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


