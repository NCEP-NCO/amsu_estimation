      subroutine llintsp(f1,slon1,slat1,dlon1,dlat1,im1,jm1,i1,j1,
     +                  fsp,rlon,rlat,izp,ierr)
c
c     This routine linearly interpolates f1 on an evenly spaced
c     lat,lon grid to obtain fsp at the single point (rlon,rlat). 
c     The subroutine arguments are defined as follows:
c
c     f1(im1,jm1):  Contains the function to be interpolated. The
c                   first index represents longitude (increasing
c                   eastward) and the second index represents 
c                   latitude (increasing northward).
c
c     fsp:          The interpolated value of f1.
c
c     slon1         The first longitude of f1 (deg E positive)
c     slat1         The first latitude  of f1 (deg N positive)
c     dlon1         The longitude increment of f1 (deg)
c     dlat1         The latitude  increment of f1 (deg)
c     rlon,rlat     The longitude,latitude of the point to interpolate f1.
c
c     im1,jm1       The dimensions of f1
c
c     i1,j1         The number of longitude,latitude points of f1
c                   to use in the interpolation
c
c     izp           Zonal Periodic flag: 
c                       =1 when f1 is periodic in the zonal direction
c                          (normally used only when f1 spans 360 deg
c                          of longitude, starting at 0)
c                       =0 if not periodic
c
c     ierr          Error flag: =0 for normal return
c                               =1 if fsp is outside of the f1 domain
c                                  (non fatal)
c                               =2 if indices i1,j1 exceed
c                                  dimension of f1 (fatal) 
c                               =3 if dlon or dlat .le. 0.0 (fatal) 
c
      dimension f1(im1,jm1)
c
c     Initialize error flag
      ierr=0
c
c     Check indices and dlat,dlon
      if (i1 .gt. im1  .or.  j1 .gt. jm1) then  
          ierr=2
          return
      endif
c
      if (dlat1 .le. 0.0 .or. dlon1 .le. 0.0) then 
         ierr=3
         return
      endif
c
c     Specify needed constants
      pi   = 3.14159265
      dtr  = pi/180.0
      erad = 6371.0
      adtr = erad*dtr
c
c     Calculate min and max long,lat of f1 domain
      rlonn1 = slon1
      rlonx1 = slon1 + dlon1*float(i1-1)
      rlatn1 = slat1
      rlatx1 = slat1 + dlat1*float(j1-1)

c
c     Check if fsp point is outside of f1 domain.
c     If yes, move the fsp point to the nearest point in the
c     f1 domain and set error flag. 
c
      if (izp .ne. 1) then
c        Adjust fsp longitude for case without zonal periodicity
         if (rlon .gt. rlonx1) then
            rlon = rlonx1
            ierr=1
         endif
c
         if (rlon .lt. rlonn1) then
            rlon = rlonn1
            ierr=1
         endif
      else
c        Zonal periodic case
         if (rlon .ge. 360.0) rlon=rlon-360.0
      endif
c
      if (rlat .gt. rlatx1) then
         rlat = rlatx1
         ierr=1
      endif
c
      if (rlat .lt. rlatn1) then
         rlat = rlatn1
         ierr=1
      endif

c
c     Find the indices of the f1 point closest to,
c     but with lon,lat less than the fsp point.
      i00 = 1 + ifix( (rlon-rlonn1)/dlon1 )
      j00 = 1 + ifix( (rlat-rlatn1)/dlat1 )
      if (i00 .lt.    1)    i00=   1
      if (izp .ne. 1) then
         if (i00 .gt. i1-1) i00=i1-1
      endif
      if (j00 .lt.    1)    j00=   1
      if (j00 .gt. j1-1)    j00=j1-1
c
c     Define the four f1 values to be used in the linear
c     interpolation.
      f00 = f1(i00  ,j00  )
      f01 = f1(i00  ,j00+1)
c
      if (izp .eq. 1 .and. i00 .eq. i1) then
         f10 = f1(    1,j00  )
         f11 = f1(    1,j00+1)
      else
         f10 = f1(i00+1,j00  )
         f11 = f1(i00+1,j00+1)
      endif
c
c     Calculate the lon,lat of the point i00,j00
      rlon00 = rlonn1 + dlon1*float(i00-1)
      rlat00 = rlatn1 + dlat1*float(j00-1)
c
c     Calculate the x,y distances between the four f1 points
c     where x,y = 0,0 at i00,j00
      dx0 = dlon1*adtr*cos( dtr*(rlat00        ) )
      dx1 = dlon1*adtr*cos( dtr*(rlat00 + dlat1) )
      dy  = dlat1*adtr 
c
c     Calculate the x,y coordinates of the current f2 point
      x = adtr*(rlon-rlon00)*cos(dtr*rlat)
      y = adtr*(rlat-rlat00)
c
c     Calculate the coefficients for the linear interpolation
      a = f00
      b = (f10-f00)/dx0
      c = (f01-f00)/dy
      d = (f11 - f00 - b*dx1 - c*dy)/(dx1*dy)
c
c     Perform interpolation 
      fsp = a + b*x + c*y + d*x*y
c
      return
      end
