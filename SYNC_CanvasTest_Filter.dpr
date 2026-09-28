library SYNC_CanvasTest_Filter;

uses
  System.SysUtils,
  AviUtl2FilterTypes in 'Source\Lib\Kits\AviUtl2Canvas\Source\Host\AviUtl2FilterTypes.pas',
  SyncCanvasPlugin in 'Source\Lib\Kits\AviUtl2Canvas\Source\Host\SyncCanvasPlugin.pas';

function InitializePlugin(Version: Cardinal): Byte; cdecl;
begin
  try
    InitializeCanvasPlugin;
    Result := 1;
  except
    Result := 0;
  end;
end;

procedure UninitializePlugin; cdecl;
begin
  try
    FinalizeCanvasPlugin;
  except
    // No exception may cross the host ABI.
  end;
end;

function GetFilterPluginTable: PFILTER_PLUGIN_TABLE; cdecl;
begin
  try
    Result := CanvasPluginTable;
  except
    Result := nil;
  end;
end;

exports
  InitializePlugin name 'InitializePlugin',
  UninitializePlugin name 'UninitializePlugin',
  GetFilterPluginTable name 'GetFilterPluginTable';

begin
end.