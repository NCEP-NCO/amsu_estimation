      PROGRAM read_COORDINATES
c=======================================================================
c     This program reads information from the COORDINATES file and 
c     outputs the file dumpbufr.in, which will be used by the script      
c     dumpjb_SAT1B.sh_cira to sectorize the amsu data.
c=======================================================================
c     Progress:
c     10/09/02 - Programming begun by Jack Dostalek CIRA/CSU/RAMM
c     12/09/02 - Updated by A. Krautkramer NOAA/NHC
c		-added variables to read the basin and storm number
c		-print basin//storm number//year into output file
c     03/26/03 - Updated by A. Krautkramer NOAA/NHC
c		-changed the lat/lon window from 20 deg x 20 deg to 36 deg x 36 deg
c     10/25/2006 - Updated by ARK NOAA/NHC
c		- changed the way the stormNumber is read from the COORDNATES File
c		- changed the ATCF storm id written to the dumpjb_* files
c=======================================================================
c     Variables
      character*2 num   			!Storm id number
      character*8 date  			!Date
      character*9 jdate 			!Julian date and time
      real clat					!Storm latitude
      real clon					!Storm longitude
      real xlon					!Longitude variable
      integer nlat				!Northern lat of box
      integer slat				!Southern lat of box
      integer elon				!Eastern lon of box
      integer wlon				!Western lon of box
      character*3 nolat				!Northern lat of box
      character*3 solat				!Southern lat of box
      character*3 ealon				!Eastern lon of box
      character*3 welon				!Western lat of box
      character*12 latlon			!Box coordinates
      character*12 cout				!Output file
      character*2 basin				!Alison Added variable for storm basin				
      character*2 stormNumber	    		!Alison Addded variable for storm number
      character*2 stormYear			!Alison Added variable for storm year
c=======================================================================
c     Open COORDINATES file
      open(unit=11,file='COORDINATES',status='old')

c     Read lines of COORDINATES file      
10    read(11,20,end=900) num,date,jdate,clat,clon,basin,stormNumber,
     .      stormYear
20    format(a2,1x,a8,1x,a9,2(1x,f6.1),35x,a2,a2,a2) 
      
c     Need to take storm latitude and longitude and get northern/southern
c     and eastern/western boundaries of a box 20 deg x 20 deg.  Here
c     longitude is east positve.  In the subsecting script, longitude
c     runs from 0 to 360 degrees, increasing to the west.
c      nlat=nint(clat+10.0)
c      slat=nint(clat-10.0)

c	new box should be 36 deg x 36 deg in order to insure there is
c	enough room for two swath centers if the storm happens to 
c	fall exactly between two separate orbits.  Each orbit is
c	~2400 km across and angled at about 15 degrees

      nlat=nint(clat+18.0)
      slat=nint(clat-18.0)
      if(clon.le.0.0) xlon=-1*clon
      if(clon.gt.0.0) xlon=360.0-clon
c      elon=nint(xlon-10.0)
      elon=nint(xlon-18.0)
      if(elon.lt.0) elon=360-elon
c      wlon=nint(xlon+10.0)
      wlon=nint(xlon+18.0)
      if(wlon.gt.360) wlon=wlon-360
           
      write(nolat,'(i3)') nlat
      write(solat,'(i3)') slat
      write(ealon,'(i3)') elon
      write(welon,'(i3)') wlon
      
      if(nlat.lt.10) nolat(1:2)='00'
      if(nlat.ge.10 .and. nlat.lt.100) nolat(1:1)='0'
      
      if(slat.lt.10 .and. slat.ge.0) solat(1:2)='00'
      if(slat.ge.10 .and. slat.lt.100) solat(1:1)='0'
      
      if(slat.lt.0 .and. slat.gt.-10) solat(1:2)='-0'
      if(slat.le.-10 .and. slat.gt.-100) solat(1:1)='-'      
            
      if(elon.lt.10) ealon(1:2)='00'
      if(elon.ge.10 .and. elon.lt.100) ealon(1:1)='0'
      
      if(wlon.lt.10) welon(1:2)='00'
      if(wlon.ge.10 .and. wlon.lt.100) welon(1:1)='0'            
      
      latlon=solat//nolat//ealon//welon
      
c     Open output file
      cout='dumpjb.in_'//num
      open(unit=12,file=cout,status='replace')
      write(12,30) date//jdate(8:9)
30    format(a10)      
      write(12,40) latlon
40    format(a12)
c	  Alison Added variable to print storm name
	  write(12,50) basin//stormNumber//date(1:2)//stormYear
50	  format(a8)
      close(unit=12)            
                  
      goto 10 


900   continue      
      
      stop
      end              
