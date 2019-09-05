{*******************************************************************************
  作者: 2018-07-20
  描述: 审核信用记录
*******************************************************************************}
unit UFormCreditDetailVerify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIForm, UFormBase, Vcl.Menus, uniMainMenu,
  Data.DB, Datasnap.DBClient, uniGUIClasses, uniBasicGrid, uniDBGrid, uniPanel,
  uniGUIBaseClasses, uniButton, uniMemo, uniLabel, uniMultiItem, uniComboBox;

type
  TfFormCreditDetailVerify = class(TfFormBase)
    UnLbl_1: TUniLabel;
    UnLbl1: TUniLabel;
    UnLbl2: TUniLabel;
    UnLbl3: TUniLabel;
    UnMMo_1: TUniMemo;
    UnLbl_CusName: TUniLabel;
    UnLbl_Money: TUniLabel;
    UnLbl_Date: TUniLabel;
    btn1: TUniButton;
    UnLbl4: TUniLabel;
    cbb_NextVarMan: TUniComboBox;
    UnLbl5: TUniLabel;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FCreditChanged : Boolean;
    FCusId, FCrdVifId, FVRId : string;
  private
    procedure LoadCreditDetail(const nCusName, nMoney, nEndDate: string);
    //加载明细
    procedure DoCreditVerify(nFlag: string);
  public
    { Public declarations }
    procedure OnCreateForm(Sender: TObject); override;
    procedure OnDestroyForm(Sender: TObject); override;
  end;

  TFormCreditDetailResult = procedure (const nChanged: Boolean) of object;
  //结果回调

procedure ShowCreditDetailVerifyForm(const nCusId, nCrdVifId, nCusName, nMoney, nEndDate, nVRId: string;
  const nResult: TFormCreditDetailResult);
//入口函数

implementation

{$R *.dfm}

uses
  Data.Win.ADODB, uniGUIVars, MainModule, uniGUIApplication, System.IniFiles,
  UManagerGroup, ULibFun, USysBusiness, USysDB, USysConst;


//Desc: 显示客户信用信息窗口
procedure ShowCreditDetailVerifyForm(const nCusId, nCrdVifId, nCusName, nMoney, nEndDate, nVRId: string;
  const nResult: TFormCreditDetailResult);
var nForm: TUniForm;
begin
  nForm := SystemGetForm('TfFormCreditDetailVerify', True);
  if not Assigned(nForm) then Exit;

  with nForm as TfFormCreditDetailVerify do
  begin
    FCusId:= nCusId;
    FCrdVifId:= nCrdVifId;
    FVRId:= nVRId;
    LoadCreditDetail(nCusName, nMoney, nEndDate);
    //load data

    ShowModal(
      procedure(Sender: TComponent; Result:Integer)
      begin
        nResult(FCreditChanged);
      end);
  end;
end;

procedure TfFormCreditDetailVerify.OnCreateForm(Sender: TObject);
begin
  FCreditChanged := False;
end;

procedure TfFormCreditDetailVerify.OnDestroyForm(Sender: TObject);
begin
//
end;

procedure TfFormCreditDetailVerify.LoadCreditDetail(const nCusName, nMoney, nEndDate: string);
var nStr: string;
begin
  UnLbl_CusName.Caption:= nCusName;
  UnLbl_Money.Caption:= nMoney;
  UnLbl_Date.Caption:= nEndDate;

  LoadVerifyMan(cbb_NextVarMan.Items);
end;

//Desc: 信用审核
procedure TfFormCreditDetailVerify.BtnOKClick(Sender: TObject);
begin
  if TUniButton(Sender).Caption='批准申请' then
    DoCreditVerify(sFlag_Yes)
  else DoCreditVerify(sFlag_No);
end;

procedure TfFormCreditDetailVerify.DoCreditVerify(nFlag: string);
var nStr: string;
    nVal: Double;
    nQuery: TADOQuery;
begin
  nQuery := nil;

  with TStringHelper,TFloatHelper,TSQLBuilder do
  try
    nVal:= StrToFloatDef(UnLbl_Money.Caption, 0);
    if nFlag=sFlag_Yes then
    begin
      nStr := '信用变更明细如下: ' + StringOfChar(#32, 16) + #13#10#13#10 +
              '※.客户名称: %s' + #13#10 +
              '※.授信金额: %.2f元' + #13#10#13#10 +
              '继续授信请点击"是".';
      nStr := Format(nStr, [UnLbl_CusName.Caption, nVal]);
    end
    else
    begin
      nStr := '拒绝本次信用额度申请' + #13#10#13#10 +
              '继续请点击 "是".';
      nStr := Format(nStr, [UnLbl_CusName.Caption, nVal]);
    end;

    MessageDlg(nStr, mtConfirmation, mbYesNo,
      procedure(Sender: TComponent; Res: Integer)
      var nList: TStrings;
      begin
        if Res <> mrYes then Exit;
        nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
        try
          nStr := SF('R_ID', FVRId);
          nStr := MakeSQLByStr([
                  SF('V_Verify', nFlag),
                  SF('V_Memo', Trim(UnMMo_1.Text)),
                  SF('V_VerDate', sField_SQLServer_Now, sfVal)
                  ], sTable_CusCreditVif, nStr, False);
          nList.Add(nStr);

          if nFlag=sFlag_Yes then
          begin
            if cbb_NextVarMan.Text='' then
            begin
                nStr := SF('C_CreditID', FCrdVifId);
                nStr := MakeSQLByStr([
                        SF('C_Verify', sFlag_Yes),
                        SF('C_VerMan', UniMainModule.FUserConfig.FUserID),
                        SF('C_VerDate', sField_SQLServer_Now, sfVal),
                        SF('C_Memo', Trim(UnMMo_1.Text))
                        ], sTable_CusCredit, nStr, False);
                nList.Add(nStr);

                nStr := 'UPDate %s Set A_CreditLimit=A_CreditLimit+%.2f ' +
                          'Where A_CID=''%s''';
                nStr := Format(nStr, [sTable_CusAccount, nVal, FCusId]);
                nList.Add(nStr);
            end
            else
            begin
              nStr := SF('C_CreditID', FCrdVifId);
              nStr := MakeSQLByStr([
                      SF('C_VerMan', Trim(cbb_NextVarMan.Text))
                      ], sTable_CusCredit, nStr, False);
              nList.Add(nStr);

              nStr := MakeSQLByStr([SF('V_CreditID', FCrdVifId),
                      SF('V_Verify', sFlag_Unknow),
                      SF('V_VerMan', Trim(cbb_NextVarMan.Text)),
                      SF('V_PreFxMan', UniMainModule.FUserConfig.FUserID)
                      ], sTable_CusCreditVif, '', True);
              nList.Add(nStr);
            end;
          end;

          DBExecute(nList, nil, FDBType);
          //匿名函数中不能使用全局的nQuery
          FCreditChanged := True;
        finally
          gMG.FObjectPool.Release(nList);
          Close;
        end;
      end);
  finally
    ReleaseDBQuery(nQuery);
  end;
end;

initialization
  RegisterClass(TfFormCreditDetailVerify);
end.
