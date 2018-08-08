{*******************************************************************************
  作者: dmzn@163.com 2018-07-03
  描述: 价格区间
*******************************************************************************}
unit UFormPriceRule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Data.Win.ADODB, USysConst, UFormBase, uniBasicGrid,
  uniDBGrid, Data.DB, Datasnap.DBClient, uniEdit, uniLabel, uniGUIClasses,
  uniMultiItem, uniComboBox, uniPanel, uniGUIBaseClasses, uniButton;

type
  TfFormPriceRule = class(TfFormBase)
    EditStock: TUniComboBox;
    UniLabel1: TUniLabel;
    UniLabel2: TUniLabel;
    EditLow: TUniEdit;
    UniLabel3: TUniLabel;
    EditHigh: TUniEdit;
    BtnDel: TUniButton;
    DataSource1: TDataSource;
    ClientDS: TClientDataSet;
    DBGrid1: TUniDBGrid;
    BtnAdd: TUniButton;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure UniFormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FChanged: Boolean;
    //数据变更
    FStockList: TStockItems;
    //水泥列表
    procedure LoadStockList(const nQuery: TADOQuery);
    procedure LoadPriceList(const nQuery: TADOQuery);
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, uniGUITypes,
  System.IniFiles, UManagerGroup, ULibFun, USysBusiness, USysDB;

procedure TfFormPriceRule.OnCreateForm(Sender: TObject);
var nIni: TIniFile;
    nQuery: TADOQuery;
begin
  nIni := nil;
  try
    ActiveControl := EditStock;
    nIni := UserConfigFile();
    LoadFormConfig(Self, nIni);

    BuildDBGridColumn('', DBGrid1);
    UserDefineGrid(ClassName, DBGrid1, True, nIni);
  finally
    nIni.Free;
  end;

  FDBType := ctMain;
  FChanged := False;

  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    LoadPriceList(nQuery);
    LoadStockList(nQuery);
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormPriceRule.UniFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FChanged then
    ModalResult := mrOk;
  //xxxxx
end;

procedure TfFormPriceRule.LoadPriceList(const nQuery: TADOQuery);
var nStr: string;
begin
  nStr := 'Select * From %s Where R_Valid=''%s'' Order By R_Date DESC';
  nStr := Format(nStr, [sTable_PriceRule, sFlag_Yes]);
  DBQuery(nStr, nQuery, ClientDS);
end;

procedure TfFormPriceRule.LoadStockList(const nQuery: TADOQuery);
var nStr: string;
    nIdx: Integer;
begin
  if Length(FStockList) < 1 then
    LoadStockFromDict(FStockList, nQuery, FDBType);
  //xxxxx

  for nIdx := Low(FStockList) to High(FStockList) do
    FStockList[nIdx].FSelected := True;
  EditStock.Clear;

  if ClientDS.Active and (ClientDS.RecordCount > 0) then
  try
    ClientDS.DisableControls;
    ClientDS.First;

    while not ClientDS.Eof do
    begin
      nStr := ClientDS.FieldByName('R_StockNo').AsString;
      for nIdx := Low(FStockList) to High(FStockList) do
       if FStockList[nIdx].FID = nStr then
       begin
         FStockList[nIdx].FSelected := False;
         Break;
       end;

      ClientDS.Next;
    end;
  finally
    ClientDS.EnableControls;
  end;

  for nIdx := Low(FStockList) to High(FStockList) do
   if FStockList[nIdx].FSelected then
    EditStock.Items.AddObject(FStockList[nIdx].FName, Pointer(nIdx));
  //xxxxx

  if EditStock.Items.Count > 0 then
    EditStock.ItemIndex := 0;
  //xxxxx
end;

procedure TfFormPriceRule.BtnAddClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  if EditStock.ItemIndex < 0 then
  begin
    ShowMessage('请选择水泥名称');
    Exit;
  end;

  with TStringHelper do
  if not (IsNumber(EditLow.Text) and IsNumber(EditHigh.Text) and (
    StrToFloat(EditLow.Text) <= StrToFloat(EditHigh.Text))) then
  begin
    ShowMessage('请填写价格区间: 价格下限 - 价格上限');
    Exit;
  end;

  nQuery := nil;
  nList := nil;
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    nIdx := NativeInt(EditStock.Items.Objects[EditStock.ItemIndex]);

    nStr := 'Update %s Set R_Valid=''%s'' ' +
            'Where R_StockNo=''%s'' And R_Valid=''%s''';
    nStr := Format(nStr, [sTable_PriceRule, sFlag_No,
            FStockList[nIdx].FID, sFlag_Yes]);
    nList.Add(nStr);

    with TSQLBuilder do
    nStr := MakeSQLByStr([SF('R_StockNo', FStockList[nIdx].FID),
            SF('R_StockName', FStockList[nIdx].FName),
            SF('R_Low', EditLow.Text),
            SF('R_High', EditHigh.Text),
            SF('R_Valid', sFlag_Yes),
            SF('R_Man', UniMainModule.FUserConfig.FUserID),
            SF('R_Date', sField_SQLServer_Now, sfVal)
            ], sTable_PriceRule, '', True);
    nList.Add(nStr);

    nQuery := LockDBQuery(FDBType);
    DBExecute(nList, nQuery, FDBType);
    FChanged := True;

    LoadPriceList(nQuery);
    LoadStockList(nQuery);
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormPriceRule.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
    nQuery: TADOQuery;
begin
  if DBGrid1.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要删除的记录');
    Exit;
  end;

  nStr := ClientDS.FieldByName('R_StockName').AsString;
  nStr := Format('确定要删除[ %s ]的价格吗?', [nStr]);
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res <> mrYes then Exit;
      //cancel

      nStr := ClientDS.FieldByName('R_ID').AsString;
      nSQL := 'Update %s Set R_Valid=''%s'' Where R_ID=%s';
      nSQL := Format(nSQL, [sTable_PriceRule, sFlag_No, nStr]);

      nQuery := nil;
      try
        nQuery := LockDBQuery(FDBType);
        DBExecute(nSQL, nQuery, FDBType);
        FChanged := True;

        LoadPriceList(nQuery);
        LoadStockList(nQuery);
      finally
        ReleaseDBQuery(nQuery);
      end;
    end);
end;

initialization
  RegisterClass(TfFormPriceRule);
end.
