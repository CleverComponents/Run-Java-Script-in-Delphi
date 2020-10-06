unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.SyncObjs,
  SpiderMonkey,
  SyNode,
  SynCommons,
  SyNodeProto,
  SyNodeSimpleProto, Vcl.Samples.Spin;


type
{$M+} //is required for published methods, we can simple inherit from TPersistent instead
  TJobParams = class
  private
    FData: TStrings;
  public
    constructor Create;
    destructor Destroy; override;

    property Data: TStrings read FData;
  published
    function setValue(cx: PJSContext; argc: uintN; var vp: JSArgRec): Boolean;
    function getValue(cx: PJSContext; argc: uintN; var vp: JSArgRec): Boolean;
  end;
{$M-}

  TForm1 = class(TForm)
    btnEvaluate: TButton;
    memSource: TMemo;
    btnThreadEvaluate: TButton;
    btnMultiThreadEvaluate: TButton;
    edtThreadCount: TSpinEdit;
    procedure btnEvaluateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnThreadEvaluateClick(Sender: TObject);
    procedure btnMultiThreadEvaluateClick(Sender: TObject);
  private
    FSMManager: TSMEngineManager;
    FEngine: TSMEngine;
    FJobParams: TJobParams;

    procedure DoOnCreateNewEngine(const aEngine: TSMEngine);
    function DoOnGetEngineName(const aEngine: TSMEngine): RawUTF8;
  end;

  TScriptThread = class(TThread)
  private
    FJobParams: TJobParams;
    FSMManager: TSMEngineManager;
    FScript: string;

    procedure DoOnCreateNewEngine(const aEngine: TSMEngine);
    function DoOnGetEngineName(const aEngine: TSMEngine): RawUTF8;
  protected
    procedure Execute; override;
  public
    constructor Create(const AScript: string; AJobParams: TJobParams);
  end;

var
  Form1: TForm1;
  paramAccessor: TCriticalSection;

implementation

{$R *.dfm}

{$I Synopse.inc}
{$I SynSM.inc}   // define SM_DEBUG JS_THREADSAFE CONSIDER_TIME_IN_Z
{$I SyNode.inc}   // define SM_DEBUG CONSIDER_TIME_IN_Z

procedure TForm1.btnEvaluateClick(Sender: TObject);
var
  res: jsval;
begin
  FEngine.Evaluate(memSource.Lines.Text, 'script.js', 1, res);
  ShowMessage('Done: ' + FJobParams.Data.Text);
end;

procedure TForm1.btnMultiThreadEvaluateClick(Sender: TObject);
var
  thread: TThread;
  script: string;
  i, count: Integer;
begin
  script := memSource.Lines.Text;
  count := edtThreadCount.Value;

  for i := 0 to count - 1 do
  begin
    //tnis simple trick requires the hello.txt name in the source javaScript and allows each thread to use own filename
    thread := TScriptThread.Create(StringReplace(script, 'hello.txt', 'hello' + IntToStr(i) + '.txt', [rfIgnoreCase, rfReplaceAll]), FJobParams);
    thread.FreeOnTerminate := True;
    thread.Start();
  end;

  ShowMessage(Format('%d concurrent threads were started.', [count]));
end;

procedure TForm1.btnThreadEvaluateClick(Sender: TObject);
var
  thread: TThread;
begin
  thread := TScriptThread.Create(memSource.Lines.Text, FJobParams);
  try
    thread.FreeOnTerminate := False;
    thread.Start();

    thread.WaitFor();
  finally
    thread.Free();
  end;

  ShowMessage('Done: ' + FJobParams.Data.Text);
end;

procedure TForm1.DoOnCreateNewEngine(const aEngine: TSMEngine);
begin
  aEngine.defineClass(FJobParams.ClassType, TSMSimpleRTTIProtoObject, aEngine.GlobalObject);
  aEngine.GlobalObject.ptr.DefineProperty(aEngine.cx, 'jobParams',
    CreateJSInstanceObjForSimpleRTTI(aEngine.cx, FJobParams, aEngine.GlobalObject),
    JSPROP_ENUMERATE or JSPROP_READONLY or JSPROP_PERMANENT
  );
end;

