{*******************************************************************************
  作者: dmzn@163.com 2018-04-20
  描述: 用户全局主模块
*******************************************************************************}
unit MainModule;

interface

uses
  uniGUIMainModule, SysUtils, Classes, Vcl.Graphics, Data.Win.ADODB, Data.DB,
  Datasnap.DBClient, System.Variants, uniGUIBaseClasses, uniGUIClasses,
  uniImageList, uniGUIForm, uniDBGrid, uniGUITypes, USysConst;

type
  TUniMainModule = class(TUniGUIMainModule)
    ImageListSmall: TUniNativeImageList;
    ImageListBar: TUniNativeImageList;
    procedure UniGUIMainModuleCreate(Sender: TObject);
    procedure UniGUIMainModuleDestroy(Sender: TObject);
    procedure UniGUIMainModuleBeforeLogin(Sender: TObject;
      var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    FMainForm: TUniForm;
    //主窗体
    FUserConfig: TSysParam;
    //系统参数
    FGridColumnAdjust: Boolean;
    //允许调整
    FMenuModule: TMenuModuleItems;
    //菜单模块
    procedure DoDefaultAdjustEvent(Sender: TComponent; nEventName: string;
      nParams: TUniStrings);
    //默认事件
    procedure DoColumnFormat(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure DoColumnSort(Column: TUniDBGridColumn; Direction: Boolean);
    procedure DoColumnSummary(Column: TUniDBGridColumn;
      GroupFieldValue: Variant);
    procedure DoColumnSummaryResult(Column: TUniDBGridColumn;
      GroupFieldValue: Variant; Attribs: TUniCellAttribs; var Result: string);
    procedure DoColumnSummaryTotal(Column: TUniDBGridColumn; Attribs: TUniCellAttribs;
      var Result: string);
    //表格处理
  end;

function UniMainModule: TUniMainModule;
//入口函数

implementation

{$R *.dfm}

uses
  UniGUIVars, ServerModule, uniGUIApplication, USysBusiness;

function UniMainModule: TUniMainModule;
begin
  Result := TUniMainModule(UniApplication.UniMainModule)
end;

procedure TUniMainModule.UniGUIMainModuleCreate(Sender: TObject);
var nIdx: Integer;
begin
  FGridColumnAdjust := False;
  //默认不允许调整表格列宽和顺序

  FUserConfig := gSysParam;
  //复制全局参数

  with FUserConfig,UniSession do
  begin
    FLocalIP   := RemoteIP;
    FLocalName := RemoteHost;
    FUserAgent := UserAgent;
    FOSUser    := SystemUser;
  end;

  GlobalSyncLock;
  try
    //for nIdx := gAllUsers.Count-1 downto 0 do
    // if PSysParam(gAllUsers[nIdx]).FLocalIP = FUserConfig.FLocalIP then
    //  FUserConfig := PSysParam(gAllUsers[nIdx])^;
    //restore

    gAllUsers.Add(@FUserConfig);
  finally
    GlobalSyncRelease;
  end;

  SetLength(FMenuModule, gMenuModule.Count);
  for nIdx := 0 to gMenuModule.Count-1 do
    FMenuModule[nIdx] := PMenuModuleItem(gMenuModule[nIdx])^;
  //准备菜单模块映射
end;

procedure TUniMainModule.UniGUIMainModuleDestroy(Sender: TObject);
var nIdx: Integer;
begin
  GlobalSyncLock;
  try
    nIdx := gAllUsers.IndexOf(@FUserConfig);
    if nIdx >= 0 then
      gAllUsers.Delete(nIdx);
    //xxxxx
  finally
    GlobalSyncRelease;
  end;
end;

procedure TUniMainModule.UniGUIMainModuleBeforeLogin(Sender: TObject;
  var Handled: Boolean);
begin
  Handled := FUserConfig.FUserID <> '';
end;

//------------------------------------------------------------------------------
//Date: 2018-05-24
//Parm: 事件;参数
//Desc: 默认Adjust处理
procedure TUniMainModule.DoDefaultAdjustEvent(Sender: TComponent;
  nEventName: string; nParams: TUniStrings);
begin
  if nEventName = sEvent_StrGridColumnResize then
    DoStringGridColumnResize(Sender, nParams);
  //用户调整列宽
end;

//Desc: 字段数据格式化
procedure TUniMainModule.DoColumnFormat(Sender: TField; var Text: string;
  DisplayText: Boolean);
var nStr: string;
    nIdx,nInt: Integer;
begin
  GlobalSyncLock;
  try
    with gAllEntitys[Sender.DataSet.Tag].FDictItem[Sender.Tag] do
    begin
      nStr := Trim(Sender.AsString) + '=';
      if nStr = '=' then Exit;

      nIdx := Pos(nStr, FFormat.FData);
      if nIdx < 1 then Exit;

      nInt := nIdx + Length(nStr);     //start
      nStr := Copy(FFormat.FData, nInt, Length(FFormat.FData) - nInt + 1);

      nInt := Pos(';', nStr);
      if nInt < 2 then
           Text := nStr
      else Text := Copy(nStr, 1, nInt - 1);
    end;
  finally
    GlobalSyncRelease;
  end;
end;

//Desc: 排序
procedure TUniMainModule.DoColumnSort(Column: TUniDBGridColumn;
  Direction: Boolean);
var nStr: string;
    nDS: TClientDataSet;
begin
  if TUniDBGrid(Column.Grid).DataSource.DataSet is TClientDataSet then
       nDS := TUniDBGrid(Column.Grid).DataSource.DataSet as TClientDataSet
  else Exit;

  if Direction then
       nStr := Column.FieldName + '_asc'
  else nStr := Column.FieldName + '_des';

  if nDS.IndexDefs.IndexOf(nStr) >= 0 then
    nDS.IndexName := nStr;
  //xxxxx
end;

//Desc: 合计计算
procedure TUniMainModule.DoColumnSummary(Column: TUniDBGridColumn;
  GroupFieldValue: Variant);
begin
  GlobalSyncLock;
  try
    with gAllEntitys[Column.Grid.Tag].FDictItem[Column.Tag] do
    begin
      if FFooter.FKind = fkSum then //sum
      begin
        if Column.AuxValue = NULL then
             Column.AuxValue := Column.Field.AsFloat
        else Column.AuxValue := Column.AuxValue + Column.Field.AsFloat;

        //***********************
        if Column.AuxValues[1] = NULL then
             Column.AuxValues[1]:= Column.Field.AsFloat
        else Column.AuxValues[1] := Column.AuxValues[1] + Column.Field.AsFloat;
      end else

      if FFooter.FKind = fkCount then //count
      begin
        if Column.AuxValue = NULL then
             Column.AuxValue := 1
        else Column.AuxValue := Column.AuxValue + 1;

        //***********************
        if Column.AuxValue = NULL then
             Column.AuxValues[1] := 1
        else Column.AuxValues[1] := Column.AuxValues[1] + 1;
      end;
    end;
  finally
    GlobalSyncRelease;
  end;
end;

//Desc: 合计结果
procedure TUniMainModule.DoColumnSummaryResult(Column: TUniDBGridColumn;
  GroupFieldValue: Variant; Attribs: TUniCellAttribs; var Result: string);
var nF: Double;
    nI: Integer;
begin
  GlobalSyncLock;
  try
    with gAllEntitys[Column.Grid.Tag].FDictItem[Column.Tag] do
    begin
      if FFooter.FKind = fkSum then //sum
      begin
        if Column.AuxValue = Null then Exit;
        nF := Column.AuxValue;
        Result := FormatFloat(FFooter.FFormat, nF );

        Attribs.Font.Style := [fsBold];
        Attribs.Font.Color := clNavy;
      end else

      if FFooter.FKind = fkCount then //count
      begin
        if Column.AuxValue = Null then Exit;
        nI := Column.AuxValue;
        Result := FormatFloat(FFooter.FFormat, nI);

        Attribs.Font.Style := [fsBold];
        Attribs.Font.Color := clNavy;
      end;
    end;

    Column.AuxValue := NULL;
  finally
    GlobalSyncRelease;
  end;
end;

procedure TUniMainModule.DoColumnSummaryTotal(Column: TUniDBGridColumn;
  Attribs: TUniCellAttribs; var Result: string);
var nF: Double;
    nI: Integer;
begin
  GlobalSyncLock;
  try
    with gAllEntitys[Column.Grid.Tag].FDictItem[Column.Tag] do
    begin
      Attribs.Color := $E0FFE0;

      if FFooter.FKind = fkSum then //sum
      begin
        Attribs.Font.Style := [fsBold];
        Attribs.Font.Color := clGreen;
        Attribs.Color := $E0FFE0;

        if Column.AuxValues[1] = Null then Exit;
        nF := Column.AuxValues[1];
        Result := FormatFloat(FFooter.FFormat, nF );
      end else

      if FFooter.FKind = fkCount then //count
      begin
        Attribs.Font.Style := [fsBold];
        Attribs.Font.Color := clGreen;
        Attribs.Color := $E0FFE0;

        if Column.AuxValues[1] = Null then Exit;
        nI := Column.AuxValues[1];
        Result := FormatFloat(FFooter.FFormat, nI);
      end;
    end;

    Column.AuxValues[1] := NULL;
  finally
    GlobalSyncRelease;
  end;
end;


initialization
  RegisterMainModuleClass(TUniMainModule);
end.
