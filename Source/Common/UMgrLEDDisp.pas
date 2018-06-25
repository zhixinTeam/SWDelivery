{*******************************************************************************
  ����: dmzn@163.com 2013-07-20
  ����: LEDС����ʾ
*******************************************************************************}
unit UMgrLEDDisp;

{$I Link.Inc}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, USysLoger, UWaitItem,
  ULibFun, IdTCPConnection, IdTCPClient, IdGlobal;

const
  cDisp_KeepLong   = 600;     //���ݱ���ʱ��
  cDisp_CtrlCardType = 'YBKJ';
  cDisp_Config     = 'LEDDisp.XML';
type
  PDispCard = ^TDispCard;
  TDispCard = record
    FID: string;
    FName: string;
    FType: string;
    FTunnel: string;                        //ͨ�����

    FHost: string;
    FPort: Integer;
    FAddr: Integer;                         //����
    FLastUpdate: Int64;                     //���
    FKeepTime: Int64;                       //�ǳ�����ʾʱ������ʱ��
    FKeepShow: Boolean;                     //������ʾ
    FClient: TIdTCPClient;                  //������·
  end;

  PDispContent = ^TDispContent;
  TDispContent = record
    FID: string;
    FText: string;
  end;

type
  TDisplayManager = class;
  TDisplayControler = class(TThread)
  private
    FOwner: TDisplayManager;
    //ӵ����
    FBuffer: TList;
    //��ʾ����
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure DoExuecte(const nCard: PDispCard);
    procedure Execute; override;
    //ִ���߳�
    procedure AddContent(const nContent: PDispContent);
    //�������
  public
    constructor Create(AOwner: TDisplayManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure WakupMe;
    //�����߳�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TDisplayManager = class(TObject)
  private
    FControler: TDisplayControler;
    //��ʾ����
    FCards: array of TDispCard;
    //�豸�б�
    FEnabled: Boolean;
    FDefault: string;
    //Ĭ������
    FBuffData: TList;
    //���ݻ���
    FSyncLock: TCriticalSection;
    //ͬ����
  protected
    procedure ClearBuffer(const nList: TList; const nFree: Boolean = False);
    procedure ClearCards;
    //������Դ
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    procedure StartDisplay;
    procedure StopDisplay;
    //��ͣ��ʾ
    procedure Display(const nTunnel,nText: string);
    //��ʾ����
  end;

var
  gDisplayManager: TDisplayManager = nil;
  //ȫ��ʹ��

function GetBXShowInfoAtTime(nTxt: string; nAddr: Integer=0): string;
//��ȡʵʱ��ʾ��Ϣ
implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TDisplayManager, 'LED��ʾ����', nEvent);
end;

constructor TDisplayManager.Create;
begin
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TDisplayManager.Destroy;
begin
  StopDisplay;
  ClearBuffer(FBuffData, True);
  ClearCards;

  FSyncLock.Free;
  inherited;
end;

