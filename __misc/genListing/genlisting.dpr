program genlisting;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, StrUtils;


{ --------------------------------------------------------- declarations }

type
  aIdxArr = array of integer;
  aNodeRec = record
    Node: string;
    Idxs: aIdxArr;
  end;
    { a bit ugly/complicated but with integers it would be even worse }
  aNodeEntry = ( nod_bw32shlib, nod_bw32src, nod_bw32, nod_csrc, nod_cw32, nod_src );

var
  idx: integer;
  nodeidx: aNodeEntry;
    { add new platforms here }
  Nodes: array[aNodeEntry] of aNodeRec = (
      (Node:'./bin/win32/shlib:'; Idxs:nil),
      (Node:'./bin/win32/src:'; Idxs:nil),
      (Node:'./bin/win32/'; Idxs:nil),
      (Node:'./cran/src:'; Idxs:nil),
      (Node:'./cran/win32/'; Idxs:nil),
      (Node:'./src:'; Idxs:nil));
  Listing, ListingGen: TStringList;
  listingPath: string;

const
  TheRootUrl = 'http://dl.dropbox.com/u/2602516/swissrpkg';

  TheVersionFile =
      '<%VAR_INDENT%><li><%VAR_VERSION%>' + #13#10 +
      '<%VAR_INDENT%>	<ul>' + #13#10 +
      '<%VAR_FILE%>'+
      '<%VAR_INDENT%>	</ul>' + #13#10 +
      '<%VAR_INDENT%></li>' + #13#10;
  TheFile =
      '<%VAR_INDENT%><li><a href=<%CONST_ROOTURL%>/<%VAR_PATH%>/<%VAR_FILENAME%> target="_blank"><%VAR_FILENAME%></a></li>' + #13#10;


{ --------------------------------------------------------- helpers }

procedure IncreaseVersion( _arr: aIdxArr );
  var
    i, j, idx: integer;
  begin
    for j:= Low( _arr ) + 1 to High( _arr ) do begin
      for i:= j to High( _arr ) do begin
        if StrToInt( ReplaceStr( Listing[_arr[i]], '.', '' ) ) < StrToInt( ReplaceStr( Listing[_arr[i - 1]], '.', '' ) ) then begin
          idx:= _arr[i]; _arr[i]:= _arr[i - 1]; _arr[i - 1]:= idx;
        end;
      end;
    end;
  end;

function SupportedFileExts( const ext: string ): boolean;
  begin
    result:= (ext = '.zip') or (ext = '.txt') or (ext = '.gz');
  end;

  { only has to match partially }
function IndexOfListing( const sval: string ): integer;
  var
    i: integer;
  begin
    for i := 0 to Listing.Count - 1 do begin
      if Pos( sval, Listing[i] ) <> 0 then begin
        result:= i;
        Exit;
      end;
    end;
    result:= -1;
  end;

function GenFile( _listIdx: integer; const _path: string; const _indent: string ): string;
  var
    li: string;
  begin
      result:= '';
      while (Listing.Count > _listIdx) and (Listing[_listIdx] <> '') do begin
        li:= TheFile;
        li:= ReplaceStr( li, '<%VAR_FILENAME%>', Listing[_listIdx] );
        li:= ReplaceStr( li, '<%VAR_PATH%>', _path );
        li:= ReplaceStr( li, '<%VAR_INDENT%>', _indent );
        result:= result + li;
        Inc( _listIdx );
      end;
  end;

function GenVersionFile( _nodeIdx: aNodeEntry ): string;
  var
    i, listidx: integer;
    tmpl: string;
  begin
    result:= '';
    for i:= High( Nodes[_nodeIdx].Idxs ) downto Low( Nodes[_nodeIdx].Idxs ) do begin
      listidx:= Nodes[_nodeIdx].Idxs[i];
      tmpl:= ReplaceStr( TheVersionFile, '<%VAR_VERSION%>', Listing[listidx] );
      tmpl:= ReplaceStr( tmpl, '<%VAR_INDENT%>', '          ' );
      Inc( listidx );

      tmpl:= ReplaceStr( tmpl, '<%VAR_FILE%>', GenFile(
          listidx,
          Copy( Nodes[_nodeIdx].Node, 3, 99 ) + Listing[Nodes[_nodeIdx].Idxs[i]],
          '              ' ) );
      result:= result + tmpl;
    end {for};
  end;


{ --------------------------------------------------------- program }

