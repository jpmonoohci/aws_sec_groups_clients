program HCIAwsSecManagerClients;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {HCIAwsSecManCli};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(THCIAwsSecManCli, HCIAwsSecManCli);
  HCIAwsSecManCli.Show;

  if (not HCIAwsSecManCli.VerifyUpdateAvailable()) then
    HCIAwsSecManCli.VerifyStatusServerSemToken();

  Application.Run;

end.
