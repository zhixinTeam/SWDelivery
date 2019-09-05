unit PLCController;

interface
uses
  IdGlobal,IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient;
const
  //PLC��ַ
  Addr_PLC=$02;
  //modbus������
  mbfReadHoldingRegs = $03;//��ȡ�Ĵ���
  mbfWriteOneReg = $06;//д�����Ĵ���
  //ModBusƫ�Ƶ�ַ,ָ������ƫ�Ƶ�ַΪ��ֵ��1
  Addr_Offset:array[0..18] of Word = (
    0001,	//���ƣ���ÿλ������£�
    0002,	//��������ÿλ������£�
    0003,	//�������趨
    0004,	//�����ȷ���
    0005,  //����
    0006,  //����
    0007,  // ���ƣ���ÿλ������£�
    0008,	//��������ÿλ������£�
    0009,	//�������趨
    0010,	//�����ȷ���
    0011,  //����
    0012,  //����
    0013,	//���ƣ���ÿλ������£�
    0014,	//��������ÿλ������£�
    0015,	//�������趨
    0016,	//�����ȷ���
    0017,  //����
    0018,  //����
    0019   //����
  );

  Control_UP:Word=$0001; //����
  Control_DOWN:Word=$0002; //�½�
  Control_Add:Word=$0004; //����
  Control_Pause:Word=$0008; //��ͣ����
  Control_Reset:Word=$0010; //���ϸ�λ

  Feedback_ready:Word=$0001;          //�����ź�
  Feedback_switch:Word=$0002;         //��λ����
  Feedback_FanStatus:Word=$0004;      //������з���
  Feedback_MaterialStatus:Word=$0008; //�������з���

  Feedback_ErrUp:Word = $0016;        //��������
  Feedback_ErrMove:Word = $0032;      //�ƶ�����
  Feedback_ErrSignal:Word = $0064;    //ͨ�Ź���
  Feedback_ErrTotle:Word = $0128;     //ϵͳ�ܹ���
  Feedback_ErrFan:Word = $0256;       //���δ����

  Const_instruction_size=8; //ָ���
type
  //otStart:��ʼ
  //otPause:��ͣ
  //otStop:ֹͣ
  //otReset:��λ
  //otUp:����
  //otDown:����
  //otQuery:��ѯ
  //otUNPause:ȡ����ͣ
  //otUnUP:ֹͣ����
  //otUnDown:ֹͣ�½�
  //otUnReset:ȡ����λ
  //otSetOpen���趨����
  //otGetOpen:��ȡ����
  //otGetStatus:��ȡ����״̬��Ϣ
  TOptionType = (otStart,otPause,otStop,otReset,otUp,otDown,otQuery,
    otUNPause,otUnUP,otUnDown,otUnReset,otSetOpen,otGetOpen,otGetStatus);
  TPLCController = class(TObject)
  private
    FErrCode:Integer;
    FErrMsg:string;
    FTcpCient:TIdTCPClient;
    FMasterAddr:Byte;
    FIndex:Integer;
    FOpenValue:Integer;         //����
    FUpDownKeepOpen: Boolean;  //�����½�ʱ�Ƿ�رշ��Ͽ�
    Finstructions:TIdBytes;
    FCurrentOpt:TOptionType;
    FStatusOrd:TIdBytes;
    function Initinstructions:Boolean;
    function CalculateCRC16ModBus(const Buffer: array of Byte; const nEnd:Integer=0):Word;
    function iIntToHex(n:Word):Byte;
  public
    constructor Create(nTcpClient:TIdTCPClient;const nMasterAddr:Byte=Addr_PLC);
    function Start(const nIdx:integer):Boolean;
    function Pause(const nIdx:integer):Boolean;
    function UnPause(const nIdx:Integer):boolean;
    function Stop(const nIdx:integer):Boolean;
    function Reset(const nIdx:integer):Boolean;
    function Up(const nIdx:integer; nData:Boolean):Boolean;
    function UnUp(const nIdx:integer; nData:Boolean):Boolean;
    function Down(const nIdx:integer; nData:Boolean):Boolean;
    function UnDown(const nIdx:Integer; nData:Boolean):Boolean;
    function Query(const nIdx:Integer;var nData:Word):Boolean;
    function UnReset(const nIdx:integer):Boolean;

    function SetOpening(const nIdx, nValue:integer):Boolean;
    function GetOpening(const nIdx, nValue:Integer):Integer;
    function GetStatus(const nIdx, nValue:Integer):Boolean;
    property ErrCode:Integer read FErrCode;
    property ErrMsg:string read FErrMsg;
    property StatusOrd:TIdBytes read FStatusOrd;
  end;

implementation
uses
  SysUtils;
{ TPLCController }

function TPLCController.CalculateCRC16ModBus(const Buffer: array of Byte;
  const nEnd: Integer): Word;
const
  GENP=$A001;//����ʽ��ʽX16+X15+X2+1��1100 0000 0000 0101��
