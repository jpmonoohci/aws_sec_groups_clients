program HCIAwsLauncher;



uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {HCIAwsSecManCli},
  FrmLogin in 'FrmLogin.pas' {Login},
  FrmPix in 'FrmPix.pas' {FormPix},
  TCustomIdHTTPUnit in 'TCustomIdHTTPUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(THCIAwsSecManCli, HCIAwsSecManCli);
  Application.CreateForm(TLogin, Login);
  Application.CreateForm(TForm1, FormPix);
  HCIAwsSecManCli.Show;

  if (not HCIAwsSecManCli.VerifyUpdateAvailable()) then
    HCIAwsSecManCli.VerifyStatusServerSemToken();

  Application.Run;

end.
