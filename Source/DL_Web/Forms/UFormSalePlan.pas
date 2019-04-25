unit UFormSalePlan;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFormBase, uniCheckBox, uniEdit, ULibFun, USysConst,
  uniLabel, uniGUIClasses, uniMultiItem, uniComboBox, uniPanel, uniPageControl,
  uniGUIBaseClasses, uniButton;

type
  TfFormSalePlan = class(TfFormBase)
    cbb_Stock: TUniComboBox;
    UnLbl1: TUniLabel;
    unEdt_Num: TUniEdit;
    UnLbl2: TUniLabel;
    Chk_1: TUniCheckBox;
    cbb_SaleMan: TUniComboBox;
    UnLbl3: TUniLabel;
    unEdt_CusNum: TUniEdit;
    UnLbl4: TUniLabel;
    cbb_Customer: TUniComboBox;
    UnLbl5: TUniLabel;
    procedure cbb_SaleManChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure cbb_StockChange(Sender: TObject);
  private
    { Private declarations }
    FnParam : TFormCommandParam;
    FStockList: TStringHelper.TDictionaryItems;
    //品种列表
    FIsStockLoaded : Boolean;
  private
    procedure LoadStockList;
    procedure InitFormData(const nID: string);
    //载入数据
    procedure SaveStockSet(IsNew: Boolean);
    procedure SaveCusStockSet(IsNew: Boolean);
    procedure LoadStockMaxValue;
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;


implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
   USysBusiness, USysRemote, USysDB;


function TfFormSalePlan.SetParam(const nParam: TFormCommandParam): Boolean;
var nStr : string;
begin
  ActiveControl := unEdt_Num;    FnParam:= nParam;    FIsStockLoaded:= FALSE;
  Result := inherited SetParam(nParam);
  LoadSaleMan(cbb_SaleMan.Items);
  LoadStockList;


  case nParam.FCommand of

   cCmd_AddData:
    begin
      FParam.FParamA := '';

      Caption := '销售计划设置 - 添加';
      if nParam.FParamA='Stock' then
      begin
        cbb_Stock.Enabled:= True;
        unEdt_Num.Enabled:= True;
        chk_1.Enabled:= True;
      end
      else if nParam.FParamA='Customer' then
      begin
        cbb_Stock.Enabled:= True;
        cbb_SaleMan.Enabled:= True;
        cbb_Customer.Enabled:= True;
        unEdt_CusNum.Enabled:= True;
      end;

      InitFormData('');
    end;

   cCmd_EditData:
    begin
      Caption := '销售供应计划 - 修改';
      if nParam.FParamA='Stock' then
      begin
        cbb_Stock.Enabled:= True;
        unEdt_Num.Enabled:= True;
        chk_1.Enabled:= True;
                                           FIsStockLoaded:= true;
        cbb_Stock.ItemIndex:= TStringHelper.StrListIndex(nParam.FParamC, cbb_Stock.Items, 0, '!');
        unEdt_Num.Text:= nParam.FParamD;
        chk_1.Checked:= nParam.FParamE=sFlag_Yes;
      end
      else if nParam.FParamA='Customer' then
      begin
        cbb_Stock.Enabled:= True;
        cbb_SaleMan.Enabled:= True;
        cbb_Customer.Enabled:= True;
        unEdt_CusNum.Enabled:= True;

        cbb_Stock.ItemIndex:= TStringHelper.StrListIndex(nParam.FParamC, cbb_Stock.Items, 0, '!');
        nStr:= GetLeftStr('@', nParam.FParamD);
        cbb_SaleMan.ItemIndex:= TStringHelper.StrListIndex(nStr, cbb_SaleMan.Items, 1, '.');
        nStr:= GetRightStr('@', nParam.FParamD);
        cbb_Customer.ItemIndex:= TStringHelper.StrListIndex(nStr, cbb_Customer.Items, 0, '.');
        unEdt_CusNum.Text:= nParam.FParamE;
      end;

      InitFormData(FParam.FParamA);
    end;
  end;
end;

//Desc: 读取品种列表
procedure TfFormSalePlan.LoadStockList;
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
      //Add('全部品种');
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

