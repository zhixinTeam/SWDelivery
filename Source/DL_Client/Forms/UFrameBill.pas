{*******************************************************************************
  作者: dmzn@163.com 2009-6-22
  描述: 开提货单
*******************************************************************************}
unit UFrameBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, Menus,
  UBitmapPanel, cxSplitter, cxLookAndFeels, cxLookAndFeelPainters,
  cxCheckBox, dxSkinsCore, dxSkinsDefaultPainters, dxSkinscxPCPainter,
  dxSkinsdxLCPainter;

type
  TfFrameBill = class(TfFrameNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCard: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    dxLayout1Item10: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    NC1: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure NC1Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameBill.FrameID: integer;
begin
  Result := cFI_FrameBill;
end;

procedure TfFrameBill.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);

  if (not gSysParam.FIsAdmin) then
  begin
    BtnEdit.Visible:= False;
  end;
end;

procedure TfFrameBill.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameBill.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;

  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $Bill ';
  //提货单

  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  if (not gSysParam.FIsAdmin)and
     (gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewMYCusData)) then
  begin
      Result := Result + ' And ((L_SaleMan=''' + gSysParam.FUserID + ''') or (L_CusName=''' +
            gSysParam.FUserID + '''))';
  end;

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$Bill', sTable_BillBak)])
  else Result := MacroValue(Result, [MI('$Bill', sTable_Bill)]);
end;

procedure TfFrameBill.AfterInitFormData;
begin
  FUseDate := True;
end;

function TfFrameBill.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price';
end;

//Desc: 执行查询
procedure TfFrameBill.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;    FUseDate := True;
    FWhere := 'L_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;
                                              FUseDate := True;
    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCard then
  begin
    EditCard.Text := Trim(EditCard.Text);
    if EditCard.Text = '' then Exit;

    FUseDate := Length(EditCard.Text) <= 3;    FUseDate := True;
    FWhere := Format(' (L_Truck like ''%%%s%%'' Or L_HYDan like ''%%%s%%'') ', [EditCard.Text, EditCard.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 未开始提货的提货单
procedure TfFrameBill.N4Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('(L_Status=''%s'')', [sFlag_BillNew]);
   20: FWhere := 'L_OutFact Is Null'
   else Exit;
  end;

  FUseDate := False;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameBill.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: 查询删除
procedure TfFrameBill.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameBill.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormBill, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除
procedure TfFrameBill.BtnDelClick(Sender: TObject);
var nStr, nReason: string;
begin
  if CheckDelete.Checked then Exit;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  if SQLQuery.FieldByName('L_EmptyOut').AsString='Y' then
  begin
    ShowMsg('空车出厂记录禁止删除', sHint); Exit;
  end;

  nStr := '确定要删除编号为[ %s ]的单据吗?';
  nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  begin
    nReason:= '';
    if not ShowInputBox('删除原因:', '删除', nReason, 200) then Exit;

    if (nReason = '') then
    begin
      ShowMsg('您未填写删除原因、操作失败', sHint);
      Exit;
    end;
    //无效或一致
  end;

  if DeleteBill(SQLQuery.FieldByName('L_ID').AsString, nReason) then
  begin
    InitFormData(FWhere);
    ShowMsg('提货单已删除', sHint);
  end;

  try
    SaveWebOrderDelMsg(SQLQuery.FieldByName('L_ID').AsString,sFlag_Sale);
  except
  end;
  //插入删除推送
end;

//Desc: 打印提货单
procedure TfFrameBill.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillReport(nStr, False);
  end;
end;

procedure TfFrameBill.PMenu1Popup(Sender: TObject);
begin
  N3.Enabled := gPopedomManager.HasPopedom(PopedomItem, sPopedom_Edit);
  //销售调拨

  {$IFDEF DYGL}
  N10.Visible := True;
  N11.Visible := True;
  //打印预提单和过路费
  {$ENDIF}
end;

//Desc: 修改未进厂车牌号
procedure TfFrameBill.N5Click(Sender: TObject);
var nStr, nStrx, nLid, nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('请输入新的车牌号码:', '修改', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //无效或一致

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    //if ChangeLadingTruckNo(nStr, nTruck) then
    begin
      nStrx := 'UPDate %s Set L_Truck=''%s'' Where L_ID=''%s''';
      nStrx := Format(nStrx, [sTable_Bill, nTruck, nStr]);
      FDM.ExecuteSQL(nStrx);
      nStrx := 'UPDate %s Set T_Truck=''%s'' Where T_Bill=''%s''';
      nStrx := Format(nStrx, [sTable_ZTTrucks, nTruck, nStr]);
      FDM.ExecuteSQL(nStrx);

      nStr := '修改车牌号[ %s -> %s ].';
      nStr := Format(nStr, [SQLQuery.FieldByName('L_Truck').AsString, nTruck]);
      FDM.WriteSysLog(sFlag_BillItem, SQLQuery.FieldByName('L_ID').AsString, nStr, False);

      InitFormData(FWhere);
      ShowMsg('车牌号修改成功', sHint);
    end;
  end;
