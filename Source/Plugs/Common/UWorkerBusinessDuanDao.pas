{*******************************************************************************
  ����: 2017-09-22
  ����: �̵�ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessDuanDao;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusiness;

type
  TWorkerBusinessDuanDao = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveDDCard(var nData: string): Boolean;
    function LogoffDDCard(var nData: string): Boolean;

    function SaveDDBase(var nData: string): Boolean;
    function DeleteDDBase(var nData: string): Boolean;
    //�̵��ſ�����ɾ��

    function DeleteDuanDao(var nData: string): Boolean;
    //�̵���ϸɾ��

    function GetPostDDItems(var nData: string): Boolean;
    //��ȡ��λ�̵���
    function SavePostDDItems(var nData: string): Boolean;
    //�����λ�̵���
    function VerifyBeforSave(var nData: string): Boolean;
    //����ǰ��֤��Ϣ
    
    function GetPrePInfo(const nTruck: string; var nPrePValue: Double;
            var nPrePMan: string; var nPrePTime: TDateTime): Boolean;
    //��ȡ����Ԥ��Ƥ����Ϣ
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

//------------------------------------------------------------------------------
class function TWorkerBusinessDuanDao.FunctionName: string;
begin
  Result := sBus_BusinessDuanDao;
end;

constructor TWorkerBusinessDuanDao.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessDuanDao.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessDuanDao.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessDuanDao.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessDuanDao.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveBills         : Result := SaveDDBase(nData);
   cBC_DeleteBill        : Result := DeleteDDBase(nData);
   cBC_DeleteOrder       : Result := DeleteDuanDao(nData);
   cBC_SaveBillCard      : Result := SaveDDCard(nData);
   cBC_LogoffCard        : Result := LogoffDDCard(nData);
   cBC_GetPostBills      : Result := GetPostDDItems(nData);
   cBC_SavePostBills     : Result := SavePostDDItems(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessDuanDao.SaveDDBase(var nData: string): Boolean;
var nStr, nTruck: string;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nTruck := FListA.Values['Truck'];
  //init card
  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  //���ڶ����г����������ӱ�ɹ�������
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if (FieldByName('T_Type').AsString = sFlag_San) then
    begin
      nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
      nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
      Exit;
    end else

    if (FieldByName('T_Type').AsString = sFlag_Dai) and
       (FieldByName('T_InFact').AsString <> '') then
    begin
      nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
      nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
      Exit;
    end else

    if FieldByName('T_Valid').AsString = sFlag_No then
    begin
      nStr := '����[ %s ]���ѳ��ӵĽ�����[ %s ],���ȴ���.';
      nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
      Exit;
    end;
  end;

  //�����Ѿ��ƹ�������ʱ��
  nStr := 'Select * From %s Where B_Truck=''%s'' and B_Card<>'''' ';
  nStr := Format(nStr, [sTable_TransBase, nTruck]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '����[ %s ]�̵�ҵ��[ %s ]δ���ǰ��ֹ����.';
    nData := Format(nStr, [nTruck, FieldByName('B_id').AsString]);
    Exit;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //���泵�ƺ�

  FDBConn.FConn.BeginTrans;
  try
    FListC.Clear;
    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_TransBase;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    nStr := MakeSQLByStr([SF('B_ID', nOut.FData),
            SF('B_Truck', nTruck),
            SF('B_SrcAddr', FListA.Values['SrcAddr']),
            SF('B_DestAddr', FListA.Values['DestAddr']),
            SF('B_CType', FListA.Values['CType']),
            SF('B_IsNei', FListA.Values['IsNei']),
            SF('B_IsSale', FListA.Values['IsSale']),
            SF('B_KDValue', FListA.Values['Value']),

            SF('B_Type', sFlag_San),
            SF('B_StockNo', FListA.Values['StockNO']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_Status', sFlag_BillNew),
            SF('B_IsUsed', sFlag_No),                    

            SF('B_Man', FIn.FBase.FFrom.FUser),
            SF('B_Date', sField_SQLServer_Now, sfVal)
            ], sTable_TransBase, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);


    if FListA.Values['IsSale']= sFlag_Yes then
    begin
      nStr := MakeSQLByStr([
            SF('T_Truck'   , FListA.Values['Truck']),
            SF('T_StockNo' , FListA.Values['StockNO']),
            SF('T_Stock'   , FListA.Values['StockName']),
            SF('T_Type'    , 'S'),
            SF('T_InTime'  , sField_SQLServer_Now, sfVal),
            SF('T_Bill'    , nOut.FData),
            SF('T_Valid'   , sFlag_Yes),
            SF('T_Value'   , FListA.Values['Value'], sfVal),
            SF('T_VIP'     , 'C'),
            SF('T_HKBills' , nOut.FData + '.')
            ], sTable_ZTTrucks, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;

    FOut.FData := nOut.FData;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015/9/19
//Parm: 
//Desc: ɾ���̵����뵥
function TWorkerBusinessDuanDao.DeleteDDBase(var nData: string): Boolean;
var nStr,nP, nCard, nDelZTTruck: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where T_PID=''%s''';
  nStr := Format(nStr, [sTable_Transfer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '�̵����뵥[ %s ]��ʹ�ã���ֹɾ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;


  nStr := 'Select * From %s  Left Join %s On B_ID=T_PId Where B_ID=''%s''';
  nStr := Format(nStr, [sTable_TransBase, sTable_TransferSW, FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if (FieldByName('B_IsSale').AsString = sFlag_Yes) then
    begin
      if (FieldByName('T_PId').AsString<>'') then
      begin
        nData := '�̵����۵�[ %s ]����Ч����ֹɾ��.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      nDelZTTruck := 'Delete From %s Where T_Bill= ''%s''';
      nDelZTTruck := Format(nDelZTTruck, [sTable_ZTTrucks, FIn.FData]);
    end;
  end;

  nStr := 'Select B_Card From %s Where B_ID=''%s''';
  nStr := Format(nStr, [sTable_TransBase, FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nCard := Fields[0].AsString
  else nCard := '';

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_TransBase]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('B_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,B_DelMan,B_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where B_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_TransBaseBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_TransBase), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_TransBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    gDBConnManager.WorkerExec(FDBConn, nDelZTTruck);     //����װ������

    if nCard <> '' then
    begin
      nStr := 'UPDate %s Set T_IDCard=Null Where T_IDCard=''%s''';
      nStr := Format(nStr, [sTable_Truck, nCard]);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      nStr := 'UPDate %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, nCard]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015/9/19
//Parm: 
//Desc: ɾ���̵����뵥
function TWorkerBusinessDuanDao.DeleteDuanDao(var nData: string): Boolean;
var nStr,nP, nBID: string;
    nIdx: Integer;
begin
  nStr := 'Select T_PID From %s Where T_ID=''%s''';
  nStr := Format(nStr, [sTable_Transfer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nBID := Fields[0].AsString
  else nBID := '';

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Transfer]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('T_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,T_DelMan,T_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where T_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_TransferBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_Transfer), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where T_ID=''%s''';
    nStr := Format(nStr, [sTable_Transfer, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := MakeSQLByStr([
            SF('B_TID', ''),
            SF('B_IsUsed', sFlag_No),
            SF('B_Status', sFlag_TruckNone),
            SF('B_NextStatus', sFlag_TruckNone)
            ], sTable_TransBase, SF('B_ID', nBID), False);
    gDBConnManager.WorkerExec(FDBConn, nStr);        

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;


//Date: 2016/2/27
//Parm: 
//Desc: �̵�ҵ�����ſ�
function TWorkerBusinessDuanDao.SaveDDCard(var nData: string): Boolean;
var nSQL, nStr, nTruck: string;
begin
  Result := False;
  //init card

  nSQL := 'Select T_IDCard, T_Truck From $Truck ' +
          ' Inner Join $TransBase on B_Truck=T_Truck ' +
          ' Where B_ID=''$BID''';
  nSQL := MacroValue(nSQL, [MI('$Truck', sTable_Truck),
          MI('$TransBase', sTable_TransBase), MI('$BID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�̵����뵥[ %s ]������.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;  

    nStr := FieldByName('T_IDCard').AsString;
    nTruck := FieldByName('T_Truck').AsString;
    if (nStr <> '') and (FIn.FExtParam <> nStr) then
    begin
      nData := '����[ %s ]�Ѱ���ſ�,��������:' + #13#10#13#10 +
               '��.ԭ�����: %s' + #13#10 +
               '��.�¿����: %s' + #13#10+#13#10 +
               '����ע���ſ�.';
      nData := Format(nData, [nTruck, nStr, FIn.FExtParam]);
      Exit;
    end;  
  end;  

  FDBConn.FConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('B_Card', FIn.FExtParam)
            ], sTable_TransBase, SF('B_ID', FIn.FData), False);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nSQL := 'Update %s Set T_IDCard=''%s'' Where T_Truck =''%s''';
    nSQL := Format(nSQL, [sTable_Truck, FIn.FExtParam, nTruck]);
    gDBConnManager.WorkerExec(FDBConn, nSQL);

    nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if Fields[0].AsInteger < 1 then
    begin
      nSQL := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nSQL := Format('C_Card=''%s''', [FIn.FExtParam]);
      nSQL := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nSQL, False);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2016/2/27
//Parm: 
//Desc: �̵�ҵ��ע���ſ�
function TWorkerBusinessDuanDao.LogoffDDCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set T_IDCard=Null Where T_IDCard=''%s''';
    nStr := Format(nStr, [sTable_Truck, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set B_Card=Null Where B_Card=''%s''';
    nStr := Format(nStr, [sTable_TransBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null ' +
            'Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessDuanDao.GetPostDDItems(var nData: string): Boolean;
var nStr: string;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nNewTransBase : Boolean;
begin
  Result := False;     nNewTransBase:= False;

  nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    if Fields[0].AsString <> sFlag_CardUsed then
    begin
      nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷�ʹ��.';
      nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
      Exit;
    end;

    if Fields[1].AsString = sFlag_Yes then
    begin
      nData := '�ſ�[ %s ]�ѱ�����,�޷�ʹ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  nStr := 'Select a.*, b.T_Truck, IsNull(b.T_PrePUse, ''N'') PrePUse, IsNull(b.T_PValue, 0) PrePValue, '+
                 'IsNull(b.T_PrePMan, '''') PrePMan, IsNull(b.T_PrePTime, GETDATE()) PrePTime  '+
          ' From $TransBase a  Left Join $Truck b On T_Truck=B_Truck ';
  nStr := nStr + 'Where B_Card=''$CD'' ';
  nStr := MacroValue(nStr, [MI('$TransBase', sTable_TransBase),
          MI('$Truck', sTable_Truck),
          MI('$CD', FIn.FData)]);
  //xxxxx
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ſ���[ %s ]û�е��˳���.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    with nBills[0] do
    begin
      FID         := FieldByName('B_TID').AsString;
      if FID = '' then
        FID       := FieldByName('B_ID').AsString;

      FZhiKa      := FieldByName('B_ID').AsString;
      FCusName    := FieldByName('B_SrcAddr').AsString +
                     FieldByName('B_DestAddr').AsString;
      FTruck      := FieldByName('B_Truck').AsString;

      FType       := SFlag_San;
      FStockNo    := FieldByName('B_StockNo').AsString;
      FStockName  := FieldByName('B_StockName').AsString;

      FCard       := FieldByName('B_Card').AsString;
      FStatus     := FieldByName('B_Status').AsString;
      FNextStatus := FieldByName('B_NextStatus').AsString;

      FIsVIP      := FieldByName('B_IsUsed').AsString;
      FValue      := FieldByName('B_Value').AsFloat;
      FIsNei      := FieldByName('B_IsNei').AsString;
      FIsSale     := FieldByName('B_IsSale').AsString;

      FPData.FDate   := FieldByName('B_PDate').AsDateTime;
      FPData.FValue  := FieldByName('B_PValue').AsFloat;
      FPData.FOperator := FieldByName('B_PMan').AsString;


      if FIsVIP <> sFlag_Yes then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;

        IF (FIsNei=sFlag_Yes) then    //  �����ڵ�����
        begin
          FStatus     := sFlag_TruckIn;
          FNextStatus := sFlag_TruckBFP;
          FValue      := 0;

          FPData.FValue  := 0;
          FPData.FOperator := '';

          FMData.FValue  := 0;
          FMData.FOperator := '';

          nNewTransBase:= True;
        end;


        FPrePData:= FieldByName('PrePUse').AsString;
        if (FPrePData=sFlag_Yes) then
        begin
            FPData.FDate    := FieldByName('PrePTime').AsDateTime;
            FPData.FValue   := FieldByName('PrePValue').AsFloat;
            FPData.FOperator:= FieldByName('PrePMan').AsString;

            if FPData.FValue >0 then
            begin
              FStatus     := sFlag_TruckBFP;
              FNextStatus := sFlag_TruckBFM;
            end;
        end;

      end;
      //���������ռ��״̬

      FMemo     := FieldByName('B_SrcAddr').AsString;
      FYSValid  := FieldByName('B_DestAddr').AsString;
      FSelected := True;
    end;
  end;

  if nNewTransBase then
  begin
    FIn.FExtParam := sFlag_TruckIn;
    FIn.FData:= CombineBillItmes(nBills);
    SavePostDDItems(nData);
    nBills[0].FID := FOut.FData;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessDuanDao.SavePostDDItems(var nData: string): Boolean;
var nVal: Double;
    nNeedP: Boolean;
    nSQL,nS,nN, nPdLNo, nLineId, nLineName,nStr: string;
    nInt, nIdx: Integer;
    nPound: TLadingBillItems;
    nOut, nPDOut: TWorkerBusinessCommand;
    nPrePValue: Double;
    nPrePMan  : string;
    nPrePTime : TDateTime;
begin
  Result := False;      nPrePValue:= 0;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //��������

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '��λ[ %s ]�ύ�˶̵�ҵ��ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  nSQL := 'Select B_Status, B_NextStatus From %s Where B_ID=''%s''';
  nSQL := Format(nSQL, [sTable_TransBase, nPound[0].FZhiKa]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�̵����뵥���[ %s ]������,�����°���.';
      nData := Format(nData, [nPound[0].FZhiKa]);
      Exit;
    end;

    nS := Fields[0].AsString;
    nN := Fields[1].AsString;
    //���뵥��ǰ״̬����һ״̬
  end;

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    if nS = sFlag_TruckIn then
    begin
      Result := True;
      Exit;
    end;
    //�볧��¼δ������

    TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nPound[0].FTruck, '', @nOut);
    FOut.FData := nOut.FData;
    //���泵�ƺ�

    nNeedP := False;
    nSQL := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam, sFlag_TransferPound]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
      nNeedP := Fields[0].AsString = sFlag_Yes;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_Transfer;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //�������ɵ���Ϣ���
    with nPound[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckOut;

      if nNeedP then FNextStatus := sFlag_TruckBFP;
      //��Ҫ����
      if nNeedP And (FPrePData=sFlag_Yes)And(FPData.FValue>0) then
      begin
        FStatus := sFlag_TruckBFP;
        FNextStatus := sFlag_TruckBFM;

        //**************************
        FListC.Clear;
        FListC.Values['Group'] := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                FListC.Text, sFlag_Yes, @nPDOut) then
          raise Exception.Create(nPDOut.FData);
        //xxxxx

        nPdLNo := nPDOut.FData;

        nSQL := MakeSQLByStr([
              SF('P_ID', nPdLNo),
              SF('P_Type', sFlag_DuanDao),
              SF('P_Order', nOut.FData),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', 0),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '��ʯ'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);
      end;

      nSQL := MakeSQLByStr([
              SF('T_ID', nOut.FData),
              SF('T_Card', FCard),
              SF('T_Truck', FTruck),
              SF('T_PID', FZhiKa),
              SF('T_SrcAddr', FMemo),
              SF('T_DestAddr', FYSValid),
              SF('T_Type', FType),

              SF('T_StockNo', FStockNo),
              SF('T_StockName', FStockName),
              SF('T_Status', FStatus),
              SF('T_NextStatus', FNextStatus),
              SF('T_InTime', sField_SQLServer_Now, sfVal),
              SF('T_InMan', FIn.FBase.FFrom.FUser),

              SF('T_PValue', FPData.FValue),
              SF('T_PDate', FPData.FDate),
              SF('T_PMan', FPData.FOperator)
              ], sTable_Transfer, '', True);
      FListA.Add(nSQL);


      nSQL := MakeSQLByStr([
              SF('B_TID', nOut.FData),
              SF('B_IsUsed', sFlag_Yes),
              SF('B_Status', FStatus),
              SF('B_NextStatus', FNextStatus),

              //////
              SF('B_Value', FValue),
              SF('B_PValue', FPData.FValue),
              SF('B_PDate', FPData.FDate),
              SF('B_PMan', FPData.FOperator),

              SF('B_MValue', '0'),
              SF('B_MDate', 'Null', sfVal),
              SF('B_MMan', '')

              ], sTable_TransBase, SF('B_ID', FZhiKa), False);
      FListA.Add(nSQL);


      if FIsSale=sFlag_Yes then
      begin
        nSQL := 'UPDate %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
        nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FZhiKa]);
        FListA.Add(nSQL);
        //���¶��г�������״̬
      end;

    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    FListC.Clear;
    FListC.Values['Field'] := 'T_PValue';
    FListC.Values['Truck'] := nPound[0].FTruck;
    FListC.Values['Value'] := FloatToStr(nPound[0].FPData.FValue);

    if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //���泵����ЧƤ��

    //**************************
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //���ذ񵥺�,�������հ�
    with nPound[0] do
    begin
      {$IFDEF DuanDaoCanFH}
      //�����Ҫ���ϳ����Ƿ��ڶ��б������ڵ��ϳ������ŶӼ�¼��
      if FIsSale=sFlag_Yes then
      begin
        nSQL := 'Select * From %s Where T_Truck=''%s''' ;
        nSQL := Format(nSQL, [sTable_ZTTrucks, FTruck]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount = 0 then
        begin
          nSQL := MakeSQLByStr([
                SF('T_Truck'   , FTruck),
                SF('T_StockNo' , FStockNo),
                SF('T_Stock'   , FStockName),
                SF('T_Type'    , 'S'),
                SF('T_InTime'  , sField_SQLServer_Now, sfVal),
                SF('T_InFact'  , sField_SQLServer_Now, sfVal),
                SF('T_Bill'    , FID),
                SF('T_Valid'   , sFlag_Yes),
                SF('T_Value'   , FValue, sfVal),
                SF('T_VIP'     , 'C'),
                SF('T_HKBills' , FID + '.')
                ], sTable_ZTTrucks, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
      end;
      //*****************************************
      {$ENDIF}

      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;

      if (FIsSale=sFlag_Yes) then
      begin
        FNextStatus := sFlag_TruckFH;
      end;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���


      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_DuanDao),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '��ʯ'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('T_Status', FStatus),
              SF('T_NextStatus', FNextStatus),
              SF('T_PValue', FPData.FValue, sfVal),
              SF('T_PDate', sField_SQLServer_Now, sfVal),
              SF('T_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Transfer, SF('T_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('B_Status', FStatus),
              SF('B_NextStatus', FNextStatus),
              SF('B_PValue', FPData.FValue, sfVal),
              SF('B_PDate', sField_SQLServer_Now, sfVal),
              SF('B_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_TransBase, SF('B_ID', FZhiKa), False);
      FListA.Add(nSQL);

                                                 gSysLoger.AddLog(TWorkerBusinessDuanDao, '�̵�ҵ��', ' Ԥ��Ƥ�������'+FPrePData);
      if FPrePData=sFlag_Yes then         // Ԥ��Ƥ�ظ���Ƥ������
      begin
          nSQL := 'UPDate %s Set T_PValue=(ISNULL(T_PValue, 0)*T_PTime+%f)/(ISNULL(T_PTime, 0)+1), T_PrePMan=''%s'','+
                              '  T_PTime=T_PTime+1, T_PrePTime=%s Where T_Truck=''%s'' And T_PrePUse=''%s''';
          nSQL := Format(nSQL,[sTable_Truck, FPData.FValue, FIn.FBase.FFrom.FUser, sField_SQLServer_Now, FTruck, sFlag_Yes]);
          FListA.Add(nSQL);
      end;
    end;

  end else

  if FIn.FExtParam = sFlag_TruckFH then           //�̵��Ż��ֳ�   ����ҵ��
  begin
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([SF('T_Status', sFlag_TruckFH),
              SF('T_NextStatus', sFlag_TruckBFM),
              SF('T_LadeTime', sField_SQLServer_Now, sfVal),
              SF('T_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Transfer, SF('T_ID', FID), False);
      FListA.Add(nSQL);


      nSQL := MakeSQLByStr([
              SF('B_Status', sFlag_TruckFH),
              SF('B_NextStatus', sFlag_TruckBFM)
              ], sTable_TransBase, SF('B_ID', FZhiKa), False);
      FListA.Add(nSQL);


      nSQL := 'Select * From %s Left Join S_ZTLines On Z_ID=T_Line Where T_Truck=''%s''' ;
      nSQL := Format(nSQL, [sTable_ZTTrucks, FTruck]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        nLineId  := FieldByName('Z_ID').AsString;
        nLineName:= FieldByName('Z_Name').AsString;
      end;

      nSQL := 'Insert Into %s (T_ID, T_Card, T_Truck, T_PID, T_StockNo, T_StockName, T_PValue, T_PDate, T_PMan, T_MValue, '+
                              'T_MDate, T_MMan, T_Status, T_NextStatus, T_Value, T_Man, T_Date, T_InTime, T_InMan, T_OutFact, T_OutMan, '+
                              'T_LadeLine, T_LineName, T_LadeTime, T_LadeMan, T_CusName, T_KDValue) '+
              '       Select   T_ID, T_Card, T_Truck, T_PID, T_StockNo, T_StockName, T_PValue, T_PDate, T_PMan, T_MValue, T_MDate, T_MMan, '+
                              'T_Status, T_NextStatus, T_Value, T_Man, T_Date, T_InTime, T_InMan, T_OutFact, T_OutMan, ''%s'', ''%s'', '+
                              'T_LadeTime, T_LadeMan, (T_DestAddr), %.2f'+
              '       From    %s '+
              '       Where   T_ID=''%s''';

      nSQL := Format(nSQL, [ sTable_TransferSW, nLineId, nLineName, FValue, sTable_Transfer, FID]);
      FListA.Add(nSQL);
      //���ɶ̵������¼
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    with nPound[0] do
    begin
      nSQL := SF('P_Order', FID);
      //where

      nVal := FMData.FValue - FPData.FValue;
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
                ], sTable_PoundLog, nSQL, False);
        //����ʱ,����Ƥ�ش�,����Ƥë������
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('T_Status', sFlag_TruckBFM),
                SF('T_NextStatus', sFlag_TruckOut),
                SF('T_PValue', FPData.FValue, sfVal),
                SF('T_PDate', sField_SQLServer_Now, sfVal),
                SF('T_PMan', FIn.FBase.FFrom.FUser),
                SF('T_MValue', FMData.FValue, sfVal),
                SF('T_MDate', DateTime2Str(FMData.FDate)),
                SF('T_MMan', FMData.FOperator),
                SF('T_Value', nVal, sfVal)
                ], sTable_Transfer, SF('T_ID', FID), False);
        FListA.Add(nSQL);

        nSQL := 'UPDate P_TransferSW Set T_KDValue= B_KDValue From P_TransBase '+
                'Where B_ID=T_PID And T_PID='''+FZhiKa+''' And T_ID='''+FID+'''';
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('B_Status', sFlag_TruckBFM),
                SF('B_NextStatus', sFlag_TruckOut),
                SF('B_PValue', FPData.FValue, sfVal),
                SF('B_PDate', sField_SQLServer_Now, sfVal),
                SF('B_PMan', FIn.FBase.FFrom.FUser),
                SF('B_MValue', FMData.FValue, sfVal),
                SF('B_MDate', DateTime2Str(FMData.FDate)),
                SF('B_MMan', FMData.FOperator),
                SF('B_Value', nVal, sfVal)
                ], sTable_TransBase, SF('B_ID', FZhiKa), False);
        FListA.Add(nSQL);

      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nSQL, False);
        //xxxxx
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('T_Status', sFlag_TruckBFM),
                SF('T_NextStatus', sFlag_TruckOut),
                SF('T_MValue', FMData.FValue, sfVal),
                SF('T_MDate', sField_SQLServer_Now, sfVal),
                SF('T_MMan', FIn.FBase.FFrom.FUser),
                SF('T_Value', nVal, sfVal)
                ], sTable_Transfer, SF('T_ID', FID), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('B_Status', sFlag_TruckBFM),
                SF('B_NextStatus', sFlag_TruckOut),
                SF('B_MValue', FMData.FValue, sfVal),
                SF('B_MDate', sField_SQLServer_Now, sfVal),
                SF('B_MMan', FIn.FBase.FFrom.FUser),
                SF('B_Value', nVal, sfVal)
                ], sTable_TransBase, SF('B_ID', FZhiKa), False);
        FListA.Add(nSQL);
      end;

      if (FIsSale=sFlag_Yes) then
      begin
          nSQL := MakeSQLByStr([
                SF('T_Status', sFlag_TruckBFM),
                SF('T_NextStatus', sFlag_TruckOut),
                SF('T_PValue', FPData.FValue, sfVal),
                SF('T_PDate', sField_SQLServer_Now, sfVal),
                SF('T_PMan', FIn.FBase.FFrom.FUser),
                SF('T_MValue', FMData.FValue, sfVal),
                SF('T_MDate', sField_SQLServer_Now, sfVal),
                SF('T_MMan', FIn.FBase.FFrom.FUser),
                SF('T_Value', nVal, sfVal)
                ], sTable_TransferSW, SF('T_ID', FID), False);
          FListA.Add(nSQL);
      end;

      FNextStatus := sFlag_TruckOut;
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FID]);
    //δ��ë�ؼ�¼

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then //����
  begin                          
    if nN = sFlag_TruckOut then
    with nPound[0] do
    begin
      FNextStatus := '';

      nSQL := MakeSQLByStr([
              SF('T_Status', sFlag_TruckOut),
              SF('T_NextStatus', ''),
              SF('T_OutFact', sField_SQLServer_Now, sfVal),
              SF('T_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Transfer, SF('T_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('B_TID', ''),
              SF('B_IsUsed', sFlag_No),
              SF('B_Status', sFlag_TruckOut),
              SF('B_NextStatus', '')                 // sFlag_TruckNone
              ], sTable_TransBase, SF('B_ID', FZhiKa), False);
      FListA.Add(nSQL);

      nSQL := 'Select B_CType, B_IsSale From %s Where B_ID=''%s''';
      nSQL := Format(nSQL, [sTable_TransBase, FZhiKa]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        if Fields[0].AsString <> sFlag_OrderCardG then
        begin
          nSQL := 'Update %s Set T_IDCard=Null Where T_IDCard=''%s''';
          nSQL := Format(nSQL, [sTable_Truck, FCard]);
          FListA.Add(nSQL);

          nSQL := 'Update %s Set T_Card=Null Where T_Card=''%s''';
          nSQL := Format(nSQL, [sTable_Transfer, FCard]);
          FListA.Add(nSQL);

          nSQL := 'Update %s Set B_Card=Null Where B_Card=''%s''';
          nSQL := Format(nSQL, [sTable_TransBase, FCard]);
          FListA.Add(nSQL);

          nSQL := 'Update %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null ' +
                  'Where C_Card=''%s''';
          nSQL := Format(nSQL, [sTable_Card, sFlag_CardInvalid, FCard]);
          FListA.Add(nSQL);
        end;

        if Fields[1].AsString = sFlag_Yes then      //  �̵���������
        begin
          nSQL := 'Delete %s Where T_Truck=''%s''';
          nSQL := Format(nSQL, [sTable_ZTTrucks, FTruck]);
          FListA.Add(nSQL);

          nSQL := MakeSQLByStr([
                  SF('T_Status', sFlag_TruckOut),
                  SF('T_NextStatus', ''),
                  SF('T_OutFact', sField_SQLServer_Now, sfVal),
                  SF('T_OutMan', FIn.FBase.FFrom.FUser)
                  ], sTable_TransferSW, SF('T_ID', FID), False);
          FListA.Add(nSQL);
        end;
      end;
    end;
  end;
  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
    begin
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      //gSysLoger.AddLog(TWorkerBusinessDuanDao, '�̵�ҵ��', FListA[nIdx]);
    end;

    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;


  with nPound[0] do           //  ���ڶ̵��Զ�����
  begin
    if (FIsNei=sFlag_Yes)And(FNextStatus = sFlag_TruckOut) then
    begin
      FIn.FExtParam := sFlag_TruckOut;
      FIn.FData:= CombineBillItmes(nPound);
      SavePostDDItems(nData);
    end;
  end;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessDuanDao.CallMe(const nCmd: Integer;
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

function TWorkerBusinessDuanDao.VerifyBeforSave(
  var nData: string): Boolean;
var
  nStr,nTruck: string;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];

  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  //���ڶ����г����������ӱ�ɹ�������
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if (FieldByName('T_Type').AsString = sFlag_San) then
    begin
      nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
      nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
      Exit;
    end else

    if (FieldByName('T_Type').AsString = sFlag_Dai) and
       (FieldByName('T_InFact').AsString <> '') then
    begin
      nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
      nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
      Exit;
    end else

    if FieldByName('T_Valid').AsString = sFlag_No then
    begin
      nStr := '����[ %s ]���ѳ��ӵĽ�����[ %s ],���ȴ���.';
      nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
      Exit;
    end;
  end;

  //�����Ѿ��ƹ�������ʱ��
  nStr := 'Select * From %s Where B_Truck=''%s'' and B_Card<>'''' ';
  nStr := Format(nStr, [sTable_TransBase, nTruck]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '����[ %s ]��ʱҵ��[ %s ]δ���ǰ��ֹ����.';
    nData := Format(nStr, [nTruck, FieldByName('B_id').AsString]);
    Exit;
  end;

  Result := True;
end;

function TWorkerBusinessDuanDao.GetPrePInfo(const nTruck: string; var nPrePValue: Double;
        var nPrePMan: string; var nPrePTime: TDateTime): Boolean;
var
  nStr:string;
begin
  Result := False;
  nPrePValue := 0;
  nPrePMan := '';
  nPrePTime := now;

  nStr := 'Select T_PrePValue, T_PrePMan, T_PrePTime From %s Where T_truck=''%s'' and T_PrePUse=''%s''';
  nStr := format(nStr,[sTable_Truck, nTruck, sflag_yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount>0 then
    begin
      nPrePValue := FieldByName('T_PrePValue').asFloat;;
      nPrePMan := FieldByName('T_PrePMan').asString;
      nPrePTime := FieldByName('T_PrePTime').asDateTime;
      Result := True;
    end;
  end;
end;


initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessDuanDao, sPlug_ModuleBus);
end.
