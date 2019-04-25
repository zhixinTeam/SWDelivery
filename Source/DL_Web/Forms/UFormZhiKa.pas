{*******************************************************************************
  作者: dmzn@163.com 2018-05-05
  描述: 纸卡办理
*******************************************************************************}
unit UFormZhiKa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Data.Win.ADODB,
  Controls, Forms, USysConst, UFormBase, uniBitBtn, uniBasicGrid, uniStringGrid,
  uniDateTimePicker, uniMultiItem, uniComboBox, uniLabel, uniGUIClasses,
  uniEdit, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormZhiKa = class(TfFormBase)
    EditName: TUniEdit;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    EditCID: TUniEdit;
    UniLabel3: TUniLabel;
    EditProject: TUniEdit;
    EditSaleMan: TUniComboBox;
    UniLabel8: TUniLabel;
    UniLabel9: TUniLabel;
    EditCus: TUniComboBox;
    UniLabel13: TUniLabel;
    UniLabel14: TUniLabel;
    UniLabel6: TUniLabel;
    EditMoney: TUniEdit;
    EditDays: TUniDateTimePicker;
    Label1: TUniLabel;
    EditPayment: TUniComboBox;
    Grid1: TUniStringGrid;
    Label3: TUniLabel;
    BtnGetContract: TUniBitBtn;
    Label2: TUniLabel;
    EditLading: TUniComboBox;
    procedure BtnOKClick(Sender: TObject);
    procedure EditSaleManChange(Sender: TObject);
    procedure EditCIDKeyPress(Sender: TObject; var Key: Char);
    procedure BtnGetContractClick(Sender: TObject);
    procedure EditCusKeyPress(Sender: TObject; var Key: Char);
    procedure Grid1Click(Sender: TObject);
  private
    { Private declarations }
    procedure MakeDefaultValue;
    //设置默认值
    procedure InitFormData(const nID: string);
    //载入数据
    procedure LoadContract(const nCID: string; const nQuery: TADOQuery);
    //读取合同
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, UManagerGroup, Vcl.Grids,
  Vcl.StdCtrls, ULibFun, UFormGetContract, USysBusiness, USysRemote, USysDB,
  UFormGetCustomer;

const
  giID       = 0;
  giName     = 1;
  giPrice    = 2;
  giFLPrice  = 3;
  giYunFei   = 4;
  giValue    = 5;
  giType     = 6;
  giCheck    = 7;
  //grid info:表格列数据描述

