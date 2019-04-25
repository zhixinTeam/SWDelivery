{*******************************************************************************
  ����: dmzn@163.com 2018-05-20
  ����: ���۽���
*******************************************************************************}
unit UFormInvoiceSettle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, uniGUITypes,
  uniGUIForm, USysConst, UFormBase, uniMemo, uniGUIClasses, uniEdit, uniLabel,
  uniPanel, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, uniButton;

type
  TfFormInvoiceSettle = class(TfFormBase)
    UniLabel1: TUniLabel;
    EditWeek: TUniEdit;
    UniLabel2: TUniLabel;
    EditMemo: TUniMemo;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FNowYear,FNowWeek,FWeekName: string;
    //��ǰ����
    FWeekBegin,FWeekEnd: TDateTime;
    //��������
    procedure InitFormData;
    //��ʼ��
    procedure ShowHintText(const nText: string);
    //��ʾ����
  public
    { Public declarations }
  end;

procedure ShowInvoiceSettleForm(const nYear,nWeek,nWeekName: string;
  const nBegin,nEnd: TDateTime; const nResult: TFormModalResult);
//��ں���

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysDB;

//Date: 2018-05-20
//Parm: ��;����,����
//Desc: ��ʾ���۽��㴰��
procedure ShowInvoiceSettleForm(const nYear,nWeek,nWeekName: string;
  const nBegin,nEnd: TDateTime; const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormInvoiceSettle', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormInvoiceSettle do
  begin
    FNowYear := nYear;
    FNowWeek := nWeek;
    FWeekName := nWeekName;

    FWeekBegin := nBegin;
    FWeekEnd := nEnd;
    InitFormData; //init
    
    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(mrOk, @FParam);
        //xxxxx
      end);
    //xxxxx
  end;
end;

