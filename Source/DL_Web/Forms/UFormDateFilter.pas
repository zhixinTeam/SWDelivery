{*******************************************************************************
  ����: dmzn@163.com 2018-05-04
  ����: ����ɸѡ��
*******************************************************************************}
unit UFormDateFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIForm, UFormBase, uniLabel, uniGUIClasses,
  uniDateTimePicker, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormDateFilter = class(TfFormBase)
    EditStart: TUniDateTimePicker;
    Label1: TUniLabel;
    Label2: TUniLabel;
    EditEnd: TUniDateTimePicker;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TFormDateFilterResult = procedure (const nStart,nEnd: TDate) of object;
  //����ص�

function ShowDateFilterForm(const nStart,nEnd: TDate;
  const nResult: TFormDateFilterResult; nTime: Boolean = False): Boolean;
procedure InitDateRange(const nID: string; var nS,nE: TDate);
procedure SaveDateRange(const nID: string; const nS,nE: TDate);
//��ں���

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, System.IniFiles, ULibFun,
  USysBusiness;

//Date: 2018-05-04
//Parm: ��ʼ����;��������
//Desc: ��ʾʱ���ɸѡ����
function ShowDateFilterForm(const nStart,nEnd: TDate;
  const nResult: TFormDateFilterResult; nTime: Boolean): Boolean;
var nForm: TUniForm;
begin
  Result := False;
  nForm := SystemGetForm('TfFormDateFilter', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormDateFilter do
  begin
    EditStart.DateTime := nStart;
    EditEnd.DateTime := nEnd;

    if nTime then
    begin
      EditStart.Kind := tUniDateTime;
      EditEnd.Kind := tUniDateTime;
    end else
    begin
      EditStart.Kind := tUniDate;
      EditEnd.Kind := tUniDate;
    end;

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(EditStart.DateTime, EditEnd.DateTime);
        //xxxxx
      end);
    Result := True;
  end;
end;

//Date: 2018-05-04
//Parm: ��ʶ
//Desc: ����nID��ʶ����������
procedure InitDateRange(const nID: string; var nS,nE: TDate);
var nStr: string;
    nIni: TIniFile;
begin
  nIni := nil;
  with TDateTimeHelper do
  try
    nIni := UserConfigFile;
    nStr := nIni.ReadString(nID, 'DateRange_Last', '');
    if nStr = Date2Str(Now) then
    begin
      nStr := nIni.ReadString(nID, 'DateRange_S', Date2Str(Now));
      nS := Str2Date(nStr);

      nStr := nIni.ReadString(nID, 'DateRange_E', Date2Str(Now));
      nE := Str2Date(nStr);
    end else
    begin
      nS := Date(); nE := Date();
    end;
  finally
    nIni.Free;
  end;
end;

//Date: 2018-05-04
//Parm: ��ʶ
//Desc: �������������nID��ʶ��
procedure SaveDateRange(const nID: string; const nS,nE: TDate);
var nIni: TIniFile;
begin
  nIni := nil;
  with TDateTimeHelper do
  try
    nIni := UserConfigFile;
    nIni.WriteString(nID, 'DateRange_S', Date2Str(nS));
    nIni.WriteString(nID, 'DateRange_E', Date2Str(nE));
    nIni.WriteString(nID, 'DateRange_Last', Date2Str(Now));
  finally
    nIni.Free;
  end;
end;

procedure TfFormDateFilter.BtnOKClick(Sender: TObject);
begin
  if EditEnd.DateTime < EditStart.DateTime then
  begin
    EditEnd.SetFocus;
    ShowMessage('�������ڲ���С�ڿ�ʼ����');
  end else ModalResult := mrOK;
end;

initialization
  RegisterClass(TfFormDateFilter);
end.
