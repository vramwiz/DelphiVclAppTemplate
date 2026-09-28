unit DarkMenuTestForm;
interface
uses System.Classes, System.Types, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  VectArtDarkPopupMenu, VectArtDarkMenuGroup;
type
  TDemoForm = class(TForm)
  private
    FGroup: TVectArtDarkMenuGroup;
    FFirst, FSecond, FChild, FContext: TVectArtDarkPopupMenu;
    FLabel: TLabel;
    procedure ItemClick(Sender: TObject);
    procedure ContextMenu(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;
var DemoForm: TDemoForm;
implementation
uses Vcl.ExtCtrls;
constructor TDemoForm.Create(AOwner: TComponent);
var Bar: TPanel;
begin
  inherited CreateNew(AOwner);
  Caption := 'Dark Menu Test'; ClientWidth := 660; ClientHeight := 400; Position := poScreenCenter;
  Bar := TPanel.Create(Self); Bar.Parent := Self; Bar.Align := alTop; Bar.Height := 40;
  FLabel := TLabel.Create(Self); FLabel.Parent := Self; FLabel.SetBounds(24,300,600,24);
  FLabel.Caption := 'Open menus / submenu / right-click background / Escape / click outside';
  FFirst := TVectArtDarkPopupMenu.CreateForHosts(Self, Self, Bar, 'First', 0,100,220,110);
  FSecond := TVectArtDarkPopupMenu.CreateForHosts(Self, Self, Bar, 'Second', 100,100,220,70);
  FChild := TVectArtDarkPopupMenu.CreatePopup(Self,Self,180,70);
  FContext := TVectArtDarkPopupMenu.CreatePopup(Self,Self,220,70);
  FFirst.AddItem('Action',0,ItemClick);
  FFirst.AddSubMenu('More',32,FChild);
  FFirst.SetItemEnabled(FFirst.AddItem('Disabled',64,ItemClick),False);
  FSecond.AddItem('Second action',0,ItemClick);
  FChild.AddItem('Child action',0,ItemClick);
  FContext.AddItem('Context action',0,ItemClick);
  FGroup := TVectArtDarkMenuGroup.Create(Self);
  FGroup.RegisterMenu(FFirst); FGroup.RegisterMenu(FSecond); FGroup.RegisterMenu(FContext);
  OnContextPopup := ContextMenu;
end;
destructor TDemoForm.Destroy;
begin
  // Group keeps non-owning references: stop monitoring before freeing menus.
  FGroup.Free;
  FFirst.Free; FSecond.Free; FContext.Free; FChild.Free;
  inherited;
end;
procedure TDemoForm.ItemClick(Sender: TObject);
begin
  FLabel.Caption := 'Action invoked';
  FGroup.CloseAll;
end;
procedure TDemoForm.ContextMenu(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  if MousePos.X<0 then MousePos := Point(40,80);
  FContext.OpenAtScreenPoint(ClientToScreen(MousePos)); Handled := True;
end;
end.