end;

//Desc: 修改封签号
procedure TfFrameBill.N7Click(Sender: TObject);
var nStr,nID,nSeal,nSave: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
//    {$IFDEF BatchInHYOfBill}
//    nSave := 'L_HYDan';
//    {$ELSE}
//    nSave := 'L_Seal';
//    {$ENDIF}

    nSave:= 'L_Seal';
    nStr := SQLQuery.FieldByName(nSave).AsString;
    nSeal := nStr;
    if not ShowInputBox('请输入新的封签编号:', '修改', nSeal, 100) then Exit;

    if (nSeal = '') or (nStr = nSeal) then Exit;
    //无效或一致
    nID := SQLQuery.FieldByName('L_ID').AsString;

    nStr := '确定要将交货单[ %s ]的封签号该为[ %s ]吗?';
    nStr := Format(nStr, [nID, nSeal]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Update %s Set %s=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nSave, nSeal, nID]);
    FDM.ExecuteSQL(nStr);

    nStr := '修改封签号[ %s -> %s ].';
    nStr := Format(nStr, [SQLQuery.FieldByName(nSave).AsString, nSeal]);
    FDM.WriteSysLog(sFlag_BillItem, nID, nStr, False);

    InitFormData(FWhere);
    ShowMsg('封签号修改成功', sHint);
  end;
end;

//Desc: 调拨提货单
procedure TfFrameBill.N3Click(Sender: TObject);
var nStr,nTmp: string;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_AddData;
    CreateBaseFormItem(cFI_FormGetZhika, PopedomItem, @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    nStr := SQLQuery.FieldByName('L_ZhiKa').AsString;
    if nStr = nP.FParamB then
    begin
      ShowMsg('相同纸卡不能调拨', sHint);
      Exit;
    end;

    nStr := 'Select C_ID,C_Name From %s,%s ' +
            'Where Z_ID=''%s'' And Z_Customer=C_ID';
    nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, nP.FParamB]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('纸卡信息无效', sHint);
        Exit;
      end;

      nStr := '系统将执行提货调拨操作,明细如下: ' + #13#10#13#10 +
              '※.从客户: %s.%s' + #13#10 +
              '※.到客户: %s.%s' + #13#10 +
              '※.品  种: %s.%s' + #13#10 +
              '※.调拨量: %.2f吨' + #13#10#13#10 +
              '确定要执行请点击"是".';
      nStr := Format(nStr, [SQLQuery.FieldByName('L_CusID').AsString,
              SQLQuery.FieldByName('L_CusName').AsString,
              FieldByName('C_ID').AsString,
              FieldByName('C_Name').AsString,
              SQLQuery.FieldByName('L_StockNo').AsString,
              SQLQuery.FieldByName('L_StockName').AsString,
              SQLQuery.FieldByName('L_Value').AsFloat]);
      if not QueryDlg(nStr, sAsk) then Exit;
    end;

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    if BillSaleAdjust(nStr, nP.FParamB) then
    begin
      nTmp := '销售调拨给纸卡[ %s ].';
      nTmp := Format(nTmp, [nP.FParamB]);

      FDM.WriteSysLog(sFlag_BillItem, nStr, nTmp, False);
      InitFormData(FWhere);
      ShowMsg('调拨成功', sHint);
    end;
  end;
