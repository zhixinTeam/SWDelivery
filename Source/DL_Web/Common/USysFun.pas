{*******************************************************************************
  ����: dmzn@163.com 2018-05-03
  ����: ��Ŀͨ�ú������嵥Ԫ
*******************************************************************************}
unit USysFun;

interface

uses
  Windows, Classes, Forms, SysUtils, IniFiles, UBaseObject, USysConst;

procedure InitSystemEnvironment;
//��ʼ��ϵͳ���л����ı���
procedure LoadSysParameter(const nIni: TIniFile = nil);
//����ϵͳ���ò���

function MakeMenuID(const nEntity,nMenu: string): string;
//�˵���ʶ
function MakeFrameName(const nFrameID: integer): string;
//����Frame����
function ReplaceGlobalPath(const nStr: string): string;
//�滻nStr�е�ȫ��·��

implementation

//---------------------------------- �������л��� ------------------------------
//Date: 2007-01-09
//Desc: ��ʼ�����л���
procedure InitSystemEnvironment;
begin
  Randomize;
  gPath := ExtractFilePath(Application.ExeName);

  with FormatSettings do
  begin
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';
  end;

  with TObjectStatusHelper do
  begin
    shData := 50;
    shTitle := 100;
  end;
end;

//Date: 2007-09-13
//Desc: ����ϵͳ���ò���
procedure LoadSysParameter(const nIni: TIniFile = nil);
var nTmp: TIniFile;
begin
  if Assigned(nIni) then
       nTmp := nIni
  else nTmp := TIniFile.Create(gPath + sConfigFile);

  try
    with gSysParam, nTmp do
    begin
      FillChar(gSysParam, SizeOf(TSysParam), #0);
      FFactory := -1;
      //��ʼ��ȫ�ֲ���

      FProgID := ReadString(sConfigSec, 'ProgID', sProgID);
      //�����ʶ�����������в���
      FAppTitle := ReadString(FProgID, 'AppTitle', sAppTitle);
      FMainTitle := ReadString(FProgID, 'MainTitle', sMainCaption);
      FHintText := ReadString(FProgID, 'HintText', '');
      FCopyRight := ReadString(FProgID, 'CopyRight', '');
    end;

    with gServerParam, nTmp do
    begin
      FPort := ReadInteger('Server', 'Port', 8077);
      FExtJS := ReadString('Server', 'JS_Ext', '');
      FUniJS := ReadString('Server', 'JS_Uni', '');
      FDBMain := ReadString('Database', 'Main', '');
    end;
  finally
    if not Assigned(nIni) then nTmp.Free;
  end;
end;

//Desc: �˵���ʶ
function MakeMenuID(const nEntity,nMenu: string): string;
begin
  Result := nEntity + '_' + nMenu;
end;

//Desc: ����FrameID���������
function MakeFrameName(const nFrameID: integer): string;
begin
  Result := 'Frame' + IntToStr(nFrameID);
end;

//Desc: �滻nStr�е�ȫ��·��
function ReplaceGlobalPath(const nStr: string): string;
var nPath: string;
begin
  nPath := gPath;
  if Copy(nPath, Length(nPath), 1) = '\' then
    System.Delete(nPath, Length(nPath), 1);
  Result := StringReplace(nStr, '$Path', nPath, [rfReplaceAll, rfIgnoreCase);
end;

end.


