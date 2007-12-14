FUNCTION getClosest, inlat, inlon, wantlat, wantlon

lat=inlat
lon=inlon
siz=SIZE(lat)
IF (siz[0] eq 0) OR (siz[0] gt 2) THEN RETURN,-1    ;fail
IF (siz[0] eq 1) THEN BEGIN
    Ncols=1
    Nrows=siz[1]
ENDIF ELSE BEGIN
    Ncols=siz[1]
    Nrows=siz[2]
    N=Ncols*Nrows
    lat=REFORM(lat,N)
    lon=REFORM(lon,N)
ENDELSE

;factor=SIN(MEDIAN(lat)/!RADEG)
factor=1.
x=factor*(lon-wantlon)
y=lat-wantlat
diff=x^2+y^2
res=MIN(diff, OK)
OK=OK[0]

row=FIX((1+OK)/Ncols)
col=OK MOD Ncols
;print,'closest at: coli=',col,' rowi=',row

RETURN,[col,row]
END