end;

procedure TfFrameBill.N10Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillLoadReport(nStr, False);
  end;
end;

procedure TfFrameBill.N11Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillFYDReport(nStr, False);
  end;
end;

procedure TfFrameBill.N12Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintHeGeReportByThId(nStr, False);
  end;
end;

procedure TfFrameBill.N13Click(Sender: TObject);
var nBillId, nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nBillId := SQLQuery.FieldByName('L_ID').AsString;

    nStr := 'Update %s Set T_InLadeFirst=Convert(varchar, GetDate(), 120) Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBillId]);

    FDM.ExecuteSQL(nStr);

    nStr:= SQLQuery.FieldByName('L_Truck').AsString;
    nStr:= Format(' %s 重置散装车辆  %s  放灰时间', [gSysParam.FUserName, nStr]);
    FDM.WriteSysLog(sFlag_BillItem, '', nStr, False);
    ShowMsg('已重置成功', sHint);
  end;
end;

procedure TfFrameBill.N14Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintHuaYanReportByBillNo(nStr, False);
  end;
end;

procedure TfFrameBill.N15Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillRt(nStr, False);
    // 声威开单小票
  end;
end;

procedure TfFrameBill.N16Click(Sender: TObject);
var nStr, nStd: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    begin
      nStd:= '';
      if not ShowInputBox('标准净重（吨）:', '输入', nStd, 15) then Exit;

      if (nStd = '') then
      begin
        ShowMsg('您未填写标准净重、操作失败', sHint);
        Exit;

        if (StrToFloatDef(nStd, -1)=-1) then
        begin
          ShowMsg('请输入合法重量', sHint);
          Exit;
        end;

        if (StrToFloatDef(nStd, 100)>100) then
        begin
          ShowMsg('标准净重输入异常', sHint);
          Exit;
        end;
      end;
      //无效
    end;

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillReport_Std(nStr, nStd, False);
  end;
end;

procedure TfFrameBill.N18Click(Sender: TObject);
var nSql, nLid, nStr : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nLid := SQLQuery.FieldByName('L_ID').AsString;
    nSql := 'UPDate %s Set L_Date=GETDATE() Where L_ID=''%s'' ';
    nSql := Format(nSql, [sTable_Bill , nLid]);
    FDM.ExecuteSQL(nSql);

    nStr:= SQLQuery.FieldByName('L_Truck').AsString;
    nStr:= Format(' %s 对超时进厂车辆 %s %s  放行', [gSysParam.FUserName, nLid, nStr]);
    FDM.WriteSysLog(sFlag_BillItem, '', nStr, False);
    ShowMsg('操作成功、已调整该车辆开单时间', sHint);
  end;
end;

procedure TfFrameBill.BtnEditClick(Sender: TObject);
var nStr:string;
    nP: TFormCommandParam;
begin
  try
    if cxView1.DataController.GetSelectedCount > 0 then
    begin
      nP.FParamA := SQLQuery.FieldByName('L_ID').AsString;

      CreateBaseFormItem(cFI_FormUPDateBindBillZhika, '', @nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;


      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_UPLoadOrderNc, SQLQuery.FieldByName('R_ID').AsString]);

      //FDM.ExecuteSQL(nStr);
      InitFormData(FWhere);
    end;
  finally
  end;
end;

procedure TfFrameBill.NC1Click(Sender: TObject);
var nID: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nID := SQLQuery.FieldByName('L_ID').AsString;
    begin
      UPLoadOrderToNC(nID, 'S');
      InitFormData(FWhere);
      ShowMsg('操作成功、稍后上传 NC ', sHint);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBill, TfFrameBill.FrameID);
end.
