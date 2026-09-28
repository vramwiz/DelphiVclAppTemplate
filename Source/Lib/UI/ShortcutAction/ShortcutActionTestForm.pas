unit ShortcutActionTestForm;
interface
uses System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, ShortcutAction;
type
  TDemoForm = class(TForm)
  private
    FShortcuts: TShortcutAction;
    FCount: Integer;
    FLabel: TLabel;
    FEnabled: TCheckBox;
    FEdit: TEdit;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;
var DemoForm: TDemoForm;
implementation
uses System.SysUtils, Winapi.Windows;
constructor TDemoForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Shortcut Action Test'; ClientWidth := 580; ClientHeight := 220; Position := poScreenCenter;
  KeyPreview := True;
  FLabel := TLabel.Create(Self); FLabel.Parent := Self; FLabel.SetBounds(20,20,530,40);
  FLabel.Caption := 'Ctrl+K: count | x: character action (outside the edit field)';
  FEnabled := TCheckBox.Create(Self); FEnabled.Parent := Self;
  FEnabled.SetBounds(20,80,280,24); FEnabled.Caption := 'Enable shortcuts'; FEnabled.Checked := True;
  FEdit := TEdit.Create(Self); FEdit.Parent := Self; FEdit.SetBounds(20,125,520,24);
  FEdit.TextHint := 'Normal typing must work here';
  FShortcuts := TShortcutAction.Create;
  FShortcuts.Add(Word(Ord('K')), [ssCtrl],
    procedure begin Inc(FCount); FLabel.Caption := Format('Ctrl+K count: %d',[FCount]); end,
    function: Boolean begin Result := FEnabled.Checked; end);
  FShortcuts.Add(Char('x'),
    procedure begin FLabel.Caption := 'KeyPress x handled'; end,
    function: Boolean begin Result := FEnabled.Checked and (ActiveControl<>FEdit); end);
  OnKeyDown := FormKeyDown; OnKeyPress := FormKeyPress;
end;
destructor TDemoForm.Destroy;
begin
  FShortcuts.Free;
  inherited;
end;
procedure TDemoForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FShortcuts.KeyDown(Key,Shift);
end;
procedure TDemoForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  FShortcuts.ProcessKeyPress(Key);
end;
end.
