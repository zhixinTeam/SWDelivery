{*******************************************************************************
  ����: dmzn@163.com 2018-05-08
  ����: ��Ƭ������

  ��ע:
  *.��ֽ����������,���ֽ�����ֻ�������ô�������Ļ�.
*******************************************************************************}
unit UFormZhiKaFixMoney;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, Data.Win.ADODB, UFormBase, uniCheckBox, uniGUIClasses, uniEdit,
  uniLabel, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormZhiKaFixMoney = class(TfFormBase)
    Label2: TUniLabel;
    Label1: TUniLabel;
    Panel1: TUniSimplePanel;
    Label3: TUniLabel;
    EditIn: TUniEdit;
    EditOut: TUniEdit;
    Label4: TUniLabel;
    Label5: TUniLabel;
    Label6: TUniLabel;
    Panel2: TUniSimplePanel;
    EditZK: TUniEdit;
    EditName: TUniEdit;
    Label10: TUniLabel;
    EditCustomer: TUniEdit;
    Label7: TUniLabel;
    EditFreeze: TUniEdit;
    EditValid: TUniEdit;
    Label8: TUniLabel;
    Label9: TUniLabel;
    Label11: TUniLabel;
    Label12: TUniLabel;
    EditMoney: TUniEdit;
    Check1: TUniCheckBox;
    Label13: TUniLabel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadZhiKaData(const nZhiKa: string);
    //��������
  public
    { Public declarations }
  end;

procedure ShowZKFixMoneyForm(const nZhiKa: string; nResult: TFormModalResult);
//��ں���

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, uniGUIForm, UManagerGroup,
  ULibFun, USysBusiness, USysRemote, USysDB;

procedure ShowZKFixMoneyForm(const nZhiKa: string; nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormZhiKaFixMoney', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormZhiKaFixMoney do
  begin
    ActiveControl := EditMoney;
    BtnOK.Enabled := False;
    LoadZhiKaData(nZhiKa);

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        nResult(Result, @FParam);
      end);
  end;
end;

procedure TfFormZhiKaFixMoney.LoadZhiKaData(const nZhiKa: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  with TStringHelper do
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select Z_Name,Z_Customer,Z_FixedMoney,Z_OnlyMoney,' +
            'C_Name From %s ' +
            ' Left Join %s on C_ID=Z_Customer ' +
            'Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, nZhiKa);

    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount < 1 then
      begin
        nStr := Format('ֽ��[ %s �Ѷ�ʧ.', [nZhiKa);
        ShowMessage(nStr);
        Exit;
      end;

      EditZK.Text := nZhiKa;
      FParam.FParamA := nZhiKa;
      EditName.Text := FieldByName('Z_Name').AsString;

      FParam.FParamB := FieldByName('Z_Customer').AsString;
      EditCustomer.Text := FieldByName('C_Name').AsString;

      FParam.FParamC := FieldByName('Z_FixedMoney').AsFloat;
      EditMoney.Text := Format('%.2f', [FieldByName('Z_FixedMoney').AsFloat);
      Check1.Checked := FieldByName('Z_OnlyMoney').AsString = sFlag_Yes;
    end;

    nStr := 'Select * From %s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, FParam.FParamB);

    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '�ͻ�[ %s,%s �˻���Ϣ��ʧ.';
        nStr := Format(nStr, [FParam.FParamB, EditCustomer.Text);
        ShowMessage(nStr); Exit;
      end;

      BtnOK.Enabled := True;
      EditIn.Text := Format('%.2f', [FieldByName('A_InMoney').AsFloat);
      EditOut.Text := Format('%.2f', [FieldByName('A_OutMoney').AsFloat);
      EditFreeze.Text := Format('%.2f', [FieldByName('A_FreezeMoney').AsFloat);

      EditValid.Text := Format('%.2f', [GetCustomerValidMoney(FParam.FParamB));
      //xxxxx
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormZhiKaFixMoney.BtnOKClick(Sender: TObject);
var nStr: string;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  with TStringHelper do
  if (not IsNumber(EditMoney.Text, True)) or
     (StrToFloat(EditMoney.Text) < 0) then
  begin
    ShowMessage('��������ȷ�Ľ��');
    Exit;
  end;

  nList := nil;
  nQuery := nil;
  with TStringHelper do
  try
    nQuery := LockDBQuery(FDBType);
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;

    nStr := 'Update %s Set Z_FixedMoney=$My,Z_OnlyMoney=$F ' +
            'Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, FParam.FParamA);

    if Check1.Checked then
    begin
      nStr := MacroValue(nStr, [MI('$My', EditMoney.Text));
      nStr := MacroValue(nStr, [MI('$F', '''' + sFlag_Yes + ''''));
    end else nStr := MacroValue(nStr, [MI('$My', 'Null'), MI('$F', 'Null'));

    nList.Add(nStr);
    //update sql

    if Check1.Checked then
    begin
      nStr := 'ֽ��[ %s ������[ %.2f -> %.2f ';
      nStr := Format(nStr, [FParam.FParamA, StrToFloat(FParam.FParamC),
                            StrToFloat(EditMoney.Text));
    end else nStr := Format('ȡ������ֽ��[ %s �Ŀ�������', [FParam.FParamA);

    nStr := WriteSysLog(sFlag_ZhiKaItem, FParam.FParamA, nStr,
            FDBType, nQuery, False, False);
    nList.Add(nStr);

    DBExecute(nList, nQuery);
    ModalResult := mrOk;
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormZhiKaFixMoney);
end.
