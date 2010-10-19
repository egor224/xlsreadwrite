unit xlsRegister;

{ Register calls.
                              ---
  The contents of this file may be used under the terms of the GNU General
  Public License Version 2 (the "GPL"). As a special exception you may
  link to non-free (proprietary) Flexcel code (http://www.tmssoftware.com).
                              ---
  The software is provided in the hope that it will be useful but without any
  express or implied warranties, including, but not without limitation, the
  implied warranties of merchantability and fitness for a particular purpose.
                              ---
  Copyright (C) 2006 - 2010 by Hans-Peter Suter, Treetron, Switzerland.
  All rights reserved.
                              ---                                              }

{==============================================================================}
interface
uses
  rhRDynload, rhxTypesAndConsts;

procedure R_init_xlsReadWrite( _info: pDllInfo ); cdecl;
procedure R_unload_xlsReadWrite( _info: pDllInfo ); cdecl;


{==============================================================================}
implementation
uses
  SysUtils, rhR, rhRInternals, xlsRead, xlsWrite, xlsHelpR, xlsDateTime, DateUtils;

{ --------------------------------------------------------- R_init_<myLib> }

procedure R_init_xlsReadWrite( _info: pDllInfo ); cdecl;
  const
    theCallMethods: array[0..4] of aCallMethodDef
                    = ( ( cadName: 'ReadXls'
                        ; cadFunc: @xlsRead.ReadXls
                        ; cadNumArgs: 11 )
                      , ( cadName: 'WriteXls'
                        ; cadFunc: @xlsWrite.WriteXls
                        ; cadNumArgs: 7 )
                      , ( cadName: 'DateTimeXls'
                        ; cadFunc: @xlsDateTime.DateTimeXls
                        ; cadNumArgs: 3 )
                      , ( cadName: 'R_unload_xlsReadWrite'
                        ; cadFunc: @R_unload_xlsReadWrite
                        ; cadNumArgs: 1 )
                      , ( cadName: nil; cadFunc: nil; cadNumArgs: 0 ) );

  begin
    try
      rRegisterRoutines( _info, nil, @theCallMethods, nil, nil );
      rUseDynamicSymbols( _info, False );
    except
      on E: Exception do begin
        rError( pChar('Unexpected error in R_init_xlsReadWrite. Message: ' + E.Message) );
      end;
    end;
  end;

procedure R_unload_xlsReadWrite( _info: pDllInfo ); cdecl;
  begin
    ConsoleMsg( 'xlsReadWrite.dll unloaded%s' );
  end;


end {xlsRegister}.
