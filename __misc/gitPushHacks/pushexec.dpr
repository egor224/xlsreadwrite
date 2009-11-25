program pushexec;

{$APPTYPE CONSOLE}

uses
  SysUtils, ShellApi, Windows;

begin
  try
    ShellExecute( 0, nil, 'push-rel2redmine.bat', nil, nil, SW_SHOWNORMAL );
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