var
  crc:Word;
  i:Integer;
  tmp:Byte;
  nfinalValue :Integer;

  //����1���ֽڵ�У����
  procedure CalOneByte(AByte:Byte);
  var
    j:Integer;
  begin
    crc:=crc xor AByte;//��������CRC�Ĵ����ĵ�8λ�������
    for j:=0 to 7 do //��ÿһλ����У��
    begin
      tmp:=crc and 1;//ȡ�����λ
      crc:=crc shr 1;//�Ĵ���������һλ
      crc:=crc and $7FFF;//�����λ��0
      if tmp=1 then//����Ƴ���λ�����Ϊ1����ô�����ʽ���
      begin
        crc:=crc xor GENP;
      end;
      crc:=crc and $FFFF;
    end;
  end;
begin
  nfinalValue := High(Buffer);
  if nEnd>0 then
  begin
    nfinalValue := nEnd;
  end;
  crc:=$FFFF;             //�������趨ΪFFFF
  for i:=Low(Buffer) to nfinalValue do   //��ÿһ���ֽڽ���У��
  begin
    CalOneByte(Buffer[i]);
  end;
  Result:=crc;
end;

constructor TPLCController.Create(nTcpClient:TIdTCPClient;const nMasterAddr: Byte);
begin
  inherited create;
  FErrCode := 0;
  FErrMsg := '';
  FTcpCient := nTcpClient;
  FMasterAddr := nMasterAddr;
end;

