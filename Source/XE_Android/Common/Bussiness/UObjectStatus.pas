{*******************************************************************************
  ����: dmzn@163.com 2015-08-06
  ����: ע�����ϵͳ���������״̬
*******************************************************************************}
unit UObjectStatus;

interface

uses
  Windows, Classes, SysUtils;

type
  TStatusObjectBase = class(TObject)
  protected
    procedure GetStatus(const nList: TStrings); virtual; abstract;
    //����״̬
  end;

  TObjectStatusManager = class(TObject)
  private
    FObjects: TList;
    //�����б�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure AddObject(const nObj: TObject);
    procedure DelObject(const nObj: TObject);
    //���ɾ��
    procedure GetStatus(const nList: TStrings);
    //��ȡ״̬
  end;

var
  gObjectStatusManager: TObjectStatusManager = nil;
  //ȫ��ʹ��

implementation

constructor TObjectStatusManager.Create;
begin
  FObjects := TList.Create;
end;

destructor TObjectStatusManager.Destroy;
begin
  FObjects.Free;
  inherited;
end;

procedure TObjectStatusManager.AddObject(const nObj: TObject);
begin
  if not (nObj is TStatusObjectBase) then
    raise Exception.Create(ClassName + ': Object Is Not Support.');
  FObjects.Add(nObj);
end;

procedure TObjectStatusManager.DelObject(const nObj: TObject);
var nIdx: Integer;
begin
  nIdx := FObjects.IndexOf(nObj);
  if nIdx > -1 then
    FObjects.Delete(nIdx);
  //xxxxx
end;

procedure TObjectStatusManager.GetStatus(const nList: TStrings);
var nIdx,nLen: Integer;
begin
  nList.BeginUpdate;
  try
    nList.Clear;
    //init

    for nIdx:=0 to FObjects.Count - 1 do
    with TStatusObjectBase(FObjects[nIdx]) do
    begin
      if nIdx <> 0 then
        nList.Add('');
      //xxxxx

      nLen := Trunc((85 - Length(ClassName)) / 2);
      nList.Add(StringOfChar('+', nLen) + ' ' + ClassName + ' ' +
                StringOfChar('+', nLen));
      GetStatus(nList);
    end;
  finally
    nList.EndUpdate;
  end;
end;

initialization
  gObjectStatusManager := nil;
finalization
  FreeAndNil(gObjectStatusManager);
end.
