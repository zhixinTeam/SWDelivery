{*******************************************************************************
  作者: dmzn@163.com 2018-05-06
  描述: 纸卡调价
*******************************************************************************}
unit UFormZhiKaPrice;

{$I Link.Inc}
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
    procedure PanelWorkClick(Sender: TObject);
  private
    { Private declarations }
    FZKList: TStrings;
    //纸卡列表
    FMainZK,FMainStock: string;
    //主纸卡号,品种
  private
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

  TFormZKPriceResult = procedure(const nRes: Integer) of object;
  //结果回调

procedure ShowZKPriceForm(const nData: string; nResult: TFormZKPriceResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm, DB,
  System.IniFiles, UManagerGroup, ULibFun, USysBusiness, USysDB;

//Date: 2018-05-06
//Parm: 待调价的记录;结果回调
//Desc: 对nData指定的记录调价
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
      if not Split(FZKList[nIdx, nList, 5, ';') then Continue;
      //明细记录号;单价;纸卡;品种名称
      if not IsNumber(nList[1, True) then Continue;

      nVal := StrToFloat(nList[1);
      if nVal < nMin then nMin := nVal;
      if nVal > nMax then nMax := nVal;

      if nStock = '' then nStock := nList[4;
      if FMainStock = '' then FMainStock := nList[3;

      if FMainZK = '' then FMainZK := nList[2 else
      if FMainZK <> nList[2 then FMainZK := sFlag_No;
    end;

    EditStock.Text := nStock;
    if nMin = nMax then
         EditPrice.Text := Format('%.2f 元/吨', [nMax)
    else EditPrice.Text := Format('%.2f - %.2f 元/吨', [nMin, nMax);
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
    ShowMessage('请输入正确的单价'); Exit;
  end;

  nStr := '注意: 该操作不可以撤销,请您慎重!' + #13#10#13#10 +
          '价格调整后,新单价会立刻生效,要继续吗?  ';
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    var nStr,nStatus,nP: string;
        nVal: Double;
        nIdx: Integer;
        nListA,nListB: TStrings;
        nQuery: TADOQuery;
    begin
      if Res <> mrYes then Exit;
      //cancel

      nListA := nil;
      nListB := nil;
      nQuery := nil;
      nQuery := LockDBQuery(FDBType);

      with TStringHelper,TFloatHelper do
      try
        nListA := gMG.FObjectPool.Lock(TStrings) as TStrings;
        nListB := gMG.FObjectPool.Lock(TStrings) as TStrings; //init

        {$IFDEF DelNotInBill}
        //调价时删除未进厂的相关品种单据
        if (FZKList.Count-1)>0 then
        begin
          if Split(FZKList[nIdx, nListA, 5, ';') then
          begin
            nStr := 'Delete %s Where T_Bill in (Select L_ID From %s Where L_InTime is Null And L_Status=''%s'' And L_StockNo=''%s'') ';
            nStr := Format(nStr, [sTable_ZTTrucks, sTable_Bill, sFlag_No, nListA[3);
            nListB.Add(nStr);
            // 清理所涉及订单的车辆排队信息

            nStr := 'UPDate %s Set A_FreezeMoney=A_FreezeMoney-(BillMoney) From ( ' +
                    'Select L_CusID, L_CusName,Sum(CAST((L_Price+IsNull(L_YunFei, 0))*L_Value AS Decimal(15,2))) BillMoney ' +
                    'From %s Where L_InTime is Null And L_Status=''%s'' And L_StockNo=''%s'' Group  by L_CusID, L_CusName ' +
                    ')S_Bill Where A_CID=L_CusID ';
            nStr := Format(nStr, [sTable_CusAccount, sTable_Bill, sFlag_No, nListA[3);
            nListB.Add(nStr);
            // 释放相关客户、涉及单据冻结金额

            nStr := 'UPDate %s Set Z_FixedMoney=Z_FixedMoney+(BillMoney) From (     ' +
                    'Select L_ZhiKa,CAST(Sum((L_Price+IsNull(L_YunFei, 0))*L_Value) AS Decimal(15,2)) BillMoney  ' +
                    'From %s Where L_InTime is Null And L_Status=''%s'' And L_StockNo=''%s'' And L_ZKMoney=''%s'' Group  by L_ZhiKa  ' +
                    ')S_Bill Where Z_ID=L_ZhiKa ';
            nStr := Format(nStr, [sTable_ZhiKa, sTable_Bill, sFlag_No, nListA[3, sFlag_Yes);
            nListB.Add(nStr);
            // 返还限提纸卡相关单据限提额度

            nStr := 'UPDate %s Set B_HasUse=B_HasUse-(BillValue) From (      ' +
                    'Select L_HYDan,Sum(L_Value) BillValue                          ' +
                    'From %s Where L_InTime is Null And L_Status=''%s'' And L_StockNo=''%s'' Group  by L_HYDan   ' +
                    ')S_Bill Where B_Batcode=L_HYDan ';
            nStr := Format(nStr, [sTable_StockBatcode, sTable_Bill, sFlag_No, nListA[3);
            nListB.Add(nStr);
            // 返还相关批次开单量

            nStr := 'UPDate %s Set C_Status=''I'', C_Used= Null    ' +
                    'Where C_Card In (Select L_Card From %s Where L_InTime is Null And L_Status=''%s'' And L_StockNo=''%s'' And L_Card Is Not Null) ';
            nStr := Format(nStr, [sTable_Card, sTable_Bill, sFlag_No, nListA[3);
            nListB.Add(nStr);
            // 重置涉及单据磁卡状态

            nStr := 'Delete %s Where H_Reporter In ( ' +
                    'Select L_Card From %s Where L_InTime is Null And L_Status=''%s'' And L_StockNo=''%s'' ) ';
            nStr := Format(nStr, [sTable_StockHuaYan, sTable_Bill, sFlag_No, nListA[3);
            nListB.Add(nStr);
            // 删除开单时生成的化验单（安塞）

            nStr := Format('Select * From %s Where 1<>1', [sTable_Bill);
            //only for fields
            nP := '';

            with DBQuery(nStr, nQuery) do
            begin
              for nIdx:=0 to FieldCount - 1 do
               if (Fields[nIdx.DataType <> ftAutoInc) and
                  (Pos('L_Del', Fields[nIdx.FieldName) < 1) then
                nP := nP + Fields[nIdx.FieldName + ',';
              //所有字段,不包括删除

              System.Delete(nP, Length(nP), 1);
            end;
            nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
                    'Select $FL,''$User'',$Now From $BI Where L_InTime is Null And L_Status=''N'' And L_StockNo=''$StockNo'' ';
            nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
                    MI('$FL', nP), MI('$User', UniMainModule.FUserConfig.FUserID+'-调价自动删除'),
                    MI('$Now', sField_SQLServer_Now),
                    MI('$BI', sTable_Bill), MI('$StockNo', nListA[3));
            nListB.Add(nStr);
            // 将所涉及的单据移除s_bill表 到s_billBak表


            nStr := 'Delete %s Where L_InTime is Null And L_Status=''%s'' And L_StockNo=''%s'' ' ;
            nStr := Format(nStr, [sTable_Bill, sFlag_No, nListA[3);
            nListB.Add(nStr);
            // 删除s_bill相关单据
          end;
        end;
        {$ENDIF}

        for nIdx:=FZKList.Count - 1 downto 0 do
        begin
          if not Split(FZKList[nIdx, nListA, 5, ';') then Continue;
          //明细记录号;单价;纸卡;品种ID,名称

          nVal := StrToFloat(EditNew.Text);
          if Check2.Checked then
            nVal := StrToFloat(nListA[1) + nVal;
          nVal := Float2Float(nVal, cPrecision, True);

          nStr := 'Update %s Set D_Price=%.2f,D_PPrice=%s ' +
                  'Where R_ID=%s And D_TPrice<>''%s''';
          nStr := Format(nStr, [sTable_ZhiKaDtl, nVal, nListA[1, nListA[0, sFlag_No);
          nListB.Add(nStr);

          nStr := '水泥品种[ %s 单价调整[ %s -> %.2f ';
          nStr := Format(nStr, [nListA[4, nListA[1, nVal);
          nStr := WriteSysLog(sFlag_ZhiKaItem, nListA[2, nStr, FDBType, nil, False, False);
          nListB.Add(nStr);

          if not Check1.Checked then Continue;
          {$IFDEF NoShowPriceChange}
          nStatus := 'Null';
          {$ELSE}
          nStatus := '''' + sFlag_TJOver + '''';
          {$ENDIF}

          nStr := 'Update %s Set Z_TJStatus=%s Where Z_ID=''%s''';
          nStr := Format(nStr, [sTable_ZhiKa, nStatus, nListA[2);
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

procedure TfFormZKPrice.PanelWorkClick(Sender: TObject);
var nListA: TStrings;
begin       Exit;
  nListA := nil;
  try
    nListA := gMG.FObjectPool.Lock(TStrings) as TStrings;
  finally
    gMG.FObjectPool.Release(nListA);
  end;
end;



initialization
  RegisterClass(TfFormZKPrice);
end.