procedure TfFormInvoiceSettle.InitFormData;
begin
  if FNowWeek = '' then
       EditWeek.Text := '��ѡ���������'
  else EditWeek.Text := Format('%s ���:[ %s ', [FWeekName, FNowYear);
end;

procedure TfFormInvoiceSettle.ShowHintText(const nText: string);
begin
  EditMemo.Lines.Add(IntToStr(EditMemo.Lines.Count) + ' ::: ' + nText);
end;

//------------------------------------------------------------------------------
//Desc: ִ�н���
procedure TfFormInvoiceSettle.BtnOKClick(Sender: TObject);
var nStr,nSQL, nCusId, nStockId: string;
    nInit: Int64;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  nList := nil;
  nQuery := nil;
  nInit := GetTickCount;
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nQuery := LockDBQuery(FDBType);

    nStr := 'Select * From ' + sTable_InvoiceWeek + ' Where W_NO=''%s''';
    nStr := Format(nStr, [FNowWeek);
    with DBQuery(nStr, nQuery) do
      if RecordCount > 0 then
      begin
        nCusId  := FieldByName('W_CusId').AsString;
        nStockId:= FieldByName('W_StockId').AsString;
      end;

    nQuery.SQL.Clear;
    //***************************************************
    nStr := 'Select * From ' + sTable_InvSettle + ' Where S_Week=''%s''';
    nStr := Format(nStr, [FNowWeek);
    with DBQuery(nStr, nQuery) do
      if RecordCount > 0 then
      begin
        ShowMessage('�����������������㲻���ٴβ���'+#13+
                    '������Ҫ�����½�������->����->����');
        Exit;
      end;

    nQuery.SQL.Clear;
    //***************************************************

    EditMemo.Clear;                           {
    ShowHintText('��ʼ�ָ��ϴν�������...');

    nSQL := 'Select S_CusID, IsNull(Sum(S_Value*IsNull((S_Price+IsNull(S_YunFei, 0)), 0)*(-1)), 0) as S_Money From %s ' +
            'Where S_Week=''%s'' Group By S_CusID';
    nSQL := Format(nSQL, [sTable_InvSettle, FNowWeek);

    nStr := 'Update $T Set $T.A_Compensation=IsNull($T.A_Compensation, 0)-IsNull(t.S_Money, 0) ' +
            'From ($S) t Where $T.A_CID=t.S_CusID';
    //xxxxx

    with TStringHelper do
     nStr := MacroValue(nStr, [MI('$T', sTable_CusAccount), MI('$S', nSQL));
    nList.Add(nStr);

    nStr := 'Delete From %s Where S_Week=''%s''';
    nStr := Format(nStr, [sTable_InvSettle, FNowWeek);
    nList.Add(nStr);

    ShowHintText('�ָ��ϴν����������.');                    }
    //--------------------------------------------------------------------------
    ShowHintText('��ʼ�����½�������...');
    nStr := 'Insert Into $ST(S_Week,S_Bill,S_CusID,S_ZhiKa,S_Stock,S_StockName,S_Value,S_Price,S_OutFact,S_Man,' +
                            'S_Date,S_SalePrice,S_SaleYunFei, S_YunFei, S_Type) ' +

            'Select R_Week, R_LID, R_CusID, R_ZhiKa, R_Stock,R_StockName, R_Value, IsNull(R_KPrice, 0) R_KPrice, R_Date,''$SM'', '+
                            'R_Date, R_Price,R_YunFei,IsNull(R_KYunFei , 0) R_KYunFei,R_Type ' +
						'From $RQT Where R_Week=''$WK'' And R_Chk=1 ';

    with TStringHelper,TDateTimeHelper do
    nStr := MacroValue(nStr, [MI('$ST', sTable_InvSettle), MI('$WK', FNowWeek),
            MI('$SM', UniMainModule.FUserConfig.FUserID),
            MI('$SD', sField_SQLServer_Now), MI('$RQT', sTable_InvoiceReq),
            MI('$SS', DateTime2Str(FWeekBegin)), MI('$ED', DateTime2Str(FWeekEnd)));
    nList.Add(nStr);

    ShowHintText('�½��������������.');
    //--------------------------------------------------------------------------
    ShowHintText('��ʼ�ϲ������۸�...');            {
    nStr := 'Update $T Set $T.S_Price=IsNull($R.R_KPrice, 0), $T.S_YunFei=IsNull($R.R_KYunFei, 0) ' +
            ' From $R Where R_Week=''$WK'' And $T.S_Week=$R.R_Week ' +
            ' And $T.S_ZhiKa=$R.R_ZhiKa And $T.S_Stock=$R.R_Stock ' +
            ' And $T.S_SalePrice=$R.R_Price And $T.S_SaleYunFei=$R.R_YunFei';
    //xxxxx

    with TStringHelper do
    nStr := MacroValue(nStr, [MI('$T', sTable_InvSettle),
            MI('$R', sTable_InvoiceReq), MI('$WK', FNowWeek));
    nList.Add(nStr);              }

    nStr := 'Delete From %s Where S_Week=''%s'' And S_Price=0 And S_YunFei=0';
    nStr := Format(nStr, [sTable_InvSettle, FNowWeek);
    nList.Add(nStr);

    ShowHintText('�����۸�ϲ����.');
    //--------------------------------------------------------------------------
    ShowHintText('��ʼ���㷵��...');
    nSQL := 'Select S_CusID,Sum(ISNULL(S_Value, 0)*ISNULL((S_Price+IsNull(S_YunFei, 0)), 0)*(-1)) as S_Money From %s ' +
            'Where S_Week=''%s'' Group By S_CusID';
    nSQL := Format(nSQL, [sTable_InvSettle, FNowWeek);

    nStr := 'Update $T Set $T.A_Compensation=IsNull($T.A_Compensation, 0)+IsNull(t.S_Money, 0) ' +
            'From ($S) t Where $T.A_CID=t.S_CusID';
    //xxxxx

    with TStringHelper do
     nStr := MacroValue(nStr, [MI('$T', sTable_CusAccount), MI('$S', nSQL));
    nList.Add(nStr);

    ShowHintText('�����������.');
    //--------------------------------------------------------------------------
    ShowHintText('��ʼ�������ս��㱨��...');
    nSQL := 'Select S_Bill,S_ZhiKa,S_Stock,S_SalePrice,S_Value From %s ' +
            'Where S_Week=''%s'' ';
    nSQL := Format(nSQL, [sTable_InvSettle, FNowWeek);

    nStr := 'Update $T Set $T.R_KValue=t.S_Value,R_KMan=''$KM'',R_KDate=$DT ' +
            'From ($S) t Where $T.R_Week=''$WK'' And $T.R_LID=t.S_Bill ' ;
    //xxxxx

    with TStringHelper do
    nStr := MacroValue(nStr, [MI('$T', sTable_InvoiceReq), MI('$S', nSQL),
            MI('$WK', FNowWeek), MI('$KM', UniMainModule.FUserConfig.FUserID),
            MI('$DT', sField_SQLServer_Now));
    nList.Add(nStr);
    nList.Add(nStr);


    ShowHintText('�������.');
    //EditMemo.Text := nList.Text;
    //--------------------------------------------------------------------------
    DBExecute(nList, nQuery);
    ModalResult := mrOk;
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);

    nInit := GetTickCount - nInit;
    if nInit < 2000 then
      Sleep(2000 - nInit);
    //xxxxx
  end;
end;

initialization
  RegisterClass(TfFormInvoiceSettle);
end.
