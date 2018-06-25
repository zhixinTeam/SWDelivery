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
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FPrice,FFLPrice: Double;
    //旧价格
    procedure InitFormData(const nID: string);
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

procedure TfFormInvoiceFLSet.InitFormData(const nID: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    nStr := 'Select req.*,W_Name From %s req ' +
            ' Left Join %s on W_NO=req.R_Week ' +
            'Where req.R_ID=%s';
    nStr := Format(nStr, [sTable_InvoiceReq, sTable_InvoiceWeek, nID]);

    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
    begin
      if RecordCount < 1 then
      begin
        nStr := Format('编号为[ %s ]的记录已丢失', [nID]);
        ShowMessage(nStr); Exit;
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
      EditFL.Text := Format('%.2f 元/吨', [FFLPrice]);
      //EditFLNew.Text := Format('%.2f', [FFLPrice]);
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceFLSet.BtnOKClick(Sender: TObject);
var nStr: string;
    nVal: Double;
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
    if FloatRelation(nVal, FFLPrice, rtEqual) then
    begin
      ModalResult := mrNo;
      Exit;
    end;

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    //xxxxx

    nStr := 'Update %s Set R_KPrice=%.2f Where R_ID=%s';
    nStr := Format(nStr, [sTable_InvoiceReq, nVal, FParam.FParamA]);
    nList.Add(nStr);

    nStr := Format('返利价差[ %.2f -> %.2f ]', [FFLPrice, nVal]);
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
