{*******************************************************************************
  作者: dmzn@163.com 2018-05-16
  描述: 结算周期
*******************************************************************************}
unit UFormInvoiceWeek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, USysConst,
  UFormBase, uniMemo, uniEdit, uniLabel, uniGUIClasses, uniDateTimePicker,
  uniPanel, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, uniButton;

type
  TfFormInvoiceWeek = class(TfFormBase)
    EditStart: TUniDateTimePicker;
    Label1: TUniLabel;
    Label2: TUniLabel;
    EditEnd: TUniDateTimePicker;
    UniLabel1: TUniLabel;
    EditName: TUniEdit;
    UniLabel2: TUniLabel;
    EditMemo: TUniMemo;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysDB, USysBusiness, USysRemote;

function TfFormInvoiceWeek.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  ActiveControl := EditName;
  Result := inherited SetParam(nParam);

  case nParam.FCommand of
   cCmd_AddData:
    begin
      FParam.FParamA := '';
      InitFormData('');
    end;
   cCmd_EditData:
    begin
      BtnOK.Enabled := False;
      InitFormData(FParam.FParamA);
    end;
  end;
end;

procedure TfFormInvoiceWeek.InitFormData(const nID: string);
var nStr: string;
    nY,nM,nD: Word;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    if nID = '' then
    begin
      nStr := 'Select Top 1 W_End From %s Order By W_End DESC';
      nStr := Format(nStr, [sTable_InvoiceWeek]);

      with DBQuery(nStr, nQuery) do
      if RecordCount > 0 then
      begin
        EditStart.DateTime := Fields[0].AsDateTime + 1;
      end else
      begin
        DecodeDate(Now, nY, nM, nD);
        EditStart.DateTime := EncodeDate(nY, nM, 1);
      end;

      DecodeDate(EditStart.DateTime, nY, nM, nD);
      Inc(nM);

      if nM > 12 then
      begin
        nM := 1; Inc(nY);
      end;
      EditEnd.DateTime := EncodeDate(nY, nM, 1) - 1;
    end else
    begin
      nStr := 'Select * From %s Where W_ID=%s';
      nStr := Format(nStr, [sTable_InvoiceWeek, nID]);

      with DBQuery(nStr, nQuery) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '记录号为[ %s ]的记录已无效.';
          ShowMessage(Format(nStr, [nID]));
          Exit;
        end;

        BtnOK.Enabled := True;
        First;

        EditName.Text      := FieldByName('W_Name').AsString;
        EditStart.DateTime := FieldByName('W_Begin').AsDateTime;
        EditEnd.DateTime   := FieldByName('W_End').AsDateTime;
        EditMemo.Text      := FieldByName('W_Memo').AsString;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

function TfFormInvoiceWeek.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nStr,nTmp: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  Result := True;

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    Result := EditName.Text <> '';
    nHint := '请填写有效的名称';
  end else

  if Sender = EditStart then
  with TStringHelper,TDateTimeHelper do
  try
    Result := EditStart.DateTime <= EditEnd.DateTime;
    nHint := '结束日期应大于开始日期';
    if not Result then Exit;

    nStr := 'Select * From $W Where ((W_Begin<=''$S'' and W_End>=''$S'') or ' +
            '(W_Begin>=''$S'' and W_End<=''$E'') or (W_Begin<=''$E'' and ' +
            'W_End>=''$E'') or (W_Begin<=''$S'' and W_End>=''$E''))';
    //xxxxx

    nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
            MI('$S', Date2Str(EditStart.DateTime)),
            MI('$E', Date2Str(EditEnd.DateTime))]);
    //xxxxx

    if FParam.FParamA <> '' then
      nStr := nStr + Format(' And W_ID<>%s', [FParam.FParamA]);
    //xxxxx

    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      nStr := '';
      First;

      while not Eof  do
      begin
        nTmp := '开始:%s 结束:%s 名称: %s' + #32#32#13#10;
        nTmp := Format(nTmp, [Date2Str(FieldByName('W_Begin').AsDateTime),
                Date2Str(FieldByName('W_End').AsDateTime),
                FieldByName('W_Name').AsString]);
        //xxxxx

        nStr := nStr + nTmp;
        Next;
      end;

      nHint := '';
      Result := False;

      nStr := '本周期与以下周期时间上有交叉,会影响提货量的统计.' +
              #13#10#13#10 + AdjustHintToRead(nStr) + #13#10 +
              '请修改"开始、结束"日期后再保存.';
      ShowMessage(nStr);
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceWeek.BtnOKClick(Sender: TObject);
var nStr,nID: string;
    nBool: Boolean;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  if not IsDataValid then Exit;
  nList := nil;
  nQuery := nil;

  with TSQLBuilder,TStringHelper,TDateTimeHelper do
  try
    nBool := FParam.FCommand <> cCmd_EditData;
    if nBool then
    begin
      nID := GetSerialNo(sFlag_BusGroup, sFlag_InvWeek, False);
      if nID = '' then Exit;
    end else nID := FParam.FParamB;
    //new id

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nStr := SF('W_ID', FParam.FParamA, sfVal);

    nStr := MakeSQLByStr([
      SF_IF([SF('W_NO', nID), ''], nBool),
      SF('W_Name', EditName.Text),
      SF('W_Begin', Date2Str(EditStart.DateTime)),
      SF('W_End', Date2Str(EditEnd.DateTime)),
      SF('W_Memo', EditMemo.Text),

      SF('W_Man', UniMainModule.FUserConfig.FUserID),
      SF('W_Date', sField_SQLServer_Now, sfVal)
      ], sTable_InvoiceWeek, nStr, nBool);
    nList.Add(nStr);

    DBExecute(nList, nil, FDBType);
    ModalResult := mrOk;
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormInvoiceWeek);
end.
