
unit xlsRead;

{ Read functionality.
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
  rhRInternals, rhxTypesAndConsts, xlsUtils, xlsHelpR;

function ReadXls( _file, _colNames, _sheet, _type,
    _from, _rowNames, _colClasses,
    _checkNames, _dateTime, _naStrings,
    _stringsAsFactors: pSExp ): pSExp; cdecl;

{==============================================================================}
implementation
uses
  SysUtils, Types, Variants, Classes, Math, UFlexCelImport, XlsAdapter, rhR, UFlxNumberFormat,
  UFlxFormats;

{  -- helper - copied from pro }

function IsNaScalar( _x: pSExp ): boolean;
  begin
    result:= (riLength( _x ) = 1) and
             (riTypeOf( _x ) in [setLglSxp, setRealSxp]) and
             (rIsNa( riReal( riCoerceVector( _x, setRealSxp ) )[0] ) <> 0);
  end;

function IsInNaStrings(const _val: string; const _naStrings: TStringDynArray = nil): boolean; overload;
  var
    i: Integer;
  begin
    result:= False;
    if (Assigned( _naStrings )) and (Length( _naStrings ) > 0) then begin
      for i:= 0 to Length( _naStrings ) - 1 do begin
        if _val = _naStrings[i] then begin
          result:= True;
          Break;
        end;
      end;
    end {if};
  end;

function IsInNaStrings(const _val: variant; const _naStrings: TStringDynArray = nil): boolean; overload;
  begin
    result:= (VarType( _val ) = varOleStr) or (VarType( _val ) = varString);
    if result then result:= IsInNaStrings( string(_val), _naStrings );
  end;

function IsNanString(const _val: variant): boolean;
  begin
    result:= ((VarType( _val ) = varOleStr) or (VarType( _val ) = varString)) and
             (_val = TheNanString);
  end;

{  -- code }

function ReadXls( _file, _colNames, _sheet, _type,
    _from, _rowNames, _colClasses,
    _checkNames, _dateTime, _naStrings,
    _stringsAsFactors: pSExp ): pSExp; cdecl;
  var
    reader: TFlexCelImport;
    colcnt, rowcnt, from: integer;
    hasColNames: boolean;
    colnames: array of string;
    rownames: array of string;
    naStrings: TStringDynArray;
    rownameKind: aRowNameKind;
    checkNames: boolean;
    dateTimeAsNumeric: boolean;
    stringsAsFactors: boolean;
    firstColAsRowName: boolean;

  procedure SelectSheet();
    var
      i, sheetIdx: integer;
      sheetName: string;
    begin
      if riIsNumeric(_sheet) then begin
        sheetIdx:= riInteger( riCoerceVector( _sheet, setIntSxp ) )[0];
        if (sheetIdx < 1) or (sheetIdx > reader.SheetCount) then begin
          raise ExlsReadWrite.Create('Sheet index must be between 1 and number of sheets');
        end;
        reader.ActiveSheet:= sheetIdx;
      end else if riIsString(_sheet) then begin
        sheetName:= GetScalarString(_sheet, 'sheet must be a character string' );
        for i:= 1 to reader.SheetCount do begin
          reader.ActiveSheet:= i;
          if SameText(reader.ActiveSheetName, sheetName) then Break;
        end;
        if not SameText(reader.ActiveSheetName, sheetName) then begin
          raise ExlsReadWrite.CreateFmt('There is no sheet "%s" in the file "%s"',
              [sheetName, riChar( riStringElt( _file, 0 ) )]);
        end;
      end else begin
        raise ExlsReadWrite.Create('sheet must be of type numeric or string');
      end {if};
    end {SelectSheet};

  procedure ArgColNames(_colNames: pSExp);
    var
      i: integer;
    begin
      if riIsLogical( _colNames ) then begin
        hasColNames:= riLogical( _colNames )[0] <> 0;
        SetLength( colNames, 0 );
      end else if riIsString( _colNames ) then begin
        SetLength( colNames, riLength( _colNames ) );
        for i := 0 to riLength( _colNames ) - 1 do begin
          colNames[i]:= string(riChar( riStringElt( _colNames, i ) ));
        end;
        hasColNames:= Length( colNames ) > 0;
      end else begin
        raise ExlsReadWrite.Create('SetColNames: "colNames" must be of type logical or string');
      end {if colHeader};
    end;

  procedure ArgTrueFalse(_val: pSExp; var _res: boolean; const _what: string );
    begin
      if riIsLogical( _val ) and (riLength( _val ) = 1) then begin
        _res:= riLogical( _val )[0] <> 0;
      end else begin
        raise ExlsReadWrite.Create( '"' + _what + '" must be TRUE or FALSE' );
      end;
    end;

  procedure ArgDateTime( _dateTime: pSExp );
    begin
      dateTimeAsNumeric:= GetScalarString( _dateTime,
          'dateTime must be a character string' ) = 'numeric';
    end;

  procedure ArgRowNames(_colNames: pSExp);
    var
      i: integer;
    begin
          { check if is NA scalar }
      if IsNaScalar( _rowNames ) then begin
        rownameKind:= rnNA;
      end else if riIsLogical( _rowNames ) then begin
        if riLogical( _rowNames )[0] <> 0 then rownameKind:= rnTrue else rownameKind:= rnFalse;
        SetLength( rowNames, 0 );
      end else if riIsString( _rowNames ) then begin
        rownameKind:= rnSupplied;
        SetLength( rowNames, riLength( _rowNames ) );
        for i := 0 to riLength( _rowNames ) - 1 do begin
          rowNames[i]:= string(riChar( riStringElt( _rowNames, i ) ));
        end;
        if not Length( rowNames ) > 0 then rownameKind:= rnFalse;
      end else begin
        raise ExlsReadWrite.Create('SetRowNames: "rowNames" must be of type logical or string');
      end;
    end;

  procedure ArgNaStrings(_naStrings: pSExp);
    var
      i: integer;
    begin
      if IsNaScalar( _naStrings ) then begin
        naStrings:= nil;
      end else begin
        if riIsString( _naStrings ) then begin
          SetLength( naStrings, riLength( _naStrings ) );
          for i := 0 to riLength( _naStrings ) - 1 do begin
            naStrings[i]:= string(riChar( riStringElt( _naStrings, i ) ));
          end;
        end else begin
          raise ExlsReadWrite.Create('"naStrings" must be a string or NA');
        end;
      end;
    end;

  procedure PrepareColNames( _idx: integer );
    var
      i: integer;
      s: string;
    begin
      if hasColNames and (Length( colNames ) > 0) then begin
        if (Length( colNames ) <> colcnt) and
           (Length( colNames ) <> (colcnt - integer(firstColAsRowName)))
        then begin
          raise EXlsReadWrite.CreateFmt( 'colNames must be a vector of ' +
            'equal (or when having rownames: equal - 1) length as the column count ' +
            '(length: %d/colcnt: %d/has rownames: %d)',
            [riLength( _colClasses ), colCnt, integer(firstColAsRowName)] );
          raise EXlsReadWrite.CreateFmt( 'colNames must be a vector with ' +
            'equal length as the column count (length: %d/colcnt: %d)',
            [Length( colNames ), colCnt] );
        end;
        Exit;
      end;

        { has colnames to be taken from sheet or created }
      SetLength( colnames, colcnt );
      for i:= 0 to colcnt - 1 do begin
        colnames[i]:= 'V' + IntToStr( i + 1 - integer(firstColAsRowName) );
        if hasColNames then begin
          s:= VarAsString( reader.CellValue[_idx - 1, i + 1] );
          if s <> '' then colnames[i]:= s;
        end;
      end;
    end {SetColNames};

  procedure ApplyMatrixRowColNames( _result: pSExp);
    var
      dim: pSExp;
      i: integer;
      r: integer;
      entry: pchar;
      myrownames, mycolnames: pSExp;
      unprotcnt: integer; // ugly, todo
    begin
      dim:= riProtect( riAllocVector( setVecSxp, 2 ) );
      unprotcnt:= 1;

        { rownames }
      if rownameKind = rnFalse then begin
        myrownames:= RNilValue;
      end else begin
        Inc( unprotcnt );
        if rownameKind = rnSupplied then begin
          myrownames:= riProtect( riAllocVector( setStrSxp, rowcnt ) );
          for r:= 0 to rowcnt - 1 do begin
            riSetStringElt( myrownames, r, riMkChar( pChar(rownames[r]) ) );
          end;
        end else begin
          if firstColAsRowName then begin
            myrownames:= riProtect( riAllocVector( setStrSxp, rowcnt ) );
          end else begin
            myrownames:= riProtect( riAllocVector( setIntSxp, rowcnt ) )
          end;
          for r:= 0 to rowcnt - 1 do begin
            if firstColAsRowName then begin
              riSetStringElt( myrownames, r, riMkChar( pChar(VarAsString(
                  reader.CellValue[r + from, 1], IntToStr( r + 1 ) ) )) );
            end else begin
              riInteger( myrownames )[r]:= r + 1;
            end;
          end {for};
        end;

        if anyDuplicated(myrownames) then begin
          riUnprotect( unprotcnt );

          raise ExlsReadWrite.Create('rownames must be unique');

        end;

      end;

        { colnames }
      mycolnames:= riProtect( riAllocVector( setStrSxp, colcnt - integer(firstColAsRowName) ));
      Inc( unprotcnt );
      if hasColNames then begin
        for i:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin
          entry:= pChar(colnames[i + integer(firstColAsRowName)]);
          if entry = '' then entry:= pchar('V' + IntToStr( i + 1 ));
          riSetStringElt( mycolnames, i, riMkChar( entry ) );
        end;
        if checkNames then begin
          mycolnames:= riProtect( MakeNames( mycolnames ) );
          Inc( unprotcnt );
        end;
      end else begin
        for i:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin
          riSetStringElt( mycolnames, i, riMkChar( pChar('V' + IntToStr( i + 1 )) ) );
        end;
      end;

        { apply }
      riSetVectorElt( dim, 0, myrownames );
      riSetVectorElt( dim, 1, mycolnames );
      riSetAttrib( result, RDimNamesSymbol, dim );

      riUnprotect( unprotcnt );
    end {ApplyColNames};

    // todo: could/should be merged with matrix case?
  procedure ApplyFrameRowNames( _result: pSExp);
    var
      r: integer;
      myrownames: pSExp;
    begin
      if rownameKind = rnSupplied then begin
        myrownames:= riProtect( riAllocVector( setStrSxp, rowcnt ) );
        for r:= 0 to rowcnt - 1 do begin
          riSetStringElt( myrownames, r, riMkChar( pChar(rownames[r]) ) );
        end;
      end else begin
        if firstColAsRowName then begin
          myrownames:= riProtect( riAllocVector( setStrSxp, rowcnt ) );
        end else begin
          myrownames:= riProtect( riAllocVector( setIntSxp, rowcnt ) )
        end;
        for r:= 0 to rowcnt - 1 do begin
          if firstColAsRowName then begin
            riSetStringElt( myrownames, r, riMkChar( pChar(VarAsString(
                reader.CellValue[r + from, 1], IntToStr( r + 1 ) ) )) );
          end else begin
            riInteger( myrownames )[r]:= r + 1;
          end;
        end {for};
      end;

      if anyDuplicated(myrownames) then begin
        riUnprotect( 1 );
        raise ExlsReadWrite.Create('rownames must be unique');
      end;

      riSetAttrib( _result, RRowNamesSymbol, myrownames );
      riUnprotect( 1 );
    end {ApplyRowNames};

  function CheckForAutoRow: boolean;
    var
      coln4row: string;
    begin
      result:= hasColNames and (colcnt >= 2);
      if result then begin
        if Length(colNames) > 0 then begin
          coln4row:= colnames[0];
        end else begin
          coln4row:= VarAsString( reader.CellValue[from - 1, 1] )
        end;
        result:= (coln4row = '') and
            VarIsStr( reader.CellValue[from, 1] ) and
            (reader.CellValue[from, 1] <> '1');
      end;
    end {CheckForAutoRow};

  function ReadDouble(): pSExp; cdecl;
    var
      r, c: integer;
      v: variant;
    begin
      result:= riProtect( riAllocMatrix( setRealSxp, rowcnt, colcnt - integer(firstColAsRowName) ) );
      for r:= 0 to rowcnt - 1 do begin
        for c:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin
          v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
          if IsInNaStrings( v, naStrings ) then riReal( result )[r + rowcnt*c]:= RNaReal
          else if IsNanString( v ) then riReal( result )[r + rowcnt*c]:= RNaN
          else riReal( result )[r + rowcnt*c]:= VarAsDouble( v, RNaReal );
        end {for};
      end {for};
      riUnprotect( 1 );
    end {ReadDouble};

  function ReadInteger(): pSExp; cdecl;
    var
      r, c: integer;
      v: variant;
    begin
      result:= riProtect( riAllocMatrix( setIntSxp, rowcnt, colcnt - integer(firstColAsRowName) ) );
      for r:= 0 to rowcnt - 1 do begin
        for c:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin
          v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
          if IsInNaStrings( v, naStrings ) then riInteger( result )[r + rowcnt*c]:= RNaInt
          else riInteger( result )[r + rowcnt*c]:= VarAsInt( v, RNaInt );
        end {for};
      end {for};
      riUnprotect( 1 );
    end {ReadInteger};

  function ReadLogical(): pSExp; cdecl;
    var
      r, c: integer;
      v: variant;
    begin
      result:= riProtect( riAllocMatrix( setLglSxp, rowcnt, colcnt - integer(firstColAsRowName) ) );
      for r:= 0 to rowcnt - 1 do begin
        for c:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin
          v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
          if IsInNaStrings( v, naStrings ) or IsNanString( v ) then begin
             riLogical( result )[r + rowcnt*c]:= RNaInt
          end else begin
            riLogical( result )[r + rowcnt*c]:= integer(VarAsBool( v, False, RNaInt ));
          end;
        end {for};
      end {for};
      riUnprotect( 1 );
    end {ReadLogical};

  function ReadString(): pSExp; cdecl;
    var
      r, c: integer;
      v: variant;
    begin
      result:= riProtect( riAllocMatrix( setStrSxp, rowcnt, colcnt - integer(firstColAsRowName) ) );
      for r:= 0 to rowcnt - 1 do begin
        for c:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin
          v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
          if IsInNaStrings( v, naStrings ) then riSetStringElt( result, r + rowcnt*c, RNaString )
          else if IsNanString( v ) then riSetStringElt( result, r + rowcnt*c, riMkChar( TheNanString ) )
          else riSetStringElt( result, r + rowcnt*c, riMkChar( pChar(VarAsString( v )) ) );
        end {for}
      end {for};
      riUnprotect( 1 );
    end {ReadString};

  function ReadDataframe(): pSExp; cdecl;
    var
      coltypes: array of aSExpType;
      hasColClasses: boolean;

      { it's a bit a hack but I don't have the nice classes
        from pro and don't want to change too many things }
    procedure SetColClasses(_colClasses: pSExp);

      function StrToColType( const _type: string ): aSExpType;
        begin
          if (_type = 'double') or (_type = 'numeric' ) then begin
            result:= setRealSxp;
          end else if _type = 'integer' then begin
            result:= setIntSxp;
          end else if _type = 'logical' then begin
            result:= setLglSxp;
          end else if (_type = 'character') then begin
            result:= setStrSxp;
          end else if (_type = 'factor') then begin
            result:= setSpecialSxp;  // misuse of aSExpType
          end else if (_type = 'isodate') then begin
            result:= setCplxSxp;     // misuse of aSExpType
          end else if (_type = 'isotime') then begin
            result:= setDotSxp;      // misuse of aSExpType
          end else if (_type = 'isodatetime') then begin
            result:= setAnySxp;      // misuse of aSExpType
          end else if _type = 'NA' then begin
            result:= setNilSxp;      // 1st try to find a type, 2nd use RNaInt
          end else begin
            raise EXlsReadWrite.CreateFmt( '"%s" is not a valid colClasses entry ' +
                '(use double, numeric, integer, logical, character, factor, isodate, isotime, isodatetime or NA)', [_type] );
          end;
        end {StrToColType};

      var
        i: integer;
      begin {SetColClasses}

          { check if is NA scalar }
        if IsNaScalar( _colClasses ) then begin
          hasColClasses:= False;
        end else begin

          if riIsString(_colClasses) then begin
            hasColClasses:= True;
            if (riLength( _colClasses ) = colCnt) or
                (riLength( _colClasses ) = colCnt - integer(firstColAsRowName))
            then begin
              SetLength( coltypes, riLength( _colClasses ) );
              for i:= 0 to Length( coltypes ) - 1 do begin
                coltypes[i]:= StrToColType( string(riChar( riStringElt( _colClasses, i ) )) );
              end;
            end else if riLength( _colClasses ) = 1 then begin
              SetLength( coltypes, colCnt );
              coltypes[0]:= StrToColType( string(riChar( riStringElt( _colClasses, 0 ) )) );
              for i:= 1 to colCnt - 1 do begin
                coltypes[i]:= coltypes[0];
              end;
            end else begin
              raise EXlsReadWrite.CreateFmt( 'colClasses must be a scalar or a vector of ' +
                'equal (or when having rownames: equal - 1) length as the column count ' +
                '(length: %d/colcnt: %d/has rownames: %d)',
                [riLength( _colClasses ), colCnt, integer(firstColAsRowName)] );
            end;
          end else begin
             raise ExlsReadWrite.Create( 'colClasses must be NA or a string (vector)' );
          end {if};
        end;
        if Length( coltypes ) = 0 then begin
          SetLength( coltypes, colcnt - integer(firstColAsRowName) );
          for i:= 0 to Length( coltypes ) - integer(firstColAsRowName) - 1 do begin
            coltypes[i]:= setNilSxp;
          end;
        end;
      end {SetColClasses};

    var
      r, c: integer;
      v: variant;
      myclass, mynames: pSExp;
      flexfmt: TFlxFormat;
      hasDate, hasTime: boolean;
      tempname: string;
      tempdat: double;
      formerfactors: pSExp;
      consideredRows: integer;
    begin {ReadDataframe}
      SetLength( coltypes, 0 );

      { support rowname }

      firstColAsRowName:= False;
      if rownameKind = rnTrue then begin
        firstColAsRowName:= True;
      end else if rownameKind = rnNA then begin
        if CheckForAutoRow then begin
          firstColAsRowName:= True;
        end;
      end;
      if firstColAsRowName and (colcnt < 2) then begin
        raise ExlsReadWrite.CreateFmt('If a column is used for the rownames, there must be  ' +
                'at least 2 columns in the Excelfile (actual number: %d)', [colcnt]);
      end;

      PrepareColNames( from );

      SetColClasses( _colClasses );
      if firstColAsRowName and (Length( coltypes ) = colcnt - integer(firstColAsRowName) + 1) then begin
          { need to remove column for rownames }
        coltypes:= Copy( coltypes, 1, Length( coltypes ) - 1 );
      end;

        { allocate }
      result:= riProtect( riAllocVector( setVecSxp, colcnt - integer(firstColAsRowName) ) );
      mynames:= riProtect( riAllocVector( setStrSxp, colcnt - integer(firstColAsRowName) ) );

      { loop columns (get type and name) }

      consideredRows:= Min( rowcnt - 1, 15 );
      for c:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin

        if rowcnt > 0 then begin

          if coltypes[c] <> setNilSxp then begin

              { type already determined }
            case coltypes[c] of
              setRealSxp:    riSetVectorElt( result, c, riAllocVector( setRealSxp, rowcnt ) );
              setIntSxp:     riSetVectorElt( result, c, riAllocVector( setIntSxp, rowcnt ) );
              setLglSxp:     riSetVectorElt( result, c, riAllocVector( setLglSxp, rowcnt ) );
              setCplxSxp,
              setDotSxp,
              setAnySxp,
              setSpecialSxp,
              setStrSxp:     riSetVectorElt( result, c, riAllocVector( setStrSxp, rowcnt ) );
            else
              assert( False, 'coltype not supported (bug)' );
            end {case};
          end else begin

              { read row and determine type }
            for r:= 0 to consideredRows do begin
              v:= reader.CellValue[from + r, c + 1 + integer(firstColAsRowName)];
              case VarType( v ) of
                varSmallint,
                varInteger,
                varShortInt,
                varByte,
                varWord,
                varLongWord,
                varInt64: begin
                  coltypes[c]:= setIntSxp;
                  riSetVectorElt( result, c, riAllocVector( setIntSxp, rowcnt ) );
                  Break;
                end;
                varSingle,
                varDouble,
                varCurrency,
                varDate: begin
                  if dateTimeAsNumeric then begin
                    coltypes[c]:= setRealSxp;
                    riSetVectorElt( result, c, riAllocVector( setRealSxp, rowcnt ) );
                    Break;
                  end else begin
                    reader.GetCellFormatDef( from, c + 1 + integer(firstColAsRowName), flexfmt );
                    HasXlsDateTime( flexfmt.Format, hasDate, hasTime );
                    if hasDate and hasTime then begin
                      coltypes[c]:= setAnySxp; // WARNING: misuse
                      riSetVectorElt( result, c, riAllocVector( setStrSxp, rowcnt ) );
                    end else if hasDate then begin
                      coltypes[c]:= setCplxSxp; // WARNING: misuse
                      riSetVectorElt( result, c, riAllocVector( setStrSxp, rowcnt ) );
                    end else if hasTime then begin
                      coltypes[c]:= setDotSxp; // WARNING: misuse
                      riSetVectorElt( result, c, riAllocVector( setStrSxp, rowcnt ) );
                    end else begin
                      coltypes[c]:= setRealSxp;
                      riSetVectorElt( result, c, riAllocVector( setRealSxp, rowcnt ) );
                      Break;
                    end;
                  end {if use oleDateTime};
                end;
                varBoolean: begin
                  coltypes[c]:= setLglSxp;
                  riSetVectorElt( result, c, riAllocVector( setLglSxp, rowcnt ) );
                  Break;
                end;
                varOleStr,
                varString: begin
                  if IsLogicalString( v ) then begin
                    coltypes[c]:= setLglSxp;
                    riSetVectorElt( result, c, riAllocVector( setLglSxp, rowcnt ) );
                    Break;
                  end else if stringsAsFactors then begin

                    coltypes[c]:= setSpecialSxp;  // misuse of aSExpType
                  end else begin
                    coltypes[c]:= setStrSxp;
                  end;
                  riSetVectorElt( result, c, riAllocVector( setStrSxp, rowcnt ) );
                  Break;
                end;
              end {case};
            end {for considered rows};

            if coltypes[c] = setNilSxp then begin
              rWarning( pChar(Format( 'Could not determine a type for column %d' +  TheLE +
                  '  - colCnt: %d, rowCnt: %d, first/last data row: %d/%d' + TheLE +
                  '  - "logical" type will be assumed and all values will be NA' + TheLE +
                  '  - if the row/colCnt area is too large, try to delete the superfluous' + TheLE +
                  '    rows/columns (not only the cell content))' + TheLELE,
                  [c + 1 + integer(firstColAsRowName), colcnt, rowcnt, from,
                  from + consideredRows] )) );
              coltypes[c]:= setNilSxp;  // riLogical and RNaInt will be used;
              riSetVectorElt( result, c, riAllocVector( setLglSxp, rowcnt ) );
            end {if nothing found in considered rows};
          end {if};
        end else begin
          riSetVectorElt( result, c, riAllocVector( setLglSxp, 0 ) );
        end {if rowcnt > 0};

          { set mynames (colnames) }
        tempname:= colnames[c + integer(firstColAsRowName)];
        if (tempname = '') and (not hasColNames) then tempname:= 'V' + IntToStr( c + 1 );
        riSetStringElt( mynames, c, riMkChar( pChar(tempname) ) );
      end {for each column};

      { loop rows (read data) }

      for r:= 0 to rowcnt - 1 do begin
        for c:= 0 to colcnt - 1 - integer(firstColAsRowName) do begin
            { todo: this reading is a duplication from above, normalize!! }
          case coltypes[c] of
            setIntSxp: begin
              v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
              if IsInNaStrings( v, naStrings ) then riInteger( riVectorElt( result, c ) )[r]:= RNaInt
              else riInteger( riVectorElt( result, c ) )[r]:= VarAsInt( v, RNaInt );
            end;
            setRealSxp: begin
              v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
              if IsInNaStrings( v, naStrings ) then riReal( riVectorElt( result, c ) )[r]:= RNaReal
              else if IsNanString( v ) then riReal( riVectorElt( result, c ) )[r]:= RNaN
              else riReal( riVectorElt( result, c ) )[r]:= VarAsDouble( v, RNaReal );
            end;

            setCplxSxp, setDotSxp, setAnySxp: begin   // misused for Date
              v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
              if IsInNaStrings( v, naStrings ) then begin
                riSetStringElt( riVectorElt( result, c ), r, RNaString );
              end else begin
                tempdat:= VarAsDouble( v, RNaReal );
                if not IsNan( tempdat ) then begin
                  if coltypes[c] = setCplxSxp then begin
                    tempname:= DateTimeToStrFmt( 'yyyy-mm-dd', tempdat );
                  end else if coltypes[c] = setDotSxp then begin
                    tempname:= DateTimeToStrFmt( 'hh:nn:ss', tempdat );
                  end else begin
                    tempname:= DateTimeToStrFmt( 'yyyy-mm-dd hh:nn:ss', tempdat );
                  end;
                end else begin
                  tempname:= '';
                end;
                riSetStringElt( riVectorElt( result, c ), r, riMkChar( pChar(tempname) ) );
              end;
            end;
            setLglSxp: begin
              v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
              if IsInNaStrings( v, naStrings ) or IsNanString( v ) then begin
                riLogical( riVectorElt( result, c ) )[r]:= RNaInt
              end else riLogical( riVectorElt( result, c ) )[r]:= integer(VarAsBool( v, False, RNaInt ));
            end;
            setSpecialSxp, setStrSxp: begin
              v:= reader.CellValue[r + from, c + 1 + integer(firstColAsRowName)];
              if IsInNaStrings( v, naStrings ) then riSetStringElt( riVectorElt( result, c ), r, RNaString )
              else if IsNanString( v ) then riSetStringElt( riVectorElt( result, c ), r, riMkChar( TheNanString ) )
              else riSetStringElt( riVectorElt( result, c ), r, riMkChar( pChar(VarAsString( v )) ) );
            end;
            setNilSxp: begin
              riLogical( riVectorElt( result, c ) )[r]:= RNaInt;
            end;
          else
            assert( False, 'ReadDataframe: coltype not supported (bug)' );
          end {case};
        end {for each column};
      end {for each row};

        { convert to factor if necessary }
      for c:= 0 to Length( coltypes ) - 1 do begin
        if coltypes[c] = setSpecialSxp then begin
          formerfactors:= riVectorElt( result, c );
          riSetVectorElt( result, c, AsFactor( formerfactors ) );
        end;
      end {for each col};

      { make the frame }

      if checkNames then mynames:= riProtect( MakeNames( mynames ) );
      riSetAttrib( result, RNamesSymbol, mynames );
      myclass:= riProtect( riMkString( 'data.frame' ) );
      riClassgets( result, myclass );
      riUnprotect( 3 + integer(checkNames) );
    end {ReadDataframe};

  var
    outputtype: aOutputType;
  begin {ReadXls}
    result:= RNilValue;
    SetLength( colnames, 0 );
    SetLength( rownames, 0 );
    try
        { check if is scalar number }
      if not ((riLength( _from ) = 1) and
             (riTypeOf( _from ) in [setIntSxp, setRealSxp]))
      then begin
        raise ExlsReadWrite.Create('ReadXls: "from" must be a scalar integer or double');
      end;
      from:= riInteger( riCoerceVector( _from, setIntSxp ) )[0];
      ArgColNames( _colNames );
      ArgRowNames( _rowNames );
      ArgNaStrings( _naStrings );
      ArgDateTime( _dateTime );
      ArgTrueFalse( _checkNames, checkNames, 'checkNames' );
      ArgTrueFalse( _stringsAsFactors, stringsAsFactors, 'stringsAsFactors' );

        { create reader }
      reader:= TFlexCelImport.Create( nil );
      reader.Adapter:= TXLSAdapter.Create( reader );
      try
          { open existing file }
        reader.OpenFile( EnsureAbsolutePath( GetScalarString( _file, 'file must be a character string' ) ) );
        SelectSheet();

          { counts and offsets }
        rowcnt:= reader.MaxRow;
        colcnt:= reader.MaxCol;
        if hasColNames and (Length( colnames ) = 0) then Inc( from );
        rowcnt:= rowcnt - from + 1;
        if (rownameKind = rnSupplied) and (not (length( rownames ) = rowcnt)) then begin
          raise ExlsReadWrite.CreateFmt('Number of supplied rownames doesn''t match ' +
              'the number of determined rows (%d/%d)', [length( rownames ), rowcnt]);
        end;

          { read data }
        if colcnt > 0 then begin
          outputtype:= StrToOutputType( riChar( riStringElt( _type, 0 ) ) );
          if outputtype = otDataFrame then begin
            { data.frame }

            result:= ReadDataframe();
            ApplyFrameRowNames( result )

          end else begin

            { matrix }

            if outputtype in [otDouble, otNumeric, otInteger, otLogical, otCharacter] then begin
              firstColAsRowName:= rownameKind = rnTrue;
              if not firstColAsRowName then begin
                if (rownameKind = rnNA) and CheckForAutoRow() then begin
                  firstColAsRowName:= True;
                end;
              end;

              PrepareColNames( from );

              case outputtype of
                otDouble, otNumeric:   result:= ReadDouble();
                otInteger:             result:= ReadInteger();
                otLogical:             result:= ReadLogical();
                otCharacter:           result:= ReadString();
              end;

                { colNames and rownames }
              ApplyMatrixRowColNames( result );

            end else begin
              raise ExlsReadWrite.Create( 'Only the types "' + AllOutputTypes +
                  '" are supported right now. (Your input was: ' +
                  riChar( riStringElt( _type, 0 ) ) + ')' );
            end {if matrix};
          end {if data.frame};
        end else begin
          result:= RNilValue;
        end {if};

        reader.CloseFile;
      finally
        reader.Free;
      end {try};
    except
      on E: ExlsReadWrite do begin
        rError( pChar(E.Message) );
      end;
      on E: Exception do begin
        rError( pChar('Unexpected error. Message: ' + E.Message) );
      end;
    end {try};
  end {ReadXls};

end {xlsRead}.