begin
  try
    if ParamCount <> 3 then raise Exception.Create( 'need 3 parameters: listing, listing-template and output' );

      { parse listing }
    Listing:= TStringList.Create(); Listing.LoadFromFile( ParamStr( 1 ) );
    for nodeidx:= Low( Nodes ) to High( Nodes ) do begin
      idx:= IndexOfListing( Nodes[nodeidx].Node );
      while idx > -1 do begin
        if (Listing.Count >= idx + 1) and SupportedFileExts( ExtractFileExt( Listing[idx + 1] ) ) then begin
            SetLength( Nodes[nodeidx].Idxs, Length( Nodes[nodeidx].Idxs ) + 1 );
            Nodes[nodeidx].Idxs[Length( Nodes[nodeidx].Idxs ) - 1]:= idx;
        end;
        Listing[idx]:= ReplaceStr( ReplaceStr( Listing[idx], Nodes[nodeidx].Node, '' ), ':', '' );
        idx:= IndexOfListing( Nodes[nodeidx].Node );
      end;
    end;

    ListingGen:= TStringList.Create(); ListingGen.LoadFromFile( ParamStr( 2 ) );

		  { handle <%VAR_BINWIN32_VERSIONFILE%> }
    IncreaseVersion( Nodes[nod_bw32].Idxs );
    ListingGen.Text:= ReplaceStr( ListingGen.Text, '<%VAR_BINWIN32_VERSIONFILE%>',
        GenVersionFile( nod_bw32 ) );

		  { handle <%VAR_BINWIN32_SHLIB_FILE%> }
    assert( Length( Nodes[nod_bw32shlib].Idxs ) = 1, 'array length - <%VAR_BINWIN32_SHLIB_FILE%>' );
    assert( Nodes[nod_bw32shlib].Idxs[0] < Listing.Count, 'idx value - <%VAR_BINWIN32_SHLIB_FILE%>' );
    ListingGen.Text:= ReplaceStr( ListingGen.Text, '<%VAR_BINWIN32_SHLIB_FILE%>',
        GenFile( Nodes[nod_bw32shlib].Idxs[0] + 1, 'bin/win32/shlib', '              '  ) );

		  { handle <%VAR_BINWIN32_SRC_FILE%> }
    assert( Length( Nodes[nod_bw32src].Idxs ) = 1, 'array length - <%VAR_BINWIN32_SRC_FILE%>' );
    assert( Nodes[nod_bw32src].Idxs[0] < Listing.Count, 'idx value - <%VAR_BINWIN32_SRC_FILE%>' );
    ListingGen.Text:= ReplaceStr( ListingGen.Text, '<%VAR_BINWIN32_SRC_FILE%>',
        GenFile( Nodes[nod_bw32src].Idxs[0] + 1, 'bin/win32/src', '              '  ) );

		  { handle <%VAR_CRANSRC_FILE%> }
    assert( Length( Nodes[nod_csrc].Idxs ) = 1, 'array length - <%VAR_CRANSRC_FILE%>' );
    assert( Nodes[nod_src].Idxs[0] < Listing.Count, 'idx value - <%VAR_CRANSRC_FILE%>' );
    ListingGen.Text:= ReplaceStr( ListingGen.Text, '<%VAR_CRANSRC_FILE%>',
        GenFile( Nodes[nod_csrc].Idxs[0] + 1, 'cran/src', '      '  ) );

		  { handle <%VAR_CRANWIN32_VERSIONFILE%> }
    IncreaseVersion( Nodes[nod_cw32].Idxs );
    ListingGen.Text:= ReplaceStr( ListingGen.Text, '<%VAR_CRANWIN32_VERSIONFILE%>',
        GenVersionFile( nod_cw32 ) );

		  { handle <%VAR_SRC_FILE%> }
    assert( Length( Nodes[nod_src].Idxs ) = 1, 'array length - <%VAR_SRC_FILE%>' );
    assert( Nodes[nod_src].Idxs[0] < Listing.Count, 'idx value - <%VAR_SRC_FILE%>' );
    ListingGen.Text:= ReplaceStr( ListingGen.Text, '<%VAR_SRC_FILE%>',
        GenFile( Nodes[nod_src].Idxs[0] + 1, 'src', '      '  ) );


    ListingGen.Text:= ReplaceStr( ListingGen.Text, '<%CONST_ROOTURL%>', TheRootUrl );
    ListingGen.SaveToFile( ParamStr( 3 ) );
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end {genlisting}.
