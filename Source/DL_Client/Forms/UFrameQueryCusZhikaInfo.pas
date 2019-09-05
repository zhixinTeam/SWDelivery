unit UFrameQueryCusZhikaInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels, UAdjustForm,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, dxSkinsdxLCPainter, cxContainer, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameQueryCusZhiKa = class(TfFrameNormal)
    dxLayout1Item1: TdxLayoutItem;
    Edt_CName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    Edt_CID: TcxButtonEdit;
    procedure Edt_CNameKeyPress(Sender: TObject; var Key: Char);
    procedure Edt_CNamePropertiesChange(Sender: TObject);
    procedure Edt_CNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FCusId:string;
  protected
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    {*基类函数*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameQueryCusZhiKa: TfFrameQueryCusZhiKa;

implementation

{$R *.dfm}

uses
  ULibFun, UMgrControl, UDataModule, UFormBase, USysConst, USysDB, USysBusiness;

//------------------------------------------------------------------------------
class function TfFrameQueryCusZhiKa.FrameID: integer;
begin
  Result := cFI_FrameQueryCusZhiKaInfo;
end;

procedure TfFrameQueryCusZhiKa.OnCreateFrame;
begin
  inherited;
  FCusId:= '';
end;

procedure TfFrameQueryCusZhiKa.OnDestroyFrame;
begin
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameQueryCusZhiKa.InitFormDataSQL(const nWhere: string): string;
var nCID : string;
begin
  Result := 'Select D_ZID,  D_Type,  D_StockNo,  D_StockName,  D_Price, D_YunFei, Z_FixedMoney, ISNULL(YFMoney, 0) YFMoney, ' +
                   'Convert(decimal(18,3),(isNull(Z_FixedMoney, 0) - ISNULL(YFMoney, 0))/isNull((D_YunFei+D_Price), 10000)) D_Valuex, ' +
                   'D_Value,  Z_Man,  Z_Date,  Z_Customer,  Z_Name,  Z_Lading,  Z_CID  ' +
                   'From S_ZhiKa a  ' +
                   'Join S_ZhiKaDtl b on a.Z_ID = b.D_ZID ' +
                   'Left Join (Select L_zhika, sum((L_Price+L_YunFei)*L_Value) YFMoney From S_Bill ' +
                   'Where L_CusID=''%s'' Group by L_zhika) c on c.L_ZhiKa = a.Z_ID ' +
                   'Where Z_Verified=''Y'' and (Z_InValid<>''Y'' or Z_InValid is null) And Z_ValidDays>GetDate() ' +
                                'and Z_Customer=''%s'' Order by Z_Date Desc ';

  Result := Format(Result, [FCusId, FCusId]);
  //xxxxx
end;

procedure TfFrameQueryCusZhiKa.Edt_CNameKeyPress(Sender: TObject;
  var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
  if Key = #13 then
  begin
    Key := #0;
    if Sender = Edt_CID then
      nP.FParamA := GetCtrlData(Edt_CID)
    else if Sender = Edt_CName then
      nP.FParamA := GetCtrlData(Edt_CName);

    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    Edt_CID.Text  := nP.FParamB;
    Edt_CName.Text:= nP.FParamC;
    FCusId:= nP.FParamB;
    InitFormData('');
  end;
end;

procedure TfFrameQueryCusZhiKa.Edt_CNamePropertiesChange(Sender: TObject);
begin
  inherited;
  InitFormData('');
end;

procedure TfFrameQueryCusZhiKa.Edt_CNamePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  inherited;
  FCusId:= Trim(Edt_CName.Text);
  InitFormData(Trim(Edt_CName.Text));
end;

initialization
  gControlManager.RegCtrl(TfFrameQueryCusZhiKa, TfFrameQueryCusZhiKa.FrameID);

end.
