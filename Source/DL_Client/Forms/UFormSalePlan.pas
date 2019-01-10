unit UFormSalePlan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, dxSkinsDefaultPainters, cxContainer, cxListBox, ExtCtrls,
  StdCtrls, RzLstBox, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit,
  UDataModule, UFormBase, cxDropDownEdit, cxCalendar;

type
  TStockItem = record
    FID   : string;
    FName : string;
  end;

  TTfFormBillSalePlan = class(TBaseForm)
    Edt_StockNum: TcxTextEdit;
    lbl2: TLabel;
    btn_Save: TButton;
    Edt_CusNum: TcxTextEdit;
    lbl3: TLabel;
    cbbEditSalesMan: TcxComboBox;
    cbbEditName: TcxComboBox;
    lbl1: TLabel;
    EditStock: TcxComboBox;
    lbl4: TLabel;
    lbl5: TLabel;
    btn1: TButton;
    chk1: TCheckBox;
    procedure btn_SaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure cbbEditSalesManPropertiesChange(Sender: TObject);
    procedure EditStockPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FParam : PFormCommandParam;
  private
    procedure SaveStockSet(IsNew: Boolean);
    procedure SaveCusStockSet(IsNew: Boolean);
  public

  private
    procedure LoadInfoData;
    procedure LoadStockMaxValue;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = ''; const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;


implementation

{$R *.dfm}


uses
  DB, IniFiles, ULibFun, UFormCtrl, UAdjustForm, UMgrControl, UFormBaseInfo,
  USysGrid, USysDB, USysConst, USysBusiness;

//DXL01
var
  gStockItems: array of TStockItem;
  //品种列表
  nP: PFormCommandParam;


  
class function TTfFormBillSalePlan.FormID: integer;
begin
  Result := cFI_FormBillSalePlan;
end;

function GetLeftStr(SubStr, Str: string): string;
begin
   Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
end;

function GetRightStr(SubStr, Str: string): string;
var
   i: integer;
begin
   i := pos(SubStr, Str);
   if i > 0 then
     Result := Copy(Str
       , i + Length(SubStr)
       , Length(Str) - i - Length(SubStr) + 1)
   else
     Result := '';
end;

class function TTfFormBillSalePlan.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr:string;
begin
  Result := nil;
  with TTfFormBillSalePlan.Create(Application) do
  begin
    try
      nP:= nParam;
      LoadInfoData;

      case nP.FCommand of
       cCmd_AddData:
        begin
          Caption := '销售供应计划 - 添加';
          if nP.FParamA='Stock' then
          begin
            EditStock.Enabled:= True;
            Edt_StockNum.Enabled:= True;
            chk1.Visible:= True;
          end
          else if nP.FParamA='Customer' then
          begin
            EditStock.Enabled:= True;
            cbbEditSalesMan.Enabled:= True;
            cbbEditName.Enabled:= True;
            Edt_CusNum.Enabled:= True;
          end;

          nP.FParamA := ShowModal;
        end;

       cCmd_EditData:
        begin
          Caption := '销售供应计划 - 修改';
          if nP.FParamA='Stock' then
          begin
            EditStock.Enabled:= True;
            Edt_StockNum.Enabled:= True;
            chk1.Visible:= True;

            EditStock.ItemIndex:= EditStock.Properties.Items.IndexOf(nP.FParamC);
            Edt_StockNum.Text:= nP.FParamD;
            chk1.Checked:= nP.FParamE=sFlag_Yes;
          end
          else if nP.FParamA='Customer' then
          begin
            EditStock.Enabled:= True;
            cbbEditSalesMan.Enabled:= True;
            cbbEditName.Enabled:= True;
            Edt_CusNum.Enabled:= True;

            EditStock.ItemIndex:= EditStock.Properties.Items.IndexOf(nP.FParamC);
            nStr:= GetLeftStr('@', nP.FParamD);
            cbbEditSalesMan.ItemIndex:= cbbEditSalesMan.Properties.Items.IndexOf(nStr);
            nStr:= GetRightStr('@', nP.FParamD);
            cbbEditName.ItemIndex:= cbbEditName.Properties.Items.IndexOf(nStr);
            Edt_CusNum.Text:= nP.FParamE;
          end;

          nP.FParamA := ShowModal;
        end;
      end;

      //ShowModal;
    finally
      nP.FCommand := cCmd_ModalResult;
      Free;
    end;
  end;
end;

procedure TTfFormBillSalePlan.LoadStockMaxValue;
var nStr: string;
    nIdx: integer;
