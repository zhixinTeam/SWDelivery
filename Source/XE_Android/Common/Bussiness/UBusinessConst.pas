{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ��������

  ��ע:
  *.����In/Out����,��ô���TBWDataBase������,��λ�ڵ�һ��Ԫ��.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  System.JSON, Classes, SysUtils, UBusinessPacker, FMX.Dialogs, UBase64,
  UWifiManager,
  System.IniFiles,                       //Ini
  System.IOUtils;                        //TPath;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*query field define*}
  cQF_Bill                    = $0001;

  {*business command*}
  cBC_GetSerialNO             = $0001;   //��ȡ���б��
  cBC_ServerNow               = $0002;   //��������ǰʱ��
  cBC_IsSystemExpired         = $0003;   //ϵͳ�Ƿ��ѹ���
  cBC_GetCardUsed             = $0004;   //��ȡ��Ƭ����
  cBC_UserLogin               = $0005;   //�û���¼
  cBC_UserLogOut              = $0006;   //�û�ע��

  cBC_GetCustomerMoney        = $0010;   //��ȡ�ͻ����ý�
  cBC_GetZhiKaMoney           = $0011;   //��ȡֽ�����ý�
  cBC_CustomerHasMoney        = $0012;   //�ͻ��Ƿ������

  cBC_SaveTruckInfo           = $0013;   //���泵����Ϣ
  cBC_GetTruckPoundData       = $0015;   //��ȡ������������
  cBC_SaveTruckPoundData      = $0016;   //���泵����������

  cBC_SaveBills               = $0020;   //���潻�����б�
  cBC_DeleteBill              = $0021;   //ɾ��������
  cBC_ModifyBillTruck         = $0022;   //�޸ĳ��ƺ�
  cBC_SaleAdjust              = $0023;   //���۵���
  cBC_SaveBillCard            = $0024;   //�󶨽������ſ�
  cBC_LogoffCard              = $0025;   //ע���ſ�

  cBC_SaveOrder               = $0040;
  cBC_DeleteOrder             = $0041;
  cBC_SaveOrderCard           = $0042;
  cBC_LogOffOrderCard         = $0043;
  cBC_GetPostOrders           = $0044;   //��ȡ��λ�ɹ���
  cBC_SavePostOrders          = $0045;   //�����λ�ɹ���

  cBC_GetPostBills            = $0030;   //��ȡ��λ������
  cBC_SavePostBills           = $0031;   //�����λ������

  cBC_ChangeDispatchMode      = $0053;   //�л�����ģʽ
  cBC_GetPoundCard            = $0054;   //��ȡ��վ����
  cBC_GetQueueData            = $0055;   //��ȡ��������
  cBC_PrintCode               = $0056;
  cBC_PrintFixCode            = $0057;   //����
  cBC_PrinterEnable           = $0058;   //�������ͣ

  cBC_JSStart                 = $0060;
  cBC_JSStop                  = $0061;
  cBC_JSPause                 = $0062;
  cBC_JSGetStatus             = $0063;
  cBC_SaveCountData           = $0064;   //����������
  cBC_RemoteExecSQL           = $0065;

  cBC_IsTunnelOK              = $0075;
  cBC_TunnelOC                = $0076;

  cBC_SyncCustomer            = $0080;   //Զ��ͬ���ͻ�
  cBC_SyncSaleMan             = $0081;   //Զ��ͬ��ҵ��Ա
  cBC_SyncStockBill           = $0082;   //ͬ�����ݵ�Զ��
  cBC_CheckStockValid         = $0083;   //��֤�Ƿ�������

type
  PSystemParam = ^TSystemParam;
  TSystemParam = record
    FOperator :string;
    FPassword :string;

    FHostIP   :string;
    FHostMAC  :string;

    FServIP   :string;
    FServPort :Integer;

    FHasLogin :Boolean;
    FSavePswd :Boolean;
    FAutoLogin:Boolean;

    FSvrService:string;
  end;

  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //����
    FData     : string;            //����
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
  end;

  TPoundStationData = record
    FStation  : string;            //��վ��ʶ
    FValue    : Double;           //Ƥ��
    FDate     : TDateTime;        //��������
    FOperator : string;           //����Ա
  end;

  PLadingBillItem = ^TLadingBillItem;
  TLadingBillItem = record
    FID         : string;          //��������
    FZhiKa      : string;          //ֽ�����
    FCusID      : string;          //�ͻ����
    FCusName    : string;          //�ͻ�����
    FTruck      : string;          //���ƺ���

    FType       : string;          //Ʒ������
    FStockNo    : string;          //Ʒ�ֱ��
    FStockName  : string;          //Ʒ������
    FValue      : Double;          //�����
    FPrice      : Double;          //�������

    FCard       : string;          //�ſ���
    FIsVIP      : string;          //ͨ������
    FStatus     : string;          //��ǰ״̬
    FNextStatus : string;          //��һ״̬

    FPData      : TPoundStationData; //��Ƥ
    FMData      : TPoundStationData; //��ë
    FFactory    : string;          //�������
    FPModel     : string;          //����ģʽ
    FPType      : string;          //ҵ������
    FPoundID    : string;          //���ؼ�¼
    FSelected   : Boolean;         //ѡ��״̬

    FKZValue    : Double;          //��Ӧ�۳�
    FMemo       : string;          //������ע
  end;

  TLadingBillItems = array of TLadingBillItem;
  //�������б�

procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//������ҵ����󷵻صĽ���������
function CombineBillItmes(const nItems: TLadingBillItems): string;
//�ϲ�����������Ϊҵ������ܴ�����ַ���
procedure LoadParamFromIni;
procedure SaveParamToIni;

resourcestring
  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //����ʾ����

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //ҵ��ģ��
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //Ӳ���ػ�
                                                                                                   
  {*common function*}  
  sSys_BasePacker             = 'Sys_BasePacker';       //���������

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //����״̬
  sBus_GetQueryField          = 'Bus_GetQueryField';    //��ѯ���ֶ�

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //���������
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //ҵ��ָ��
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //Ӳ��ָ��
  sBus_BusinessPurchaseOrder  = 'Bus_BusinessPurchaseOrder'; //�ɹ������

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //����״̬
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //��ѯ���ֶ�

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //������ҵ��
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //ҵ��ָ��
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //Ӳ��ָ��
  sCLI_BusinessPurchaseOrder  = 'CLI_BusinessPurchaseOrder'; //�ɹ������

var gSysParam: TSystemParam;

implementation

//Date: 2014-09-17
//Parm: ����������;�������
//Desc: ����nDataΪ�ṹ���б�����
procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
var nStr: string;
    nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item
      
      with nListB,nItems[nInt] do
      begin
        FID         := Values['ID'];
        FZhiKa      := Values['ZhiKa'];
        FCusID      := Values['CusID'];
        FCusName    := Values['CusName'];
        FTruck      := Values['Truck'];

        FType       := Values['Type'];
        FStockNo    := Values['StockNo'];
        FStockName  := Values['StockName'];

        FCard       := Values['Card'];
        FIsVIP      := Values['IsVIP'];
        FStatus     := Values['Status'];
        FNextStatus := Values['NextStatus'];

        FFactory    := Values['Factory'];
        FPModel     := Values['PModel'];
        FPType      := Values['PType'];
        FPoundID    := Values['PoundID'];
        FSelected   := Values['Selected'] = 'Y';

        with FPData do
        begin
          FStation  := Values['PStation'];
          //FDate     := StrToDateTime(Values['PDate']);
          FOperator := Values['PMan'];

          nStr := Trim(Values['PValue']);
          if (nStr <> '') then
               FPData.FValue := StrToFloatDef(nStr, 0)
          else FPData.FValue := 0;
        end;

        with FMData do
        begin
          FStation  := Values['MStation'];
          //FDate     := StrToDateTime(Values['MDate']);
          FOperator := Values['MMan'];

          nStr := Trim(Values['MValue']);
          if (nStr <> '') then
               FMData.FValue := StrToFloatDef(nStr, 0)
          else FMData.FValue := 0;
        end;

        nStr := Trim(Values['Value']);
        if (nStr <> '') then
             FValue := StrToFloatDef(nStr, 0)
        else FValue := 0;

        nStr := Trim(Values['Price']);
        if (nStr <> '') then
             FPrice := StrToFloatDef(nStr, 0)
        else FPrice := 0;

        nStr := Trim(Values['KZValue']);
        if (nStr <> '') then
             FKZValue := StrToFloatDef(nStr, 0)
        else FKZValue := 0;

        FMemo := Values['Memo'];
      end;

      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;   
end;

//Date: 2014-09-18
//Parm: �������б�
//Desc: ��nItems�ϲ�Ϊҵ������ܴ����
function CombineBillItmes(const nItems: TLadingBillItems): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    nListB.Clear;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      with nListB do
      begin
        Values['ID']         := FID;
        Values['ZhiKa']      := FZhiKa;
        Values['CusID']      := FCusID;
        Values['CusName']    := FCusName;
        Values['Truck']      := FTruck;

        Values['Type']       := FType;
        Values['StockNo']    := FStockNo;
        Values['StockName']  := FStockName;
        Values['Value']      := FloatToStr(FValue);
        Values['Price']      := FloatToStr(FPrice);

        Values['Card']       := FCard;
        Values['IsVIP']      := FIsVIP;
        Values['Status']     := FStatus;
        Values['NextStatus'] := FNextStatus;

        Values['Factory']    := FFactory;
        Values['PModel']     := FPModel;
        Values['PType']      := FPType;
        Values['PoundID']    := FPoundID;

        with FPData do
        begin
          Values['PStation'] := FStation;
          Values['PValue']   := FloatToStr(FPData.FValue);
          Values['PDate']    := DateTimeToStr(FDate);
          Values['PMan']     := FOperator;
        end;

        with FMData do
        begin
          Values['MStation'] := FStation;
          Values['MValue']   := FloatToStr(FMData.FValue);
          Values['MDate']    := DateTimeToStr(FDate);
          Values['MMan']     := FOperator;
        end;

        if FSelected then
             Values['Selected'] := 'Y'
        else Values['Selected'] := 'N';

        Values['KZValue']    := FloatToStr(FKZValue);
        Values['Memo']       := FMemo;
      end;

      nListA.Add(PackerEncodeStr(nListB.Text));
      //add bill
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListB.Free;
    nListA.Free;
  end;
end;


procedure LoadParamFromIni;
var nIniFile:TIniFile;
begin
  try
    nIniFile:=TIniFile.Create(TPath.GetHomePath + '/ReadFile.ini');

    with gSysParam,nIniFile do
    begin
      FHostIP   := GetWiFiLocalIP;
      FHostMAC  := GetWiFiLocalMAC;

      FOperator := DecodeBase64(ReadString('ActivityConfig' ,'User', ''));
      FPassword := DecodeBase64(ReadString('ActivityConfig' ,'Password', ''));

      FServIP   := DecodeBase64(ReadString('ActivityConfig' ,'ServIP', ''));
      FServPort := ReadInteger('ActivityConfig' ,'ServPort', 8082);

      FSavePswd := ReadBool('ActivityConfig', 'SavePsd', False);
      FHasLogin := ReadBool('ActivityConfig', 'HasLogin', False);
      FAutoLogin:= ReadBool('ActivityConfig', 'AutoLogin', False);

      FSvrService:= DecodeBase64(ReadString('ActivityConfig' ,'SvrService', ''));
    end;
  finally
    FreeAndNil(nIniFile);
  end;
end;

procedure SaveParamToIni;
var nIniFile:TIniFile;
begin
  try
    nIniFile:=TIniFile.Create(TPath.GetHomePath + '/ReadFile.ini');

    with gSysParam, nIniFile do
    begin
      WriteString('ActivityConfig' ,'User', EncodeBase64(FOperator));
      WriteString('ActivityConfig' ,'Password', EncodeBase64(FPassword));

      WriteBool('ActivityConfig', 'SavePsd', FSavePswd);
      WriteBool('ActivityConfig', 'AutoLogin', FSavePswd and FAutoLogin);
      WriteBool('ActivityConfig', 'HasLogin', FSavePswd and FAutoLogin and FHasLogin );

      if not FSavePswd then
        WriteString('ActivityConfig' ,'Password', '');

      WriteString('ActivityConfig' ,'ServIP', EncodeBase64(FServIP));
      WriteInteger('ActivityConfig' ,'ServPort', FServPort);
      WriteString('ActivityConfig' ,'SvrService', EncodeBase64(FSvrService));
    end;
  finally
    FreeAndNil(nIniFile);
  end;
end;

function CombineBillItmesToJSON(const nItems: TLadingBillItems): string;
var nJsonAll, nJsonOne, nJsonObject: TJSONObject;
    nArrAll,nArrOne: TJSONArray;
    nIdx: Integer;
begin
  nJsonObject := TJSONObject.Create;

  try
    nArrAll := TJSONArray.Create;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      nJsonAll   := TJSONObject.Create;
      if not Assigned(nJsonAll) then Continue;
      with nJsonAll do
      begin
        AddPair(TJSONPair.Create('ID', FID));
        AddPair(TJSONPair.Create('ZhiKa', FZhiKa));
        AddPair(TJSONPair.Create('CusID', FID));
        AddPair(TJSONPair.Create('CusName', FZhiKa));
        AddPair(TJSONPair.Create('Truck', FID));

        AddPair(TJSONPair.Create('Type', FZhiKa));
        AddPair(TJSONPair.Create('StockNo', FID));
        AddPair(TJSONPair.Create('StockName', FZhiKa));
        AddPair(TJSONPair.Create('Value', FloatToStr(FValue)));
        AddPair(TJSONPair.Create('Price', FloatToStr(FPrice)));


        AddPair(TJSONPair.Create('Card', FID));
        AddPair(TJSONPair.Create('IsVIP', FZhiKa));
        AddPair(TJSONPair.Create('Status', FID));
        AddPair(TJSONPair.Create('ZhiKa', FZhiKa));
        AddPair(TJSONPair.Create('NextStatus', FID));


        AddPair(TJSONPair.Create('Factory', FZhiKa));
        AddPair(TJSONPair.Create('PModel', FID));
        AddPair(TJSONPair.Create('PType', FZhiKa));
        AddPair(TJSONPair.Create('PoundID', FID));

        if FSelected then
             AddPair(TJSONPair.Create('Selected', 'Y'))
        else AddPair(TJSONPair.Create('Selected', 'N'));


        AddPair(TJSONPair.Create('KZValue', FloatToStr(FKZValue)));
        AddPair(TJSONPair.Create('Memo', FMemo));

        nArrOne := TJSONArray.Create;
        with FPData do
        begin
          nJsonOne   := TJSONObject.Create;

          nJsonOne.AddPair(TJSONPair.Create('PStation', FStation));
          nJsonOne.AddPair(TJSONPair.Create('PValue', FloatToStr(FPData.FValue)));
          nJsonOne.AddPair(TJSONPair.Create('PDate', DateTimeToStr(FDate)));
          nJsonOne.AddPair(TJSONPair.Create('PMan', FOperator));

          nArrOne.Add(nJsonOne);
        end;


        with FMData do
        begin
          nJsonOne   := TJSONObject.Create;

          nJsonOne.AddPair(TJSONPair.Create('MStation', FStation));
          nJsonOne.AddPair(TJSONPair.Create('MValue', FloatToStr(FMData.FValue)));
          nJsonOne.AddPair(TJSONPair.Create('MDate', DateTimeToStr(FDate)));
          nJsonOne.AddPair(TJSONPair.Create('MMan', FOperator));

          nArrOne.Add(nJsonOne);
        end;

        AddPair(TJSONPair.Create('BFStations', nArrOne));
      end;

      nArrAll.Add(nJsonAll);
    end;

    Result := nJsonObject.ToString;
  finally
    nJsonObject.Free;
  end;
end;

procedure AnalyseBillItemsFromJSON(const nData: string;
  var nItems: TLadingBillItems);
begin
  //
end;

end.


