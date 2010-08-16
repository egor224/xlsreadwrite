unit xlsUtils;

{ Helpers.
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
  SysUtils, rhRInternals, rhxTypesAndConsts, xlsHelpR;

type
  ExlsReadWrite = class( Exception );

  aOutputType = ( otUndefined, otDouble, otInteger, otLogical
                , otCharacter, otDataFrame, otNumeric );
  aRowNameKind =( rnNA, rnTrue, rnFalse, rnSupplied );

const
  TheNAString =     'NA';   // see remark in pro vesion
  TheNaNString =    'NaN';

  TheOutputType: array[aOutputType] of string
                 = ( 'undefined', 'double', 'integer', 'logical'
                   , 'character', 'data.frame', 'numeric' );
  TheRowNameKind:array[aRowNameKind] of string
                 = ( 'NA', 'True', 'False', 'Supplied' );

function DateTimeToStrFmt( const _format: string; _dateTime: TDateTime ): string;
                 
function StrToOutputType( const _type: string ): aOutputType;
function AllOutputTypes(): string;

function VarAsBool(const _v: variant; _default: boolean; _navalue: integer): integer;
function VarAsDouble(const _v: variant; _default: double; _nanvalue: double; _navalue: double): double;
function VarAsInt(const _v: variant; _default, _navalue: integer): integer;
function VarAsString( const _v: variant ): string; overload;
function VarAsString( const _v: variant; const _def: string ): string; overload;

function IsLogicalString(const _val: string ): boolean;

function ShlibPath: string;

function ReplaceVersionAndCommit( const _s: string ): string;

function GetWdString(): string;
function EnsureAbsolutePath( const fn: string ): string;

function GetScalarString( _val: pSExp; const _err: string ): string;

{==============================================================================}
implementation
uses
  Windows, Classes, Variants;

function DateTimeToStrFmt( const _format: string; _dateTime: TDateTime ): string;
  begin
    DateTimeToString( result, _format, _dateTime );
  end;

function StrToOutputType( const _type: string ): aOutputType;
  var
    i: aOutputType;
  begin
    for i:= Low( aOutputType) to High( aOutputType ) do begin
      if SameText( _type, theOutputType[i] ) then begin
        result:= i;
        Exit;
      end;
    end {for};
    result:= otUndefined;
  end {StrToOutputType};

function AllOutputTypes(): string;
  var
    i: aOutputType;
  begin
    result:= '';
    for i:= Succ( Low( aOutputType) ) to High( aOutputType ) do begin
      result:= result + ' / ' + theOutputType[i];
    end {for};
    if Length( result ) > 3 then Delete( result, 1, 3 );
  end {AllOutputTypes};

function VarAsBool(const _v: variant; _default: boolean; _navalue: integer): integer;
  const
    eps: double = 1e-17;
    zero: double = 0;
  begin
    case VarType( _v ) of
      varBoolean:       result:= integer(_v);

      varSmallint,
      varInteger,
      varInt64,
      varByte,
      varWord,
      varLongWord:      result:= integer(_v <> 0);

      varSingle,
      varDouble,
      varDate:          result:= integer(Abs( zero - double(_v) ) >= eps);
      varCurrency:      result:= integer(Abs( zero - currency(_v) ) >= eps);

      varOleStr,
      varString:        begin
        result:= integer(StrToBoolDef( _v, _default ));
      end;

      varEmpty,
      varNull: 	        result:= _navalue;
    else
      result:= integer(_default);
    end;
  end {VarAsBool};

function VarAsInt(const _v: variant; _default, _navalue: integer): integer;
  begin
    case VarType( _v ) of
      varShortInt,
      varSmallint,
      varInteger,
      varInt64,
      varByte,
      varWord,
      varLongWord,
      varBoolean:       result:= _v;

      varSingle,
      varDouble,
      varCurrency,
      varDate:          result:= Trunc( _v );

      varOleStr,
      varString:        begin
        result:= StrToIntDef( _v, _default );
      end;

      varEmpty,
      varNull: 	        result:= _navalue;
    else
      result:= _default;
    end {case};
  end {VarAsInt};

function VarAsDouble(const _v: variant; _default: double; _nanvalue: double;
    _navalue: double): double;
  begin
    case VarType( _v ) of
      varSmallint,
      varInteger,
      varSingle,
      varDouble,
      varCurrency,
      varDate,
      varBoolean,
      varShortInt,
      varByte,
      varWord,
      varLongWord,
      varInt64:           result:= _v;

      varOleStr,
      varString:        begin
        result:= StrToFloatDef( _v, _nanvalue );
      end;

      varEmpty,
      varNull: 	          result:= _navalue;
    else
      result:= _default;
    end {case};
  end {VarAsDouble};

function VarAsString( const _v: variant ): string;
  begin
    result:= VarAsString( _v, '' );
  end {VarAsString};

function VarAsString( const _v: variant; const _def: string ): string;
  begin
    if VarIsNull( _v ) or VarIsEmpty( _v ) or (VarType(_v) = varError) then begin
      result:= _def;
    end else if VarType(_v) = varDate then begin
      result:= DateTimeToStr( VarToDateTime( _v ) );
    end else begin
      result:= string(_v);
    end;
  end {VarAsString};

function IsLogicalString(const _val: string ): boolean;
  const
    theLogical: array[0..1] of string = ( 'true', 'false' );
  var
    i: Integer;
  begin
    result:= False;
    for i := Low( theLogical ) to High( theLogical ) do begin
      if AnsiSameText( _val, theLogical[i]) then begin
        result := True;
        Break;
      end;
    end;
  end;

function ShlibPath: string;
  begin
    SetLength( result, 255 );
    Windows.GetModuleFileName( HInstance, pChar(result), 255 );
    SetLength( result, StrLen( pChar(result) ) );
    result:= ExtractFileDir( result );
  end;

function ReplaceVersionAndCommit( const _s: string ): string;
  var
    v, c: string;
    descr, comm: string;
  begin
    v:= ''; c:= '';
    descr:= ShlibPath() + '\..\DESCRIPTION';
    comm:= ShlibPath + '\..\COMMIT';
    if not FileExists( descr ) then begin
        { support debugging from Delphi }
      descr:= ShlibPath() + '\..\..\DESCRIPTION';
      comm:= ShlibPath() + '\..\..\inst\COMMIT';
    end;

    if FileExists( descr ) then begin
      with TStringList.Create() do try
        LoadFromFile( descr );
        NameValueSeparator:= ':';
        v:= Trim( Values['Version'] );
        if v = '0.0.0' then v:= '0.0.0/devel';
      finally
        Free();
      end;
    end else begin
      v:= '<version_info_missing>';
    end;
    if FileExists( comm ) then begin
      with TStringList.Create() do try
        LoadFromFile( comm );
        if Count > 0 then c:= Strings[0];
        System.Delete( c, 11, 99 );
        if (Count > 1) and (Pos( 'dirty', Strings[1] ) > -1) then begin
          c:= c + '-d';
        end;
      finally
        Free();
      end;
    end else begin
      c:= '<commit_info_missing>';
    end;

    if v = '' then v:= '<missing>';
    if c = '' then c:= '<missing>';
    result:= StringReplace( _s, '@version@', v, [] );
    result:= StringReplace( result, '@commit@', c, [] );
  end;

function GetWdString(): string;
  var
    wd: pSExp;
  begin
    wd:= GetWd();
    result:= GetScalarString( wd, 'GetWdString: could not retrieve "getwd"' );
  end;

function EnsureAbsolutePath( const fn: string ): string;
  begin
    result:= fn;
    if not ((ExtractFileDrive( fn ) <> '') or
            (Length( fn ) > 0) and (fn[1] = PathDelim))
    then begin
        { construct absolute path using getwd from R }
      result:= GetWdString() + PathDelim + fn;
    end;
  end;

function GetScalarString( _val: pSExp; const _err: string ): string;
  begin
    if riIsString( _val ) and (riLength( _val ) = 1) then begin
      result:= riChar( riStringElt( _val, 0 ) );
    end else begin
      raise ExlsReadWrite.Create( _err );
    end;
  end;

end {xlsUtils}.
