      program compgfs
c     This program compares the latest gfs file on the server with the 
c     latest gfs file on the system.

      character *1 hxy
      character *2 mm,dd,hh,chour
      character *4 yyyy
      character *8 cday
c	csrvfil(20)
      character *10 csysfil(1000),clastsys,csrvfil(50),chold1
      character *11 csrv,csys
      character *15 clog,cout
c      character *21 cdatdir
      character *28 cxdir
c	cnwsfil(20)
c      character *19 cnwsfil(50),cgetfil,chold2
      character *30 cnwsfil(50),cgetfil,chold2
c      character *19 cline
      character *30 cline

      integer iyy,idd

      data csrv,csys,clog /'srvgfs.list','sysgfs.list',
     &'compgfs_ibm.log'/
c      data cxdir /'/home/dostalek/jack/gfs/bin/'/
c      data cdatdir /'/data/model/grib/gfs/'/
      data cout /'compgfs_ibm.dat'/
      data isrv,isys,ilog,icont1 /11,12,13,14/
      
     
c-------------------------------------------------------------------
c     **** OPEN LOG FILE ****
c-------------------------------------------------------------------

c     open(unit=ilog,file=cxdir//clog,status='replace')
      open(unit=ilog,file=clog,status='replace')


c-------------------------------------------------------------------
c     **** OPEN LIST OF SYSTEM GFS PACK FORMAT FILES ****
c
c     Open the sysgfs.list file which contains a list of file with 
c     the naming convension G000YY_[Y|X]MMdd_PACK.DAT where:
c
c	YY - the last two digits of the calendar year
c       [Y|X] - decodes teh day and hour of the run when
c		combined with dd.
c       MM - two digits indicating the calendar month 
c   
c	Example sysgfs.list contents:
c    
c       	G00004_Y0826_PACK.DAT
c		G00005_X0106_PACK.DAT
c
c	Decode the date/time group of each PACK file and then choose the
c	latest date
c
c----------------------------------------------------------------------

c
c     open(unit=isys,file=cxdir//csys,status='old')
      open(unit=isys,file=csys,status='old')
      
      n=1
5     read(isys,10,end=20) iyy,hxy,mm,idd
10    format(4x,i2,1x,a1,a2,i2)
C10    format(35x,i2,1x,a1,a2,i2)
    
c     Convert to 4 digit year

      if(iyy.gt.50) iyyyy=1900+iyy      
      if(iyy.lt.50) iyyyy=2000+iyy
      write(yyyy,'(i4)') iyyyy
      
c     Decode day and hour of run  
  
      if(hxy.eq.'X') then
      
        if(idd.lt.50) then
          hh='00'
        elseif(idd.gt.50) then
          idd=idd-50
          hh='12'
        endif
	
      elseif(hxy.eq.'Y') then
      
        if(idd.lt.50) then
          hh='06'
        elseif(idd.gt.50) then
          idd=idd-50
          hh='18'
        endif
	
      endif
      
      write(dd,'(i2)') idd
      
      if(idd.lt.10) dd(1:1)='0'
      csysfil(n)=yyyy//mm//dd//hh 
      n=n+1
      
      goto 5
20    continue

c     Find latest file on local system

      clastsys=csysfil(1)
      do 25 i=2,n-1
         if(clastsys.gt.csysfil(i)) goto 25
         if(clastsys.lt.csysfil(i)) then
            clastsys=csysfil(i)
         endif
25    continue            


      write(ilog,30) 'Latest system time '//clastsys
30    format(a29)      

      close(unit=isys)
      
      
c-------------------------------------------------------------------
c     **** OPEN LIST OF SERVER GFS GRIB FILES ****
c
c     Open the srvgfs.list file which contains a list of GFS grib files 
c     on the server.  Read teh contents of the file into an 
c     array named cnwsfil().  Then extract the date and hour of the GFS grib
c     file and store that information in the array csrvfil.
c
c	Example srvgfs.list contents:
c    
c       	gfs.20050210/gfs.t00z.pgrbf00
c		gfs.20050210/gfs.t00z.pgrbf03
c		gfs.20050210/gfs.t00z.pgrbf06
c	
c
c	where:
c		gfs.20050210/ - directory containing the 
c				gfs grib files.  The directory
c				is in the format gfs.YYYYMMDD.
c		gfs.t00z.pgrbf00 - gfs grib file with the format
c				   gfs.tHHz.pgrbfFF
c					HH - gfs run time
c					FF - forecast hour 
c  
c	cnwsfil(m) = (gfs.20050210/gfs.t00z.pgrbf00,
c		      gfs.20050210/gfs.t00z.pgrbf03,
c                     gfs.20050210/gfs.t00z.pgrbf06)
c
c	csrvfil(m) = (2005021000)
c
c	Decode the date/time group of each PACK file and then choose the
c	latest date
c
c----------------------------------------------------------------------

c      open(unit=isrv,file=cxdir//csrv,status='old')
      open(unit=isrv,file=csrv,status='old')
      
      m=1
34    read(isrv,35,end=45) cline
35    format(a30)
c35    format(a19)
      
      cnwsfil(m)=cline
      read(cline,40,end=45) cday,chour
c40    format(a8,a2)
40    format(4x,a8,6x,a2)
      csrvfil(m)=cday//chour
      m=m+1
      goto 34          
45    continue 
 
      close(unit=isrv) 
      
         
c-------------------------------------------------------------------
c     **** SORT CSRVFIL ARRAY IN ASCENDING ORDER ****
c-------------------------------------------------------------------

      last=m-1
      do 47 j=1,m-2
        iold=j
        ibeg=j+1
       
        do 48 k=ibeg,last
          if(csrvfil(k).lt.csrvfil(iold)) iold=k
48      continue
       
        chold1=csrvfil(j)
        csrvfil(j)=csrvfil(iold)
        csrvfil(iold)=chold1
c       Also order gblav* files
        chold2=cnwsfil(j)
        cnwsfil(j)=cnwsfil(iold)
        cnwsfil(iold)=chold2       
        
47    continue      


c-------------------------------------------------------------------
c     **** WRITE INFORMATION TO LOG ****
c-------------------------------------------------------------------
            
      write(ilog,49) 'File times on server (in ascending order)'
49    format(a41)                    
      do 50 i=1,m-1
         write(ilog,51) csrvfil(i),cnwsfil(i)
c51       format(a10,2x,a19) 
51       format(a10,2x,a30)     
50    continue  
      write(ilog,*) ' '       

c-------------------------------------------------------------------
c     **** COMPARE THE LASTEST TIME N THE SYSTEM TO FILES ON THE SERVER ****
c-------------------------------------------------------------------
          
      last=m-1
      
      if(clastsys.lt.csrvfil(last)) then
         cgetfil=cnwsfil(last)
         goto 57
      else
         goto 58  
      endif   
      
c-------------------------------------------------------------------
c     **** WRITE INFORMATION TO LOG ****
c-------------------------------------------------------------------

57    write(ilog,59) 'New gfs file on server '//cgetfil
c59    format(a42)
59    format(a53)
      write(ilog,*) ' '


c-------------------------------------------------------------------
c     **** WRITE INFORMATION TO COMPGFS.DAT ****
c-------------------------------------------------------------------

c     For new file case

c      open(unit=icont1,file=cxdir//cout,status='replace')
      open(unit=icont1,file=cout,status='replace')
      write(icont1,60) 'noexit'
60    format(a6) 
                 
c      write(icont1,65) cdatdir
c65    format(a21)
      write(icont1,66) cgetfil
c66    format(a19) 
66    format(a30) 
      
c      write(icont1,67) cgetfil(9:10)
      write(icont1,67) cgetfil(19:20)
67    format(a2)
      write(icont1,69) cgetfil(7:12)
c      write(icont1,69) cgetfil(3:8)
69    format(a6)      
      close(unit=icont1)    
68    goto 75

c     For no new file case
       
c58    open(unit=icont1,file=cxdir//cout,status='replace')
58    open(unit=icont1,file=cout,status='replace')
      write(icont1,70) 'exit'
70    format(a4) 
      close(unit=icont1)
      
75    continue                     
      stop
      end
     
