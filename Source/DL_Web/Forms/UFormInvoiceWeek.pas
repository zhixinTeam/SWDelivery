{*******************************************************************************
  作者: dmzn@163.com 2018-05-16
  描述: 结算周期
*******************************************************************************}
unit UFormInvoiceWeek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, USysConst, ULibFun,
  UFormBase, uniMemo, uniEdit, uniLabel, uniGUIClasses, uniDateTimePicker, System.DateUtils,
  uniPanel, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, uniButton, uniMultiItem,
  uniComboBox, uniCheckBox;

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
    cbb_Stock: TUniComboBox;
    UnLbl1: TUniLabel;
    cbb_EditCus: TUniComboBox;
    UnLbl2: TUniLabel;
    cbb_EditSaleMan: TUniComboBox;
    UnLbl3: TUniLabel;
    Chk_1: TUniCheckBox;
    procedure BtnOKClick(Sender: TObject);
    procedure cbb_EditSaleManChange(Sender: TObject);
    procedure Chk_1Click(Sender: TObject);
    procedure EditEndExit(Sender: TObject);
  private
    { Private declarations }
    FStockList: TStringHelper.TDictionaryItems;
    //品种列表
  private
    procedure InitFormData(const nID: string);
    //载入数据
    procedure LoadStockList;
    function  GetStockName: string;
    function  GetStockId: string;
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
   USysDB, USysBusiness, USysRemote;


function TfFormInvoiceWeek.SetParam(const nParam: TFormCommandParam): Boolean;
var nStr: string;
    nQuery: TADOQuery;
