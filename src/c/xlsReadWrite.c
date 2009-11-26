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
	"xlsReadWrite version (cran placeholder shlib\n"
  "Copyright (C) 2009 Hans-Peter Suter, Treetron, Switzerland.\n\n";

const char cranmsg[] = 
  "!! PLEASE GET THE ACTUAL SHLIB\n"
  "Our own xlsReadWrite code is free, but we also use a proprietary code library (Flexcel,\n"
  "tmssoftware.com) which can only be distributed legally in precompiled, i.e. binary form. As\n"
  "cran 'generally does not accept submissions of precompiled binaries due to security reasons'\n"
  "we provide the following command to download the regular shlib from our dropbox account:\n\n"
  "   xls.getshlib()\n\n"
  "There have been thorough tests initially but we do not give ANY GUARANTEES AT ALL.\n"
  "You might want to revise the 'xls.getshlib' code and/or read '?xls.getshlib' first\n"
  "Alternatively you can download the shlib or full package manually and/or compile the\n"
	"library for yourself. Please find more info in the package help and the README file.\n";

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
