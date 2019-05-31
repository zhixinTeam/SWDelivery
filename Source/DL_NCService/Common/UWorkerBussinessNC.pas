{*******************************************************************************
  描述: 用友相关业务和数据处理
*******************************************************************************}
unit UWorkerBussinessNC;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, DB, ADODB, NativeXml, UBusinessWorker, StrUtils,
  UBusinessPacker, UBusinessConst, UMgrDBConn, UMgrParam, UFormCtrl, USysLoger,DateUtils,
  ZnMD5, ULibFun, USysDB, UMITConst, UMgrChannel, IdHTTP, Graphics, uNC_SOAP;

const
    FUrl= 'http://61.185.114.170:66/uapws/service/uapbd';

type

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FNCChannel: IDataReceivePortType;
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    FPackOut: Boolean;
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

  TBusWorkerBusinessNC = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerWebChatData;
    FOut: TWorkerBusinessCommand;
    //in out
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; override;
    //base funciton
    function UnPackIn(var nData: string): Boolean;
    procedure BuildDefaultXML;

    function ParseDefault(var nData: string): Boolean;
    function CheckNode(nNode: TXmlNode; nStr:string; var nData:string): Boolean;
    function CheckExists(const nPm:TChkParam; nID, nName:string;var nRe:string): Boolean;
    function GetCusId(const nPK:string): string;
    function GetSaleManId(const nPK:string): string;
    function GetMateId(const nPK:string): string;
    function CheckExistsPOrderBase(const nPK, nPKDtl, nOrderNo:string): Boolean;
    function GetZhiKaFreezeMoney(const nZhiKa, nCusId:string): Double;
    function CheckExistsZhika(const nZid, nZPk:string): Boolean;
    function MakeZhiKaLog(nID, nCusId, nDesc, nData: string): string;
    function GetOldOrderValue(const nid:string): Double;
    //***************基础数据处理（添加、修改、删除）***************************
    function EditCustomer(var nData: string): Boolean;
    //客户档案
    function EditProvider(var nData: string): Boolean;
    //供应商
    function EditUnit(var nData: string): Boolean;
    //计量单位
    function EditStocks(var nData: string): Boolean;
    //水泥品种
    function EditCusCredit(var nData: string): Boolean;
    //销售客户信用
    function EditPOrder(var nData: string): Boolean;
    //采购合同订单
    function EditZhiKa(var nData: string): Boolean;
    //销售纸卡
    function DoCHBill(var nData: string): Boolean;
    //销售单冲红
    function DoCHOrder(var nData: string): Boolean;
    //销售单冲红


    function AddSyncOrder(nOrderNo, nStatus, nProc, nErrMsg: string): Boolean;
    function AddSyncBill(nOrderNo, nStatus, nProc, nErrMsg: string): Boolean;

    function SendMsg(nPrmA, nPrmB, nPrmC:string):string;
    function SendOrderPoundInfo(var nData:string):boolean;
    //采购单
    //************************************************************
    function AddManualEventRecord(const nEID,nKey,nEvent:string;
             const nFrom: string = sFlag_DepBangFang ;
             const nSolution: string = sFlag_Solution_YN;
             const nDepartmen: string = sFlag_DepDaTing;
             const nReset: Boolean = False; const nMemo: string = ''): Boolean;
    function UPDateBillsBind(nBillNo, nNewZhiKaPK, nNewZhikaDtlPk: string; var nData:string): Boolean;
    //NC调价后根据新纸卡信息 更新旧纸卡现有未出厂订单信息
    function SendBillPoundInfo(var nData:string):boolean;
    //销售单
    function ChkNcStatus(var nData: string): Boolean;
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

uses IdSSLOpenSSL, IdGlobal, IdURI, uStrSub, UNCStatusChkThread;

//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;
  FNCChannel := nil;

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

//    {$IFDEF WXChannelPool}
//    FWXChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
//    if not Assigned(FWXChannel) then
//    begin
//      nData := '连接服务失败(NC Web Service No Channel).';
//      Exit;
//    end;
//
//    with FWXChannel^ do
//    begin
//      if not Assigned(FChannel) then
//        FChannel := CoReviceWSImplService.Create(FMsg, FHttp);
//      FHttp.TargetUrl := gSysParam.FSrvRemote;
//    end; //config web service channel
//    {$ENDIF}

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
      if FPackOut then
      begin
        WriteLog('打包');
        nData := FPacker.PackOut(FDataOut);
      end;

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
    {$IFDEF WXChannelPool}
    gChannelManager.ReleaseChannel(FNCChannel);
    {$ELSE}
    FNCChannel := nil;
    {$ENDIF}
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
class function TBusWorkerBusinessNC.FunctionName: string;
begin
  Result := sBus_BusinessNC;
end;

constructor TBusWorkerBusinessNC.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TBusWorkerBusinessNC.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TBusWorkerBusinessNC.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessNC;
  end;
end;

procedure TBusWorkerBusinessNC.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TBusWorkerBusinessNC.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerWebchatData;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessNC);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessNC);
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

function TBusWorkerBusinessNC.UnPackIn(var nData: string): Boolean;
var nNode, nTmp: TXmlNode;
    nx:string;
begin
  Result := False;
  // 如接口服务正常访问则挂起心跳线程
  if Not gTNCStatusChker.Suspended then
    gTNCStatusChker.Suspend;
    
  try
    try
      FPacker.XMLBuilder.Clear;

      if Pos('<?xml', nData)>0 then
        FPacker.XMLBuilder.ReadFromString(nData);
    except
      WriteLog('XML解析失败');
    end;
    //nNode := FPacker.XMLBuilder.Root.FindNode('Message');
    nNode := FPacker.XMLBuilder.Root;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('DataRow'))) then
    begin
      nData := '无效参数节点(Head.Message Null).';
      Exit;
    end;

    nTmp := nNode.FindNode('Message');
    nx:= nNode.AttributeByName['billtype'];
    //**********************
    if nNode.AttributeByName['billtype']='BD0001' then FIn.FCommand:= cBC_NCEditCustomer
    else
    if nNode.AttributeByName['billtype']='BD0002' then FIn.FCommand:= cBC_NCEditProvider
    else
    if nNode.AttributeByName['billtype']='BD0003' then FIn.FCommand:= cBC_NCEditUnit
    else
    if nNode.AttributeByName['billtype']='BD0004' then FIn.FCommand:= cBC_NCEditMate
    else
    if nNode.AttributeByName['billtype']='BD0005' then FIn.FCommand:= cBC_NCEditCredit
    else
    if nNode.AttributeByName['billtype']='BD0006' then FIn.FCommand:= cBC_NCEditOrder
    else
    if nNode.AttributeByName['billtype']='BD0007' then FIn.FCommand:= cBC_NCEditZhiKa
    else
    if nNode.AttributeByName['billtype']='BD0008' then FIn.FCommand:= cBC_NCCHBill
    else
    if nNode.AttributeByName['billtype']='BD0009' then FIn.FCommand:= cBC_NCCHOrder
    else
    begin
      nData := '无效的请求类型(Message.billtype error).';
    end;
  except on Ex : Exception do
    begin
      nData := 'XML解析失败:' + Ex.Message;
    end;
  end;
end;

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TBusWorkerBusinessNC.DoDBWork(var nData: string): Boolean;
begin
  if Pos('<?xml', nData)>0 then UnPackIn(nData);

  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;
  FPackOut := False;

  case FIn.FCommand of

      cBC_NCEditCustomer :
                            begin
                              Result := EditCustomer(nData);
                            end;
      cBC_NCEditProvider :
                            begin
                              Result := EditProvider(nData);
                            end;
      cBC_NCEditUnit     :
                            begin
                              Result := EditUnit(nData);
                            end;
      cBC_NCEditMate     :
                            begin
                              Result := EditStocks(nData);
                            end;
      cBC_NCEditCredit   :
                            begin
                              Result := EditCusCredit(nData);
                            end;
      cBC_NCEditOrder    :
                            begin
                              Result := EditPOrder(nData);
                            end;
      cBC_NCEditZhiKa    :
                            begin
                              Result := EditZhiKa(nData);
                            end;


      cBC_SendToNcOrdreInfo    :
                            begin
                              FPackOut := True;
                              Result := SendOrderPoundInfo(nData);
                            end;
                            
      cBC_SendToNcBillInfo    :
                            begin
                              FPackOut := True;
                              Result := SendBillPoundInfo(nData);
                            end;

      cBC_NcStatusChk         :
                            begin
                              FPackOut := True;
                              Result := ChkNcStatus(nData);
                            end;

      cBC_NCCHBill            :
                            begin
                              Result := DoCHBill(nData);
                            end;

      cBC_NCCHOrder           :
                            begin
                              Result := DoCHOrder(nData);
                            end;
   else
    begin
      Result := False;
      nData := '无效的请求类型(Message.billtype error).';
      nData := Format(nData, [FIn.FCommand]);
    end;
  end;
end;

function TBusWorkerBusinessNC.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
  Exit;
  BuildDefaultXML;

  with FPacker.XMLBuilder do
  begin
    //Root.NodeNewAtIndex(0, 'Info').WriteString(nData);
    nData:= Root.WriteToString;
  end;
end;

//Date: 2017-10-28
//Desc: 初始化XML参数
procedure TBusWorkerBusinessNC.BuildDefaultXML;
begin
  with FPacker.XMLBuilder do
  begin
    Clear;
    VersionString := '1.0';
    EncodingString:= 'utf-8';

    XmlFormat := xfCompact;
    Root.Name := 'Info';
    //first node
  end;
end;

//Date: 2017-10-26
//Desc: 解析默认数据
function TBusWorkerBusinessNC.ParseDefault(var nData: string): Boolean;
var nStr: string;
    nNode: TXmlNode;
begin
  with FPacker.XMLBuilder do
  begin
    Result:= False;
    nNode := Root.FindNode('DataRow');

    if not Assigned(nNode) then
    begin
      nData := '无效参数节点(WebService-Response.DataRow Is Null).';
      Exit;
    end;

    Result := True;
    //done
  end;
end;

function TBusWorkerBusinessNC.CheckNode(nNode: TXmlNode; nStr:string; var nData:string): Boolean;
begin
  Result := False;
  try
    with nNode do
    begin
      if NodeByName(nStr).ValueAsString = '' then
      begin
        nData := Format('节点 %s 值无效', [nStr]);
        Exit;
      end;
      Result := True;
    end;
  except on Ex : Exception do
    begin
      nData := Format('节点 %s 错误', [nStr]);
    end;
  end;
end;

