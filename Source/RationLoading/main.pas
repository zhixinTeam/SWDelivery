unit main;
{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient,PLCController, ExtCtrls, IdContext, IdCustomTCPServer,
  IdTCPServer, IniFiles, IdGlobal, UMgrSendCardNo;

type
  TFormMain = class(TForm)
    IdTCPServer1: TIdTCPServer;
    Memo1: TMemo;
    wPanel: TScrollBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    function IdBytesToAnsiString(ParamBytes: TIdBytes): AnsiString;
  private
    { Private declarations }
    procedure LoadPoundItems;
    procedure ResetPanelPosition;
    //����λ��
    procedure RunSysObject;
  public
    { Public declarations }
    procedure DoExecute(const nContext: TIdContext);
    procedure OnGetCardNo(var nBase: TSendDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //���մſ���
  end;

var
  FormMain: TFormMain;
  AppPath: string;
  gPlcOpenValue: Integer;
  gMitUrl:string;
  gUpDownKeepOpen:Boolean;

implementation

uses
  UFrame, UMgrPoundTunnels, USysLoger, UClientWorker, UMemDataPool, UFormConn,
  UMgrChannel, UChannelChooser, UMITPacker, ULibFun, UDataModule;

{$R *.dfm}

procedure TFormMain.FormShow(Sender: TObject);
var
  nFrame:TFrame1;
begin
  if not Assigned(gPoundTunnelManager) then
  begin
    gPoundTunnelManager := TPoundTunnelManager.Create;
    gPoundTunnelManager.LoadConfig('Tunnels.xml');
  end;
  LoadPoundItems;
  ResetPanelPosition;
  Memo1.Clear;
end;

procedure TFormMain.LoadPoundItems;
var nIdx: Integer;
    nT: PPTTunnelItem;
begin
  with gPoundTunnelManager do
  begin
    for nIdx:= 0 to Tunnels.Count-1 do
    begin
      if nIdx > 5 then
      begin
        ShowMsg('�������ͨ��', '����');
        Exit;
      end;
      nT := Tunnels[nIdx];
      //tunnel

      if Assigned(nT.FOptions) And
         (UpperCase(nT.FOptions.Values['Enable']) <> 'Y') then
      begin
        Continue;
      end;

      with TFrame1.Create(Self) do
      begin
        Name := 'fFramePlcCtrl' + IntToStr(nIdx);
        Parent := wPanel;

        FrameId := nIdx+1;

        GroupBox1.Caption := nT.FName;
        PoundTunnel := nT;
        FTCPSer := IdTCPServer1;
        IdTCPServer1.Active := True;

        FSysLoger:= gSysLoger;
      end;
    end;
  end;
end;

//Desc: ���ü������λ��
procedure TFormMain.ResetPanelPosition;
var nIdx: Integer;
    nL,nT,nNum: Integer;
    nCtrl: TFrame1;
begin
  nT := 0;
  nL := 0;
  nNum := 0;

  for nIdx:=0 to wPanel.ControlCount - 1 do
  if wPanel.Controls[nIdx] is TFrame1 then
  begin
    nCtrl := wPanel.Controls[nIdx] as TFrame1;

    if ((nL + nCtrl.Width) > wPanel.ClientWidth) and (nNum > 0) then
    begin
      nL := 0;
      nNum := 0;
      nT := nT + nCtrl.Height;
    end;

    nCtrl.Top := nT;
    nCtrl.Left := nL;

    Inc(nNum);
    nL := nL + nCtrl.Width;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  MyFile : TIniFile;
  LocalPort: Integer;
begin
  AppPath := ExtractFilePath(Application.ExeName);

  MyFile := TIniFile.Create(AppPath + 'sysconfig.ini');

  LocalPort := MyFile.ReadInteger('FixLoading','localPort',5050);

  gMitUrl := MyFile.ReadString('Mit','MitUrl','');
  MyFile.Free;


  RunSysObject;

  IdTCPServer1.DefaultPort := LocalPort;
end;



procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IdTCPServer1.Active := False;
end;

procedure TFormMain.RunSysObject;
begin
  gSysLoger := TSysLoger.Create(AppPath + 'Logs\');
  //Sysloger
  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //mem pool

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel
  gChannelChoolser.AddChannelURL(gMitUrl);
end;

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      //Frame1.WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;

procedure TFormMain.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
    nBase: TSendDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeSendBase, False);
    BytesToRaw(nBuf, nBase, cSizeSendBase);

    case nBase.FCommand of
     cCmd_SendCard :
      begin
        OnGetCardNo(nBase,nBuf,nContext);
      end;
    end;
  end;
end;

procedure TFormMain.OnGetCardNo(var nBase: TSendDataBase;
  var nBuf: TIdBytes; nCtx: TIdContext);
var
  nTunnel, nCardNo, nStr: string;
  i: Integer;
  nT: PPTTunnelItem;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));
  i := Pos('@',nStr);
  if i < 0 then Exit;

  nTunnel:= Copy(nStr,0,i-1);
  nCardNo := Copy(nStr,i+1,Length(nStr));
  Memo1.Lines.Add('���յ�����:'+ nTunnel + ',' + nCardNo);
  for i := 0 to gPoundTunnelManager.Tunnels.Count - 1 do
  begin
    if i > 5 then
      Continue;

    nT := gPoundTunnelManager.Tunnels[i];
    //tunnel

    if Assigned(nT.FOptions) And
       (UpperCase(nT.FOptions.Values['Enable']) <> 'Y') then
    begin
      Continue;
    end;

    with  TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))) do
    begin
      //if FIsBusy then Continue;
      if PoundTunnel.FID = nTunnel then
      begin
        if Pos('Close', nCardNo) > 0 then
        begin
          IncTon.Value := 0;
          IncMin.Value := 0;
          StopPound;
          Exit;
        end;
        EditBill.Text := nCardNo;
        LoadBillItems(EditBill.Text);
      end;
    end;
  end;
end;

function TFormMain.IdBytesToAnsiString(ParamBytes: TIdBytes): AnsiString;
var
  i: Integer;
  S: AnsiString;
begin
  S := '';
  for i := 0 to Length(ParamBytes) - 1 do
  begin
    S := S + AnsiChar(ParamBytes[i]);
  end;
  //ShowMessage(s);
  Result := S;
end;

end.
