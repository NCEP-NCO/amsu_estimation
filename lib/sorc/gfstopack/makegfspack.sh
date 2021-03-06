#!/bin/sh
###############################################################
#
#   AUTHOR:    Gilbert - W/NP11
#
#   DATE:      01/11/1999
#
#   PURPOSE:   This script uses the make utility to update the libgfspack 
#              archive libraries.
#              It first reads a list of source files in the library and
#              then generates a makefile used to update the archive
#              libraries.  The make command is then executed for each
#              archive library, where the archive library name and 
#              compilation flags are passed to the makefile through 
#              environment variables.
#
#   REMARKS:   Only source files that have been modified since the last
#              library update are recompiled and replaced in the object
#              archive libraries.  The make utility determines this
#              from the file modification times.
#
#              New source files are also compiled and added to the object 
#              archive libraries.
#
###############################################################
. /nwprod/gempak/.gempak
#
#     Generate a list of object files that corresponds to the
#     list of Fortran ( .f ) files in the current directory
#
for i in `ls *.f`
do
  obj=`basename $i .f`
  OBJS="$OBJS ${obj}.o"
done

#
#     Remove make file, if it exists.  May need a new make file
#     with an updated object file list.
#
if [ -f make.libgfspack ] 
then
  rm -f make.libgfspack
fi
#
#     Generate a new make file ( make.libgfspack), with the updated object list,
#     from this HERE file.
#
cat > make.libgfspack << EOF
SHELL=/bin/sh

\$(LIB):	\$(LIB)( ${OBJS} )

.f.a:
	ftn -c \$(FFLAGS) \$<
	ar \$(AFLAGS) \$@ \$*.o
	rm -f \$*.o

EOF
#
#     Update 4-byte version of libgfspack.a
#
export LIB="libgfspack.a"
#export FFLAGS=" -O3 -q32 -bshared"
#export AFLAGS=" -v -q -X32"
#export CFLAGS=" -O3 -q32"
export FFLAGS=" -g -align all"
export AFLAGS =" ruv"
export CFLAGS=" "
make -f make.libgfspack

rm -f make.libgfspack