function TBusWorkerBusinessNC.CheckExists(const nPm:TChkParam; nID, nName:string;var nRe:string): Boolean;
var nStr, nTip:string;
begin
  Result:= False;

  case nPm of
    PR_Stock    :
      begin
        nStr:= Format('Select * From Sys_Dict Where D_Name=''StockItem'' And D_ParamB=''%s'' And D_Value=''%s''',
                                  [nID, nName]);
        nTip:= '销售物料';
      end;

    PR_Provider :
      begin
        nStr:= Format('Select * From P_Provider Where P_ID=''%s'' And P_Name=''%s''',
                                  [nID, nName]);
        nTip:= '供应商';
      end;

    PR_Materails :
      begin
        nStr:= Format('Select * From P_Materails Where M_ID=''%s'' And M_Name=''%s''',
                                  [nID, nName]);
        nTip:= '采购物料';
      end;

    PR_SaleMan  :
      begin
        nStr:= Format('Select * From S_Salesman Where (S_ID=''%s'' OR S_PK=''%s'') And S_Name=''%s''',
                                  [nID, nID, nName]);
        nTip:= '业务员';
      end;

    PR_Cus      :
      begin
        nStr:= Format('Select * From S_Customer Where C_ID=''%s'' And C_Name=''%s''',
                                  [nID, nName]);

        nTip:= '销售客户档案';
      end;

    PR_CusID    :
      begin
        nStr:= Format('Select * From S_Customer Where C_ID=''%s'' ',
                                  [nID]);
        nTip:= '销售客户资金账户';
      end;
  end;

  try
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount>0 then
      begin
        Result:= True;
      end
      else nRe:= Format('参数 %s 信息 %s 、%s 无效', [nTip, nID, nName]);
    end;
  except
    nRe:= '检查信息项 '+nTip+' 时发生错误';
  end;
end;

