      program pullvar_nhc
c  This program creates a script called pullvar_nhc.ksh which pulls appropriate 
c  fields from GFS grib file.

      integer *4 nvars,ishell,ilog,nlevs
      character *1 cvar3,cvar4,clev4
      character *4 cvar(5),clev(11),ctmpvar,ctmplev
      character *9 ctmpfil
      character *14 cinput
      character *15 cscript
      character *16 clog      
      character *28 cgrbdir
      character *19 cgribfil
      character *40 cgrep
      character *120 ccom

c getenv is not considered intrinsic by pgf90
c     INTRINSIC getenv 
	  
c	  Als added code need to query environmental variable 
c	  set by get_gfs.pl named GFSFILE
	  
	  character *100 gfsfile 
	  call getenv("GFSFILE", gfsfile)
      
c      data cgrbdir /'/home/dostalek/jack/gfs/bin/'/
      data clog /'pullvar_nhc.log'/      
      data cscript /'pullvar_nhc.ksh'/
c      data cinput /'pullvar_nhc.in'/
      data ilog,ishell,iinput /50,51,52/
      data nvars,nlevs /5,11/
      data cvar /'UGRD','VGRD','HGT ','TMP ','RH  '/
      data clev /'100 ','150 ','200 ','250 ','300 ','400 ','500 ',
     +'700 ','850 ','925 ','1000'/ 

c     Open log file
c      open(unit=ilog,file=cgrbdir//clog,status='replace')
	  open(unit=ilog,file=clog,status='replace')
c     Open input file
c      open(unit=iinput,file=cgrbdir//cinput,status='old')
c	  open(unit=iinput,file=cinput,status='old')
c      read(iinput,3) cgribfil
c3     format(a19)
c   

c     Create the shell script 
c      open(unit=ishell,file=cgrbdir//cscript,status='replace')
	  open(unit=ishell,file=cscript,status='replace')          

      write(ishell,4) '#!/bin/ksh'
4     format (a10)      
      write(ishell,5) '# Script pullvar_nhc.ksh'
5     format (a24)              
      write(ishell,7) '#'
7     format (a1)      
c      write(ishell,12) 'WGRIB=''/home/dostalek/jack/wgrib/wgrib''' 
	write(ishell,12) 'WGRIB=./wgrib'
12    format(a15)
c      write(ishell,8) 'gribdir='''//cgrbdir//''''
c8     format (a38)
c      write(ishell,9) 'gribfil='''//cgribfil//''''
c9     format (a29)     

c	  Als code
	  write (ishell,999) 'gribfil='//gfsfile//''
999   format (a100) 	  



c     Cycle through variables, creating appropriate wgrib commands
            
      do 200 ivar=1,nvars
        ctmpvar=cvar(ivar)
        cvar3=ctmpvar(3:3)
        cvar4=ctmpvar(4:4)
        nvarchar=4
        if(cvar4.eq.' ') nvarchar=3
        if(cvar3.eq.' ') nvarchar=2
        do 100 ilev=1,nlevs
          ctmplev=clev(ilev)
          clev4=ctmplev(4:4)
          nlevchar=4
          if(clev4.eq.' ') nlevchar=3
          cgrep="|grep ':"//ctmplev(1:nlevchar)//" mb:'|grep ':"//
     +    ctmpvar(1:nvarchar)//":'|"
          ngrepch=index(cgrep,'  ')
          ngrepch=ngrepch-1
          ctmpfil=ctmplev(1:nlevchar)//ctmpvar(1:nvarchar)
          mchar=index(ctmpfil,' ')
          mchar=mchar-1
          
          if(ctmpfil(1:mchar).eq.'250RH') goto 100
          if(ctmpfil(1:mchar).eq.'200RH') goto 100
          if(ctmpfil(1:mchar).eq.'150RH') goto 100
          if(ctmpfil(1:mchar).eq.'100RH') goto 100
          
c          ccom='$WGRIB -s $gribdir$gribfil '//cgrep(1:ngrepch)//' $WGRIB 
c     + -s -i -H $gribdir$gribfil -o $gribdir"'//ctmpfil(1:mchar)//'.bin"          
c     +'
	        ccom='$WGRIB -s $gribfil '//cgrep(1:ngrepch)//' $WGRIB 
     + -s -i -H $gribfil -o "'//ctmpfil(1:mchar)//'.bin"          
     +'
          write(ishell,150) ccom
150        format (a120)          
100      continue
200    continue

      write(ishell,10) '#'
10    format (a1)
      write(ishell,11) 'exit'
11    format (a4)            

      write(ilog,*) ' '
      write(ilog,*) 'pullvar_nhc.ksh created'
      write(ilog,*) '  '

      close(unit=ishell)
      close(unit=iinput)
      close(unit=ilog)
  
      stop
      end          
          
          
          
          
          
          
