{*******************************************************************************
  作者: dmzn@163.com 2018-05-04
  描述: 合同管理
*******************************************************************************}
unit UFormContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysConst, uniGUITypes, UFormBase, uniCheckBox, uniBitBtn, uniBasicGrid,
  uniStringGrid, uniDateTimePicker, uniMultiItem, uniComboBox, uniLabel,
  uniGUIClasses, uniEdit, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormSaleContract = class(TfFormBase)
    EditID: TUniEdit;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    EditName: TUniEdit;
    UniLabel3: TUniLabel;
    EditArea: TUniEdit;
    UniLabel4: TUniLabel;
    EditApproval: TUniEdit;
    EditSaleMan: TUniComboBox;
    UniLabel8: TUniLabel;
    UniLabel9: TUniLabel;
    EditCus: TUniComboBox;
    UniLabel10: TUniLabel;
    EditQAddr: TUniEdit;
    UniLabel13: TUniLabel;
    UniLabel14: TUniLabel;
    UniLabel6: TUniLabel;
    UniLabel5: TUniLabel;
    EditDays: TUniEdit;
    EditJAddr: TUniEdit;
    EditQDate: TUniDateTimePicker;
    Label1: TUniLabel;
    Label2: TUniLabel;
    EditPayment: TUniComboBox;
    Check1: TUniCheckBox;
    Grid1: TUniStringGrid;
    Label3: TUniLabel;
    EditMemo: TUniEdit;
    BtnMakeID: TUniBitBtn;
    procedure BtnOKClick(Sender: TObject);
    procedure EditSaleManChange(Sender: TObject);
    procedure EditCusKeyPress(Sender: TObject; var Key: Char);
    procedure BtnMakeIDClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  System.IniFiles, Vcl.Grids, Vcl.StdCtrls, ULibFun, USysBusiness, USysRemote,
  USysDB, UFormGetCustomer;

const
  giID    = 0;
  giName  = 1;
  giValue = 2;
  giPrice = 3;
  giMoney = 4;
  giType  = 5;
  //grid info:表格列数据描述

procedure TfFormSaleContract.OnCreateForm(Sender: TObject);
begin
  with Grid1 do
  begin
    FixedCols := 2;
    RowCount := 0;
    ColCount := 6;
    Options := [goVertLine,goHorzLine,goEditing,goFixedColClick];
  end;

  UserDefineStringGrid(Name, Grid1, True);
end;

procedure TfFormSaleContract.OnDestroyForm(Sender: TObject);
begin
  UserDefineStringGrid(Name, Grid1, False);
end;

function TfFormSaleContract.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  ActiveControl := EditID;
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

