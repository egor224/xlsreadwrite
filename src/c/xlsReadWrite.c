/*
 *  xlsReadWrite.c
 *
 *  Compiles a placeholder shlib when we may not distribute the binary
 *  library (containing flexcel code). Each xlsReadWrite call will print
 *  a message and point to the helper function to download the full library.
 *
 */

#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <R_ext/Print.h>

const char crmsg[] = 
	"xlsReadWrite version (cran shlib)\n"
  "Copyright (C) 2009 Hans-Peter Suter, Treetron, Switzerland.\n\n";

const char cranmsg[] = 
  "!! Your installation still contains the cran placeholder shlib (dll/so). Please get\n"
  "the regular shlib from our dropbox account by executing the following command:\n"
  "   xls.getshlib()\n\n"
  "More info, forum and manual download (shlib, regular pkg) at http://www.swissr.org.\n\n"  
  "BACKGROUND: Our own xlsReadWrite code is free, but we also use proprietary code\n"
  "(Flexcel, tmssoftware.com) which we may only distribute legally in precompiled,\n"
  "i.e. binary form. Now CRAN 'generally does not accept submissions of precompiled\n"
  "binaries due to security reasons'. NO GUARANTEES: We have done thorough tests\n"
  "initially and there are integrity checks, but we do _not_ give any guarantees.\n"
  "However you are free to check out the CODE at http://github.com/swissr/xlsreadwrite,\n"
  "and in case of issues, we are happy to hear about them on our forum (www.swissr.org).";

SEXP ReadXls( SEXP _file, SEXP _colNames, SEXP _sheet, SEXP _type, SEXP _from, SEXP _rowNames, SEXP _colClasses, SEXP _checkNames, SEXP _dateTimeAs, SEXP _stringsAsFactors )
{
	error(cranmsg);
	return R_NilValue;
}

SEXP WriteXls( SEXP _data, SEXP _file, SEXP _colNames, SEXP _sheet, SEXP _skipLines, SEXP _rowNames )
{
	error(cranmsg);
	return R_NilValue;
}

SEXP DateTimeXls( SEXP _what, SEXP _val, SEXP _fmt )
{
	error(cranmsg);
	return R_NilValue;
}

const static R_CallMethodDef R_CallDef[] = {
	{"ReadXls", (DL_FUNC)&ReadXls, 10},
	{"WriteXls", (DL_FUNC)&WriteXls, 6},
	{"DateTimeXls", (DL_FUNC)&DateTimeXls, 3},
	{NULL, NULL, 0}
};

void R_init_xlsReadWrite(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, R_CallDef, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
		Rprintf(crmsg);
		Rprintf(cranmsg);
}
