program HorizontalTrackBarTest;
uses Vcl.Forms, Vcl.Themes, Vcl.Styles, HorizontalTrackBarTestForm in 'HorizontalTrackBarTestForm.pas';
{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows Modern Dark');
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.