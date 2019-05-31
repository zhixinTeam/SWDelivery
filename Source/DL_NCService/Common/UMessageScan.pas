{*******************************************************************************
描述: 单据推送扫描线程     销售  采购
*******************************************************************************}
unit UMessageScan;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UWorkerBussinessNC,
  UNCStatusChkThread ;

type
  TMessageScan = class;
  TMessageScanThread = class(TThread)
  private
    FOwner: TMessageScan;
    //拥有者
    FDBConn, FDBConnA : PDBWorker;
    //数据对象
    FListA,FListB,FListC: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
    FNumOutFactMsg: Integer;
    //提货单出厂消息推送计时计数
  protected
    function SendSaleBillToNC(nList: TStrings):Boolean;
    //销售单
    function GetOrderNCInfo(nRid, nTime: string; Var nNo, nPk:string):Boolean;
    function SendOrderToNC(nList: TStrings):Boolean;
    //采购单
    procedure UPDateOrderStatus(const nSuccess: Boolean; nRid, nOrderNo, nProc : string);
    //更新消息状态

    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TMessageScan);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TMessageScan = class(TObject)
  private
    FThread: TMessageScanThread;
    //扫描线程
  public
    FSyncTime:Integer;
    //设定同步次数阀值
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停上传
    procedure LoadConfig(const nFile:string);//载入配置文件
  end;

var
  gMessageScan: TMessageScan = nil;
  //全局使用


implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TMessageScan, 'NC推送消息扫描', nMsg);
end;

constructor TMessageScan.Create;
begin
  FThread := nil;
end;

destructor TMessageScan.Destroy;
begin
  Stop;
  inherited;
end;

procedure TMessageScan.Start;
begin
  if not Assigned(FThread) then
    FThread := TMessageScanThread.Create(Self);
  FThread.Wakeup;
end;

procedure TMessageScan.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//载入nFile配置文件
procedure TMessageScan.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('Item');
    try
      FSyncTime:= StrToInt(nNode.NodeByName('SyncTime').ValueAsString);
    except
      FSyncTime:= 5;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TMessageScanThread.Create(AOwner: TMessageScan);
var nErr : Integer;
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FDBConnA := nil;
  FDBConnA := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
  if not FDBConnA.FConn.Connected then
    FDBConnA.FConn.Connected := True;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 30*1000;
  FNcIsOnLine:= True;

  FSyncLock := TCrossProcWaitObject.Create('Service_MessageScan');
  //process sync
end;

destructor TMessageScanThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FXMLBuilder.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TMessageScanThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TMessageScanThread.StopMe;
begin
  gDBConnManager.ReleaseConnection(FDBConnA);
  WriteLog('Release FDBConn');
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMessageScanThread.Execute;
var nErr, nSuccessCount, nFailCount: Integer;
    nStr: string;
    nResult : Boolean;
    nInit: Int64;
    nOut: TWorkerBusinessCommand;
