{*******************************************************************************
  作者: dmzn@163.com 2018-05-06
  描述: 纸卡办理明细查询
*******************************************************************************}
unit UFrameZhiKaDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  ULibFun, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu, uniMultiItem,
  uniComboBox, uniButton, uniBitBtn, uniEdit, uniLabel, Data.DB,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameZhiKaDetail = class(TfFrameBase)
    Label1: TUniLabel;
    EditID: TUniEdit;
    Label2: TUniLabel;
    EditCus: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItem1: TUniMenuItem;
    MenuItem2: TUniMenuItem;
    MenuItem8: TUniMenuItem;
    MenuItem4: TUniMenuItem;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    MenuItem5: TUniMenuItem;
    MenuItem6: TUniMenuItem;
    MenuItem7: TUniMenuItem;
    MenuItem3: TUniMenuItem;
    MenuItemN3: TUniMenuItem;
    MenuItem11: TUniMenuItem;
    MenuItem12: TUniMenuItem;
    MenuItemN2: TUniMenuItem;
    MenuItem9: TUniMenuItem;
    MenuItem10: TUniMenuItem;
    MenuItem13: TUniMenuItem;
    MenuItem14: TUniMenuItem;
    Label4: TUniLabel;
    EditStock: TUniComboBox;
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure EditStockChange(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure DBGridMainDrawColumnCell(Sender: TObject; ACol, ARow: Integer;
      Column: TUniDBGridColumn; Attribs: TUniCellAttribs);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*时间区间*}
    FDateFilte: Boolean;
    //启用区间
    FValidFilte: Boolean;
    //启用有效状态
    FStockList: TStringHelper.TDictionaryItems;
    //品种列表
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
    procedure OnFreeByStock(const nStocks: string);
    //按品种冻结
    procedure OnZKPrice(const nRes: Integer);
    //调价结果
    procedure LoadStockList;
    function GetStockID: string;
    //品种列表
    function FreezeZK(const nFreeze: Boolean): Boolean;
    //冻结选中提货单
    procedure SelectedZK(const nList: TStrings);
    //获取选中纸卡号
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    procedure AfterInitFormData; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  UManagerGroup, USysBusiness, UFormBase, USysDB, USysConst,
  UFormDateFilter, UFormZhiKaFreeze, UFormZhiKaPrice, UFormSysLog;

procedure TfFrameZhiKaDetail.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  FDateFilte := False;
  FValidFilte := True;

  MenuItem2.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem3.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem4.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);

  MenuItem6.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem9.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem10.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);

  InitDateRange(ClassName, FStart, FEnd);
  LoadStockList;
end;

procedure TfFrameZhiKaDetail.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameZhiKaDetail.OnLoadGridConfig(const nIni: TIniFile);
begin
  inherited;
  with DBGridMain do
  begin
    if UniMainModule.FGridColumnAdjust then
         Options := Options + [dgMultiSelect]
    else Options := Options + [dgMultiSelect, dgCheckSelect];
  end;
end;

//Desc: 日期选择窗返回结果
procedure TfFrameZhiKaDetail.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

//Desc: 按品种冻结返回结果
procedure TfFrameZhiKaDetail.OnFreeByStock(const nStocks: string);
begin
  InitFormData(FWhere);
end;

//Desc: 纸卡调价结果
procedure TfFrameZhiKaDetail.OnZKPrice(const nRes: Integer);
begin
  InitFormData(FWhere);
end;

