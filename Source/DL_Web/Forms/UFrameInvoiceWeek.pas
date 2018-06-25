{*******************************************************************************
  作者: dmzn@163.com 2018-05-16
  描述: 结算周期
*******************************************************************************}
unit UFrameInvoiceWeek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, uniGUIForm, UFrameBase, uniButton, uniBitBtn,
  uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid,
  uniDBGrid, uniPanel, uniToolBar, uniGUIBaseClasses;

type
  TfFrameInvoiceWeek = class(TfFrameBase)
    Label2: TUniLabel;
    EditID: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    UniLabel1: TUniLabel;
    EditName: TUniEdit;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*时间区间*}
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, UManagerGroup,
  ULibFun, USysBusiness, USysDB, USysConst, UFormBase, UFormDateFilter;

procedure TfFrameInvoiceWeek.OnCreateFrame(const nIni: TIniFile);
var nY,nM,nD: Word;
begin
  inherited;
  InitDateRange(ClassName, FStart, FEnd);

  if FStart = FEnd then
  begin
    DecodeDate(FStart, nY, nM, nD);
    FStart := EncodeDate(nY, 1, 1);
    FEnd := EncodeDate(nY+1, 1, 1) - 1;
  end;
end;

procedure TfFrameInvoiceWeek.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameInvoiceWeek.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFrameInvoiceWeek.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    Result := 'Select * From $Week ';

    if nWhere = '' then
         Result := Result + 'Where (W_Date>=''$S'' and W_Date <''$E'')'
    else Result := Result + 'Where (' + nWhere + ')';

    Result := MacroValue(Result, [MI('$Week', sTable_InvoiceWeek),
              MI('$S', Date2Str(FStart)), MI('$E', Date2Str(FEnd + 1))]);
    //xxxxx
  end;
end;

//Desc: 日期筛选
procedure TfFrameInvoiceWeek.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

//------------------------------------------------------------------------------
//Desc: 添加
procedure TfFrameInvoiceWeek.BtnAddClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormInvoiceWeek', True);
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

//Desc: 修改
procedure TfFrameInvoiceWeek.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  if DBGridMain.SelectedRows.Count < 1 then
  begin
    ShowMessage('请选择要修改的记录');
    Exit;
  end;

  nForm := SystemGetForm('TfFormInvoiceWeek', True);
  if not Assigned(nForm) then Exit;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := ClientDS.FieldByName('W_ID').AsString;
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

//Desc: 删除
procedure TfFrameInvoiceWeek.BtnDelClick(Sender: TObject);
var nStr,nID: string;
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
    nID := ClientDS.FieldByName('W_NO').AsString;
    nStr := 'Select Count(*) From %s Where I_Week=''%s'' And I_Status=''%s''';
    nStr := Format(nStr, [sTable_Invoice, nID, sFlag_InvHasUsed]);

    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
    begin
      if Fields[0].AsInteger > 0 then
      begin
        nStr := '已有[ %d ]张发票在本周期内开出,不允许删除!';
        nStr := Format(nStr, [Fields[0].AsInteger]);
        ShowMessage(nStr); Exit;
      end;
    end;

    nStr := Format('确定要删除名称为[ %s ]的记录吗?', [nID]);
    MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      begin
        if Res <> mrYes then Exit;
        //cancel

        try
          nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
          nStr := 'Delete From %s Where W_NO=''%s''';
          nStr := Format(nStr, [sTable_InvoiceWeek, nID]);
          nList.Add(nStr);

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
    gMG.FObjectPool.Release(nList);
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFrameInvoiceWeek.EditNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'W_NO like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'W_Name like ''%' + EditName.Text + '%''';
    InitFormData(FWhere);
  end;
end;

initialization
  RegisterClass(TfFrameInvoiceWeek);
end.
