unit xlsDateTime;

{ Date/Time functionality.
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
  rhRInternals, rhxTypesAndConsts, xlsUtils;

function DateTimeXls( _what, _val, _fmt: pSExp ): pSExp; cdecl;

{==============================================================================}
implementation
uses
  SysUtils, DateUtils, Variants, Classes, Math, rhR, xlsHelpR;

{ --------------------------------------------------------- date time routines }
{ taken from the pro version (lcid removed (can be worked around with iso strings)) }

function IsoStrToDateTime( const _val: string ): TDateTime;
  begin
    case Length( _val ) of
      8: begin
        if Pos( ':', _val ) > 0 then begin
          result:= EncodeTime( StrToInt( Copy( _val, 1, 2 ) ),
              StrToInt( Copy( _val, 4, 2 ) ), StrToInt( Copy( _val, 7, 2 ) ), 0 );
        end else begin
          result:= EncodeDate( StrToInt( Copy( _val, 1, 4 ) ),
              StrToInt( Copy( _val, 5, 2 ) ), StrToInt( Copy( _val, 7, 2 ) ) );
        end;
      end;
      10: begin
        result:= EncodeDate( StrToInt( Copy( _val, 1, 4 ) ),
            StrToInt( Copy( _val, 6, 2 ) ), StrToInt( Copy( _val, 9, 2 ) ) );
      end;
      14: begin
        result:= EncodeDateTime( StrToInt( Copy( _val, 1, 4 ) ),
            StrToInt( Copy( _val, 5, 2 ) ), StrToInt( Copy( _val, 7, 2 ) ),
            StrToInt( Copy( _val, 9, 2 ) ), StrToInt( Copy( _val, 11, 2 ) ),
            StrToInt( Copy( _val, 13, 2 ) ), 0 );
      end;
      19: begin
        result:= EncodeDateTime( StrToInt( Copy( _val, 1, 4 ) ),
            StrToInt( Copy( _val, 6, 2 ) ), StrToInt( Copy( _val, 9, 2 ) ),
            StrToInt( Copy( _val, 12, 2 ) ), StrToInt( Copy( _val, 15, 2 ) ),
            StrToInt( Copy( _val, 18, 2 ) ), 0 );
      end;
      21: begin
        result:= EncodeDateTime( StrToInt( Copy( _val, 1, 4 ) ),
            StrToInt( Copy( _val, 6, 2 ) ), StrToInt( Copy( _val, 9, 2 ) ),
            StrToInt( Copy( _val, 12, 2 ) ), StrToInt( Copy( _val, 15, 2 ) ),
            StrToInt( Copy( _val, 18, 2 ) ), StrToInt( Copy( _val, 21, 1 ) )*100 );
      end;
      22: begin
        result:= EncodeDateTime( StrToInt( Copy( _val, 1, 4 ) ),
            StrToInt( Copy( _val, 6, 2 ) ), StrToInt( Copy( _val, 9, 2 ) ),
            StrToInt( Copy( _val, 12, 2 ) ), StrToInt( Copy( _val, 15, 2 ) ),
            StrToInt( Copy( _val, 18, 2 ) ), StrToInt( Copy( _val, 21, 2 ) )*10 );
      end;
      23: begin
        result:= EncodeDateTime( StrToInt( Copy( _val, 1, 4 ) ),
            StrToInt( Copy( _val, 6, 2 ) ), StrToInt( Copy( _val, 9, 2 ) ),
            StrToInt( Copy( _val, 12, 2 ) ), StrToInt( Copy( _val, 15, 2 ) ),
            StrToInt( Copy( _val, 18, 2 ) ), StrToInt( Copy( _val, 21, 3 ) ) );
      end;
    else
      raise EXlsReadWrite.CreateFmt( 'date/time string has a length of %d ' +
         'instead of 8, 10, 16, 19 or 21 - 23 (ISO-8601 standard; fraction with 1, 2 or 3 digits supported)', [Length( _val )] );
    end {case};
  end {IsoStrToDateTime};

function xheDateTimeToStr( _date, _fmt: pSExp ): pSExp; cdecl;
  var
    i, nd, nf: integer;
    useSameFmt: boolean;
    fmt: string;
    sdat: string;
    x: double;
  begin
    nd:= riLength( _date );
    nf:= riLength( _fmt );
    useSameFmt:= nf = 1;
    if useSameFmt then begin
      fmt:= riChar( riStringElt( _fmt, 0 ) );
    end else begin
      if nd <> nf then raise EXlsReadWrite.Create( 'Length of format must be 1 or same as length of date' );
    end;
    result:= riProtect( riAllocVector( setStrSxp, nd ));

    for i:= 0 to nd - 1 do begin
      x:= riReal( _date )[i];
      if (rIsNA( x ) <> 0) then begin
        sdat:= TheNAString;
      end else if (rIsNaN( x ) <> 0) then begin
        sdat:= TheNaNString;
      end else if IsNan( x ) then begin
        sdat:= 'my' + TheNaNString;
      end else if (rIsNaN( x ) <> 0) then begin
        sdat:= TheNaNString;
      end else if useSameFmt then begin
        DateTimeToString( sdat, fmt, x )
      end else begin
        DateTimeToString( sdat, riChar( riStringElt( _fmt, i ) ), x )
      end;
      riSetStringElt( result, i, riMkChar( pChar(sdat) ) );
    end {for};
    riUnprotect( 1 );
  end {xheDateTimeToStr};

function xheDateTimeToIsoStr( _date, _isofmt: pSExp ): pSExp; cdecl;
  var
    i, nd, isofmt: integer;
    sdat: string;
    x: double;
  begin
    nd:= riLength( _date );
    isofmt:= riInteger( _isofmt )[0];  // integer is controlled by me
    result:= riProtect( riAllocVector( setStrSxp, nd ));
    for i:= 0 to nd - 1 do begin
      x:= riReal( _date )[i];
      if (rIsNA( x ) <> 0) then begin
        sdat:= TheNAString;
      end else if (rIsNaN( x ) <> 0) then begin
        sdat:= TheNaNString;
      end else case isofmt of
        1: DateTimeToString( sdat, 'yyyymmdd', x );
        2: DateTimeToString( sdat, 'yyyy-mm-dd', x );
        3: DateTimeToString( sdat, 'yyyymmddhhnnss', x );
        4: DateTimeToString( sdat, 'yyyy-mm-dd hh:nn:ss', x );
        5: DateTimeToString( sdat, 'yyyy-mm-dd hh:nn:ss.zzz', x );
      end {case};
      riSetStringElt( result, i, riMkChar( pChar(sdat) ) );
    end {for};
    riUnprotect( 1 );
  end {xheDateTimeToIsoStr};

function xheStrToDateTime( _date: pSExp ): pSExp; cdecl;
  var
    i, nd: integer;
  begin
    nd:= riLength( _date );
    result:= riProtect( riAllocVector( setRealSxp, nd ));
    for i:= 0 to nd - 1 do begin
      riReal( result )[i]:= StrToDateTime( riChar( riStringElt( _date, i ) ) );
    end {for};
    riUnprotect( 1 );
  end {xheStrToDateTime};

function xheIsoStrToDateTime( _date: pSExp ): pSExp; cdecl;
  var
    i, nd: integer;
  begin
    nd:= riLength( _date );
    result:= riProtect( riAllocVector( setRealSxp, nd ));
    for i:= 0 to nd - 1 do begin
      riReal( result )[i]:= IsoStrToDateTime( riChar( riStringElt( _date, i ) ) );
    end {for};
    riUnprotect( 1 );
  end {xheIsoStrToDateTime};


{ --------------------------------------------------------- DateTimeXls call }

function DateTimeXls( _what, _val, _fmt: pSExp ): pSExp; cdecl;
  var
    fktname: string;
  begin
    result:= RNilValue;  // need to give back something
    try
        { get function (name) }
      fktname:= GetScalarString( _what,
          'DateTimeXls: first argument must be the function name' );

      { dispatch to function (strictly alphabetic order) }

        { xheDateTimeToIsoStr }
      if fktname = 'xheDateTimeToIsoStr' then begin
        result:= xheDateTimeToIsoStr(
            riProtect( riCoerceVector( _val, setRealSxp ) ),
            riProtect( riCoerceVector( _fmt, setIntSxp ) ) );
        riUnprotect( 1 );

        { xheDateTimeToStr }
      end else if fktname = 'xheDateTimeToStr' then begin
        result:= xheDateTimeToStr(
            riProtect( riCoerceVector( _val, setRealSxp ) ),
            riProtect( riCoerceVector( _fmt, setStrSxp ) ) );
        riUnprotect( 1 );

        { xheIsoStrToDateTime }
      end else if fktname = 'xheIsoStrToDateTime' then begin
        result:= xheIsoStrToDateTime(
            riProtect( riCoerceVector( _val, setStrSxp ) ) );

        { xheStrToDateTime }
      end else if fktname = 'xheStrToDateTime' then begin
        result:= xheStrToDateTime(
            riProtect( riCoerceVector( _val, setStrSxp ) ) );
      end {if fktname};

      riUnprotect( 1 );
    except
      on E: ExlsReadWrite do begin
        rError( pChar(E.Message) );
      end;
      on E: EAssertionFailed do begin
        rError( pChar('Assertion failed: ' + E.Message + TheLE +
            '(This is probably a bug. We appreciate your bug report.' + TheLE +
            'Please include the message and (if possible) the relevant data.' + TheLE +
            'Thank you!)') );
      end;
      on E: Exception do begin
        rError( pChar('Unexpected error: ' + E.Message) );
      end;
    end {except};

  end {DateTimeXls};


end {xlsDateTime}.
