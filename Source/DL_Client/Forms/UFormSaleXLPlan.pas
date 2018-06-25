unit UFormSaleXLPlan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, dxSkinsDefaultPainters, cxContainer, cxListBox, ExtCtrls,
  StdCtrls, RzLstBox, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit,
  UDataModule, UFormBase, cxDropDownEdit, cxCalendar;

type
  TTfFormSaleXLPlan = class(TBaseForm)
    lst_Stock: TcxListBox;
    lst_CusName: TcxListBox;
    Edt_StockNum: TcxTextEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    btn_Save: TButton;
    Edt_CusNum: TcxTextEdit;
    lbl3: TLabel;
    DateEdt_Date: TcxDateEdit;
    procedure btn_SaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FListA : TStrings;
  public

  private
    procedure LoadInfoData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = ''; const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;


implementation

{$R *.dfm}

uses
  DB, IniFiles, ULibFun, UFormCtrl, UAdjustForm, UMgrControl, UFormBaseInfo,
  USysGrid, USysDB, USysConst;

//DXL01

class function TTfFormSaleXLPlan.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;

  with TTfFormSaleXLPlan.Create(Application) do
  begin
    try
        LoadInfoData;
        ShowModal;
    finally
      Free;
    end;
  end;
end;

class function TTfFormSaleXLPlan.FormID: integer;
begin
  Result := cFI_FormSaleXLPlan;
end;

procedure TTfFormSaleXLPlan.LoadInfoData;
var nStr: string;
    nIdx: integer;
begin
  nStr:= 'Select * From Sys_Dict Where D_Name=''StockItem''';

  with FDM.QueryTemp(nStr) do
  begin
    if Active then
    while not Eof do
    begin
      lst_Stock.Items.Add(FieldByName('D_Value').AsString);
      
      Next;
    end;
  end;

end;

procedure TTfFormSaleXLPlan.btn_SaveClick(Sender: TObject);
var nStrSql : string;
    nIdx : Integer;
begin
  if (lst_Stock.SelCount>0) then
  begin
    if (StrToIntDef(Trim(Edt_StockNum.Text), 0)>0) then
    begin
      FListA.Clear;
      for nIdx:= 0 to lst_Stock.items.count do
      begin
        if lst_Stock.Selected[nIdx] then
        begin
          nStrSql:= 'Insert Into $SalePlan (X_StockNo ,X_StockName ,X_CusId ,X_CusName ,X_Day ,X_XZValue)'+
                    ' Select ''$StockNo'', ''$StockName'', '''', '''', ''$Date'', $Value ';
          nStrSql:= MacroValue(nStrSql, [MI('$SalePlan',  sTable_SalePlan),
                                       MI('$StockNo',  ''),
                                       MI('$StockName', lst_Stock.Items[nIdx]),
                                       MI('$Date', DateTime2Str(DateEdt_Date.Date)),
                                       MI('$Value', Trim(Edt_StockNum.Text))
                                       ]);
          FListA.Add(nStrSql);
        end;
      end;

    end
    else ShowMsg('请输入选中品种限量吨数！', sHint);
  end
  else ShowMsg('请选择限量品种', sHint);
end;

procedure TTfFormSaleXLPlan.FormCreate(Sender: TObject);
begin
  inherited;
  FListA := TStringList.Create;
end;

procedure TTfFormSaleXLPlan.FormDestroy(Sender: TObject);
begin
  inherited;
  FreeAndNil(FListA);
end;

initialization
  gControlManager.RegCtrl(TTfFormSaleXLPlan, TTfFormSaleXLPlan.FormID);

end.
