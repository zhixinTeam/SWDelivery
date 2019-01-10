{*******************************************************************************
  作者: dmzn@163.com 2018-05-08
  描述: 业务员管理
*******************************************************************************}
unit UFrameSalesMan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameBase, uniGUITypes, Vcl.Menus, uniMainMenu, uniLabel, uniEdit, Data.DB,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, uniGUIBaseClasses, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameSalesMan = class(TfFrameBase)
    EditName: TUniEdit;
    UniLabel1: TUniLabel;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
    MenuItemN2: TUniMenuItem;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  UFormBase, ULibFun, UManagerGroup, USysBusiness, USysDB, USysConst;

function TfFrameSalesMan.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper do
  begin
    Result := 'Select * From $SM';
    if nWhere = '' then
         Result := Result + ' Where S_InValid<>''$Yes'''
    else Result := Result + ' Where (' + nWhere + ')';

    Result := MacroValue(Result, [MI('$SM', sTable_Salesman),
              MI('$Yes', sFlag_Yes)]);
    //xxxxx
  end;
end;

procedure TfFrameSalesMan.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormSalesMan', True);
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

procedure TfFrameSalesMan.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nForm := SystemGetForm('TfFormSalesMan', True);
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

procedure TfFrameSalesMan.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
    nList: TStrings;
    nQuery: TADOQuery;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要删除的记录');
    Exit;
  end;

  nQuery := nil;
  try
    nQuery := LockDBQuery(FDBType);
    nStr := ClientDS.FieldByName('S_ID').AsString;
    nSQL := 'Select Count(*) From %s Where C_SaleMan=''%s''';
    nSQL := Format(nSQL, [sTable_SaleContract, nStr]);

    with DBQuery(nSQL, nQuery) do
    if Fields[0].AsInteger > 0 then
    begin
      ShowMessage('该业务员已签合同,不能删除.');
      Exit;
    end;

    nStr := ClientDS.FieldByName('S_Name').AsString;
    nStr := Format('确定要删除名称为[ %s ]的业务员吗?', [nStr]);
    MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      begin
        if Res <> mrYes then Exit;
        //cancel

        nList := nil;
        try
          nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
          nStr := ClientDS.FieldByName('S_ID').AsString;

          nSQL := 'Delete From %s Where S_ID=''%s''';
          nSQL := Format(nSQL, [sTable_Salesman, nStr]);
          nList.Add(nSQL);

          nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
          nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_SalesmanItem, nStr]);
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
    //xxxxx
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFrameSalesMan.EditNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'S_Name like ''%%%s%%'' Or S_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameSalesMan.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameSalesMan.MenuItemN1Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('S_InValid=''%s''', [sFlag_Yes]);
    20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

initialization
  RegisterClass(TfFrameSalesMan);
end.
