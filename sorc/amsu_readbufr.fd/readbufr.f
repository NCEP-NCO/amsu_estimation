      PROGRAM READBUFR
c=======================================================================      
c     This program reads amsu data in bufr format and outputs brightness
c     temperatures and other information for use in tropical storm work.
c=======================================================================
c     Progress:
c     04/23/02 - Programming begun by Jack Dostalek CIRA/CSU/RAMM
c     04/29/02 - Switched to helene, ulysses has trouble with readsb
c     05/29/02 - Copy put on asp.ncep.noaa.gov
c     06/19/02 - New output format made
c     12/03/02 - Updated for NOAA-17
c     05/27/04 - Changed 1bamua.ibm to amuata.ibm for antenna temperatures
c     02/12    - Added code to read in an input parameter indicating 
c		 the file that contains the bufr data   
c	                   readbufr amuata.ibm
c		 	   readbufr airsev.ibm
c=======================================================================
c     Variables:
      character*2 cio                           !Input/output flag for openbf
      character*8 csubset
      character*20 cbufrin			!Input bufr file name
      integer lubfr				!Logical unit number for bufr file
      integer iret
      integer lundx
      integer idate
      real*8 r8arr(1298,1)
      integer yr				!Year
      integer mo				!Month
      integer dy				!Day
      integer hr				!Hour
      integer mi				!Minute
      integer se				!Second
      real lat					!Latitude
      real lon					!Longitude
      integer sat				!Satellite
      integer sensor			        !Sensor
      integer scanele,eleold			!Scan element
      integer landsea				!Land sea flag
      real satzen				!Satellite zenith angle
      real solzen				!Solar zenith angle
      integer elev				!Surface elevation
      integer sathght				!Satellite height
      real tb(15)				!Brightness temperatures
      integer date
      integer time
c=======================================================================
c     Data statements:
      data lubfr,luoutaq /11,23/
      data luout15,luout16,luout18,luout19 /15,16,18,19/
      data luout2,luout1 /22,21/
      data cbufrin,cio /'airsev.ibm','IN'/
c=======================================================================   
       character*20 ARG1
       CALL GETARG(1,ARG1)
       READ (ARG1,*) cbufrin
c=======================================================================      
c     Open output files according to *.ibm file
c     -------------  
      IF(cbufrin.eq.'amuata.ibm') THEN
        open(unit=luout15,file='noaa15.out',status='replace')
        open(unit=luout16,file='noaa16.out',status='replace')
        open(unit=luout18,file='noaa18.out',status='replace')
        open(unit=luout19,file='noaa19.out',status='replace')      
        open(unit=luout2,file='metop2.out',status='replace')
        open(unit=luout1,file='metop1.out',status='replace')
      ELSEIF(cbufrin.eq.'airsev.ibm') THEN
        open(unit=luoutaq,file='nasaaq.out',status='replace')
      ENDIF
      
c     For some reason, the values are being repeated 9 times
c     with slightly different longitudes.  While a more permanent
c     solution is sought, this fix will suffice.
      eleold=100      	      	          

c     Open bufr file
c     --------------
      mxmn=1298
      mxlv=1
      lundx=lubfr
      nmsg=0
      open(unit=lubfr,file=cbufrin,status='old',form='unformatted')
      call openbf(lubfr,cio,lundx)      
10    call readmg(lubfr,csubset,idate,iret)                          
      if(iret.eq.0) then
        nmsg=nmsg+1     
	nsb=0                       
30      call readsb(lubfr,iretsb)               
	if(iretsb.eq.0) then
	  nsb=nsb+1
	  call ufbseq(lubfr,r8arr,mxmn,mxlv,nlv,csubset)	  
c     r8arr is a real array, but not all values are best output as real
c     values. So here I will do some modifications before I write the data
c     out. This also will show what the values in r8arr are.
          IF(csubset .eq. 'NC021123') THEN
            yr=nint(r8arr(1,1))
            mo=nint(r8arr(2,1))
            dy=nint(r8arr(3,1))
            hr=nint(r8arr(4,1))
            mi=nint(r8arr(5,1))
            se=nint(r8arr(6,1))
            lat=r8arr(7,1)
            lon=r8arr(8,1)                             	  
            if(r8arr(9,1).eq.206) then
              sat=15
            elseif(r8arr(9,1).eq.207) then 
              sat=16
            elseif(r8arr(9,1).eq.209) then 
              sat=18
            elseif(r8arr(9,1).eq.223) then
              sat=19
            elseif(r8arr(9,1).eq.4) then
              sat=2 	  	  
            elseif(r8arr(9,1).eq.3) then 
              sat=1 	  	  
            else
              sat=-999
            endif
            sensor=nint(r8arr(10,1))
            if(sensor.eq.570) nchan=15
	    if(sensor.eq.547) nchan=5	  	  	  	 	  
            scanele=nint(r8arr(11,1))
            landsea=nint(r8arr(12,1))
            satzen=r8arr(13,1)
            solzen=r8arr(14,1)
            elev=r8arr(15,1)
            sathght=r8arr(16,1)
