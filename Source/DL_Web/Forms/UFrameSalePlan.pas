unit UFrameSalePlan;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UFrameBase, uniPanel, uniPageControl, System.IniFiles,
  frxClass, frxExportPDF, frxDBSet, Data.DB, Datasnap.DBClient, uniGUIClasses,
  uniBasicGrid, uniDBGrid, uniToolBar, uniGUIBaseClasses, Data.Win.ADODB,
  uniEdit, uniLabel;

type
  TfFrameSalePlan = class(TfFrameBase)
    unpgcntrl1: TUniPageControl;
    unSht_1: TUniTabSheet;
    unSht_2: TUniTabSheet;
    unDB_Stock: TUniDBGrid;
    unDB_StockCus: TUniDBGrid;
    Ds_Mx: TDataSource;
    Ds_StockCus: TClientDataSet;
    UnLblLabel1: TUniLabel;
    EditStock: TUniEdit;
    UnLblLabel2: TUniLabel;
    EditCustomer: TUniEdit;
    procedure unpgcntrl1Change(Sender: TObject);
    procedure EditStockKeyPress(Sender: TObject; var Key: Char);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
                        const nQuery: TADOQuery = nil); override;
  public
    { Public declarations }
  end;

var
  fFrameSalePlan: TfFrameSalePlan;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, uniGUIForm, UFormBase, UManagerGroup,
  USysBusiness, USysDB, USysConst, UFormDateFilter, UBusinessPacker, ULibFun;


procedure TfFrameSalePlan.OnLoadGridConfig(const nIni: TIniFile);
begin
  BuildDBGridColumn(FEntity, unDB_Stock, FilterColumnField()); //构建表头
  UserDefineGrid(ClassName, unDB_Stock, True, nIni);
  //自定义表头配置


  BuildDBGridColumn('MAIN_DXLMX', unDB_StockCus, FilterColumnField());
  //构建表头
  UserDefineGrid(ClassName, unDB_StockCus, True, nIni);
  //自定义表头配置
end;

procedure TfFrameSalePlan.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormSalePlan', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_AddData;
  if unpgcntrl1.ActivePageIndex=0 then
    nParam.FParamA:= 'Stock'
  else nParam.FParamA:= 'Customer';
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
end;

procedure TfFrameSalePlan.BtnDelClick(Sender: TObject);
var nStr, nSQL: string;
begin
  if unpgcntrl1.ActivePageIndex=0 then
  if unDB_Stock.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  if unpgcntrl1.ActivePageIndex=1 then
  if unDB_StockCus.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nStr := Format('确定要删除该条设置么?', [nStr]);
  MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      begin
        if Res <> mrYes then Exit;
        //cancel

        try
          if unpgcntrl1.ActivePageIndex=0 then
          begin
            nStr := ClientDS.FieldByName('R_ID').AsString;
            nSQL := 'Delete From %s Where R_ID=''%s''';
            nSQL := Format(nSQL, [sTable_SalePlanStock, nStr]);
          end
          else
          begin
            nStr := Ds_StockCus.FieldByName('R_ID').AsString;
            nSQL := 'Delete From %s Where R_ID=''%s''';
            nSQL := Format(nSQL, [sTable_SalePlanCustomer, nStr]);
          end;

          DBExecute(nSQL, nil, FDBType);

          InitFormData(FWhere);
          ShowMessage('已成功删除记录');
        except
          on nErr: Exception do
          begin
            ShowMessage('删除失败: ' + nErr.Message);
          end;
        end;
      end);
end;

procedure TfFrameSalePlan.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
    nStr  : string;
begin
  if unpgcntrl1.ActivePageIndex=0 then
  if unDB_Stock.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  if unpgcntrl1.ActivePageIndex=1 then
  if unDB_StockCus.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  if unpgcntrl1.ActivePageIndex=0 then
  begin
    nParam.FParamA := 'Stock';
    nParam.FParamB := ClientDS.FieldByName('R_ID').AsString;
    nParam.FParamC := ClientDS.FieldByName('S_StockName').AsString;
    nParam.FParamD := ClientDS.FieldByName('S_Value').AsString;
    nParam.FParamE := ClientDS.FieldByName('S_ProhibitCreateBill').AsString;
    ///  是否禁止未设置供应计划客户开单
  end
  else
  begin
    nParam.FParamA := 'Customer';
    nParam.FParamB := Ds_StockCus.FieldByName('R_ID').AsString;
    nParam.FParamC := Ds_StockCus.FieldByName('C_StockName').AsString;
    nStr:= Ds_StockCus.FieldByName('C_SManName').AsString+'@';
    nParam.FParamD := nStr + Ds_StockCus.FieldByName('C_CusNo').AsString;
    nParam.FParamE := Ds_StockCus.FieldByName('C_MaxValue').AsString;
  end;

  nForm := SystemGetForm('TfFormSalePlan', True);
  if not Assigned(nForm) then Exit;

  if unpgcntrl1.ActivePageIndex=0 then
    nParam.FParamA:= 'Stock'
  else nParam.FParamA:= 'Customer';
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
end;

procedure TfFrameSalePlan.EditStockKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  EditCustomer.Text := Trim(EditCustomer.Text);
  if EditCustomer.Text <> '' then
  begin
    unpgcntrl1.ActivePageIndex:= 1;

    FWhere := ' C_CusName like ''%%%s%%'' ';
    FWhere := Format(FWhere, [EditCustomer.Text]);
  end;

  EditStock.Text := Trim(EditStock.Text);
  if EditStock.Text <> '' then
  begin
    if FWhere<>'' then
      FWhere := FWhere + ' And ';

    if unpgcntrl1.ActivePageIndex=0 then
      FWhere := FWhere + ' S_StockName like ''%' + EditStock.Text + '%'' '
    else
    begin
      FWhere := FWhere + ' C_StockName like ''%' + EditStock.Text + '%'' ';
    end;
  end;

  InitFormData(FWhere);
end;

procedure TfFrameSalePlan.unpgcntrl1Change(Sender: TObject);
begin
  InitFormData('');
end;

procedure TfFrameSalePlan.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
    nQry: TADOQuery;
begin
  with TStringHelper do
  begin
    nQry := nil;
    try
      if Assigned(nQuery) then
           nQry := nQuery
      else nQry := LockDBQuery(FDBType);

      if unpgcntrl1.ActivePageIndex=0 then
      begin
        nStr := ' Select * From  $SalePlanStock ';
      end
      else
      begin
        nStr := ' Select * From $SalePlanCustomer ';
      end;

      if nWhere <> '' then
         nStr := nStr + ' Where (' + nWhere + ')';

      nStr := MacroValue(nStr, [MI('$SalePlanStock', sTable_SalePlanStock),
                                    MI('$SalePlanCustomer', sTable_SalePlanCustomer)]);
      //xxxxx
      if unpgcntrl1.ActivePageIndex=0 then
          DBQuery(nStr, nQry, ClientDS)
      else DBQuery(nStr, nQry, Ds_StockCus);
    finally
      if not Assigned(nQuery) then
        ReleaseDBQuery(nQry);
    end;
  end;
end;


initialization
  RegisterClass(TfFrameSalePlan);


end.
