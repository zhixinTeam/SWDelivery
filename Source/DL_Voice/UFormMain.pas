{*******************************************************************************
  ����: dmzn@163.com 2012-4-21
  ����: �����������
*******************************************************************************}
unit UFormMain;

{.$DEFINE DEBUG}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdGlobal, UTrayIcon, UBase64, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, ComCtrls, StdCtrls, IdContext, ExtCtrls;

type
  TfFormMain = class(TForm)
    GroupBox1: TGroupBox;
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    CheckSrv: TCheckBox;
    EditPort: TLabeledEdit;
    IdTCPServer1: TIdTCPServer;
    CheckAuto: TCheckBox;
    CheckLoged: TCheckBox;
    Timer1: TTimer;
    BtnTest: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckSrvClick(Sender: TObject);
    procedure CheckLogedClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnTestClick(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*״̬��ͼ��*}
    FResource: TStrings;
    //�ı���Դ
    FNetVoice: Boolean;
    //����ģʽ
    procedure ShowLog(const nStr: string);
    //��ʾ��־
    procedure DoExecute(const nContext: TIdContext);
    //ִ�ж���
    function VoiceTextAdjust(const nText: WideString): string;
    //�ı�����
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, USysLoger, UMgrVoice, UMgrRemoteVoice,
  UMgrVoiceNet, UMemDataPool;

var
  gPath: string;               //����·��
  gCompany: string = '';       //��˾����

resourcestring
  sHint               = '��ʾ';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sAutoStartKey       = 'VoiceHelper';
  sResourceFile       = 'VoiceRes.txt';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '������������Ԫ', nEvent);
end;

//------------------------------------------------------------------------------
procedure TfFormMain.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm);

  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Application.Title;
  FTrayIcon.Visible := True;

  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    EditPort.Text := nIni.ReadString('Config', 'Port', '8000');
    Timer1.Enabled := nIni.ReadBool('Config', 'Enabled', False);

    FNetVoice := nIni.ReadInteger('Config', 'NetVoice', 0) = 1;
    //�����������

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    CheckAuto.Checked := nReg.ValueExists(sAutoStartKey);
  finally
    nIni.Free;
    nReg.Free;
  end;

  gMemDataManager := TMemDataManager.Create;
  //�ڴ������

  if FNetVoice then
  begin
    gNetVoiceHelper := TNetVoiceManager.Create;
    gNetVoiceHelper.LoadConfig(gPath + 'NetVoice.xml');
  end else
  begin
    gVoiceManager.LoadConfig(gPath + 'Voice.xml');
    //voice manager

    FResource := TStringList.Create;
    if FileExists(gPath + sResourceFile) then
      FResource.LoadFromFile(gPath + sResourceFile);
    //load resource
  end;
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    nIni.WriteBool('Config', 'Enabled', CheckSrv.Checked);

    if nIni.ReadString('Config', 'Port', '') = '' then
      nIni.WriteString('Config', 'Port', EditPort.Text);
    //xxxxx

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    if CheckAuto.Checked then
      nReg.WriteString(sAutoStartKey, Application.ExeName)
    else if nReg.ValueExists(sAutoStartKey) then
      nReg.DeleteValue(sAutoStartKey);
    //xxxxx
  finally
    nIni.Free;
    nReg.Free;
  end;

  FResource.Free;
  //free obj
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CheckSrv.Checked := True;
end;

procedure TfFormMain.CheckSrvClick(Sender: TObject);
begin
  if not IdTCPServer1.Active then
    IdTCPServer1.DefaultPort := StrToInt(EditPort.Text);
  IdTCPServer1.Active := CheckSrv.Checked;

  BtnTest.Enabled := CheckSrv.Checked;
  EditPort.Enabled := not CheckSrv.Checked;

  if FNetVoice then
  begin
    if CheckSrv.Checked then
         gNetVoiceHelper.StartVoice
    else gNetVoiceHelper.StopVoice;
  end else
  begin
    if CheckSrv.Checked then
         gVoiceManager.StartVoice
    else gVoiceManager.StopVoice;
  end;
end;

procedure TfFormMain.CheckLogedClick(Sender: TObject);
begin
  gSysLoger.LogSync := CheckLoged.Checked;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

//Date: 2014-05-21
//Parm: ���������ı�
//Desc: ʹ��������Դ,��nText�е������ַ����н���
function TfFormMain.VoiceTextAdjust(const nText: WideString): string;
var nStr: string;
    nIdx,nLen: Integer;
begin
  Result := '';
  nLen := Length(nText);

  for nIdx:=1 to nLen do
  begin
    nStr := FResource.Values[nText[nIdx]];
    if nStr = '' then
         Result := Result + nText[nIdx]
    else Result := Result + nStr;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;

procedure TfFormMain.DoExecute(const nContext: TIdContext);
var nStr: string;
    nBuf: TIdBytes;
    nBase: TVCDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeVCBase, False);
    BytesToRaw(nBuf, nBase, cSizeVCBase);

    case nBase.FCommand of
     cVCCmd_PlaySound :
      begin
        Socket.ReadBytes(nBuf, nBase.FDataLen, False);
        nStr := DecodeBase64(BytesToString(nBuf));

        if FNetVoice then
             gNetVoiceHelper.PlayVoice(nStr)
        else gVoiceManager.PlayVoice(VoiceTextAdjust(nStr));
      end;
    end;
  end;
end;

//Desc: test
procedure TfFormMain.BtnTestClick(Sender: TObject);
var nStr: string;
begin
  nStr := '������������ϳ�ϵͳ���԰�ť';
  //test
  
  if FNetVoice then
       gNetVoiceHelper.PlayVoice(nStr)
  else gVoiceManager.PlayVoice(nStr);
end;

end.