//------------------------------------------------------------------------------
procedure TfFormZhiKa.OnCreateForm(Sender: TObject);
begin
  with Grid1 do
  begin
    FixedCols := 2;
    RowCount := 0;
    ColCount := 8;
    Options := [goVertLine,goHorzLine, goColSizing, goEditing,goFixedColClick;
  end;

  ActiveControl := EditName;
  InitFormData('');
  UserDefineStringGrid(Name, Grid1, True);
end;

procedure TfFormZhiKa.OnDestroyForm(Sender: TObject);
begin
  UserDefineStringGrid(Name, Grid1, False);
end;

function TfFormZhiKa.SetParam(const nParam: TFormCommandParam): Boolean;
begin
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

procedure TfFormZhiKa.MakeDefaultValue;
var nStr: string;
begin
  with TStringHelper,TDateTimeHelper do
  begin
    EditLading.ItemIndex := StrListIndex('T', EditLading.Items, 0, '.');
    EditPayment.Text := '现款';

    nStr := Copy(Date2Str(Now(), False), 3, 4);
    EditName.Text := Format('%s零售价', [nStr);
  end;
end;

//Date: 2018-05-03
//Parm: 供应商编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormZhiKa.InitFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  EditCID.ReadOnly := nID <> '';
  BtnGetContract.Enabled := not EditCID.ReadOnly;
  EditSaleMan.ReadOnly := True;
  EditCus.ReadOnly := True;

  if nID = '' then
  begin
    EditSaleMan.Style := csDropDownList;
    EditCus.Style := csDropDown;
    MakeDefaultValue;
  end else
  begin
    EditSaleMan.Style := csDropDown;
    EditCus.Style := csDropDown
  end;

  if EditSaleMan.Items.Count < 1 then
    LoadSaleMan(EditSaleMan.Items);
  //xxxxx

  if EditPayment.Items.Count < 1 then
    LoadSysDictItem(sFlag_PaymentItem, EditPayment.Items);
  //xxxxx

  nQuery := nil;
  if nID <> '' then
  try
    with TStringHelper do
    begin
      nStr := 'Select zk.*,S_Name,S_PY,C_Name From $ZK zk ' +
              ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan' +
              ' Left Join $Cus cus On cus.c_ID=zk.Z_Customer ' +
              'Where zk.R_ID=$ID';
      nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
              MI('$Cus', sTable_Customer), MI('$SM', sTable_Salesman),
              MI('$ID', nID));
      //xxxxx

      nQuery := LockDBQuery(FDBType);
      //get query
      
      with DBQuery(nStr, nQuery) do
      begin
        if RecordCount < 1 then
        begin
          nStr := '记录号为[ %s 的纸卡已无效.';
          ShowMessage(Format(nStr, [nID));
          Exit;
        end;

        BtnOK.Enabled := True;
        First;

        FParam.FParamB      := FieldByName('Z_ID').AsString;
        EditName.Text       := FieldByName('Z_Name').AsString;
        EditCID.Text        := FieldByName('Z_CID').AsString;
        EditProject.Text    := FieldByName('Z_Project').AsString;
        EditPayment.Text    := FieldByName('Z_Payment').AsString;
        EditMoney.Text      := FieldByName('Z_YFMoney').AsString;
        EditDays.DateTime   := FieldByName('Z_ValidDays').AsDateTime;

        nStr := FieldByName('Z_Lading').AsString;
        EditLading.ItemIndex := StrListIndex(nStr, EditLading.Items, 0, '.');

        EditSaleMan.Text  := FieldByName('Z_SaleMan').AsString + '.' +
                             FieldByName('S_Name').AsString;
        //xxxxxx

        EditCus.Text      := FieldByName('Z_Customer').AsString + '.' +
                             FieldByName('C_Name').AsString;
        //xxxxxx
      end;
    end;

    LoadContract(EditCID.Text, nQuery);
    //加载合同

    nStr := 'Select * From %s Where D_ZID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, FParam.FParamB);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        nStr := FieldByName('D_StockNo').AsString;
        for nIdx := 0 to Grid1.RowCount-1 do
        if Grid1.Cells[0, nIdx = nStr then //编号匹配
        begin
          Grid1.Cells[giValue, nIdx := FieldByName('D_Value').AsString;
          Grid1.Cells[giPrice, nIdx := FieldByName('D_Price').AsString;
          Grid1.Cells[giFLPrice, nIdx := FieldByName('D_FLPrice').AsString;
          Grid1.Cells[giYunFei, nIdx := FieldByName('D_YunFei').AsString;
          Grid1.Cells[giCheck, nIdx := sCheckFlag;
          Break;
        end;

        Next;
      end;
    end;
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Date: 2018-05-05
//Parm: 合同编号;查询对象
//Desc: 加载编号为nCID的合同数据
procedure TfFormZhiKa.LoadContract(const nCID: string; const nQuery: TADOQuery);
var nStr: string;
    nIdx: Integer;
    nBool: Boolean;
    nC: TADOQuery;
begin
  nC := nil;
  with TStringHelper do
  try
    if Assigned(nQuery) then
         nC := nQuery
    else nC := LockDBQuery(FDBType);

    nBool := FParam.FCommand <> cCmd_EditData;
    if nBool then //修改时无需记载
    begin
      nStr := 'Select sc.*,sm.S_Name,sm.S_PY,cus.C_Name as CusName,' +
              '$Now as S_Now From $SC sc' +
              ' Left Join $SM sm On sm.S_ID=sc.C_SaleMan' +
              ' Left Join $Cus cus On cus.C_ID=sc.C_Customer ' +
              'Where sc.C_ID=''$ID''';
      nStr := MacroValue(nStr, [MI('$SC', sTable_SaleContract),
              MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
              MI('$ID', nCID), MI('$Now', sField_SQLServer_Now));
      //xxxxx

      with DBQuery(nStr, nC) do
      if RecordCount > 0 then
      begin
        FParam.FParamC := nCID;
        nBool := FieldByName('C_XuNi').AsString = sFlag_Yes;
        EditSaleMan.ReadOnly := nBool;
        EditCus.ReadOnly := nBool;

        nStr := FieldByName('C_SaleMan').AsString + '.' +
                FieldByName('S_Name').AsString;
        if EditSaleMan.Items.IndexOf(nStr) < 0 then
          EditSaleMan.Items.Add(nStr);
        //xxxxx

        nStr := FieldByName('C_SaleMan').AsString;
        EditSaleMan.ItemIndex := StrListIndex(nStr, EditSaleMan.Items, 0, '.');

        nStr := FieldByName('C_Customer').AsString + '.' +
                FieldByName('CusName').AsString;
        if EditCus.Items.IndexOf(nStr) < 0 then
          EditCus.Items.Add(nStr);
        //xxxxx

        nStr := FieldByName('C_Customer').AsString;
        EditCus.ItemIndex := StrListIndex(nStr, EditCus.Items, 0, '.');

        EditDays.DateTime := FieldByName('S_Now').AsFloat +
                             FieldByName('C_ZKDays').AsInteger;
        //当前 + 时长
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := 'Select * From %s Where E_CID=''%s''';
    nStr := Format(nStr, [sTable_SContractExt, nCID);

    with DBQuery(nStr, nC) do
    if RecordCount > 0 then
    begin
      if FParam.FParamC = '' then
        FParam.FParamC := nCID;
      //xxxxx
      
      Grid1.RowCount := RecordCount;
      nIdx := 0;
      First;

      while not Eof do
      begin
        Grid1.Cells[giID, nIdx := FieldByName('E_StockNo').AsString;
        Grid1.Cells[giName, nIdx := FieldByName('E_StockName').AsString;
        Grid1.Cells[giPrice, nIdx := FieldByName('E_Price').AsString;
        Grid1.Cells[giFLPrice, nIdx := '0';
        Grid1.Cells[giYunFei, nIdx := '0';
        Grid1.Cells[giValue, nIdx := '0';
        Grid1.Cells[giType, nIdx := FieldByName('E_Type').AsString;

        Inc(nIdx);
        Next;
      end;
    end;
  finally
    if not Assigned(nQuery) then
      ReleaseDBQuery(nC);
    //xxxxx
  end;
end;

procedure TfFormZhiKa.Grid1Click(Sender: TObject);
begin
  if Grid1.Col = giCheck then
  begin
    if Grid1.Cells[giCheck, Grid1.Row = sCheckFlag then
         Grid1.Cells[giCheck, Grid1.Row := ''
    else Grid1.Cells[giCheck, Grid1.Row := sCheckFlag;
  end;
end;

//Desc: 业务员变更,选择客户
procedure TfFormZhiKa.EditSaleManChange(Sender: TObject);
var nStr: string;
begin
  nStr := GetIDFromBox(EditSaleMan);
  if nStr = '' then
  begin
    EditCus.Items.Clear;
    Exit;
  end;

  nStr := Format('C_SaleMan=''%s''', [nStr);
  LoadCustomer(EditCus.Items, nStr);
end;

//Desc: 加载合同
procedure TfFormZhiKa.EditCIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditCID.Text := Trim(EditCID.Text);

    if EditCID.Text <> '' then
      LoadContract(EditCID.Text, nil);
    //xxxxx
  end;
end;

//Desc: 选择客户
procedure TfFormZhiKa.EditCusKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    ShowGetCustomerForm(GetNameFromBox(EditCus),
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

//Desc: 选择合同
procedure TfFormZhiKa.BtnGetContractClick(Sender: TObject);
begin
  ShowGetContractForm(
    procedure(const nResult: Integer; const nParam: PFormCommandParam)
    begin
      if nParam.FParamA <> '' then
      begin
        EditCID.Text := nParam.FParamA;
        LoadContract(nParam.FParamA, nil);
      end;
    end);
  //xxxxx
end;

procedure TfFormZhiKa.BtnOKClick(Sender: TObject);
var nStr,nID,nVerify: string;
    nIdx: Integer;
    nBool: Boolean;
    nList: TStrings;
    nQuery: TADOQuery;
begin            
  if FParam.FParamC = '' then
  begin
    ShowMessage('请填写合同编号'); 
    Exit;
  end;

  nID := GetIDFromBox(EditCus);
  if (nID = '') or ((not EditCus.ReadOnly) and (EditCus.ItemIndex < 0)) then
  begin
    ShowMessage('请选择客户'); 
    Exit;
  end;

  if EditDays.DateTime <= Date() then
  begin
    ShowMessage('请填写有效的时长'); 
    Exit;
  end;

  with TStringHelper do
  if (not IsNumber(EditMoney.Text, True)) or
     (StrToFloat(EditMoney.Text) < 0) then
  begin
    ShowMessage('预付金额是数值');
    Exit;
  end;

  for nIdx := 0 to Grid1.RowCount - 1 do
  with TStringHelper do
  begin
    if Grid1.Cells[giCheck, nIdx <> sCheckFlag then Continue;
    if (not IsNumber(Grid1.Cells[giPrice, nIdx, True)) or
       (StrToFloat(Grid1.Cells[giPrice, nIdx) <= 0) then
    begin
      nStr := '品种[ %s 单价无效.';
      ShowMessage(Format(nStr, [Grid1.Cells[giName, nIdx));
      Exit;
    end;

    if not IsNumber(Grid1.Cells[giFLPrice, nIdx, True) then
    begin
      nStr := '品种[ %s 返利价差无效.';
      ShowMessage(Format(nStr, [Grid1.Cells[giName, nIdx));
      Exit;
    end;

    if (not IsNumber(Grid1.Cells[giYunFei, nIdx, True)) or
       (StrToFloat(Grid1.Cells[giYunFei, nIdx) < 0) then
    begin
      nStr := '品种[ %s 运费无效.';
      ShowMessage(Format(nStr, [Grid1.Cells[giName, nIdx));
      Exit;
    end;
  end;

  nList := nil;
  nQuery := nil;
  with TSQLBuilder,TStringHelper,TDateTimeHelper do
  try
    nBool := FParam.FCommand <> cCmd_EditData;
    if nBool then
    begin
      nID := GetSerialNo(sFlag_BusGroup, sFlag_ZhiKa, False);
      if nID = '' then Exit;      
    end else nID := FParam.FParamB;
    //new id

    nVerify := sFlag_Yes;
    if nBool then
    begin
      nQuery := LockDBQuery(FDBType);
      if IsZhiKaNeedVerify(nQuery) then
        nVerify := sFlag_No;
      //xxxxx
    end;

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;    
    nStr := SF('R_ID', FParam.FParamA, sfVal);

    nStr := MakeSQLByStr([
      SF_IF([SF('Z_ID', nID), '', nBool),
      SF('Z_Name', EditName.Text),
      SF('Z_CID', FParam.FParamC),
      SF('Z_Project', EditProject.Text),
      SF('Z_Payment', EditPayment.Text),
      
      SF('Z_Lading', GetIDFromBox(EditLading)),
      SF('Z_ValidDays', Date2Str(EditDays.DateTime)),
      SF('Z_YFMoney', EditMoney.Text, sfVal),
      SF('Z_Man', UniMainModule.FUserConfig.FUserID),
      SF('Z_Date', sField_SQLServer_Now, sfVal),
      
      SF_IF([SF('Z_Customer', GetIDFromBox(EditCus)), '', nBool),
      SF_IF([SF('Z_SaleMan', GetIDFromBox(EditSaleMan)), '', nBool),
      SF_IF([SF('Z_Verified', nVerify), '', nBool)
      , sTable_ZhiKa, nStr, nBool);
    nList.Add(nStr);

    if not nBool then
    begin
      nStr := 'Delete From %s Where D_ZID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKaDtl, nID);
      nList.Add(nStr);
    end;

    for nIdx:=0 to Grid1.RowCount-1 do
    begin
      if Grid1.Cells[giCheck, nIdx <> sCheckFlag then Continue;
      //no selected

      nStr := MakeSQLByStr([SF('D_ZID', nID),
              SF('D_Type', Grid1.Cells[giType, nIdx),
              SF('D_StockNo', Grid1.Cells[giID, nIdx),
              SF('D_StockName', Grid1.Cells[giName, nIdx),
              SF('D_Price', Grid1.Cells[giPrice, nIdx, sfVal),
              SF('D_FLPrice', Grid1.Cells[giFLPrice, nIdx, sfVal),
              SF('D_YunFei', Grid1.Cells[giYunFei, nIdx, sfVal),

              SF_IF([SF('D_Value', Grid1.Cells[giValue, nIdx, sfVal),
                     'D_Value=0', IsNumber(Grid1.Cells[giValue, nIdx, True))
              //xxxxx
              , sTable_ZhiKaDtl, '', True);
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
  RegisterClass(TfFormZhiKa);
end.
