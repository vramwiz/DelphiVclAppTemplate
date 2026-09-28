program ColorPickerTest;
uses Vcl.Forms, Vcl.Themes, Vcl.Styles, ColorPickerTestForm in 'ColorPickerTestForm.pas';
{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows Modern Dark');
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.