unit UFramQueryNcZhiKaLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameQueryNcZhiKaLog = class(TfFrameNormal)
    dxLayout1Item1: TdxLayoutItem;
    Edt_NcOrder: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCusPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
  private
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameQueryNcZhiKaLog: TfFrameQueryNcZhiKaLog;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameQueryNcZhiKaLog.FrameID: integer;
begin
  Result := cFI_FrameQueryNcZhiKaLog;
end;

procedure TfFrameQueryNcZhiKaLog.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);

  if (not gSysParam.FIsAdmin) then
  begin
    BtnEdit.Visible:= False;
  end;
end;

procedure TfFrameQueryNcZhiKaLog.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameQueryNcZhiKaLog.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $ZhiKaLog Left Join S_Customer on Lg_CusID=C_ID ';
  //提货单

  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (Lg_Date>=''$ST'' and Lg_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [ MI('$ZhiKaLog', 'Sys_ZhiKaLog'),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

procedure TfFrameQueryNcZhiKaLog.AfterInitFormData;
begin
  FUseDate := True;
end;


procedure TfFrameQueryNcZhiKaLog.EditDatePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFrameQueryNcZhiKaLog.EditCusPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if Sender = Edt_NcOrder then
  begin
    Edt_NcOrder.Text := Trim(Edt_NcOrder.Text);
    if Edt_NcOrder.Text = '' then Exit;

    FUseDate := Length(Edt_NcOrder.Text) <= 3;
    FWhere := 'Lg_ZhiKaID =''' + Edt_NcOrder.Text + '''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameQueryNcZhiKaLog, TfFrameQueryNcZhiKaLog.FrameID);
  
end.
