unit xlsHelpR;

{ R related things.
                              ---
  The contents of this file may be used under the terms of the GNU General
  Public License Version 2 (the "GPL"). As a special exception you may
  link to non-free (proprietary) Flexcel code (http://www.tmssoftware.com).
                              ---
  The software is provided in the hope that it will be useful but without any
  express or implied warranties, including, but not without limitation, the
  implied warranties of merchantability and fitness for a particular purpose.
                              ---
  Copyright (C) 2006 - 2009 by Hans-Peter Suter, Treetron, Switzerland.
  All rights reserved.
                              ---                                              }

{==============================================================================}
interface
uses
  Variants, rhRInternals, rhxTypesAndConsts;

  { call R functions (in the global R environment) }
function GetWd(): pSExp;
function AsFactor( _val: pSExp ): pSExp;
function MakeNames( _names: pSExp ): pSExp;


{==============================================================================}
implementation
uses
  rhR;


function GetWd(): pSExp;
  var
    fcall: pSExp;
  begin
    fcall:= riProtect( riLang1( riInstall( 'getwd' ) ) );
    result:= riProtect( riEval( fcall, RGlobalEnv ) );
    riUnprotect( 2 );
  end;

function AsFactor( _val: pSExp ): pSExp;
  var
    fcall: pSExp;
  begin
    fcall:= riProtect( riLang2( riInstall( 'as.factor' ), _val ) );
    result:= riProtect( riEval( fcall, RGlobalEnv ) );
    riUnprotect( 2 );
  end {AsFactor};

function MakeNames( _names: pSExp ): pSExp;
  var
    fcall: pSExp;
  begin
    fcall:= riProtect( riLang2( riInstall( 'make.names' ), _names ) );
    result:= riProtect( riEval( fcall, RGlobalEnv ) );
    riUnprotect( 2 );
  end {MakeNames};


end {xlsHelpR}.
