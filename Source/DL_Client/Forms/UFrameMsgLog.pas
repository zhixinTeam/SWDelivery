unit UFrameMsgLog;

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
  TfFrameMsgLog = class(TfFrameNormal)
    dxLayout1Item1: TdxLayoutItem;
    Edt_Date: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    Edt_Keys: TcxButtonEdit;
    procedure Edt_KeysPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Edt_DatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
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
  fFrameMsgLog: TfFrameMsgLog;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB;

class function TfFrameMsgLog.FrameID: integer;
begin
  Result := cFI_FrameMsgLog;
end;

procedure TfFrameMsgLog.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameMsgLog.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameMsgLog.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  Edt_Date.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select Replace(Replace(E_Event, CHAR(13) ,''''), CHAR(10) ,'''') E_EventEx, * From $MEvent ';

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (E_Date>=''$S'' and E_Date <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  Result := Result + ' And E_From=''磅房''  Order by E_Date Desc ';
  Result := MacroValue(Result, [MI('$MEvent', sTable_ManualEvent),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

procedure TfFrameMsgLog.Edt_KeysPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = Edt_Keys then
  begin
    Edt_Keys.Text := Trim(Edt_Keys.Text);
    if Edt_Keys.Text = '' then Exit;

    FWhere := 'E_Event like ''%%%s%%''';
    FWhere := Format(FWhere, [Edt_Keys.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameMsgLog.Edt_DatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then
    InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameMsgLog, TfFrameMsgLog.FrameID);

end.