begin
  ActiveControl := EditName;
  Result := inherited SetParam(nParam);
  LoadSaleMan(cbb_EditSaleMan.Items);
  LoadStockList;

  nQuery := nil;
  with TStringHelper do
  try
    nQuery := LockDBQuery(FDBType);
    nStr := 'Select C_ID,C_Name,C_SaleMan From %s Where C_ID=''%s''';
    nStr := Format(nStr, [sTable_Customer, nParam.FParamA);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      nStr := FieldByName('C_SaleMan').AsString;
      Cbb_EditSaleMan.ItemIndex := StrListIndex(nStr, Cbb_EditSaleMan.Items, 0, '.');

      nStr := FieldByName('C_ID').AsString + '.' +
              FieldByName('C_Name').AsString;
      //xxxxxx

      if Cbb_EditCus.Items.IndexOf(nStr) < 0 then
        Cbb_EditCus.Items.Add(nStr);
      Cbb_EditCus.Text := nStr;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;

  //***********************************************************
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

//Desc: 读取品种列表
procedure TfFormInvoiceWeek.LoadStockList;
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    with cbb_Stock.Items do
    begin
      BeginUpdate;
      Clear;
      Add('全部品种');
    end;

    SetLength(FStockList, 0);
    nQuery := LockDBQuery(FDBType);

    nStr := 'Select D_Value,D_Memo,D_ParamB From %s ' +
            'Where D_Name=''%s'' Order By D_Index ASC';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(FStockList, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with FStockList[nIdx do
        begin
          FKey   := FieldByName('D_ParamB').AsString;
          FValue := FieldByName('D_Value').AsString;
          FParam := FieldByName('D_Memo').AsString;
        end;

        Inc(nIdx);
        Next;
      end;
    end;

    for nIdx := Low(FStockList) to High(FStockList) do
      cbb_Stock.Items.AddObject(FStockList[nIdx.FValue, Pointer(nIdx));
    cbb_Stock.ItemIndex := 0;
  finally
    cbb_Stock.Items.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceWeek.cbb_EditSaleManChange(Sender: TObject);
var nStr: string;
begin
  nStr := GetIDFromBox(cbb_EditSaleMan);
  if nStr = '' then
  begin
    cbb_EditCus.Items.Clear;
    Exit;
  end;

  nStr := Format('C_SaleMan=''%s''', [nStr);
  LoadCustomer(cbb_EditCus.Items, nStr);
end;

procedure TfFormInvoiceWeek.Chk_1Click(Sender: TObject);
begin
  if Chk_1.Checked then
  begin
    cbb_EditSaleMan.Enabled:= True;
    cbb_EditCus.Enabled:= True;
  end
  else
  begin
    cbb_EditSaleMan.Enabled:= False;
    cbb_EditCus.Enabled:= False;
  end;
end;

procedure TfFormInvoiceWeek.EditEndExit(Sender: TObject);
begin
  EditName.Text:= FormatDateTime('yy年M月d日-', EditStart.DateTime)+FormatDateTime('M月d日', EditEnd.DateTime);
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
      nStr := Format(nStr, [sTable_InvoiceWeek);

      with DBQuery(nStr, nQuery) do
      if RecordCount > 0 then
      begin
        DecodeDate(Fields[0.AsDateTime, nY, nM, nD);
        EditStart.DateTime := EncodeDate(nY, nM, nD) + 1;
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
      EditEnd.DateTime := IncMilliSecond(EncodeDate(nY, nM, 1), - 1);
    end else
    begin
      nStr := 'Select * From %s Where W_ID=%s';
      nStr := Format(nStr, [sTable_InvoiceWeek, nID);

      with DBQuery(nStr, nQuery) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '记录号为[ %s 的记录已无效.';
          ShowMessage(Format(nStr, [nID));
          Exit;
        end;

        BtnOK.Enabled := True;
        First;

        EditName.Text      := FieldByName('W_Name').AsString;
        EditStart.DateTime := FieldByName('W_Begin').AsDateTime;
        EditEnd.DateTime   := FieldByName('W_End').AsDateTime;
        EditMemo.Text      := FieldByName('W_Memo').AsString;

        Chk_1.Checked:= FieldByName('W_CusName').AsString<>'';
        if Chk_1.Checked then
        begin
          cbb_EditCus.Enabled:= True;
          cbb_EditSaleMan.Enabled:= True;
        end;

        nStr:= FieldByName('W_SaleManId').AsString;
        Cbb_EditSaleMan.ItemIndex := TStringHelper.StrListIndex(nStr, Cbb_EditSaleMan.Items, 0, '.');

        cbb_EditSaleManChange(Self);
        nStr:= FieldByName('W_CusId').AsString;
        with TStringHelper do
          cbb_EditCus.ItemIndex := StrListIndex(nStr, cbb_EditCus.Items, 0, '.');

        nStr:= FieldByName('W_StockName').AsString;
        if nStr='' then
          cbb_Stock.ItemIndex := 0
        else
        begin
          with TStringHelper do
            cbb_Stock.ItemIndex := StrListIndex(nStr, cbb_Stock.Items, 0, '~');
        end;
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
    nHint := '请填写周期标示名称';
  end

  else if Sender = Chk_1 then
  begin
    if Chk_1.Checked then
    begin
      Result := (cbb_EditSaleMan.Text<>'')And(cbb_EditCus.Text<>'');
      nHint := '请选择返利的客户';
    end;
  end;

//  else if Sender = EditStart then
//  with TStringHelper,TDateTimeHelper do
//  try
//    Result := EditStart.DateTime <= EditEnd.DateTime;
//    nHint := '结束日期应大于开始日期';
//    if not Result then Exit;
//
//    nStr := 'Select * From $W Where ((W_Begin<=''$S'' and W_End>=''$S'') or ' +
//            '(W_Begin>=''$S'' and W_End<=''$E'') or (W_Begin<=''$E'' and ' +
//            'W_End>=''$E'') or (W_Begin<=''$S'' and W_End>=''$E''))';
//    //xxxxx
//
//    nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
//            MI('$S', Date2Str(EditStart.DateTime)),
//            MI('$E', Date2Str(EditEnd.DateTime)));
//    //xxxxx
//
//    if FParam.FParamA <> '' then
//      nStr := nStr + Format(' And W_ID<>%s', [FParam.FParamA);
//    //xxxxx
//
//    nQuery := LockDBQuery(FDBType);
//    with DBQuery(nStr, nQuery) do
//    if RecordCount > 0 then
//    begin
//      nStr := '';
//      First;
//
//      while not Eof  do
//      begin
//        nTmp := '开始:%s 结束:%s 名称: %s' + #32#32#13#10;
//        nTmp := Format(nTmp, [Date2Str(FieldByName('W_Begin').AsDateTime),
//                Date2Str(FieldByName('W_End').AsDateTime),
//                FieldByName('W_Name').AsString);
//        //xxxxx
//
//        nStr := nStr + nTmp;
//        Next;
//      end;
//
//      nHint := '';
//      Result := False;
//
//      nStr := '本周期与以下周期时间上有交叉,会影响提货量的统计.' +
//              #13#10#13#10 + AdjustHintToRead(nStr) + #13#10 +
//              '请修改"开始、结束"日期后再保存.';
//      ShowMessage(nStr);
//    end;
//  finally
//    ReleaseDBQuery(nQuery);
//  end;
end;

//Desc: 获取选中的品种
function TfFormInvoiceWeek.GetStockName: string;
var nIdx: Integer;
begin
  Result := '';
  if cbb_Stock.ItemIndex < 1 then Exit;

  nIdx := NativeInt(cbb_Stock.Items.Objects[cbb_Stock.ItemIndex);
  Result := FStockList[nIdx.FValue;
end;

function TfFormInvoiceWeek.GetStockId: string;
var nIdx: Integer;
begin
  Result := '';
  if cbb_Stock.ItemIndex < 1 then Exit;

  nIdx := NativeInt(cbb_Stock.Items.Objects[cbb_Stock.ItemIndex);
  Result := FStockList[nIdx.FKey;
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
      SF_IF([SF('W_NO', nID), '', nBool),
      SF('W_Name', EditName.Text),
      SF('W_Begin', DateTime2Str(EditStart.DateTime)),
      SF('W_End', DateTime2Str(EditEnd.DateTime)),
      SF('W_Memo', EditMemo.Text),

      SF('W_CusId', GetLeftStr('.', cbb_EditCus.Text)),
      SF('W_CusName', GetRightStr('.', cbb_EditCus.Text)),
      SF('W_SaleManId', GetLeftStr('.', cbb_EditSaleMan.Text)),
      SF('W_SaleMan', GetRightStr('.', cbb_EditSaleMan.Text)),
      SF('W_StockId', GetStockId),
      SF('W_StockName', GetStockName),

      SF('W_Man', UniMainModule.FUserConfig.FUserID),
      SF('W_Date', sField_SQLServer_Now, sfVal)
      , sTable_InvoiceWeek, nStr, nBool);
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
