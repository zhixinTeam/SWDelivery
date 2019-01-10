{*******************************************************************************
  作者: dmzn@163.com 2018-05-18
  描述: 设置返利价格
*******************************************************************************}
unit UFormInvoiceFLSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, USysConst,
  UFormBase, uniGUIClasses, uniEdit, uniLabel, uniPanel, Vcl.Controls,
  Vcl.Forms, uniGUIBaseClasses, uniButton;

type
  TfFormInvoiceFLSet = class(TfFormBase)
    Label1: TUniLabel;
    Label2: TUniLabel;
    UniLabel1: TUniLabel;
    EditName: TUniEdit;
    UniLabel2: TUniLabel;
    EditCustomer: TUniEdit;
    EditStock: TUniEdit;
    EditValue: TUniEdit;
    EditPrice: TUniEdit;
    UniLabel3: TUniLabel;
    UniLabel4: TUniLabel;
    EditFL: TUniEdit;
    EditFLNew: TUniEdit;
    UniLabel5: TUniLabel;
    Panel2: TUniSimplePanel;
    UnLbl1: TUniLabel;
    unEdt_YunFei: TUniEdit;
    UnLbl2: TUniLabel;
    UnLbl3: TUniLabel;
    UnLbl4: TUniLabel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FPrice,FFLPrice, FYYunFei, FYFlYunfei, FFLYunFei: Double;
    //旧价格
    FWhere : string;
  private
    procedure InitFormData(const nWhere: string);
    //载入数据
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysDB, USysBusiness;

function TfFormInvoiceFLSet.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  ActiveControl := EditFLNew;
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

procedure TfFormInvoiceFLSet.InitFormData(const nWhere: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
//    nStr := 'Select req.*,W_Name From %s req ' +
//            ' Left Join %s on W_NO=req.R_Week ' +
//            'Where req.R_ID=%s';

    nStr := 'Select R_Week, R_CusID, R_Customer, R_SaleID, R_SaleMan, R_Type, R_Stock, R_Price, SUM(R_Value) R_Value, R_PreHasK, '+
                'R_ReqValue, R_KPrice,SUM(R_KValue) R_KValue, R_KOther, R_Man, R_Date, R_CusPY, R_StockName, R_ZhiKa, R_YunFei, R_KMan, R_KDate, '+
                'R_KYunFei, W_Name,Z_Name,Z_Project From %s  req ' +

              ' Left Join %s On W_NO=req.R_Week ' +
              ' Left Join %s On Z_ID=req.R_ZhiKa  ';

    nStr := nStr + 'Where R_Chk=1 And ' + nWhere;
    nStr := nStr +
              ' Group  by  R_Week, R_CusID, R_Customer, R_SaleID, R_SaleMan, R_Type, R_Stock, R_Price, R_PreHasK, R_ReqValue, '+
              'R_KPrice, R_KOther, R_Man, R_Date, R_CusPY, R_StockName, R_ZhiKa, R_YunFei, R_KMan, R_KDate, R_KYunFei,'+
              ' W_Name,Z_Name,Z_Project';

    nStr := Format(nStr, [sTable_InvoiceReq, sTable_InvoiceWeek, sTable_ZhiKa]);

    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount < 1 then
      begin
        //nStr := Format('编号为[ %s ]的记录已丢失', [nID]);
        ShowMessage('未能找到符合条件的记录');
        Exit;
      end;

      BtnOK.Enabled := True;
      First;

      FParam.FParamB := FieldByName('R_ZhiKa').AsString;
      EditName.Text  := FieldByName('W_Name').AsString;
      EditCustomer.Text := FieldByName('R_Customer').AsString;
      EditStock.Text := FieldByName('R_StockName').AsString;
      EditValue.Text := Format('%.2f 吨', [FieldByName('R_Value').AsFloat]);

      FPrice := FieldByName('R_Price').AsFloat;
      EditPrice.Text := Format('%.2f 元/吨', [FPrice]);

      FFLPrice := FieldByName('R_KPrice').AsFloat;
      EditFL.Text := Format('%.2f 元/吨', [FFLPrice]);      // 之前设置的返利销售价价差
      //EditFLNew.Text := Format('%.2f', [FFLPrice]);


      FYYunFei := FieldByName('R_YunFei').AsFloat;
      UnLbl3.Caption := Format('%.2f 元/吨', [FYYunFei]);

      FYFlYunfei := FieldByName('R_KYunFei').AsFloat;        // 返利运费价差
      unEdt_YunFei.Text := Format('%.2f', [FYFlYunfei]);
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceFLSet.BtnOKClick(Sender: TObject);
var nStr: string;
    nVal, nYunFei: Double;
    nList: TStrings;
begin
  nList := nil;
  with TStringHelper,TFloatHelper do
  try
    if not IsNumber(EditFLNew.Text, True) then
    begin
      ShowMessage('请输入有效的返利价差'); Exit;
    end;

    nVal := StrToFloat(EditFLNew.Text);
    nYunFei := StrToFloat(unEdt_YunFei.Text);

    if FloatRelation(nVal, FFLPrice, rtEqual)and
        FloatRelation(nYunFei, FYFlYunfei, rtEqual) then
    begin
      ShowMessage('本次操作未更改任何一项返利价格、取消此次操作');
      ModalResult := mrNo;
      Exit;
    end;


    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    //xxxxx

    nStr := 'UPDate %s Set R_KPrice=%.2f, R_KYunFei=%.2f Where R_Chk=1 And %s';
    nStr := Format(nStr, [sTable_InvoiceReq, nVal, nYunFei, FParam.FParamA]);
    nList.Add(nStr);

    nStr := Format('返利价差[ %.2f -> %.2f ] 返利运费价差[ %.2f -> %.2f ]',
                                      [FFLPrice, nVal, FYFlYunfei, nYunFei]);
    nStr := WriteSysLog(sFlag_ZhiKaItem, FParam.FParamB, nStr,
            FDBType, nil, False, False);
    nList.Add(nStr);

    DBExecute(nList);
    ModalResult := mrOk;
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

initialization
  RegisterClass(TfFormInvoiceFLSet);
end.
