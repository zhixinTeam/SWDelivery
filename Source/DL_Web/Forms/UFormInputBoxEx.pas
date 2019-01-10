{*******************************************************************************
  ����: dmzn@163.com 2018-05-04
  ����: ����ɸѡ��
*******************************************************************************}
unit UFormInputBoxEx;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIForm, UFormBase, uniLabel, uniGUIClasses,
  uniDateTimePicker, uniPanel, uniGUIBaseClasses, uniButton, uniEdit;

type
  TfFormInputBoxEx = class(TfFormBase)
    Label1: TUniLabel;
    undt1: TUniEdit;
  private
    { Private declarations }
    procedure SetHint(const nStr: string);
  public
    { Public declarations }
  end;

  TFormDateResult = procedure (const nValue: string) of object;
  //����ص�

function ShowInputBoxForm(const nHint,nTitle: string; const nResult: TFormDateResult;
  const nSize: Word = 0): Boolean;
//��ں���

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, System.IniFiles, ULibFun,
  USysBusiness;

//Date: 2018-05-04
//Parm: ��ʼ����;��������
//Desc: ��ʾʱ���ɸѡ����
function ShowInputBoxForm(const nHint,nTitle: string; const nResult: TFormDateResult;
  const nSize: Word = 0): Boolean;
var nForm: TUniForm;
begin
  Result := False;
  nForm := SystemGetForm('TfFormInputBoxEx', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormInputBoxEx do
  begin
    Caption := nTitle;
    SetHint(nHint);
    undt1.Text := '';
    undt1.MaxLength := nSize;

    //Result := ShowModal = mrOK;
    //if Result then nValue := undt1.Text;
    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(undt1.Text);
        //xxxxx
      end);
    Result := True;
  end;
end;

//Desc: ������ʾ��Ϣ
procedure TfFormInputBoxEx.SetHint(const nStr: string);
var nNum: integer;
begin
  undt1.Caption := nStr;
end;

initialization
  RegisterClass(TfFormInputBoxEx);



end.
