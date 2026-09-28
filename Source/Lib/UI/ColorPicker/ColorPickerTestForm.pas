unit ColorPickerTestForm;
interface
uses System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  ColorPickerHueBar, ColorPickerSVArea;
type
  TDemoForm = class(TForm)
  private
    FHue: TColorPickerHueBar;
    FSV: TColorPickerSVArea;
    FPreview: TPanel;
    FInput: TEdit;
    FLabel: TLabel;
    procedure HueChanged(Sender: TObject);
    procedure ColorChanged(Sender: TObject);
    procedure ParseClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;
var DemoForm: TDemoForm;
implementation
uses System.SysUtils, Vcl.Graphics, Winapi.Windows, ColorCode, ColorPickerColorMath;
constructor TDemoForm.Create(AOwner: TComponent);
var Button: TButton;
begin
  inherited CreateNew(AOwner);
  Caption := 'Color Picker Test'; ClientWidth := 560; ClientHeight := 400; Position := poScreenCenter;
  FSV := TColorPickerSVArea.Create(Self); FSV.Parent := Self; FSV.SetBounds(20,20,320,260);
  FHue := TColorPickerHueBar.Create(Self); FHue.Parent := Self; FHue.SetBounds(20,295,320,28);
  FPreview := TPanel.Create(Self); FPreview.Parent := Self; FPreview.SetBounds(365,20,170,100);
  FPreview.ParentBackground := False; FPreview.StyleElements := [];
  FInput := TEdit.Create(Self); FInput.Parent := Self; FInput.SetBounds(365,145,170,24);
  FInput.Text := '#FF0000';
  Button := TButton.Create(Self); Button.Parent := Self; Button.SetBounds(365,180,170,30);
  Button.Caption := 'Parse HEX / RGB'; Button.OnClick := ParseClick;
  FLabel := TLabel.Create(Self); FLabel.Parent := Self; FLabel.SetBounds(20,350,510,24);
  FHue.OnChange := HueChanged; FSV.OnChange := ColorChanged;
  ColorChanged(Self);
end;
procedure TDemoForm.HueChanged(Sender: TObject);
var H, S, V: Double;
begin
  ColorToHsv(FSV.Color,H,S,V);
  FSV.BaseColor := FHue.Color;
  FSV.Color := HsvToColor(ColorHue(FHue.Color),S,V);
  ColorChanged(Self);
end;
procedure TDemoForm.ColorChanged(Sender: TObject);
var C: TColor;
begin
  C := ColorToRGB(FSV.Color); FPreview.Color := C;
  FLabel.Caption := Format('#%.2x%.2x%.2x  RGB(%d,%d,%d)',
    [GetRValue(C),GetGValue(C),GetBValue(C),GetRValue(C),GetGValue(C),GetBValue(C)]);
end;
procedure TDemoForm.ParseClick(Sender: TObject);
var C: TColor;
begin
  if not TryParseColorCode(FInput.Text,C) then begin FLabel.Caption := 'Invalid color'; Exit; end;
  FHue.Color := C; FSV.BaseColor := C; FSV.Color := C;
  ColorChanged(Self);
end;
end.
