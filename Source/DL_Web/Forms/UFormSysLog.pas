{*******************************************************************************
  作者: dmzn@163.com 2018-05-12
  描述: 系统日志
*******************************************************************************}
unit UFormSysLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  USysconst, UFormBase, uniGUIForm, Data.DB, Datasnap.DBClient, uniBitBtn,
  uniEdit, uniLabel, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  Vcl.Controls, Vcl.Forms, uniGUIBaseClasses, uniButton;

type
  TfFormSysLog = class(TfFormBase)
    ClientDS1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TUniDBGrid;
    PanelTop: TUniSimplePanel;
    Label1: TUniLabel;
    EditItem: TUniEdit;
    Btn1: TUniButton;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    procedure BtnDateFilterClick(Sender: TObject);
    procedure Btn1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    //时间间隔
    FWhere: string;
    //查询条件
    procedure InitFormData(const nWhere: string);
    //加载数据
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
    function SetParam(const nParam: TFormCommandParam): Boolean; override;
  end;

procedure ShowSystemLog(const nParam: TFormCommandParam);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, System.IniFiles,
  ULibFun, USysBusiness, USysDB, UFormDateFilter;

//Date: 2018-05-12
//Parm: 参数
//Desc: 显示系统日志窗口
procedure ShowSystemLog(const nParam: TFormCommandParam);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormSysLog', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormSysLog do
  begin
    SetParam(nParam);
    ShowModal();
  end;
end;

procedure TfFormSysLog.OnCreateForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile();
    LoadFormConfig(Self, nIni);

    BuildDBGridColumn('MAIN_A02', DBGrid1);
    UserDefineGrid(ClassName, DBGrid1, True, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormSysLog.OnDestroyForm(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile();
    SaveFormConfig(Self, nIni);
    UserDefineGrid(ClassName, DBGrid1, False, nIni);
  finally
    nIni.Free;
  end;
end;

function TfFormSysLog.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  Result := True;
  BtnOK.Enabled := False;
  if nParam.FCommand <> cCmd_ViewSysLog then Exit;

  with TDateTimeHelper do
  begin
    FStart := Str2Date(nParam.FParamA);
    FEnd := Str2Date(nParam.FParamB);
    EditItem.Text := nParam.FParamC;

    FWhere := nParam.FParamD;
    InitFormData(FWhere);
  end;
end;

procedure TfFormSysLog.InitFormData(const nWhere: string);
var nStr: string;
    nQuery: TADOQuery;
begin
  nQuery := nil;
  with TDateTimeHelper do
  try
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    nStr := 'Select * From %s Where L_Date>=''%s'' And L_Date<''%s''';
    nStr := Format(nStr, [sTable_SysLog, Date2Str(FStart), Date2Str(FEnd+1)]);
    if nWhere <> '' then nStr := nStr + ' And (' + nWhere + ')';

    nQuery := LockDBQuery(FDBType);
    DBQuery(nStr, nQuery, ClientDS1);
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

//Desc: 日期选择窗返回结果
procedure TfFormSysLog.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFormSysLog.Btn1Click(Sender: TObject);
begin
  EditItem.Text := Trim(EditItem.Text);
  if EditItem.Text <> '' then
  begin
    FWhere := Format('L_ItemID=''%s''', [EditItem.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFormSysLog.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

initialization
  RegisterClass(TfFormSysLog);
end.
