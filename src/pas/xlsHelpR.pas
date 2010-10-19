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
  Copyright (C) 2006 - 2010 by Hans-Peter Suter, Treetron, Switzerland.
  All rights reserved.
                              ---                                              }

{==============================================================================}
interface
uses
  Variants, rhRInternals, rhxTypesAndConsts;

procedure ConsoleMsg( const _msg: string );

  { call R functions (in the global R environment) }
function GetWd(): pSExp;
function AnyDuplicated( _val: pSExp ): boolean;
function AsFactor( _val: pSExp ): pSExp;
function MakeNames( _names: pSExp ): pSExp;
function IsNaScalar( _x: pSExp ): boolean;

const
  TheLF = #10;
  TheLFLF = #10#10;

{==============================================================================}
implementation
uses
  rhR;

procedure ConsoleMsg( const _msg: string );
  begin
    rRprintf( pChar(_msg + TheLF) );
  end;

function GetWd(): pSExp;
  var
    fcall: pSExp;
  begin
    fcall:= riProtect( riLang1( riInstall( 'getwd' ) ) );
    result:= riProtect( riEval( fcall, RGlobalEnv ) );
    riUnprotect( 2 );
  end;

function anyDuplicated( _val: pSExp ): boolean;
  var
    res, fcall: pSExp;
  begin
    fcall:= riProtect( riLang2( riInstall( 'anyDuplicated' ), _val ) );
    res:= riProtect( riEval( fcall, RGlobalEnv ) );
    result:= riInteger(riCoerceVector( res, setIntSxp ))[0] > 0;
    riUnprotect( 2 );
  end {AnyDuplicated};

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
    unique: pSExp;
  begin
    unique:= riProtect( riScalarLogical( 1 ) );
    fcall:= riProtect( riLang3( riInstall( 'make.names' ), _names, unique ) );
    result:= riProtect( riEval( fcall, RGlobalEnv ) );
    riUnprotect( 3 );
  end {MakeNames};

function IsNaScalar( _x: pSExp ): boolean;
  begin
    result:= (riLength( _x ) = 1) and
             (riTypeOf( _x ) in [setLglSxp, setRealSxp]) and
             (rIsNa( riReal( riCoerceVector( _x, setRealSxp ) )[0] ) <> 0);
  end;


end {xlsHelpR}.