function TfFrameZhiKaDetail.InitFormDataSQL(const nWhere: string): string;
var nNo: string;
begin
  with TStringHelper,TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    //xxxxx

    Result := 'Select sm.*,zk.*,zd.*,ht.*,zd.R_ID as D_RID,' +
              'C_PY,C_Name,D_Price-D_PPrice As D_ZDPrice From $ZK zk ' +
              ' Left Join $SM sm on sm.S_ID=zk.Z_SaleMan' +
              ' Left Join $Cus cus on cus.C_ID=zk.Z_Customer' +
              ' Left Join $ZD zd on zd.D_ZID=zk.Z_ID ' +
              ' Left join $HT ht on zk.Z_CID=ht.C_ID ';
    //xxxxx

    if nWhere = '' then
         Result := Result + ' Where (1 = 1)'
    else Result := Result + ' Where (' + nWhere + ')';

    if FValidFilte then
      Result := Result + ' and (IsNull(Z_InValid, '''')<>''$Yes''' +
                         ' and Z_ValidDays>$Now)';
    //xxxxx

    if FDateFilte then
      Result := Result + ' and (Z_Date>=''$STT'' and Z_Date<''$End'')';
    //xxxxx

    nNo := GetStockID;
    if nNo <> '' then
      Result := Result + ' and (zd.D_StockNo=''$No'')';
    //xxxxx

    Result := MacroValue(Result, [MI('$ZK', sTable_ZhiKa), MI('$Yes', sFlag_Yes),
              MI('$ZD', sTable_ZhiKaDtl), MI('$SM', sTable_Salesman),
              MI('$Cus', sTable_Customer), MI('$Now', sField_SQLServer_Now),
              MI('$STT', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)),
              MI('$HT', sTable_SaleContract), MI('$No', nNo)]);
    //xxxxx
  end;
end;

procedure TfFrameZhiKaDetail.AfterInitFormData;
begin
  FDateFilte := False;
  FValidFilte := True;
end;

//Desc: 读取品种列表
procedure TfFrameZhiKaDetail.LoadStockList;
var nStr: string;
    nIdx: Integer;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  try
    with EditStock.Items do
    begin
      BeginUpdate;
      Clear;
      Add('全部显示');
    end;

    SetLength(FStockList, 0);
    nQuery := LockDBQuery(FDBType);

    nStr := 'Select D_Value,D_Memo,D_ParamB From %s ' +
            'Where D_Name=''%s'' Order By D_Index ASC';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      SetLength(FStockList, RecordCount);
      nIdx := 0;
      First;

      while not Eof do
      begin
        with FStockList[nIdx] do
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
      EditStock.Items.AddObject(FStockList[nIdx].FValue, Pointer(nIdx));
    EditStock.ItemIndex := 0;
  finally
    EditStock.Items.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

//Desc: 获取选中的品种
function TfFrameZhiKaDetail.GetStockID: string;
var nIdx: Integer;
begin
  Result := '';
  if EditStock.ItemIndex < 1 then Exit;

//  if not (FDateFilte and FValidFilte) then     //
//  begin
//    EditStock.ItemIndex := 0;
//    Exit;
//  end;

  nIdx := NativeInt(EditStock.Items.Objects[EditStock.ItemIndex]);
  Result := FStockList[nIdx].FKey;
end;

procedure TfFrameZhiKaDetail.BtnRefreshClick(Sender: TObject);
begin
  EditStock.ItemIndex := 0;
  inherited;
end;

//Desc: 品种切换
procedure TfFrameZhiKaDetail.EditStockChange(Sender: TObject);
begin
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameZhiKaDetail.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

