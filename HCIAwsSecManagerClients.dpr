program HCIAwsSecManagerClients;



uses
  Vcl.Forms,
  Service in 'Service.pas' {srvService: TService},
  frmMain in 'frmMain.pas' {HCIAwsSecManCli},
  Server.Runner in 'Server.Runner.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(THCIAwsSecManCli, HCIAwsSecManCli);
  Application.CreateForm(TsrvService, srvService);
  ;
  Application.Run;
end.
