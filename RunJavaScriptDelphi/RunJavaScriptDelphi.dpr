program RunJavaScriptDelphi;

uses
  FastMM4,
  FastMM4Messages,
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  NSPRAPI,
  SpiderMonkey,
  SyNode,
  SyNodeBinding_buffer,
  SyNodeBinding_const,
  SyNodeBinding_fs,
  SyNodeBinding_HTTPClient,
  SyNodeBinding_util,
  SyNodeBinding_uv,
  SyNodeBinding_worker,
  SyNodeReadWrite,
  SyNodeSimpleProto,
  SyNodeProto;

{$R *.res}

begin
  InitJS;
  try
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  finally
    Form1.Free();
    ShutDownJS;
  end;
end.
