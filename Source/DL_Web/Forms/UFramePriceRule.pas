{*******************************************************************************
  ����: dmzn@163.com 2018-07-01
  ����: �۸����
*******************************************************************************}
unit UFramePriceRule;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, UFormBase, uniCheckBox, Vcl.Menus,
  uniMainMenu, uniButton, uniBitBtn, uniEdit, uniLabel, Data.DB,
  Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniToolBar, uniGUIBaseClasses;

type
  TfFramePriceRule = class(TfFrameBase)
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    Check1: TUniCheckBox;
    PMenu1: TUniPopupMenu;
    MenuItem1: TUniMenuItem;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure Check1Click(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*ʱ������*}
    FFilteDate: Boolean;
    //ɸѡ����
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //����ɸѡ
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    procedure AfterInitFormData; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //�������
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  ULibFun, UManagerGroup, USysBusiness, USysDB, USysConst,
  UFormDateFilter;

procedure TfFramePriceRule.OnCreateFrame(const nIni: TIniFile);
var nY,nM,nD: Word;
begin
  inherited;
  FDBType := ctMain;
  FFilteDate := True;
  InitDateRange(ClassName, FStart, FEnd);

  if FStart = FEnd then
  begin
    DecodeDate(Now(), nY, nM, nD);
    FStart := EncodeDate(nY, 1, 1);
  end;
end;

procedure TfFramePriceRule.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFramePriceRule.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFramePriceRule.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd));
    //xxxxx
    Result := 'Select * from $R r ';

    if Check1.Checked then
    begin
      Result := Result + 'Where R_Date>=''$S'' and R_Date <''$End'''
    end else
    begin
      Result := Result + 'Where R_Valid=''$Yes''';
    end;

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx

    Result := MacroValue(Result, [MI('$R', sTable_PriceRule),
              MI('$Yes', sFlag_Yes),
              MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)));
    //xxxxx
  end;
end;

procedure TfFramePriceRule.AfterInitFormData;
begin
  FFilteDate := True;
  inherited;
end;

//Desc: ����ɸѡ
procedure TfFramePriceRule.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

//------------------------------------------------------------------------------
procedure TfFramePriceRule.Check1Click(Sender: TObject);
begin
  InitFormData(FWhere);
end;

//Desc: �޸Ķ���
procedure TfFramePriceRule.BtnEditClick(Sender: TObject);
var nForm: TUniForm;
    nParam: TFormCommandParam;
begin
  nForm := SystemGetForm('TfFormPriceRule', True);
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

procedure TfFramePriceRule.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFramePriceRule.MenuItem1Click(Sender: TObject);
var nStr: string;
begin
  if DBGridMain.SelectedRows.Count > 0 then
  begin
    nStr := 'R_StockNo=''%s''';
    nStr := Format(nStr, [ClientDS.FieldByName('R_StockNo').AsString);
    InitFormData(nStr);
  end;
end;

initialization
  RegisterClass(TfFramePriceRule);
end.
