program RunJavaScriptDelphi;

uses
  FastMM4 in '..\..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\..\FastMM\FastMM4Messages.pas',
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  NSPRAPI in '..\..\23\mORMot\SyNode\NSPRAPI.pas',
  SpiderMonkey in '..\..\23\mORMot\SyNode\SpiderMonkey.pas',
  SyNode in '..\..\23\mORMot\SyNode\SyNode.pas',
  SyNodeBinding_buffer in '..\..\23\mORMot\SyNode\SyNodeBinding_buffer.pas',
  SyNodeBinding_const in '..\..\23\mORMot\SyNode\SyNodeBinding_const.pas',
  SyNodeBinding_fs in '..\..\23\mORMot\SyNode\SyNodeBinding_fs.pas',
  SyNodeBinding_HTTPClient in '..\..\23\mORMot\SyNode\SyNodeBinding_HTTPClient.pas',
  SyNodeBinding_util in '..\..\23\mORMot\SyNode\SyNodeBinding_util.pas',
  SyNodeBinding_uv in '..\..\23\mORMot\SyNode\SyNodeBinding_uv.pas',
  SyNodeBinding_worker in '..\..\23\mORMot\SyNode\SyNodeBinding_worker.pas',
  SyNodeReadWrite in '..\..\23\mORMot\SyNode\SyNodeReadWrite.pas',
  SyNodeSimpleProto in '..\..\23\mORMot\SyNode\SyNodeSimpleProto.pas',
  SyNodeProto in '..\..\23\mORMot\SyNode\SyNodeProto.pas';

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
