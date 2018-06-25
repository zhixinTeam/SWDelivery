{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, UBase64,
  USysLoger, USysDB, UMITConst;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
  end;

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TK3SalePalnItem = record
    FInterID: string;       //主表编号
    FEntryID: string;       //附表编号
    FTruck: string;         //车牌号
  end;

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    {$IFDEF UseK3SalePlan}
    FSalePlans: array of TK3SalePalnItem;
    //k3销售计划
    {$ENDIF}
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCardUsed(var nData: string): Boolean;
    //获取卡片类型
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //登录注销，用于移动终端
    function GetServerNow(var nData: string): Boolean;
    //获取服务器时间
    function GetSerailID(var nData: string): Boolean;
    //获取串号
    function IsSystemExpired(var nData: string): Boolean;
    //系统是否已过期
    function GetCustomerValidMoney(var nData: string): Boolean;
    //获取客户可用金
    function GetZhiKaValidMoney(var nData: string): Boolean;
    //获取纸卡可用金
    function CustomerHasMoney(var nData: string): Boolean;
    //验证客户是否有钱
    function SaveTruck(var nData: string): Boolean;
    function UpdateTruck(var nData: string): Boolean;
    //保存车辆到Truck表
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //存取车辆称重数据

    function GetStockBatcode(var nData: string): Boolean;
    //获取品种批次号
    {$IFDEF UseERP_K3}
    function SyncRemoteSaleMan(var nData: string): Boolean;
    function SyncRemoteCustomer(var nData: string): Boolean;
    function SyncRemoteProviders(var nData: string): Boolean;
    function SyncRemoteMaterails(var nData: string): Boolean;
    //同步新安中联K3系统数据
    function SyncRemoteStockBill(var nData: string): Boolean;
    //同步交货单到K3系统
    function SyncRemoteStockOrder(var nData: string): Boolean;
    //同步交货单到K3系统
    function IsStockValid(var nData: string): Boolean;
    //验证物料是否允许发货
    {$ENDIF}
    {$IFDEF UseK3SalePlan}
    function IsSalePlanUsed(const nInter,nEntry,nTruck: string): Boolean;
    function GetSalePlan(var nData: string): Boolean;
    //读取销售计划
    {$ENDIF}
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill: 
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
end;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_ServerNow           : Result := GetServerNow(nData);                 
   cBC_GetSerialNO         : Result := GetSerailID(nData);

   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_GetCustomerMoney    : Result := GetCustomerValidMoney(nData);
   cBC_GetZhiKaMoney       : Result := GetZhiKaValidMoney(nData);
   cBC_CustomerHasMoney    : Result := CustomerHasMoney(nData);
   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_UpdateTruckInfo     : Result := UpdateTruck(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);
   cBC_GetStockBatcode     : Result := GetStockBatcode(nData);

   {$IFDEF UseERP_K3}
   cBC_SyncCustomer        : Result := SyncRemoteCustomer(nData);
   cBC_SyncSaleMan         : Result := SyncRemoteSaleMan(nData);
   cBC_SyncProvider        : Result := SyncRemoteProviders(nData);
   cBC_SyncMaterails       : Result := SyncRemoteMaterails(nData);
   cBC_SyncStockBill       : Result := SyncRemoteStockBill(nData);
   cBC_CheckStockValid     : Result := IsStockValid(nData);

   cBC_SyncStockOrder      : Result := SyncRemoteStockOrder(nData);
   {$ENDIF}

   {$IFDEF UseK3SalePlan}
   cBC_LoadSalePlan        : Result := GetSalePlan(nData);
   {$ENDIF}
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: 获取卡片类型：销售S;采购P;其他O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      nData := '磁卡[ %s ]信息不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名，密码；返回用户数据
//Desc: 用户登录
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //未传递用户名

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr<>FListA.Values['Password'] then Exit;
    {
    if CallMe(cBC_ServerNow, '', '', @nOut) then
         nStr := PackerEncodeStr(nOut.FData)
    else nStr := IntToStr(Random(999999));

    nInfo := FListA.Values['User'] + nStr;
    //xxxxx

    nStr := 'Insert into $EI(I_Group, I_ItemID, I_Item, I_Info) ' +
            'Values(''$Group'', ''$ItemID'', ''$Item'', ''$Info'')';
    nStr := MacroValue(nStr, [MI('$EI', sTable_ExtInfo),
            MI('$Group', sFlag_UserLogItem), MI('$ItemID', FListA.Values['User']),
            MI('$Item', PackerEncodeStr(FListA.Values['Password'])),
            MI('$Info', nInfo)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);  }

    Result := True;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名；验证数据
//Desc: 用户注销
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
//var nStr: string;
begin
  {nStr := 'delete From %s Where I_ItemID=''%s''';
  nStr := Format(nStr, [sTable_ExtInfo, PackerDecodeStr(FIn.FData)]);
  //card status

  
  if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
       Result := False
  else Result := True;     }

  Result := True;
end;

//Date: 2014-09-05
//Desc: 获取服务器当前时间
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: 按规则生成序列编号
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '没有[ %s.%s ]的编码配置.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //按日期编码
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: 验证系统是否已过期
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := '系统已过期 %d 天,请联系管理员!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('系统在 %d 天后过期', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

{$IFDEF COMMON}
//Date: 2014-09-05
//Desc: 获取指定客户的可用金额
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr: string;
    nUseCredit: Boolean;
    nVal,nCredit: Double;
begin
  nUseCredit := False;
  if FIn.FExtParam = sFlag_Yes then
  begin
    nStr := 'Select MAX(C_End) From %s ' +
            'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
    nStr := Format(nStr, [sTable_CusCredit, FIn.FData, sFlag_Yes]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      nUseCredit := (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
                    (Fields[0].AsDateTime > Now());
    //信用未过期
  end;

  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的客户账户不存在.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    nVal := FieldByName('A_InitMoney').AsFloat + FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

    if nUseCredit then
      nVal := nVal + nCredit;

    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;
    FOut.FData := FloatToStr(nVal);
    FOut.FExtParam := FloatToStr(nCredit);
    Result := True;
  end;
end;
{$ENDIF}

{$IFDEF COMMON}
//Date: 2014-09-05
//Desc: 获取指定纸卡的可用金额
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney,nCredit: Double;
begin
  nStr := 'Select ca.*,Z_OnlyMoney,Z_FixedMoney From $ZK,$CA ca ' +
          'Where Z_ID=''$ZID'' and A_CID=Z_Customer';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData),
          MI('$CA', sTable_CusAccount)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的纸卡不存在,或客户账户无效.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;

    nVal := FieldByName('A_InitMoney').AsFloat + FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

    nStr := 'Select MAX(C_End) From %s ' +
            'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
    nStr := Format(nStr, [sTable_CusCredit, FieldByName('A_CID').AsString,
            sFlag_Yes]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
       (Fields[0].AsDateTime > Now()) then
    begin
      nVal := nVal + nCredit;
      //信用未过期
    end;

    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;
    //total money

    if FOut.FExtParam = sFlag_Yes then
    begin
      if nMoney > nVal then
        nMoney := nVal;
      //enough money
    end else nMoney := nVal;

    FOut.FData := FloatToStr(nMoney);
    Result := True;
  end;
end;
{$ENDIF}

//Date: 2014-09-05
//Desc: 验证客户是否有钱,以及信用是否过期
function TWorkerBusinessCommander.CustomerHasMoney(var nData: string): Boolean;
var nStr,nName: string;
    nM,nC: Double;
begin
  FIn.FExtParam := sFlag_No;
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;

  nM := StrToFloat(FOut.FData);
  FOut.FData := sFlag_Yes;
  if nM > 0 then Exit;

  nStr := 'Select C_Name From %s Where C_ID=''%s''';
  nStr := Format(nStr, [sTable_Customer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
         nName := Fields[0].AsString
    else nName := '已删除';
  end;

  nC := StrToFloat(FOut.FExtParam);
  if (nC <= 0) or (nC + nM <= 0) then
  begin
    nData := Format('客户[ %s ]的资金余额不足.', [nName]);
    Result := False;
    Exit;
  end;

  nStr := 'Select MAX(C_End) From %s ' +
          'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
  nStr := Format(nStr, [sTable_CusCredit, FIn.FData, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
     (Fields[0].AsDateTime <= Now()) then
  begin
    nData := Format('客户[ %s ]的信用已过期.', [nName]);
    Result := False;
  end;
end;

//Date: 2014-10-02
//Parm: 车牌号[FIn.FData];
//Desc: 保存车辆到sTable_Truck表
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;                                                               
  FIn.FData := UpperCase(FIn.FData);
  
  nStr := 'Select Count(*) From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Truck, FIn.FData, GetPinYinOfStr(FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2016-02-16
//Parm: 车牌号(Truck); 表字段名(Field);数据值(Value)
//Desc: 更新车辆信息到sTable_Truck表
function TWorkerBusinessCommander.UpdateTruck(var nData: string): Boolean;
var nStr: string;
    nValInt: Integer;
    nValFloat: Double;
begin
  Result := True;
  FListA.Text := FIn.FData;

  if FListA.Values['Field'] = 'T_PValue' then
  begin
    nStr := 'Select T_PValue, T_PTime From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, FListA.Values['Truck']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nValInt := Fields[1].AsInteger;
      nValFloat := Fields[0].AsFloat;
    end else Exit;

    nValFloat := nValFloat * nValInt + StrToFloatDef(FListA.Values['Value'], 0);
    nValFloat := nValFloat / (nValInt + 1);
    nValFloat := Float2Float(nValFloat, cPrecision);

    nStr := 'Update %s Set T_PValue=%.2f, T_PTime=T_PTime+1 Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nValFloat, FListA.Values['Truck']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2014-09-25
//Parm: 车牌号[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: 称重数据[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  with nPound[0] do
  begin
    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //保存车牌号

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '进厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nStr := SF('P_ID', FPoundID);
      //where

      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //称重时,由于皮重大,交换皮毛重数据
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
      end;

      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

//Date: 2016-02-24
//Parm: 物料编号[FIn.FData];预扣减量[FIn.ExtParam];
//Desc: 按规则生成指定品种的批次编号
function TWorkerBusinessCommander.GetStockBatcode(var nData: string): Boolean;
var nStr,nP, nTip, nSql: string;
    nNew: Boolean;
    nInt,nInc: Integer;
    nVal,nPer, nSurplus : Double;

    //生成新批次号
    function NewBatCode: string;
    begin
      nStr := 'Select * From %s Where B_Stock=''%s''';
      nStr := Format(nStr, [sTable_StockBatcode, FIn.FData]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        nP := FieldByName('B_Prefix').AsString;
        nStr := FieldByName('B_UseYear').AsString;

        if nStr = sFlag_Yes then
        begin
          nStr := Copy(Date2Str(Now()), 3, 2);
          nP := nP + nStr;
          //前缀后两位年份
        end;

        nStr := FieldByName('B_Base').AsString;
        nInt := FieldByName('B_Length').AsInteger;
        nInt := nInt - Length(nP + nStr);

        if nInt > 0 then
             Result := nP + StringOfChar('0', nInt) + nStr
        else Result := nP + nStr;

        nStr := '物料[ %s.%s ]将立即使用批次号[ %s ],请通知化验室确认已采样.';
        nStr := Format(nStr, [FieldByName('B_Stock').AsString,
                              FieldByName('B_Name').AsString, Result]);
        //xxxxx

        FOut.FBase.FErrCode := sFlag_ForceHint;
        FOut.FBase.FErrDesc := nStr;
      end;

      nStr := MakeSQLByStr([SF('B_Batcode', Result),
                SF('B_FirstDate', sField_SQLServer_Now, sfVal),
                SF('B_HasUse', 0, sfVal),
                SF('B_LastDate', sField_SQLServer_Now, sfVal)
                ], sTable_StockBatcode, SF('B_Stock', FIn.FData), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
begin
  Result := True;
  FOut.FData := '';
  
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BatchAuto]);
  
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := Fields[0].AsString;
    if nStr <> sFlag_Yes then Exit;
  end  else Exit;
  //默认不使用批次号

  Result := False; //Init
  nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_StockBatcode, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '物料[ %s ]未配置批次号规则.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FOut.FData := FieldByName('B_Batcode').AsString;
    nInc := FieldByName('B_Incement').AsInteger;
    nNew := False;

    if FieldByName('B_UseDate').AsString = sFlag_Yes then
    begin
      nP := FieldByName('B_Prefix').AsString;
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime, False);

      nInt := FieldByName('B_Length').AsInteger;
      nInt := Length(nP + nStr) - nInt;

      if nInt > 0 then
      begin
        System.Delete(nStr, 1, nInt);
        FOut.FData := nP + nStr;
      end else
      begin
        nStr := StringOfChar('0', -nInt) + nStr;
        FOut.FData := nP + nStr;
      end;

      nNew := True;
    end;

    if (not nNew) and (FieldByName('B_AutoNew').AsString = sFlag_Yes) then      //元旦重置
    begin
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
      nStr := Copy(nStr, 1, 4);
      nP := Date2Str(FieldByName('B_LastDate').AsDateTime);
      nP := Copy(nP, 1, 4);

      if nStr <> nP then
      begin
        nStr := 'Update %s Set B_Base=1 Where B_Stock=''%s''';
        nStr := Format(nStr, [sTable_StockBatcode, FIn.FData]);
        
        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode;
        nNew := True;
      end;
    end;

    if not nNew then //编号超期
    begin
      nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
      nP := Date2Str(FieldByName('B_FirstDate').AsDateTime);

      if (Str2Date(nP) > Str2Date('2000-01-01')) and
         (Str2Date(nStr) - Str2Date(nP) > FieldByName('B_Interval').AsInteger) then
      begin
        nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s''';
        nStr := Format(nStr, [sTable_StockBatcode, nInc, FIn.FData]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode;
        nNew := True;
      end;
    end;

    if not nNew then //编号超发
    begin
      nVal := FieldByName('B_HasUse').AsFloat + StrToFloat(FIn.FExtParam);
      //已使用+预使用
      nPer := FieldByName('B_Value').AsFloat * FieldByName('B_High').AsFloat / 100;
      //可用上限

      if nVal >= nPer then //超发
      begin
        nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s''';
        nStr := Format(nStr, [sTable_StockBatcode, nInc, FIn.FData]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        FOut.FData := NewBatCode;
      end else
      begin
        nPer := FieldByName('B_Value').AsFloat * FieldByName('B_Low').AsFloat / 100;
        //提醒
      
        if nVal >= nPer then //超发提醒
        begin
          nStr := '物料[ %s.%s ]即将更换批次号,请通知化验室准备取样.';
          nStr := Format(nStr, [FieldByName('B_Stock').AsString,
                                FieldByName('B_Name').AsString]);
          //xxxxx

          FOut.FBase.FErrCode := sFlag_ForceHint;
          FOut.FBase.FErrDesc := nStr;

          nSurplus:= FieldByName('B_Value').AsFloat-FieldByName('B_HasUse').AsFloat;
          nStr := '物料[ %s.%s ]批次[%s]发货已达预警量、剩余发货量[ %g ]、即将更换批次号,请准备取样.';
          nStr := Format(nStr, [FieldByName('B_Stock').AsString, FieldByName('B_Name').AsString,
                                FieldByName('B_Batcode').AsString, nSurplus]);

          nTip:= FieldByName('B_Batcode').AsString +'>>'+ sFlag_ManualF;
          nSql:= ' If Not Exists (Select * From Sys_ManualEvent Where E_ID='''+nTip+''')  '+
                 '      Insert Into Sys_ManualEvent(E_ID, E_From, E_Event, E_Solution, E_Departmen, E_Date) '+
                 '      Select ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', CONVERT(Varchar(20), GETDATE(), 120)  ';
          nSql:= Format(nSql, [nTip, sFlag_DepSys, nStr, sFlag_Solution_YNt, sFlag_DepHuaYan]);
          gDBConnManager.WorkerExec(FDBConn, nSql);
        end;
      end;
    end;
  end;

  if FOut.FData = '' then
    FOut.FData := NewBatCode;
  //xxxxx
  
  Result := True;
  FOut.FBase.FResult := True;
end;

{$IFDEF UseERP_K3}
//Date: 2014-10-14
//Desc: 同步新安中联客户数据到DL系统
function TWorkerBusinessCommander.SyncRemoteCustomer(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select S_Table,S_Action,S_Record,S_Param1,S_Param2,FItemID,' +
            'FName,FNumber,FEmployee From %s' +
            '  Left Join %s On FItemID=S_Record';
    nStr := Format(nStr, [sTable_K3_SyncItem, sTable_K3_Customer]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := FieldByName('S_Action').AsString;
        //action

        if nStr = 'A' then //Add
        begin
          if FieldByName('FItemID').AsString = '' then Continue;
          //invalid

          nStr := MakeSQLByStr([SF('C_ID', FieldByName('FItemID').AsString),
                  SF('C_Name', FieldByName('FName').AsString),
                  SF('C_PY', GetPinYinOfStr(FieldByName('FName').AsString)),
                  SF('C_SaleMan', FieldByName('FEmployee').AsString),
                  SF('C_Memo', FieldByName('FNumber').AsString),
                  SF('C_Param', FieldByName('FNumber').AsString),
                  SF('C_XuNi', sFlag_No)
                  ], sTable_Customer, '', True);
          FListA.Add(nStr);

          nStr := MakeSQLByStr([SF('A_CID', FieldByName('FItemID').AsString),
                  SF('A_Date', sField_SQLServer_Now, sfVal)
                  ], sTable_CusAccount, '', True);
          FListA.Add(nStr);
        end else

        if nStr = 'E' then //edit
        begin
          if FieldByName('FItemID').AsString = '' then Continue;
          //invalid

          nStr := SF('C_ID', FieldByName('FItemID').AsString);
          nStr := MakeSQLByStr([
                  SF('C_Name', FieldByName('FName').AsString),
                  SF('C_PY', GetPinYinOfStr(FieldByName('FName').AsString)),
                  SF('C_SaleMan', FieldByName('FEmployee').AsString),
                  SF('C_Memo', FieldByName('FNumber').AsString)
                  ], sTable_Customer, nStr, False);
          FListA.Add(nStr);
        end else

        if nStr = 'D' then //delete
        begin
          nStr := 'Delete From %s Where C_ID=''%s''';
          nStr := Format(nStr, [sTable_Customer, FieldByName('S_Record').AsString]);
          FListA.Add(nStr);
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //开启事务
    
      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;

      nStr := 'Delete From ' + sTable_K3_SyncItem;
      gDBConnManager.WorkerExec(nDBWorker, nStr);
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2014-10-14
//Desc: 同步新安中联业务员数据到DL系统
function TWorkerBusinessCommander.SyncRemoteSaleMan(var nData: string): Boolean;
var nStr,nDept: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nDept := '1356';
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SaleManDept]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nDept := Fields[0].AsString;
      //销售部门编号
    end;

    nStr := 'Select FItemID,FName,FDepartmentID From t_EMP';
    //FDepartmentID='1356'为销售部门

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        if Fields[2].AsString = nDept then
             nStr := sFlag_No
        else nStr := sFlag_Yes;
        
        nStr := MakeSQLByStr([SF('S_ID', Fields[0].AsString),
                SF('S_Name', Fields[1].AsString),
                SF('S_InValid', nStr)
                ], sTable_Salesman, '', True);
        //xxxxx
        
        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'Delete From ' + sTable_Salesman;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-10-14
//Desc: 同步新安中联供应商数据到DL系统
function TWorkerBusinessCommander.SyncRemoteProviders(var nData: string): Boolean;
var nStr,nSaler: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nSaler := '待分配业务员';
    nStr := 'Select FItemID,FName,FNumber From t_Supplier Where FDeleted=0';
    //未删除供应商

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('P_ID', Fields[0].AsString),
                SF('P_Name', Fields[1].AsString),
                SF('P_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('P_Memo', Fields[2].AsString),
                SF('P_Saler', nSaler)
                ], sTable_Provider, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //开启事务

      nStr := 'Delete From ' + sTable_Provider;
      gDBConnManager.WorkerExec(FDBConn, nStr);

      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2014-10-14
//Desc: 同步新安中联原材料数据到DL系统
function TWorkerBusinessCommander.SyncRemoteMaterails(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select FItemID,FName,FNumber From t_ICItem ';// +
            //'Where (FFullName like ''%%原材料_主要材料%%'') or ' +
            //'(FFullName like ''%%原材料_燃料%%'')';
    //xxxxx

    {$IFDEF YNHT}
    nStr := nStr + ' Where FDeleted=0 and ' +
            '(FParentID=''3406'' or FParentID=''3408'' or ' +
            ' FParentID=''3410'' or FParentID=''27200'')';
    {$ENDIF}

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('M_ID', Fields[0].AsString),
                SF('M_Name', Fields[1].AsString),
                SF('M_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('M_Memo', GetPinYinOfStr(Fields[2].AsString))
                ], sTable_Materails, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'Delete From ' + sTable_Materails;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;


//Date: 2014-10-14
//Desc: 获取指定客户的可用金额
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr,nCusID: string;
    nUseCredit: Boolean;
    nVal,nCredit: Double;
    nDBWorker: PDBWorker;
begin
  Result := False;
  nUseCredit := False;
  
  if FIn.FExtParam = sFlag_Yes then
  begin
    nStr := 'Select MAX(C_End) From %s ' +
            'Where C_CusID=''%s'' and C_Money>=0 and C_Verify=''%s''';
    nStr := Format(nStr, [sTable_CusCredit, FIn.FData, sFlag_Yes]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      nUseCredit := (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
                    (Fields[0].AsDateTime > Now());
    //信用未过期
  end;

  nStr := 'Select A_FreezeMoney,A_CreditLimit,C_Param From %s,%s ' +
          'Where A_CID=''%s'' And A_CID=C_ID';
  nStr := Format(nStr, [sTable_Customer, sTable_CusAccount, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的客户账户不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nCusID := FieldByName('C_Param').AsString;
    nVal := FieldByName('A_FreezeMoney').AsFloat;
    nCredit := FieldByName('A_CreditLimit').AsFloat;
  end;

  nDBWorker := nil;
  try
    nStr := 'DECLARE @return_value int, @Credit decimal(28, 10),' +
            '@Balance decimal(28, 10)' +
            'Execute GetCredit ''%s'' , @Credit output , @Balance output ' +
            'select @Credit as Credit , @Balance as Balance , ' +
            '''Return Value'' = @return_value';
    nStr := Format(nStr, [nCusID]);
    
    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'K3数据库上编号为[ %s ]的客户账户不存在.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      nVal := -(FieldByName('Balance').AsFloat) - nVal;
      if nUseCredit then
      begin
        nCredit := FieldByName('Credit').AsFloat + nCredit;
        nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;
        nVal := nVal + nCredit;
      end;

      nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;
      FOut.FData := FloatToStr(nVal);
      FOut.FExtParam := FloatToStr(nCredit);
      Result := True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2014-10-14
//Desc: 获取指定纸卡的可用金额
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nStr := 'Select Z_Customer,Z_OnlyMoney,Z_FixedMoney From $ZK ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的纸卡不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nStr := FieldByName('Z_Customer').AsString;
    if not TWorkerBusinessCommander.CallMe(cBC_GetCustomerMoney, nStr,
       sFlag_Yes, @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    nVal := StrToFloat(nOut.FData);
    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;
                                
    if FOut.FExtParam = sFlag_Yes then
    begin
      if nMoney > nVal then
        nMoney := nVal;
      //enough money
    end else nMoney := nVal;

    FOut.FData := FloatToStr(nMoney);
    Result := True;
  end;
end;

//Date: 2014-10-15
//Parm: 交货单列表[FIn.FData]
//Desc: 同步交货单数据到K3系统
function TWorkerBusinessCommander.SyncRemoteStockBill(var nData: string): Boolean;
var nID,nIdx: Integer;
    nVal,nMoney: Double;
    nK3Worker: PDBWorker;
    nStr,nSQL,nBill,nStockID: string;
begin
  Result := False;
  nK3Worker := nil;
  nStr := AdjustListStrFormat(FIn.FData , '''' , True , ',' , True);

  nSQL := 'select L_ID,L_Truck,L_SaleID,L_CusID,L_StockNo,L_Value,' +
          'L_Seal,L_HYDan,L_Price,L_OutFact From $BL ' +
          'where L_ID In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BL', sTable_Bill) , MI('$IN', nStr)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的交货单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nK3Worker := gDBConnManager.GetConnection(sFlag_DB_K3, FErrNum);
    if not Assigned(nK3Worker) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not nK3Worker.FConn.Connected then
      nK3Worker.FConn.Connected := True;
    //conn db

    FListA.Clear;
    First;
    
    while not Eof do
    begin
      nSQL :='DECLARE @ret1 int, @FInterID int, @BillNo varchar(200) '+
            'Exec @ret1=GetICMaxNum @TableName=''%s'',@FInterID=@FInterID output '+
            'EXEC p_BM_GetBillNo @ClassType =21,@BillNo=@BillNo OUTPUT ' +
            'select @FInterID as FInterID , @BillNo as BillNo , ' +
            '''RetGetICMaxNum'' = @ret1';
      nSQL := Format(nSQL, ['ICStockBill']);
      //get FInterID, BillNo

      with gDBConnManager.WorkerQuery(nK3Worker, nSQL) do
      begin
        nBill := FieldByName('BillNo').AsString;
        nID := FieldByName('FInterID').AsInteger;
      end;

      {$IFDEF YNHT}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Fpoordbillno', ''),
          SF('Fstatus', 0, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Ftrantype', 21, sfVal),
          SF('Fdeptid', 186, sfVal),

          SF('Frelatebrid', 0, sfVal),
          //SF('Fmanagetype', 0, sfVal),
          SF('Fvchinterid', 0, sfVal),

          SF('Fsalestyle', 101, sfVal),
          SF('Fseltrantype', 0, sfVal),

          SF('Fbillerid', 16559, sfVal),
          SF('Ffmanagerid', 36761, sfVal),
          SF('Fsmanagerid', 36761, sfVal),

          SF('Fupstockwhensave', 1, sfVal),
          SF('Fmarketingstyle', 12530, sfVal),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fheadselfb0144', 15263, sfVal),
          SF('Fheadselfb0146', FieldByName('L_Truck').AsString),

          SF('Fempid', FieldByName('L_SaleID').AsString, sfVal),
          SF('Fsupplyid', FieldByName('L_CusID').AsString, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        {$IFDEF JYZL}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Fpoordbillno', ''),
          SF('Fstatus', 0, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Ftrantype', 21, sfVal),
          SF('Fdeptid', 177, sfVal),
          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fmanagetype', 0, sfVal),
          SF('Fvchinterid', 0, sfVal),

          SF('Fsalestyle', 101, sfVal),
          SF('Fseltrantype', 0, sfVal),
          SF('Fsettledate', Date2Str(Now)),

          SF('Fbillerid', 16442, sfVal),
          SF('Ffmanagerid', 293, sfVal),
          SF('Fsmanagerid', 261, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fempid', FieldByName('L_SaleID').AsString, sfVal),
          SF('Fsupplyid', FieldByName('L_CusID').AsString, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
        {$ELSE}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Fpoordbillno', ''),
          SF('Fstatus', 0, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Ftrantype', 21, sfVal),
          SF('Fdeptid', 1356, sfVal),
          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fmanagetype', 0, sfVal),
          SF('Fvchinterid', 0, sfVal),

          SF('Fsalestyle', 101, sfVal),
          SF('Fseltrantype', 83, sfVal),
          SF('Fsettledate', Date2Str(Now)),

          SF('Fbillerid', 16394, sfVal),
          SF('Ffmanagerid', 1278, sfVal),
          SF('Fsmanagerid', 1279, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fempid', FieldByName('L_SaleID').AsString, sfVal),
          SF('Fsupplyid', FieldByName('L_CusID').AsString, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
        {$ENDIF}
      {$ENDIF}

      //------------------------------------------------------------------------
      nVal := FieldByName('L_Value').AsFloat;
      nMoney := nVal * FieldByName('L_Price').AsFloat;
      nMoney := Float2Float(nMoney, cPrecision, True);

      {$IFDEF YNHT}
        nStr := FieldByName('L_StockNo').AsString;
        if nStr = '3396' then  //熟料
             nStockID := '3213'
        else nStockID := '3214';

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', FieldByName('L_StockNo').AsString),
                                              
          SF('Fentryid', 1, sfVal),
          SF('Funitid', 64, sfVal),

          SF('Fdcspid', 0, sfVal),
          SF('Fsnlistid', 0, sfVal),
          SF('Fsourceentryid', 1, sfVal),

          SF('Forderbillno', FieldByName('L_ID').AsString),
          SF('Forderinterid', '0', sfVal),
          SF('Forderentryid', '0', sfVal),
          //订单编号

          SF('Fsourcebillno', '0'),
          SF('Fsourcetrantype', 0, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', nVal, sfVal),
          SF('Fauxqtymust', nVal, sfVal),

          {$IFDEF BatchInHYOfBill}
          SF('FEntrySelfB0155', FieldByName('L_HYDan').AsString),
          {$ELSE}
          SF('FEntrySelfB0155', FieldByName('L_Seal').AsString),
          {$ENDIF}
          //水泥出厂编号

          SF('Fconsignprice', FieldByName('L_Price').AsFloat , sfVal),
          SF('Fconsignamount', nMoney, sfVal),
          SF('fdcstockid', nStockID, sfVal)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        {$IFDEF JYZL}
        nStr := FieldByName('L_StockNo').AsString;
        if nStr = '6053' then  //熟料
             nStockID := '322'
        else nStockID := '326';

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', FieldByName('L_StockNo').AsString),
                                              
          SF('Fentryid', 1, sfVal),
          SF('Funitid', 132, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 1, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fseoutbillno', FieldByName('L_ID').AsString),
          SF('Fseoutinterid', '0', sfVal),
          SF('Fseoutentryid', '0', sfVal),

          SF('Fsourcebillno', '0'),
          SF('Fsourcetrantype', 83, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', nVal, sfVal),
          SF('Fauxqtymust', nVal, sfVal),

          SF('Fconsignprice', FieldByName('L_Price').AsFloat , sfVal),
          SF('Fconsignamount', nMoney, sfVal),
          SF('fdcstockid', nStockID, sfVal)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
        {$ELSE}
        nStr := FieldByName('L_StockNo').AsString;
        if (nStr = '444') or (nStr = '1388') then  //熟料
             nStockID := '1731'
        else nStockID := '1730';

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', FieldByName('L_StockNo').AsString),
                                              
          SF('Fentryid', 1, sfVal),
          SF('Funitid', 136, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 1, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fseoutbillno', '0'),
          SF('Fseoutinterid', '0', sfVal),
          SF('Fseoutentryid', '0', sfVal),

          SF('Fsourcebillno', '0'),
          SF('Fsourcetrantype', 83, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('Fentryselfb0166', FieldByName('L_ID').AsString),
          SF('Fentryselfb0167', FieldByName('L_Truck').AsString),
          SF('Fentryselfb0168', DateTime2Str(Now)),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', nVal, sfVal),
          SF('Fauxqtymust', nVal, sfVal),

          SF('Fconsignprice', FieldByName('L_Price').AsFloat , sfVal),
          SF('Fconsignamount', nMoney, sfVal),
          SF('fdcstockid', nStockID, sfVal)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
        {$ENDIF}
      {$ENDIF}

      Next;
      //xxxxx
    end;

    //----------------------------------------------------------------------------
    nK3Worker.FConn.BeginTrans;
    try
      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(nK3Worker, FListA[nIdx]);
      //xxxxx

      nK3Worker.FConn.CommitTrans;
      Result := True;
    except
      nK3Worker.FConn.RollbackTrans;
      nStr := '同步交货单数据到K3系统失败.';
      raise Exception.Create(nStr);
    end;
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
  end;
end;

//Date: 2014-10-15
//Parm: 采购单列表[FIn.FData]
//Desc: 同步采购单数据到K3系统
function TWorkerBusinessCommander.SyncRemoteStockOrder(var nData: string): Boolean;
var nID,nIdx: Integer;
    nVal: Double;
    nK3Worker: PDBWorker;
    nStr,nSQL,nBill,nStockID: string;
begin
  Result := False;
  nK3Worker := nil;

  nSQL := 'select O_ID,O_Truck,O_SaleID,O_ProID,O_StockNo,' +
          'D_ID, (D_MValue-D_PValue-D_KZValue) as D_Value,D_InTime, ' +
          'D_PValue, D_MValue, D_YSResult, D_KZValue ' +
          'From $OD od left join $OO oo on od.D_OID=oo.O_ID ' +
          'where D_ID=''$IN''';
  nSQL := MacroValue(nSQL, [MI('$OD', sTable_OrderDtl) ,
                            MI('$OO', sTable_Order),
                            MI('$IN', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nSQL)  do
  try
    if RecordCount < 1 then
    begin
      nData := '编号为[ %s ]的采购单不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if FieldByName('D_YSResult').AsString=sFlag_No then
    begin          //拒收
      Result := True;
      Exit;
    end;  

    nK3Worker := gDBConnManager.GetConnection(sFlag_DB_K3, FErrNum);
    if not Assigned(nK3Worker) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not nK3Worker.FConn.Connected then
      nK3Worker.FConn.Connected := True;
    //conn db

    FListA.Clear;
    First;

    while not Eof do
    begin
      nSQL :='DECLARE @ret1 int, @FInterID int, @BillNo varchar(200) '+
            'Exec @ret1=GetICMaxNum @TableName=''%s'',@FInterID=@FInterID output '+
            'EXEC p_BM_GetBillNo @ClassType =1,@BillNo=@BillNo OUTPUT ' +
            'select @FInterID as FInterID , @BillNo as BillNo , ' +
            '''RetGetICMaxNum'' = @ret1';
      nSQL := Format(nSQL, ['ICStockBill']);
      //get FInterID, BillNo

      with gDBConnManager.WorkerQuery(nK3Worker, nSQL) do
      begin
        nBill := FieldByName('BillNo').AsString;
        nID := FieldByName('FInterID').AsInteger;
      end;

      {$IFDEF YNHT}
      nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Ftrantype', 1, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fdeptid', 191, sfVal),
          SF('FEmpid', 0, sfVal),
          SF('Fsupplyid', FieldByName('O_ProID').AsString, sfVal),
          //SF('FPosterid', FieldByName('O_SaleID').AsString, sfVal),
          //SF('FCheckerid', FieldByName('O_SaleID').AsString, sfVal),


          SF('Fbillerid', 36761, sfVal),
          SF('Ffmanagerid', 36761, sfVal),
          SF('Fsmanagerid', 36761, sfVal),

          SF('Fstatus', 0, sfVal),
          SF('Fvchinterid', 0, sfVal),

          //SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fseltrantype', 0, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal)
          ], 'ICStockBill', '', True);
      //  FListA.Add(nSQL);
      {$ELSE}
        {$IFDEF JYZL}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Ftrantype', 1, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fdeptid', 0, sfVal),
          SF('FEmpid', 0, sfVal),
          SF('Fsupplyid', FieldByName('O_ProID').AsString, sfVal),
          //SF('FPosterid', FieldByName('O_SaleID').AsString, sfVal),
          //SF('FCheckerid', FieldByName('O_SaleID').AsString, sfVal),


          SF('Fbillerid', 16394, sfVal),
          SF('Ffmanagerid', 1789, sfVal),
          SF('Fsmanagerid', 1789, sfVal),

          SF('Fstatus', 0, sfVal),
          SF('Fvchinterid', 9662, sfVal),

          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fseltrantype', 0, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
        {$ELSE}
        nSQL := MakeSQLByStr([
          SF('Frob', 1, sfVal),
          SF('Fbrno', 0, sfVal),
          SF('Fbrid', 0, sfVal),

          SF('Ftrantype', 1, sfVal),
          SF('Fdate', Date2Str(Now)),

          SF('Fbillno', nBill),
          SF('Finterid', nID, sfVal),

          SF('Fdeptid', 0, sfVal),
          SF('FEmpid', 0, sfVal),
          SF('Fsupplyid', FieldByName('O_ProID').AsString, sfVal),
          //SF('FPosterid', FieldByName('O_SaleID').AsString, sfVal),
          //SF('FCheckerid', FieldByName('O_SaleID').AsString, sfVal),


          SF('Fbillerid', 16394, sfVal),
          SF('Ffmanagerid', 1789, sfVal),
          SF('Fsmanagerid', 1789, sfVal),

          SF('Fstatus', 0, sfVal),
          SF('Fvchinterid', 9662, sfVal),

          SF('Fconsignee', 0, sfVal),

          SF('Frelatebrid', 0, sfVal),
          SF('Fseltrantype', 0, sfVal),

          SF('Fupstockwhensave', 0, sfVal),
          SF('Fmarketingstyle', 12530, sfVal)
          ], 'ICStockBill', '', True);
        FListA.Add(nSQL);
        {$ENDIF}
      {$ENDIF}

      //------------------------------------------------------------------------
      nVal := FieldByName('D_Value').AsFloat;

      {$IFDEF YNHT}
        nStockID := FieldByName('O_StockNo').AsString;

      { nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', nStockID),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', 0, sfVal),
          SF('Fauxqtymust', 0, sfVal),

          SF('Fentryid', 1, sfVal),
          SF('Funitid', 64, sfVal),
          //SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 0, sfVal),
          //SF('Fchkpassitem', 1058, sfVal),

          SF('Fsourcetrantype', 0, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('finstockid', '0', sfVal),
          SF('fdcstockid', '3211', sfVal),

          SF('FEntrySelfA0158', FieldByName('D_MValue').AsFloat, sfVal),
          SF('FEntrySelfA0159', FieldByName('D_PValue').AsFloat, sfVal),
          SF('FEntrySelfA0160', FieldByName('D_KZValue').AsFloat, sfVal),
          SF('FEntrySelfA0161', FieldByName('O_Truck').AsString),
          SF('FEntrySelfA0162', FieldByName('D_ID').AsString)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);  }
        nSQL := MakeSQLByStr([
          SF('FInTime', FieldByName('D_InTime').AsString),
          SF('FOutTime', sField_SQLServer_Now, sfVal),

          SF('FNO', nID),
          SF('FPrintNum', 1, sfVal),
          SF('FState', 3, sfVal),
          SF('FBillerID', 16559, sfVal),
          //DL系统

          SF('FRemark', FieldByName('D_ID').AsString),
          SF('FCarNO', FieldByName('O_Truck').AsString),
          SF('FSupplyID', FieldByName('O_ProID').AsString),
          SF('FICItemID', FieldByName('O_StockNo').AsString),


          SF('FTotal', Float2Float(FieldByName('D_MValue').AsFloat, 100, True) * 1000, sfVal),
          SF('FTruck', Float2Float(FieldByName('D_PValue').AsFloat, 100, True) * 1000, sfVal),
          SF('FNet', Float2Float(nVal, 100, True) * 1000, sfVal)
          ], 'A_BuyWeight', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        {$IFDEF JYZL}
        nStockID := FieldByName('O_StockNo').AsString;

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', nStockID),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', 0, sfVal),
          SF('Fauxqtymust', 0, sfVal),

          SF('Fentryid', 1, sfVal),
          SF('Funitid', 136, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 0, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fsourcetrantype', 0, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('finstockid', '0', sfVal),
          SF('fdcstockid', '2071', sfVal),

          SF('FEntrySelfA0158', FieldByName('D_MValue').AsFloat, sfVal),
          SF('FEntrySelfA0159', FieldByName('D_PValue').AsFloat, sfVal),
          SF('FEntrySelfA0160', FieldByName('D_KZValue').AsFloat, sfVal),
          SF('FEntrySelfA0161', FieldByName('O_Truck').AsString),
          SF('FEntrySelfA0162', FieldByName('D_ID').AsString)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
      {$ELSE}
        nStockID := FieldByName('O_StockNo').AsString;

        nSQL := MakeSQLByStr([
          SF('Fbrno', 0, sfVal),
          SF('Finterid', nID),
          SF('Fitemid', nStockID),

          SF('Fqty',  nVal, sfVal),
          SF('Fauxqty', nVal, sfVal),
          SF('Fqtymust', 0, sfVal),
          SF('Fauxqtymust', 0, sfVal),

          SF('Fentryid', 1, sfVal),
          SF('Funitid', 136, sfVal),
          SF('Fplanmode', 14036, sfVal),

          SF('Fsourceentryid', 0, sfVal),
          SF('Fchkpassitem', 1058, sfVal),

          SF('Fsourcetrantype', 0, sfVal),
          SF('Fsourceinterid', '0', sfVal),

          SF('finstockid', '0', sfVal),
          SF('fdcstockid', '2071', sfVal),

          SF('FEntrySelfA0158', FieldByName('D_MValue').AsFloat, sfVal),
          SF('FEntrySelfA0159', FieldByName('D_PValue').AsFloat, sfVal),
          SF('FEntrySelfA0160', FieldByName('D_KZValue').AsFloat, sfVal),
          SF('FEntrySelfA0161', FieldByName('O_Truck').AsString),
          SF('FEntrySelfA0162', FieldByName('D_ID').AsString)
          ], 'ICStockBillEntry', '', True);
        FListA.Add(nSQL);
        {$ENDIF}
      {$ENDIF}

      Next;
      //xxxxx
    end;

    //----------------------------------------------------------------------------
    nK3Worker.FConn.BeginTrans;
    try
      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(nK3Worker, FListA[nIdx]);
      //xxxxx

      nK3Worker.FConn.CommitTrans;
      Result := True;
    except
      nK3Worker.FConn.RollbackTrans;
      nStr := '同步采购单数据到K3系统失败.';
      raise Exception.Create(nStr);
    end;
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
  end;
end;

//Date: 2014-10-16
//Parm: 物料列表[FIn.FData]
//Desc: 验证物料是否允许发货.
function TWorkerBusinessCommander.IsStockValid(var nData: string): Boolean;
var nStr: string;
    nK3Worker: PDBWorker;
begin
  Result := True;
  nK3Worker := nil;
  try
    nStr := 'Select FItemID,FName from T_ICItem Where FDeleted=1';
    //sql
    
    with gDBConnManager.SQLQuery(nStr, nK3Worker, sFlag_DB_K3) do
    begin
      if RecordCount < 1 then Exit;
      //not forbid

      SplitStr(FIn.FData, FListA, 0, ',');
      First;

      while not Eof do
      begin
        nStr := Fields[0].AsString;
        if FListA.IndexOf(nStr) >= 0 then
        begin
          nData := '品种[ %s.%s ]已禁用,不能发货.';
          nData := Format(nData, [nStr, Fields[1].AsString]);

          Result := False;
          Exit;
        end;

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nK3Worker);
  end;
end;   
{$ENDIF}

{$IFDEF UseK3SalePlan}
//Desc: 计划已使用
function TWorkerBusinessCommander.IsSalePlanUsed(const nInter, nEntry,
  nTruck: string): Boolean;
var nIdx: Integer;
begin
  Result := False;
  for nIdx:=Low(FSalePlans) to High(FSalePlans) do
   with FSalePlans[nIdx] do
    if (FInterID=nInter) and (FEntryID=nEntry) and (FTruck=nTruck) then
    begin
      Result := True;
      Exit;
    end;
  //xxxxx
end;

//Date: 2017-01-03
//Parm: 客户编号[FIn.FData]
//Desc: 读取客户的销售计划
function TWorkerBusinessCommander.GetSalePlan(var nData: string): Boolean;
var nIdx: Integer;
    nStr: string;
    nWorker: PDBWorker;
begin
  Result := False;
  nStr := 'select o.FBillNo,e.FInterID,e.FEntryID,i.FItemID as StockID,' +
          'i.FName as StockName,org.FItemID CusID,org.FName as CusName,' +
          'e.FQty as StockValue,e.FNote as Truck from SEOrderEntry e ' +
          '  left join SEOrder o on o.fInterID=e.fInterID' +
          '  left join t_Organization org on org.FItemID=o.FcustID' +
          '  left join t_ICItem i on i.FItemID=e.FItemID ' +
          'WHERE e.FDate>=%s-1 and o.FcustID=''%s'' and ' +
          '  o.FCancellation=0 and o.FStatus=1';
  nStr := Format(nStr, [sField_SQLServer_Now, FIn.FData]);

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_K3) do
    begin
      if RecordCount < 1 then
      begin
        nData := '未找到该客户的销售计划';
        Exit;
      end;

      SetLength(FSalePlans, 0);
      FListC.Clear;
      First;

      while not Eof do
      begin
        FListC.Add(FieldByName('FInterID').AsString);
        Next;
      end;

      nStr := 'Delete From %s Where S_Date<%s-1';
      nStr := Format(nStr, [sTable_K3_SalePlan, sField_SQLServer_Now]);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      nStr := 'Select * From %s Where S_InterID in (%s)';
      nStr := Format(nStr, [sTable_K3_SalePlan, CombinStr(FListC, ',', False)]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        SetLength(FSalePlans, RecordCount);
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FSalePlans[nIdx] do
          begin
            FInterID := FieldByName('S_InterID').AsString;
            FEntryID := FieldByName('S_EntryID').AsString;
            FTruck := FieldByName('S_Truck').AsString;
          end;

          Inc(nIdx);
          Next;
        end;
      end;

      //------------------------------------------------------------------------
      FListA.Clear;
      FListB.Clear;
      First;

      while not Eof do
      try
        nStr := Trim(FieldByName('Truck').AsString);
        if nStr = '' then Continue;
        SplitStr(nStr, FListC, 0, ' ');

        for nIdx:=FListC.Count-1 downto 0 do
         if Trim(FListC[nIdx]) = '' then FListC.Delete(nIdx);
        //xxxxx

        if FListC.Count < 2 then Continue;
        if FListC.Count mod 2 <> 0 then Continue;
        //格式: 车牌 吨 车牌 吨

        nIdx:=0;
        while nIdx< FListC.Count do
        with FListB do
        begin
          if IsSalePlanUsed(FieldByName('FInterID').AsString,
             FieldByName('FEntryID').AsString, FListC[nIdx]) then
          begin
            Inc(nIdx, 2);
            Continue;
          end;

          Values['billno'] := FieldByName('FBillNo').AsString;
          Values['inter'] := FieldByName('FInterID').AsString;
          Values['entry'] := FieldByName('FEntryID').AsString;

          Values['id'] := FieldByName('StockID').AsString;
          Values['name'] := FieldByName('StockName').AsString;
          Values['truck'] := FListC[nIdx];
          Inc(nIdx);
          
          if IsNumber(FListC[nIdx], True) then
               Values['value'] := FListC[nIdx]
          else Values['value'] := '0';
          Inc(nIdx);

          FListA.Add(EncodeBase64(FListB.Text));
          //new item
        end;
      finally
        Next;
      end;

      Result := FListA.Count > 0;
      if Result then
           FOut.FData := EncodeBase64(FListA.Text)
      else nData := '找到销售计划,但车辆信息无效,有效格式: 车牌 吨 车牌 吨.';
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;
{$ENDIF}

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.
