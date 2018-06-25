{*******************************************************************************
  作者: dmzn@163.com 2018-05-17
  描述: 获取返利周期
*******************************************************************************}
unit UFormInvoiceGetWeek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, uniGUIForm,
  USysConst, Data.Win.ADODB, UFormBase, uniLabel, uniGUIClasses, uniMultiItem,
  uniComboBox, uniPanel, Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, uniButton;

type
  TfFormInvoiceGetWeek = class(TfFormBase)
    EditYear: TUniComboBox;
    UniLabel8: TUniLabel;
    UniLabel9: TUniLabel;
    EditWeek: TUniComboBox;
    procedure EditYearChange(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitFormData(const nYear,nWeek: string);
    procedure LoadWeekList(const nYear: string; const nQuery: TADOQuery);
    //载入数据
    procedure GetResult;
    //获取结果
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

procedure ShowInvoiceGetWeekForm(const nParam: TFormCommandParam;
  const nResult: TFormModalResult);
//入口函数

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, System.IniFiles,
  ULibFun, USysBusiness, USysDB;

//Date: 2018-05-17
//Parm: 参数;结果回调
//Desc: 显示结算周期查询窗口
procedure ShowInvoiceGetWeekForm(const nParam: TFormCommandParam;
  const nResult: TFormModalResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormInvoiceGetWeek', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormInvoiceGetWeek do
  begin
    SetParam(nParam);
    //init

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        if Result = mrOk then
        begin
          GetResult;
          nResult(Result, @FParam);
        end;
      end);
    //xxxxx
  end;
end;

function TfFormInvoiceGetWeek.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  Result := inherited SetParam(nParam);
  InitFormData(nParam.FParamA, nParam.FParamB);
end;

procedure TfFormInvoiceGetWeek.GetResult;
begin
  with FParam do
  begin
    FParamA := EditYear.Text;
    FParamB := GetIDFromBox(EditWeek);
    FParamC := GetNameFromBox(EditWeek);
  end;
end;

procedure TfFormInvoiceGetWeek.InitFormData(const nYear, nWeek: string);
var nStr: string;
    nInt: Integer;
    nY1,nY2,nM,nD: Word;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  with TStringHelper do
  try
    EditYear.Items.BeginUpdate;
    EditYear.Items.Clear;

    nStr := 'SELECT MIN(W_Begin) AS W_Begin, MAX(W_End) AS W_End FROM %s';
    nStr := Format(nStr, [sTable_InvoiceWeek]);

    nQuery := LockDBQuery(FDBType);
    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      DecodeDate(Fields[0].AsDateTime, nY1, nM, nD);
      DecodeDate(Fields[1].AsDateTime, nY2, nM, nD);

      for nInt:=nY1 to nY2 do
        EditYear.Items.Add(IntToStr(nInt));
      //xxxxx
    end;

    if EditYear.Items.Count < 1 then
    begin
      ShowMessage('未找到有效周期'); Exit;
    end;

    if nYear = '' then
    begin
      DecodeDate(Now(), nY1, nM, nD);
      EditYear.ItemIndex := EditYear.Items.IndexOf(IntToStr(nY1));
    end else EditYear.ItemIndex := EditYear.Items.IndexOf(nYear);
    //focus to load week list

    if EditYear.ItemIndex > -1 then
      LoadWeekList(EditYear.Text, nQuery);
    if EditWeek.Items.Count < 1 then Exit;
    //no week in list

    if nWeek = '' then
    begin
      nStr := 'Select Top 1 W_NO From $W ' +
              'Where (W_Begin<=$Now And W_End+1>$Now) Or (W_Begin>=$Now) ' +
              'Order By W_Begin ASC';
      nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
              MI('$Now', sField_SQLServer_Now)]);
      //get now fix week

      with DBQuery(nStr, nQuery) do
      if RecordCount > 0 then
           nStr := Fields[0].AsString
      else nStr := '';
    end else nStr := nWeek;

    if nStr = '' then
         EditWeek.ItemIndex := 0
    else EditWeek.ItemIndex := StrListIndex(nStr, EditWeek.Items, 0, '.');
  finally
    EditYear.Items.EndUpdate;
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceGetWeek.LoadWeekList(const nYear: string;
 const nQuery: TADOQuery);
var nStr: string;
begin
  with TStringHelper do
  try
    EditWeek.Items.BeginUpdate;
    EditWeek.Items.Clear;
    EditWeek.Items.Add('全部周期');

    nStr := 'Select W_NO,W_Name From $W Where (W_Begin>=''$S'' and ' +
            'W_Begin<''$E'') or (W_End>=''$S'' and W_End<''$E'') ' +
            'Order By W_Begin';
    nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
            MI('$S', nYear), MI('$E', IntToStr(StrToInt(nYear)+1))]);
    //xxxxx

    with DBQuery(nStr, nQuery) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditWeek.Items.Add(FieldByName('W_NO').AsString + '.' +
                           FieldByName('W_Name').AsString);
        Next;
      end;
    end;
  finally
    EditWeek.Items.EndUpdate;
    EditWeek.ItemIndex := 0;
  end;
end;

//Desc: 年份变化,更新周期
procedure TfFormInvoiceGetWeek.EditYearChange(Sender: TObject);
var nQuery: TADOQuery;
begin
  nQuery := nil;
  if EditYear.ItemIndex > -1 then
  try
    nQuery := LockDBQuery(FDBType);
    LoadWeekList(EditYear.Text, nQuery);
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

procedure TfFormInvoiceGetWeek.BtnOKClick(Sender: TObject);
begin
  if EditYear.ItemIndex < 0 then
  begin
    ShowMessage('请选择年份');
    Exit;
  end;

  if EditWeek.ItemIndex < 0 then
  begin
    ShowMessage('请选择有效周期');
    Exit;
  end;

  ModalResult := mrOk;
end;

initialization
  RegisterClass(TfFormInvoiceGetWeek);
end.
