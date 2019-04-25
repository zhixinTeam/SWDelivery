{*******************************************************************************
  作者: dmzn@163.com 2018-05-07
  描述: 车辆调度查询
*******************************************************************************}
unit UFrameQueryDiapatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, UFrameBase, uniEdit,
  uniLabel, Data.DB, Datasnap.DBClient, uniSplitter, uniGUIClasses,
  uniBasicGrid, uniDBGrid, uniPanel, uniToolBar, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, frxClass, frxExportPDF, frxDBSet;

type
  TfFrameQueryDiapatch = class(TfFrameBase)
    Label1: TUniLabel;
    EditTruck: TUniEdit;
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
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
  uniGUIVars, MainModule, uniGUIApplication, uniGUIForm, UManagerGroup,
  ULibFun, USysBusiness, USysDB, USysConst;

function TfFrameQueryDiapatch.InitFormDataSQL(const nWhere: string): string;
begin
  with TStringHelper,TDateTimeHelper do
  begin
    Result := ' Select zt.*,Z_Name,L_CusID,L_CusName,L_Status,L_Value ' +
              'From $ZT zt ' +
              ' Left Join $ZL zl On zl.Z_ID=zt.T_Line ' +
              ' Left Join $Bill b On b.L_ID=zt.T_Bill ';
    //xxxxx

    if nWhere <> '' then
      Result := Result + ' Where (' + nWhere + ')';
    //xxxx

    if (Not UniMainModule.FUserConfig.FIsAdmin) then
    begin
      if HasPopedom2(sPopedom_ViewMYCusData, FPopedom) then
        Result := Result + 'And (L_SaleMan='''+ UniMainModule.FUserConfig.FUserID +''')';
    end;

    Result := MacroValue(Result, [MI('$ZT', sTable_ZTTrucks),
              MI('$ZL', sTable_ZTLines), MI('$Bill', sTable_Bill));
    //xxxxx
  end;
end;

procedure TfFrameQueryDiapatch.EditTruckKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then Exit;
  Key := #0;

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := Format('zt.T_Truck like ''%%%s%%''', [EditTruck.Text);
    InitFormData(FWhere);
  end;
end;

initialization
  RegisterClass(TfFrameQueryDiapatch);
end.
