program CanvasTests;
{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Types, System.Math, System.JSON,
  Vcl.Forms, Winapi.Windows, Winapi.D3D11, Winapi.D3DCommon, Winapi.DXGIFormat,
  AviUtl2FilterTypes, PluginFilterContextManager, SyncFrameCapture,
  SyncCanvasView, SyncCanvasEditor;

var Texture: ID3D11Texture2D;

procedure TestDll(const FileName: string);
var Module: HMODULE;
  Initialize: function(Version: Cardinal): Byte; cdecl;
  Finalize: procedure; cdecl;
  GetTable: function: PFILTER_PLUGIN_TABLE; cdecl;
  Table: PFILTER_PLUGIN_TABLE;
begin
  Module := LoadLibrary(PChar(FileName));
  if Module = 0 then RaiseLastOSError;
  try
    @Initialize := GetProcAddress(Module, 'InitializePlugin');
    @Finalize := GetProcAddress(Module, 'UninitializePlugin');
    @GetTable := GetProcAddress(Module, 'GetFilterPluginTable');
    if not Assigned(Initialize) or not Assigned(Finalize) or not Assigned(GetTable) then
      raise Exception.Create('Missing plugin exports');
    if Initialize(0) <> 1 then raise Exception.Create('Plugin initialization failed');
    try
      Table := GetTable();
      if (Table=nil) or (string(Table.Label_)<>'SYNC') or
        (string(Table.Name)<>'キャンバステスト') then raise Exception.Create('Invalid plugin registration');
      if Table.Func_Proc_Video(nil)<>1 then raise Exception.Create('Pass-through failed');
      Writeln('PASS: DLL exports, initialize, SYNC registration, callback, finalize');
    finally Finalize(); end;
  finally FreeLibrary(Module); end;
end;

function GetTexture: Pointer; cdecl;
begin
  Result := Pointer(Texture);
end;

procedure Check(Condition: Boolean; const Description: string);
begin
  if not Condition then raise Exception.Create(Description);
  Writeln('PASS: ', Description);
end;

procedure Run;
var Device: ID3D11Device; DC: ID3D11DeviceContext; Level: D3D_FEATURE_LEVEL;
  Desc: D3D11_TEXTURE2D_DESC; Initial: D3D11_SUBRESOURCE_DATA;
  Pixels, Actual: TBytes; I, Width, Height: Integer; Status, Saved: string;
  Capture: TSyncFrameCapture; Video: TFILTER_PROC_VIDEO;
  Editor, Reloaded: TSyncCanvasEditor;
  Contexts: TPluginFilterContextList<TPluginFilterContextItem>;
  ObjectInfo: TOBJECT_INFO; First: TPluginFilterContextItem;
begin
  SetLength(Pixels, 257*3*4);
  for I := 0 to Length(Pixels)-1 do Pixels[I] := Byte(I mod 251);
  Check(D3D11CreateDevice(nil, D3D_DRIVER_TYPE_WARP, 0, 0, nil, 0,
    D3D11_SDK_VERSION, Device, Level, DC) >= 0, 'D3D11 WARP device');
  Desc := Default(D3D11_TEXTURE2D_DESC);
  Desc.Width := 257; Desc.Height := 3; Desc.MipLevels := 1; Desc.ArraySize := 1;
  Desc.Format := DXGI_FORMAT_R8G8B8A8_UNORM; Desc.SampleDesc.Count := 1;
  Desc.Usage := D3D11_USAGE_DEFAULT;
  Initial := Default(D3D11_SUBRESOURCE_DATA);
  Initial.pSysMem := @Pixels[0]; Initial.SysMemPitch := 257*4;
  Check(Device.CreateTexture2D(Desc, @Initial, Texture) >= 0, 'Test GPU texture');
  Video := Default(TFILTER_PROC_VIDEO);
  Video.GetFramebufferTexture2D := GetTexture;
  Capture := TSyncFrameCapture.Create;
  try
    Capture.Capture(@Video);
    Check(Capture.CopyRgba(Actual, Width, Height, Status), 'GPU snapshot available');
    Check((Width=257) and (Height=3) and (Length(Actual)=Length(Pixels)) and
      CompareMem(@Pixels[0], @Actual[0], Length(Pixels)), 'GPU pixels and row pitch');
    Capture.Capture(nil);
    Check(not Capture.CopyRgba(Actual, Width, Height, Status), 'Unavailable capture clears stale image');
  finally Capture.Free; Texture := nil; end;
  Pixels := TBytes.Create(10,20,30,255);
  Actual := ConvertSyncFramebufferToRgba(Pixels,1,1,Ord(DXGI_FORMAT_B8G8R8A8_UNORM));
  Check((Actual[0]=30) and (Actual[2]=10), 'BGRA conversion');
  Check(Length(ConvertSyncFramebufferToRgba(Pixels,2,1,Ord(DXGI_FORMAT_R8G8B8A8_UNORM)))=0,
    'Invalid buffer rejected');
  Contexts := TPluginFilterContextList<TPluginFilterContextItem>.Create;
  try
    ObjectInfo := Default(TOBJECT_INFO); ObjectInfo.ID := 1; ObjectInfo.EffectID := 1;
    Video.Object_ := @ObjectInfo;
    First := Contexts.GetContext(@Video);
    Check(First=Contexts.GetContext(@Video), 'Same object/effect reuses context');
    ObjectInfo.EffectID := 2;
    Check(First<>Contexts.GetContext(@Video), 'Different effect uses separate context');
    Check(Contexts.FindByObjectLocation(0,0,0)=nil, 'Ambiguous location never returns another effect');
  finally Contexts.Free; end;
  Editor := TSyncCanvasEditor.Create(nil);
  Reloaded := TSyncCanvasEditor.Create(nil);
  try
    Editor.LoadSnapshot(Pixels,1,1,'','test');
    Editor.View.SetView(1,10,20);
    Editor.View.ZoomAt(2,Point(100,100));
    Check(SameValue(Editor.View.Zoom,2) and SameValue(Editor.View.PanX,-80) and
      SameValue(Editor.View.PanY,-60), 'Zoom keeps pointer anchor');
    Editor.View.PanBy(12,34);
    Saved := Editor.SaveData;
    Reloaded.LoadSnapshot(Pixels,1,1,Saved,'test');
    Check(SameValue(Reloaded.View.Zoom,2) and SameValue(Reloaded.View.PanX,-68) and
      SameValue(Reloaded.View.PanY,-26), 'JSON round trip preserves pan and zoom');
    if ParamStr(1)='--ui' then
    begin
      SetLength(Pixels,640*360*4);
      for I := 0 to 640*360-1 do
      begin
        Pixels[I*4] := Byte((I mod 640)*255 div 639);
        Pixels[I*4+1] := Byte((I div 640)*255 div 359);
        Pixels[I*4+2] := 80; Pixels[I*4+3] := 255;
      end;
      Editor.LoadSnapshot(Pixels,640,360,'','Synthetic RGBA UI fixture');
      Editor.ShowModal;
      Writeln(Editor.SaveData);
    end;
  finally Reloaded.Free; Editor.Free; end;
end;

begin
  Application.Initialize;
  try
    Run;
    if (ParamCount=2) and (ParamStr(1)='--dll') then TestDll(ParamStr(2));
  except
    on E: Exception do begin Writeln('FAIL: ',E.Message); ExitCode := 1; end;
  end;
end.
