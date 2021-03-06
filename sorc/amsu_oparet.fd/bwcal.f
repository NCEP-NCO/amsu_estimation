c     bwcal.f
c
c     This group of routines is for calculating balanced winds
c     from mass fields
c  
      subroutine bwgcal(r,pp,tp,ps,ts,dz,nr,np,nz,rlat,
     +                 zp,vp,zz,tz,pz,rhoz,vz)
c     This routine calculates the gradient wind as a function of radius and
c     pressure, and as a function of radius and height, given the temperature
c     as a function of pressure, the pressure at the surface at r=rmax,
c     the surface temperature (assumed constant), and the latitude.
c
      dimension r(nr)
      dimension pp(np)
      dimension tp(nr,np),zp(nr,np),vp(nr,np)
      dimension ts(nr),ps(nr)
c
      dimension zz(nz)
      dimension tz(nr,nz),pz(nr,nz),rhoz(nr,nz),vz(nr,nz)
c
c     Input:  r   - radial coordinates (m)
c             pp  - pressure coordinates (pa)
c             tp  - temperature (k) as a function of r,p
c             ps  - surface pressure (Pa) a function of r
c             ts  - surface temperature (K) as a function of r
c             dz  - height increment for z (m) coordinates
c             nr  - No. of radii
c             np  - No. of pressure levels
c             nz  - No. of height levels
c             rlat - latitude (deg N)
c
c     Output: zp   - height (m) as a function of r,p
c             vp   - gradient wind (m/s) as a function of r,p
c             zz   - height (m) coordinate values (m)
c             tz   - temperature (K) as a function of r,z
c             pz   - pressure (Pa) as a function of r,z
c             rhoz - density (kg/m3) as a function of r,z
c             vz   - gradient wind as a function of r,z
c
      common /cons/ pi,g,rd,dtr,erad,erot
c
c*     Calculate Coriolis parameter  !changed by J. Knaff
c*                                   !11/22/02
c*      f  = 2.0*erot*sin(rlat*dtr)  !
c
c     Calculate Coriolis parameter
c     here we use the natural coordinate system so that our statistical
c     algorithms will work in the Southern Hemisphere. This involves using
c     the absolute value of f for our calculation of vz.
c
      f  = abs( 2.0*erot*sin(rlat*dtr) )
c
c     Extract ps at r=rmax
      psi = ps(nr)
c
c     Calculate z at r=rmax at lowest pressure level
      t1=ts(nr)
      t2=tp(nr,np)
      p1=psi
      p2=pp(np)
      call tkness(p1,p2,t1,t2,delz)
      zp(nr,np) = zz(1) + delz
c
c     Calculate the rest of the z values at r=rmax
      do 15 k=np-1,1,-1
         t1 = tp(nr,k+1)
         t2 = tp(nr,k  )
         p1 = pp(k+1)
         p2 = pp(k  )
         call tkness(p1,p2,t1,t2,delz)
         zp(nr,k) = zp(nr,k+1) + delz
   15 continue
c
c     Calculate z at upper most pressure (assumed constant with r)
      do 20 i=1,nr-1
         zp(i,1) = zp(nr,1)
   20 continue
c
c     Integrate z downward for r<rmax
      do 25 i=1,nr-1
      do 25 k=2,np
         t1 = tp(i,k  )
         t2 = tp(i,k-1)
         p1 = pp(k  )
         p2 = pp(k-1)
         call tkness(p1,p2,t1,t2,delz)
         zp(i,k) = zp(i,k-1) - delz
   25 continue
c
c     Evaluate surface pressure
      pz(nr,1) = psi
      do 30 i=1,nr-1
         t1 = tp(i,np)
         t2 = ts(i)
         z2 = zz(1)
         z1 = zp(i,np)
         p1 = pp(np)
         call p2cal(z1,z2,t1,t2,p1,p2)
         pz(i,1) = p2
   30 continue
c
c     Evaluate surface temperature 
      do 35 i=1,nr
         tz(i,1) = ts(i)
   35 continue
c
c     Calculate t and p at remaining height levels
      do 40 i=1,nr
      do 40 m=2,nz
c        Find first pressure level below current height level
         iplev = 0
         do 45 k=1,np
            if (zp(i,k) .lt. zz(m)) then
               iplev = k
               go to 1000
            endif
   45    continue
 1000    continue
c
         if (iplev .eq. 0) then
c           Current height is below bottom pressure level. Interpolate
c           between surface and lowest pressure level.
            t1 = tz(i,1)
            t2 = tp(i,1)
            z1 = zz(1)
            z2 = zp(i,1)
            p1 = pz(i,1)
            zt = zz(m)
c
            call tint(z1,z2,zt,t1,t2,tt)
            tz(i,m) = tt
c
            call p2cal(z1,zt,t1,tt,p1,pt)
            pz(i,m) = pt
c
         elseif (iplev .eq. 1) then
c           Current height level is above top pressure level. Assume
c           isothermal atmosphere from top pressure to current height.
            tz(i,m) = tp(i,1)
c
            t1 = tp(i,1)
            t2 = tz(i,m)
            z1 = zp(i,1)
            z2 = zz(m)
            p1 = pp(1)
            call p2cal(z1,z2,t1,t2,p1,p2)
            pz(i,m) = p2
         else
c           Current height level is between pressure levels
            t1 = tp(i,iplev)
            t2 = tp(i,iplev-1)
            z1 = zp(i,iplev)
            z2 = zp(i,iplev-1)
            zt = zz(m)
            p1 = pp(iplev)
c
            call tint(z1,z2,zt,t1,t2,tt)
            tz(i,m) = tt
c
            call p2cal(z1,zt,t1,tt,p1,pt)
            pz(i,m) = pt
         endif
   40 continue
c
c     Calculate density as a function of r,z
      do 50 i=1,nr
      do 50 m=1,nz
	 rhoz(i,m) = pz(i,m)/(rd*tz(i,m))
   50 continue
c
c     Calculate gradient wind as a function of r,z
c
c     Set v = 0 at r=0
      do 55 m=1,nz
	 vz(1,m) = 0.0
   55 continue
c
      do 60 i=2,nr
	 rm1 = r(i-1)
	 if (i .eq. nr) then
	    rp1 = r(i)
         else
	    rp1 = r(i+1)
         endif
         do 65 m=1,nz
	    pm1 = pz(i-1,m)
	    if (i .eq. nr) then
	       pp1 = pz(i,m)
            else
	       pp1 = pz(i+1,m)
            endif
c
	    pgrad = (pp1-pm1)/( (rp1-rm1)*rhoz(i,m) )
	    c = f*r(i)/2.0
c
	    if (pgrad .ge. 0.0) then
	       vz(i,m) = -c + sqrt(c*c + r(i)*pgrad)
            else
	       disc = c*c + r(i)*pgrad
               if (disc .le. 0.0) then 
	          vz(i,m) = -c 
               else 
		  vz(i,m) = -c + sqrt(disc)
               endif
	    endif
   65    continue
   60 continue
c
      return
      end
