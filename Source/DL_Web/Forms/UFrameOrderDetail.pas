{*******************************************************************************
  作者: dmzn@163.com 2018-05-08
  描述:采购明细
*******************************************************************************}
unit UFrameOrderDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, System.IniFiles,
  Controls, Forms, uniGUITypes, UFrameBase, Vcl.Menus, uniMainMenu, uniCheckBox,
  uniButton, uniBitBtn, uniEdit, uniLabel, Data.DB, Datasnap.DBClient,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel, uniToolBar,
  uniGUIBaseClasses, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameOrderDetail = class(TfFrameBase)
    Label2: TUniLabel;
    EditCustomer: TUniEdit;
    Label3: TUniLabel;
    EditDate: TUniEdit;
    BtnDateFilter: TUniBitBtn;
    Label1: TUniLabel;
    EditBill: TUniEdit;
    Label4: TUniLabel;
    EditTruck: TUniEdit;
    PMenu1: TUniPopupMenu;
    MenuItemN1: TUniMenuItem;
    Check1: TUniCheckBox;
    MenuItemN2: TUniMenuItem;
    MenuItemN3: TUniMenuItem;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure BtnDateFilterClick(Sender: TObject);
    procedure DBGridMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemN1Click(Sender: TObject);
    procedure MenuItemN3Click(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    procedure OnDateFilter(const nStart,nEnd: TDate);
    procedure OnDateTimeFilter(const nStart,nEnd: TDate);
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
  uniGUIVars, MainModule, uniGUIApplication, ULibFun, UManagerGroup,
  USysBusiness, USysDB, USysConst, UFormDateFilter;

procedure TfFrameOrderDetail.OnCreateFrame(const nIni: TIniFile);
begin
  inherited;
  with TDateTimeHelper do
  begin
    FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
    FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  end;

  FJBWhere := '';
  InitDateRange(ClassName, FStart, FEnd);
end;

procedure TfFrameOrderDetail.OnDestroyFrame(const nIni: TIniFile);
begin
  SaveDateRange(ClassName, FStart, FEnd);
  inherited;
end;

procedure TfFrameOrderDetail.OnDateFilter(const nStart,nEnd: TDate);
begin
  FStart := nStart;
  FEnd := nEnd;
  InitFormData(FWhere);
end;

function TfFrameOrderDetail.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper, TDateTimeHelper do
  begin
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    Result := 'Select *,(D_MValue-D_PValue-D_KZValue) as D_NetWeight ' +
              'From $OD od Left Join $OO oo on od.D_OID=oo.O_ID ';
    //xxxxxx

    if FJBWhere = '' then
    begin
      Result := Result + 'Where (D_OutFact>=''$S'' and D_OutFact <''$End'')';

      if nWhere <> '' then
        Result := Result + ' And (' + nWhere + ')';
      //xxxxx
    end else
    begin
      Result := Result + ' Where (' + FJBWhere + ')';
    end;

    if Check1.Checked then
         Result := MacroValue(Result, [MI('$OD', sTable_OrderDtlBak)])
    else Result := MacroValue(Result, [MI('$OD', sTable_OrderDtl)]);

    Result := MacroValue(Result, [MI('$OD', sTable_OrderDtl),MI('$OO', sTable_Order),
              MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
    //xxxxx
  end;
end;

//Desc: 日期筛选
procedure TfFrameOrderDetail.BtnDateFilterClick(Sender: TObject);
begin
  ShowDateFilterForm(FStart, FEnd, OnDateFilter);
end;

//Desc: 执行查询
procedure TfFrameOrderDetail.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'D_ProPY like ''%%%s%%'' Or D_ProName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'oo.O_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'od.D_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------
procedure TfFrameOrderDetail.DBGridMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, DBGridMain);
end;

procedure TfFrameOrderDetail.MenuItemN1Click(Sender: TObject);
begin
  ShowDateFilterForm(FTimeS, FTimeE, OnDateTimeFilter, True)
end;

procedure TfFrameOrderDetail.OnDateTimeFilter(const nStart,nEnd: TDate);
begin
  with TDateTimeHelper do
  try
    FTimeS := nStart;
    FTimeE := nEnd;

    //FJBWhere := '(D_InTime>=''%s'' and D_InTime <''%s'')';
    FJBWhere := '(D_OutFact>=''%s'' and D_OutFact <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

procedure TfFrameOrderDetail.MenuItemN3Click(Sender: TObject);
begin
  try
    FJBWhere := '(D_OutFact Is Null)';
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

initialization
  RegisterClass(TfFrameOrderDetail);
end.