//Desc: 刷新
procedure TfFrameZhiKaDetail.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FDateFilte := Length(EditID.Text) <= 3;
    FValidFilte := False;

    FWhere := Format('Z_ID Like ''%%%s%%''', [EditID.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := Format('C_PY Like ''%%%s%%'' or C_Name Like ''%%%s%%''',
              [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameZhiKaDetail.DBGridMainDrawColumnCell(Sender: TObject; ACol,
  ARow: Integer; Column: TUniDBGridColumn; Attribs: TUniCellAttribs);
begin
  if (Column.FieldName='Z_TJStatus') then
  begin
    if ClientDS.FieldByName('Z_TJStatus').AsString='T' then
    begin
      Attribs.Font.Color := $ffcc00;
      //Attribs.Color := clWhite;
    end
  end
  else
  begin
    Attribs.Font.Color := clBlack;
    //Attribs.Color := clWhite;
  end;
end;

procedure TfFrameZhiKaDetail.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 冻结,解冻
procedure TfFrameZhiKaDetail.MenuItem2Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: if not FreezeZK(True) then Exit;
   20: if not FreezeZK(False) then Exit;
   30: begin
         FValidFilte := False;
         FWhere := 'Z_InValid=''$Yes'' Or Z_ValidDays<=%s';
         FWhere := Format(FWhere, [sField_SQLServer_Now]);
       end;
   40: begin
         FValidFilte := False;
         FWhere := '1=1';
       end;
   50: begin
         FDateFilte := False;
         FValidFilte := False;
         FWhere := Format('Z_TJStatus=''%s''', [sFlag_TJing]);
       end else Exit;
  end;

  InitFormData(FWhere);
end;

//Desc: 参与调价
procedure TfFrameZhiKaDetail.MenuItem9Click(Sender: TObject);
var nIdx,nLen: Integer;
    nList: TStrings;
    nStr,nRID,nFlag: string;
    nBK: TBookmark;
begin
  nLen := DBGridMain.SelectedRows.Count - 1;
  if nLen < 0 then Exit;

  nBK := nil;
  nList := nil;
  try
    if TComponent(Sender).Tag = 10 then
         nFlag := sFlag_Yes
    else nFlag := sFlag_No;

    ClientDS.DisableControls;
    nBK := ClientDS.GetBookmark; //backup
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;

    for nIdx:=DBGridMain.SelectedRows.Count - 1 downto 0 do
    begin
      ClientDS.Bookmark := DBGridMain.SelectedRows[nIdx];
      nRID := ClientDS.FieldByName('D_RID').AsString;
      if nRID = '' then Continue;

      nStr := 'Update %s Set D_TPrice=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZhiKaDtl, nFlag, nRID]);
      nList.Add(nStr);
    end;

    DBExecute(nList, nil, FDBType);
    //write
  finally
    gMG.FObjectPool.Release(nList);
    //xxxxx

    if Assigned(nBK) then
    begin
      if ClientDS.BookmarkValid(nBK) then
        ClientDS.GotoBookmark(nBK); //restore
      ClientDS.FreeBookmark(nBK);
    end;

    ClientDS.EnableControls;
    InitFormData(FWhere);
    //reload
  end;
end;

//Desc: 按品种冻结
procedure TfFrameZhiKaDetail.MenuItem4Click(Sender: TObject);
begin
  ShowZKFreezeForm(OnFreeByStock);
end;

//Desc: 获取选中纸卡列表
procedure TfFrameZhiKaDetail.SelectedZK(const nList: TStrings);
var nIdx: Integer;
    nBK: TBookmark;
begin
  nList.Clear;
  nBK := nil;
  try
    ClientDS.DisableControls;
    nBK := ClientDS.GetBookmark;
    //backup

    for nIdx:=DBGridMain.SelectedRows.Count - 1 downto 0 do
    begin
      ClientDS.Bookmark := DBGridMain.SelectedRows[nIdx];
      nList.Add(ClientDS.FieldByName('Z_ID').AsString);
    end;
  finally
    if Assigned(nBK) then
    begin
      if ClientDS.BookmarkValid(nBK) then
        ClientDS.GotoBookmark(nBK); //restore
      ClientDS.FreeBookmark(nBK);
    end;
    ClientDS.EnableControls;
  end;
end;

//Desc: 冻结当前选中的提货单
function TfFrameZhiKaDetail.FreezeZK(const nFreeze: Boolean): Boolean;
var nStr: string;
    nIdx: Integer;
    nListA,nListB: TStrings;
begin
  Result := False;
  if DBGridMain.SelectedRows.Count < 1 then Exit;

  nListA := nil;
  nListB := nil;
  try
    nListA := gMG.FObjectPool.Lock(TStrings) as TStrings;
    SelectedZK(nListA);
    if nListA.Count < 1 then Exit;

    nListB := gMG.FObjectPool.Lock(TStrings) as TStrings;
    for nIdx:=nListA.Count - 1 downto 0 do
    begin
      if nFreeze then
      begin
        nStr := 'Update %s Set Z_TJStatus=''%s'' Where Z_ID=''%s'' and ' +
                'IsNull(Z_InValid,'''')<>''%s'' And Z_ValidDays>%s';
        nStr := Format(nStr, [sTable_ZhiKa, sFlag_TJing, nListA[nIdx],
                sFlag_Yes, sField_SQLServer_Now]);
        nListB.Add(nStr); //调价中
      end else
      begin
        nStr := 'Update %s Set Z_TJStatus=''%s'' Where Z_ID=''%s'' and ' +
                'Z_TJStatus=''%s''';
        nStr := Format(nStr, [sTable_ZhiKa, sFlag_TJOver, nListA[nIdx],
                sFlag_TJing]);
        nListB.Add(nStr); //调价结束
      end;
    end;

    DBExecute(nListB, nil, FDBType);
    Result := True;
  finally
    gMG.FObjectPool.Release(nListA);
    gMG.FObjectPool.Release(nListB);
  end;
end;

//Desc: 调价
procedure TfFrameZhiKaDetail.MenuItem6Click(Sender: TObject);
var nIdx,nLen: Integer;
    nList: TStrings;
    nBK: TBookmark;
    nStr,nRID,nZID,nStock,nType: string;
begin
  nLen := DBGridMain.SelectedRows.Count - 1;
  if nLen < 0 then Exit;

  nBK := nil;
  nList := nil;
  try
    ClientDS.DisableControls;
    nBK := ClientDS.GetBookmark;
    //backup

    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nLen := DBGridMain.SelectedRows.Count - 1;

    for nIdx:= 0 to nLen do
    begin
      ClientDS.Bookmark := DBGridMain.SelectedRows[nIdx];
      nRID := ClientDS.FieldByName('D_RID').AsString;
      nZID := ClientDS.FieldByName('Z_ID').AsString;
      if (nRID = '') or (nZID = '') then Continue;

      nStr := ClientDS.FieldByName('Z_TJStatus').AsString;
      if nStr <> sFlag_TJing then
      begin
        nStr := '调价前需要冻结纸卡,记录[ %s ]不符合要求.';
        nStr := Format(nStr, [nRID]);
        ShowMessage(nStr); Exit;
      end;

      if nIdx = 0 then
      begin
        nType := ClientDS.FieldByName('D_Type').AsString;
        nStock := ClientDS.FieldByName('D_StockNO').AsString;
      end else
      begin
        if (ClientDS.FieldByName('D_Type').AsString <> nType) or
           (ClientDS.FieldByName('D_StockNO').AsString <> nStock) then
        begin
          nStr := '只有同品种的水泥才能统一调价,记录[ %s ]不符合要求.';
          nStr := Format(nStr, [nRID]);
          ShowMessage(nStr); Exit;
        end;
      end;

      nStr := Format('%s;%s;%s;%s;%s', [nRID,
              ClientDS.FieldByName('D_Price').AsString,
              nZID, nStock, ClientDS.FieldByName('D_StockName').AsString]);
      nList.Add(nStr);
    end;

    if nList.Count < 1 then
    begin
      ShowMessage('选中记录无效'); Exit;
    end;

    ShowZKPriceForm(nList.Text, OnZKPrice);
    //执行调价
  finally
    gMG.FObjectPool.Release(nList);
    //xxxxx

    if Assigned(nBK) then
    begin
      if ClientDS.BookmarkValid(nBK) then
        ClientDS.GotoBookmark(nBK); //restore
      ClientDS.FreeBookmark(nBK);
    end;

    ClientDS.EnableControls;
  end;
end;

//Desc: 调价记录
procedure TfFrameZhiKaDetail.MenuItem7Click(Sender: TObject);
var nStr: string;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    nParam.FCommand := cCmd_ViewSysLog;
    nParam.FParamA := '2008-08-08';
    nParam.FParamB := '2050-12-12';

    nParam.FParamC := ClientDS.FieldByName('Z_ID').AsString;
    nStr := 'L_Group=''$Group'' And L_ItemID=''$ID''';
    with TStringHelper do
    nParam.FParamD := MacroValue(nStr, [MI('$Group', sFlag_ZhiKaItem),
                      MI('$ID', nParam.FParamC)]);
    //检索条件

    ShowSystemLog(nParam);
  end;
end;

initialization
  RegisterClass(TfFrameZhiKaDetail);
end.
