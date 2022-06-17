program HCIAwsLauncher;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {HCIAwsSecManCli},
  FrmLogin in 'FrmLogin.pas' {Login};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(THCIAwsSecManCli, HCIAwsSecManCli);
  Application.CreateForm(TLogin, Login);
  HCIAwsSecManCli.Show;

  if (not HCIAwsSecManCli.VerifyUpdateAvailable()) then
    HCIAwsSecManCli.VerifyStatusServerSemToken();

  Application.Run;

end.
