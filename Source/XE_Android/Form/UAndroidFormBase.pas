unit UAndroidFormBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Controls.Presentation, FMX.Layouts,
  FMX.VirtualKeyboard, FMX.Platform;

type
  TfrmFormBase = class(TForm)
    MainVertScrollBox: TScrollBox;
    MainLayout: TLayout;
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormFocusChanged(Sender: TObject);
    procedure EditMouseEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    // ���̲������
    FKBBounds: TRectF;
    FNeedOffset: Boolean;
    FService: IFMXVirtualKeyboardToolbarService;
    FService_kb: FMX.VirtualKeyboard.IFMXVirtualKeyboardService;

    procedure UpdateKBBounds;
    procedure RestorePosition;
    procedure CalcContentBoundsProc(Sender: TObject; var ContentBounds: TRectF);
  public
    { Public declarations }
  end;

var
  frmFormBase: TfrmFormBase;

implementation

{$R *.fmx}

procedure TfrmFormBase.FormCreate(Sender: TObject);
begin
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
  IInterface(FService_kb));
  if TPlatformServices.Current.SupportsPlatformService
  (IFMXVirtualKeyboardToolbarService, IInterface(FService)) then
  begin
    FService.SetToolbarEnabled(true);
    FService.SetHideKeyboardButtonVisibility(true);
  end;
  MainVertScrollBox.OnCalcContentBounds := CalcContentBoundsProc;
end;

procedure TfrmFormBase.FormFocusChanged(Sender: TObject);
begin
  UpdateKBBounds;
end;

procedure TfrmFormBase.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds.Create(0, 0, 0, 0);
  FNeedOffset := False;//��ʶ����Ҫ�������пؼ���λ��
  RestorePosition;
end;

procedure TfrmFormBase.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds := TRectF.Create(Bounds);
  FKBBounds.TopLeft := ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight := ScreenToClient(FKBBounds.BottomRight);
  UpdateKBBounds;
end;

procedure TfrmFormBase.EditMouseEnter(Sender: TObject);
begin
  { Android: ��Щ���뷨�����ؼ�(�� qq�� �ٶȵ�), ��������̰������ؼ���(���ᴥ��
  VirtualKeyboardOnHide �¼�), ��ʱ�ٵ���༭�����ٲ�����ʾ�������,
  ���������ж������Ѿ��н���ʱ���ٴδ�����ʾ�� IOS: ��δ���� }
  {$IFDEF ANDROID}
  if TEdit(Sender).IsFocused and Assigned(FService_kb) then
  try
    FService_kb.ShowVirtualKeyboard(TEdit(Sender));
  except
  end;
  {$ENDIF}
end;

function Max(const x, y: Single): Single;
begin
  if x>y then
       Result := x
  else Result := y;
end;

procedure TfrmFormBase.CalcContentBoundsProc(Sender: TObject; var ContentBounds: TRectF);
begin
  if FNeedOffset and (FKBBounds.Top > 0) then
  begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom, 2 * ClientHeight - FKBBounds.Top);
  end;
end;

procedure TfrmFormBase.RestorePosition; //��ԭ���пؼ���λ��
begin
  MainVertScrollBox.ViewportPosition := PointF(MainVertScrollBox.ViewportPosition.X, 0);
  MainLayout.Align := TAlignLayout.alClient;
  MainVertScrollBox.RealignContent;
end;

//Discrpit:�������пؼ���λ�ã����������ƶ�һ��������̵ĸ߶�
procedure TfrmFormBase.UpdateKBBounds;
var
  LFocused: TControl;
  LFocusRect: TRectF;
begin
  FNeedOffset := False;
  //xxxxx

  if Assigned(Focused) then
  begin
    LFocused := TControl(Focused.GetObject);
    LFocusRect := LFocused.AbsoluteRect;
    LFocusRect.Offset(MainVertScrollBox.ViewportPosition);

    if (LFocusRect.IntersectsWith(TRectF.Create(FKBBounds))) and
    (LFocusRect.Bottom > FKBBounds.Top) then
    begin
      FNeedOffset := True;

      Application.ProcessMessages;
      MainLayout.Align := TAlignLayout.alHorizontal;

      MainVertScrollBox.RealignContent;
      MainVertScrollBox.ViewportPosition :=PointF(MainVertScrollBox.ViewportPosition.X * 4,
                                        (LFocusRect.Bottom - FKBBounds.Top)*4);
      //xxxx
    end;
  end;

  if not FNeedOffset then
    RestorePosition;
end;

end.
