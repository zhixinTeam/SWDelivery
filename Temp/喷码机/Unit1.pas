unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CPort, StdCtrls, ExtCtrls, CPortCtl, UMgrCodePrinter,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, USysLoger,
  Sockets;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    CheckBox1: TCheckBox;
    ComPort1: TComPort;
    Memo1: TMemo;
    ComComboBox1: TComComboBox;
    Button2: TButton;
    Button3: TButton;
    IdTCPClient1: TIdTCPClient;
    TcpClient1: TTcpClient;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComPort1RxBuf(Sender: TObject; const Buffer: PAnsiChar;
      Count: Integer);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TcpClient1Receive(Sender: TObject; Buf: PAnsiChar;
      var DataLen: Integer);
  private
    { Private declarations }
    FBuffer: string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  gPath: string;

implementation

{$R *.dfm}
uses IdGlobal, ULibFun;

type
  TByteWord = record
    FH: Byte;
    FL: Byte;
  end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
  begin
    ComPort1.Close;
    ComPort1.Port := ComComboBox1.Text;
    ComPort1.Open;
  end else ComPort1.Close;
end;

function CalCRC16(data, crc, genpoly: Word): Word;
var i: Word;
begin
  data := data shl 8;                       // 移到高字节
  for i:=7 downto 0 do
  begin
    if ((data xor crc) and $8000) <> 0 then //只测试最高位
         crc := (crc shl 1) xor genpoly     // 最高位为1，移位和异或处理
    else crc := crc shl 1;                  // 否则只移位（乘2）
    data := data shl 1;                     // 处理下一位
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

procedure TForm1.Button1Click(Sender: TObject);
var nStr,nData: string;
    nBuf: array of Byte;
    nCrc: TByteWord;
    nWord: Word;
begin
  //protocol: 55 7F len order datas crc16 AA
  nData := Char($55) + Char($7F) + Char(Length(Edit1.Text) + 1) + 'E' + Char($5A);
  nData := nData + Edit1.Text;

  nCrc := TByteWord(CRC16(nData, 5, Length(nData)));
  nData := nData + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);

  SetLength(nBuf, Length(nData) + 1);
  StrPCopy(@nBuf[0], nData);

  ComPort1.WriteStr(nData);
  //ComPort1.Write(@nbuf[0], Length(nData));
  Memo1.Lines.Add(TimeToStr(Now) + ' ::: 编辑成功.');
                                            Exit;
  nData := Char($55) + Char($7F) + Char($01) + 'P' + Char($01);
  nCrc := TByteWord(CRC16(nData, 5, Length(nData)));
  nData := nData + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);

  SetLength(nBuf, Length(nData) + 1);
  StrPCopy(@nBuf[0], nData);

  ComPort1.WriteStr(nData);
  Memo1.Lines.Add(TimeToStr(Now) + ' ::: 打印成功.');
end;

procedure TForm1.ComPort1RxBuf(Sender: TObject; const Buffer: PAnsiChar;
  Count: Integer);
var nStr,nTmp: string;
    nIdx,nE: Integer;
begin
  FBuffer := FBuffer + StrPas(Buffer);
  nE := 0;
  nStr := '';

  for nIdx:=Length(FBuffer) downto 1 do
  begin
    if Ord(FBuffer[nIdx]) = $AA then
    begin
      nE := nIdx; Continue;
    end;

    if (Ord(FBuffer[nIdx]) = $55) and (nE > 0) then
    begin
      nStr := Copy(FBuffer, nIdx, nE - nIdx + 1);
      System.Delete(FBuffer, 1, nIdx);
    end;
  end;

  if nStr <> '' then
  begin
    nTmp := '';
    
    for nIdx:=1 to Length(nStr) do
      nTmp := nTmp + ' ' + IntToHex(Ord(nStr[nIdx]), 2);
    Memo1.Lines.Add(nTmp);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  gPath := ExtractFilePath(Application.ExeName);
  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gCodePrinterManager.LoadConfig(gPath + 'CodePrinter.xml');
end;

procedure TForm1.Button2Click(Sender: TObject);
var nHint: string;
begin
  if not gCodePrinterManager.PrintCode(Edit2.Text, Edit1.Text, nHint) then
    ShowMessage(nHint);
end;


procedure TForm1.Button3Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nBuf: TIdBytes;
    nList: TStrings;
begin
  nStr := '55 7F 06 54 01 31 35 36 38 39 F0 2F aa';
  nList := TStringList.Create;
  SplitStr(nStr, nList, 0, ' ');

  nStr := '';
  for nIdx:=0 to nList.Count - 1 do
  begin
    nStr := nStr + Char(StrToInt('$' + nList[nIdx]));
  end;

  nList.Free;

  nBuf  := ToBytes(nStr, en8Bit);


  if not IdTCPClient1.Connected then
    IdTCPClient1.Connect;
  IdTCPClient1.Socket.Write(nBuf);

  //SetLength(nBuf, 0);
  IdTCPClient1.Socket.ReadBytes(nBuf, 9, False);

  nStr := '';
  for nIdx:=Low(nBuf) to High(nBuf) do
  begin
    nStr := nStr + ' ' + IntToHex(nBuf[nIdx], 2);
  end;

  Memo1.Lines.Add(nStr);
  
end;

procedure TForm1.TcpClient1Receive(Sender: TObject; Buf: PAnsiChar;
  var DataLen: Integer);
var nIdx: Integer;
    nStr,nData: string;
begin
  SetLength(nData, DataLen);
  StrLCopy(PChar(nData), Buf, DataLen);

  nStr := '';
  for nIdx:=1 to Length(nData) do
  begin
    nStr := nStr + ' ' + IntToHex(Ord(nData[nIdx]), 2);
  end;

  Memo1.Lines.Add(nStr);
end;

end.
