{*******************************************************************************
  作者: dmzn@163.com 2018-04-25
  描述: 合同管理
*******************************************************************************}
unit UFrameContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid,
  uniPanel, uniToolBar, uniGUIBaseClasses;

type
  TfFrameContract = class(TfFrameBase)
    Label1: TUniLabel;
    EditID: TUniEdit;
    Label2: TUniLabel;
    EditCus: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItem1: TUniMenuItem;
    MenuItemN1: TUniMenuItem;
    MenuItem2: TUniMenuItem;
    MenuItem3: TUniMenuItem;
    MenuItemN4: TUniMenuItem;
    MenuItem4: TUniMenuItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  ULibFun, UManagerGroup, USysBusiness, UFormBase, USysDB, USysConst;

procedure TfFrameContract.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  MenuItem2.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
  MenuItem3.Enabled := HasPopedom2(sPopedom_Edit, FPopedom);
end;

function TfFrameContract.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select con.*,sm.S_Name,sm.S_PY,cus.C_Name as Cus_Name,' +
            'cus.C_PY From $Con con' +
            ' Left Join $SM sm On sm.S_ID=con.C_SaleMan' +
            ' Left Join $Cus cus On cus.C_ID=con.C_Customer';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where IsNull(C_Freeze, '''')<>''$Yes'''
  else Result := Result + ' Where (' + nWhere + ')';

  with TStringHelper do
  Result := MacroValue(Result, [MI('$Con', sTable_SaleContract),
            MI('$SM', sTable_Salesman),
            MI('$Cus', sTable_Customer), MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

procedure TfFrameContract.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormSaleContract', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_AddData;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

procedure TfFrameContract.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nForm := SystemGetForm('TfFormSaleContract', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := ClientDS.FieldByName('R_ID').AsString;
  (nForm as TfFormBase).SetParam(nParam);

  nForm.ShowModal(
    procedure(Sender: TComponent; Result:Integer)
    begin
      if Result = mrok then
        InitFormData(FWhere);
      //refresh
    end);
  //show form
end;

procedure TfFrameContract.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要删除的记录');
    Exit;
  end;

  nList := nil;
  nQuery := nil;
  try
    nStr := ClientDS.FieldByName('C_ID').AsString;
    nSQL := 'Select Count(*) From %s Where Z_CID=''%s''';
    nSQL := Format(nSQL, [sTable_ZhiKa, nStr]);

    nQuery := LockDBQuery(FDBType);
    with DBQuery(nSQL, nQuery) do
    if Fields[0].AsInteger > 0 then
    begin
      ShowMessage('该合同已办纸卡,不允许删除.');
      Exit;
    end;

    nSQL := Format('确定要删除编号为[ %s ]的合同吗?', [nStr]);
    MessageDlg(nSQL, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      begin
        if Res <> mrYes then Exit;
        //cancel

        try
          nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
          nStr := ClientDS.FieldByName('C_ID').AsString;

          nSQL := 'Delete From %s Where C_ID=''%s''';
          nSQL := Format(nSQL, [sTable_SaleContract, nStr]);
          nList.Add(nSQL);

          nSQL := 'Delete From %s Where E_CID=''%s'' ';
          nSQL := Format(nSQL, [sTable_SContractExt, nStr]);
          nList.Add(nSQL);

          DBExecute(nList, nil, FDBType);
          gMG.FObjectPool.Release(nList);
          nList := nil;

          InitFormData(FWhere);
          ShowMessage('已成功删除记录');
        except
          on nErr: Exception do
          begin
            gMG.FObjectPool.Release(nList);
            ShowMessage('删除失败: ' + nErr.Message);
          end;
        end;
      end);
  finally
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFrameContract.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'con.C_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'C_PY like ''%%%s%%'' Or C_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameContract.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 冻结,解冻合同
procedure TfFrameContract.MenuItem2Click(Sender: TObject);
var nStr,nSQL: string;
begin
  if Sender = MenuItem4 then
  begin
    InitFormData('1=1');
    Exit;
  end; //query all

  if DBGridMain.SelectedRows.Count > 0 then
  begin
    case TComponent(Sender).Tag of
      10: nStr := sFlag_Yes;
      20: nStr := sFlag_No;
    end;

    nSQL := 'Update %s Set C_Freeze=''%s'' Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_SaleContract, nStr,
                          ClientDS.FieldByName('C_ID').AsString]);
    //xxxxx

    DBExecute(nSQL, nil, FDBType);
    InitFormData(FWhere);
    ShowMessage('操作成功');
  end;
end;

initialization
  RegisterClass(TfFrameContract);
end.