function TPLCController.UnPause(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUNPause;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 30000;
        FErrMsg := 'ȡ����ָͣ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 39999;
      FErrMsg := 'ȡ����ָͣ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;  
end;

function TPLCController.Down(const nIdx:integer; nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otDown;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 80000;
        FErrMsg := '����ָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 89999;
      FErrMsg := '����ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.Initinstructions: Boolean;
var
  nCrc:Word;
  noffset:word;
  nCrcStr:string;
  nUnPauseInstruct,nUnUpInstruct,nUnDownInstruct,nUnResetInstruct:Word;
  nOrder:string;
begin
  nUnPauseInstruct := $0004;  //not Control_Pause;
  nUnUpInstruct    := $0000;  //not Control_UP;
  nUnDownInstruct  := $0000;  //not Control_DOWN;
  nUnResetInstruct := $0000;  //not Control_Reset;
  case FCurrentOpt of
    otSetOpen:   noffset := Addr_Offset[(FIndex-1)*6]+1;
    otGetOpen:   noffset := Addr_Offset[(FIndex-1)*6]+2;
    otGetStatus: noffset := Addr_Offset[0]-1;
    otUp, otUnUP:begin
      if FUpDownKeepOpen then
        noffset := Addr_Offset[(FIndex-1)*6]+3   //�����½�ʱ���Ͽڱ��ֿ���
      else
        noffset := Addr_Offset[(FIndex-1)*6]-1;
    end;
    otDown,otUnDown:begin
      if FUpDownKeepOpen then
        noffset := Addr_Offset[(FIndex-1)*6]+4   //�����½�ʱ���Ͽڱ��ֿ���
      else
        noffset := Addr_Offset[(FIndex-1)*6]-1;
    end;
  else
    noffset := Addr_Offset[(FIndex-1)*6]-1;
  end;

  SetLength(Finstructions,Const_instruction_size);
  FillBytes(Finstructions,Const_instruction_size,0);

  Finstructions[0] := FMasterAddr;
  case FCurrentOpt of
    otStart:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_Add shr 8;
      Finstructions[5] := Control_Add and $0F;
    end;
    otPause:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_pause shr 8;
      Finstructions[5] := Control_pause and $0F;
    end;
    otUnPause:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := 0;//nUnPauseInstruct shr 8;
      Finstructions[5] := 0;//nUnPauseInstruct and $0F;
    end;    
    otStop:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := 0;
      Finstructions[5] := 0;
    end;
    otReset:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_Reset shr 8;
      Finstructions[5] := Control_Reset;
    end;
    otUnReset:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := nUnResetInstruct shr 8;
      Finstructions[5] := nUnResetInstruct and $0F;
    end;
    otUp:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := Control_UP shr 8;
      Finstructions[5] := Control_UP and $0F;
    end;
    otUnUP:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := nUnUpInstruct shr 8;
      Finstructions[5] := nUnUpInstruct and $0F;    
    end;
    otDown:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      if FUpDownKeepOpen then
      begin
        Finstructions[4] := Control_UP shr 8;
        Finstructions[5] := Control_UP and $0F;
      end
      else
      begin
        Finstructions[4] := Control_DOWN shr 8;
        Finstructions[5] := Control_DOWN and $0F;
      end;
    end;
    otUnDown:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := nUnDownInstruct shr 8;
      Finstructions[5] := nUnDownInstruct and $0F;
    end;  
    otQuery:begin
      Finstructions[1] := mbfReadHoldingRegs;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := 0;
      Finstructions[5] := 1;
    end;
    otSetOpen:begin
      Finstructions[1] := mbfWriteOneReg;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := $00;
      Finstructions[5] := Word(FOpenValue);
    end;
    otGetOpen:begin
      Finstructions[1] := mbfReadHoldingRegs;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := $00;
      Finstructions[5] := Word(FOpenValue);
    end;
    otGetStatus:begin
      Finstructions[1] := mbfReadHoldingRegs;
      Finstructions[2] := noffset shr 8;
      Finstructions[3] := noffset and $0F;
      Finstructions[4] := $00;
      Finstructions[5] := Word(20);
    end;
  else;
  end;
  nCrc := CalculateCRC16ModBus(Finstructions,5);
  nCrcStr := IntToHex(nCrc,2);
  if Length(nCrcStr)=3 then nCrcStr := '0'+nCrcStr;
  Finstructions[6] := StrToInt('$'+Copy(nCrcStr,3,2));
  Finstructions[7] := StrToInt('$'+Copy(nCrcStr,1,2));
end;

function TPLCController.Pause(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otPause;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 20000;
        FErrMsg := '��ָͣ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 29999;
      FErrMsg := '��ָͣ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;  
end;

function TPLCController.Query(const nIdx:Integer;var nData:Word): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
  iretSize:Integer;
begin
  nData := 0;
  Result := False;
  FCurrentOpt := otStart;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    nData := nRecvBuffer[3] shl 8 +nRecvBuffer[4];
  except
    on E:Exception do
    begin
      FErrCode := 109999;
      FErrMsg := '��ѯָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
end;

function TPLCController.Reset(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otReset;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 50000;
        FErrMsg := '��λָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 59999;
      FErrMsg := 'ȡ����λָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.Start(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otStart;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 10000;
        FErrMsg := '����ָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 19999;
      FErrMsg := '����ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.Stop(const nIdx:integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otStop;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 40000;
        FErrMsg := 'ָֹͣ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 49999;
      FErrMsg := 'ָֹͣ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;  
end;

function TPLCController.Up(const nIdx:integer; nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUp;
  FIndex := nIdx;
  FUpDownKeepOpen := nData ;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 60000;
        FErrMsg := '����ָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 69999;
      FErrMsg := '����ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.UnUp(const nIdx: integer;nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUnUP;
  FIndex := nIdx;
  FUpDownKeepOpen:= nData;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 70000;
        FErrMsg := 'ȡ������ָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 79999;
      FErrMsg := 'ȡ������ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.UnDown(const nIdx: Integer; nData:Boolean): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUnDown;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 90000;
        FErrMsg := 'ȡ������ָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 99999;
      FErrMsg := 'ȡ������ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.UnReset(const nIdx: integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i:Integer;
begin
  Result := False;
  FCurrentOpt := otUnReset;
  FIndex := nIdx;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 110000;
        FErrMsg := 'ȡ����ָͣ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 119999;
      FErrMsg := 'ȡ����ָͣ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.SetOpening(const nIdx, nValue: integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i: integer;
begin
  Result := False;
  FCurrentOpt := otSetOpen;
  FIndex := nIdx;
  FOpenValue := nvalue;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 120000;
        FErrMsg := '���÷�λ����ָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 129999;
      FErrMsg := '���÷�λ����ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := True;
end;

function TPLCController.GetOpening(const nIdx, nValue:integer): Integer;
var
  nRecvBuffer:TIdBytes;
  i: integer;
begin
  Result := -1;
  FCurrentOpt := otGetOpen;
  FIndex := nIdx;
  FOpenValue := nValue;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    for i := 0 to Const_instruction_size-1 do
    begin
      if Finstructions[i]<>nRecvBuffer[i] then
      begin
        FErrCode := 130000;
        FErrMsg := '��ȡ��λ����ָ��ִ��ʧ��';
        Exit;
      end;
    end;
  except
    on E:Exception do
    begin
      FErrCode := 139999;
      FErrMsg := '��ȡ��λ����ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := 0;
end;

function TPLCController.GetStatus(const nIdx, nValue: Integer): Boolean;
var
  nRecvBuffer:TIdBytes;
  i: integer;
begin
  Result := False;
  FCurrentOpt := otGetStatus;
  FIndex := nIdx;
  FOpenValue := nValue;
  Initinstructions;
  try
    FTcpCient.Socket.Write(Finstructions);
    FTcpCient.Socket.ReadBytes(nRecvBuffer,-1);
    FStatusOrd := nRecvBuffer;
  except
    on E:Exception do
    begin
      FErrCode := 149999;
      FErrMsg := '��ȡ��λ����ָ��ִ��ʧ��,����δ֪�쳣:'+e.Message;
      Exit;
    end;
  end;
  Result := true;
end;

function TPLCController.iIntToHex(n: Word): Byte;
begin
  if n < 10 then
  begin
    Result := n;
    exit;
  end;
  case n of
    10:Result := $0A;
    11:Result := $0B;
    12:Result := $0C;
    13:Result := $0D;
    14:Result := $0E;
    15:Result := $0F;
  end;
end;

end.
