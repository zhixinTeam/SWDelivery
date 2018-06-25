{*******************************************************************************
  ����: dmzn@163.com 2013-11-23
  ����: ģ�鹤������,������Ӧ����¼�
*******************************************************************************}
unit UEventWorker;

{$I Link.Inc}
interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UPlugConst;

type
  TPlugWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //���в���

implementation

class function TPlugWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := sPlug_ModuleBus;
    FModuleName := '����ҵ��';
    FModuleVersion := '2014-09-01';
    FModuleDesc := '�ṩˮ��һ��ͨ������ҵ���߼��������';
    FModuleBuildTime:= Str2DateTime('2014-09-01 15:01:01');
  end;
end;

procedure TPlugWorker.RunSystemObject(const nParam: PPlugRunParameter);
begin
  gPlugRunParam := nParam^;
end;

{$IFDEF DEBUG}
procedure TPlugWorker.GetExtendMenu(const nList: TList);
var nItem: PPlugMenuItem;
begin
  New(nItem);
  nList.Add(nItem);
  nItem.FName := 'Menu_Param_1';

  nItem.FModule := ModuleInfo.FModuleID;
  nItem.FCaption := 'ҵ�����';
  nItem.FFormID := cFI_FormTest1;
  nItem.FDefault := False;
end;
{$ENDIF}

end.