begin
                        
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;
    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行

    FDBConn := nil;
    with gParamManager.ActiveParam^ do
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then
      begin
        WriteLog('无效的数据库连接...');
        Continue;
      end;

      nStr := 'Select * From %s Where D_Name=''SysParam'' And D_Memo=''NCServiceStatus''';
      nStr := Format(nStr, [sTable_SysDict]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount > 0 then
        begin
          First;
          FNcIsOnLine:= (FieldByName('D_Value').AsString='OnLine');
        end;
      end;
      IF not FNcIsOnLine then
      begin
        if gTNCStatusChker.Suspended then gTNCStatusChker.Resume;
        Continue;
      end;

      nStr:= 'Select Top 100 * From %s Where N_SyncNum <= %d And N_Status<>0';
      nStr:= Format(nStr,[sTable_UPLoadOrderNc, gMessageScan.FSyncTime, sFlag_Yes]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
          Continue;
        //无新消息
        nSuccessCount := 0;
        nFailCount := 0;
        WriteLog('查询到'+ IntToStr(RecordCount) + '条数据,开始推送...');
        nInit := GetTickCount;

        First;
        while not Eof do
        begin
          FListA.Clear;
          FListA.Values['RID']     := FieldByName('R_ID').AsString;
          FListA.Values['ID']      := FieldByName('N_OrderNo').AsString;
          FListA.Values['Type']    := FieldByName('N_Type').AsString;
          FListA.Values['Status']  := FieldByName('N_Status').AsString;
          FListA.Values['Proc']    := FieldByName('N_Proc').AsString;

          FDBConn.FConn.BeginTrans;
          try
            nStr := PackerEncodeStr(FListA.Text);

            if FListA.Values['Type'] = sFlag_Sale then
              nResult := SendSaleBillToNC(FListA)
            else
              nResult := SendOrderToNC(FListA);
            //******************************************

            if nResult then
            begin
              //更新为已处理
              Inc(nSuccessCount);
            end
            else Inc(nFailCount);

            UPDateOrderStatus(nResult, FieldByName('R_ID').AsString,
                                       FieldByName('N_OrderNo').AsString,
                                       FieldByName('N_Proc').AsString );
            FDBConn.FConn.CommitTrans;
          except
            if FDBConn.FConn.InTransaction then
              FDBConn.FConn.RollbackTrans;
          end ;
          WriteLog('第'+IntToStr(RecNo)+'条处理完成！单号:'+FListA.Values['ID']);
          Next;
        end;
      end;
      WriteLog(IntToStr(nSuccessCount) + '条消息同步成功，'
                + IntToStr(nFailCount) + '条消息同步失败，'
                + '耗时: ' + IntToStr(GetTickCount - nInit) + 'ms');
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
      FSyncLock.SyncLockLeave();
      WriteLog('已完成本次任务');
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

function TMessageScanThread.SendSaleBillToNC(nList: TStrings):Boolean;
var nStr, nErrMsg : string;
    nOut: TWorkerBusinessCommand;
    nErrNum:Integer;
begin
  Result:= False;
  nStr  := PackerEncodeStr(nList.Text);
  Result:= TBusWorkerBusinessNC.CallMe(cBC_SendToNcBillInfo, nStr,'',@nOut);

  if not Result then
  begin
      nErrMsg:= StringReplace(nOut.FData, #13, '', [rfReplaceAll]);
      nErrMsg:= StringReplace(nErrMsg, #10, '', [rfReplaceAll]);

      nStr:= ' UPDate %s Set N_ErrorMsg=''%s'' Where R_ID=%s ';
      nStr:= Format(nStr, [sTable_UPLoadOrderNc, nErrMsg, nList.Values['RID']]);
      gDBConnManager.WorkerExec(FDBConnA, nStr);
  end;
end;

// 重新获取 采购单对应的NC采购单信息
function TMessageScanThread.GetOrderNCInfo(nRid, nTime: string; Var nNo, nPk:string):Boolean;
var nStr : string;
begin
  Result:= False;
  try
    nStr := 'Select B_ID, B_PKOrder, B_PKdtl, B_Date, DATEDIFF(SS, ''%s'', B_Date) InTimeDiff From %s ' +
            'Where B_Date<''%s'' And B_NCOrderNo=''%s''  Order by InTimeDiff Desc  ';
    nStr := Format(nStr, [nTime, sTable_OrderBase, nTime, nNo]);
    with gDBConnManager.WorkerQuery(FDBConnA, nStr) do
    begin
      if RecordCount > 0 then
      begin
        First;
        // NC 采购单发生改价操作需更新 DL 采购单O_BID字段
        if nNo<>FieldByName('B_NCOrderNo').AsString then
        begin
          nNo:= FieldByName('B_NCOrderNo').AsString;
          nPk:= FieldByName('B_PKdtl').AsString;
        end;
        Result:= True;
      end;
    end;
  finally
  end;
end;

function TMessageScanThread.SendOrderToNC(nList: TStrings):Boolean;
var nStr, nLID, nProPk, nMtlPk, nBid, nBPKDtl: string;
    nOut: TWorkerBusinessCommand;
    nJuShou:Boolean;
begin
  Result := False;
  nJuShou := False;
  nLID := nList.Values['ID'];
  try
    nStr := 'Select *, b.R_ID ORID From %s a Left Join %s b On B_ID=O_BID Left Join %s c On O_ID=D_OID ' +
            'Where D_ID=''%s'' ';
    nStr := Format(nStr, [sTable_OrderBase, sTable_Order, sTable_OrderDtl, nLID]);
    with gDBConnManager.WorkerQuery(FDBConnA, nStr) do
    begin
      if RecordCount < 1 then
      begin
        WriteLog(Format('采购单 %s 已无效.', [nLID]));
        Exit;
      end;

      First;
      FListB.Clear;

      nJuShou:= FieldByName('D_YSResult').AsString='N';

      IF not nJuShou then
      begin
        nProPk := FieldByName('B_ProId').AsString;
        nMtlPk := FieldByName('O_StockNo').AsString;
        nBid   := FieldByName('B_NCOrderNo').AsString;
        nBPKDtl:= FieldByName('B_PKDtl').AsString;
        //GetOrderNCInfo(FieldByName('ORID').AsString, FieldByName('D_OutFact').AsString, nBid, nBPKDtl);
        //重新查找与出厂时间匹配的NC采购单
        //***********
        FListB.Values['Proc']      := nList.Values['Proc'];
        FListB.Values['CreateTime']:= FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('O_Date').AsDateTime);
        FListB.Values['ProPk']     := nProPk;
        FListB.Values['creator']   := FieldByName('O_Man').AsString;
        FListB.Values['OutFact']   := FieldByName('D_OutFact').AsString;
        FListB.Values['BID']       := nBid;
        FListB.Values['OID']       := FieldByName('O_ID').AsString;
        FListB.Values['ORID']      := FieldByName('ORID').AsString;
        FListB.Values['DID']       := FieldByName('D_ID').AsString;
        FListB.Values['Value']     := FieldByName('D_Value').AsString;

        FListB.Values['StockPK']   := nMtlPk;
        FListB.Values['PkDtl']     := nBPKDtl;
        FListB.Values['CarrierPK'] := nProPk;                                // 承运商PK
        FListB.Values['KFTime']    := FormatDateTime('yyyy-MM-dd HH:mm:ss', Now);      // 矿发时间

        FListB.Values['KFValue']   := FieldByName('O_YJZValue').AsString;    // 矿发量
        if (FieldByName('O_YJZValue').AsString='')or
            (FieldByName('O_YJZValue').AsString='0') then
            FListB.Values['KFValue']:= FieldByName('D_Value').AsString;

        FListB.Values['MDate']     := FieldByName('D_MDate').AsString;
        FListB.Values['MValue']    := FieldByName('D_MValue').AsString;
        FListB.Values['PValue']    := FieldByName('D_PValue').AsString;
        FListB.Values['KZValue']   := FieldByName('D_KZValue').AsString;
        FListB.Values['TruckNo']   := FieldByName('D_Truck').AsString;
      end;
    end;

    IF not nJuShou then
    begin
      // *******************  获取供应商、原料  PK 值
      nStr := 'Select * From %s Where P_ID=''%s''';
      nStr := Format(nStr, [sTable_Provider, nProPk]);
      with gDBConnManager.WorkerQuery(FDBConnA, nStr) do
      begin
        if RecordCount < 1 then
        begin
          WriteLog(Format('供应商[ %s ]不存在、本次将终止上传单据.', [nProPk]));
          Exit;
        end
        else nProPk:= FieldByName('P_PKPro').AsString;
      end;

      nStr := 'Select * From %s Where M_ID=''%s''';
      nStr := Format(nStr, [sTable_Materails, nMtlPk]);
      with gDBConnManager.WorkerQuery(FDBConnA, nStr) do
      begin
        if RecordCount < 1 then
        begin
          WriteLog(Format('原料[ %s ]不存在、本次将终止上传单据.', [nMtlPk]));
          Exit;
        end
        else nMtlPk:= FieldByName('M_PK').AsString;
      end;

      FListB.Values['ProPk']     := nProPk;
      FListB.Values['StockPK']   := nMtlPk;
      FListB.Values['CarrierPK'] := nProPk;
      nStr := PackerEncodeStr(FListB.Text);
      ////*******************************************

      Result := TBusWorkerBusinessNC.CallMe(cBC_SendToNcOrdreInfo, nStr,'',@nOut);
      if not Result then
      begin
          nStr:= ' UPDate %s Set N_ErrorMsg=''%s'' Where R_ID=%s ';
          nStr:= Format(nStr, [sTable_UPLoadOrderNc, nOut.FData, nList.Values['RID']]);
          gDBConnManager.WorkerExec(FDBConnA, nStr);
      end;
    end
    else
    begin
      nStr:= ' Delete %s Where R_ID=%s ';
      nStr:= Format(nStr, [sTable_UPLoadOrderNc, nList.Values['RID']]);
      gDBConnManager.WorkerExec(FDBConnA, nStr);
      WriteLog(Format('采购单[ %s ]为拒收、本次将终止上传单据.', [nLID]));
    end;
  finally
  end;
end;

procedure TMessageScanThread.UPDateOrderStatus(const nSuccess: Boolean; nRid, nOrderNo, nProc : string);
var
  nStr, nMark: string;
begin
  if nSuccess then  nMark:= '0'
  else nMark:= '1';

  nStr := 'UPDate %s Set N_Status=%s, N_SyncNum=N_SyncNum + 1 Where R_ID=%s ';
  nStr := Format(nStr, [sTable_UPLoadOrderNc, nMark, nRid]);
  gDBConnManager.WorkerExec(FDBConnA, nStr);
  //标记处理结果

  if nSuccess then
  begin
    try
      nStr := 'Select * From %s Where N_OrderNo=''%s'' And N_Proc=''%s'' ';
      nStr := Format(nStr, [sTable_UPLoadOrderNcHistory, nOrderNo, nProc]);
      with gDBConnManager.WorkerQuery(FDBConnA, nStr) do
      begin
        if RecordCount = 0 then
        begin
          nStr := 'Insert Into %s(N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum) ' +
                  '  Select N_OrderNo, N_Type, N_Status, N_Proc, N_SyncNum ' +
                  '  From S_UPLoadOrderNc Where R_ID=''%s'' ';
          nStr := Format(nStr, [sTable_UPLoadOrderNcHistory, nRid]);
          gDBConnManager.WorkerExec(FDBConnA, nStr);
        end;

        nStr:= 'Delete %s Where R_ID=%s ';
        nStr := Format(nStr, [sTable_UPLoadOrderNc, nRid]);
        gDBConnManager.WorkerExec(FDBConnA, nStr);
      end;
    except
      raise;
    end;
  end;
end;


initialization
  gMessageScan := nil;
finalization
  FreeAndNil(gMessageScan);
end.

