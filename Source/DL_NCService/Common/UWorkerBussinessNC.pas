{*******************************************************************************
  ����: �������ҵ������ݴ���
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
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FNCChannel: IDataReceivePortType;
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    FPackOut: Boolean;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  TBusWorkerBusinessNC = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerWebChatData;
    FOut: TWorkerWebChatData;
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
    function GetMateId(const nPK:string): string;
    function CheckExistsPOrderBase(const nPK, nPKDtl, nOrderNo:string): Boolean;
    function GetZhiKaFreezeMoney(const nZhiKa, nCusId:string): Double;
    function CheckExistsZhika(const nZid, nZPk:string): Boolean;
    //***************�������ݴ��������ӡ��޸ġ�ɾ����***************************
    function EditCustomer(var nData: string): Boolean;
    //�ͻ�����
    function EditProvider(var nData: string): Boolean;
    //��Ӧ��
    function EditUnit(var nData: string): Boolean;
    //������λ
    function EditStocks(var nData: string): Boolean;
    //ˮ��Ʒ��
    function EditCusCredit(var nData: string): Boolean;
    //���ۿͻ�����
    function EditPOrder(var nData: string): Boolean;
    //�ɹ���ͬ����
    function EditZhiKa(var nData: string): Boolean;
    //����ֽ��

    function SendMsg(nPrmA, nPrmB, nPrmC:string):string;
    function SendOrderPoundInfo(var nData:string):boolean;
    //�ɹ���
    //************************************************************
    function AddManualEventRecord(const nEID,nKey,nEvent:string;
             const nFrom: string = sFlag_DepBangFang ;
             const nSolution: string = sFlag_Solution_YN;
             const nDepartmen: string = sFlag_DepDaTing;
             const nReset: Boolean = False; const nMemo: string = ''): Boolean;
    function UPDateZhiKaBind(nOldZhika, nNewZhiKaPk, nStockNo: string): Boolean;
    function UPDateBills(nBillNo, nNewZhiKaPK: string; var nData:string): Boolean;
    //NC���ۺ������ֽ����Ϣ ���¾�ֽ������δ����������Ϣ
    function SendBillPoundInfo(var nData:string):boolean;
    //���۵�
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

//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
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
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

//    {$IFDEF WXChannelPool}
//    FWXChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
//    if not Assigned(FWXChannel) then
//    begin
//      nData := '���ӷ���ʧ��(NC Web Service No Channel).';
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
      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      if FPackOut then
      begin
        WriteLog('���');
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
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
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
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
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
begin
  Result := False;
  // ��ӿڷ���������������������߳�
  gTNCStatusChker.Suspend;
  try
    try
      FPacker.XMLBuilder.Clear;

      if Pos('<?xml', nData)>0 then
        FPacker.XMLBuilder.ReadFromString(nData);
    except
      WriteLog('XML����ʧ��');
    end;
    //nNode := FPacker.XMLBuilder.Root.FindNode('Message');
    nNode := FPacker.XMLBuilder.Root;
    if not (Assigned(nNode) and Assigned(nNode.FindNode('DataRow'))) then
    begin
      nData := '��Ч�����ڵ�(Head.Message Null).';
      Exit;
    end;

    nTmp := nNode.FindNode('Message');
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
    begin
      nData := '��Ч����������(Message.billtype error).';
      Exit;
    end;
  except on Ex : Exception do
    begin
      nData := 'XML����ʧ��:' + Ex.Message;
      Exit;
    end;
  end;
end;

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TBusWorkerBusinessNC.DoDBWork(var nData: string): Boolean;
begin
  if Pos('<?xml', nData)>0 then UnPackIn(nData);

  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
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
   else
    begin
      Result := False;
      nData := '��Ч����������(Message.billtype error).';
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
//Desc: ��ʼ��XML����
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
//Desc: ����Ĭ������
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
      nData := '��Ч�����ڵ�(WebService-Response.DataRow Is Null).';
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
        nData := Format('�ڵ� %s ֵ��Ч', [nStr]);
        Exit;
      end;
      Result := True;
    end;
  except on Ex : Exception do
    begin
      nData := Format('�ڵ� %s ����', [nStr]);
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
        nTip:= '��������';
      end;

    PR_Provider :
      begin
        nStr:= Format('Select * From P_Provider Where P_ID=''%s'' And P_Name=''%s''',
                                  [nID, nName]);
        nTip:= '��Ӧ��';
      end;

    PR_Materails :
      begin
        nStr:= Format('Select * From P_Materails Where M_ID=''%s'' And M_Name=''%s''',
                                  [nID, nName]);
        nTip:= '�ɹ�����';
      end;

    PR_SaleMan  :
      begin
        nStr:= Format('Select * From S_Salesman Where S_ID=''%s'' And S_Name=''%s''',
                                  [nID, nName]);
        nTip:= 'ҵ��Ա';
      end;

    PR_Cus      :
      begin
        nStr:= Format('Select * From S_Customer Where C_ID=''%s'' And C_Name=''%s''',
                                  [nID, nName]);

        nTip:= '���ۿͻ�����';
      end;

    PR_CusID    :
      begin
        nStr:= Format('Select * From S_Customer Where C_ID=''%s'' ',
                                  [nID]);
        nTip:= '���ۿͻ��ʽ��˻�';
      end;
  end;

  try
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount>0 then
      begin
        Result:= True;
      end
      else nRe:= Format('���� %s ��Ϣ %s ��%s ��Ч', [nTip, nID, nName]);
    end;
  except
    nRe:= '�����Ϣ�� '+nTip+' ʱ��������';
  end;
end;

function TBusWorkerBusinessNC.CheckExistsPOrderBase(const nPK, nPKDtl, nOrderNo:string): Boolean;
var nStr, nTip:string;
begin
  Result:= False;
  try
    nStr:= Format('Select * From P_OrderBase Where Where B_PKOrder=''%s'' And B_PKDtl=''%s'' And B_NCOrderNo=''%s'' ',
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
//Desc: �ͻ�����
function TBusWorkerBusinessNC.EditCustomer(var nData: string): Boolean;
var nSql, nPK, nInitMoney: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('���ͻ���������Σ�' + nData);
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
          nData := '��Ч�����ڵ�(WebService-Message.DataRow Is Null).';
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

            if (NodeByName('smanid').ValueAsString<>'')And
               (NodeByName('smanid').ValueAsString<>'null')then
            if not CheckExists(PR_SaleMan, NodeByName('smanid').ValueAsString,NodeByName('smanname').ValueAsString, nData) then
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
                nSql:= Format(' Insert Into S_Salesman(S_ID, S_Name, S_PY, S_InValid)Select top 1 ''%s'', ''%s'', ''%s'', ''%s'' ' +
                                          ' From Master..SysDatabases Where Not exists(Select * From S_Salesman Where S_ID=''%s'') '  ,
                              [ NodeByName('smanid').ValueAsString, NodeByName('smanname').ValueAsString,
                                GetPinYinOfStr(NodeByName('smanname').ValueAsString), 'N', NodeByName('smanid').ValueAsString]);
                FListA.Add(nSql);
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
                nSql:= Format(' UPDate S_Salesman Set S_Name=''%s'' ,S_PY=''%s'' Where S_ID=''%s'' ', [
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
              nData:= '�ڵ� proc ��Ч�Ĳ�����ʾ';
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
              //gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('�ͻ�����' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '�����ɹ�';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '����ʧ��';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '����ʧ�ܡ�����XML���ݷ�������';
        WriteLog('�ͻ�����ͬ�� ������' + Ex.Message);
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
//Desc:��Ӧ�̵���
function TBusWorkerBusinessNC.EditProvider(var nData: string): Boolean;
var nSql, nPK: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('����Ӧ�̵�������Σ�' + nData);
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
          nData := '��Ч�����ڵ�(WebService-Message.DataRow Is Null).';
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
              nData:= '�ڵ� proc ��Ч�Ĳ�����ʾ';
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
              gSysLoger.AddLog('��Ӧ�̵���' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '�����ɹ�';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '����ʧ��';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '����ʧ�ܡ�����XML���ݷ�������';
        WriteLog('��Ӧ��ͬ�� ������' + Ex.Message);
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
//Desc:������λ
function TBusWorkerBusinessNC.EditUnit(var nData: string): Boolean;
var nSql, nPK: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('��������λ����Σ�' + nData);

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
          nData := '��Ч�����ڵ�(WebService-Message.DataRow Is Null).';
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
                            [ 'MaterailsItem','������λ',NodeByName('unitname').ValueAsString,NodeByName('unitid').ValueAsString,
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
              nData:= '�ڵ� proc ��Ч�Ĳ�����ʾ';
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
              gSysLoger.AddLog('������λ����' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '�����ɹ�';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '����ʧ��';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '����ʧ�ܡ�����XML���ݷ�������';
        WriteLog('������λͬ�� ������' + Ex.Message);
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
//Desc: ���ϵ���  ˮ��Ʒ��
function TBusWorkerBusinessNC.EditStocks(var nData: string): Boolean;
var nSql, nPK, nPageType: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('�����ϵ�������Σ�' + nData);
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
          nData := '��Ч�����ڵ�(WebService-Message.DataRow Is Null).';
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
              if LeftStr(NodeByName('mateid').ValueAsString,2)='04' then   // 04 ��ͷ����  01 �ɹ���
              begin
                nSql:= Format(' Insert Into Sys_Dict (D_Name, D_Desc, D_Value,D_Memo, D_ParamB) Select top 1  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' '+
                                   ' From Master..SysDatabases Where Not exists(Select * From Sys_Dict Where D_Name=''StockItem'' And D_ParamB =''%s'') '  ,
                              [ 'StockItem',NodeByName('pk_mate').ValueAsString,NodeByName('matename').ValueAsString,NodeByName('package').ValueAsString,
                                NodeByName('mateid').ValueAsString, NodeByName('mateid').ValueAsString ]);
              end
              else
              begin
                nSql:= Format(' Insert Into P_Materails (M_ID, M_Name, M_PY, M_Unit, M_PrePTime, M_IsSale, M_IsNei, M_Pk) '+
                                   ' Select top 1  ''%s'', ''%s'', ''%s'', ''��'', ''365'', ''N'' , ''N'' , ''%s''  '+
                                   ' From Master..SysDatabases Where Not exists(Select * From P_Materails Where M_ID=''%s'' And M_Pk =''%s'') '  ,
                              [ NodeByName('mateid').ValueAsString,NodeByName('matename').ValueAsString,GetPinYinOfStr(NodeByName('matename').ValueAsString),
                                NodeByName('pk_mate').ValueAsString, 
                                NodeByName('mateid').ValueAsString, NodeByName('pk_mate').ValueAsString ]);
              end;

              FListA.Add(nSql);
            end
            else if NodeByName('proc').ValueAsString='update' then
            begin
              if LeftStr(NodeByName('mateid').ValueAsString,2)='04' then   // 04 ��ͷ����  01 �ɹ���
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
              if LeftStr(NodeByName('mateid').ValueAsString,2)='04' then   // 04 ��ͷ����  01 �ɹ���
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
              nData:= '�ڵ� proc ��Ч�Ĳ�����ʾ';
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
              gSysLoger.AddLog('���ϵ���' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '�����ɹ�';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '����ʧ��';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '����ʧ�ܡ�����XML���ݷ�������';
        WriteLog('����ͬ�� ������' + Ex.Message);
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
//Desc: ���ۿͻ�����
function TBusWorkerBusinessNC.EditCusCredit(var nData: string): Boolean;
var nSql, nPK, nStr: string;
    nIdx: Integer;
    nNode,nRoot: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('���ͻ����á���Σ�' + nData);
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
          nData := '��Ч�����ڵ�(WebService-Message.DataRow Is Null).';
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
              nData:= '�ڵ� proc ��Ч�Ĳ�����ʾ';
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
              gSysLoger.AddLog('�ͻ�����' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '�����ɹ�';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '����ʧ��';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '����ʧ�ܡ�����XML���ݷ�������';
        WriteLog('�ͻ����� ������' + Ex.Message);
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
//Desc: �ɹ�����
function TBusWorkerBusinessNC.EditPOrder(var nData: string): Boolean;
var nSql, nPK, nPKDtl, nOrderId, nNCOrderId, nProId, nProName, nCMan, nCTime, nProc, nMid, nFlag: string;
    nIdx, nRestValue, nLimValue, nWarnValue, nValue : Integer;
    nRoot, nDetails, nItem: TXmlNode;
    ExecSql:Boolean;
begin
  WriteLog('���ɹ���������Σ�' + nData);
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
          nData := '��Ч�����ڵ�(WebService-Message.DataRow Is Null).';
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
          nNCOrderId:= Root.Nodes[0].NodeByName('order').ValueAsString;     // NC ���
          
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
                nData:= 'ȱ�ٽڵ� dtl_pk';
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
                  nOrderId:= FormatDateTime('OyyyyMMddHHmmsszzz', Now);             // DL ���

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
                // �޸Ĳɹ���Ϊ������״̬
                nSql:= Format(' UPDate P_OrderBase Set B_BStatus=''N'' Where B_NCOrderNo=''%s'' AND B_PKOrder=''%s'' AND B_PKdtl=''%s'' ',
                              [nNCOrderId, nPK, nPKDtl]);
                FListA.Add(nSql);
              end
              else
              begin
                nData:= '�ڵ� proc ��Ч�Ĳ�����ʾ';
                ExecSql:= False;
                Break;
              end;
            end;
          end;
        except
          nData:= '����XML��Ϣ�������ȱ�ٽڵ�';
          ExecSql:= False;
        end;

        if ExecSql then
        begin
          FDBConn.FConn.BeginTrans;
          try
            for nIdx:=0 to FListA.Count - 1 do
            begin
              gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('�ɹ����� ' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '�����ɹ�';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '����ʧ��';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= '����ʧ�ܡ���������������';
        WriteLog('�ɹ����� ������' + Ex.Message);
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

//Date: 2018-11-25
//Desc: ����ֽ��
function TBusWorkerBusinessNC.EditZhiKa(var nData: string): Boolean;
var nSql, nPK, nPKDtl, nZId, nZName, nCusId, nSmanId, nFixmoney,
    nValidDay, nCMan, nCTime, nProc, nFlag, nType: string;
    nPrice,nFlPrice,nValue,nYFPrice, nFreezeMoney, nFixmoneyNew:Double;
    nIdx: Integer;
    nRoot, nDetails, nItem: TXmlNode;
    ExecSql, NeedExecDtl:Boolean;
begin
  WriteLog('������ֽ������Σ�' + nData);
  try
    try
      Result := False;   ExecSql:= True;   NeedExecDtl:= True;

      with FPacker.XMLBuilder do
      begin
        ReadFromString(nData);
        if not ParseDefault(nData) then Exit;
        nRoot := Root.FindNode('DataRow');

        if not Assigned(nRoot) then
        begin
          nData := '��Ч�����ڵ�(WebService-Message.DataRow Is Null).';
          Exit;
        end;

        FListA.Clear;
        //***********
          if (Not CheckNode(Root.Nodes[0], 'pk_zk', nData)) or (Not CheckNode(Root.Nodes[0], 'zid', nData)) or
                (Not CheckNode(Root.Nodes[0], 'cusid', nData)) or (Not CheckNode(Root.Nodes[0], 'validdays', nData)) or
                (Not CheckNode(Root.Nodes[0], 'proc', nData)) then
          begin
            ExecSql:= False;
            Exit;
          end;

        nProc   := Root.Nodes[0].NodeByName('proc').ValueAsString;
        nPK     := Root.Nodes[0].NodeByName('pk_zk').ValueAsString;
        nZId    := Root.Nodes[0].NodeByName('zid').ValueAsString;
        nZName  := Root.Nodes[0].NodeByName('zname').ValueAsString;
        nCusId  := Root.Nodes[0].NodeByName('cusid').ValueAsString;
        nSmanId := Root.Nodes[0].NodeByName('smanid').ValueAsString;
        nValidDay:= Root.Nodes[0].NodeByName('validdays').ValueAsString;
        if nValidDay='0' then
             nValidDay:= FormatDateTime('yyyy-MM-dd HH:mm:ss', IncYear(Now, 100))
        else nValidDay:= FormatDateTime('yyyy-MM-dd HH:mm:ss', IncDay(Now, StrToInt(nValidDay)));

        nFixmoney:= Root.Nodes[0].NodeByName('fixmoney').ValueAsString;
        nFixmoney:= StringReplace(nFixmoney, ',', '', [rfReplaceAll]);
        nFixmoney:= StringReplace(nFixmoney, '��', '', [rfReplaceAll]);
        nFixmoneyNew:= Float2Float(StrToFloatDef(nFixmoney, 0), cPrecision, False);
        nFixmoney:= FloatToStr(nFixmoneyNew);

        nCMan   := Root.Nodes[0].NodeByName('creator').ValueAsString;
        nCTime  := Root.Nodes[0].NodeByName('date').ValueAsString;

        nFlag   := Root.Nodes[0].NodeByName('flag').ValueAsString;
        if nFlag='0' then nFlag:= sFlag_Yes else nFlag:= sFlag_No;
        //**************************************************************************
        nCusId  := GetCusId(nCusId);
        if (not CheckExists(PR_CusID, nCusId, '', nData)) then
        begin
          WriteLog(nData);
          ExecSql:= False;
          Exit;
        end;
        //***********
        if nProc='add' then
        begin
          if not CheckExistsZhika(nZId, nPK) then
          begin
            nSql:= Format(' Insert Into S_ZhiKa(Z_ID, Z_Name, Z_PKzk, Z_Customer, Z_SaleMan, Z_Lading, Z_ValidDays, Z_Verified,'+
                                                'Z_YFMoney, Z_FixedMoney, Z_OnlyMoney, Z_Man, Z_Date) '+
                                    'Select top 1  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' '+
                                    'From Master..SysDatabases Where Not exists(Select * From S_ZhiKa Where Z_ID=''%s'' And Z_PKzk =''%s'') '  ,
                              [ nZId, nZName, nPK, nCusId, nSmanId, 'T', nValidDay, nFlag, '0', nFixmoney, 'Y', nCMan, nCTime, nZId, nPK ]);
            FListA.Add(nSql);
            FListA.Add(' Delete S_ZhiKaDtl Where D_ZID='''+ nZId +'''');
          end
          else NeedExecDtl:= False;
        end
        else if nProc='update' then
        begin
          ///////////////  ��ȡδ�������ݽ���Լ�����δ�ϴ����ϴ�ʧ�ܵ��ݽ��
          nFreezeMoney:= GetZhiKaFreezeMoney(nZId, nCusId);
          if nFixmoneyNew<nFreezeMoney then
          begin
            nData:= '�ͻ� ' + nCusId + ' ���ڷ������ '+floattoStr(nFreezeMoney)+'����ֽ�������޸�Ϊ 0 Ԫ';
            nFixmoney:= '0';
          end
          else nFixmoney:= FloatToStr(nFixmoneyNew-nFreezeMoney);

          nSql:= Format(' UPDate S_ZhiKa Set Z_Name=''%s'', Z_Customer=''%s'', Z_SaleMan=''%s'', Z_ValidDays=''%s'', Z_Verified=''%s'',Z_FixedMoney=''%s'' ' +
                                                    'Z_Man=''%s'', Z_Date=''%s'' ' +
                            ' Where Z_ID=''%s'' AND Z_PKzk=''%s'' ',
                            [ nZName, nCusId, nSmanId, nValidDay, nFlag, nFixmoney, nCMan, nCTime, nZId, nPK]);
          FListA.Add(nSql);
          FListA.Add(' Delete S_ZhiKaDtl Where D_ZID='''+ nZId +'''');
        end
        else if nProc='delete' then
        begin
          // �޸�ֽ��Ϊ������״̬
          nSql:= Format(' UPDate S_ZhiKa Set Z_InValid=''Y'' Where Z_ID=''%s'' AND Z_PKzk=''%s'' ', [nZId, nPK]);
          FListA.Add(nSql);
        end
        else
        begin
          nData:= '�ڵ� proc ��Ч�Ĳ�����ʾ';
          ExecSql:= False;
          Exit;
        end;
        //***********
        nDetails:= Root.FindNode('detail');        //  ����ֽ��Ʒ����ϸ

        if NeedExecDtl then
        for nIdx:=0 to nDetails.NodeCount-1 do
        begin
          nItem := nDetails.Nodes[nIdx];  nSql:= '';

          if (Not CheckNode(nItem, 'stockno', nData)) or (Not CheckNode(nItem, 'stockname', nData)) or
                   (Not CheckNode(nItem, 'price', nData)) then
          begin
            ExecSql:= False;
            Exit;
          end;

          with nItem do
          begin
            if not CheckExists(PR_Stock, NodeByName('stockno').ValueAsString, NodeByName('stockname').ValueAsString, nData) then
            begin
              ExecSql:= False;
              Exit;
            end;

            if (nProc='add')or(nProc='update') then
            begin
              nType   := NodeByName('stockname').ValueAsString;
              if Pos('��', nType)>0 then nType:= sFlag_Dai else nType:= sFlag_San;
              nPKDtl  := NodeByName('dtl_pk').ValueAsString;
              nPrice  := Float2Float(NodeByName('price').ValueAsFloatDef(0), cPrecision, False);
              nFlPrice:= NodeByName('flprice').ValueAsFloatDef(0);
              nValue  := NodeByName('value').ValueAsFloatDef(0);
              nYFPrice:= NodeByName('yunfei').ValueAsFloatDef(0);

              if (nPrice>0)and(nFlPrice>=0)and(nValue>=0)and(nYFPrice>=0) then
              begin
                nSql:= Format(' Insert Into S_ZhiKaDtl(D_ZID,D_Type,D_StockNo,D_StockName,D_Price,D_Value,D_TPrice,D_FLPrice,D_YunFei,D_PkDtl) '+
                                    'Select top 1  ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'' '+
                                    'From Master..SysDatabases Where Not exists(Select * From S_ZhiKaDtl Where D_ZID=''%s'' And D_StockNo =''%s'') '  ,
                              [ nZId, nType, NodeByName('stockno').ValueAsString, NodeByName('stockname').ValueAsString, FloatToStr(nPrice),
                                FloatToStr(nValue), 'Y', FloatToStr(nFlPrice), FloatToStr(nYFPrice), nPKDtl,
                                nZId, NodeByName('stockno').ValueAsString]);
                FListA.Add(nSql);
              end
              else
              begin
                nData:= NodeByName('stockname').ValueAsString + ' ���ۼۡ������ۻ��˷�����';
                ExecSql:= False;
                Exit;
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
              //gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
              gSysLoger.AddLog('����ֽ�� ' + FListA[nIdx]);
            end;

            FDBConn.FConn.CommitTrans;
            nData:= '�����ɹ�';
            Result := True;
          except
            FDBConn.FConn.RollbackTrans;
            nData:= '����ʧ��';
          end;
        end;
      end;
    except on Ex : Exception do
      begin
        nData:= 'XML����ʧ��';
        WriteLog('��������ֽ�� ������' + Ex.Message);
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
    //*******************************************************  <![CDATA[%s]]>
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

//Desc: �ɹ�������
function TBusWorkerBusinessNC.SendOrderPoundInfo(var nData: string): Boolean;
var nStr: string;
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
                  FListA.Values['KZValue'], FListA.Values['MValue'], FListA.Values['PValue']
                  ]);
  WriteLog('�ɹ����ϴ�NC��'+nStr);
  WriteLog('�ɹ����ϴ�NC��'+gSysParam.FSrvRemote);
  try
    try
      try
        FNCChannel := GetIDataReceivePortType(False, gSysParam.FSrvRemote);
        nStr:= FNCChannel.receiveData('BS0001', 'null', nStr);
        WriteLog('NC���أ�'+nStr);
        //nStr := SendMsg('BS0001','null', nStr);
        //nStr:= '<?xml version="1.0" encoding="utf-8"?><Info><DataRow><Pk>0</Pk><Message>��������˲���ɾ��</Message><Status>-1</Status></DataRow></Info> ';
      except on Ex:Exception do
        begin
          gSysParam.FErrorNum:= gSysParam.FErrorNum + 1;
          if gSysParam.FErrorNum>=10 then gTNCStatusChker.Resume;

          nData:= '����NC������'+ Ex.Message;
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
            WriteLog('����ʧ��:'+nData+'Ӧ��:'+nStr);
            Exit;
          end;

          nRoot := Root.FindNode('DataRow');
          if not Assigned(nRoot) then
          begin
            nData := '������������ȱ�ٽڵ� DataRow.';
            Exit;
          end;

          nNode := Root.Nodes[0];
          with nNode do
          begin
            if NodeByName('Status').ValueAsString='-1' then
            begin
              nData := Format(' %s ����ʧ�ܣ�%s', [ FListA.Values['ID'],
                                            NodeByName('Message').ValueAsString]);
            end
            else Result:= True;
          end;
        end;
      except
        on Ex:Exception do
        begin
          WriteLog('���Ͳɹ������������������ݳ�����'+ Ex.Message);
        end;
      end;
    except
      on Ex:Exception do
      begin
        WriteLog('����NC�ӿڳ�����'+ Ex.Message);
      end;
    end;
  finally
    FOut.FData := sFlag_Yes;
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
    WriteLog('��ѡ��������.');
    Exit;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '�¼���¼:[ %s ]�Ѵ���';
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

//Desc: �������ж�������ֽ����ϵ
function TBusWorkerBusinessNC.UPDateZhiKaBind(nOldZhika, nNewZhiKaPk, nStockNo: string): Boolean;
var nStr, nNewZID, nZhiKaDtl : string;
    nPrice, nYunFei : Double;
    FErrNum : Integer;
    xDBConn : PDBWorker;
begin
  Result:= False;
  xDBConn:= nil;
  xDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, FErrNum);

  // ��ȡ��ֽ�� ���� ���˷�
  nStr := 'Select Z_ID, D_StockNo, D_StockName, Z_PKzk, IsNull(Z_FixedMoney, 0) Z_FixedMoney, ' +
                 'D_Price, IsNull(D_YunFei, 0) D_YunFei, D_PKDtl  From S_ZhiKa ' +
          'Left  Join  S_ZhiKaDtl On Z_ID=D_ZID   ' +
          'Where Z_PKzk=''%s''  ';
  nStr := Format(nStr, [nNewZhiKaPk]);
  //xxxxx
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      try
        xDBConn.FConn.BeginTrans;
        try
          while not Eof do
          begin
            nNewZID   := FieldByName('Z_ID').AsString;
            nZhiKaDtl := FieldByName('D_PKDtl').AsString;

            nPrice    := FieldByName('D_Price').AsFloat;
            nYunFei   := FieldByName('D_YunFei').AsFloat;


            // ���¾�ֽ����Դֽ����Ϣ���۸��˷ѵ�
            nStr := 'UPDate S_Bill Set L_ZhiKa=''%s'', L_Price=%g, L_YunFei=%g, L_Pkzk=''%s'' ' +
                    'Where L_ZhiKa=''%s'' And L_PKDtl=''%s'' And L_OutFact Is Null And l_Status<>''O'' ';

            nStr := Format(nStr, [nNewZID, nPrice, nYunFei, nNewZhiKaPk, nOldZhika, nZhiKaDtl]);
            //xxxxx

            gDBConnManager.WorkerExec(xDBConn, nStr);
            xDBConn.FConn.CommitTrans;
            Result:= True;
          end;
        except
          xDBConn.FConn.RollbackTrans;
        end;
      finally
        gDBConnManager.ReleaseConnection(xDBConn);
      end;
    end;
  end;
end;

////  NC���ۺ������ֽ����Ϣ ���¾�ֽ������δ����������Ϣ
function TBusWorkerBusinessNC.UPDateBills(nBillNo, nNewZhiKaPK: string; var nData:string): Boolean;
var nStr, nStockNo, nTruck, nOldZhiKaId, nZhiKaId, nZhiKaDtl, nCusId, nCusName: string;
    nFixMoney, nPrice, nYunFei, nValue, nNeedJK : Double;
    nPrePrice, nPreYunFei, nPreMoney, nNewMoney, nFreezeMoney : Double;
    xDBConn : PDBWorker;
begin
  Result:= False;   nFreezeMoney:= 0;
  //**************************
  nStr := 'Select * From S_Bill Where L_ID=''' + nBillNo + '''';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount = 1 then
    begin
      nStockNo   := FieldByName('L_StockNo').AsString;
      nOldZhiKaId:= FieldByName('L_Zhika').AsString;

      // ���¾�ֽ����������ֽ��
      UPDateZhiKaBind(nOldZhiKaId, nNewZhiKaPK, nStockNo);
    end
    else nData := '���¶�����Ϣʧ��, δ�ҵ����۶��� ' + nBillNo;
  end;
end;

//Desc: ���۵���Ϣ
function TBusWorkerBusinessNC.SendBillPoundInfo(var nData: string): Boolean;
var nStr, nTime, nProc, nZhiKaPK, nZhiKaDtlPK, nCreator, nHid, nBid : string;
    nCard : string;
    nZhika, nMTime, nMValue, nPValue, nValue : string;
    nRoot, nNode : TXmlNode;
begin
  Result := False;
  try                         exit;
    FListA.Text := PackerDecodeStr(FIn.FData);
    nCard:= FListA.Values['Card'];

    nStr:= 'Select * From S_Bill Where L_ID='''+FListA.Values['ID']+'''';
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

        if FIn.FExtParam='' then
        begin
          FIn.FExtParam:= FormatDateTime('yyyy-MM-dd HH:mm:ss', FieldByName('L_OutFact').AsDateTime)
        end;
      end
      else
      begin
        nData:= 'δ�ҵ����۶��� '+FListA.Values['ID'];
        Exit;
      end;
    end;

    nStr:= 'Select * From S_ZhiKa Where Z_ID='''+nZhika+'''';
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount = 1 then
        nHid:= FieldByName('R_ID').AsString
      else
      begin
        nData:= 'δ�ҵ����� '+FListA.Values['ID'] + ' ��ֽ��������Ϣ';
        Exit;
      end;
    end;

    if FListA.Values['proc']='' then nProc:= 'add'
    else nProc:= FListA.Values['proc'];
    //***********************************************************
    nStr := '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Message billtype="BS0002">' +
            ' <DataRow> ' +
            '   <proc>%s</proc> ' +
            '    <pk_org>%s</pk_org> ' +
            '    <dbilldate>%s</dbilldate> ' +
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
            '    <dr>0</dr> ' +
            ' </DataRow> ' +
            '</Message>';

    nStr := Format(nStr, [nProc, gSysParam.FFactID, nTime, nZhiKaPK, nZhiKaDtlPK,
                           nCreator, FIn.FExtParam, FListA.Values['ID'],
                          nHid, nBid, nValue,
                          nMTime, nMValue, nPValue]);
    WriteLog('���۵��ϴ�NC��'+nStr);
    try
      try
        FNCChannel := GetIDataReceivePortType(False, gSysParam.FSrvRemote);
        nStr := FNCChannel.receiveData('BS0002', 'null', nStr);
        //nStr := SendMsg('BS0002','null', nStr);
        //nStr:= '<?xml version="1.0" encoding="utf-8"?><Info><DataRow><Pk>1001ZZ100000000ETVWR</Pk><Message>δ֪����</Message><Status>-1</Status></DataRow></Info> ';
      except on Ex:Exception do
        begin
          gSysParam.FErrorNum:= gSysParam.FErrorNum + 1;
          if gSysParam.FErrorNum>=10 then gTNCStatusChker.Resume;
          
          nData:= '����NC������'+ Ex.Message;
          WriteLog(nData);
          Exit;
        end;
      end;

      WriteLog('���أ�'+nStr);
      try
        gSysParam.FErrorNum:= 0;
        with FPacker.XMLBuilder do
        begin
          ReadFromString(nStr);
          if not ParseDefault(nData) then Exit;

          nRoot := Root.FindNode('DataRow');
          if not Assigned(nRoot) then
          begin
            nData := '���۵�������������ȱ�ٽڵ� DataRow.';
            Exit;
          end;

          nNode := Root.Nodes[0];
          with nNode do
          begin
            if NodeByName('Status').ValueAsString='-1' then
            begin
              nData := Format('���۵� %s ����ʧ�ܣ�%s', [ FListA.Values['ID'],
                                            NodeByName('Message').ValueAsString]);

              if Pos('<PkNew>', nStr)>0 then
              if NodeByName('PkNew').ValueAsString<>'' then
              begin
                Result := UPDateBills(FListA.Values['ID'], NodeByName('PkNew').ValueAsString, nData);
                FOut.FExtParam:= 'Y';
                // ��Ƿ����ļ�
              end;
            end
            else
            begin
              Result:= True;
              if nCard<>'' then // �м����������ʱ��NCͬ���ɹ�ֱ��д�� ͬ����ʷ��
              begin
                nStr := MakeSQLByStr([SF('N_OrderNo', FListA.Values['ID']),
                        SF('N_Type', 'S'),
                        SF('N_Status', '0'),
                        SF('N_Proc', nProc),
                        SF('N_SyncNum', '1')
                        ], sTable_UPLoadOrderNcHistory, '', True);

                gDBConnManager.WorkerExec(FDBConn, nStr);
              end;
            end;
          end;
        end;
      except
        on Ex:Exception do
        begin
          WriteLog('�������۳�����-->NC �����������ݳ�����'+ Ex.Message);
        end;
      end;
    except
      on Ex:Exception do
      begin
        WriteLog('����NC�ӿڳ�����'+ Ex.Message);
      end;
    end;
  finally
    FOut.FData := sFlag_Yes;
    FOut.FBase.FResult := True;
  end;
end;

//Desc: Nc״̬���
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
        nData := '����NC������' + Ex.Message;
        WriteLog(nData);
        Exit;
      end;
    end;

    if nStr = 'OK' then
    begin
      gSysParam.FErrorNum:= 0;
      Result:= True;
      nStr := 'UPDate Sys_Dict Set D_Value=''OnLine'' Where D_Memo=''NCServiceStatus'' And D_Name= ''SysParam'' ';
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