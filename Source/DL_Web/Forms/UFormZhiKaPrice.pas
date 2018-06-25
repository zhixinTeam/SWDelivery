{*******************************************************************************
  ����: dmzn@163.com 2018-05-06
  ����: ֽ������
*******************************************************************************}
unit UFormZhiKaPrice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, uniGUITypes, UFormBase, uniCheckBox, uniGUIClasses, uniEdit,
  uniLabel, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormZKPrice = class(TfFormBase)
    Label1: TUniLabel;
    EditStock: TUniEdit;
    Label2: TUniLabel;
    EditPrice: TUniEdit;
    Label3: TUniLabel;
    EditNew: TUniEdit;
    Check1: TUniCheckBox;
    Check2: TUniCheckBox;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FZKList: TStrings;
    //ֽ���б�
    FMainZK,FMainStock: string;
    //��ֽ����,Ʒ��
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

  TFormZKPriceResult = procedure(const nRes: Integer) of object;
  //����ص�

procedure ShowZKPriceForm(const nData: string; nResult: TFormZKPriceResult);
//��ں���

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  System.IniFiles, UManagerGroup, ULibFun, USysBusiness, USysDB;

//Date: 2018-05-06
//Parm: �����۵ļ�¼;����ص�
//Desc: ��nDataָ���ļ�¼����
procedure ShowZKPriceForm(const nData: string; nResult: TFormZKPriceResult);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormZKPrice', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormZKPrice do
  begin
    nParam.FCommand := cCmd_EditData;
    nParam.FParamA := nData;
    SetParam(nParam);

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
          nResult(mrOk);
        //xxxxx
      end);
  end;
end;

procedure TfFormZKPrice.OnCreateForm(Sender: TObject);
var nIni: TIniFile;
begin
  FZKList := gMG.FObjectPool.Lock(TStrings) as TStrings;
  //init

  nIni := nil;
  try
    nIni := UserConfigFile;
    Check1.Checked := nIni.ReadBool(ClassName, 'AutoUnfreeze', True);
    Check2.Checked := nIni.ReadBool(ClassName, 'NewPriceType', False);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZKPrice.OnDestroyForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile;
    nIni.WriteBool(ClassName, 'AutoUnfreeze', Check1.Checked);
    nIni.WriteBool(ClassName, 'NewPriceType', Check2.Checked);
  finally
    nIni.Free;
  end;

  gMG.FObjectPool.Release(FZKList);
  //free
end;

function TfFormZKPrice.SetParam(const nParam: TFormCommandParam): Boolean;
var nIdx: Integer;
    nStock: string;
    nList: TStrings;
    nMin,nMax,nVal: Double;
begin
  Result := True;
  nList := nil;
  ActiveControl := EditNew;

  with TStringHelper do
  try
    FMainZK := '';
    FMainStock := '';

    nMin := MaxInt;
    nMax := 0;
    nStock := '';

    FZKList.Text := nParam.FParamA;
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;

    for nIdx:=FZKList.Count - 1 downto 0 do
    begin
      if not Split(FZKList[nIdx], nList, 5, ';') then Continue;
      //��ϸ��¼��;����;ֽ��;Ʒ������
      if not IsNumber(nList[1], True) then Continue;

      nVal := StrToFloat(nList[1]);
      if nVal < nMin then nMin := nVal;
      if nVal > nMax then nMax := nVal;

      if nStock = '' then nStock := nList[4];
      if FMainStock = '' then FMainStock := nList[3];

      if FMainZK = '' then FMainZK := nList[2] else
      if FMainZK <> nList[2] then FMainZK := sFlag_No;
    end;

    EditStock.Text := nStock;
    if nMin = nMax then
         EditPrice.Text := Format('%.2f Ԫ/��', [nMax])
    else EditPrice.Text := Format('%.2f - %.2f Ԫ/��', [nMin, nMax]);
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

procedure TfFormZKPrice.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  with TStringHelper do
  if not (IsNumber(EditNew.Text, True) and ((StrToFloat(EditNew.Text) > 0) or
     Check2.Checked)) then
  begin
    EditNew.SetFocus;
    ShowMessage('��������ȷ�ĵ���'); Exit;
  end;

  nStr := 'ע��: �ò��������Գ���,��������!' + #13#10#13#10 +
          '�۸������,�µ��ۻ�������Ч,Ҫ������?  ';
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    var nStr,nStatus: string;
        nVal: Double;
        nIdx: Integer;
        nListA,nListB: TStrings;
    begin
      if Res <> mrYes then Exit;
      //cancel

      nListA := nil;
      nListB := nil;
      with TStringHelper,TFloatHelper do
      try
        nListA := gMG.FObjectPool.Lock(TStrings) as TStrings;
        nListB := gMG.FObjectPool.Lock(TStrings) as TStrings; //init

        for nIdx:=FZKList.Count - 1 downto 0 do
        begin
          if not Split(FZKList[nIdx], nListA, 5, ';') then Continue;
          //��ϸ��¼��;����;ֽ��;Ʒ������

          nVal := StrToFloat(EditNew.Text);
          if Check2.Checked then
            nVal := StrToFloat(nListA[1]) + nVal;
          nVal := Float2Float(nVal, cPrecision, True);

          nStr := 'Update %s Set D_Price=%.2f,D_PPrice=%s ' +
                  'Where R_ID=%s And D_TPrice<>''%s''';
          nStr := Format(nStr, [sTable_ZhiKaDtl, nVal, nListA[1], nListA[0], sFlag_No]);
          nListB.Add(nStr);

          nStr := 'ˮ��Ʒ��[ %s ]���۵���[ %s -> %.2f ]';
          nStr := Format(nStr, [nListA[4], nListA[1], nVal]);
          nStr := WriteSysLog(sFlag_ZhiKaItem, nListA[2], nStr, FDBType, nil, False, False);
          nListB.Add(nStr);

          if not Check1.Checked then Continue;
          {$IFDEF NoShowPriceChange}
          nStatus := 'Null';
          {$ELSE}
          nStatus := '''' + sFlag_TJOver + '''';
          {$ENDIF}

          nStr := 'Update %s Set Z_TJStatus=%s Where Z_ID=''%s''';
          nStr := Format(nStr, [sTable_ZhiKa, nStatus, nListA[2]]);
          nListB.Add(nStr);
        end;

        DBExecute(nListB, nil, FDBType);
      finally
        gMG.FObjectPool.Release(nListA);
        gMG.FObjectPool.Release(nListB);
      end;

      ModalResult := mrOk;
      //well done
    end);
  //xxxxx
end;

initialization
  RegisterClass(TfFormZKPrice);
end.
