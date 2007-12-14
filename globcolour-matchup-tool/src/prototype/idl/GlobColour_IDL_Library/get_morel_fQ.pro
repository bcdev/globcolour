;+
; NAME:
;   get_Morel_FQ
; SYNTAX:
;   get_Morel_fQ, foqtable, wavelength_array, n_waves, thetaS, thetaV, dphi, Chl,
; PURPOSE:
;   To apply f/Q correction to Gordon & Clark Lw...
; INPUTS
;   DATA:
;     "morel_fq.dat" LUT can be found at http://www.crseo.ucsb.edu/seawifs/software/seadas/data/common/morel_fq.dat
;   ARGUMENTS:
;     Wavelength [scalar or vector] wavelength in nm
;     n_wave [scalar]  number of wavelength bands
;     thetaS [scalar] Solar Zenith angle in degrees
;     thetaV [scalar] Viewing Zenith angle in degrees
;     dphi   [scalar] Relative Azimuth difference
;     Chl    [scalar] Chlorophyll concentration in mg/m3
; OUTPUT:
;   brdf: f/Q correction factor as a function of wl, thetaS, thetaV, dphi, Chl
;   tab_data: LU Table data corresponding to the inputs (interpolated, if tabs do not match the LUT tabs)
;
; Author:
;   Yaswant Pradhan, University of Plymouth, Mar 2006
;   Last Change: Nov 2006 (WL interpolation)
;-

;++
FUNCTION CMAX, A,B
if (A ge B) then val=A else val=B
return,val
end
;--

;++
; return closest indice of xtab where xtab[i] < xval
FUNCTION morel_index, xtab, ntab, xval
    i = 0
    if (xval le xtab[0]) then begin
      i = 0
    endif else if (xval ge xtab[ntab-1]) then begin
      i = ntab-2
    endif else begin
        while (xval gt xtab[i]) do begin
          i=i+1
        endwhile
        i=i-1
    endelse
    return,i
end
;--


;++
PRO foqint_morel, foqtab, wave, nwave, solz, senzp, dphi, chl, brdf, tab_data

;foqtab is returned from foqtab=read_MorelfQ_LUT('morel_fq.dat')


wavetab =   [412.5,442.5,490.0,510.0,560.0,620.0,660.0]
solztab =   [0.,15.,30.,45.,60.,75.]
chltab =    [0.03,0.1,0.3,1.0,3.0,10.0]
senztab =   [1.078,3.411,6.289,9.278,12.300,15.330,18.370,21.410,24.450,27.500,30.540,33.590,36.640,39.690,42.730,45.780,48.830]
phitab =    [0.,15.,30.,45.,60.,75.,90.,105.,120.,135.,150.,165.,180.]
lchltab =   dblarr(6)

;Log transform Chl data
lchltab = alog(chltab)
ti=dblarr(nwave)

;Set Lower limits
lchl = alog(CMAX(chl,0.01))

if (senzp LT senztab[0]) then senzp = senztab[0]

;Lower bounding indices
for w=0,nwave-1 do ti[w] = morel_index(wavetab,7,wave[w])

js = morel_index(solztab,6,solz)
kc = morel_index(lchltab,6,lchl)
ln = morel_index(senztab,17,senzp)
ma = morel_index(phitab,13,dphi)


ds=(dc=(dn=(da=(dw=(dblarr(2))))))

ds[0]=(solztab[js+1]-solz)/(solztab[js+1]-solztab[js])
ds[1]=(solz-solztab[js])/(solztab[js+1]-solztab[js])

dc[0]=(lchltab[kc+1]-lchl)/(lchltab[kc+1]-lchltab[kc])
dc[1]=(lchl-lchltab[kc])/(lchltab[kc+1]-lchltab[kc])

dn[0]=(senztab[ln+1]-senzp)/(senztab[ln+1]-senztab[ln])
dn[1]=(senzp-senztab[ln])/(senztab[ln+1]-senztab[ln])

da[0]=(phitab [ma+1]-dphi)/(phitab [ma+1]-phitab [ma])
da[1]=(dphi-phitab [ma])/(phitab [ma+1]-phitab [ma])


for iw=0,nwave-1 do begin
    dw[0]=(wavetab[ti[iw]+1] - wave[iw])/(wavetab[ti[iw]+1]- wavetab [ti[iw]])
    dw[1]=(wave[iw] - wavetab[ti[iw]])/(wavetab[ti[iw]+1] - wavetab[ti[iw]])

  ; using nearest wavelength (tables are for MERIS bands)
    brdf[iw] = 0.0

    for i=0,1 do for j=0,1 do for k=0,1 do for l=0,1 do for m=0,1 do begin
        ;brdf[iw] = (ds[j]*dc[k]*dn[l]*da[m]*foqtab[i,js+j,kc+k,ln+l,ma+m])+brdf[iw]  ;No interpolation, use the nearest wl from LUT
        brdf[iw] = (dw[i]*ds[j]*dc[k]*dn[l]*da[m]*foqtab[ti[iw]+i,js+j,kc+k,ln+l,ma+m])+brdf[iw]
    endfor
endfor
print,brdf
end
;--



PRO get_morel_fQ, foqtab, wave, nwave, solz, senz, dphi, chl, brdf, tab_data


    brdf=(foq0=(foq=(dblarr(nwave))))

    foqint_morel, foqtab, wave, nwave, 0.0D, 0.0D, 0.0D, chl, foq0
    foqint_morel, foqtab, wave, nwave, solz, senz, dphi, chl, foq

    for i=0,nwave-1 do brdf[i] = double(foq0[i])/double(foq[i])
    tab_data=foq

    ;print,'f/Q: ',double(foq[*])
    print,'BRDF: ',double(brdf[*])

END