begin
  Edt_StockNum.Text:= '0';
  if (nP.FParamA<>'Stock') then
  begin
    nIdx := EditStock.ItemIndex;
    //----------------------
    nStr := ' Select * From X_SalePlanStock Where S_StockName=''' + gStockItems[nIdx].FName + '''';
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount >0 then
      begin
        Edt_StockNum.Text := FieldByName('S_Value').AsString;
      end
      else
      begin
        ShowMsg('该品种当前尚未设置供应限量、请设置后再操作', sHint);
      end
    end;
  end;
end;

procedure TTfFormBillSalePlan.LoadInfoData;
var nStr: string;
    nIdx: integer;
begin
  nStr := 'Select D_Value,D_ParamB From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);
  //------------------------
  EditStock.Properties.Items.Clear;
  SetLength(gStockItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gStockItems, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gStockItems[nIdx] do
      begin
        FID := Fields[1].AsString;
        FName := Fields[0].AsString;
        EditStock.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  LoadSaleMan(cbbEditSalesMan.Properties.Items, '');
end;

procedure TTfFormBillSalePlan.btn_SaveClick(Sender: TObject);
var nStrSql : string;
begin
  if StrToFloatDef(Trim(Edt_CusNum.Text), 0)>StrToFloatDef(Trim(Edt_StockNum.Text), 0) then
  begin
    ShowMsg('当前品种客户供应上限不能大于总供应量', sHint);
    Exit;
  end;

  if (nP.FParamA='Stock') then
  begin
    SaveStockSet(nP.FCommand=cCmd_AddData);
  end
  else
  begin
    SaveCusStockSet(nP.FCommand=cCmd_AddData);
  end;
end;

procedure TTfFormBillSalePlan.SaveStockSet(IsNew: boolean);
var nStrSql, nPrCBill : string;
begin
  if chk1.Checked then nPrCBill:= 'Y'
  else nPrCBill:= 'N';

  if IsNew then
  begin
    if (EditStock.ItemIndex >= 0) then
    begin
        //*******************************
        if (StrToIntDef(Trim(Edt_StockNum.Text), 0) >= 0) then
        begin
            nStrSql := ' Select * From X_SalePlanStock Where S_StockName='''+gStockItems[EditStock.ItemIndex].FName+'''';
            with FDM.QueryTemp(nStrSql) do
            begin
              if RecordCount > 0 then
              begin
                ShowMsg('该品种当前已设置供应限量、请勿重复操作', sHint);
                Exit;
              end
            end;
            
            nStrSql := 'Insert Into $SalePlanStk (S_StockNo, S_StockName, S_Value, S_ProhibitCreateBill)' +
                      ' Select ''$StockNo'', ''$StockName'', $Value, ''$PrCBill''';
            nStrSql := MacroValue(nStrSql, [MI('$SalePlanStk', sTable_SalePlanStock), MI('$StockNo', gStockItems[EditStock.ItemIndex ].FID),
                                            MI('$StockName', gStockItems[EditStock.ItemIndex ].FName), MI('$Value', Trim(Edt_StockNum.Text)),
                                            MI('$PrCBill', Trim(nPrCBill))]);
          FDM.ExecuteSQL(nStrSql);
          close;
        end
        else ShowMsg('请输入选中品种限量吨数！', sHint);
    end
    else ShowMsg('请选择限量品种', sHint);
  end
  else
  begin
    if (EditStock.ItemIndex >= 0) then
    begin
      if (StrToIntDef(Trim(Edt_StockNum.Text), 0) >= 0) then
      begin
          nStrSql := cbbEditName.Text;
          nStrSql := 'UPDate $SalePlan Set S_StockNo=''$StockNo'' ,S_StockName=''$StockName'', S_Value=''$Value'',S_ProhibitCreateBill=''$PrCBill'' '+
                            ' Where R_Id=$Rid ';
          nStrSql := MacroValue(nStrSql, [MI('$SalePlan', sTable_SalePlanStock), MI('$StockNo', gStockItems[EditStock.ItemIndex ].FId),
                                          MI('$StockName', gStockItems[EditStock.ItemIndex ].FName), MI('$Value', Trim(Edt_StockNum.Text)),
                                          MI('$PrCBill', Trim(nPrCBill)),
                                          MI('$Rid', np.FParamB)]);
          FDM.ExecuteSQL(nStrSql);
          close;
      end
      else ShowMsg('请输入选中品种限量吨数！', sHint);
    end
    else ShowMsg('请选择限量品种', sHint);
  end;
end;

procedure TTfFormBillSalePlan.SaveCusStockSet(IsNew: boolean);
var nStrSql : string;
    nIdx : Integer;
    nStockMaxValue : double;
