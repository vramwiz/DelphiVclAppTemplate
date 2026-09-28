unit HorizontalTrackBarTestForm;
interface
uses System.Classes, Vcl.Forms, Vcl.StdCtrls, HorizontalTrackBarControl;
type
  TDemoForm = class(TForm)
  private
    FBar: THorizontalTrackBarControl;
    FLabel: TLabel;
    FEnabled, FTicks, FWheel: TCheckBox;
    procedure Changed(Sender: TObject);
    procedure Options(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;
var DemoForm: TDemoForm;
implementation
uses System.SysUtils;
constructor TDemoForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Horizontal Trackbar Test'; ClientWidth := 560; ClientHeight := 240;
  Position := poScreenCenter;
  FLabel := TLabel.Create(Self); FLabel.Parent := Self; FLabel.SetBounds(20,20,500,24);
  FBar := THorizontalTrackBarControl.Create(Self); FBar.Parent := Self;
  FBar.SetBounds(20,60,500,50); FBar.SetRange(-100,100); FBar.Position := 0;
  FBar.OnChange := Changed;
  FEnabled := TCheckBox.Create(Self); FEnabled.Parent := Self;
  FEnabled.SetBounds(20,140,140,24); FEnabled.Caption := 'Enabled'; FEnabled.Checked := True;
  FTicks := TCheckBox.Create(Self); FTicks.Parent := Self;
  FTicks.SetBounds(180,140,140,24); FTicks.Caption := 'Show ticks'; FTicks.Checked := True;
  FWheel := TCheckBox.Create(Self); FWheel.Parent := Self;
  FWheel.SetBounds(340,140,180,24); FWheel.Caption := 'Wheel changes value'; FWheel.Checked := True;
  FEnabled.OnClick := Options; FTicks.OnClick := Options; FWheel.OnClick := Options;
  Changed(Self);
end;
procedure TDemoForm.Changed(Sender: TObject);
begin
  FLabel.Caption := Format('Value: %d   Range: -100..100   Drag / wheel / keyboard', [FBar.Position]);
end;
procedure TDemoForm.Options(Sender: TObject);
begin
  FBar.Enabled := FEnabled.Checked; FBar.ShowTicks := FTicks.Checked;
  FBar.WheelChangesPosition := FWheel.Checked;
end;
end.