//Date: 2018-05-03
//Parm: 供应商编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormSaleContract.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  EditID.ReadOnly := nID <> '';
  BtnMakeID.Enabled := nID = '';
  EditSaleMan.ReadOnly := nID <> '';
  EditCus.ReadOnly := nID <> '';

  if nID = '' then
  begin
    EditSaleMan.Style := csDropDownList;
    EditCus.Style := csDropDown;
  end else
  begin
    EditSaleMan.Style := csDropDown;
    EditCus.Style := csDropDown;
  end;

  if EditSaleMan.Items.Count < 1 then
    LoadSaleMan(EditSaleMan.Items);
  LoadSysDictItem(sFlag_PaymentItem, EditPayment.Items);

  nQuery := nil;
  with TStringHelper do
  try
    nStr := 'Select * From $Table Where D_Name=''$Name'' Order By D_Index DESC';
    nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                              MI('$Name', sFlag_StockItem)]);
    //xxxxx

    nQuery := LockDBQuery(ctWork);
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      Grid1.RowCount := RecordCount;
      nIdx := 0;
      First;

      while not Eof do
      begin
        Grid1.Cells[giID,    nIdx] := FieldByName('D_ParamB').AsString;
        Grid1.Cells[giName,  nIdx] := FieldByName('D_Value').AsString;
        Grid1.Cells[giValue, nIdx] := '0';
        Grid1.Cells[giPrice, nIdx] := '0';
        Grid1.Cells[giMoney, nIdx] := '0';
        Grid1.Cells[giType,  nIdx] := FieldByName('D_Memo').AsString;

        Inc(nIdx);
        Next;
      end;
    end;

    if nID <> '' then
    begin
      nStr := 'Select sc.*,C_Name,S_Name From %s sc ' +
              ' Left Join %s c on c.C_ID=sc.C_Customer ' +
              ' Left Join %s s On s.S_ID=sc.C_SaleMan ' +
              'Where sc.R_ID=''%s''';
      nStr := Format(nStr, [sTable_SaleContract, sTable_Customer,
           sTable_SalesMan, nID]);
      //xxxxx

      with DBQuery(nStr, nQuery) do
      if RecordCount > 0 then
      begin
        BtnOK.Enabled := True;
        First;

        EditID.Text       := FieldByName('C_ID').AsString;
        EditName.Text     := FieldByName('C_Project').AsString;
        EditQDate.DateTime:= FieldByName('C_Date').AsDateTime;
        EditArea.Text     := FieldByName('C_Area').AsString;
        EditQAddr.Text    := FieldByName('C_Addr').AsString;
        EditJAddr.Text    := FieldByName('C_Delivery').AsString;
        EditPayment.Text  := FieldByName('C_Payment').AsString;
        EditApproval.Text := FieldByName('C_Approval').AsString;
        EditDays.Text     := FieldByName('C_ZKDays').AsString;
        EditMemo.Text     := FieldByName('C_Memo').AsString;

        Check1.Checked    := FieldByName('C_XuNi').AsString = sFlag_Yes;
        //xxxxx

        EditSaleMan.Text  := FieldByName('C_SaleMan').AsString + '.' +
                             FieldByName('S_Name').AsString;
        //xxxxxx

        EditCus.Text      := FieldByName('C_Customer').AsString + '.' +
                             FieldByName('C_Name').AsString;
        //xxxxxx
      end;
    end;

    nStr := 'Select * From %s Where E_CID=''%s''';
    nStr := Format(nStr, [sTable_SContractExt, EditID.Text]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr := FieldByName('E_StockNo').AsString;
        for nIdx := 0 to Grid1.RowCount-1 do
        if Grid1.Cells[0, nIdx] = nStr then //编号匹配
        begin
          Grid1.Cells[giValue, nIdx] := FieldByName('E_Value').AsString;
          Grid1.Cells[giPrice, nIdx] := FieldByName('E_Price').AsString;
          Grid1.Cells[giMoney, nIdx] := FieldByName('E_Money').AsString;
          Break;
        end;

        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Desc: 业务员变更,选择客户
procedure TfFormSaleContract.EditSaleManChange(Sender: TObject);
var nStr: string;
begin
  nStr := GetIDFromBox(EditSaleMan);
  if nStr = '' then
  begin
    EditCus.Items.Clear;
    Exit;
  end;

  nStr := Format('C_SaleMan=''%s''', [nStr]);
  LoadCustomer(EditCus.Items, nStr);
end;

//Desc: 选择客户
procedure TfFormSaleContract.EditCusKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    ShowGetCustomerForm(GetNameFromBox(EditCus), '',
      procedure(const nResult: Integer; const nParam: PFormCommandParam)
      begin
        nStr := Trim(nParam.FParamC + '.' + nParam.FParamD); //saleman: id.name
        if (nStr <> '.') and (EditSaleMan.Items.IndexOf(nStr) < 0) then
          EditSaleMan.Items.Add(nStr);
        EditSaleMan.ItemIndex := EditSaleMan.Items.IndexOf(nStr);

        nStr := nParam.FParamA + '.' + nParam.FParamB; //cus: id.name
        if EditCus.Items.IndexOf(nStr) < 0 then
          EditCus.Items.Add(nStr);
        EditCus.ItemIndex := EditCus.Items.IndexOf(nStr);
      end
    );
  end;
end;

//Desc: 生成编号
procedure TfFormSaleContract.BtnMakeIDClick(Sender: TObject);
begin
  EditID.Text := GetSerialNo(sFlag_BusGroup, sFlag_Contract, False);
end;

procedure TfFormSaleContract.BtnOKClick(Sender: TObject);
var nStr,nCus: string;
    nIdx: Integer;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    EditID.SetFocus;
    ShowMessage('请填写合同编号'); Exit;
  end;

  nCus := GetIDFromBox(EditCus);
  if (nCus = '') or ((not EditCus.ReadOnly) and (EditCus.ItemIndex < 0)) then
  begin
    EditCus.SetFocus;
    ShowMessage('请选择客户'); Exit;
  end;

  with TStringHelper do
  if (not IsNumber(EditDays.Text, False)) or (StrToInt(EditDays.Text) < 0 ) then
  begin
    EditDays.SetFocus;
    ShowMessage('请填写有效的时长'); Exit;
  end;

  nList := nil;
  nQuery := nil;
  with TSQLBuilder,TStringHelper,TDateTimeHelper do
  try
    nQuery := LockDBQuery(FDBType);
    if FParam.FCommand = cCmd_AddData then
    begin
      nStr := 'Select Count(*) From %s Where C_ID=''%s''';
      nStr := Format(nStr, [sTable_SaleContract, EditID.Text]);
      //查询编号是否存在

      with DBQuery(nStr, nQuery) do
      if Fields[0].AsInteger > 0 then
      begin
        EditID.SetFocus;
        ShowMessage('该编号的合同已经存在'); Exit;
      end;
    end;

    if FParam.FCommand = cCmd_AddData then
         nIdx := 0
    else nIdx := 1;

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nStr := SF('R_ID', FParam.FParamA, sfVal);

    nStr := MakeSQLByStr([
      SF_IF([SF('C_ID', EditID.Text), ''], nIdx = 0),
      SF_IF([SF('C_SaleMan', GetIDFromBox(EditSaleMan)), ''], nIdx = 0),
      SF_IF([SF('C_Customer', GetIDFromBox(EditCus)), ''], nIdx = 0),
      SF_IF([SF('C_Freeze', sFlag_No), ''], nIdx = 0),
      SF_IF([SF('C_XuNi', sFlag_Yes), SF('C_XuNi', sFlag_No)], Check1.Checked),

      SF('C_Project', EditName.Text),
      SF('C_Date', Date2Str(EditQDate.DateTime)),
      SF('C_Area', EditArea.Text),
      SF('C_Addr', EditQAddr.Text),
      SF('C_Delivery', EditJAddr.Text),
      SF('C_Payment', EditPayment.Text),
      SF('C_Approval', EditApproval.Text),
      SF('C_ZKDays', EditDays.Text, sfVal),
      SF('C_Memo', EditMemo.Text)
      ], sTable_SaleContract, nStr, FParam.FCommand = cCmd_AddData);
    nList.Add(nStr);

    if FParam.FCommand = cCmd_EditData then
    begin
      nStr := 'Delete From %s Where E_CID=''%s''';
      nStr := Format(nStr, [sTable_SContractExt, EditID.Text]);
      nList.Add(nStr);
    end;

    for nIdx := 0 to Grid1.RowCount-1 do
    if IsNumber(Grid1.Cells[giValue, nIdx], True) and
       (StrToFloat(Grid1.Cells[giValue, nIdx]) > 0) then
    begin
      nStr := MakeSQLByStr([
        SF('E_CID', EditID.Text),
        SF('E_Type', Grid1.Cells[giType, nIdx]),
        SF('E_StockNo', Grid1.Cells[giID, nIdx]),
        SF('E_StockName', Grid1.Cells[giName, nIdx]),
        SF('E_Value', Grid1.Cells[giValue, nIdx], sfVal),

        SF_IF([SF('E_Price', Grid1.Cells[giPrice, nIdx], sfVal), 'E_Price=0'],
               IsNumber(Grid1.Cells[giPrice, nIdx], True)),
        //xxxxx

        SF_IF([SF('E_Money', Grid1.Cells[giMoney, nIdx], sfVal), 'E_Money=0'],
               IsNumber(Grid1.Cells[giMoney, nIdx], True))
        //xxxxx
        ], sTable_SContractExt, '', True);
      nList.Add(nStr);
    end;

    DBExecute(nList, nil, FDBType);
    ModalResult := mrOk;
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormSaleContract);
end.
