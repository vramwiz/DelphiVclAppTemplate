program VerticalScrollBarTest;

uses
  Vcl.Forms, Vcl.Themes, Vcl.Styles,
  VerticalScrollBarControl in 'Lib\UI\VerticalScrollBar\VerticalScrollBarControl.pas',
  VerticalScrollBarTestForm in 'Lib\UI\VerticalScrollBar\Tests\VerticalScrollBarTestForm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Vertical Scrollbar Test';
  TStyleManager.TrySetStyle('Windows Modern Dark');
  Application.CreateForm(TScrollBarTestForm, ScrollBarTestForm);
  Application.Run;
end.