begin
  nStrSql:= GetRightStr('.', cbbEditName.Text);
  if IsNew then
  begin
    if (EditStock.ItemIndex >= 0) then
    begin
        if (StrToIntDef(Trim(Edt_CusNum.Text), 0) >= 0) then
        begin
            nIdx:= EditStock.ItemIndex;
            //----------------------
            nStrSql := ' Select * From X_SalePlanStock Where S_StockName='''+gStockItems[nIdx].FName+'''';
            with FDM.QueryTemp(nStrSql) do
            begin
              if RecordCount < 1 then
              begin
                ShowMsg('该品种当前尚未设置供应限量、请设置后再操作', sHint);
                close;
                Exit;
              end
              else
              begin
                nStockMaxValue:= FieldByName('S_Value').AsFloat;
              end;
            end;

            //----------------------
            nStrSql := ' Select * From X_SalePlanCustomer Where C_StockName='''+gStockItems[nIdx].FName+
                                ''' And C_CusNo='''+GetLeftStr('.', cbbEditName.Text)+''' ';
            with FDM.QueryTemp(nStrSql) do
            begin
              if RecordCount > 0 then
              begin
                ShowMsg('当前客户已设置该品种供应量、请勿重复操作', sHint);
                close;
                Exit;
              end;
            end;
            //----------------------
            nIdx:= EditStock.ItemIndex;
            nStrSql := 'Insert Into %s (C_StockNo,C_StockName,C_SManNo,C_SManName,C_CusNo,C_CusName,C_MaxValue)' +
                      ' Select ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %s ';
            nStrSql := Format(nStrSql, [sTable_SalePlanCustomer, gStockItems[nIdx].FID, gStockItems[nIdx].FName,
                                          cbbEditSalesMan.Text,
                                          GetRightStr('.', cbbEditSalesMan.Text), GetLeftStr('.', cbbEditName.Text),
                                          GetRightStr('.', cbbEditName.Text), Trim(Edt_CusNum.Text), np.FParamB]);
            FDM.ExecuteSQL(nStrSql);
        end
        else ShowMsg('请输入选中品种限量吨数！', sHint);
    end
    else ShowMsg('请选择限量品种', sHint);
  end
  else
  begin
    if (EditStock.ItemIndex >= 0) then
    begin
      if (StrToIntDef(Trim(Edt_CusNum.Text), 0) >= 0) then
      begin
        nIdx:= EditStock.ItemIndex;
        //----------------------
        nStrSql := 'UPDate $SalePlanStkCus Set C_StockNo =''$StkNo'' ,C_StockName =''$StkName'', C_SManNo =''$SManNo'', C_SManName =''$SManName'' ,  ' +
		                    'C_CusNo =''$CusNo''  ,C_CusName =''$CusName'' ,C_MaxValue =$Value  Where R_Id=$Rid ';
        nStrSql := MacroValue(nStrSql, [MI('$SalePlanStkCus', sTable_SalePlanCustomer), MI('$StkNo', gStockItems[nIdx].FID),
                                        MI('$StkName', gStockItems[nIdx].FName), MI('$SManNo', cbbEditSalesMan.Text),
                                        MI('$SManName', GetRightStr('.', cbbEditSalesMan.Text)), MI('$CusNo', GetLeftStr('.', cbbEditName.Text)),
                                        MI('$CusName', GetRightStr('.', cbbEditName.Text)),MI('$Value', Trim(Edt_CusNum.Text)),
                                        MI('$Rid', np.FParamB)]);
        FDM.ExecuteSQL(nStrSql);
      end
      else ShowMsg('请输入选中品种限量吨数！', sHint);
    end
    else ShowMsg('请选择限量品种', sHint);
  end;

  Close;
end;

procedure TTfFormBillSalePlan.FormCreate(Sender: TObject);
begin
  inherited;
  //FListA := TStringList.Create;
end;

procedure TTfFormBillSalePlan.FormDestroy(Sender: TObject);
begin
  inherited;
  //FreeAndNil(FListA);
end;

procedure TTfFormBillSalePlan.btn1Click(Sender: TObject);
begin
  Close;
end;

procedure TTfFormBillSalePlan.cbbEditSalesManPropertiesChange(
  Sender: TObject);
var nStr : string;
begin
  if cbbEditSalesMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(cbbEditSalesMan)]);
    LoadCustomer(cbbEditName.Properties.Items, nStr);
  end;
end;

procedure TTfFormBillSalePlan.EditStockPropertiesChange(Sender: TObject);
begin
  LoadStockMaxValue;
end;

initialization
  gControlManager.RegCtrl(TTfFormBillSalePlan, TTfFormBillSalePlan.FormID);

end.
