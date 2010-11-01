unit xlsWrite;

{ Write functionality.
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
  rhRInternals, rhxTypesAndConsts;

function WriteXls( _data, _file, _colNames, _sheet, _skipLines, _rowNames, _naStrings: pSExp ): pSExp; cdecl;

{==============================================================================}
implementation
uses
  Windows, SysUtils, Variants, Types, Classes, UFlexCelImport, xlsUtils, XlsAdapter,
  xlsHelpR, rhR;

type
  aColheadertype = ( chtNone, chtLogical, chtString );

function WriteXls( _data, _file, _colNames, _sheet, _skipLines, _rowNames, _naStrings: pSExp ): pSExp; cdecl;
  var
    writer: TFlexCelImport;
    colcnt, rowcnt, offsetRow: integer;
    colheadertype: aColheadertype;
    nastrings: TStringDynArray;
    skipLines: integer;
    rownameKind: aRowNameKind;
    rowNameAsFirstCol: boolean;

  procedure SelectOrInsertSheet();
    var
      i, sheetIdx: integer;
      sheetName: string;
    begin
      if riIsNumeric( _sheet ) then begin
        sheetIdx := riInteger( riCoerceVector( _sheet, setIntSxp ) )[0];
        if (sheetIdx < 1) or (sheetIdx > writer.SheetCount) then begin
          raise ExlsReadWrite.Create('Sheet index must be between 1 and number of sheets');
        end;
        writer.ActiveSheet := sheetIdx;
      end else if riIsString(_sheet) then begin
        sheetName:= riChar( riStringElt( _sheet, 0 ) );
        if sheetName = '' then begin
          writer.ActiveSheet:= 1;
        end else begin
          for i:= 1 to writer.SheetCount do begin
            writer.ActiveSheet:= i;
            if SameText(writer.ActiveSheetName, sheetName) then Break;
          end;
          if not SameText(writer.ActiveSheetName, sheetName) then begin
            writer.InsertEmptySheets( 1, 1 );
            writer.ActiveSheet:= 1;
            writer.ActiveSheetName:= sheetName;
          end {if};
        end {if};
      end else begin
        raise ExlsReadWrite.Create('sheet must be of type numeric or string');
      end {if};
    end {SelectOrInsertSheet};

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

  function AutoRowname: boolean;
    var
      dim, myrownames: pSExp;
    begin
      result:= False;
      myrownames:= nil;

      if colheadertype <> chtNone then begin
        if riIsFrame( _data ) then begin
          myrownames:= riGetAttrib( _data, RRowNamesSymbol );
        end else begin
          dim:= riGetAttrib( _data, RDimNamesSymbol );
          if (not riIsNull( dim )) then begin
            myrownames:= riVectorElt( dim, 0 );
          end;
        end;

        result:= Assigned( myrownames) and (not riIsNull( myrownames)) and
            (riLength( myrownames ) > 0) and (riTypeOf( myrownames ) = setStrSxp) and
            (string(riChar( riStringElt( myrownames, 0 ) )) <> '1' );
      end;
    end {CheckForAutoRow};

  procedure ArgRowNames(_rowNames: pSExp);
    begin
        { check if is NA scalar }
      rowNameAsFirstCol:= False;
      if (riLength( _rowNames ) = 1) and
         (riTypeOf( _rowNames ) in [setLglSxp, setRealSxp]) and
         (rIsNa( riReal( riCoerceVector( _rowNames, setRealSxp ) )[0] ) <> 0)
      then begin
        rownameKind:= rnNA;
      end else if riIsLogical( _rowNames ) then begin
        if (riLogical( _rowNames )[0] <> 0) then rownameKind:= rnTrue else rownameKind:= rnFalse;
      end else if riIsString( _rowNames ) then begin
        rownameKind:= rnSupplied;
        if (not (riLength( _rowNames ) = rowcnt)) then begin
          raise ExlsReadWrite.CreateFmt('Number of supplied rownames doesn''t match ' +
              'the number of determined rows (%d/%d)', [riLength( _rowNames ), rowcnt]);
        end;
      end else begin
        raise ExlsReadWrite.Create('SetRowNames: "rowNames" must be of type logical or string');
      end;
    end;

  procedure ApplyColHeader();
    var
      i: integer;
      cn, dim: pSExp;
      dropEntry: boolean;
    begin
      cn:= nil;
      dropEntry:= False;

      if colheadertype = chtString then begin
        cn:= _colNames;
        dropEntry:= rowNameAsFirstCol and
            (riLength( _colNames ) = colcnt + integer(rowNameAsFirstCol))
      end else if colheadertype = chtLogical then begin
        if riTypeOf( _data ) = setVecSxp then begin
            { frame }
          cn:= riGetAttrib( _data, RNamesSymbol );
          if riIsNull( cn ) then cn:= nil;
        end else begin
            { matrix }
          dim:= riGetAttrib( _data, RDimNamesSymbol );
          if not riIsNull( dim ) then begin
            cn:= riVectorElt( dim, 1 );
            if riIsNull( cn ) then cn:= nil;
          end else begin
            cn:= nil;
          end;
        end;
      end {if};

      if Assigned( cn ) then begin
        for i:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
          writer.CellValue[skiplines + 1, i + 1]:=
              string(riChar( riStringElt( cn, i - integer(rowNameAsFirstCol) + integer(dropEntry) ) ));
        end;
      end else begin
        for i:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
          writer.CellValue[skiplines + 1, i + 1]:=
              'V' + IntToStr( i - integer(rowNameAsFirstCol) + 1 );
        end;
      end;
    end;

  procedure ApplyRowNames();
    var
      r: integer;
      rn, dim: pSExp;
    begin
      if rownameKind = rnSupplied then begin
        rn:= _rowNames;
      end else begin
        assert( rownameKind = rnTrue, 'ApplyRowNames: rownameKind <> rnTrue' );
        if riIsFrame( _data ) then begin
          rn:= riGetAttrib( _data, RRowNamesSymbol );
        end else begin
          dim:= riGetAttrib( _data, RDimNamesSymbol );
          if (not riIsNull( dim )) then begin
            rn:= riVectorElt( dim, 0 );
          end else begin
            rn:= nil;
          end;
        end {is frame};
        
        if riIsNull( rn ) then begin
          rn:= nil;
        end;
      end;

      if Assigned( rn ) then begin
        if riTypeOf( rn ) = setStrSxp then begin
          for r:= 0 to rowcnt - 1 do begin
            writer.CellValue[r + 1 + offsetRow, 1]:=
              string(riChar( riStringElt( rn, r ) ));
          end;
        end else if riTypeOf( rn ) = setIntSxp then begin
          for r:= 0 to rowcnt - 1 do begin
            writer.CellValue[r + 1 + offsetRow, 1]:= riInteger( rn )[r];
          end;
        end else assert( False, 'ApplyRowNames: rownames whould be setStrSxp or setIntSxp' );
      end else begin
        for r:= 0 to rowcnt - 1 do begin
          writer.CellValue[r + 1 + offsetRow, 1]:= IntToStr( r + 1 );
        end;
      end;
    end {ApplyRowNames};

  procedure EventuallyApplyNaString(_row, _col: integer);
    begin
      if (Assigned( naStrings )) and (Length( naStrings ) = 1) then begin
        writer.CellValue[_row, _col]:= naStrings[0];
      end {if};
    end;

  procedure WriteDouble(); cdecl;
    var
      r, c: integer;
      valreal: double;
    begin
      for r := 0 to rowcnt - 1 do begin
        for c:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
          valreal:= riReal( _data )[r + rowcnt*(c - integer(rowNameAsFirstCol))];
          if (rIsNan( valreal ) <> 0) then writer.CellValue[r + 1 + offsetRow, c + 1]:= TheNanString
          else if (rIsNa( valreal ) = 0) then writer.CellValue[r + 1 + offsetRow, c + 1]:= valreal
          else EventuallyApplyNaString( r + 1 + offsetRow, c + 1 );
        end {for};
      end {for};
    end {WriteDouble};

  procedure WriteInteger(); cdecl;
    var
      r, c: integer;
      valint: integer;
    begin
      for r := 0 to rowcnt - 1 do begin
        for c:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
          valint:= riInteger( _data )[r + rowcnt*(c - integer(rowNameAsFirstCol))];
          if valint <> RNaInt then writer.CellValue[r + 1 + offsetRow, c + 1]:= valint
          else EventuallyApplyNaString( r + 1 + offsetRow, c + 1);
        end {for};
      end {for};
    end {WriteInteger};

  procedure WriteLogical(); cdecl;
    var
      r, c: integer;
      valint: integer;
    begin
      for r := 0 to rowcnt - 1 do begin
        for c:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
          valint:= riLogical( _data )[r + rowcnt*(c - integer(rowNameAsFirstCol))];
          if valint <> RNaInt then writer.CellValue[r + 1 + offsetRow, c + 1]:= valint
          else EventuallyApplyNaString( r + 1 + offsetRow, c + 1);
        end {for};
      end {for};
    end {WriteLogical};

  procedure WriteString(); cdecl;
    var
      r, c: integer;
      val: string;
    begin
      for r := 0 to rowcnt - 1 do begin
        for c:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
          if riStringElt( _data, r + rowcnt*(c - integer(rowNameAsFirstCol)) ) <> RNAString then begin
            val:= string(riChar( riStringElt( _data, r + rowcnt*(c - integer(rowNameAsFirstCol)) ) ));
            writer.CellValue[r + 1 + offsetRow, c + 1]:= val;
          end else EventuallyApplyNaString( r + 1 + offsetRow, c + 1 );
        end {for};
      end {for};
    end {WriteString};

  procedure WriteDataframe(); cdecl;
    var
      coltypes: array of aSExpType;
      lev: array of pSExp;
      r, c: integer;
      valint: integer;
      valreal: double;
      val: string;
    begin
      SetLength( coltypes, colcnt + integer(rowNameAsFirstCol) );
      SetLength( lev, colcnt + integer(rowNameAsFirstCol) );

        { loop columns (set type) }
      if rowNameAsFirstCol then begin
        coltypes[0]:= setStrSxp;
        lev[0]:= nil;
      end;
      for c:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
        lev[c - integer(rowNameAsFirstCol)]:= nil;
        coltypes[c - integer(rowNameAsFirstCol)]:=
            riTypeOf( riVectorElt( _data, c - integer(rowNameAsFirstCol) ) );
          { treat factors separately }
        if coltypes[c - integer(rowNameAsFirstCol)] = setIntSxp then begin
          if riIsFactor( riVectorElt( _data, c - integer(rowNameAsFirstCol) ) ) then begin
            coltypes[c - integer(rowNameAsFirstCol)]:= setCplxSxp;  // WARNING: misuse of setCplxSxp !!!
            lev[c - integer(rowNameAsFirstCol)]:=
                riGetAttrib( riVectorElt( _data, c - integer(rowNameAsFirstCol) ), RLevelsSymbol );
          end;
        end;
      end {for};

        { loop rows (write data) }
      for r:= 0 to rowcnt - 1 do begin
          { data columns }
        for c:= integer(rowNameAsFirstCol) to colcnt - 1 + integer(rowNameAsFirstCol) do begin
          case coltypes[c - integer(rowNameAsFirstCol)] of
            setIntSxp: begin
              valint:= riInteger( riVectorElt( _data, c - integer(rowNameAsFirstCol) ) )[r];
                // todo: code copied from above (ugly, needs refactoring)
              if valint <> RNaInt then writer.CellValue[r + 1 + offsetRow, c + 1]:= valint
              else EventuallyApplyNaString( r + 1 + offsetRow, c + 1);
            end;
            setCplxSxp: begin  // setCplxSxp used for factors (WARNING: levels 1-based, riStringElt 0-based)
              valint:= riInteger( riVectorElt( _data, c - integer(rowNameAsFirstCol) ) )[r];
              if valint <> RNaInt then begin
                  { levels 1-based, riStringElt 0-based: subtract 1 from valint }
                writer.CellValue[r + 1 + offsetRow, c + 1]:=
                    string(riChar( riStringElt( lev[c - integer(rowNameAsFirstCol)], valint - 1 ) ));
              end else EventuallyApplyNaString( r + 1 + offsetRow, c + 1);
            end;
            setRealSxp: begin
              valreal:= riReal( riVectorElt( _data, c - integer(rowNameAsFirstCol) ) )[r];
                // todo: code copied from above (ugly, needs refactoring)
              if (rIsNan( valreal ) <> 0) then writer.CellValue[r + 1 + offsetRow, c + 1]:= TheNanString
              else if (rIsNa( valreal ) = 0) then writer.CellValue[r + 1 + offsetRow, c + 1]:= valreal
              else EventuallyApplyNaString( r + 1 + offsetRow, c + 1 );
            end;
            setLglSxp: begin
              valint:= riLogical( riVectorElt( _data, c - integer(rowNameAsFirstCol) ) )[r];
                // todo: code copied from above (ugly, needs refactoring)
              if valint <> RNaInt then writer.CellValue[r + 1 + offsetRow, c + 1]:= valint
              else EventuallyApplyNaString( r + 1 + offsetRow, c + 1);
            end;
            setStrSxp: begin
                // todo: code copied from above (ugly, needs refactoring)
              if riStringElt( riVectorElt( _data, c - integer(rowNameAsFirstCol) ), r ) <> RNAString then begin
                val:= string(riChar( riStringElt( riVectorElt( _data, c - integer(rowNameAsFirstCol) ), r ) ));
                writer.CellValue[r + 1 + offsetRow, c + 1]:= val;
              end else EventuallyApplyNaString( r + 1 + offsetRow, c + 1 );
            end;
          else
            assert( True, 'WriteDataframe: coltype not supported' );
          end {case};
        end {for each column};
      end {for each row};
    end {WriteDataframe};

  var
    filename: string;
    tmpl: string;
    elem: pSExp;
  begin {WriteXls}
    result:= RNilValue;
    try
      filename:= GetScalarString( _file, 'file must be a character string' );

        { _skipLines }
      skipLines:= riInteger( riCoerceVector( _skipLines, setIntSxp ) )[0];

        { row and column count }
      offsetRow:= skipLines;
      if riIsFrame( _data ) then begin
        elem:= riVectorElt( _data, 0 );
        if riIsNull( elem ) then begin
          rowcnt:= 0;
        end else begin
          rowcnt:= riLength( elem );
        end;
        colcnt:= riLength( _data );
      end else begin
        rowcnt:= riNrows( _data );
        if (rowcnt = 0) and (riLength( _data ) = 0) and (not riIsMatrix( _data )) then begin
          colcnt:= 0;
        end else begin
          colcnt:= riNcols( _data );
        end;
      end;
      if rowcnt > 65536 then raise ExlsReadWrite.CreateFmt( 'Only up to %d rows supported (Excel <V2007))', [65536] );
      if colcnt > 256 then raise ExlsReadWrite.CreateFmt( 'Only up to %f columns supported (Excel <V2007))', [256] );

        { _colNames }
      colheadertype:= chtNone;
      if riIsLogical( _colNames ) then begin
        if riLogical( _colNames )[0] <> 0 then colheadertype:= chtLogical;
      end else if riIsString( _colNames ) then begin
        colheadertype:= chtString;
      end else begin
        raise ExlsReadWrite.Create('colHeader must be of type logical or string');
      end;

        { _rowNames }
      ArgRowNames( _rowNames );
      if rownameKind = rnNA then begin
        if AutoRowname then begin
          rowNameAsFirstCol:= True;
          rownameKind:= rnTrue;
        end;
      end {if};

        { _naStrings }
      ArgNaStrings( _naStrings );
      
        { create writer }
      writer:= TFlexCelImport.Create( nil );
      writer.Adapter:= TXLSAdapter.Create( writer );
      try
          { open template file }
        tmpl:= ShlibPath() + '\..\..\template\TemplateNew.xls';           // >= R2.12
        if not FileExists( tmpl ) then begin
          tmpl:= ShlibPath() + '\..\template\TemplateNew.xls';            // < R2.12
          if not FileExists( tmpl ) then begin
            tmpl:= ShlibPath() + '\..\..\inst\template\TemplateNew.xls';  // debugging
            if not FileExists( tmpl ) then begin
              raise ExlsReadWrite.CreateFmt('Could not find template file (%s).' + TheLE +
                 'It is supposed to be at these places (>= R2.12.x / < R2.12.x):' + TheLE +
                 '- %s' + TheLE + '- %s',
                  ['TemplateNew.xls', ShlibPath() + '\..\..\template\TemplateNew.xls',
                  ShlibPath() + '\..\template\TemplateNew.xls'] );
            end;
          end;
        end;
        writer.OpenFile( tmpl );
        SelectOrInsertSheet();

        if colheadertype <> chtNone then Inc( offsetRow );

        if (rownameKind in [rnTrue, rnSupplied]) then begin
          rowNameAsFirstCol:= True;
        end;

        if (colcnt > 0) and (colheadertype = chtString) and
            not ((riLength( _colNames ) = colcnt) or
                 (riLength( _colNames ) = colcnt + integer(rowNameAsFirstCol)))
        then begin
          raise EXlsReadWrite.CreateFmt( 'colNames must be a vector with ' +
            'equal length as the column count (incl./excl. column for rownames;' + TheLE +
            '(length: %d/colcnt: %d/has rownames: %d)',
            [riLength( _colNames ), colCnt, integer(rowNameAsFirstCol)] );
        end;

            
        { -- write matrix }

        case riTypeOf( _data ) of
          setRealSxp:   WriteDouble();
          setIntSxp:    WriteInteger();
          setLglSxp:    WriteLogical();
          setStrSxp:    WriteString();
          setVecSxp:    begin
            if not riIsFrame( _data ) then begin
              raise ExlsReadWrite.Create( 'Currently the following types ' +
                  'are supported: ' + #13#13 +
                  'REALSXP (double), INTSXP (integer), LGLSXP (logical) ' +
                  'STRSXP (character), VECSXP (data.frame)' );
            end;
            WriteDataframe();
          end {setVecSxp}
        else
          raise ExlsReadWrite.Create( 'Currently only the following types ' +
              'are supported: ' + #13#13 +
              'REALSXP (double), INTSXP (integer), LGLSXP (logical) ' +
              'STRSXP (character), VECSXP (data.frame or list)' );
        end {case};

          { colNames and rownames }
        if colheadertype <> chtNone then ApplyColHeader();
        if rownameKind in [rnTrue, rnSupplied] then ApplyRowNames();

          { close }
        if FileExists(FileName) then SysUtils.DeleteFile( filename );
        writer.Save( filename );
        writer.CloseFile;
      finally
        writer.Free;
      end {try};
    except
      on E: ExlsReadWrite do begin
        rError( pChar(E.Message) );
      end;
      on E: Exception do begin
        rError( pChar('Unexpected error. Message: ' + E.Message) );
      end;
    end {try};
  end;

end {xlsWrite}.
