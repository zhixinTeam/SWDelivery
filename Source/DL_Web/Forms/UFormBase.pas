{*******************************************************************************
  作者: dmzn@163.com 2018-04-24
  描述: 标准窗体
*******************************************************************************}
unit UFormBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  uniGUITypes, uniGUIAbstractClasses, uniGUIClasses, uniGUIForm, uniPanel,
  uniGUIBaseClasses, uniButton, UManagerGroup, ULibFun, USysBusiness,
  USysConst;

type
  TfFormBase = class(TUniForm)
    BtnOK: TUniButton;
    BtnExit: TUniButton;
    PanelWork: TUniSimplePanel;
    procedure UniFormCreate(Sender: TObject);
    procedure UniFormDestroy(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FDBType: TAdoConnectionType;
    //数据连接
    FParam: TFormCommandParam;
    //命令参数
    procedure OnCreateForm(Sender: TObject); virtual;
    procedure OnDestroyForm(Sender: TObject); virtual;
    {*基类函数*}
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; virtual;
    function IsDataValid: Boolean; virtual;
    {*验证数据*}
    procedure GetSaveSQLList(const nList: TStrings); virtual;
    {*写SQL列表*}
    procedure AfterSaveData(var nDefault: Boolean); virtual;
    {*后续动作*}
  public
    { Public declarations }
    function SetParam(const nParam: TFormCommandParam): Boolean; virtual;
    {*设置参数*}
  end;

implementation

{$R *.dfm}

procedure TfFormBase.UniFormCreate(Sender: TObject);
begin
  FDBType := ctWork;
  FillChar(FParam, SizeOf(FParam), #0);
  OnCreateForm(Sender);
end;

procedure TfFormBase.UniFormDestroy(Sender: TObject);
begin
  OnDestroyForm(Sender);
end;

procedure TfFormBase.OnCreateForm(Sender: TObject);
begin

end;

procedure TfFormBase.OnDestroyForm(Sender: TObject);
begin

end;

function TfFormBase.SetParam(const nParam: TFormCommandParam): Boolean;
begin
  Result := True;
  FParam := nParam;
end;

//------------------------------------------------------------------------------
//Desc: 写数据SQL列表
procedure TfFormBase.GetSaveSQLList(const nList: TStrings);
begin
  nList.Clear;
end;

//Desc: 验证Sender的数据是否正确,返回提示内容
function TfFormBase.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  nHint := '';
  Result := True;
end;

//Desc: 保存后续动作
procedure TfFormBase.AfterSaveData(var nDefault: Boolean);
begin

end;


function TfFormBase.IsDataValid: Boolean;
var nStr: string;
    nList: TList;
    nObj: TObject;
    i,nLen: integer;
begin
  nList := nil;
  try
    Result := True;
    nList := gMG.FObjectPool.Lock(TList) as TList;
    TApplicationHelper.EnumSubCtrlList(Self, nList);

    nLen := nList.Count - 1;
    for i:=0 to nLen do
    begin
      nObj := TObject(nList[i]);
      if not OnVerifyCtrl(nObj, nStr) then
      begin
        if nObj is TWinControl then
          TWinControl(nObj).SetFocus;
        //xxxxx

        if nStr <> '' then
          ShowMessage(nStr);
        //xxxxx

        Result := False;
        Exit;
      end;
    end;
  finally
    gMG.FObjectPool.Release(nList);
  end;
end;

procedure TfFormBase.BtnOKClick(Sender: TObject);
var nBool: Boolean;
    nList: TStrings;
begin
  if not IsDataValid then Exit;

  nList := nil;
  try
    nList := gMG.FObjectPool.Lock(TStrings) as TStrings;
    GetSaveSQLList(nList);

    if nList.Count > 0 then
      DBExecute(nList, nil, FDBType);
    gMG.FObjectPool.Release(nList);

    nList := nil;
    nBool := True;
    AfterSaveData(nBool);

    if nBool then
    begin
      ModalResult := mrOK;
      ShowMessage('已保存成功');
    end;
  except
    on nErr: Exception do
    begin
      gMG.FObjectPool.Release(nList);
      ShowMessage('保存失败: ' + nErr.Message);
    end;
  end;
end;

end.