function TBusWorkerBusinessNC.CheckExistsPOrderBase(const nPK, nPKDtl, nOrderNo:string): Boolean;
var nStr, nTip:string;
begin
  Result:= False;
  try
    nStr:= Format('Select * From P_OrderBase Where B_PKOrder=''%s'' And B_PKDtl=''%s'' And B_NCOrderNo=''%s'' ',
                                                        [nPK, nPKDtl, nOrderNo]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      Result:= RecordCount>0;
    end;
  except
  end;
end;

function TBusWorkerBusinessNC.GetMateId(const nPK:string): string;
var nStr, nTip:string;
begin
  Result:= '';
  try
    nStr:= Format('Select * From P_Materails Where M_Pk=''%s'' ', [nPK]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount>0 then
      begin
        Result:= FieldByName('M_ID').AsString;
      end;
    end;
  except
  end;
end;

//Date: 2018-11-25
//Desc: 客户档案
function TBusWorkerBusinessNC.EditCustomer(var nData: string): Boolean;
var nSql, nPK, nInitMoney: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【客户档案】入参：' + nData);
  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '无效参数节点(WebService-Message.DataRow Is Null).';
          Exit;
        end;

        FListA.Clear;
        //
        for nIdx:=0 to Root.NodeCount-1 do
        begin
          nNode := Root.Nodes[nIdx];  nSql:= '';
                   
          with nNode do
          begin
            if (Not CheckNode(nNode, 'pk_cus', nData)) or (Not CheckNode(nNode, 'cusid', nData)) or
                (Not CheckNode(nNode, 'cusname', nData))  then
            begin
              ExecSql:= False;
              Break;
            end;


            nPK:= NodeByName('pk_cus').ValueAsString;
            nInitMoney:= FloatToStr(Float2Float(NodeByName('initmoney').ValueAsFloatDef(0), cPrecision, False));
            //**************
            if NodeByName('proc').ValueAsString='add' then
            begin
              nSql:= Format(' Insert Into S_Customer(C_ID, C_Name, C_PY, C_Account, C_PKCus)Select top 1 ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' '+
                                        ' From Master..SysDatabases Where Not exists(Select * From S_Customer Where C_PKCus=''%s'') '  ,
                            [ NodeByName('cusid').ValueAsString,NodeByName('cusname').ValueAsString,GetPinYinOfStr(NodeByName('cusname').ValueAsString),
                            NodeByName('bankno').ValueAsString,NodeByName('pk_cus').ValueAsString,NodeByName('pk_cus').ValueAsString]);
              FListA.Add(nSql);
              ///**********
              nSql:= Format(' Insert Into Sys_CustomerAccount(A_CID,A_InitMoney,A_Date)Select top 1 ''%s'', ''%s'', GETDATE() ' +
                                        ' From Master..SysDatabases Where Not exists(Select * From Sys_CustomerAccount Where A_CID=''%s'') '  ,
                            [ NodeByName('cusid').ValueAsString ,nInitMoney, NodeByName('cusid').ValueAsString]);
              FListA.Add(nSql);
              ///**********
              if NodeByName('smanid').ValueAsString<>'' then
              begin
                try
                  nSql:= Format(' Insert Into S_Salesman(S_ID, S_Name, S_PY, S_InValid, S_PK)Select top 1 ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' ' +
                                              ' From Master..SysDatabases Where Not exists(Select * From S_Salesman Where S_ID=''%s'') '  ,
                                  [ NodeByName('smancode').ValueAsString, NodeByName('smanname').ValueAsString,
                                    GetPinYinOfStr(NodeByName('smanname').ValueAsString), 'N', NodeByName('smanid').ValueAsString,
                                    NodeByName('smancode').ValueAsString]);
                  FListA.Add(nSql);
                except
                end;
              end;
            end
            else if NodeByName('proc').ValueAsString='update' then
            begin
              nSql:= Format(' UPDate S_Customer Set C_Name=''%s'', C_PY=''%s'', C_Account=''%s'' Where C_PKCus=''%s'' ', [
                            NodeByName('cusname').ValueAsString,GetPinYinOfStr(NodeByName('cusname').ValueAsString),
                            NodeByName('bankno').ValueAsString,NodeByName('pk_cus').ValueAsString]);
              FListA.Add(nSql);
              //********
              nSql:= Format(' UPDate Sys_CustomerAccount Set A_InitMoney=''%s'' Where A_CID=''%s'' ', [
                            nInitMoney,NodeByName('cusid').ValueAsString]);
              FListA.Add(nSql);
              //********
              if NodeByName('smanid').ValueAsString<>'' then
              if NodeByName('smanid').ValueAsString<>'null' then
              begin
                if not CheckExists(PR_SaleMan, NodeByName('smanid').ValueAsString,NodeByName('smanname').ValueAsString, nData) then
                begin
                  try
                    nSql:= Format(' Insert Into S_Salesman(S_ID, S_Name, S_PY, S_InValid, S_PK)Select top 1 ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' ' +
                                              ' From Master..SysDatabases Where Not exists(Select * From S_Salesman Where S_ID=''%s'') '  ,
                                  [ NodeByName('smancode').ValueAsString, NodeByName('smanname').ValueAsString,
                                    GetPinYinOfStr(NodeByName('smanname').ValueAsString), 'N', NodeByName('smanid').ValueAsString,
                                    NodeByName('smancode').ValueAsString]);
                    FListA.Add(nSql);
                  except
                  end;
                end;

                nSql:= Format(' UPDate S_Salesman Set S_Name=''%s'' ,S_PY=''%s'' Where S_PK=''%s'' ', [
                              NodeByName('smanname').ValueAsString, GetPinYinOfStr(NodeByName('smanname').ValueAsString),
                              NodeByName('smanid').ValueAsString]);
                FListA.Add(nSql);
              end;
            end
            else if NodeByName('proc').ValueAsString='delete' then
            begin
              nSql:= Format(' Delete S_Customer Where C_PKCus=''%s'' ', [NodeByName('pk_cus').ValueAsString]);
              FListA.Add(nSql);
              nSql:= Format(' Delete Sys_CustomerAccount Where A_CID=''%s'' ', [NodeByName('cusid').ValueAsString]);
              FListA.Add(nSql);
            end
            else
            begin
              nData:= '节点 proc 无效的操作标示';
              ExecSql:= False;
              Break;
            end;
          end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('客户档案' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、解析XML数据发生错误';
        WriteLog('客户档案同步 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Date: 2018-11-25
//Desc:供应商档案
function TBusWorkerBusinessNC.EditProvider(var nData: string): Boolean;
var nSql, nPK: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【供应商档案】入参：' + nData);
  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '无效参数节点(WebService-Message.DataRow Is Null).';
          Exit;
        end;

        FListA.Clear;
        //
        for nIdx:=0 to Root.NodeCount-1 do
        begin
          nNode := Root.Nodes[nIdx];  nSql:= '';

          if (Not CheckNode(nNode, 'proid', nData)) or (Not CheckNode(nNode, 'pk_pro', nData)) or
                (Not CheckNode(nNode, 'proname', nData)) then
          begin
              ExecSql:= False;
              Break;
          end;
          //***********************
          with nNode do
          begin
            if NodeByName('proc').ValueAsString='add' then
            begin
              nSql:= Format(' Insert Into P_Provider(P_ID, P_Name, P_PY, P_PKPro) Select top 1 ''%s'', ''%s'', ''%s'', ''%s'' '+
                                        ' From Master..SysDatabases Where Not exists(Select * From P_Provider Where P_PKPro=''%s'') '  ,
                            [ NodeByName('proid').ValueAsString,NodeByName('proname').ValueAsString,GetPinYinOfStr(NodeByName('proname').ValueAsString),
                              NodeByName('pk_pro').ValueAsString,NodeByName('pk_pro').ValueAsString]);
              FListA.Add(nSql);
            end
            else if NodeByName('proc').ValueAsString='update' then
            begin
              nSql:= Format(' UPDate P_Provider Set P_Name=''%s'', P_PY=''%s'' Where P_PKPro=''%s'' ',  [
                            NodeByName('proname').ValueAsString,GetPinYinOfStr(NodeByName('proname').ValueAsString),
                            NodeByName('pk_pro').ValueAsString]);
              FListA.Add(nSql);
            end
            else if NodeByName('proc').ValueAsString='delete' then
            begin
              nSql:= Format(' Delete P_Provider Where P_PKPro=''%s'' ',  [NodeByName('pk_pro').ValueAsString]);
              FListA.Add(nSql);
            end
            else
            begin
              nData:= '节点 proc 无效的操作标示';
              ExecSql:= False;
              Break;
            end;

            nPK:= NodeByName('pk_pro').ValueAsString;
          end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('供应商档案' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、解析XML数据发生错误';
        WriteLog('供应商同步 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Date: 2018-11-25
//Desc:计量单位
function TBusWorkerBusinessNC.EditUnit(var nData: string): Boolean;
var nSql, nPK: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【计量单位】入参：' + nData);

  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '无效参数节点(WebService-Message.DataRow Is Null).';
          Exit;
        end;

        FListA.Clear;
        //
        for nIdx:=0 to Root.NodeCount-1 do
        begin
          nNode := Root.Nodes[nIdx];  nSql:= '';

          if (Not CheckNode(nNode, 'pk_unit', nData)) or (Not CheckNode(nNode, 'unitid', nData)) or
                (Not CheckNode(nNode, 'unitname', nData)) then
          begin
              ExecSql:= False;
              Break;
          end;
          //**************************
          with nNode do
          begin
            if NodeByName('proc').ValueAsString='add' then
            begin
              nSql:= Format(' Insert Into Sys_Dict (D_Name, D_Desc, D_Value, D_Memo, D_ParamB) Select top 1 ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' '+
                                 ' From Master..SysDatabases Where Not exists(Select * From Sys_Dict Where D_Name=''MaterailsItem'' And D_Memo =''%s'') '  ,
                            [ 'MaterailsItem','计量单位',NodeByName('unitname').ValueAsString,NodeByName('unitid').ValueAsString,
                              NodeByName('pk_unit').ValueAsString, NodeByName('unitid').ValueAsString ]);
              FListA.Add(nSql);
            end
            else if NodeByName('proc').ValueAsString='update' then
            begin
              nSql:= Format(' UPDate Sys_Dict Set D_Value=''%s'' Where D_Name=''MaterailsItem'' And D_Memo=''%s'' ',  [
                            NodeByName('unitname').ValueAsString,NodeByName('unitid').ValueAsString]);
              FListA.Add(nSql);
            end
            else if NodeByName('proc').ValueAsString='delete' then
            begin
              nSql:= Format(' Delete Sys_Dict Where D_Name=''MaterailsItem'' And D_Memo=''%s'' ',  [NodeByName('unitid').ValueAsString]);
              FListA.Add(nSql);
            end
            else
            begin
              nData:= '节点 proc 无效的操作标示';
              ExecSql:= False;
              Break;
            end;

            nPK:= NodeByName('pk_unit').ValueAsString;
          end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('计量单位档案' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、解析XML数据发生错误';
        WriteLog('计量单位同步 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Date: 2018-11-25
//Desc: 物料档案  水泥品种
function TBusWorkerBusinessNC.EditStocks(var nData: string): Boolean;
var nSql, nSaleSQL, nPK, nPageType: string;
    nIdx: Integer;
    nNode, nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【物料档案】入参：' + nData);
  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '无效参数节点(WebService-Message.DataRow Is Null).';
          Exit;
        end;

        FListA.Clear;
        //
        for nIdx:=0 to Root.NodeCount-1 do
        begin
          nNode := Root.Nodes[nIdx];  nSql:= '';

          if (Not CheckNode(nNode, 'pk_mate', nData)) or (Not CheckNode(nNode, 'package', nData)) or
                (Not CheckNode(nNode, 'mateid', nData)) or (Not CheckNode(nNode, 'matename', nData)) then
          begin
            ExecSql:= False;
            Break;
          end;
          //**************************
          with nNode do
          begin
            nNode.NodeByName('pk_mate').ValueAsString;
            //****************
            if NodeByName('proc').ValueAsString='add' then
            begin
              nSql:= Format(' Insert Into P_Materails (M_ID, M_Name, M_PY, M_Unit, M_PrePTime, M_IsSale, M_IsNei, M_Pk) '+
                                   ' Select top 1  ''%s'', ''%s'', ''%s'', ''吨'', ''365'', ''N'' , ''N'' , ''%s''  '+
                                   ' From Master..SysDatabases Where Not exists(Select * From P_Materails Where M_ID=''%s'' And M_Pk =''%s'') '  ,
                              [ NodeByName('mateid').ValueAsString,NodeByName('matename').ValueAsString,GetPinYinOfStr(NodeByName('matename').ValueAsString),
                                NodeByName('pk_mate').ValueAsString,
                                NodeByName('mateid').ValueAsString, NodeByName('pk_mate').ValueAsString ]);
              FListA.Add(nSql);
              //************************************  // 04 开头销售  01 采购类
              if LeftStr(NodeByName('mateid').ValueAsString,2)='04' then   // 04 开头销售  01 采购类
              begin
                nSaleSQL:= Format(' Insert Into Sys_Dict (D_Name, D_Desc, D_Value,D_Memo, D_ParamB) Select top 1  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' '+
                                   ' From Master..SysDatabases Where Not exists(Select * From Sys_Dict Where D_Name=''StockItem'' And D_ParamB =''%s'') '  ,
                              [ 'StockItem',NodeByName('pk_mate').ValueAsString,NodeByName('matename').ValueAsString,NodeByName('package').ValueAsString,
                                NodeByName('mateid').ValueAsString, NodeByName('mateid').ValueAsString ]);
                FListA.Add(nSaleSQL);
              end;
            end
            else if NodeByName('proc').ValueAsString='update' then
            begin
              if LeftStr(NodeByName('mateid').ValueAsString,2)='04' then   // 04 开头销售  01 采购类
              begin
                nSql:= Format(' UPDate Sys_Dict Set D_Value=''%s'' Where D_ParamB=''%s'' And D_Name=''StockItem'' ', [
                              NodeByName('matename').ValueAsString,NodeByName('mateid').ValueAsString]);
              end
              else
              begin
                nSql:= Format(' UPDate P_Materails Set M_Name=''%s'', M_PY=''%s'' Where M_ID=''%s'' And M_Pk=''%s'' ', [
                              NodeByName('matename').ValueAsString,GetPinYinOfStr(NodeByName('matename').ValueAsString),
                              NodeByName('mateid').ValueAsString, NodeByName('pk_mate').ValueAsString]);
              end;

              FListA.Add(nSql);
            end
            else if NodeByName('proc').ValueAsString='delete' then
            begin
              if LeftStr(NodeByName('mateid').ValueAsString,2)='04' then   // 04 开头销售  01 采购类
              begin
                nSql:= Format(' Delete Sys_Dict Where D_Name=''StockItem'' And D_ParamB=''%s'' ',  [NodeByName('mateid').ValueAsString]);
              end
              else
              begin
                nSql:= Format(' Delete P_Materails Where M_ID=''%s'' ',  [NodeByName('mateid').ValueAsString]);
              end;
              FListA.Add(nSql);
            end
            else
            begin
              nData:= '节点 proc 无效的操作标示';
              ExecSql:= False;
              Break;
            end;
          end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('物料档案' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、解析XML数据发生错误';
        WriteLog('物料同步 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Date: 2018-11-25
//Desc: 销售客户信用
function TBusWorkerBusinessNC.EditCusCredit(var nData: string): Boolean;
var nSql, nPK, nStr: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【客户信用】入参：' + nData);
  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '无效参数节点(WebService-Message.DataRow Is Null).';
          Exit;
        end;

        FListA.Clear;
        //
        for nIdx:=0 to Root.NodeCount-1 do
        begin
          nNode := Root.Nodes[nIdx];  nSql:= '';

          if (Not CheckNode(nNode, 'pk_credit', nData)) or (Not CheckNode(nNode, 'cusid', nData)) or
                (Not CheckNode(nNode, 'C_Money', nData)) then
          begin
            ExecSql:= False;
            Break;
          end;

          if not CheckExists(PR_CusID, nNode.NodeByName('cusid').ValueAsString,'', nData) then
          begin
            ExecSql:= False;
            Break;
          end;
          //*********************
          with nNode do
          begin
            nPK:= NodeByName('pk_credit').ValueAsString;

            nStr := 'Select * From Sys_CustomerCredit Where C_PkCdt='''+nPK+'''';

            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            begin
              if RecordCount>1 then Break;
            end;
            //*********************
            if NodeByName('proc').ValueAsString='add' then
            begin
              nStr := MakeSQLByStr([SF('C_CusID', NodeByName('cusid').ValueAsString),
                      SF('C_Money', Float2Float(NodeByName('money').ValueAsFloat, cPrecision, False), sfVal),
                      SF('C_Man', NodeByName('matename').ValueAsString),
                      SF('C_Date', DateTime2Str(Now), sfVal),
                      SF('C_End', NodeByName('enddate').ValueAsString),
                      SF('C_Verify', sFlag_Yes),
                      SF('C_VerMan', 'NC'),
                      SF('C_VerDate', DateTime2Str(Now), sfVal),
                      SF('C_Memo',NodeByName('matename').ValueAsString),
                      SF('C_PkCdt',NodeByName('pk_credit').ValueAsString)
                      ], sTable_CusCredit, '', True);
              FListA.Add(nStr);

              nStr := 'Update %s Set A_CreditLimit=A_CreditLimit+%.2f Where A_CID=''%s''';
              nStr := Format(nStr, [sTable_CusAccount, NodeByName('money').ValueAsFloat,
                                    NodeByName('cusid').ValueAsString]);
              FListA.Add(nStr);
            end
            else
            begin
              nData:= '节点 proc 无效的操作标示';
              ExecSql:= False;
              Break;
            end;
          end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('客户信用' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、解析XML数据发生错误';
        WriteLog('客户信用 出错：' + Ex.Message);
      end;
    end;
  finally

    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Date: 2018-11-25
//Desc: 采购订单
function TBusWorkerBusinessNC.EditPOrder(var nData: string): Boolean;
var nSql, nPK, nPKDtl, nOrderId, nNCOrderId, nProId, nProName, nCMan, nCTime, nProc, nMid, nFlag: string;
    nIdx, nRestValue, nLimValue, nWarnValue, nValue : Integer;
    nRoot, nDetails, nItem: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【采购订单】入参：' + nData);
  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '无效参数节点(WebService-Message.DataRow Is Null).';
          Exit;
        end;

        FListA.Clear;
        //***********
        try
          if (Not CheckNode(Root.Nodes[0], 'pk_order', nData)) or (Not CheckNode(Root.Nodes[0], 'order', nData)) or
                (Not CheckNode(Root.Nodes[0], 'code', nData)) or (Not CheckNode(Root.Nodes[0], 'name', nData)) or
                (Not CheckNode(Root.Nodes[0], 'proc', nData)) then
          begin
            ExecSql:= False;
            Exit;
          end;

          nPK     := Root.Nodes[0].NodeByName('pk_order').ValueAsString;
          nNCOrderId:= Root.Nodes[0].NodeByName('order').ValueAsString;     // NC 编号
          
          nProId  := Root.Nodes[0].NodeByName('code').ValueAsString;
          nProName:= Root.Nodes[0].NodeByName('name').ValueAsString;
          nCMan   := Root.Nodes[0].NodeByName('creator').ValueAsString;
          nCTime  := Root.Nodes[0].NodeByName('date').ValueAsString;
          nProc   := Root.Nodes[0].NodeByName('proc').ValueAsString;
          nFlag   := Root.Nodes[0].NodeByName('flag').ValueAsString;
          if nFlag='0' then nFlag:= 'Y' else nFlag:= 'N';

          if nProc<>'add' then
          if not CheckExists(PR_Provider, nProId, nProName, nData) then
          begin
            ExecSql:= False;
            Exit;
          end;
          //***********
          nDetails:= Root.FindNode('detail');

          for nIdx:=0 to nDetails.NodeCount-1 do
          begin
            nItem := nDetails.Nodes[nIdx];  nSql:= '';

            if (Not CheckNode(nItem, 'mid', nData)) or (Not CheckNode(nItem, 'mname', nData)) or
                  (Not CheckNode(nItem, 'value', nData)) or (Not CheckNode(nItem, 'dtl_pk', nData)) then
            begin
              ExecSql:= False;
              Exit;
            end;
            ///******************
            with nItem do
            begin
              nPKDtl:= NodeByName('dtl_pk').ValueAsString;
              if nPKDtl='' then
              begin
                nData:= '缺少节点 dtl_pk';
                Exit;
              end;
              
              nMid:= GetMateId(NodeByName('mid').ValueAsString);
              if not CheckExists(PR_Materails, nMid, NodeByName('mname').ValueAsString, nData) then
              begin
                WriteLog(nData);
                ExecSql:= False;
                Exit;
              end;
              ///************************************************************
              nValue    := Integer(Trunc(NodeByName('value').ValueAsFloatDef(0)));
              nRestValue:= nValue;
              nLimValue := nValue;
              nWarnValue:= 100; //Integer(Trunc(nValue*0.1));
              //*****************************
              if nProc='add' then
              begin
                if CheckExistsPOrderBase(nPK, nPKDtl, nNCOrderId)then
                begin
                  nSql:= Format(' UPDate P_OrderBase Set B_ProID=''%s'', B_ProName=''%s'', B_ProPY=''%s'', B_StockNo=''%s'', B_StockName=''%s'',B_Value=%d, ' +
                                                        'B_RestValue=%d, B_LimValue=%d, B_WarnValue=%d, B_BStatus=''%s'' ' +
                                ' Where B_NCOrderNo=''%s'' AND B_PKOrder=''%s'' AND B_PKdtl=''%s''',
                                [ nProId, nProName, GetPinYinOfStr(nProName), nMid, NodeByName('mname').ValueAsString,
                                  nValue, nRestValue, nLimValue, nWarnValue, nFlag, nNCOrderId, nPK, nPKDtl]);
                end
                else
                begin
                  Sleep(60);
                  nOrderId:= FormatDateTime('OyyyyMMddHHmmsszzz', Now);             // DL 编号
                  
                  nSql:= Format(' Insert Into P_OrderBase(B_ID, B_BStatus, B_ProID, B_ProName, B_ProPY, B_Man, B_Date, B_StockType, B_StockNo, B_StockName, '+
                                                         'B_Value, B_PKOrder,B_PKdtl, B_RestValue, B_LimValue, B_WarnValue, B_FreezeValue, B_SentValue,B_NCOrderNo) '+
                                    'Select top 1  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%d'', ''%s'', ''%s'', '+
                                                     '%d, %d, %d, 0, 0, ''%s'' '+
                                    'From Master..SysDatabases Where Not exists(Select * From P_OrderBase Where B_NCOrderNo=''%s'' And B_PKOrder =''%s'' And B_PKdtl =''%s'') ',
                                [ nOrderId , nFlag, nProId, nProName, GetPinYinOfStr(nProName), nCMan, nCTime,'S',nMid, NodeByName('mname').ValueAsString,
                                  nValue, nPK, nPKDtl, nRestValue, nLimValue, nWarnValue, nNCOrderId,
                                  nNCOrderId, nPK, nPKDtl ]);
                end;

                FListA.Add(nSql);
              end
              else if nProc='update' then
              begin
                nSql:= Format(' UPDate P_OrderBase Set B_ProID=''%s'', B_ProName=''%s'', B_ProPY=''%s'', B_StockNo=''%s'', B_StockName=''%s'',B_Value=%d, ' +
                                                      'B_RestValue=%d, B_LimValue=%d, B_WarnValue=%d, B_BStatus=''%s'' ' +
                              ' Where B_NCOrderNo=''%s'' AND B_PKOrder=''%s'' AND B_PKdtl=''%s''',
                              [ nProId, nProName, GetPinYinOfStr(nProName), nMid, NodeByName('mname').ValueAsString,
                                nValue, nRestValue, nLimValue, nWarnValue, nFlag, nNCOrderId, nPK, nPKDtl]);
                FListA.Add(nSql);
              end
              else if nProc='delete' then
              begin
                // 修改采购单为不可用状态
                nSql:= Format(' UPDate P_OrderBase Set B_BStatus=''N'' Where B_NCOrderNo=''%s'' AND B_PKOrder=''%s'' AND B_PKdtl=''%s'' ',
                              [nNCOrderId, nPK, nPKDtl]);
                FListA.Add(nSql);
              end
              else
              begin
                nData:= '节点 proc 无效的操作标示';
                ExecSql:= False;
                Break;
              end;
            end;
          end;
        except
          nData:= '解析XML信息项出错、缺少节点';
          ExecSql:= False;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('采购订单 ' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、服务器发生错误';
        WriteLog('采购订单 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

function TBusWorkerBusinessNC.GetCusId(const nPK:string): string;
var nStr, nTip:string;
begin
  Result:= '';
  try
    nStr:= Format('Select * From S_Customer Where C_PKCus=''%s'' ', [nPK]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount>0 then
      begin
        Result:= FieldByName('C_ID').AsString;
      end;
    end;
  except
  end;
end;

function TBusWorkerBusinessNC.GetSaleManId(const nPK:string): string;
var nStr, nTip:string;
begin
  Result:= '';
  try
    nStr:= Format('Select * From S_Salesman Where S_PK=''%s'' ', [nPK]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount>0 then
      begin
        Result:= FieldByName('S_ID').AsString;
      end;
    end;
  except
  end;
end;

function TBusWorkerBusinessNC.GetZhiKaFreezeMoney(const nZhiKa, nCusId:string): Double;
var nStr, nTip:string;
begin
  Result:= 0;
  try
    nStr:='Select L_CusID, L_ZhiKa, Sum((L_Price+ISNULL(L_YunFei, 0))*L_Value) FreezeMoney From S_Bill ' +
          'Left Join S_UPLoadOrderNc On N_OrderNo=L_ID  ' +
          'Where ((N_Type=''S'' And N_Status<>0) or L_Status<>''O'') And (L_CusID=''%s'' And L_ZhiKa=''%s'')  ' +
          'Group  by L_CusID, L_ZhiKa  ';

    nStr:= Format(nStr, [nZhiKa, nCusId]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount>0 then
      begin
        Result:= FieldByName('FreezeMoney').AsFloat;
      end;
    end;
  except
  end;
end;

function TBusWorkerBusinessNC.CheckExistsZhika(const nZid, nZPk:string): Boolean;
var nStr:string;
begin
  Result:= False;
  try
    nStr:= Format('Select * From S_ZhiKa Where Z_ID=''%s'' And Z_PKzk =''%s'' ',
                          [nZid, nZPk]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      Result:= RecordCount>0 ;
    end;
  except
  end;
end;

function TBusWorkerBusinessNC.GetOldOrderValue(const nid:string): Double;
var nStr:string;
begin
  Result:= 0;
  try
    nStr:= Format('Select isNull(O_Value, 0) O_Value From P_Order Where O_ID=''%s'' ', [nid]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      Result:= FieldByName('O_Value').AsFloat;
    end;
  except
  end;
end;

function TBusWorkerBusinessNC.MakeZhiKaLog(nID, nCusId, nDesc, nData: string): string;
var nStr:string;
begin
  nData:= StringReplace(nData, '''', '"', [rfReplaceAll]);
  Result:= Format(' Insert Into Sys_ZhiKaLog(Lg_Date,Lg_ZhiKaID,Lg_CusID ,Lg_Desc ,Lg_SourcXML) '+
                                    'Select Convert(Varchar(19),GetDate(),121), ''%s'', ''%s'', ''%s'', ''%s'' ',
                                    [nID,nCusId, nDesc, nData]);
end;

//Date: 2018-11-25
//Desc: 销售纸卡
function TBusWorkerBusinessNC.EditZhiKa(var nData: string): Boolean;
var nSql, nPK, nPKDtl, nZId, nZName, nCusId, nSmanPk, nSmanId, nSMan, nFixmoney, nXml, nStatus,
    nValidDay, nCMan, nCTime, nProc, nFlag, nType, nZ_InValid, nOldZid, nOldDtl, nIsTail: string;
    nPrice,nFlPrice,nValue,nYFPrice, nFreezeMoney, nFixmoneyNew:Double;
    nIdx: Integer;
    nRoot, nDetails, nItem: TXmlNode;
    ExecSql, NeedExecDtl, nInValid :Boolean;
begin
  WriteLog('【销售纸卡】入参：' + nData);
  nXml:= nData;
  try
    try
      Result := False;
      ExecSql:= True;   NeedExecDtl:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then
        begin
          WriteLog('【销售纸卡】：解析失败');
          Exit;
        end;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '无效参数节点(WebService-Message.DataRow Is Null).';    WriteLog('【销售纸卡】：'+nData);
          Exit;
        end;

        FListA.Clear;
        //***********
          if (Not CheckNode(Root.Nodes[0], 'pk_zk', nData)) or (Not CheckNode(Root.Nodes[0], 'zid', nData)) or
                (Not CheckNode(Root.Nodes[0], 'cusid', nData)) or (Not CheckNode(Root.Nodes[0], 'validdays', nData)) or
                (Not CheckNode(Root.Nodes[0], 'proc', nData)) then
          begin
            ExecSql:= False;
            WriteLog('【销售纸卡】：'+nData);
            Exit;
          end;

        nProc   := Root.Nodes[0].NodeByName('proc').ValueAsString;
        nPK     := Root.Nodes[0].NodeByName('pk_zk').ValueAsString;
        nZId    := Root.Nodes[0].NodeByName('zid').ValueAsString;
        nZName  := Root.Nodes[0].NodeByName('zname').ValueAsString;
        nCusId  := Root.Nodes[0].NodeByName('cusid').ValueAsString;
        nSmanPk := Root.Nodes[0].NodeByName('smanid').ValueAsString;
        nValidDay:= Root.Nodes[0].NodeByName('validdays').ValueAsString;
        if nValidDay='0' then
             nValidDay:= FormatDateTime('yyyy-MM-dd HH:mm:ss', IncYear(Now, 30))
        else nValidDay:= FormatDateTime('yyyy-MM-dd HH:mm:ss', IncDay(Now, StrToInt(nValidDay)));

        nFixmoney:= Root.Nodes[0].NodeByName('fixmoney').ValueAsString;
        nFixmoney:= StringReplace(nFixmoney, ',', '', [rfReplaceAll]);
        nFixmoney:= StringReplace(nFixmoney, '，', '', [rfReplaceAll]);
        nFixmoneyNew:= Float2Float(StrToFloatDef(nFixmoney, 0), cPrecision, False);
        nFixmoney:= FloatToStr(nFixmoneyNew);   //FormatFloat()

        nCMan   := Root.Nodes[0].NodeByName('creator').ValueAsString;
        nCTime  := Root.Nodes[0].NodeByName('date').ValueAsString;

        if Root.Nodes[0].NodeByName('issupporttail').ValueAsBoolDef(False) then
          nIsTail:= 'Y' else  nIsTail:= 'N';


        nFlag   := Root.Nodes[0].NodeByName('flag').ValueAsString;
        if nFlag='0' then
        begin
          nFlag:= sFlag_Yes;  nZ_InValid:= 'null';   nStatus:= '有效';
        end
        else
        begin
          nFlag:= sFlag_No;  nZ_InValid:= '''Y''';   nStatus:= '关闭';
        end;
        //**************************************************************************
        nCusId  := GetCusId(nCusId);
        if (not CheckExists(PR_CusID, nCusId, '', nData)) then
        begin
          WriteLog(nData);
          ExecSql:= False;
          Exit;
        end;
        nSman:= GetSaleManId(nSmanPk);
        if nSman<>'' then nSmanId:= nSman
        else nSmanId:= nSmanPk;
        //***********
        if nProc='add' then
        begin
          if not CheckExistsZhika(nZId, nPK) then
          begin
            //FListA.Add(' Delete S_ZhiKa Where Z_ID='''+ nZId +''' And Z_PKzk='''+nPK+'''');
            FListA.Add(' Delete S_ZhiKa Where Z_ID='''+ nZId +'''');

            nSql:= Format(' Insert Into S_ZhiKa(Z_ID, Z_Name, Z_PKzk, Z_Customer, Z_SaleMan, Z_Lading, Z_ValidDays, Z_Verified,'+
                                                'Z_YFMoney, Z_FixedMoney, Z_OnlyMoney, Z_Man, Z_Date, Z_IsSupportTail) '+
                                    'Select top 1  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %s, ''%s'', ''%s'', ''%s'', ''%s'' '+
                                    'From Master..SysDatabases Where Not exists(Select * From S_ZhiKa Where Z_ID=''%s'' And Z_PKzk =''%s'') '  ,
                              [ nZId, nZName, nPK, nCusId, nSmanId, 'T', nValidDay, nFlag, '0', nFixmoney, 'Y', nCMan, nCTime, nIsTail, nZId, nPK ]);
            FListA.Add(nSql);
            FListA.Add(' Delete S_ZhiKaDtl Where D_ZID='''+ nZId +'''');
            FListA.Add(MakeZhiKaLog(nZId, nCusId, Format('%s 为客户 %s 新增纸卡 %s  金额：%s  状态为: %s 支持尾单：%s', [nCMan, nCusId, nZId, nFixmoney, nStatus, nIsTail]), nXml));
          end
          else
          begin

            nSql:= Format(' UPDate S_ZhiKa Set Z_Name=''%s'', Z_Customer=''%s'', Z_SaleMan=''%s'', Z_ValidDays=''%s'', Z_Verified=''%s'', Z_InValid=%s, Z_FixedMoney=''%s'', ' +
                                                      'Z_Man=''%s'', Z_Date=''%s'', Z_IsSupportTail=''%s'' ' +
                              ' Where Z_ID=''%s'' AND Z_PKzk=''%s'' ',
                              [ nZName, nCusId, nSmanId, nValidDay, nFlag, nZ_InValid, nFixmoney, nCMan, nCTime, nIsTail, nZId, nPK]);
            FListA.Add(nSql);
            FListA.Add(' Delete S_ZhiKaDtl Where D_ZID='''+ nZId +'''');
            FListA.Add(MakeZhiKaLog(nZId, nCusId, Format('%s 为客户 %s 修改纸卡 %s  金额为：%s  状态为: %s 支持尾单：%s', [nCMan, nCusId, nZId, nFixmoney, nStatus, nIsTail]), nXml));
          end;
          //else NeedExecDtl:= False;
        end
        else if nProc='update' then
        begin
          ///////////////  获取未出厂单据金额以及出厂未上传、上传失败单据金额
          {nFreezeMoney:= GetZhiKaFreezeMoney(nZId, nCusId);
          if nFixmoneyNew<nFreezeMoney then
          begin
            nData:= '客户 ' + nCusId + ' 正在发货金额 '+floattoStr(nFreezeMoney)+'、该纸卡金额将被修改为 0 元';
            nFixmoney:= '0';
          end
          else nFixmoney:= FloatToStr(nFixmoneyNew-nFreezeMoney);  }

          nSql:= Format(' UPDate S_ZhiKa Set Z_Name=''%s'', Z_Customer=''%s'', Z_SaleMan=''%s'', Z_ValidDays=''%s'', Z_Verified=''%s'', Z_InValid=%s, Z_FixedMoney=''%s'', ' +
                                                    'Z_Man=''%s'', Z_Date=''%s'', Z_IsSupportTail=''%s'' ' +
                            ' Where Z_ID=''%s'' AND Z_PKzk=''%s'' ',
                            [ nZName, nCusId, nSmanId, nValidDay, nFlag, nZ_InValid, nFixmoney, nCMan, nCTime, nIsTail, nZId, nPK]);
          FListA.Add(nSql);
          FListA.Add(' Delete S_ZhiKaDtl Where D_ZID='''+ nZId +'''');
          FListA.Add(MakeZhiKaLog(nZId, nCusId, Format('%s 为客户 %s 修改纸卡 %s  金额为：%s  状态为: %s 支持尾单：%s', [nCMan, nCusId, nZId, nFixmoney, nStatus, nIsTail]), nXml));
        end
        else if nProc='delete' then
        begin
          // 修改纸卡为不可用状态
          nSql:= Format(' UPDate S_ZhiKa Set Z_InValid=''Y'' Where Z_ID=''%s'' AND Z_PKzk=''%s'' ', [nZId, nPK]);
          FListA.Add(nSql);
          FListA.Add(MakeZhiKaLog(nZId, nCusId, Format('%s 为客户 %s 停用纸卡 %s  状态为: %s 支持尾单：%s', [nCMan, nCusId, nZId, nStatus, nIsTail]), nXml));
        end
        else
        begin
          nData:= '节点 proc 无效的操作标示';
          ExecSql:= False;                  WriteLog('【销售纸卡】：'+nData);
          Exit;
        end;
        //***********
        nDetails:= Root.FindNode('detail');        //  处理纸卡品种明细

        if NeedExecDtl then
        for nIdx:=0 to nDetails.NodeCount-1 do
        begin
          nItem := nDetails.Nodes[nIdx];  nSql:= '';

          if (Not CheckNode(nItem, 'stockno', nData)) or (Not CheckNode(nItem, 'stockname', nData)) or
                   (Not CheckNode(nItem, 'price', nData)) then
          begin
            ExecSql:= False;                 WriteLog('【销售纸卡】：'+nData);
            Exit;
          end;

          with nItem do
          begin
            if not CheckExists(PR_Stock, NodeByName('stockno').ValueAsString, NodeByName('stockname').ValueAsString, nData) then
            begin
              ExecSql:= False;               WriteLog('【销售纸卡】：'+nData);
              Exit;
            end;

            if (nProc='add')or(nProc='update') then
            begin
              nType   := NodeByName('stockname').ValueAsString;
              if Pos('袋', nType)>0 then nType:= sFlag_Dai else nType:= sFlag_San;
              nPKDtl  := NodeByName('dtl_pk').ValueAsString;
              nPrice  := Float2Float(NodeByName('price').ValueAsFloatDef(0), cPrecision, False);
              nFlPrice:= NodeByName('flprice').ValueAsFloatDef(0);
              nValue  := NodeByName('value').ValueAsFloatDef(0);
              nYFPrice:= NodeByName('yunfei').ValueAsFloatDef(0);
              nInValid:= NodeByName('isadjprice').ValueAsBoolDef(False);

              //该订单与之前其他订单有关联关系 更改未出厂单据到新订单下
              try
                nOldZid := NodeByName('oldzid').ValueAsString;
                nOldDtl := NodeByName('olddtl_zk').ValueAsString;
                if (nOldZid<>'')and(nOldZid<>'null') then
                begin
                   nSql:= Format(' UPDate S_Bill Set L_Zhika=''%s'', L_PKzk=''%s'', L_PKDtl=''%s'', L_Price=%g, L_YunFei=%g '+
                                 ' Where L_OutFact is null And L_ZhiKa=''%s'' ' ,
                                [ nZId, nPK, nPKDtl, nPrice, nYFPrice, nOldZid]);
                  FListA.Add(nSql);
                  WriteLog(nSql);
                end;
              except
              end;

              if (nPrice>0)and(nFlPrice>=0)and(nValue>=0)and(nYFPrice>=0) then
              begin
                nSql:= Format(' Insert Into S_ZhiKaDtl(D_ZID,D_Type,D_StockNo,D_StockName,D_Price,D_Value,D_TPrice,D_FLPrice,D_YunFei,D_PkDtl) '+
                                    'Select top 1  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' '+
                                    'From Master..SysDatabases Where Not exists(Select * From S_ZhiKaDtl Where D_ZID=''%s'' And D_StockNo =''%s'') '  ,
                              [ nZId, nType, NodeByName('stockno').ValueAsString, NodeByName('stockname').ValueAsString, FloatToStr(nPrice),
                                FloatToStr(nValue), 'Y', FloatToStr(nFlPrice), FloatToStr(nYFPrice), nPKDtl,
                                nZId, NodeByName('stockno').ValueAsString]);
                FListA.Add(nSql);
                FListA.Add(MakeZhiKaLog(nZId, nCusId, Format('%s 为客户 %s 修改纸卡 %s 品种 %s  水泥、运费单价分别为：%s 、%s ',
                                    [nCMan, nCusId, nZId, NodeByName('stockname').ValueAsString, FloatToStr(nPrice), FloatToStr(nFlPrice)]), nXml));
              end
              else
              begin
                nData:= NodeByName('stockname').ValueAsString + ' 销售价、返利价或运费有误';
                ExecSql:= False;         WriteLog('【销售纸卡】：'+nData);
                Exit;
              end;

              if nInValid then
              begin
                nSql:= Format(' UPDate S_ZhiKa Set Z_InValid=''Y'' Where Z_ID=''%s'' AND Z_PKzk=''%s'' ', [nZId, nPK]);
                FListA.Add(nSql);
              end;
            end;
          end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('销售纸卡 ' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= 'XML解析失败';
        WriteLog('解析销售纸卡 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Date: 2019-05-16
//Desc: 销售单冲红
function TBusWorkerBusinessNC.DoCHBill(var nData: string): Boolean;
var nSql, nProc, nBillNo, nZhiKa, nStockNo, nStockName, nPK, nPKDtl, nCusID, nCusName,
    nFlag, nCreater, nHPK, nHDtlPK, nBillDate: string;
    nPrice, nYunFei, nValue, nBillMoney : Double;
    nIdx: Integer;
    nRoot, nDetails, nItem: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【销售发货单冲红】入参：' + nData);
  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        FListA.Clear;
        //**********************************************
        nProc     := Root.Nodes[0].NodeByName('proc').ValueAsString;
        nHPK      := Root.Nodes[0].NodeByName('cgeneralhid').ValueAsString;
        nBillDate := FormatDateTime('yyyy-MM-dd HH:mm:ss', Root.Nodes[0].NodeByName('dbilldate').ValueAsDateTimeDef(Now));
        nBillNo   := Root.Nodes[0].NodeByName('vbillcode').ValueAsString;
        nCusId    := Root.Nodes[0].NodeByName('custcode').ValueAsString;
        nCusName  := Root.Nodes[0].NodeByName('custname').ValueAsString;
        nCreater  := Root.Nodes[0].NodeByName('creator').ValueAsString;
        nFlag     := Root.Nodes[0].NodeByName('flag').ValueAsString;

        nDetails:= Root.FindNode('detail');        //  处理冲红单明细
        for nIdx:=0 to nDetails.NodeCount-1 do
        begin
            nItem := nDetails.Nodes[nIdx];  nSql:= '';
            with nItem do
            begin
              nHDtlPK := NodeByName('dtl_pk').ValueAsString;
              nZhiKa  := NodeByName('csaleorderno').ValueAsString;
              nPK     := NodeByName('pk_saleorder_h').ValueAsString;
              nPKDtl  := NodeByName('pk_saleorder_b').ValueAsString;
              nStockNo:= NodeByName('mcode').ValueAsString;
              nStockName:= NodeByName('mname').ValueAsString;
              nPrice  := Float2Float(NodeByName('nprice').ValueAsFloatDef(0), cPrecision, False);
              nYunFei := NodeByName('yunfei').ValueAsFloatDef(0);
              nValue  := NodeByName('nnetnum').ValueAsFloatDef(0);
            end;

            if (nProc='add')then
            begin
              nSql:= Format(' Insert Into S_Bill(L_ID,L_ZhiKa,L_Project,L_CusID,L_CusName,L_CusPY,L_StockNo,L_StockName,L_Value,L_Price,L_YunFei,L_ZKMoney,'+
                                                'L_Status,L_NextStatus,L_InTime,L_OutFact,L_Man,L_Date,L_PKzk,L_PKDtl,L_Area)'+
                                  'Select top 1 ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %g, %g, %g,''Y'',''O'','''', '+
                                               '''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''冲红或手工出库'' From Master..SysDatabases '+
                                  'Where Not exists(Select * From S_Bill Where L_ID=''%s'') ',
                            [nBillNo, nZhiKa, nHPK+'.'+nHDtlPK, nCusId, nCusName, GetPinYinOfStr(nCusName), nStockNo, nStockName, nValue, nPrice, nYunFei,
                            nBillDate,nBillDate,nCreater,nBillDate,nPK,nPKDtl, nBillNo]);
              FListA.Add(nSql);
            end
            else if (nProc='update')and(nFlag='1') then
            begin
              nSql:= Format(' Delete S_Bill Where L_ID=''%s'' ', [nBillNo]);
              FListA.Add(nSql);
            end
            else if (nProc='update') then
            begin
              nSql:= Format(' UPDate S_Bill Set L_ZhiKa=''%s'', L_CusID =''%s'', L_CusName =''%s'', L_CusPY =''%s'', L_StockNo =''%s'', L_StockName =''%s'', '+
                                               'L_Value =%g, L_Price =%g, L_YunFei =%g, L_InTime =''%s'', L_OutFact =''%s'', L_Man =''%s'', '+
                                               'L_Date =''%s'', L_PKzk =''%s'', L_PKDtl =''%s'' ' +
                            ' Where L_Project=''%s''  And L_ID=''%s'' ',
                           [nZhiKa, nCusId, nCusName, GetPinYinOfStr(nCusName), nStockNo, nStockName, nValue, nPrice, nYunFei,
                            nBillDate,nBillDate,nCreater,nBillDate,nPK,nPKDtl, nHPK+'.'+nHDtlPK, nBillNo]);
              FListA.Add(nSql);
            end
            else
            begin
              nData:= '节点 proc 无效的操作标示';
              ExecSql:= False;                  WriteLog('【销售单冲红】：'+nData);
              Exit;
            end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('销售单冲红：' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、解析XML数据发生错误';
        WriteLog('销售发货单冲红 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nHPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Date: 2019-05-16
//Desc: 采购单冲红
function TBusWorkerBusinessNC.DoCHOrder(var nData: string): Boolean;
var nSql, nProc, nBillNo, nZhiKa, nStockNo, nStockName, nPK, nPKDtl, nCusID, nCusName,
    nFlag, nCreater, nHPK, nHDtlPK, nBillDate: string;
    nPrice, nYunFei, nValue, nBillMoney : Double;
    nIdx: Integer;
    nRoot, nDetails, nItem: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('【采购单冲红】入参：' + nData);
  try
    try
      Result := False;   ExecSql:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        FListA.Clear;
        //**********************************************
        nProc     := Root.Nodes[0].NodeByName('proc').ValueAsString;
        nHPK      := Root.Nodes[0].NodeByName('pk_arriveorder').ValueAsString;
        nBillDate := FormatDateTime('yyyy-MM-dd HH:mm:ss', Root.Nodes[0].NodeByName('dbilldate').ValueAsDateTimeDef(Now));
        nBillNo   := Root.Nodes[0].NodeByName('vbillcode').ValueAsString;
        nCusId    := Root.Nodes[0].NodeByName('code').ValueAsString;
        nCusName  := Root.Nodes[0].NodeByName('name').ValueAsString;
        nCreater  := Root.Nodes[0].NodeByName('creator').ValueAsString;
        nFlag     := Root.Nodes[0].NodeByName('flag').ValueAsString;

        nDetails:= Root.FindNode('detail');        //  处理冲红单明细
        for nIdx:=0 to nDetails.NodeCount-1 do
        begin
            nItem := nDetails.Nodes[nIdx];  nSql:= '';

            with nItem do
            begin
              nHDtlPK := NodeByName('dtl_pk').ValueAsString;
              nZhiKa  := NodeByName('orderno').ValueAsString;
              nPK     := NodeByName('pk_order').ValueAsString;
              nPKDtl  := NodeByName('pk_order_b').ValueAsString;
              nStockNo:= NodeByName('mcode').ValueAsString;
              nStockName:= NodeByName('mname').ValueAsString;
              nPrice  := Float2Float(NodeByName('nprice').ValueAsFloatDef(0), cPrecision, False);
              nValue  := NodeByName('nnetnum').ValueAsFloatDef(0);
            end;

            if (nProc='add')then
            begin
              nSql:= Format(' Insert Into P_Order(O_ID,O_BID,O_Project,O_ProID,O_ProName,O_ProPY,O_StockNo,O_StockName,O_Value,O_Man,O_Date,O_Memo)'+
                                  'Select top 1 ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %g, '+
                                               '''%s'', ''%s'', ''采购单冲红'' From Master..SysDatabases '+
                                  'Where Not exists(Select * From P_Order Where O_ID=''%s'') ',
                            ['CH'+nBillNo, nZhiKa, nHPK+'.'+nHDtlPK, nCusId, nCusName, GetPinYinOfStr(nCusName), nStockNo, nStockName, nValue,
                            nCreater,nBillDate, 'CH'+nBillNo]);
              FListA.Add(nSql);

              nSql:= Format(' Insert Into P_OrderDtl(D_ID,D_OID,D_Project,D_ProID,D_ProName,D_ProPY,D_StockNo,D_StockName,D_Status,D_NextStatus,'+
                                                    'D_InTime,D_Value,D_KZValue,D_YSResult,D_Memo)'+
                                  'Select top 1 ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''O'', '''', ''%s'', %g, 0,'+
                                                '''Y'',''采购单冲红'' From Master..SysDatabases '+
                                  'Where Not exists(Select * From P_OrderDtl Where D_ID=''%s'') ',
                            [nBillNo, 'CH'+nBillNo, nHPK+'.'+nHDtlPK, nCusId, nCusName, GetPinYinOfStr(nCusName), nStockNo, nStockName, nBillDate, nValue, nBillNo]);
              FListA.Add(nSql);

              nSql:= Format(' UPDate P_OrderBase Set B_SentValue=B_SentValue+(%g)  Where B_NCOrderNo=''%s''  ', [nValue, nZhiKa]);
              FListA.Add(nSql);
            end
            else if (nProc='update')and(nFlag='1') then
            begin
              nSql:= Format(' Delete P_Order Where O_ID=''%s'' ', ['CH'+nBillNo]);
              FListA.Add(nSql);

              nSql:= Format(' Delete P_OrderDtl Where D_ID=''%s'' ', [nBillNo]);
              FListA.Add(nSql);

              nSql:= Format(' UPDate P_OrderBase Set B_SentValue=B_SentValue-(%g)  Where B_NCOrderNo=''%s''  ',
                                  [nValue, nZhiKa]);
              FListA.Add(nSql);
            end
            else if (nProc='update') then
            begin
              nSql:= Format(' UPDate P_OrderBase Set B_SentValue=B_SentValue+((%g)-(%g))  Where B_NCOrderNo=''%s''  ',
                                  [nValue, GetOldOrderValue('CH'+nBillNo), nZhiKa]);
              FListA.Add(nSql);

              nSql:= Format(' UPDate P_Order Set O_BID=''%s'', O_Project=''%s'', O_ProID =''%s'', O_ProName =''%s'', O_ProPY =''%s'', O_StockNo =''%s'', O_StockName =''%s'', '+
                                               'O_Value =%g, O_Date =''%s'' ' +
                            ' Where O_Project=''%s'' And O_ID=''%s'' ',
                           [nZhiKa,nHPK+'.'+nHDtlPK, nCusId, nCusName, GetPinYinOfStr(nCusName), nStockNo, nStockName, nValue, nBillDate, nHPK+'.'+nHDtlPK, 'CH'+nBillNo]);
              FListA.Add(nSql);

              nSql:= Format(' UPDate P_OrderDtl Set D_Project=''%s'', D_ProID =''%s'', D_ProName =''%s'', D_ProPY =''%s'', D_StockNo =''%s'', D_StockName =''%s'', '+
                                               'D_Value =%g, D_InTime =''%s'' ' +
                            ' Where D_Project=''%s'' And D_ID=''%s'' ',
                           [nHPK+'.'+nHDtlPK, nCusId, nCusName, GetPinYinOfStr(nCusName), nStockNo, nStockName, nValue, nBillDate, nHPK+'.'+nHDtlPK, nBillNo]);
              FListA.Add(nSql);
            end
            else
            begin
              nData:= '节点 proc 无效的操作标示';
              ExecSql:= False;                  WriteLog('【采购单冲红】：'+nData);
              Exit;
            end;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('采购单冲红：' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '处理成功';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '处理失败';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '操作失败、解析XML数据发生错误';
        WriteLog('采购单冲红 出错：' + Ex.Message);
      end;
    end;
  finally
    BuildDefaultXML;
    with FPacker.XMLBuilder.Root.NodeNewAtIndex(0, 'DataRow') do
    begin
      WriteString('Pk', nHPK);
      WriteString('Message', nData);

      if Result then
        WriteInteger('Status', 1)
      else WriteInteger('Status', -1);
    end;
    nData:= FPacker.XMLBuilder.WriteToString;

    Result := True;
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

function TBusWorkerBusinessNC.SendMsg(nPrmA, nPrmB, nPrmC:string):string;
function GetNewOPer : TIdHTTP;
var FidHttp : TIdHTTP;
    FidSSL  : TIdSSLIOHandlerSocketOpenSSL;
begin
  try
    FidHttp := TIdHTTP.Create(nil);
    FidSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    if (FidHttp <> nil) and (FidSSL <> nil) then
    begin
      FidHttp.IOHandler := FidSSL;
      Result:= FidHttp;
    end;
  except
    Result:= nil;
    //Exception.ThrowOuterException(Exception.Create('IdHttp Init Error'));
  end;
end;

var nFOPer : TIdHTTP;
    nParam : string;
    wParam : TStrings;
    nResponse : WideString;
begin
  nFOPer:= nil;
  try
    nFOPer:= GetNewOPer;
    wParam:= TStringList.Create();
    //*******************************************************  <![CDATA[%s>
    wParam.Clear;

    nParam:= '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:idat="http://service.ncitf.itf.nc/IDataReceive">' +
             '   <soapenv:Header/>' +
             '   <soapenv:Body>' +
             '      <idat:receiveData>' +
             '         <string>%s</string>' +
             '         <string1>%s</string1>' +
             '         <string2>%s</string2>' +
             '      </idat:receiveData>' +
             '   </soapenv:Body>' +
             '</soapenv:Envelope>';

    nParam:= Format(nParam, [nPrmA, nPrmB, nPrmC]);
    wParam.Add(nParam);
    //*******************************************
    nFOPer.Request.Clear;
    nFOPer.ConnectTimeout := 5000*1000;
    nFOPer.ReadTimeout := 5000*1000;
    nFOPer.Request.UserAgent := 'Mozilla/5.0';
    nFOPer.Request.Accept := 'application/json, text/javascript, */*; q=0.01';
    //nFOPer.Request.AcceptLanguage := 'zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3';
    nFOPer.Request.ContentType:= 'Text/XML; charset=UTF-8';
    nFOPer.Request.Connection := 'keep-alive';
    nFOPer.HTTPOptions:= [hoInProcessAuth, hoKeepOrigProtocol];

    try
      nResponse:= nFOPer.Post(FUrl, wParam);
    except on Ex:Exception do
      raise Ex
    end;
    nResponse:= StringReplace(nResponse, '&lt;', '<', [rfReplaceAll]);
    nResponse:= GetLeftStr('</return>', GetRightStr('<return>', nResponse));
  finally
    nFOPer.Disconnect;
    wParam.Free;
    nFOPer.Free;
  end;
end;

//Desc: 插入待上传订单 或失败订单
function TBusWorkerBusinessNC.AddSyncOrder(nOrderNo, nStatus, nProc, nErrMsg: string): Boolean;
var nstr, nNum : string;
begin
  if nStatus='1' then nNum:= '6'
  else nNum:= '0';

  nStr := 'Insert Into S_UPLoadOrderNc(N_OrderNo, N_Type, N_Status, N_Proc,N_ErrorMsg,N_SyncNum)'+
              'Select ''$OrderNo'',''$Type'',''$Status'',''$Proc'',''$Msg'',''$Num'' ' +
              'Where  Not exists(Select * From S_UPLoadOrderNc Where N_OrderNo=''$OrderNo'' And N_Type =''$Type'' ' +
              ' And N_Status =''$Status'' And N_Proc =''$Proc'') ';
  nStr := MacroValue(nStr, [MI('$OrderNo', nOrderNo), MI('$Type', 'P'), MI('$Msg', nErrMsg), MI('$Status', nStatus),
                            MI('$Proc', nProc), MI('$Num', nNum)]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

function TBusWorkerBusinessNC.AddSyncBill(nOrderNo, nStatus, nProc, nErrMsg: string): Boolean;
var nstr, nNum : string;
begin
  if nStatus='1' then nNum:= '6'
  else nNum:= '0';

  nStr := 'Insert Into S_UPLoadOrderNc(N_OrderNo, N_Type, N_Status, N_Proc,N_ErrorMsg,N_SyncNum)'+
              'Select ''$OrderNo'',''$Type'',''$Status'',''$Proc'',''$Msg'',''$Num'' ' +
              'Where  Not exists(Select * From S_UPLoadOrderNc Where N_OrderNo=''$OrderNo'' And N_Type =''$Type'' ' +
              ' And N_Status =''$Status'' And N_Proc =''$Proc'') ';
  nStr := MacroValue(nStr, [MI('$OrderNo', nOrderNo), MI('$Type', 'S'), MI('$Msg', nErrMsg), MI('$Status', nStatus),
                            MI('$Proc', nProc), MI('$Num', nNum)]);
  gDBConnManager.WorkerExec(FDBConn, nStr);

  nStr := 'UPDate S_UPLoadOrderNc Set N_ErrorMsg=''$Msg'' Where N_OrderNo=''$OrderNo'' And N_Proc=''$Proc'' ';
  nStr := MacroValue(nStr, [MI('$OrderNo', FListA.Values['ID']), MI('$Msg', nErrMsg),MI('$Proc', nProc)]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;


//Desc: 采购单过磅
function TBusWorkerBusinessNC.SendOrderPoundInfo(var nData: string): Boolean;
var nStr, nRe: string;
    nRoot, nNode : TXmlNode;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := '<?xml version="1.0" encoding="UTF-8"?>' +
          '<Message billtype="BS0001">' +
          ' <DataRow> ' +
          '    <proc>%s</proc>' +
          '    <pk_org>%s</pk_org>' +
          '    <dbilldate>%s</dbilldate>' +
          '    <pk_stordoc>%s</pk_stordoc>' +
          '    <pk_supplier>%s</pk_supplier>' +
          '    <creator>%s</creator>' +
          '    <creationtime>%s</creationtime>' +
          '    <dlbillcode>%s</dlbillcode>' +
          '    <dlhid>%s</dlhid>' +
          '    <pk_material>%s</pk_material>' +
          '    <nnum>%s</nnum>' +
          '    <dlbid>%s</dlbid>' +
          '    <corderno>%s</corderno>' +
          '    <corderbid>%s</corderbid>' +
          '    <ncoalnum>%s</ncoalnum>' +
          '    <pk_carrier>%s</pk_carrier>' +
          '    <dcoaltime>%s</dcoaltime> ' +
          '    <dgrosstime>%s</dgrosstime> ' +
          '    <nsundries>%s</nsundries> ' +
          '    <ngrossnum>%s</ngrossnum> ' +
          '    <ntarenum>%s</ntarenum> ' +
          '    <cardno>%s</cardno> ' +
          '    <dr>0</dr> ' +
          ' </DataRow>' +
          '</Message>';

  nStr := Format(nStr, [FListA.Values['Proc'], gSysParam.FFactID,
                  FListA.Values['OutFact'], FListA.Values['Stordoc'],
                  FListA.Values['ProPk'], FListA.Values['creator'],
                  FListA.Values['OutFact'], FListA.Values['OID'], FListA.Values['ORID'],
                  FListA.Values['StockPK'], FListA.Values['Value'],FListA.Values['DID'],
                  FListA.Values['BID'], FListA.Values['PkDtl'], FListA.Values['KFValue'],
                  FListA.Values['CarrierPK'], FListA.Values['KFTime'], FListA.Values['MDate'],
                  FListA.Values['KZValue'], FListA.Values['MValue'], FListA.Values['PValue'],
                  FListA.Values['TruckNo']  ]);
  WriteLog('采购单上传NC：'+nStr);
  WriteLog('采购单上传NC：'+gSysParam.FSrvRemote);
  try
    try
      try
        FNCChannel := GetIDataReceivePortType(False, gSysParam.FSrvRemote);
        nStr:= FNCChannel.receiveData('BS0001', 'null', nStr);
        WriteLog('NC返回：'+nStr);
        //nStr := SendMsg('BS0001','null', nStr);
        //nStr:= '<?xml version="1.0" encoding="utf-8"?><Info><DataRow><Pk>0</Pk><Message>订单已审核不能删除</Message><Status>-1</Status></DataRow></Info> ';
        //nStr:= gSysParam.FRe;
      except on Ex:Exception do
        begin
          AddSyncOrder(FListA.Values['DID'],'1',FListA.Values['Proc'],Ex.Message);

          gSysParam.FErrorNum:= gSysParam.FErrorNum + 1;
          if gSysParam.FErrorNum>=10 then
            if gTNCStatusChker.Suspended then gTNCStatusChker.Resume;

          nData:= '访问NC出错：'+ Ex.Message;
          WriteLog(nData);
          Exit;
        end;
      end;

      try
        gSysParam.FErrorNum:= 0;
        with FPacker.XMLBuilder do
        begin
          ReadFromString(nStr);
          if not ParseDefault(nData) then
          begin
            WriteLog('推送失败:'+nData+' 应答:'+nStr);
            Exit;
          end;

          nRoot := Root.FindNode('DataRow');
          if not Assigned(nRoot) then
          begin
            nData := '返回内容有误缺少节点 DataRow.';
            Exit;
          end;

          nNode := Root.Nodes[0];
          with nNode do
          begin
            if NodeByName('Status').ValueAsString='-1' then
            begin
              nData := Format('操作失败：%s %s', [ FListA.Values['DID'],
                                            NodeByName('Message').ValueAsString]);
            end
            else Result:= True;
          end;
        end;
      except
        on Ex:Exception do
        begin
          WriteLog('推送采购出厂单解析返回内容出错：'+ Ex.Message);
        end;
      end;
    except
      on Ex:Exception do
      begin
        WriteLog('访问NC接口出错：'+ Ex.Message);
      end;
    end;
  finally
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

function TBusWorkerBusinessNC.AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom,nSolution,nDepartmen: string;
 const nReset: Boolean; const nMemo: string): Boolean;
var nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  if Trim(nSolution) = '' then
  begin
    WriteLog('请选择处理方案.');
    Exit;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '事件记录:[ %s ]已存在';
    WriteLog(Format(nStr, [nEID]));

    if not nReset then Exit;
    nUpdate := True;
  end
  else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx

  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

////  NC调价后根据新纸卡信息 更新旧纸卡现有未出厂订单信息
function TBusWorkerBusinessNC.UPDateBillsBind(nBillNo, nNewZhiKaPK, nNewZhikaDtlPk: string; var nData:string): Boolean;
var nStr, nTruck, nOldZhika, nOldDtlPk, nNewZID: string;
    nIdx : Integer;
    nPrice, nYunFei : Double;
begin
  Result:= False;  FListA.Clear;
  //**************************
  nStr := 'Select * From S_Bill Where L_ID=''' + nBillNo + '''';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '更新订单信息失败, 未找到销售订单 ' + nBillNo;
      WriteLog(nData);
      Exit;
    end;
    
    nOldZhiKa := FieldByName('L_Zhika').AsString;
    nOldDtlPk := FieldByName('L_PKDtl').AsString;
  end;

  // 更新旧纸卡订单绑定关系到新纸卡下
  // 获取新纸卡 单价 、运费
  nStr := 'Select Z_ID, D_StockNo, D_StockName, Z_PKzk, IsNull(Z_FixedMoney, 0) Z_FixedMoney, ' +
                 'D_Price, IsNull(D_YunFei, 0) D_YunFei, D_PKDtl  From S_ZhiKa ' +
          'Left  Join  S_ZhiKaDtl On Z_ID=D_ZID   ' +
          'Where Z_PKzk=''%s'' And D_PKDtl=''%s''  ';
  nStr := Format(nStr, [nNewZhiKaPk, nNewZhikaDtlPk]);
  //xxxxx
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 0 then
    begin
      nData:= format('未能获取到新纸卡 PK %s 信息、更改绑定关系失败', [nNewZhiKaPk]);
      WriteLog(nData);
      Exit;
    end
    else
    begin
      while not Eof do
      begin
        nNewZID := FieldByName('Z_ID').AsString;
        nPrice  := FieldByName('D_Price').AsFloat;
        nYunFei := FieldByName('D_YunFei').AsFloat;

                // 更新旧纸卡来源纸卡信息、价格、运费等
        nStr := 'UPDate S_Bill Set L_ZhiKa=''%s'', L_Price=%g, L_YunFei=%g, L_Pkzk=''%s'', L_PkDtl=''%s''  ' +
                'Where L_ZhiKa=''%s'' And L_PKDtl=''%s'' And L_OutFact Is Null And l_Status<>''O'' ';
        nStr := Format(nStr, [nNewZID, nPrice, nYunFei, nNewZhiKaPK, nNewZhikaDtlPk, nOldZhika, nOldDtlPk]);
                //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx := 0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      WriteLog('更新纸卡绑定关系：' + FListA[nIdx]);
    end;

    FDBConn.FConn.CommitTrans;
    nData := '处理成功';
    Result:= True;
  except
    FDBConn.FConn.RollbackTrans;
    nData := '处理失败';
  end;
end;

//Desc: 销售单信息
function TBusWorkerBusinessNC.SendBillPoundInfo(var nData: string): Boolean;
var nStr, nTime, nProc, nZhiKaNo, nZhiKaPK, nZhiKaDtlPK, nCreator, nHid, nBid : string;
    nCard, nErrMsg, nTruckNo: string;
    nZhika, nMTime, nMValue, nPValue, nValue : string;
    nRoot, nNode : TXmlNode;
begin
  Result := False;   FOut.FExtParam:= '';
  try
    FListA.Text := PackerDecodeStr(FIn.FData);
    nCard:= FListA.Values['Card'];

    nStr:= 'Select *, (L_MValue-L_PValue) ValueX  From S_Bill Where L_ID='''+FListA.Values['ID']+'''';
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount= 1 then
      begin
        nTime := FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('L_Date').AsDateTime);
        nZhiKaPK   := FieldByName('L_PKzk').AsString;
        nZhiKaDtlPK:= FieldByName('L_PkDtl').AsString;
        nBid:= FieldByName('R_ID').AsString;
        nCreator:= FieldByName('L_Man').AsString;

        nZhika := FieldByName('L_ZhiKa').AsString;
        nMTime := FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('L_MDate').AsDateTime);
        nMValue:= FieldByName('L_MValue').AsString;
        nPValue:= FieldByName('L_PValue').AsString;
        nValue := FieldByName('L_Value').AsString;
        nTruckNo:= FieldByName('L_Truck').AsString;

        {$IFDEF BasisWeightWithPM}
        if FieldByName('L_IsBasisWeightWithPM').AsString='Y' then
          nValue := FieldByName('ValueX').AsString;
        {$ENDIF}

        if FIn.FExtParam='' then
        begin
          if FieldByName('L_OutFact').AsDateTime<IncYear(Now) then
            FIn.FExtParam:= FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('L_MDate').AsDateTime)
          else FIn.FExtParam:= FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('L_OutFact').AsDateTime);
        end;
      end
      else
      begin
        nData:= '未找到销售订单 '+FListA.Values['ID'];
        Exit;
      end;
    end;

    nStr:= 'Select * From S_ZhiKa Where Z_ID='''+nZhika+'''';
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount = 1 then
      begin
        nHid    := FieldByName('R_ID').AsString;
        nZhiKaNo:= FieldByName('Z_ID').AsString;
      end
      else
      begin
        nData:= '未找到订单 '+FListA.Values['ID'] + ' 的纸卡创建信息';
        Exit;
      end;
    end;

    nProc:= FListA.Values['proc'];
    if (nCard<>'') then nProc:= 'add';
    if (nProc='') then
    begin
      nData:= '订单 '+FListA.Values['ID'] + ' 无法推送、缺少操作标示';
      Exit;
    end;
    //***********************************************************
    nStr := '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Message billtype="BS0002">' +
            ' <DataRow> ' +
            '   <proc>%s</proc> ' +
            '    <pk_org>%s</pk_org> ' +
            '    <dbilldate>%s</dbilldate> ' +
            '    <saleorderno>%s</saleorderno> ' +
            '    <csaleorderhid>%s</csaleorderhid> ' +
            '    <csaleorderbid>%s</csaleorderbid> ' +
            '    <creator>%s</creator> ' +
            '    <creationtime>%s</creationtime> ' +
            '    <dlbillcode>%s</dlbillcode> ' +
            '    <dlhid>%s</dlhid> ' +
            '    <dlbid>%s</dlbid> ' +
            '    <nnum>%s</nnum> ' +
            '    <dgrosstime>%s</dgrosstime> ' +
            '    <ngrossnum>%s</ngrossnum> ' +
            '    <ntarenum>%s</ntarenum> ' +
            '    <cardno>%s</cardno> ' +
            '    <dr>0</dr> ' +
            ' </DataRow> ' +
            '</Message>';
                                                    //nTime
    nStr := Format(nStr, [nProc, gSysParam.FFactID, FIn.FExtParam, nZhiKaNo, nZhiKaPK, nZhiKaDtlPK,
                           nCreator, FIn.FExtParam, FListA.Values['ID'],
                          nHid, nBid, nValue,
                          nMTime, nMValue, nPValue, nTruckNo]);
    WriteLog('销售单上传NC：'+nStr);
    WriteLog('销售单上传NC：'+gSysParam.FSrvRemote);
    try
      try
        FNCChannel := GetIDataReceivePortType(False, gSysParam.FSrvRemote);
        nStr := FNCChannel.receiveData('BS0002', 'null', nStr);
        //nStr := SendMsg('BS0002','null', nStr);
        //nStr:= '<?xml version="1.0" encoding="utf-8"?><Info><DataRow><Pk>1001ZZ100000000ETVWR</Pk><Message>未知错误</Message><Status>-1</Status></DataRow></Info> ';
        //nStr:= gSysParam.FRe;
        //nstr:= '<?xml version="1.0" encoding="UTF-8"?><Info><DataRow><Pk>null</Pk><Message>客户编码【C0200512】,客户名称【西咸新区平鑫尔建材有限公司】超信用金额175103.15000000，禁止继续操作！</Message><Status>-1</Status></DataRow></Info>'
      except on Ex:Exception do
        begin
          AddSyncBill(FListA.Values['ID'],'1',nProc,Ex.Message);

          gSysParam.FErrorNum:= gSysParam.FErrorNum + 1;
          if gSysParam.FErrorNum>=10 then
            if gTNCStatusChker.Suspended then gTNCStatusChker.Resume;

          nData:= '访问NC出错：'+ Ex.Message;
          WriteLog(nData);
          Exit;
        end;
      end;

      WriteLog('NC返回：'+nStr);
      try
        gSysParam.FErrorNum:= 0;
        with FPacker.XMLBuilder do
        begin
          ReadFromString(nStr);
          if not ParseDefault(nData) then Exit;

          nRoot := Root.FindNode('DataRow');
          if not Assigned(nRoot) then
          begin
            nData := '销售单返回内容有误缺少节点 DataRow.';
            Exit;
          end;

          nNode := Root.Nodes[0];
          with nNode do
          begin
            if NodeByName('Status').ValueAsString='-1' then
            begin
              nErrMsg:= StringReplace(NodeByName('Message').ValueAsString, #13, '', [rfReplaceAll]);
              nErrMsg:= StringReplace(nErrMsg, #10, '', [rfReplaceAll]);
              nData := Format('销售单 %s 操作失败：%s', [ FListA.Values['ID'], nErrMsg]);

              if Pos('<PkNew>', nStr)>0 then
              begin
                if (NodeByName('PkNew').ValueAsString <> '') and
                   (NodeByName('PkBNew').ValueAsString <> '') then
                begin
                  Result := UPDateBillsBind(FListA.Values['ID'], NodeByName('PkNew').ValueAsString,
                                                             NodeByName('PkBNew').ValueAsString, nData);
                  nData := 'PriceIsChanageY '+nData;
                  FOut.FExtParam := 'PriceIsChanageY';
                  // 标记发生改价将进行二次校验
                end;
              end
              else
              begin
                IF nCard<>'' then
                begin
                  nStr := 'Insert Into S_UPLoadOrderNc(N_OrderNo, N_Type, N_Status, N_Proc,N_ErrorMsg)Select ''$OrderNo'',''$Type'',''$Status'',''$Proc'',''$Msg'' '+
                          'Where  Not exists(Select * From S_UPLoadOrderNc Where N_OrderNo=''$OrderNo'' And N_Type =''$Type'' '+
                                              ' And N_Status =''$Status'' And N_Proc =''$Proc'') ';
                  nStr := MacroValue(nStr, [MI('$OrderNo', FListA.Values['ID']), MI('$Type', 'S'), MI('$Msg', nData),
                                            MI('$Status', '1'), MI('$Proc', nProc)]);
                  gDBConnManager.WorkerExec(FDBConn, nStr);
                end;

                nStr := 'UPDate S_UPLoadOrderNc Set N_ErrorMsg=''$Msg'' Where N_OrderNo=''$OrderNo'' And N_Proc=''$Proc'' ';
                nStr := MacroValue(nStr, [MI('$OrderNo', FListA.Values['ID']), MI('$Msg', nData),MI('$Proc', nProc)]);
                gDBConnManager.WorkerExec(FDBConn, nStr);
              end;
            end
            else
            begin
              Result:= True;
              if nCard<>'' then // 中间件出厂触发时如NC同步成功直接写入 同步历史表
              begin
                nStr := MakeSQLByStr([SF('N_OrderNo', FListA.Values['ID']),
                        SF('N_Type', 'S'),
                        SF('N_Status', '0'),
                        SF('N_Proc', nProc),
                        SF('N_SyncNum', '1')
                        ], sTable_UPLoadOrderNcHistory, '', True);
                gDBConnManager.WorkerExec(FDBConn, nStr);

                nStr := 'Delete S_UPLoadOrderNc Where N_OrderNo=''$OrderNo'' And N_Type =''$Type'' '+
                                              ' And N_Status =''$Status'' And N_Proc =''$Proc''';
                nStr := MacroValue(nStr, [MI('$OrderNo', FListA.Values['ID']), MI('$Type', 'S'),
                                            MI('$Status', '1'), MI('$Proc', nProc)]);
                gDBConnManager.WorkerExec(FDBConn, nStr);
              end;
            end;
          end;
        end;
      except
        on Ex:Exception do
        begin
          WriteLog('推送销售出厂单-->NC 解析返回内容出错：'+ Ex.Message);
        end;
      end;
    except
      on Ex:Exception do
      begin
        WriteLog('访问NC接口出错：'+ Ex.Message);
      end;
    end;
  finally
    FOut.FData := nData;
    FOut.FBase.FResult := True;
  end;
end;

//Desc: Nc状态监测
function TBusWorkerBusinessNC.ChkNcStatus(var nData: string): Boolean;
var nStr, nTime, nProc, nZhiKaPK, nZhiKaDtlPK, nCreator, nHid, nBid : string;
    nCard : string;
    nZhika, nMTime, nMValue, nPValue, nValue : string;
    nRoot, nNode : TXmlNode;
begin
  Result := False;
  try
    try
      FNCChannel := GetIDataReceivePortType(False, gSysParam.FSrvRemote);
      nStr := FNCChannel.receiveData('BS0003', 'null', 'null');
    except
      on Ex: Exception do
      begin
        gSysParam.FErrorNum := gSysParam.FErrorNum + 1;
        nData := '访问NC出错：' + Ex.Message;
        WriteLog(nData);
        Exit;
      end;
    end;

    if nStr = 'OK' then
    begin
      WriteLog('网络链接恢复、NC服务工作状态正常、现切换为在线模式 OnLine');
      gSysParam.FErrorNum:= 0;
      if Not gTNCStatusChker.Suspended then
          gTNCStatusChker.Suspend;

      Result:= True;
      nStr := 'UPDate Sys_Dict Set D_Value=''OnLine'' Where D_Memo=''NCServiceStatus'' And D_Name=''SysParam'' ';
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
  finally
    FOut.FData := sFlag_Yes;
    FOut.FBase.FResult := True;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessNC, sPlug_ModuleBus);
end.
