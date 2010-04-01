;+
; NAME:
;   SOLAR
;
; PURPOSE:
;   Calculate the solar zenith angle (and optionally the omega angle (see below))
;
; CATEGORY:
;   FUNCTION
;
; CALLING SEQUENCE:
;   solar(srd,hour,minute,lat,lon)
;
; EXAMPLE:
;   solar(201,12,35,20.,10.)
;
; INPUTS:
;   utc   flt or fltarr: the time (UTC) as days since Jan 1 00:00 of the year
;     e.g. the time 0.5 is noon of Jan 1st.
;     (presently it also works for the following year, if the first year
;      had 365 days. I.e it works for the NOXAR times for 1995 and 1996 but
;      not yet for 1997
;   srd int or flt: Serial day of year (1.-365.)
;   hour int or float: UTC hour of the day (0.-23.)
;   minute int or float: UTC minutes of the day (0.-59.)
;   lat   flt or fltarr: the latitude in deg (pos. for northern hemisphere)
;   lon   flt or fltarr: the longitude in deg (pos. for eastern longitudes)
;
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORD INPUT PARAMETERS:
;
; OUTPUTS
;   the solar zenith angle in radian
;   omega : the hour angle in radian
;       the local time (in fractional hours) can be approximated by
;       calculating 12+omega*180/!pi*24/360.
; COMMON BLOCKS:
;   None
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
;   First implementation Oct, 25 2004 by Yaswant Pradhan
;   adapted from the JNO2 program by Wiel Wauben, KNMI
;-

FUNCTION r2d,radians
degrees=radians*(180./!PI)
RETURN,degrees
END
FUNCTION d2r,degrees
radians=degrees*(!PI/180.)
RETURN,radians
END

FUNCTION SOLAR, srd, hour, minute, lat, lon, omega=omega

   utc=srd + hour/24.0 + double(minute/(24.0*60.0))
   print,'UTC = ',utc

; if utc,lat and lon do not have the same number of elements
; then resize the arrays to the minimal number of elements
   dim=Min([n_elements(srd),n_elements(hour),n_elements(minute),n_elements(lat),n_elements(lon)])

   if n_elements(srd) gt dim then srd=srd(0:dim-1)
   if n_elements(hour) gt dim then hour=hour(0:dim-1)
   if n_elements(minute) gt dim then minute=minute(0:dim-1)
   if n_elements(lat) gt dim then lat=lat(0:dim-1)
   if n_elements(lon) gt dim then lon=lon(0:dim-1)

; calculate the number of days since the 1.1. of the specific year
   daynum=floor(utc)+1
   ;print,daynum

; calculate the relative SUN-earth distance for the given day
; resulting from the elliptic orbit of the earth
   eta = 2.*!pi*daynum/365.
   fluxfac = 1.000110 $
            +0.034221*cos(eta)+0.000719*cos(2.*eta) $
            +0.001280*sin(eta)+0.000077*sin(2.*eta)
   dist = 1./sqrt(fluxfac)

; calculate the solar declination for the given day
; the declination varies due to the fact, that the earth rotation axis
; is not perpendicular to the ecliptic plane
   delta = 0.006918$
          -0.399912*cos(eta)-0.006758*cos(2.*eta)-0.002697*cos(3.*eta)$
          +0.070257*sin(eta)+0.000907*sin(2.*eta)+0.001480*sin(3.*eta)

; equation of time, used to compensate for the earth's elliptical orbit
; around the sun and its axial tilt when calculating solar time
; eqt is the correction in hours
   et = 2.*!pi*daynum/366.
   eqt = 0.0072*cos(et)-0.0528*cos(2.*et)-0.0012*cos(3.*et)$
        -0.1229*sin(et)-0.1565*sin(2.*et)-0.0041*sin(3.*et)

; calculate the solar zenith angle
   ;dtr = !pi/180. ; degrees to radian conversion factor
   time = (utc+1.-daynum)*24 ; time in hours
   omega = d2r((360./24.)*(time+lon/15.+eqt-12.))
   sunh = sin(delta)*sin(d2r(lat))+cos(delta)*cos(d2r(lat))*cos(omega)

;IF (sunh lt -1.0) THEN sunh=-1.0
;IF (sunh gt 1.0) THEN sunh=1.0
   solel = asin(sunh)
   sza = !pi/2.-solel

; Solar azimuth added by yaswant
   azi=(sin(delta)*cos(d2r(lat))-cos(delta)*sin(d2r(lat))*cos(omega))$
        /cos(!pi/2.-sza)

;IF (azi lt -1.0) THEN azi=-1.0
;IF (azi gt 1.0) THEN azi=1.0

azim = acos(azi)
print,'Solar Azimuth (in degs) :        ',r2d(azim)
print,'Solar Zenith Angle (in degs) :',r2d(sza)
print,'Solar Elevation Angle (in degs) :',r2d(solel)
print,'Hour Angle (in degrees) :           ',r2d(omega)
; Function return is solar zenith in radians
return,sza
end
