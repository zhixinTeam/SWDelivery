unit UFrameQueryDuanDaoFH;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit,
  cxButtonEdit, Menus;

type
  TfFrameQueryDuanDaoFH = class(TfFrameNormal)
    dxlytm_1: TdxLayoutItem;
    Edt_Bill: TcxButtonEdit;
    dxlytm_2: TdxLayoutItem;
    Edt_Truck: TcxButtonEdit;
    dxlytm_3: TdxLayoutItem;
    Edt_Keys: TcxButtonEdit;
    dxlytm_4: TdxLayoutItem;
    Edt_Date: TcxButtonEdit;
    pmPMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    procedure Edt_BillPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Edt_DatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;

    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameQueryDuanDaoFH: TfFrameQueryDuanDaoFH;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB;

class function TfFrameQueryDuanDaoFH.FrameID: integer;
begin
  Result := cFI_FrameDuanDaoQuery;
end;

procedure TfFrameQueryDuanDaoFH.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameQueryDuanDaoFH.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameQueryDuanDaoFH.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  Edt_Date.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select * From $TransferSW ';

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (T_OutFact>=''$S'' and T_OutFact <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  Result := MacroValue(Result, [MI('$TransferSW', sTable_TransferSW),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;


procedure TfFrameQueryDuanDaoFH.Edt_BillPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if Sender = Edt_Keys then
  begin
    Edt_Keys.Text := Trim(Edt_Keys.Text);
    if Edt_Keys.Text = '' then Exit;

    FWhere := 'T_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [Edt_Keys.Text]);
    InitFormData(FWhere);
  end;
  
  if Sender = Edt_Truck then
  begin
    Edt_Truck.Text := Trim(Edt_Truck.Text);
    if Edt_Truck.Text = '' then Exit;

    FWhere := 'T_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [Edt_Truck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = Edt_Bill then
  begin
    Edt_Bill.Text := Trim(Edt_Bill.Text);
    if Edt_Bill.Text = '' then Exit;

    FWhere := 'T_ID like ''%%%s%%'' OR T_PID like ''%%%s%%''';
    FWhere := Format(FWhere, [Edt_Bill.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameQueryDuanDaoFH.Edt_DatePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

procedure TfFrameQueryDuanDaoFH.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('T_ID').AsString;
    PrintDuanDaoOrderReport(nStr, False);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameQueryDuanDaoFH, TfFrameQueryDuanDaoFH.FrameID);

end.