procedure TDisplayManager.ClearBuffer(const nList: TList; const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx := nList.Count - 1 downto 0 do
  begin
    Dispose(PDispContent(nList[nIdx]));
    nList.Delete(nIdx);
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

procedure TDisplayManager.ClearCards;
var nIdx: Integer;
begin
  for nIdx := High(FCards) downto Low(FCards) do
  with FCards[nIdx] do
  begin
    FClient.Disconnect;
    FClient.Free;
    FClient := nil;
  end;
end;

procedure TDisplayManager.StartDisplay;
begin
  if FEnabled and (Length(FCards) > 0) then
  begin
    if not Assigned(FControler) then
      FControler := TDisplayControler.Create(Self);
    FControler.WakupMe;
  end;
end;

procedure TDisplayManager.StopDisplay;
begin
  if Assigned(FControler) then
    FControler.StopMe;
  FControler := nil;
end;

//Date: 2013-07-20
//Parm: ��ʶ;����
//Desc: ��nID������ʾnText
procedure TDisplayManager.Display(const nTunnel,nText: string);
var nItem: PDispContent;
    nIdx, nInt: Integer;
begin
  if not Assigned(FControler) then Exit;
  //no controler

  if nTunnel = '' then Exit;
  //δָ������

  FSyncLock.Enter;
  try
    nInt := 0;
    for nIdx := Low(FCards) to High(FCards) do
    begin
      if (CompareText(FCards[nIdx].FID, nTunnel) = 0) or            //ID��ͬ
         (CompareText(FCards[nIdx].FTunnel, nTunnel) = 0) then      //Tunnel��ͬ
      begin
        New(nItem);
        FBuffData.Add(nItem);

        nItem.FID := FCards[nIdx].FID;
        nItem.FText := nText;

        Inc(nInt);
      end;
    end;

    if nInt > 0 then FControler.WakupMe;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: ����nFile�����ļ�
procedure TDisplayManager.LoadConfig(const nFile: string);
var nIdx,nInt: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nInt := 0;
    SetLength(FCards, 0);
    nXML.LoadFromFile(nFile);

    nNode := nXML.Root.NodeByName('config');
    FEnabled := nNode.NodeByName('enable').ValueAsString = '1';
    FDefault := nNode.NodeByName('default').ValueAsString;

    for nIdx:=nXML.Root.NodeCount - 1 downto 0 do
    begin
      nNode := nXML.Root.Nodes[nIdx];
      if CompareText(nNode.Name, 'card') <> 0 then Continue;

      nTmp := nNode.FindNode('enable');
      if (not Assigned(nTmp)) or (nTmp.ValueAsString <> '1') then Continue;
      //not valid card

      SetLength(FCards, nInt + 1);
      with FCards[nInt],nNode do
      begin
        FID := AttributeByName['ID'];
        FName := AttributeByName['Name'];
        FType := AttributeByName['Type'];

        FHost := NodeByName('ip').ValueAsString;
        FPort := NodeByName('port').ValueAsInteger;
        FAddr := NodeByName('addr').ValueAsInteger;

        nTmp := FindNode('keepshow');
        if not Assigned(nTmp) then
             FKeepShow := True
        else FKeepShow := nTmp.ValueAsString = '1';

        nTmp := FindNode('keeptime');
        if not Assigned(nTmp) then
             FKeepTime := cDisp_KeepLong
        else FKeepTime := nTmp.ValueAsInt64Def(cDisp_KeepLong);

        nTmp := FindNode('tunnel');
        if Assigned(nTmp) then
          FTunnel := nTmp.ValueAsString;

        if not Assigned(FClient) then
          FClient := TIdTCPClient.Create;

        FClient.Host := FHost;
        FClient.Port := FPort;
        FClient.ReadTimeout := 5 * 1000;
        FClient.ConnectTimeout := 5 * 1000;

        FLastUpdate := 0;
        Inc(nInt);
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TDisplayControler.Create(AOwner: TDisplayManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2000;
end;

destructor TDisplayControler.Destroy;
begin
  FOwner.ClearBuffer(FBuffer, True);
  FWaiter.Free;
  inherited;
end;

procedure TDisplayControler.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TDisplayControler.WakupMe;
begin
  FWaiter.Wakeup;
end;

//Desc: ���������,���������
procedure TDisplayControler.AddContent(const nContent: PDispContent);
var nIdx: Integer;
    nItem: PDispContent;
begin
  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nItem := FBuffer[nIdx];
    if nItem.FID = nContent.FID then
    begin
      Dispose(nItem);
      FBuffer.Delete(nIdx);
    end;
  end;

  FBuffer.Add(nContent);
  //�����ʾ����

  for nIdx:=Low(FOwner.FCards) to High(FOwner.FCards) do
   if CompareText(FOwner.FCards[nIdx].FID, nContent.FID) = 0 then
    FOwner.FCards[nIdx].FLastUpdate := GetTickCount;
  //update status
end;

procedure TDisplayControler.Execute;
var nStr: string;
    nIdx: Integer;
    nContent: PDispContent;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FOwner.FBuffData.Count - 1 do
        AddContent(FOwner.FBuffData[nIdx]);
      FOwner.FBuffData.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    for nIdx:=Low(FOwner.FCards) to High(FOwner.FCards) do
    if GetTickCount - FOwner.FCards[nIdx].FLastUpdate >=
       FOwner.FCards[nIdx].FKeepTime * 1000 then
    begin
      if FOwner.FCards[nIdx].FKeepShow then
        Continue;
      //Ԥװ������ʾ����һֱ������Ϣ

      nStr := StringReplace(FOwner.FDefault, 'dt', Date2Str(Now),
              [rfReplaceAll, rfIgnoreCase]);
      //date item

      nStr := StringReplace(nStr, 'wk', Date2Week(),
              [rfReplaceAll, rfIgnoreCase]);
      //week item

      nStr := StringReplace(nStr, 'tm', Time2Str(Now),
              [rfReplaceAll, rfIgnoreCase]);
      //week item

      New(nContent);
      FBuffer.Add(nContent);

      nContent.FID := FOwner.FCards[nIdx].FID;
      nContent.FText := nStr;
      //default content
    end;

    if FBuffer.Count > 0 then
    try
      for nIdx:=Low(FOwner.FCards) to High(FOwner.FCards) do
        DoExuecte(@FOwner.FCards[nIdx]);
      //send contents
    finally
      FOwner.ClearBuffer(FBuffer);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2013-07-20
//Parm: �ַ�
//Desc: ��ȡnTxt������
function ConvertStr(const nTxt: WideString; var nBuf: TIdBytes): Integer;
var nStr: string;
    nIdx: Integer;
begin
  Result := 0;
  nStr := nTxt;
  SetLength(nBuf, Length(nStr));

  for nIdx:=1 to Length(nTxt) do
  begin
    nStr := nTxt[nIdx];
    nBuf[Result] := Ord(nStr[1]);
    Inc(Result);

    if Length(nStr) = 2 then
    begin
      nBuf[Result] := Ord(nStr[2]);
      Inc(Result);
    end;
  end;
end;
//Date: 2015/2/8
//Parm: �ַ�����Ϣ;�ַ�����
//Desc:
function AsciConvertBuf(const nTxt: string; var nBuf: TIdBytes): Integer;
var nIdx: Integer;
    nC: char;
begin
  Result := 0;
  for nIdx:=1 to Length(nTxt) do
  begin
    SetLength(nBuf, Result + 1);

    nC := nTxt[nIdx];

    nBuf[Result] := Ord(nC);
    Inc(Result);
  end;
end;

//Desc: ��ʾ����
procedure TDisplayControler.DoExuecte(const nCard: PDispCard);
var nIdx: Integer;
    nBuf: TIdBytes;
    nStrSend: string;
    nContent: PDispContent;
begin
  if not Terminated then
  try
    for nIdx:=FBuffer.Count - 1 downto 0 do
    begin
      nContent := FBuffer[nIdx];
      if CompareText(nContent.FID, nCard.FID) <> 0 then Continue;
      if CompareText(nCard.FType, cDisp_CtrlCardType) = 0 then
      begin
        nStrSend := GetBXShowInfoAtTime(nContent.FText, nCard.FAddr);
        AsciConvertBuf(nStrSend, nBuf);
      end
      else
        ConvertStr(Char($40) + Char(nCard.FAddr) + nContent.FText + #13, nBuf);

      if not nCard.FClient.Connected then
        nCard.FClient.Connect;
      //xxxxxx

      nCard.FClient.Socket.Write(nBuf);
      nCard.FLastUpdate := GetTickCount;
    end;
  except
    on E: Exception do
    begin
      WriteLog(Format('��Ļ[ %s.%s ]�쳣:[ %s ].', [nCard.FID,
        nCard.FName, E.Message]));
      //loged

      nCard.FClient.Disconnect;
      if Assigned(nCard.FClient.IOHandler) then
        nCard.FClient.IOHandler.InputBuffer.Clear;
      //close connection
    end;
  end;
end;

type
  TPackHeader = record
    FDstAddr: Integer;
    FSrcAddr: Integer;
    FReserved: array[0..5] of Byte;

    FDevType: Char;
    FProtocolVersion: Char;
  end;

  TAreaData = record
    AreaDataLen: Integer;

    AreaType: Byte;
    AreaX: Integer;
    AreaY: Integer;
    AreaWidth: Integer;
    AreaHeight: Integer;

    DynamicAreaLoc: Byte;
    Lines_sizes: Byte;
    RunMode: Byte;
    Timeout: Integer;

    Reserved: array[0..2] of char;
    SingleLine: Byte;
    NewLine: Byte;

    DisplayMode: Byte;
    ExitMode: Byte;
    Speed: Byte;
    StayTime: Byte;

    DataLen: Word;
    Data: string;
  end;

  TShowAreaData = record
    FDelAreaNum: Byte;
    FDeleteAreaId: array of Byte;

    FAreaNum: Byte;
    FAreaDataDymicA: array of TAreaData;
  end;

  TRequestData = record
    FCmdGroup: Byte;	//���������
    FCmd: Byte;	//������

    FResponse: Byte;	//�Ƿ�Ҫ��������ظ���0x01��������������ظ�;0x02�������������ػظ�
    FReserved: array[0..1] of Byte;	//����	
	
    FData:string;	//���͵�����
  end;


  TResponseData = record
    FCmdGroup: Byte;	//���������
    FCmd: Byte;	//������
	
    FCmdError: Byte;	//�����״̬
    FReserved: array[0..1] of Byte;	//����
	
    FData:string;	//���͵�����
  end;

  PBXDataRecord = ^TBXDataRecord;
  TBXDataRecord = record
    FPDHeader: array [0..7] of Byte;
    FPackHead: TPackHeader;
    FDataLen : Integer;

    FRequestData: TRequestData;
    FResponseData:TResponseData;
		
    FCRC: Int64;
    FEnd: Byte; //$5A
  end;

//Date: 2015/2/8
//Parm: ���������Դ���CRC16��
//Desc:
const tabel: array [0..255] of ULONG = (
    $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040
    );
//Date: 2015/2/8
//Parm: ԴCRC;����
//Desc: ����CRC16У���㷨
function YBCRC(const nCrc, nData: ULONG): ULONG;
begin
  Result := (nCrc shr 8) xor tabel[(nCrc xor nData) and $FF];
end;
//Date: 2015/2/8
//Parm: Դ���ݣ����ݳ���
//Desc: ����CRC16У���㷨
function YBCalcCRC16(nData: Pointer; nSize: Integer): ULONG;
var nIdx: Integer;
    nCrc: ULONG;
    nP:PAnsichar;
begin
  nCrc := 0;
  nP := nData;
  for nIdx:=0 to nSize-1 do
    nCrc := YBCRC(nCrc, Ord(nP[nIdx]));

  Result := nCrc;
end;

//������ת��Ϊ���ֽ���ǰ�����ֽ��ں��ַ���
function Int2LHStr(nInt: Integer): string;
begin
	Result := Chr(nInt mod 256) + Chr(nInt div 256);
end;
//�����ֽ���ǰ�����ֽ��ں���ַ���ת������
function LHStr2Int(nStr: string): Integer;
begin
	if Length(nStr) <> 2 then 
	begin	
		Result := 0;
		Exit;
	end;	
	Result := Ord(nStr[1]) + Ord(nStr[2]) * 256;
end;

function CalCRC16(data, crc, genpoly: Word): Word;
var i: Word;
begin
  data := data shl 8;                       // �Ƶ����ֽ�
  for i:=7 downto 0 do
  begin
    if ((data xor crc) and $8000) <> 0 then //ֻ�������λ
         crc := (crc shl 1) xor genpoly     // ���λΪ1����λ�������
    else crc := crc shl 1;                  // ����ֻ��λ����2��
    data := data shl 1;                     // ������һλ
  end;

  Result := crc;
end;

function CRC16(const nStr: string; const nStart,nEnd: Integer): Word;
var nIdx: Integer;
begin
  Result := 0;
  if (nStart > nEnd) or (nEnd < 1) then Exit;

  for nIdx:=nStart to nEnd do
  begin
    Result := CalCRC16(Ord(nStr[nIdx]), Result, $1021);
  end;
end;


procedure InitBXData(var nBXDataRecord:TBXDataRecord);
begin
  with nBXDataRecord do
  begin
    FillChar(FPDHeader, Length(FPDHeader), $A5);

    with FPackHead do
    begin
      FDstAddr := 1; //Ĭ������Ϊ1��
      FSrcAddr := $8000;
      FDevType := Chr($FE);
      FProtocolVersion := Chr($02);
      
      FillChar(FReserved, Length(FReserved), 0);
    end;

    with FRequestData do
    begin
      FillChar(FReserved, Length(FReserved), 0);
    end;

    with FResponseData do
    begin
      FillChar(FReserved, Length(FReserved), 0);
    end;

    FDataLen := 0;
    FEnd := $5A;
  end;  
end;  

function PackSendHeader(nPackHeader: TPackHeader):string;
var nIdx: Integer;
begin
	Result := '';
	with nPackHeader do
	begin
		Result := Result + Int2LHStr(FDstAddr);
		//����ַ		
		Result := Result + Int2LHStr(FSrcAddr);
		//Դ��ַ
		
		for nIdx:=Low(FReserved) to High(FReserved) do
			Result := Result + Chr(FReserved[nIdx]);
			
		Result := Result + Char(FDevType);
		Result := Result + Char(FProtocolVersion);
		//�豸������Э��汾
	end;
end;

function UnpackRecvHeader(nRecvhead: string):TPackHeader;
begin
end;

function PackRequestData(nRequestData: TRequestData):string;
var nIdx: Integer;
begin
	Result := '';
	with nRequestData do
	begin
		Result := Result + Chr(FCmdGroup);
		//���������		
		Result := Result + Chr(FCmd);
		//������		
		Result := Result + Chr(FResponse);
		//�Ƿ�Ҫ��������ظ�

		for nIdx:=Low(FReserved) to High(FReserved) do
			Result := Result + Chr(FReserved[nIdx]);

    Result := Result + FData;
		//���ݳ��������ݱ���
	end;
end;

function UnpackResponseData(nResponseData: string):TResponseData;
begin
end;

function PackSendData(const nBXDataRecord: TBXDataRecord):string;
var nIdx, nLen: Integer;
		nStrData: string;
  function StrEscape(const AStr: string;const nIndex:Integer=1):string;
  var
    i : Integer;
    ch:char;  
  begin
    Result:='';
    for i:=nIndex to length(AStr)  do
    begin
      ch:=AStr[i];
      
      if IntToHex(Ord(ch),2) = 'A6' then
      begin
        Result := Result + Chr($A6) + chr($01);
      end
      else if IntToHex(Ord(ch),2) = 'A5' then
      begin
        Result := Result + Chr($A6) + chr($02);
      end
      else if IntToHex(Ord(ch),2) = '5B' then
      begin
        Result := Result + Chr($5B) + chr($01);
      end
      else if IntToHex(Ord(ch),2) = '5A' then
      begin
        Result := Result + Chr($5B) + chr($02);
      end
      else begin
        Result := Result+ch;
      end;
    end;    
  end;
begin
	Result := '';
	
	with nBXDataRecord do
	begin
		for nIdx:=Low(FPDHeader) to High(FPDHeader) do
		 Result := Result + Chr(FPDHeader[nIdx]);
		//֡ͷ��$A5(8��) 
		
		Result := Result + PackSendHeader(FPackHead);
		//����ͷ

		nStrData := PackRequestData(FRequestData);
		nLen := Length(nStrData);
		//���ݳ���
		
		Result := Result + Int2LHStr(nLen);	
		Result := Result + nStrData;
		//���ݳ��������ݱ���
		
		Result := Result + Int2LHStr(YBCalcCRC16(@Result[9] , Length(Result)-8));
		Result := Copy(Result,1,8)+StrEscape(Result,9);
		Result := Result + Chr(FEnd);
	end;	
end;

function UnpackRecvData(const nRecvStr: string):PBXDataRecord;
begin
  Result := New(PBXDataRecord);
  with Result^ do
  begin

  end;  
end;

function ShowDynamicAreaData(const nTxt: string; nAreaX:Integer=0;
    nAreaY: Integer=0; nAreaWidth: Integer=$18; nAreaHeight: Integer=$20;
    nDynamicAreaLoc: Byte=$00; nLines_sizes: Byte=$00; nRunMode: Byte=$00;
    nTimeout: Integer=2; nSingleLine: Byte=$02; nNewLine: Byte=$02;
    nDisplayMode: Byte=$01; nExitMode: Byte=$00; nSpeed: Byte=$04;
    nStayTime: Byte=$05): string;
var nInt: Integer;
    nStrArea: string;
    nShowAreaData:TShowAreaData;
begin
  Result := '';
  with nShowAreaData do
  begin
    FDelAreaNum := 0;
    SetLength(FDeleteAreaId, 0);

    FAreaNum := 1;
    SetLength(FAreaDataDymicA, 1);

    Result := Result + Chr(FDelAreaNum);
    Result := Result + Chr(FAreaNum);

    nStrArea := '';
    with FAreaDataDymicA[0] do
    begin
      AreaType := $00;
      AreaX := nAreaX;
      AreaY := nAreaY;

      nStrArea := nStrArea + Chr(AreaType);
      nStrArea := nStrArea + Int2LHStr(AreaX);
      nStrArea := nStrArea + Int2LHStr(AreaY);

      AreaWidth := nAreaWidth;
      AreaHeight := nAreaHeight;

      nStrArea := nStrArea + Int2LHStr(AreaWidth);
      nStrArea := nStrArea + Int2LHStr(AreaHeight);

      DynamicAreaLoc := nDynamicAreaLoc;
      Lines_sizes := nLines_sizes;
      RunMode := nRunMode;
      Timeout := nTimeout;

      nStrArea := nStrArea + Chr(DynamicAreaLoc);
      nStrArea := nStrArea + Chr(Lines_sizes);
      nStrArea := nStrArea + Chr(RunMode);
      nStrArea := nStrArea + Int2LHStr(Timeout);

      for nInt:=Low(Reserved) to High(Reserved) do
       nStrArea := nStrArea + Reserved[nInt];

      SingleLine := nSingleLine;
      NewLine := nNewLine;

      nStrArea := nStrArea + Chr(SingleLine);
      nStrArea := nStrArea + Chr(NewLine);

      DisplayMode := nDisplayMode;
      ExitMode := nExitMode;
      Speed := nSpeed;
      StayTime := nStayTime;

      nStrArea := nStrArea + Chr(DisplayMode);
      nStrArea := nStrArea + Chr(ExitMode);
      nStrArea := nStrArea + Chr(Speed);
      nStrArea := nStrArea + Chr(StayTime);

      DataLen := Length(nTxt);
      Data := nTxt;

      nStrArea := nStrArea + Int2LHStr(DataLen) + #00#00 ;
      nStrArea := nStrArea + Data;
    end;

    Result := Result + Int2LHStr(Length(nStrArea));
    Result := Result + nStrArea;
  end;
end;  

function GetBXShowInfoAtTime(nTxt: string; nAddr: Integer=0): string;
var nStrSend: string;
    nBXDataRecord: TBXDataRecord;
begin
  InitBXData(nBXDataRecord);

  with nBXDataRecord do
  begin
    if nAddr <> 0 then FPackHead.FDstAddr := nAddr;

    with FRequestData do
    begin
      FCmd := $06;
      FCmdGroup := $A3;
      FResponse := $02;

      nStrSend:=StringReplace(nTxt,Chr($A5), Chr($A6)+Chr($02), [rfReplaceAll]);
      nStrSend:=StringReplace(nTxt,Chr($5A), Chr($5B)+Chr($02), [rfReplaceAll]);

      //nTxt := Copy(nTxt, 1, 24);
      FData := ShowDynamicAreaData(nTxt);
      FDataLen := Length(FData);
    end;
  end;

  Result := PackSendData(nBXDataRecord);
end;  

initialization
  gDisplayManager := TDisplayManager.Create;
finalization
  FreeAndNil(gDisplayManager);
end.
