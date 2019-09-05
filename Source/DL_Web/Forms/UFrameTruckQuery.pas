{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 出入车辆查询
*******************************************************************************}
unit UFrameTruckQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu, uniButton,
  uniBitBtn, uniEdit, uniLabel, Data.DB, Datasnap.DBClient, uniGUIClasses,
  uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, uniGUIBaseClasses, frxClass,
  frxExportPDF, frxDBSet;

type
  TfFrameTruckQuery = class(TfFrameBase)
    Label1: TUniLabel;
    EditTruck: TUniEdit;
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    PMenu1: TUniPopupMenu;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    MenuItemN1: TUniMenuItem;
    MenuItemN2: TUniMenuItem;
    MenuItemN3: TUniMenuItem;
    MenuItemN4: TUniMenuItem;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure MenuItemN1Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    {*时间区间*}
    FFilteDate: Boolean;
    //筛选日期
    procedure OnDateFilter(const nStart,nEnd: TDate);
    //日期筛选
  public
    { Public declarations }
    procedure OnCreateFrame(const nIni: TIniFile); override;
    procedure OnDestroyFrame(const nIni: TIniFile); override;
    procedure AfterInitFormData; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //构建语句
  end;

implementation

{$R *.dfm}
uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, uniGUIForm,
  ULibFun, UManagerGroup, USysBusiness, USysDB, USysConst,
  UFormDateFilter;

procedure TfFrameTruckQuery.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  FFilteDate := True;
  InitDateRange(ClassName, FStart, FEnd);
end;

procedure TfFrameTruckQuery.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameTruckQuery.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFrameTruckQuery.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    //xxxxx
    Result := 'Select * from $Bill b Left Join S_Customer On C_ID=L_CusID ';

    if FFilteDate then
      Result := Result + 'Where ((L_InTime>=''$S'' and L_InTime <''$End'') Or ' +
              '(L_OutFact>=''$S'' and L_OutFact <''$End''))';
    //xxxxx

    if nWhere <> '' then
      if FFilteDate then
           Result := Result + ' And (' + nWhere + ')'
      else Result := Result + ' Where (' + nWhere + ')';
    //xxxxx

    if (Not UniMainModule.FUserConfig.FIsAdmin) then
    begin
      if HasPopedom2(sPopedom_ViewMYCusData, FPopedom) then
        Result := Result + 'And (L_SaleMan='''+ UniMainModule.FUserConfig.FUserID +''' or C_WeiXin='''+
                                                UniMainModule.FUserConfig.FUserID +''')';
    end;

    Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
              MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
    //xxxxx
  end;
end;

procedure TfFrameTruckQuery.AfterInitFormData;
begin
  FFilteDate := True;
  inherited;
end;

//Desc: 日期筛选
procedure TfFrameTruckQuery.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

procedure TfFrameTruckQuery.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'L_Truck like ''%' + EditTruck.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameTruckQuery.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

//Desc: 快捷菜单
procedure TfFrameTruckQuery.MenuItemN1Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: //显示全部
     begin
       FWhere := '';
       InitFormData;
     end;
    20: //未出厂
     begin
       FFilteDate := False;
       FWhere := 'L_InTime Is Not Null And L_OutFact Is Null';
       InitFormData(FWhere);
     end;
    30: //已出厂
     begin
       FWhere := '';
       InitFormData('L_OutFact Is not Null');
     end;
  end;
end;

initialization
  RegisterClass(TfFrameTruckQuery);
end.