function TForm1.DoOnGetEngineName(const aEngine: TSMEngine): RawUTF8;
begin
  Result := 'FormEngine';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FJobParams := TJobParams.Create();
  FJobParams.Data.Values['name1'] := 'value1'; //set up initial data for jobParams

  FSMManager := TSMEngineManager.Create(''); //because we use Node.js modules from a .res file.
  FSMManager.MaxPerEngineMemory := 512 * 1024 * 1024;
  FSMManager.OnNewEngine := DoOnCreateNewEngine;
  FSMManager.OnGetName := DoOnGetEngineName;

  FEngine := FSMManager.ThreadSafeEngine(nil);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FSMManager.ReleaseCurrentThreadEngine();
  FSMManager.Free();
  FJobParams.Free();
end;

{ TJobParams }

constructor TJobParams.Create;
begin
  inherited Create();
  FData := TStringList.Create();
end;

destructor TJobParams.Destroy;
begin
  FData.Free();
  inherited Destroy();
end;

function TJobParams.getValue(cx: PJSContext; argc: uintN; var vp: JSArgRec): Boolean;
begin
  try
    if (argc <> 1) or (not vp.argv[0].isString)  then
    begin
      raise ESMException.Create('getValue accepts one string parameter');
    end;

    paramAccessor.Enter();
    try
      vp.rval := SimpleVariantToJSval(cx, FData.Values[vp.argv[0].asJSString.ToString(cx)]);
    finally
      paramAccessor.Leave();
    end;

    Result :=  true;
  except
    on E: Exception do
    begin
      Result := False;
      JSError(cx, E);
    end;
  end;
end;

function TJobParams.setValue(cx: PJSContext; argc: uintN; var vp: JSArgRec): Boolean;
begin
  try
    if (argc <> 2) then
    begin
      raise ESMException.Create('setValue accepts two string parameters');
    end;

    if not (vp.argv[0].isString and vp.argv[1].isString) then
    begin
      raise ESMException.Create('setValue parameters should be strings');
    end;

    paramAccessor.Enter(); //allows to avoid the thread racing condition
    try
      FData.Values[vp.argv[0].asJSString.ToString(cx)] := vp.argv[1].asJSString.ToString(cx);
    finally
      paramAccessor.Leave();
    end;

    Result :=  true;
  except
    on E: Exception do
    begin
      Result := False;
      JSError(cx, E);
    end;
  end;
end;

{ TScriptThread }

constructor TScriptThread.Create(const AScript: string; AJobParams: TJobParams);
begin
  inherited Create(True);

  FScript := AScript;
  FJobParams := AJobParams;
end;

procedure TScriptThread.DoOnCreateNewEngine(const aEngine: TSMEngine);
begin
  aEngine.defineClass(FJobParams.ClassType, TSMSimpleRTTIProtoObject, aEngine.GlobalObject);
  aEngine.GlobalObject.ptr.DefineProperty(aEngine.cx, 'jobParams',
    CreateJSInstanceObjForSimpleRTTI(aEngine.cx, FJobParams, aEngine.GlobalObject),
    JSPROP_ENUMERATE or JSPROP_READONLY or JSPROP_PERMANENT
  );
end;

function TScriptThread.DoOnGetEngineName(const aEngine: TSMEngine): RawUTF8;
begin
  Result := RawUTF8(Format('ThreadEngine%d', [GetCurrentThreadId()])); //we need to uniquely identify a js engine per each thread
end;

procedure TScriptThread.Execute;
var
  res: jsval;
  engineThread: TSMEngine;
begin
  FSMManager := TSMEngineManager.Create('');
  try
    FSMManager.MaxPerEngineMemory := 512 * 1024 * 1024;
    FSMManager.OnNewEngine := DoOnCreateNewEngine;
    FSMManager.OnGetName := DoOnGetEngineName;

    engineThread := FSMManager.ThreadSafeEngine(nil);
    engineThread.Evaluate(FScript, 'script.js', 1, res);
  finally
    FSMManager.ReleaseCurrentThreadEngine();
    FSMManager.Free();
  end;
end;

initialization
  paramAccessor := TCriticalSection.Create();

finalization
  paramAccessor.Free();

end.