c     The remaining values of r8arr are the channel numbers and 
c     brightness temperatures, i.e., 1 tb1 2 tb2. I only need the
c     brightness temperatures, not the channel numbers themselves.          
            do 40 n=1,nchan
              m=(n-1)*3          
              tb(n)=r8arr(20+m,1)
              if(ABS(tb(n)-1.0e11) .lt. 1.0e10) tb(n)=-99.0
40          continue          
            date=yr*10000+mo*100+dy
            time=hr*10000+mi*100+se

            if(sat.eq.15) then
              write(luout15,50) date,time,lat,lon,sat,sensor,scanele,
     &        landsea,satzen,solzen,elev,sathght,(tb(n),n=1,15)     
            elseif(sat.eq.16) then
              write(luout16,50) date,time,lat,lon,sat,sensor,scanele,
     &        landsea,satzen,solzen,elev,sathght,(tb(n),n=1,15)
            elseif(sat.eq.18) then
              write(luout18,50) date,time,lat,lon,sat,sensor,scanele,
     &        landsea,satzen,solzen,elev,sathght,(tb(n),n=1,15) 
            elseif(sat.eq.19) then
              write(luout19,50) date,time,lat,lon,sat,sensor,scanele,
     &        landsea,satzen,solzen,elev,sathght,(tb(n),n=1,15)                    
            elseif(sat.eq.2) then
              write(luout2,50) date,time,lat,lon,sat,sensor,scanele,
     &        landsea,satzen,solzen,elev,sathght,(tb(n),n=1,15)                                          
            elseif(sat.eq.1) then
              write(luout1,50) date,time,lat,lon,sat,sensor,scanele,
     &        landsea,satzen,solzen,elev,sathght,(tb(n),n=1,15)                                          
            else
              write(*,*) 'Unknown satellite id in bufr file ',
     &        r8arr(9,1)
            endif	
	  
	  ELSEIF(csubset .eq. 'NC021249') THEN
	    	    	    	    	    
            yr=nint(r8arr(1196,1))
            mo=nint(r8arr(1197,1))
            dy=nint(r8arr(1198,1))
            hr=nint(r8arr(1199,1))
            mi=nint(r8arr(1200,1))
            se=nint(r8arr(1201,1))
            lat=r8arr(1202,1)
            lon=r8arr(1203,1)
	    if(r8arr(1,1).eq.784) sat=1                             	              	  
            sensor=nint(r8arr(1195,1))
            if(sensor.eq.570) nchan=15            	  	  	  	 	  
            scanele=nint(r8arr(1206,1))
	    
            IF(scanele.eq.eleold) THEN
	      GOTO 30
	    ELSE
	      eleold=scanele
	    ENDIF	    
	    
	    
	    
            landsea=0
            satzen=r8arr(1204,1)
            solzen=r8arr(6,1)
            elev=0
            sathght=r8arr(5,1)
c     The remaining values of r8arr are the channel numbers and 
c     brightness temperatures, i.e., 1 tb1 2 tb2. I only need the
c     brightness temperatures, not the channel numbers themselves.          
            do 45 n=1,nchan
              m=(n-1)*4          
              tb(n)=r8arr(1210+m,1)
              if(ABS(tb(n)-1.0e11) .lt. 1.0e10) tb(n)=-99.0
45          continue          
            date=yr*10000+mo*100+dy
            time=hr*10000+mi*100+se	    
	    	    	    	    	    	    
            if(sat.eq.1) then
              write(luoutaq,50) date,time,lat,lon,sat,sensor,scanele,
     &        landsea,satzen,solzen,elev,sathght,(tb(n),n=1,15)                                          
            endif	    
	    	    	    	    	    	    	    	    	    	    	    	    	    	    	    	    	    	  
	  ENDIF  
50        format(i8,1x,i6,1x,2(f8.3,1x),1x,i2,2x,i3,2x,i2,2x,i1,2x,
     &           f8.3,1x,f8.3,1x,i5,2x,i6,2x,15(f6.2,2x))          

	  
	  	  
          goto 30
        else
	  print*,nmsg,nsb	  	    
          goto 10
        endif    	
      endif

      call closbf(lubfr)
      
900   continue                   
      IF(cbufrin.eq.'amuata.ibm') THEN
        close(unit=luout15)
        close(unit=luout16)
        close(unit=luout18)
        close(unit=luout19)
        close(unit=luout2)              
        close(unit=luout1)              
      ELSEIF(cbufrin.eq.'airsev.ibm') THEN
        CLOSE(unit=luoutaq)
      ENDIF	       
      
              
   
      stop
      end

