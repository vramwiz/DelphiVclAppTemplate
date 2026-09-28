program DelphiVclAppTemplate;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  DelphiVclAppTemplateMainForm in 'Source\Shell\DelphiVclAppTemplateMainForm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  TStyleManager.TrySetStyle('Windows Modern Dark');
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Delphi VCL App Template';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
