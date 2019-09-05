{*******************************************************************************
  ����: dmzn@163.com 2016-12-30
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessBill;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  {$IFDEF MicroMsg}UMgrRemoteWXMsg,{$ENDIF} DateUtils, StrUtils,
  UWorkerBusiness, UBusinessConst, UMgrDBConn, ULibFun, UFormCtrl, UBase64,
  USysLoger, USysDB, UMITConst;

type
  TStockMatchItem = record
    FStock: string;         //Ʒ��
    FGroup: string;         //����
    FRecord: string;        //��¼
  end;

  TBillLadingLine = record
    FBill: string;          //������
    FLine: string;          //װ����
    FName: string;          //������
    FPerW: Integer;         //����
    FTotal: Integer;        //�ܴ���
    FNormal: Integer;       //����
    FBuCha: Integer;        //����
    FHKBills: string;       //�Ͽ���
  end;

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //ɢװ�൥
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //����ƥ��
    FBillLines: array of TBillLadingLine;
    //װ����
    FOnLine : Boolean;
  protected
    procedure WriteBillLog(const nEvent: string);
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //���Ϸ���
    function AllowedSanMultiBill: Boolean;
    function VerifyBeforSave(var nData: string): Boolean;
    function VerifyBeforSaveEx(var nData: string): Boolean;
    function ChkNcServiceStatus: Boolean;
    function SaveBills(var nData: string): Boolean;
    //���潻����
    function DeleteBill(var nData: string): Boolean;
    //ɾ��������
    function ChangeBillTruck(var nData: string): Boolean;
    //�޸ĳ��ƺ�
    function BillSaleAdjust(var nData: string): Boolean;
    //���۵���
    function SaveBillCard(var nData: string): Boolean;
    function SaveBillLSCard(var nData: string): Boolean;
    //�󶨴ſ�
    function LogoffCard(var nData: string): Boolean;
    //ע���ſ�
    function MakeSanPreHK(var nData: string): Boolean;
    //ִ��ɢװԤ�Ͽ�
    function GetPostBillItems(var nData: string): Boolean;
    //��ȡ��λ������
    function BasisWeightBillOutChk(var nBill: TLadingBillItem): Boolean;
    function SavePostBillItems(var nData: string): Boolean;
    //�����λ������
    function AddManualEventRecord(const nEID,nKey,nEvent:string;
             const nFrom: string = sFlag_DepBangFang ;
             const nSolution: string = sFlag_Solution_YN;
             const nDepartmen: string = sFlag_DepDaTing;
             const nReset: Boolean = False; const nMemo: string = ''): Boolean;

  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //��֤�����Ƿ���Ч
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

class function TWorkerBusinessBills.FunctionName: string;
begin
  Result := sBus_BusinessSaleBill;
end;

constructor TWorkerBusinessBills.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessBills.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessBills.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Desc: ��¼nEvent��־
procedure TWorkerBusinessBills.WriteBillLog(const nEvent: string);
begin
  gSysLoger.AddLog(TWorkerBusinessBills, '', nEvent);
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessBills.CallMe(const nCmd: Integer;
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

//Date: 2014-09-15
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveBills           : Result := SaveBills(nData);
   cBC_DeleteBill          : Result := DeleteBill(nData);
   cBC_ModifyBillTruck     : Result := ChangeBillTruck(nData);
   cBC_SaleAdjust          : Result := BillSaleAdjust(nData);
   cBC_SaveBillCard        : Result := SaveBillCard(nData);
   cBC_SaveBillLSCard      : Result := SaveBillLSCard(nData);
   cBC_LogoffCard          : Result := LogoffCard(nData);
   cBC_GetPostBills        : Result := GetPostBillItems(nData);
   cBC_SavePostBills       : Result := SavePostBillItems(nData);
   cBC_MakeSanPreHK        : Result := MakeSanPreHK(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: Ʒ�ֱ��
//Desc: ����nStock��Ӧ�����Ϸ���
function TWorkerBusinessBills.GetStockGroup(const nStock: string): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: Ʒ�ֱ��
//Desc: ����������������nStockͬƷ��,��ͬ��ļ�¼
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock);
  if nStr = '' then Exit;  

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FGroup = nStr then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;
end;

//Date: 2014-09-16
//Parm: ���ƺ�;
//Desc: ��֤nTruck�Ƿ���Ч
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '��Ч�ĳ��ƺų���Ϊ3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower
  
  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('���ƺ�[ %s ]��Ч.', [nTruck]);
      Exit;
    end;
  end;

  Result := True;
end;

//Date: 2014-10-07
//Desc: ����ɢװ�൥
function TWorkerBusinessBills.AllowedSanMultiBill: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SanMultiBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Date: 2014-09-15
//Desc: ��֤�ܷ񿪵�
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx: Integer;
    nSalePlanYu : Double; // x����������ǰ���ɿ�����
    nStr,nTruck, nStockNo, nStockName: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;    {$IFDEF NCSale} ChkNcServiceStatus; {$ENDIF}
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  nStr := 'Select %s as T_Now,T_LastTime,T_NoVerify,T_Valid From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nData := '����[ %s ]������Ա��ֹ����.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;
  end;

  nStockNo  := FListC.Values['StockNo'];
  nStockName:= FListC.Values['StockName'];
  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  {$IFDEF SanPreHK}
  FSanMultiBill := True;
  {$ELSE}
  FSanMultiBill := AllowedSanMultiBill;
  {$ENDIF}//ɢװ�����൥

  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //Ʒ�ַ���ƥ��

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;
  end;

  {$IFDEF ProhibitMultipleOrder}
  nStr := 'Select L_ID From S_Bill Where L_OutFact is Null  AND L_Truck=''%s'' '+
          'Union '+
          'Select O_ID L_ID From P_Order Left Join P_OrderDtl On O_ID=D_OID '+
          'Where D_OutFact is Null AND D_Truck=''%s'' ';
  nStr := Format(nStr, [nTruck, nTruck]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '����[ %s ]��δ��ɶ���[ %s ]֮ǰ��ֹ����.';
    nData := Format(nStr, [nTruck, FieldByName('L_ID').AsString]);
    WriteLog(nData);
    Exit;
  end;
  {$ENDIF}
  ////**********************************************************
  ////**********************************************************
  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);
  //���ڶ����г���

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if (FieldByName('T_Type').AsString = sFlag_San) and (not FSanMultiBill) then
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

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //���泵�ƺ�

  //----------------------------------------------------------------------------
  nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY,sm.S_Name From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $SM sm On sm.S_ID=Z_SaleMan ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$SM', sTable_Salesman),
          MI('$ZID', FListA.Values['ZhiKa'])]);
  //ֽ����Ϣ

  try
    with gDBConnManager.WorkerQuery(FDBConn, nStr),FListA do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('ֽ��[ %s ]�Ѷ�ʧ.', [Values['ZhiKa']]);
        Exit;
      end;

      if FieldByName('Z_Freeze').AsString = sFlag_Yes then
      begin
        nData := Format('ֽ��[ %s ]�ѱ�����Ա����.', [Values['ZhiKa']]);
        Exit;
      end;

      if FieldByName('Z_InValid').AsString = sFlag_Yes then
      begin
        nData := Format('ֽ��[ %s ]�ѱ�����Ա����.', [Values['ZhiKa']]);
        Exit;
      end;

      nStr := FieldByName('Z_TJStatus').AsString;

      {$IFNDEF NoShowPriceChange}
      if nStr  <> '' then
      begin
        if nStr = sFlag_TJOver then
             nData := 'ֽ��[ %s ]�ѵ���,�����¿���.'
        else nData := 'ֽ��[ %s ]���ڵ���,���Ժ󿪵�.';

        nData := Format(nData, [Values['ZhiKa']]);
        Exit;
      end;
      {$ELSE}
      if nStr = sFlag_TJing then
      begin
        nData := 'ֽ��[ %s ]���ڵ���,���Ժ󿪵�.';
        nData := Format(nData, [Values['ZhiKa']]);
        Exit;
      end;
      {$ENDIF}

      if FieldByName('Z_ValidDays').AsDateTime <= Date() then
      begin
        nData := Format('ֽ��[ %s ]����[ %s ]����.', [Values['ZhiKa'],
                 Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
        Exit;
      end;

      Values['Project'] := FieldByName('Z_Project').AsString;
      Values['Area'] := FieldByName('C_Area').AsString;
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
      Values['SaleID'] := FieldByName('Z_SaleMan').AsString;
      Values['SaleMan'] := FieldByName('S_Name').AsString;
      Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
    end;
  except on E:Exception do
    gSysLoger.AddLog(TWorkerBusinessBills, '��ֽ֤���쳣', E.Message);
  end;
  Result := True;
  //verify done
end;

//Date: 2018-08-20
//Desc: ��֤�ܷ񿪵�    ������Ӧ���  ��û������Ʒ�� ���ͻ����� ��ͨ��
function TWorkerBusinessBills.VerifyBeforSaveEx(var nData: string): Boolean;
var nSalePlanYu : Double; // x����������ǰ���ɿ�����
    nStr : string;
    nProhibitCreateBill : Boolean;
begin
  Result := False;  nProhibitCreateBill:= False;
  //----------------------------------------------------------------------------
  nStr := 'Select S_StockNo, S_StockName, S_Value, L_Value, S_ProhibitCreateBill From X_SalePlanStock  ' +
          'Left   Join (     ' +
          '	Select L_StockNo, L_StockName, SUM(L_Value) L_Value From S_Bill ' +
          '	Where  L_date >= CONVERT(varchar(100), GETDATE(), 23)+'' 00:00:00'' And ' +
          '		   L_date <= CONVERT(varchar(100), GETDATE(), 23)+'' 23:59:59'' And  ' +
          '		   L_StockNo=''%s''  ' +
          '	Group  by  L_StockNo, L_StockName  ' +
          ') tl On Tl.L_StockNo=S_StockNo ' +
          'WHERE S_StockName=''%s''  ';

  nStr := Format(nStr, [FListC.Values['StockNo'], FListC.Values['StockName']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    nSalePlanYu:= FieldByName('S_Value').AsFloat - FieldByName('L_Value').AsFloat;
    //ʣ��������

    if RecordCount > 0 then
    begin
      gSysLoger.AddLog(TWorkerBusinessBills, '', 'Ʒ�֣�' + FListC.Values['StockName'] +' ������: '+FieldByName('S_Value').AsString+
            ' �ѷ���: '+FieldByName('L_Value').AsString );


      nProhibitCreateBill:= FieldByName('S_ProhibitCreateBill').AsString=sFlag_Yes;
      // ��ֹδ���ù�Ӧ�ƻ��ͻ�����

      if (StrToFloatDef(FListC.Values['Value'], 0) > nSalePlanYu) then
      begin
        nData := 'Ʒ��[ %s ]��ǰ�Ѵ��Ʒ�����Ӧ����������󿪵���Ϊ�� %.2f�������������.';
        nData := Format(nData, [FListC.Values['StockName'], nSalePlanYu]);
        Exit;
      end;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select C_StockName, C_CusName, C_MaxValue, L_Value  From X_SalePlanCustomer  ' +
          'Left   Join (     ' +
          '	Select L_CusID, L_CusName, L_StockNo, L_StockName, SUM(L_Value) L_Value From S_Bill ' +
          '	Where  L_date >= CONVERT(varchar(100), GETDATE(), 23)+'' 00:00:00'' And ' +
          '		   L_date <= CONVERT(varchar(100), GETDATE(), 23)+'' 23:59:59'' And  ' +
          '		   L_StockNo=''%s'' And L_CusId=''%s''   ' +
          '	Group  by  L_CusID, L_CusName, L_StockNo, L_StockName  ' +
          ') HZ On HZ.L_CusID= C_CusNo And C_StockNo=L_StockNo  ' +
          'WHERE C_StockName=''%s'' And C_CusName=''%s'' ';

  nStr := Format(nStr, [FListC.Values['StockNo'], FListA.Values['CusID'],
                            FListC.Values['StockName'], FListA.Values['CusName']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    nSalePlanYu:= FieldByName('C_MaxValue').AsFloat - FieldByName('L_Value').AsFloat;

    if RecordCount > 0 then
    begin
      gSysLoger.AddLog(TWorkerBusinessBills, '', '�ͻ�[ '+FListA.Values['CusName']+' ]Ʒ��[ '+FListC.Values['StockName']+' ]���ο������� ' +
              FListC.Values['Value'] + ' ����: '+FieldByName('C_MaxValue').AsString+ ' �ѷ���: '+FieldByName('L_Value').AsString );


      if (StrToFloatDef(FListC.Values['Value'], 0) > nSalePlanYu) then
      begin
        nData := '�ͻ�[ %s ]Ʒ��[ %s ]��ǰ�Ѵ�ÿͻ���Ʒ�ֿɷ������ޡ����ɿ�����Ϊ�� %.2f�������������.';
        nData := Format(nData, [FListA.Values['CusName'], FListC.Values['StockName'], nSalePlanYu]);
        Exit;
      end;
    end
    else
    begin
      if nProhibitCreateBill then
      begin
        nData := '����Ա��ֹ �ͻ�[ %s ]Ʒ��[ %s ] ����.';
        nData := Format(nData, [FListA.Values['CusName'], FListC.Values['StockName']]);
        Exit;
      end;
    end;
  end;
  Result := True;
  //verify done
end;

//**** ����ܷ񷢻�
function TWorkerBusinessBills.ChkNcServiceStatus: Boolean;
var nSQL : string;
    nLastTime : TDateTime;   // ����ʱ��
begin
  Result:= False;
  //*****************
  nSQL := 'Select * From %s Where D_Name=''SysParam'' And D_Memo=''NCServiceStatus''  ';
  nSQL := Format(nSQL, [sTable_SysDict]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount > 0 then
    begin
      FOnLine:= (FieldByName('D_Value').AsString='OnLine');
      Result:= True;
    end;
  end;
end;

//Date: 2014-09-15
//Desc: ���潻����
function TWorkerBusinessBills.SaveBills(var nData: string): Boolean;
var nIdx: Integer;
    nVal,nMoney,nProportion: Double;
    nStr,nSQL,nFixMoney, nStockCodeParam, nZhiKaPK, nZhiKaDtlPK: string;
    nStatus, nNextStatus: string;
    nOut, nTmp, nOutX: TWorkerBusinessCommand;
    nList, nListX : TStrings;
    nCanCreateBill:Boolean;
begin
  nList := TStringList.Create;   nStockCodeParam:= '';
  nListX:= TStringList.Create;
  Result:= False;                                                              //gSysLoger.AddLog(TWorkerBusinessBills, '', '���潻����');
  FListA.Text := PackerDecodeStr(FIn.FData);

  if not VerifyBeforSave(nData) then Exit;
  if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FListA.Values['ZhiKa'], '', @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;

  nMoney:= Float2Float((StrToFloat(nOut.FData)), cPrecision, True);
  nFixMoney := nOut.FExtParam;
  //zhika money

  {$IFDEF NCSale}
  if NOT gSysParam.FAllowSale then
  begin
    nData:= '���߳���ʱ���ѳ��޶�������ʱ�䡢�ݲ��ܿ�������֪ͨ������Ա��ʱ����';
    Exit;
  end;

  //���ֽ��״̬
  nSQL := 'Select * From %s Where Z_ID=''%s'' And IsNull(Z_InValid, '''')<>''Y'' And IsNull(Z_Freeze, '''')<>''Y''';
  nSQL := Format(nSQL, [sTable_ZhiKa, FListA.Values['ZhiKa']]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount = 0 then
    begin
      nData := 'ֽ��[ %s ]����Ч�򱻶��ᡢ��ֽ���ݲ��ܿ���.';
      nData := Format(nData, [FListA.Values['ZhiKa']]);
      Exit;
    end;
  end;
  {$ENDIF}

  FListB.Text := PackerDecodeStr(FListA.Values['Bills']);
  //unpack bill list
  nVal := 0;

  for nIdx:=0 to FListB.Count - 1 do
  begin
    FListC.Text := PackerDecodeStr(FListB[nIdx]);
    //get bill info

    with FListC do
      nVal := nVal + Float2Float((StrToFloat(Values['Price'])+StrToFloat(Values['YunFeiPrice'])) *
                      StrToFloat(Values['Value']), cPrecision, True);
    //xxxx
  end;

  {$IFDEF SalePlanCheck}
  if not VerifyBeforSaveEx(nData) then Exit;
  {$ENDIF}

  if FloatRelation(nVal, nMoney, rtGreater) then
  begin
    nData := 'ֽ��[ %s ]��û���㹻�Ľ��,��������:' + #13#10#13#10 +
             '���ý��: %.2f' + #13#10 +
             '�������: %.2f' + #13#10#13#10 +
             '���С��������ٿ���.';
    nData := Format(nData, [FListA.Values['ZhiKa'], nMoney, nVal]);
    Exit;
  end;
  
  {$IFDEF NCSale}
  nCanCreateBill:= False;
  nSQL := 'Select Z_ID, Z_CID, C_ID From %s Left Join  %s on Z_CID=C_ID '+
          'Where Z_ID=''%s'' ';
  nSQL := Format(nSQL, [sTable_ZhiKa, sTable_SaleContract, FListA.Values['ZhiKa']]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount > 0 then
    begin
      nCanCreateBill:= FieldByName('C_ID').AsString<>'';
    end;
  end;
  //*************************************************************************
  //*************************����NC��������ֽ��PK �Լ�ֽ��Ʒ�� PKDtl ********
  nSQL := 'Select Z_ID,D_StockName,Z_PKzk, D_PkDtl From %s Left  Join  %s On Z_ID=D_ZID ' +
          'Where Z_ID=''%s'' And D_StockNo=''%s''';
  nSQL := Format(nSQL, [sTable_ZhiKa, sTable_ZhiKaDtl, FListA.Values['ZhiKa'],
                                                     FListC.Values['StockNo']]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount = 0 then
    begin
      nData := 'ֽ��[ %s ]�������ݲ��ܿ���������ϵ����Ա.';
      nData := Format(nData, [FListA.Values['ZhiKa']]);
      Exit;
    end;
    nZhiKaPK := FieldByName('Z_PKzk').AsString;
    nZhiKaDtlPK := FieldByName('D_PkDtl').AsString;

    if ((nZhiKaPK = '') or (nZhiKaDtlPK = '')) And (not nCanCreateBill) then
    begin
      nData := 'ֽ��[ %s ]��Ϣȱ��PK��Ϣ�ݲ��ܿ���������ϵ����Ա.';
      nData := Format(nData, [FListA.Values['ZhiKa']]);
      Exit;
    end;
  end;
  {$ENDIF}
  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    for nIdx:=0 to FListB.Count - 1 do
    begin
      if Length(FListA.Values['Card']) > 0 then
      begin      //��������ҵ���Դ���������
        nSQL := 'Select L_ID From %s Where L_Card = ''%s'' And L_OutFact Is NULL';
        nSQL := Format(nSQL, [sTable_Bill, FListA.Values['Card']]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        begin
          if RecordCount < 1 then
          begin
            nData := '�޷��ҵ��ſ�[ %s ]��Ӧ����ҵ�񵥺�.';
            nData := Format(nData, [FListA.Values['Card']]);
            Exit;
          end;

          if RecordCount > 1 then
          begin
            nData := '��������ҵ���ֹƴ��.';
            Exit;
          end;
          nOut.FData := Fields[0].AsString;
        end;
      end else   //����ҵ�񣬻�ȡ��������

      begin
        FListC.Values['Group'] :=sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_BillNo;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
              FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx
      end;

      FOut.FData := FOut.FData + nOut.FData + ',';
      //combine bill

      {$IFDEF SendMorefactoryStock}
        begin
          // �������೧�����λ�ȡ
          with nList do
          begin
            Clear;
            Values['StockNO'] := FListC.Values['StockNO'];
            Values['Factory'] := FListA.Values['SendFactory'];
          end;
          nStockCodeParam:= PackerEncodeStr(nList.Text);
          //*******************

          if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcodeEx,
             nStockCodeParam, FListC.Values['Value'], @nTmp) then
             raise Exception.Create(nTmp.FData);
        end;
      {$ELSE}
        begin
          //  ������ȡ����
          FListC.Text := PackerDecodeStr(FListB[nIdx]);
          //get bill info
          if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
             FListC.Values['StockNO'], FListC.Values['Value'], @nTmp) then
             raise Exception.Create(nTmp.FData);
        end;
      {$ENDIF}

        {$IFDEF BatchInHYOfBill}
        if nTmp.FData = '' then
             FListC.Values['HYDan'] := FListC.Values['Seal']
        else FListC.Values['HYDan'] := nTmp.FData;
        {$ELSE}
        if nTmp.FData <> '' then
          FListC.Values['Seal'] := nTmp.FData;
        //auto batcode
        {$ENDIF}

        if PBWDataBase(@nTmp).FErrCode = sFlag_ForceHint then
        begin
          FOut.FBase.FErrCode := sFlag_ForceHint;
          FOut.FBase.FErrDesc := PBWDataBase(@nTmp).FErrDesc;
        end;
        //*************��ȡ���κ���Ϣ

      {$IFDEF RemoteSnap}
        if FListC.Values['SnapTruck']='' then FListC.Values['SnapTruck']:='Y';
      {$ELSE}
        FListC.Values['SnapTruck']:='N';
      {$ENDIF} //�Ƿ���г���ʶ��
      if FListC.Values['IsSample']='' then FListC.Values['IsSample']:='N';
                                                              
      nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
              SF('L_ZhiKa', FListA.Values['ZhiKa']),
              SF('L_Order', FListC.Values['OrderNo']),
              SF('L_Project', FListA.Values['Project']),
              SF('L_Area', FListA.Values['Area']),
              SF('L_CusID', FListA.Values['CusID']),
              SF('L_CusName', FListA.Values['CusName']),
              SF('L_CusPY', FListA.Values['CusPY']),
              SF('L_SaleID', FListA.Values['SaleID']),
              SF('L_SaleMan', FListA.Values['SaleMan']),

              SF('L_Type', FListC.Values['Type']),
              SF('L_StockNo', FListC.Values['StockNO']),
              SF('L_StockName', FListC.Values['StockName']),
              SF('L_Value', FListC.Values['Value'], sfVal),
              SF('L_Price', FListC.Values['Price'], sfVal),
              SF('L_YunFei', FListC.Values['YunFeiPrice'], sfVal),

              //**************** NC ֽ������
              {$IFDEF NCSale}
              SF('L_PKzk', nZhiKaPK),
              SF('L_PkDtl', nZhiKaDtlPK),
              SF('L_BillValue', FListC.Values['Value'], sfVal),
              {$ENDIF}

              {$IFDEF SendMorefactoryStock}
              SF('L_SendFactory', FListA.Values['SendFactory']),
              {$ENDIF} //ʹ��ָ����������

              {$IFDEF PrintGLF}
              SF('L_PrintGLF', FListC.Values['PrintGLF']),
              {$ENDIF} //�Զ���ӡ��·��

              {$IFDEF PrintHYEach}
              SF('L_PrintHY', FListC.Values['PrintHY']),
              {$ENDIF} //�泵��ӡ���鵥

              {$IFDEF RemoteSnap}
              SF('L_SnapTruck', FListC.Values['SnapTruck']),
              {$ENDIF} //�Ƿ���г���ʶ��

              SF('L_ZKMoney', nFixMoney),
              SF('L_Truck', FListA.Values['Truck']),
              SF('L_ICCardNo', FListA.Values['ICCardNo']),                      //  ����
              SF('L_Lading', FListA.Values['Lading']),
              SF('L_IsVIP', FListA.Values['IsVIP']),
              SF('L_Seal', FListC.Values['Seal']),
              SF('L_HYDan', FListC.Values['HYDan']),
              SF('L_Man', FIn.FBase.FFrom.FUser),
              SF('L_IsSample', FListC.Values['IsSample']),
              SF('L_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Bill,SF('L_ID', nOut.FData),FListA.Values['Card']='');
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //���ݿ����������߸�����Ϣ

      {$IFDEF CreateBillCreateHYEach}
      begin
        nListX.Values['Group'] := sFlag_BusGroup;
        nListX.Values['Object']:= sFlag_HYDan;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            nListX.Text, sFlag_Yes, @nOutX) then
          raise Exception.Create(nOutX.FData);
        //xxxxx

        nStr := MakeSQLByStr([SF('H_No', nOutX.FData),
                SF('H_Custom', FListA.Values['CusID']),
                SF('H_CusName', FListA.Values['CusName']),
                SF('H_SerialNo', FListC.Values['HYDan']),
                SF('H_Truck', FListA.Values['Truck']),
                SF('H_Value', FListC.Values['Value'], sfVal),
                SF('H_BillDate', sField_SQLServer_Now, sfVal),
                SF('H_ReportDate', sField_SQLServer_Now, sfVal),
                //SF('H_EachTruck', sFlag_Yes),
                SF('H_Reporter', nOut.FData)], sTable_StockHuaYan, '', True);
        FListA.Add(nStr); //�Զ����ɻ��鵥
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
      {$ENDIF}

      nStr := MakeSQLByStr([
                SF('P_Truck', FListA.Values['Truck']),
                SF('P_CusID', FListA.Values['CusID']),
                SF('P_CusName', FListA.Values['CusName']),
                SF('P_MID', FListC.Values['StockNO']),
                SF('P_MName', FListC.Values['StockName']),
                SF('P_MType', FListC.Values['Type']),
                SF('P_LimValue', FListC.Values['Value'], sfVal)
                ], sTable_PoundLog, SF('P_Bill', nOut.FData), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //���°���������Ϣ

      nStr := 'Update %s Set B_HasUse=B_HasUse+%s Where B_Batcode=''%s''';
          {$IFDEF SendMorefactoryStock}
           nStr := nStr + ' And B_SendFactory='''+FListA.Values['SendFactory']+'''';
          {$endif}       /// ���¶�Ӧ��������
      nStr := Format(nStr, [sTable_StockBatcode, FListC.Values['Value'],
              FListC.Values['HYDan']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //�������κ�ʹ����

      if FListA.Values['Card'] = '' then
      begin
        nStr := MakeSQLByStr([
                SF('L_Status', sFlag_TruckNone)
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
        //�����ɽ�����״̬Ϊδ֪

        if FListC.Values['IsPlan'] = sFlag_Yes then
        begin
          nStr := MakeSQLByStr([
                  SF('S_InterID', FListC.Values['InterID']),
                  SF('S_EntryID', FListC.Values['EntryID']),
                  SF('S_Truck', FListA.Values['Truck']),
                  SF('S_Date', sField_SQLServer_Now, sfVal)
                  ], sTable_K3_SalePlan, '', True);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
        //������ʹ�õ����ۼƻ�
      end;

      if FListA.Values['BuDan'] = sFlag_Yes then //����
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', 0, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_MValue', FListC.Values['Value'], sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser),
                SF('L_OutFact', sField_SQLServer_Now, sfVal),
                SF('L_OutMan', FIn.FBase.FFrom.FUser),
                
                {$IFDEF NCSale}
                SF('L_PKzk', nZhiKaPK),
                SF('L_PkDtl', nZhiKaDtlPK),
                {$ENDIF}

                SF('L_Card', '')
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);

        {$IFDEF NCSale}
        /// ���� ���ϴ�NC ��
        nStr:= MakeSQLByStr([SF('N_OrderNo', nOut.FData), SF('N_Type', 'S'),
                              SF('N_Status', '-1'), SF('N_Proc', 'add')
                        ], sTable_UPLoadOrderNc, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
        {$ENDIF}
      end else
      begin
        if FListC.Values['Type'] = sFlag_San then
        begin
          nStr := '';
          //ɢװ����ϵ�
        end else
        begin
          nStr := FListC.Values['StockNO'];
          nStr := GetMatchRecord(nStr);
          //��Ʒ����װ�������еļ�¼��
        end;

        if nStr <> '' then
        begin
          nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
                  'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
          nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
                  MI('$RD', nStr), MI('$Val', FListC.Values['Value']),
                  MI('$BL', nOut.FData)]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end else
        begin
          nSQL := MakeSQLByStr([
            SF('T_Truck'   , FListA.Values['Truck']),
            SF('T_StockNo' , FListC.Values['StockNO']),
            SF('T_Stock'   , FListC.Values['StockName']),
            SF('T_Type'    , FListC.Values['Type']),
            SF('T_InTime'  , sField_SQLServer_Now, sfVal),
            SF('T_Bill'    , nOut.FData),
            SF('T_Valid'   , sFlag_Yes),
            SF('T_Value'   , FListC.Values['Value'], sfVal),
            SF('T_VIP'     , FListA.Values['IsVIP']),
            SF('T_HKBills' , nOut.FData + '.')
            ], sTable_ZTTrucks, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;

        if Length(FListA.Values['Card']) > 0 then
        begin
          if FListC.Values['Type'] = sFlag_Dai then
          begin
            nSQL := 'Update $Bill Set L_NextStatus=''$NT'' '+
                    'Where L_ID=''$ID''';
            nSQL := MacroValue(nSQL, [MI('$Bill', sTable_Bill),
                    MI('$NT', sFlag_TruckZT),
                    MI('$ID', nOut.FData)]);
            gDBConnManager.WorkerExec(FDBConn, nSQL);
          end;
          //��װ��һ״̬ջ̨

          nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
          nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
                  nOut.FData]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
        //��������ҵ���ѽ���

        {$IFDEF TruckInNow}
        nStatus := sFlag_TruckIn;
        nNextStatus := sFlag_TruckBFP;
        if FListC.Values['Type'] = sFlag_Dai then
        begin
          nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
          nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
           if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
            nNextStatus := sFlag_TruckZT;
          //��װ������
        end;

        nSQL := MakeSQLByStr([
                SF('L_Status', nStatus),
                SF('L_NextStatus', nNextStatus),
                SF('L_InTime', sField_SQLServer_Now, sfVal)
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);

        nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
        nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
                nOut.FData]);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
        {$ENDIF}
      end;
    end;

    if FListA.Values['BuDan'] = sFlag_Yes then //����
    begin
      {$IFDEF BDAUDIT}
      WriteLog('������˹�������,����δ����,�ȴ��������...');
      {$ELSE}
      nStr := 'Update %s Set A_OutMoney=A_OutMoney+%s Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
              FListA.Values['CusID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //freeze money from account
      {$ENDIF}
    end else
    begin
      {$IFNDEF NCSale}
      nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney+%s Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
              FListA.Values['CusID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //freeze money from account
      {$ENDIF}
    end;

    {$IFNDEF NCSale}
    if nFixMoney = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney-%s Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, FloatToStr(nVal),
              FListA.Values['ZhiKa']]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //freeze money from zhika
    end;
    {$ENDIF}

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  {$IFDEF UseERP_K3}
  if FListA.Values['BuDan'] = sFlag_Yes then //����
  try
    nSQL := AdjustListStrFormat(FOut.FData, '''', True, ',', False);
    //bill list

    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill, nSQL, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

  except
    nStr := 'Delete From %s Where L_ID In (%s)';
    nStr := Format(nStr, [sTable_Bill, nSQL]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    raise;
  end;
  {$ENDIF}

  {$IFDEF MicroMsg}
  with FListC do
  begin
    Clear;
    Values['bill'] := FOut.FData;
    Values['company'] := gSysParam.FHintText;
  end;

  if FListA.Values['BuDan'] = sFlag_Yes then
       nStr := cWXBus_OutFact
  else nStr := cWXBus_MakeCard;

  gWXPlatFormHelper.WXSendMsg(nStr, FListC.Text);
  {$ENDIF}
end;

//------------------------------------------------------------------------------
//Date: 2014-09-16
//Parm: ������[FIn.FData];���ƺ�[FIn.FExtParam]
//Desc: �޸�ָ���������ĳ��ƺ�
function TWorkerBusinessBills.ChangeBillTruck(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
begin
  Result := False;
  if not VerifyTruckNO(FIn.FExtParam, nData) then Exit;

  nStr := 'Select L_Truck,L_InTime From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <> 1 then
    begin
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    {$IFNDEF TruckInNow}
    if Fields[1].AsString <> '' then
    begin
      nData := '������[ %s ]�����,�޷��޸ĳ��ƺ�.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    {$ENDIF}

    nTruck := Fields[0].AsString;
  end;

  nStr := 'Select R_ID,T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      SplitStr(Fields[1].AsString, FListC, 0, '.');
      FListA.AddStrings(FListC);
      FListB.Add(Fields[0].AsString);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�����޸���Ϣ

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�

        nStr := 'Update %s Set P_Truck=''%s'' Where P_Bill=''%s''';
        nStr := Format(nStr, [sTable_PoundLog, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ�������¼���ƺ�
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-30
//Parm: ��������[FIn.FData];��ֽ��[FIn.FExtParam]
//Desc: ����������������ֽ���Ŀͻ�
function TWorkerBusinessBills.BillSaleAdjust(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal,nMon: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //init

  //----------------------------------------------------------------------------
  nStr := 'Select L_CusID,L_StockNo,L_StockName,L_Value,L_Price,L_ZhiKa,' +
          'L_ZKMoney,L_OutFact,L_YunFei From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('������[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    if FieldByName('L_OutFact').AsString = '' then
    begin
      nData := '����������(������)���ܵ���.';
      Exit;
    end;

    FListB.Clear;
    with FListB do
    begin
      Values['CusID'] := FieldByName('L_CusID').AsString;
      Values['StockNo'] := FieldByName('L_StockNo').AsString;
      Values['StockName'] := FieldByName('L_StockName').AsString;
      Values['ZhiKa'] := FieldByName('L_ZhiKa').AsString;
      Values['ZKMoney'] := FieldByName('L_ZKMoney').AsString;
    end;

    nVal := FieldByName('L_Value').AsFloat;
    nMon := nVal * (FieldByName('L_Price').AsFloat + FieldByName('L_YunFei').AsFloat);
    nMon := Float2Float(nMon, cPrecision, True);
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY,sm.S_Name From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $SM sm On sm.S_ID=Z_SaleMan ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$SM', sTable_Salesman),
          MI('$ZID', FIn.FExtParam)]);
  //ֽ����Ϣ

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('ֽ��[ %s ]�Ѷ�ʧ.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('ֽ��[ %s ]�ѱ�����Ա����.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('ֽ��[ %s ]�ѱ�����Ա����.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('ֽ��[ %s ]����[ %s ]����.', [FIn.FExtParam,
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;

    FListA.Clear;
    with FListA do
    begin
      Values['Project'] := FieldByName('Z_Project').AsString;
      Values['Area'] := FieldByName('C_Area').AsString;
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
      Values['SaleID'] := FieldByName('Z_SaleMan').AsString;
      Values['SaleMan'] := FieldByName('S_Name').AsString;
      Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Price, D_YunFei From %s Where D_ZID=''%s'' And D_StockNo=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, FIn.FExtParam, FListB.Values['StockNo']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := 'ֽ��[ %s ]��û������Ϊ[ %s ]��Ʒ��.';
      nData := Format(nData, [FIn.FExtParam, FListB.Values['StockName']]);
      Exit;
    end;

    {$IFNDEF NCSale}
    FListC.Clear;
    nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListB.Values['CusID']]);
    FListC.Add(nStr); //��ԭ���������

    if FListB.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) ' +
              'Where Z_ID=''%s'' And Z_OnlyMoney=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon,
              FListB.Values['ZhiKa'], sFlag_Yes]);
      FListC.Add(nStr); //��ԭ�����������
    end;
    {$ENDIF}

    nMon := nVal * (FieldByName('D_Price').AsFloat + FieldByName('D_YunFei').AsFloat);
    nMon := Float2Float(nMon, cPrecision, True);

    if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FIn.FExtParam, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    if FloatRelation(nMon, StrToFloat(nOut.FData), rtGreater, cPrecision) then
    begin
      nData := '�ͻ�[ %s.%s ]����,��������:' + #13#10#13#10 +
               '��.�������: %.2fԪ' + #13#10 +
               '��.��������: %.2fԪ' + #13#10 +
               '��.�� �� ��: %.2fԪ' + #13#10#13#10 +
               '�뵽�����Ұ���"��������"����,Ȼ���ٴε���.';
      nData := Format(nData, [FListA.Values['CusID'], FListA.Values['CusName'],
               StrToFloat(nOut.FData), nMon,
               Float2Float(nMon - StrToFloat(nOut.FData), cPrecision, True)]);
      Exit;
    end;

    {$IFNDEF NCSale}
    nStr := 'Update %s Set A_OutMoney=A_OutMoney+(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListA.Values['CusID']]);
    FListC.Add(nStr); //���ӵ���������

    if FListA.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon, FIn.FExtParam]);
      FListC.Add(nStr); //�ۼ�������������
    end;
    {$ENDIF}

    nStr := MakeSQLByStr([SF('L_ZhiKa', FIn.FExtParam),
            SF('L_Project', FListA.Values['Project']),
            SF('L_Area', FListA.Values['Area']),
            SF('L_CusID', FListA.Values['CusID']),
            SF('L_CusName', FListA.Values['CusName']),
            SF('L_CusPY', FListA.Values['CusPY']),
            SF('L_SaleID', FListA.Values['SaleID']),
            SF('L_SaleMan', FListA.Values['SaleMan']),
            SF('L_Price', FieldByName('D_Price').AsFloat, sfVal),
            SF('L_YunFei', FieldByName('D_YunFei').AsFloat, sfVal),
            SF('L_ZKMoney', FListA.Values['ZKMoney'])
            ], sTable_Bill, SF('L_ID', FIn.FData), False);
    FListC.Add(nStr); //���ӵ���������
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Desc: ͬ��NC���� ������
function CallBusinessSaleBillToNC(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nIn.FBase.FParam := sParam_NoHintOnError;
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessNC);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);
    if not Result then
      gSysLoger.AddLog(TWorkerBusinessBills, '֪ͨNC����:', nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

function CallBusinessSaleBillToNCEx(const nCmd: Integer; const nData, nExt: string;
  const nOut: PWorkerBusinessCommand): Boolean;
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

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessNC);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else
    begin
      nOut.FData:= nStr;
      gSysLoger.AddLog(TWorkerBusinessBills, '֪ͨNC����:', nOut.FBase.FErrDesc);
    end
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-16
//Parm: ��������[FIn.FData]
//Desc: ɾ��ָ��������
function TWorkerBusinessBills.DeleteBill(var nData: string): Boolean;
var nIdx: Integer;
    nHasOut: Boolean;
    nVal,nMoney: Double;
    nStr,nP,nFix,nRID,nCus,nBill,nZK,nHY,nFact: string;
    nListBill : TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //init
  nStr := ' Select L_ZhiKa,L_Value,L_Price,L_YunFei,L_CusID,L_OutFact,L_ZKMoney,L_HYDan,L_EmptyOut,L_Status ' +
          {$IFDEF SendMorefactoryStock} ',L_SendFactory ' + {$ENDIF}
          ' From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if (FieldByName('L_EmptyOut').AsString = 'Y') then
    begin
      nData := '�����[ %s ]Ϊ�ճ�����,������ɾ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';

    //�ѳ���
    if nHasOut and ((FIn.FBase.FFrom.FUser<>'admin')or(FIn.FBase.FFrom.FUser<>'����')) then
    begin
      nData := '������[ %s ]�ѳ���,�ǹ���Ա������ɾ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nCus := FieldByName('L_CusID').AsString;
    nHY  := FieldByName('L_HYDan').AsString;
    nZK  := FieldByName('L_ZhiKa').AsString;
    nFix := FieldByName('L_ZKMoney').AsString;

    {$IFDEF SendMorefactoryStock}
    nFact := FieldByName('L_SendFactory').AsString;
    {$ENDIF}

    nVal := FieldByName('L_Value').AsFloat;
    nMoney := Float2Float(nVal*(FieldByName('L_Price').AsFloat+FieldByName('L_YunFei').AsFloat), cPrecision, True);
  end;

  {$IFDEF NCSale}
  if nHasOut then   ///   ����ѳ��� ����ɾ��NC ����  ��NC �������᷵��ʧ��
  begin
    nListBill:= TStringList.Create;
    try
      nListBill.Clear;
      nListBill.Values['ID']  := FIn.FData;
      nListBill.Values['Proc']:= 'delete';
      //*******************
      if not CallBusinessSaleBillToNC(cBC_SendToNcBillInfo, PackerEncodeStr(nListBill.Text), '', @nOut) then
      begin
        nData:= nOut.FData;
        Exit;
      end;
    finally
      nListBill.Free;
    end;
  end;
  {$ENDIF}


  nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
          'Where T_HKBills Like ''%%%s%%''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if RecordCount <> 1 then
    begin
      nData := '������[ %s ]�����ڶ�����¼��,�쳣��ֹ!';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nRID := Fields[0].AsString;
    nBill := Fields[2].AsString;
    SplitStr(Fields[1].AsString, FListA, 0, '.')
  end else
  begin
    nRID := '';
    FListA.Clear;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FListA.Count = 1 then
    begin
      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nRID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else

    if FListA.Count > 1 then
    begin
      nIdx := FListA.IndexOf(FIn.FData);
      if nIdx >= 0 then
        FListA.Delete(nIdx);
      //�Ƴ��ϵ��б�

      if nBill = FIn.FData then
        nBill := FListA[0];
      //����������

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //���ºϵ���Ϣ
    end;

    //--------------------------------------------------------------------------
    {$IFNDEF NCSale}
    if nHasOut then
    begin
      nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //�ͷų���
    end else
    begin
      nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //�ͷŶ����
    end;

    if nFix = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMoney, nZK]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //�ͷ�������
    end;
    {$ENDIF}

    nStr := 'Update %s Set B_HasUse=B_HasUse-%.2f Where B_Batcode=''%s''';
        {$IFDEF SendMorefactoryStock}
         nStr := nStr + ' And B_SendFactory='''+nFact+'''';
        {$endif}
    nStr := Format(nStr, [sTable_StockBatcode, nVal, nHY]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�ͷ�ʹ�õ����κ�

    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('L_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
            'Select $FL,''$User'',$Now From $BI Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$BI', sTable_Bill), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    {$IFDEF DelBillNeedReson}
    nStr := 'UPDate %s Set L_DelReson=''%s''  Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_BillBak, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    {$ENDIF}

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: ������[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�������󶨴ſ�
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�������б�

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('������[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '������[ %s ]�ѳ���,��ֹ�쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '������[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then
      begin
        if nStr = sFlag_San then
             nData := '������[ %s ]ͬΪɢװ,���ܲ���.'
        else nData := '������[ %s ]��ˮ�����Ͳ�һ��,���ܲ���.';
          
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //����ʹ�õĴſ�
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  SplitStr(FIn.FData, FListA, 0, ',');
  //�������б�
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //�ſ��б�

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if (nStr <> sFlag_Dai) or ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '����[ %s ]����ʹ�øÿ�,�޷�����.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '����[ %s ]����ʹ�øÿ�,��ͬ�ƺŲ��ܲ���.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select T_HKBills From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_ZTTrucks, nTruck]);

  //���ڶ����г���
  nStr := '';
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    try
      nStr := nStr + Fields[0].AsString;
    finally
      Next;
    end;

    nStr := Copy(nStr, 1, Length(nStr)-1);
    nStr := StringReplace(nStr, '.', ',', [rfReplaceAll]);
  end; 

  nStr := AdjustListStrFormat(nStr, '''', True, ',', False);
  //�����н������б�

  nSQL := 'Select L_Card From %s Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      if (Fields[0].AsString <> '') and
         (Fields[0].AsString <> FIn.FExtParam) then
      begin
        nData := '����[ %s ]�Ĵſ��Ų�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.�����ſ�: [%s]' + #13#10 +
                 '*.�����ſ�: [%s]' + #13#10#13#10 +
                 '��ͬ�ſ��Ų��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [nTruck, FIn.FExtParam, Fields[0].AsString]);
        Exit;
      end;

      Next;
    end;  
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //���¼����б�

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2016-12-30
//Parm: ���ƺ�[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: ���ɳ����ĳ������������¼
function TWorkerBusinessBills.SaveBillLSCard(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nStr := 'Select T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '����[ %s ]���е���[ %s ]δ���,���ܰ���ſ�.';
    nData := Format(nStr, [FIn.FData, Fields[0].AsString]);
    Exit;
  end;

  FListC.Values['Group'] :=sFlag_BusGroup;
  FListC.Values['Object'] := sFlag_BillNo;
  //to get serial no

  if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then
    raise Exception.Create(nOut.FData);
  //xxxxx

  FOut.FData := nOut.FData;
  //bill no

  FDBConn.FConn.BeginTrans;
  try
    nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
            SF('L_Card', FIn.FExtParam),
            SF('L_CusID', sFlag_LSCustomer),
            SF('L_CusName', '���ۿͻ�_����'),

            SF('L_Type', sFlag_San),
            SF('L_StockNo', sFlag_LSStock),
            SF('L_StockName', '��������_����'),
            SF('L_Value', 0, sfVal),
            SF('L_Price', 0, sfVal),

            SF('L_Truck', FIn.FData),
            SF('L_Status', sFlag_BillNew),
            SF('L_Man', FIn.FBase.FFrom.FUser),
            SF('L_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Bill, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
    nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_Sale),
            SF('C_Freeze', sFlag_No),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, nStr, False);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData]
//Desc: ע���ſ�
function TWorkerBusinessBills.LogoffCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Card=Null Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-07-04
//Parm: �������[FIn.FData];�Ͽ���[FIn.FExtParam]
//Desc: ��Ԥ�ȹ�����ֽ���п۳�������
function TWorkerBusinessBills.MakeSanPreHK(var nData: string): Boolean;
var nStr: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;

  Result := False;
  try
    nStr := 'Select * From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '�����[ %s ]��ʧ,�Ͽ�ʧ��';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      with nListA do
      begin
        Clear;
        Values['BillID']   := FIn.FData;
        Values['BillCard'] := FieldByName('L_Card').AsString;
        //ԭ����

        Values['Truck']    := FieldByName('L_Truck').AsString;
        Values['Lading']   := FieldByName('L_Lading').AsString;
        Values['IsVIP']    := FieldByName('L_IsVIP').AsString;
        Values['BuDan']    := sFlag_No;
      end;

      with nListB do
      begin
        Clear;
        Values['Type']      := FieldByName('L_Type').AsString;
        Values['StockNO']   := FieldByName('L_StockNo').AsString;
        Values['StockName'] := FieldByName('L_StockName').AsString;

        Values['Seal']      := FieldByName('L_Seal').AsString;
        Values['PrintGLF']  := FieldByName('L_PrintGLF').AsString;
        Values['PrintHY']   := FieldByName('L_PrintHY').AsString;
      end;
    end;

    nStr := 'Select H_ZhiKa,D_StockNo,D_Price From %s hk ' +
            ' Left Join %s zd on zd.D_ZID=hk.H_ZhiKa ' +
            'Where H_Bill=''%s''';
    nStr := Format(nStr, [sTable_BillHK, sTable_ZhiKaDtl, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '����[ %s ]����[ %s ]��,�����ֽ��';
        nData := Format(nData, [nListA.Values['Truck'], FIn.FExtParam]);
        Exit;
      end;

      First;
      nListA.Values['ZhiKa'] := FieldByName('H_ZhiKa').AsString;
    
      while not Eof do
      begin
        if FieldByName('D_StockNo').AsString = nListB.Values['StockNO'] then
        begin
          nListB.Values['Price'] := FieldByName('D_Price').AsString;
          nListB.Values['Value'] := FIn.FExtParam;

          nListA.Values['Bills'] := PackerEncodeStr(PackerEncodeStr(nListB.Text));
          Break;
        end;

        Next;
      end;

      if nListB.Values['Price'] = '' then
      begin
        nData := '����[ %s ]���� %s ��,���ϵ�ֽ����û��[ %s ]Ʒ��.';
        nData := Format(nData, [nListA.Values['Truck'], FIn.FExtParam,
                 nListB.Values['StockName']]);
        Exit;
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := PackerEncodeStr(nListA.Text);
    if not TWorkerBusinessBills.CallMe(cBC_SaveBills, nStr, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    FDBConn.FConn.BeginTrans;
    try
      nListA.Values['HKBill'] := nOut.FData;
      //�Ͽ����ɵĵ���

      nStr := MakeSQLByStr([SF('L_Card', nListA.Values['BillCard']),
              SF('L_Status', sFlag_TruckBFM),
              SF('L_NextStatus', sFlag_TruckOut),
              SF('L_PValue', '0', sfVal),
              SF('L_MValue', FIn.FExtParam, sfVal),
              SF('L_Man', FIn.FData + '-�ϵ�')
              ], sTable_Bill, SF('L_ID', nListA.Values['HKBill']), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      nStr := 'Update %s Set H_HKBill=''%s'' Where H_Bill=''%s''';
      nStr := Format(nStr, [sTable_BillHK, nListA.Values['HKBill'],
              nListA.Values['BillID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      FDBConn.FConn.CommitTrans;
      Result := True;
    except
      on E: Exception do
      begin
        nData := '����[ %s ]�ϵ�ʧ��,����: %s';
        nData := Format(nData, [nListA.Values['Truck'], E.Message]);
        FDBConn.FConn.RollbackTrans;

        TWorkerBusinessBills.CallMe(cBC_DeleteBill, nOut.FData, '', @nOut);
        //ɾ�������
      end;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessBills.GetPostBillItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsBill: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsBill := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsBill := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //ǰ׺�ͳ��ȶ����㽻�����������,����Ϊ��������
  end;

  if not nIsBill then
  begin
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
        nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷����.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '�ſ�[ %s ]�ѱ�����,�޷����.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
          'L_StockName,L_Truck,L_Value,L_Price,L_YunFei,L_ZKMoney,L_Status,' +
          'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,L_PrintHY,' +
          'L_HYDan, L_EmptyOut,L_SnapTruck,L_IsSample,L_BillValue '+

            {$IFDEF ChkSaleCardInTimeOut}      // ���۽�����ʱ���
              ',DATEDIFF(MINUTE, L_Date, GETDATE()) InTimeDiff '+   {$ENDIF}
            {$IFDEF BasisWeightWithPM}
            ',L_IsBasisWeightWithPM '+     {$ENDIF}

          'From $Bill  ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where L_ID=''$CD'''
  else nStr := nStr + 'Where L_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '������[ %s ]����Ч.'
      else nData := '�ſ���[ %s ]û�н�����.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('L_ID').AsString;
      FZhiKa      := FieldByName('L_ZhiKa').AsString;
      FCusID      := FieldByName('L_CusID').AsString;
      FCusName    := FieldByName('L_CusName').AsString;
      FTruck      := FieldByName('L_Truck').AsString;

      FType       := FieldByName('L_Type').AsString;
      FStockNo    := FieldByName('L_StockNo').AsString;
      FStockName  := FieldByName('L_StockName').AsString;
      FValue      := FieldByName('L_Value').AsFloat;
      FPrice      := FieldByName('L_Price').AsFloat;
      FYunfei     := FieldByName('L_YunFei').AsFloat;
      FBillValue  := FieldByName('L_BillValue').AsFloat;

      FCard       := FieldByName('L_Card').AsString;
      FIsVIP      := FieldByName('L_IsVIP').AsString;
      FStatus     := FieldByName('L_Status').AsString;
      FNextStatus := FieldByName('L_NextStatus').AsString;

      FHYDan      := FieldByName('L_HYDan').AsString;
      FPrintHY    := FieldByName('L_PrintHY').AsString = sFlag_Yes;

      FSnapTruck  := FieldByName('L_SnapTruck').AsString = sFlag_Yes;

      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FYSValid      := FieldByName('L_EmptyOut').AsString;
      FIsSample     := FieldByName('L_IsSample').AsString;
      {$IFDEF ChkSaleCardInTimeOut}
      FMinuteDate   := FieldByName('InTimeDiff').AsInteger;
      {$ENDIF}

      {$IFDEF BasisWeightWithPM}
      FIsBasisWeight:= FieldByName('L_IsBasisWeightWithPM').AsString= sFlag_Yes;
      {$ENDIF}

      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

function TWorkerBusinessBills.AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom,nSolution,nDepartmen: string;
 const nReset: Boolean; const nMemo: string): Boolean;
var nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  if Trim(nSolution) = '' then
  begin
    WriteLog('��ѡ������.');
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

//��׼���,���¾��� �ʽ�У��
function TWorkerBusinessBills.BasisWeightBillOutChk(var nBill: TLadingBillItem): Boolean;
var nOut: TWorkerBusinessCommand;
    nStr, nData, nSQL, nFactory: string;
    nVal, nMVal, m, f, nEmpTruckWc, nNewValue : Double;
    nFixMoney : Boolean;
begin
  Result:= False;
  nEmpTruckWc:= 0;  nNewValue:= 0;
  try
    with nBill do
    begin
      if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
                  FZhiKa, '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
      nFixMoney := nOut.FExtParam=sFlag_Yes;
      //*******************************************************************
      nStr := 'Select * From %s Where D_Name=''%s'' And D_Memo=''EmpTruckWuCha'' ';
      nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha, sFlag_PEmpTWuCha]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount>0 then nEmpTruckWc:= FieldbyName('D_Value').AsFloat;
      end;

      nVal := FMData.FValue * 1000 - FPData.FValue * 1000;
      if (Abs(nVal)<= nEmpTruckWc) and (FIsSample<>sFlag_Yes) then
      begin
        // �ж�Ϊ�ճ�����
        WriteLog(Format('���װ���������� ���ţ�%s ����Ʒ���������أ�%.2f ���� ���ճ�������׼ %.2f ������Կճ�������ʾ',
                            [FID, nVal, nEmpTruckWc]));
        FYSValid:= 'Y';
        FValue:= 0;
        //*****************  //�ճ����������� ë��=Ƥ�� �����Ϊ0
        nSQL := 'UPDate %s Set L_EmptyOut=''Y'', L_Value=0, L_MValue=L_PValue Where L_ID=''%s''  ';
        nSQL := Format(nSQL, [sTable_Bill, FID]);
        FListA.Add(nSQL);  nSQL:= ''; //���³���
      end;

      if FYSValid=sFlag_Yes then    ///  �ճ�������
      begin
        nVal := Float2Float((FPrice+FYunFei) * FValue, cPrecision, False);
        {$IFNDEF NCSale}
        if nFixMoney then
        begin
          nSQL := 'UPDate %s Set Z_FixedMoney=Z_FixedMoney+%s Where Z_ID=''%s''';
          nSQL := Format(nSQL, [sTable_ZhiKa, FloatToStr(nVal), FZhiKa]);
          //xxxxx
          FListA.Add(nSQL); nSQL:= '';
        end;   //�ͷ�������

        nSQL := 'UPDate %s Set A_FreezeMoney=A_FreezeMoney-%s Where A_CID=''%s''';
        nSQL := Format(nSQL, [sTable_CusAccount, FloatToStr(nVal), FCusID]);
        FListA.Add(nSQL);   nSQL:= '';
        //�ͷŶ����
        {$ENDIF}


        {$IFDEF SendMorefactoryStock}
        nSQL := ' Select L_HYDan, L_SendFactory From %s Where L_ID=''%s'' ';
        nSQL := Format(nSQL, [sTable_Bill, FID]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          nFactory:= Fields[1].AsString;
        end;
        {$ENDIF}

        nSQL := 'UPDate %s Set B_HasUse=B_HasUse-%.2f Where B_Batcode=''%s''';
        nSQL := Format(nSQL, [sTable_StockBatcode, FValue, FHYDan]);
          {$IFDEF SendMorefactoryStock}
          nSQL := nSQL + ' And B_SendFactory='''+nFactory+'''';
          {$endif}
        FListA.Add(nSQL);   nSQL:= '';
        //�ͷ�ʹ�õ����κ�
      end
      else
      begin   //   �ǿճ�������
        {$IFNDEF NCSale}
        //------------------------------------------------------------------------
        //��׼���,���¾���
        nVal := StrToFloat(nOut.FData) + ((FPrice+FYunFei) * FValue);
        //ֽ�����ý�: ʣ���� + ����������
        nVal := Float2Float(nVal, cPrecision, False);

        nStr := 'Select (L_MValue-L_PValue),(L_Price+IsNull(L_YunFei, 0)) From %s Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FID]);
        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        begin
            if RecordCount < 1 then
            begin
              nData := Format('������[ %s ]�Ѷ�ʧ', [FID]);
              WriteLog(nData);
              Exit;
            end;

            nNewValue:= Fields[0].AsFloat;
            nMVal := Fields[0].AsFloat;
            m := Float2Float(nMVal * Fields[1].AsFloat, cPrecision, True);
            //������ʵ���ܶ�

            if nVal < m then
            begin
              nSQL := FID + sFlag_ManualF;
              nStr := 'Select Count(*) From %s Where E_ID=''%s''';
              nStr := Format(nStr, [sTable_ManualEvent, nSQL]);

              f := gDBConnManager.WorkerQuery(FDBConn, nStr).Fields[0].AsInteger;
              //�¼��Ƿ����

		          nData := '����[ %s ]����,��������:' + #13#10#13#10 +
		                  '��.���ݱ��: %s' + #13#10 +
		                  '��.����ܶ�: %.2f��,%.2fԪ' + #13#10 +
		                  '��.���ý��: %.2fԪ' + #13#10 +
		                  '��.�貹���: %.2fԪ';
		          nData := Format(nData, [FTruck, FID, nMVal, m, nVal, m-nVal]);
		
		          nSQL := MakeSQLByStr([
		                  SF_IF([SF('E_ID', nSQL), ''], f < 1),
		                  SF_IF([SF('E_Key', FTruck), ''], f < 1),
		                  SF_IF([SF('E_From', '�����Ÿ�'), ''], f < 1),
		                  SF_IF([SF('E_Result', 'Null', sfVal), ''], f < 1),
		
		                  SF('E_Event', nData), //�����¼�
		                  SF_IF([SF('E_Solution', sFlag_Solution_OK), ''], f < 1),
		                  SF_IF([SF('E_Departmen', sFlag_DepDaTing), ''], f < 1),
		                  SF_IF([SF('E_Date', sField_SQLServer_Now, sfVal), ''], f < 1)
		                  ], sTable_ManualEvent, SF('E_ID', nSQL), f < 1);
		          //xxxxx

              gDBConnManager.WorkerExec(FDBConn, nSQL);
              Exit;
            end;
        end;

        m := m - Float2Float((FPrice+FYunFei) * FValue, cPrecision, True);
        //������: �ܶ� - ������

        if nFixMoney then     // ����ֽ��
        begin
          nSQL := 'UPDate %s Set Z_FixedMoney=Z_FixedMoney-(%.2f) Where Z_ID=''%s''';
          nSQL := Format(nSQL, [sTable_ZhiKa, m, FZhiKa]);
          FListA.Add(nSQL); //����ֽ����������
        end;

        nSQL := 'UPDate %s Set A_OutMoney=A_OutMoney+(%.2f) Where A_CID=''%s''';
        nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
        FListA.Add(nSQL); //���³�����
        {$ENDIF}

        nSQL := ' Select L_HYDan From %s Where L_ID=''%s'' ';
        {$IFDEF SendMorefactoryStock}
        nSQL := ' Select L_HYDan, L_SendFactory From %s Where L_ID=''%s'' ';
        {$ENDIF}
        nSQL := Format(nSQL, [sTable_Bill, FID]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
            nSQL := 'UPDate %s Set B_HasUse=B_HasUse+(%.2f - %.2f) ' +
                    'Where B_Batcode=''%s''';
            nSQL := Format(nSQL, [sTable_StockBatcode, nNewValue, FValue,
                    Fields[0].AsString]);
              {$IFDEF SendMorefactoryStock}
              nSQL := nSQL + ' And B_SendFactory='''+Fields[1].AsString+'''';
              {$endif}
            FListA.Add(nSQL);
        end;
        //�������κ�ʹ�������
      end;

      Result:= True;
    end;
  except
    on Ex:Exception do
    WriteLog(Format('��׼���װ�������������ʽ�У�鷢���쳣��%s', [Ex.Message]));
  end;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nP,nSQL,nTmp,nFixMoney, nFactory,nOutFactTime, nHDInfo,
    nCusID, nCusName, nEMsg, nZKID, nPKzk, nPKDtl, nNewPrice, nNewYunFei,
    nBillNo : string;

    f,m,nVal,nMVal,nTrueVal,nNeedJK, nYMValue,nNewBillValue: Double;
    i,nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nPrice, nYunFei, nMoney : Double;
    nOut: TWorkerBusinessCommand;
    nPriceChanged, nTail:Boolean;
begin
  Result := False;    nPriceChanged:= False;  nNewBillValue:= 0;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  {$IFNDEF SanPreHK}
  if (nBills[0].FType = sFlag_San) and (nInt > 1) then
  begin
    nData := '��λ[ %s ]�ύ��ɢװ�ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
  {$ENDIF}

  FListA.Clear;
  //���ڴ洢SQL�б�
  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    with nBills[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckBFP;
    end;

    if nBills[0].FType = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        nBills[0].FNextStatus := sFlag_TruckZT;
      //��װ������
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nStr := SF('L_ID', nBills[nIdx].FID);
      nSQL := MakeSQLByStr([
              SF('L_Status', nBills[0].FStatus),
              SF('L_NextStatus', nBills[0].FNextStatus),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nBills[nIdx].FID]);
      FListA.Add(nSQL);
      //���¶��г�������״̬
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

    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '��λ[ %s ]�ύ��Ƥ������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    //--------------------------------------------------------------------------
    FListC.Clear;
    FListC.Values['Field'] := 'T_PValue';
    FListC.Values['Truck'] := nBills[nInt].FTruck;
    FListC.Values['Value'] := FloatToStr(nBills[nInt].FPData.FValue);

    if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //���泵����ЧƤ��

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckBFP;
      if FType = sFlag_Dai then
           FNextStatus := sFlag_TruckZT
      else FNextStatus := sFlag_TruckFH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���

      nSQL := MakeSQLByStr([
              SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := nOut.FData;
      //���ذ񵥺�,�������հ�

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', FID),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FValue),
              SF('P_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', nBills[nInt].FFactory),
              SF('P_PStation', nBills[nInt].FPData.FStation),
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //ջ̨�ֳ�
  begin
    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPData.FValue > 0 then
    begin
      nInt := nIdx;
      Break;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //�ѳ�Ƥ
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_EmptyOut', FYSValid),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //���¶��г������״̬
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //�Ż��ֳ�
  begin                                                                         
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_EmptyOut', FYSValid),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //���¶��г������״̬
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    nInt := -1;  nZKID:= ''; nPKzk:= ''; nPKDtl:= ''; nNewPrice:= ''; nNewYunFei:= ''; nHDInfo:= '';
    nMVal := 0;  nTail:= False;   nBillNo:= '';

    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nMVal := nBills[nIdx].FMData.FValue;
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '��λ[ %s ]�ύ��ë������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    nSQL := ' Select L_HYDan From %s Where L_ID=''%s'' ';
    {$IFDEF SendMorefactoryStock}
    nSQL := ' Select L_HYDan, L_SendFactory From %s Where L_ID=''%s'' ';
    nSQL := Format(nSQL, [sTable_Bill, nBills[0].FID]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nFactory:= Fields[1].AsString;
    end;
    {$ENDIF}

    with nBills[0] do
    begin
      if FBillValue=0 then FBillValue:= FValue;
      // ���������ڼ��㳬��

      if FPData.FValue = 0 then
      begin
        nData := '���� %s Ƥ������Ϊ 0�����ܳ�ë��.';
        WriteBillLog(nData);
        Exit;
      end;

      if FYSValid <> sFlag_Yes then        //�ǿճ���������
      begin
        if FType = sFlag_San then //ɢװ�轻���ʽ��
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
                 nBills[0].FZhiKa, '', @nOut) then
          begin
            nData := nOut.FData;
            Exit;
          end;

          m := StrToFloat(nOut.FData);
          m := m + Float2Float((FPrice+FYunFei) * FValue, cPrecision, False);
          //ֽ�����ý�

          nVal := FValue;
          FValue := nMVal - FPData.FValue;
          //�¾���,ʵ�������
          f := Float2Float((FPrice+FYunFei) * FValue, cPrecision, True) - m;
          //ʵ������������ý���

          {$IFNDEF NCSale}
          if f > 0 then
          begin
            {$IFDEF SanPreHK}
            f := Float2Float(f / (FPrice+FYunFei), cPrecision, True);
            //ֽ����������

            FValue := FValue - f;
            //ֽ�����ɷ���
            nMVal := nMVal - f;
            FMData.FValue := nMVal;
            //����ë��,ʹ��������һ��

            if not TWorkerBusinessBills.CallMe(cBC_MakeSanPreHK,
                   nBills[0].FID, FloatToStr(f), @nOut) then
            begin
              nData := nOut.FData;
              Exit;
            end;
            {$ELSE}
            nData := '�ͻ�[ %s.%s ]�ʽ�����,��������:' + #13#10#13#10 +
                     '��.���ý��: %.2fԪ' + #13#10 +
                     '��.������: %.2fԪ' + #13#10 +
                     '��.�� �� ��: %.2fԪ' + #13#10+#13#10 +
                     '�뵽�����Ұ���"��������"����,Ȼ���ٴγ���.';
            nData := Format(nData, [FCusID, FCusName, m, (FPrice+FYunFei) * FValue, f]);
            Exit;
            {$ENDIF}
          end;

          m := Float2Float((FPrice+FYunFei) * FValue, cPrecision, True);
          m := m - Float2Float((FPrice+FYunFei) * nVal, cPrecision, True);
          //����������

          nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney+(%.2f) ' +
                  'Where A_CID=''%s''';
          nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
          FListA.Add(nSQL); //�����˻�
          {$ELSE}
//            if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaKFNum,
//                   nBills[0].FZhiKa, nBills[0].FStockNo, @nOut) then
//            begin
//              nData := nOut.FData;
//              Exit;
//            end;

            if (FBillValue<FValue)and(f>0) then        //(StrToFloat(nOut.FData))=0
            begin
                nNewBillValue:= FValue-FBillValue;

                nStr:= ' Select top 1 * From (  ' +
                       ' Select D_ZID, Z_PKzk, D_PKDtl, D_Type, D_StockNo, D_StockName, D_Price, D_YunFei, Z_FixedMoney, ISNULL(YFMoney, 0) YFMoney,   ' +
                       ' Convert(decimal(18,5),(isNull(Z_FixedMoney, 0) - ISNULL(YFMoney, 0))/isNull((D_YunFei+D_Price), 10000)) D_Valuex, D_Value, Z_Customer  ' +
                       ' From S_ZhiKa a   ' +
                       ' Join S_ZhiKaDtl b on a.Z_ID = b.D_ZID ' +
                       ' Left Join (  ' +
                           ' Select L_zhika, sum((L_Price+L_YunFei)*L_Value) YFMoney ' +
                           ' From S_Bill ' +
                           ' Where L_CusID=''%s'' Group by L_zhika) c on c.L_ZhiKa = a.Z_ID ' +
                           ' Where Z_Verified=''Y'' And (Z_InValid<>''Y'' or Z_InValid is null) And Z_ValidDays>GetDate() and ' +
                           ' Z_Customer=''%s'' And Z_IsSupportTail=''Y'' And D_StockNo=''%s'' ) x ' +
                       ' Where D_Valuex>=%g Order by D_Valuex  ';
                nStr := Format(nStr, [FCusID, FCusID, FStockNo, (nNewBillValue)]);
                         WriteBillLog(nStr);
                with gDBConnManager.WorkerQuery(FDBConn, nStr) do
                begin
                  if recordCount=0 then
                  begin
                    nData := '�÷������ѳ��ɷ�����δ�ҵ�֧��β���ϲ���NC����';
                    WriteLog(nData);
                    Exit;
                  end;

                  nZKID:= FieldByName('D_ZID').AsString;
                  nPKzk:= FieldByName('Z_PKzk').AsString;
                  nPKDtl:= FieldByName('D_PKDtl').AsString;
                  nNewPrice:= FieldByName('D_Price').AsString;
                  nNewYunFei:= FieldByName('D_YunFei').AsString;
                end;

                if (nZKID<>'')and(nPKzk<>'')and(nPKDtl<>'') then
                begin
                  FListC.Clear;
                  FListC.Values['Group'] := sFlag_BusGroup;
                  FListC.Values['Object']:= sFlag_BillNo;
                  //to get serial no

                  if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                        FListC.Text, sFlag_Yes, @nOut) then
                    raise Exception.Create(nOut.FData);
                  //xxxxx
                  if (nOut.FData='')then
                  begin
                    nData := '��ȡ���۶������ʧ�ܡ�δ�������µ���';
                    WriteLog(nData);
                    Exit;
                  end;

                  nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
                  //only for fields
                  nP := '';
                  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
                  begin
                    for nIdx:=0 to FieldCount - 1 do
                     if (Fields[nIdx].DataType <> ftAutoInc) and
                        (Fields[nIdx].FieldName<>'L_ID') and
                        (Fields[nIdx].FieldName<>'L_HDBills') and
                        (Fields[nIdx].FieldName<>'L_Status') and
                        (Fields[nIdx].FieldName<>'L_NextStatus') and
                        (Fields[nIdx].FieldName<>'L_ZhiKa') and
                        (Fields[nIdx].FieldName<>'L_PKzk') and
                        (Fields[nIdx].FieldName<>'L_PKDtl') and
                        (Fields[nIdx].FieldName<>'L_Price') and
                        (Fields[nIdx].FieldName<>'L_YunFei') and

                        (Fields[nIdx].FieldName<>'L_Value') and
                        (Fields[nIdx].FieldName<>'L_MValue') then
                      nP := nP + Fields[nIdx].FieldName + ',';
                    //�����ֶ�,������ɾ��

                    System.Delete(nP, Length(nP), 1);
                  end;


                  nStr := 'Insert Into $BB($FL,L_Value,L_MValue,L_ZhiKa, L_PKzk,L_PKDtl, L_Price, L_YunFei, L_ID,L_Status,L_NextStatus,L_HDBills) ' +
                          'Select $FL,'+FloatToStr(nNewBillValue)+','+FloatToStr(nNewBillValue)+'+L_PValue, '+
                                 '''$ZhiKa'', ''$Pkzk'', ''$PkDtl'', $Price, $YunFei, ''$New'',''M'',''O'',''$HDB'' From $BI Where L_ID=''$ID''';
                  nStr := MacroValue(nStr, [MI('$BB', sTable_Bill),MI('$FL', nP),
                                            MI('$ZhiKa', nZKID),MI('$Pkzk', nPKzk),MI('$PkDtl', nPKDtl),
                                            MI('$Price', nNewPrice),MI('$YunFei', nNewYunFei),MI('$New', nOut.FData),
                                            MI('$HDB', FID +'��'+ nOut.FData),
                                            MI('$BI', sTable_Bill), MI('$ID', FID)]);
                  FListA.Add(nStr); //�����¶��� ��L_Value=ʵ��װ����-��������

                  nHDInfo:= Format('���� %s ��������%g ʵ�ʾ��أ�%g  ����ֽ�� %s ʣ�������㡢����β�����������ֱ�Ϊ: %s��%s ',
                                              [FID, FBillValue, FValue, FZhiKa, FID, nOut.FData]);
                  nTail:= True;   nBillNo:= nOut.FData;
                end;
            end
            else
            begin
              nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal)
                      ], sTable_Bill, SF('L_ID', FID), False);
              FListA.Add(nSQL); //���������
            end;
          {$ENDIF}

          {$IFNDEF NCSale}
          if nOut.FExtParam = sFlag_Yes then
          begin
            nSQL := 'Update %s Set Z_FixedMoney=Z_FixedMoney-(%.2f) ' +
                    'Where Z_ID=''%s''';
            nSQL := Format(nSQL, [sTable_ZhiKa, m, FZhiKa]);
            FListA.Add(nSQL); //����ֽ��������
          end;
          {$ENDIF}

          nSQL := ' Select L_HYDan From %s Where L_ID=''%s'' ';
          {$IFDEF SendMorefactoryStock}
          nSQL := ' Select L_HYDan, L_SendFactory From %s Where L_ID=''%s'' ';
          {$ENDIF}
          nSQL := Format(nSQL, [sTable_Bill, FID]);
          with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
          if RecordCount > 0 then
          begin
            nSQL := 'Update %s Set B_HasUse=B_HasUse+(%.2f - %.2f) ' +
                    'Where B_Batcode=''%s''';
            nSQL := Format(nSQL, [sTable_StockBatcode, FValue, nVal,
                    Fields[0].AsString]);
              {$IFDEF SendMorefactoryStock}
              nSQL := nSQL + ' And B_SendFactory='''+Fields[1].AsString+'''';
              {$endif}
            FListA.Add(nSQL);
          end;
          //�������κ�ʹ����
        end;
      end
      else
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
               nBills[0].FZhiKa, '', @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
        nFixMoney := nOut.FExtParam;

        nVal := Float2Float((FPrice+FYunFei) * FValue, cPrecision, False);
        {$IFNDEF NCSale}
        if nFixMoney = sFlag_Yes then
        begin
          nSQL := 'Update %s Set Z_FixedMoney=Z_FixedMoney+%s Where Z_ID=''%s''';
          nSQL := Format(nSQL, [sTable_ZhiKa, FloatToStr(nVal),
                  nBills[0].FZhiKa]);
          //xxxxx
          FListA.Add(nSQL);
        end;   //�ͷ�������

        nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney-%s Where A_CID=''%s''';
        nSQL := Format(nSQL, [sTable_CusAccount, FloatToStr(nVal),
                FCusID]);
        FListA.Add(nSQL);
        //�ͷŶ����
        {$ENDIF}

        nSQL := 'Update %s Set B_HasUse=B_HasUse-%.2f Where B_Batcode=''%s''';
        nSQL := Format(nSQL, [sTable_StockBatcode, FValue, FHYDan]);
          {$IFDEF SendMorefactoryStock}
          nSQL := nSQL + ' And B_SendFactory='''+nFactory+'''';
          {$endif}
        FListA.Add(nSQL);
        //�ͷ�ʹ�õ����κ�
      end;
    end;

    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIdx < High(nBills) then
      begin
        FMData.FValue := FPData.FValue + FValue;
        nVal := nVal + FValue;
        //�ۼƾ���

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        FMData.FValue := nMVal - nVal;
        //�ۼ����ۼƵľ���

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    FListB.Clear;
    if nBills[nInt].FPModel <> sFlag_PoundCC then //����ģʽ,ë�ز���Ч
    begin
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //δ��ë�ؼ�¼

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          FListB.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nBills[nInt].FPModel = sFlag_PoundCC then Continue;
      //����ģʽ,������״̬

      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //�ų����γ���

      if FYSValid <> sFlag_Yes then   //�ж��Ƿ�ճ�����  �ǿճ�����
      begin
        if nTail then
        begin
          FValue:= FBillValue;
          FMData.FValue:= FMData.FValue-nNewBillValue;
        end;

        nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);

        if nTail then
        begin
          nSQL := MakeSQLByStr([
                  SF('L_MDate', sField_SQLServer_Now, sfVal),
                  SF('L_MMan', FIn.FBase.FFrom.FUser)
                  ], sTable_Bill, SF('L_ID', nBillNo), False);
          FListA.Add(nSQL);
        end;
      end else
      begin
        nSQL := MakeSQLByStr([SF('L_Value', 0.00, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);

      end;
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //δ���ؽ������б�

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�ص������¼��Ƥ��,���ڱ��ε�ë��

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�صĹ�����¼��Ƥ��,���ڱ��ε�ë��
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //δ��ë�ؼ�¼

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;  nPriceChanged:= False;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nOutFactTime:= FormatDateTime('yyyy-MM-dd HH:mm:ss', Now);

      {$IFDEF BasisWeightWithPM}
      //  ��װ� (��Ƥ װ�� ��ë)   ɢװ������У���ʽ�
      if (FType = sFlag_San) and FIsBasisWeight then
      begin
        IF not BasisWeightBillOutChk(nBills[nIdx]) then
        begin
          WriteBillLog(Format('���װ�������� %s�������ʽ�У��δͨ��', [nBills[nIdx].FID]));
          Exit;
        end;
      end;
      {$ENDIF}
                                              
        {$IFDEF NCSale}
        ChkNcServiceStatus;
        //*******
        if (FValue>0) then
        begin
          if (LeftStr(nBills[nIdx].FZhiKa, 2)<>'ZK') then      // �ճ������� ����������ֽ�� ���ϴ� NC ��֤
          begin
            if FOnLine then
            begin
              WriteBillLog(Format('�������۳������� NC��%s', [nBills[nIdx].FID]));

              FListC.Clear;
              FListC.Values['ID']  := nBills[nIdx].FID;
              FListC.Values['Proc']:= 'add';
              FListC.Values['Card']:= nBills[nIdx].FCard;

              if not CallBusinessSaleBillToNC(cBC_SendToNcBillInfo, PackerEncodeStr(FListC.Text), nOutFactTime, @nOut) then
              begin
                gSysLoger.AddLog(TWorkerBusinessBills, '���۵�����', Format(' %s ����ʧ�ܣ�'+nOut.FData, [nBills[nIdx].FID]));
                Exit;
              end
              else
              begin
                begin
                  nSQL := 'Select * From %s Where L_ID=''%s''';
                  nSQL := Format(nSQL, [sTable_Bill, FID]);
                  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
                  if RecordCount > 0 then
                  begin
                    //�緢���ļ� �����»�ȡ���� ���ۡ��˷���Ϣ
                    nPriceChanged:= nBills[nIdx].FZhiKa<>FieldByName('L_ZhiKa').AsString;//nOut.FExtParam='Y';
                    IF nPriceChanged then
                    begin
                      nBills[nIdx].FZhiKa:= FieldByName('L_ZhiKa').AsString;
                      FPrice := FieldByName('L_Price').AsFloat;
                      FYunFei:= FieldByName('L_YunFei').AsFloat;
                    end;
                  end
                  else
                  begin
                    WriteBillLog(Format('δ�ܲ��ҵ����۶��� %s����ֹ��������', [FID]));
                    Exit;
                  end;
                end;
              end;
            end
            else WriteBillLog(Format('����Ա���л�����ģʽ��%s ���� %s ��������������У��',[FID, FTruck]));
          end
          else WriteBillLog(Format('�����ڰ���ֽ����%s %s ���� %s �����ϴ�NC������������У��', [FID, nBills[nIdx].FZhiKa, FTruck]));
        end
        else WriteBillLog(Format('���ճ�����������%s %s ���� %s �����ϴ�NC������������У��', [FID, nBills[nIdx].FZhiKa, FTruck]));
        /// ******************************************  ���ض��μ���Ƿ��ܿۼ�������
        nMoney:= 0;
        // ��ȡֽ���ѿۼ���������ʣ����ý��
        if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
               nBills[nIdx].FZhiKa, 'GetOutMoney', @nOut) then
        begin
          nData := nOut.FData;
          gSysLoger.AddLog(TWorkerBusinessBills, '���۳���У��', nData);
          Exit;
        end;
        nMoney:= Float2Float((StrToFloat(nOut.FData)), cPrecision, True);
        nVal := Float2Float((FPrice+FYunFei) * FValue, cPrecision, True);

        // ����У���ʽ�
        if (nMoney-nVal<0) then
        begin
          nNeedJK:= Float2Float(-1*(nMoney-nVal), cPrecision);
          nData  := Format('%s ���� %s ���۵� %s ֽ�����:%g ����֧�����λ���:%g ,�貹���ʽ� %g Ԫ�����ɳ���',
                              [FCusName, FTruck, FID, nMoney, nVal, nNeedJK]);

          gSysLoger.AddLog(TWorkerBusinessBills, '���۳���У��', nData);
          AddManualEventRecord(FID+'C', FTruck, nData, 'ϵͳ��Ϣ', sFlag_Solution_OK,
                    sFlag_DepDaTing, True);
          AddManualEventRecord(FID+'O', FTruck, nData, 'ϵͳ��Ϣ', sFlag_Solution_OK,
                    sFlag_DepMenGang, True);
          Exit;
        end
        else
        begin
          IF nPriceChanged then
          begin
            nEMsg:= '�ö�������ֽ���ѵ��ۡ��Ժ��ϴ�';
            nData  := Format('%s ���� %s ���۵� %s �ѹ�����ֽ�������¼۸񡢾��ʽ�˶����Է��С��Ժ��ٴ�ͬ��',
                                [FCusName, FTruck, FID]);
            gSysLoger.AddLog(TWorkerBusinessBills, '���۳���У��', nData);
          end;

          if not FOnLine then
          begin
            nEMsg:= 'NC��������ߡ��Ժ��ϴ�';
            nData  := Format('%s ���� %s ���۵� %s NC�������ߡ������ʽ�У��ͨ�����Ժ��ٴ�ͬ��',
                                [FCusName, FTruck, FID, nNeedJK]);
            gSysLoger.AddLog(TWorkerBusinessBills, '���۳���У��', nData);
          end;

          //�磨�����ļ� ������ģʽУ��ͨ����   �������ٴ�����
          IF nPriceChanged or (not FOnLine) then
          begin
            nStr := MakeSQLByStr([SF('N_OrderNo', FID),
                                  SF('N_Type', 'S'), SF('N_Status', '-1'),
                                  SF('N_Proc', 'add'), SF('N_SyncNum', '0'),
                                  SF('N_ErrorMsg', nEMsg)] ,
                                  sTable_UPLoadOrderNc, '', True);
            FListA.Add(nStr);
          end;

        end;
        gSysLoger.AddLog(TWorkerBusinessBills, '���۳���У��', Format('���۵� %s ���� %s ����У��ͨ��', [FID, FTruck]));
      {$ENDIF}
      /// ************************************
      FListB.Add(FID);
      //�������б�

      {$IFDEF BasisWeightWithPM}
      if (FType = sFlag_San)and(FYSValid<>sFlag_Yes)and FIsBasisWeight then
      begin
        nSQL := MakeSQLByStr([ SF('L_Value', 'L_MValue-L_PValue',sfVal)], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //���½�����
      end;
      {$ENDIF}

      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_NextStatus', ''),
              SF('L_Card', ''),
              SF('L_OutFact', nOutFactTime),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //���½�����

      {$IFNDEF NCSale}
      if FYSValid <> sFlag_Yes then
      begin
        nVal := Float2Float((FPrice+FYunFei) * FValue, cPrecision, True);
        //����������

        nSQL := 'UPDate %s Set A_OutMoney=A_OutMoney+(%.2f),' +
                'A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
        nSQL := Format(nSQL, [sTable_CusAccount, nVal, nVal, FCusID]);
        FListA.Add(nSQL); //���¿ͻ��ʽ�(���ܲ�ͬ�ͻ�)
      end;
      {$ENDIF}

      {$IFNDEF CreateBillCreateHYEach}   //δ�ڿ��������鵥
        {$IFDEF PrintHYEach}
        //if FPrintHY then
        if FYSValid <> sFlag_Yes then
        begin
          FListC.Clear;
          FListC.Values['Group'] :=sFlag_BusGroup;
          FListC.Values['Object'] := sFlag_HYDan;
          //to get serial no

          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
              FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          //xxxxx

          nSQL := MakeSQLByStr([SF('H_No', nOut.FData),
                  SF('H_Custom', FCusID),
                  SF('H_CusName', FCusName),
                  SF('H_SerialNo', FHYDan),
                  SF('H_Truck', FTruck),
                  SF('H_Value', FValue, sfVal),
                  SF('H_BillDate', sField_SQLServer_Now, sfVal),
                  SF('H_ReportDate', sField_SQLServer_Now, sfVal),
                  //SF('H_EachTruck', sFlag_Yes),
                  SF('H_Reporter', FID)], sTable_StockHuaYan, '', True);
          FListA.Add(nSQL); //�Զ����ɻ��鵥
        end;
        {$ENDIF}
      {$ENDIF}
    end;

    {$IFDEF UseERP_K3}
    nStr := CombinStr(FListB, ',', True);
    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill, nStr, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;
    {$ENDIF}

    nSQL := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
    FListA.Add(nSQL); //���´ſ�״̬

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //�������б�

    nSQL := 'Select T_Line,Z_Name as T_Name,T_Bill,T_PeerWeight,T_Total,' +
            'T_Normal,T_BuCha,T_HKBills From %s ' +
            ' Left Join %s On Z_ID = T_Line ' +
            'Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sTable_ZTLines, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      SetLength(FBillLines, RecordCount);
      //init

      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FBillLines[nIdx] do
          begin
            FBill    := FieldByName('T_Bill').AsString;
            FLine    := FieldByName('T_Line').AsString;
            FName    := FieldByName('T_Name').AsString;
            FPerW    := FieldByName('T_PeerWeight').AsInteger;
            FTotal   := FieldByName('T_Total').AsInteger;
            FNormal  := FieldByName('T_Normal').AsInteger;
            FBuCha   := FieldByName('T_BuCha').AsInteger;
            FHKBills := FieldByName('T_HKBills').AsString;
          end;

          Inc(nIdx);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if (Pos(FID, FBillLines[i].FHKBills) > 0) and
          (FID <> FBillLines[i].FBill) then
       begin
          nInt := i;
          Break;
       end;
      //�Ͽ�,��������

      if nInt < 0 then Continue;
      //����װ����Ϣ

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //������Ч

        i := Trunc(FValue * 1000 / FPerW);
        //����

        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //����װ����Ϣ

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //�ۼ��Ͽ�������װ����
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if FID = FBillLines[i].FBill then
       begin
          nInt := i;
          Break;
       end;
      //�Ͽ�����

      if nInt < 0 then Continue;
      //����װ����Ϣ

      with FBillLines[nInt] do
      begin
        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_DaiTotal', FTotal, sfVal),
                SF('L_DaiNormal', FNormal, sfVal),
                SF('L_DaiBuCha', FBuCha, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //����װ����Ϣ
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    FListA.Add(nSQL); //����װ������
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nBills[0].FCard);
    //���������Զ�����

    if nHDInfo<>'' then
      WriteBillLog(nHDInfo);
  end;

  {$IFDEF MicroMsg}
  nStr := '';
  for nIdx:=Low(nBills) to High(nBills) do
    nStr := nStr + nBills[nIdx].FID + ',';
  //xxxxx

  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with FListA do
    begin
      Clear;
      Values['bill'] := nStr;
      Values['company'] := gSysParam.FHintText;
    end;

    gWXPlatFormHelper.WXSendMsg(cWXBus_OutFact, FListA.Text);
  end;
  {$ENDIF}
end;


initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
end.