procedure TfFormSalePlan.BtnOKClick(Sender: TObject);
begin
  if StrToFloatDef(Trim(unEdt_CusNum.Text), 0)>StrToFloatDef(Trim(unEdt_Num.Text), 0) then
  begin
    ShowMessage('当前品种客户供应上限不能大于总供应量');
    Exit;
  end;

  if (FnParam.FParamA='Stock') then
  begin
    SaveStockSet(FnParam.FCommand=cCmd_AddData);
  end
  else
  begin
    SaveCusStockSet(FnParam.FCommand=cCmd_AddData);
  end;

end;

procedure TfFormSalePlan.cbb_SaleManChange(Sender: TObject);
var nStr: string;
begin
  nStr := GetIDFromBox(cbb_SaleMan);
  if nStr = '' then
  begin
    cbb_Customer.Items.Clear;
    Exit;
  end;

  nStr := Format('C_SaleMan=''%s''', [nStr);
  LoadCustomer(cbb_Customer.Items, nStr);
end;

procedure TfFormSalePlan.LoadStockMaxValue;
var nStr: string;
    nIdx: integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  unEdt_Num.Text:= '0';
  if (FnParam.FParamA<>'Stock') then
  begin
    nIdx := cbb_Stock.ItemIndex;
    //----------------------
    nStr := ' Select * From X_SalePlanStock Where S_StockName=''' + FStockList[nIdx.FValue + '''';
    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount >0 then
      begin
        unEdt_Num.Text := FieldByName('S_Value').AsString;
      end
      else
      begin
        if FIsStockLoaded then
          ShowMessage('该品种当前尚未设置供应限量、请设置后再操作');
      end
    end;
  end;
end;

procedure TfFormSalePlan.cbb_StockChange(Sender: TObject);
begin
  LoadStockMaxValue;
end;

procedure TfFormSalePlan.InitFormData(const nID: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
//    nQuery := LockDBQuery(FDBType);
//    with DBQuery(nStrSql, nQuery) do


  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormSalePlan.SaveStockSet(IsNew: boolean);
var nStrSql, nPrCBill : string;
    nQuery: TADOQuery;
begin
  nQuery := nil;   ModalResult := mrOk;
  try
    if chk_1.Checked then nPrCBill:= 'Y'
    else nPrCBill:= 'N';

    with TStringHelper do
    begin
      if IsNew then
      begin
        if (cbb_Stock.ItemIndex >= 0) then
        begin
            //*******************************
            if (StrToIntDef(Trim(unEdt_Num.Text), 0) >= 0) then
            begin
                nStrSql := ' Select * From X_SalePlanStock Where S_StockName='''+FStockList[cbb_Stock.ItemIndex.FValue+'''';
                nQuery := LockDBQuery(FDBType);
                with DBQuery(nStrSql, nQuery) do
                begin
                  if RecordCount > 0 then
                  begin
                    ShowMessage('该品种当前已设置供应限量、请勿重复操作');
                    Exit;
                  end
                end;


                nStrSql := 'Insert Into $SalePlanStk (S_StockNo, S_StockName, S_Value, S_ProhibitCreateBill)' +
                          ' Select ''$StockNo'', ''$StockName'', $Value, ''$PrCBill''';
                nStrSql := MacroValue(nStrSql, [MI('$SalePlanStk', sTable_SalePlanStock), MI('$StockNo', FStockList[cbb_Stock.ItemIndex .FKey),
                                                MI('$StockName', FStockList[cbb_Stock.ItemIndex .FValue), MI('$Value', Trim(unEdt_Num.Text)),
                                                MI('$PrCBill', Trim(nPrCBill)));
              DBExecute(nStrSql);
            end
            else ShowMessage('请输入选中品种限量吨数！');
        end
        else ShowMessage('请选择限量品种');
      end
      else
      begin
        if (cbb_Stock.ItemIndex >= 0) then
        begin
          if (StrToIntDef(Trim(unEdt_Num.Text), 0) >= 0) then
          begin
              nStrSql := 'UPDate $SalePlan Set S_StockNo=''$StockNo'' ,S_StockName=''$StockName'', S_Value=''$Value'',S_ProhibitCreateBill=''$PrCBill'' '+
                                ' Where R_Id=$Rid ';
              nStrSql := MacroValue(nStrSql, [MI('$SalePlan', sTable_SalePlanStock), MI('$StockNo', FStockList[cbb_Stock.ItemIndex .FKey),
                                              MI('$StockName', FStockList[cbb_Stock.ItemIndex .fValue), MI('$Value', Trim(unEdt_Num.Text)),
                                              MI('$PrCBill', Trim(nPrCBill)),
                                              MI('$Rid', FnParam.FParamB));
              DBExecute(nStrSql);
          end
          else ShowMessage('请输入选中品种限量吨数！');
        end
        else ShowMessage('请选择限量品种');
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormSalePlan.SaveCusStockSet(IsNew: boolean);
var nStrSql : string;
    nIdx : Integer;
    nStockMaxValue : double;
    nQuery: TADOQuery;
begin
  nQuery := nil;    ModalResult := mrOk;
  try
    with TStringHelper do
    begin
      if IsNew then
      begin
        if (cbb_Stock.ItemIndex >= 0) then
        begin
            if (StrToIntDef(Trim(unEdt_CusNum.Text), 0) >= 0) then
            begin
                nIdx:= cbb_Stock.ItemIndex;
                //----------------------
                nStrSql := ' Select * From X_SalePlanStock Where S_StockName='''+FStockList[nIdx.FValue+'''';
                nQuery := LockDBQuery(FDBType);
                with DBQuery(nStrSql, nQuery) do
                begin
                  if RecordCount < 1 then
                  begin
                    ShowMessage('该品种当前尚未设置供应限量、请设置后再操作');
                    close;
                    Exit;
                  end
                  else nStockMaxValue:= FieldByName('S_Value').AsFloat;
                end;

                //----------------------
                nStrSql := ' Select * From X_SalePlanCustomer Where C_StockName='''+FStockList[nIdx.FValue+
                                    ''' And C_CusNo='''+GetLeftStr('.', FStockList[nIdx.FKey)+''' ';
                nQuery:= nil;
                nQuery := LockDBQuery(FDBType);
                with DBQuery(nStrSql, nQuery) do
                begin
                  if RecordCount > 0 then
                  begin
                    ShowMessage('当前客户已设置该品种供应量、请勿重复操作');
                    Exit;
                  end;
                end;
                //----------------------
                nIdx:= cbb_Stock.ItemIndex;
                nStrSql := 'Insert Into %s (C_StockNo,C_StockName,C_SManNo,C_SManName,C_CusNo,C_CusName,C_MaxValue)' +
                          ' Select ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %s ';
                nStrSql := Format(nStrSql, [sTable_SalePlanCustomer, FStockList[nIdx.FKey, FStockList[nIdx.FValue,
                                              cbb_SaleMan.Text,
                                              GetRightStr('.', cbb_SaleMan.Text), GetLeftStr('.', cbb_Customer.Text),
                                              GetRightStr('.', cbb_Customer.Text), Trim(unEdt_CusNum.Text), FnParam.FParamB);
                DBExecute(nStrSql, nil, FDBType);
            end
            else ShowMessage('请输入选中品种限量吨数！');
        end
        else ShowMessage('请选择限量品种');
      end
      else
      begin
        if (cbb_Stock.ItemIndex >= 0) then
        begin
          if (StrToIntDef(Trim(unEdt_CusNum.Text), 0) >= 0) then
          begin
            nIdx:= cbb_Stock.ItemIndex;
            //----------------------
            nStrSql := 'UPDate $SalePlanStkCus Set C_StockNo =''$StkNo'' ,C_StockName =''$StkName'', C_SManNo =''$SManNo'', C_SManName =''$SManName'' ,  ' +
                            'C_CusNo =''$CusNo''  ,C_CusName =''$CusName'' ,C_MaxValue =$Value  Where R_Id=$Rid ';
            nStrSql := MacroValue(nStrSql, [MI('$SalePlanStkCus', sTable_SalePlanCustomer), MI('$StkNo', FStockList[nIdx.FKey),
                                            MI('$StkName', FStockList[nIdx.FValue), MI('$SManNo', cbb_SaleMan.Text),
                                            MI('$SManName', GetRightStr('.', cbb_SaleMan.Text)), MI('$CusNo', GetLeftStr('.', cbb_Customer.Text)),
                                            MI('$CusName', GetRightStr('.', cbb_Customer.Text)),MI('$Value', Trim(unEdt_CusNum.Text)),
                                            MI('$Rid', FnParam.FParamB));
            DBExecute(nStrSql);
          end
          else ShowMessage('请输入选中品种限量吨数！');
        end
        else ShowMessage('请选择限量品种');
      end;
    end;
    Close;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormSalePlan);


end.
