PRO nLw_Rfl
;+
;Calculate Meris equivalent Reflectance and exact_nLw from NOMAD Lw and Es
;-
COMMON INSITU,inData,inRows,inCols
close,/all
read_GC_insitu, /nomad  ;Read GlobCOLOUR in-situ data (NOMAD format; Note: if the in-situ data format changes, you have to change the template in 'read_GC_insitu.pro')
    ;++in-situ meta
    inYear=inData.Year
    inMonth=inData.Month
    inDate=inData.Day
    inID=inData.NOMAD_ID
    inSDY=LONARR(inRows)
    for i=0,inRows-1 do inSDY(i)=sdy(inDate(i),inMonth(i),inYear(i))
    inHour=inData.Hour
    inMin=inData.Minute
    inLon=inData.Longitude
    inLat=inData.Latitude
    inDay=LONG((1000.*inYear)+inSDY)
    inTime=(1000.*inYear)+inSDY+(double(inHour)/24.)+(double(inMin)/1440.)
    ;--

    ;++in-situ data
    inChl_a=inData.Chl_a    ;SeaWiFS, MODISA, MERIS
    inChl_f=inData.CHL_FL   ;SeaWiFS, MODISA, MERIS
    inChl_af=inChl_a        ;Cobined inChl_a and inChl_f
        no_a=where(inChl_a LT 0.,cnt)
        if (cnt GT 0.) then inChl_af(no_a)=inChl_f(no_a)
    inKd_490=inData.Kd489   ;SeaWiFS, MODISA, MERIS

    inLw_411=inData.Lw411   ;SeaWiFS,MODISA,MERIS
    inLw_443=inData.Lw443   ;SeaWiFS,MODISA,MERIS
    inLw_489=inData.Lw489   ;SeaWiFS,MODISA,MERIS
    inLw_510=inData.Lw510   ;SeaWiFS,MERIS
    inLw_530=inData.Lw530   ;MODISA
    inLw_555=inData.Lw555   ;SeaWiFS,MODISA,MERIS
    inLw_619=inData.Lw619   ;MERIS
    inLw_670=inData.Lw670   ;SeaWiFS,MODISA,MERIS
    inLw_683=inData.Lw683   ;MERIS


    inEs_411=inData.Es411   ;SeaWiFS,MODISA,MERIS
    inEs_443=inData.Es443   ;SeaWiFS,MODISA,MERIS
    inEs_489=inData.Es489   ;SeaWiFS,MODISA,MERIS
    inEs_510=inData.Es510   ;SeaWiFS,MERIS
    inEs_530=inData.Es530   ;MODISA
    inEs_555=inData.Es555   ;SeaWiFS,MODISA,MERIS
    inEs_619=inData.Es619   ;MERIS
    inEs_670=inData.Es670   ;SeaWiFS,MODISA,MERIS
    inEs_683=inData.Es683   ;MERIS


    ;++Normalise in-situ Lw [Ref: http://oceancolor.gsfc.nasa.gov/DOCS/RSR_tables.html]
    inWL=[411.,443.,489.,510.,530.,555.,619.,670.,683.] ;Actual in-situ wavelengths
    print,'Loading Thuillier F0 Table'
    openr,33,'C:\sw\sw\mypro\GlobCOLOUR\DDS_MatchUps\Thuillier_F0.DAT'
        head=strarr(15) ;15line header
        readf,33,head
        f0_data=fltarr(2,2198)
        readf,33,f0_data
        f0_wl=reform(f0_data(0,*))
        f0_th=reform(f0_data(1,*))
    close,33
    bw=10.  ;assume the spectral bandwidth to be 11nm for each wavelength
    F0=fltarr(n_elements(inWL))

    for nw=0,n_elements(inWL)-1 do begin
       pos=where(f0_wl GE inWL(nw)-bw/2. AND f0_wl LE inWL(nw)+bw/2.)
       F0[nw]=average(f0_th(pos))
    endfor

    ;++Initiate Variable for 1- standard normalisation
        inLwn_411=fltarr(inRows)
        inLwn_443=fltarr(inRows)
        inLwn_489=fltarr(inRows)
        inLwn_510=fltarr(inRows)
        inLwn_530=fltarr(inRows)
        inLwn_555=fltarr(inRows)
        inLwn_619=fltarr(inRows)
        inLwn_670=fltarr(inRows)
        inLwn_683=fltarr(inRows)

    ;2- Exact Normalisation
        inexLwn_411=fltarr(inRows)
        inexLwn_443=fltarr(inRows)
        inexLwn_489=fltarr(inRows)
        inexLwn_510=fltarr(inRows)
        inexLwn_530=fltarr(inRows)
        inexLwn_555=fltarr(inRows)
        inexLwn_619=fltarr(inRows)
        inexLwn_670=fltarr(inRows)
        inexLwn_683=fltarr(inRows)

    ;3- MERIS Reflectance
        inRfl_411=fltarr(inRows)
        inRfl_443=fltarr(inRows)
        inRfl_489=fltarr(inRows)
        inRfl_510=fltarr(inRows)
        inRfl_530=fltarr(inRows)
        inRfl_555=fltarr(inRows)
        inRfl_619=fltarr(inRows)
        inRfl_670=fltarr(inRows)
        inRfl_683=fltarr(inRows)
    ;--Initiate Variable

;++
openw,1,'Lw_Es_nLw_exnLw_Rfl.csv'
printf,1,'Year,SDY,Longitude,Latitude,SZA,Chl,'+ $
       'Lw411,Lw443,Lw489,Lw510,Lw530,Lw555,Lw619,Lw670,Lw683,'+ $
       'Es411,Es443,Es489,Es510,Es530,Es555,Es619,Es670,Es683,'+ $
       'nLw411,nLw443,nLw489,nLw510,nLw530,nLw555,nLw619,nLw670,nLw683,'+ $
       'exnLw411,exnLw443,exnLw489,exnLw510,exnLw530,exnLw555,exnLw619,exnLw670,exnLw683,'+ $
       'Rfl411,Rfl443,Rfl489,Rfl510,Rfl530,Rfl555,Rfl619,Rfl670,Rfl683'
;--




    for r=0,inRows-1 do begin
        ;++Calulate the standard normalised Lw
        inLwn_411(r)= (inLw_411(r) GT 0. AND inEs_411(r) GT 0.) ? (inLw_411(r)*F0(0)/inEs_411(r)) : -1.
        inLwn_443(r)= (inLw_443(r) GT 0. AND inEs_443(r) GT 0.) ? (inLw_443(r)*F0(1)/inEs_443(r)) : -1.
        inLwn_489(r)= (inLw_489(r) GT 0. AND inEs_489(r) GT 0.) ? (inLw_489(r)*F0(2)/inEs_489(r)) : -1.
        inLwn_510(r)= (inLw_510(r) GT 0. AND inEs_510(r) GT 0.) ? (inLw_510(r)*F0(3)/inEs_510(r)) : -1.
        inLwn_530(r)= (inLw_530(r) GT 0. AND inEs_530(r) GT 0.) ? (inLw_530(r)*F0(4)/inEs_530(r)) : -1.
        inLwn_555(r)= (inLw_555(r) GT 0. AND inEs_555(r) GT 0.) ? (inLw_555(r)*F0(5)/inEs_555(r)) : -1.
        inLwn_619(r)= (inLw_619(r) GT 0. AND inEs_619(r) GT 0.) ? (inLw_619(r)*F0(6)/inEs_619(r)) : -1.
        inLwn_670(r)= (inLw_670(r) GT 0. AND inEs_670(r) GT 0.) ? (inLw_670(r)*F0(7)/inEs_670(r)) : -1.
        inLwn_683(r)= (inLw_683(r) GT 0. AND inEs_683(r) GT 0.) ? (inLw_683(r)*F0(8)/inEs_683(r)) : -1.
        ;--Calulate the standard normalised Lw

        ;++Calulate Reflectance
        ;Rfl = PI*Lw/Es (REVAMP protocol)
        ;(http://www.brockmann-consult.de/revamp/pdfs/REVAMP_Protocols.pdf)
        inRfl_411(r)= (inLw_411(r) GT 0. AND inEs_411(r) GT 0.) ? (inLw_411(r)*!PI/inEs_411(r)) : -1.
        inRfl_443(r)= (inLw_443(r) GT 0. AND inEs_443(r) GT 0.) ? (inLw_443(r)*!PI/inEs_443(r)) : -1.
        inRfl_489(r)= (inLw_489(r) GT 0. AND inEs_489(r) GT 0.) ? (inLw_489(r)*!PI/inEs_489(r)) : -1.
        inRfl_510(r)= (inLw_510(r) GT 0. AND inEs_510(r) GT 0.) ? (inLw_510(r)*!PI/inEs_510(r)) : -1.
        inRfl_530(r)= (inLw_530(r) GT 0. AND inEs_530(r) GT 0.) ? (inLw_530(r)*!PI/inEs_530(r)) : -1.
        inRfl_555(r)= (inLw_555(r) GT 0. AND inEs_555(r) GT 0.) ? (inLw_555(r)*!PI/inEs_555(r)) : -1.
        inRfl_619(r)= (inLw_619(r) GT 0. AND inEs_619(r) GT 0.) ? (inLw_619(r)*!PI/inEs_619(r)) : -1.
        inRfl_670(r)= (inLw_670(r) GT 0. AND inEs_670(r) GT 0.) ? (inLw_670(r)*!PI/inEs_670(r)) : -1.
        inRfl_683(r)= (inLw_683(r) GT 0. AND inEs_683(r) GT 0.) ? (inLw_683(r)*!PI/inEs_683(r)) : -1.
        ;--Calulate Reflectance

        ;++BRDF correction
        solz=solar(inSDY(r),inHour(r),inMin(r),inLat(r),inLon(r))   ;Returns the Sun Zenith Angle in radians
        if (inChl_a(r) GT 0.) then inChl=inChl_a(r) $
        else if (inChl_a(r) LT 0. AND inChl_f(r) GT 0.) then inChl=inChl_f(r) $
        else inChl=0.1  ;Set Chl value to 0.1, if there are no measurements

        morel_fq,inWL,9,solz*!RADEG,0.,135.,inChl,f_Q
        ;++Calulate the exact normalised Lw
        inexLwn_411(r)= (inLwn_411(r) GT 0.) ? inLwn_411(r)*f_Q[0] : -1.
        inexLwn_443(r)= (inLwn_443(r) GT 0.) ? inLwn_443(r)*f_Q[1] : -1.
        inexLwn_489(r)= (inLwn_489(r) GT 0.) ? inLwn_489(r)*f_Q[2] : -1.
        inexLwn_510(r)= (inLwn_510(r) GT 0.) ? inLwn_510(r)*f_Q[3] : -1.
        inexLwn_530(r)= (inLwn_530(r) GT 0.) ? inLwn_530(r)*f_Q[4] : -1.
        inexLwn_555(r)= (inLwn_555(r) GT 0.) ? inLwn_555(r)*f_Q[5] : -1.
        inexLwn_619(r)= (inLwn_619(r) GT 0.) ? inLwn_619(r)*f_Q[6] : -1.
        inexLwn_670(r)= (inLwn_670(r) GT 0.) ? inLwn_670(r)*f_Q[7] : -1.
        inexLwn_683(r)= (inLwn_683(r) GT 0.) ? inLwn_683(r)*f_Q[8] : -1.
        ;--Calulate the exact normalised Lw
        ;--BRDF correction

printf,1,inYear(r),inSDY(r),inLon(r),inLat(r),solz*!RADEG,inChl, $
       inLw_411(r),inLw_443(r),inLw_489(r),inLw_510(r),inLw_530(r),inLw_555(r),inLw_619(r),inLw_670(r),inLw_683(r), $
       inEs_411(r),inEs_443(r),inEs_489(r),inEs_510(r),inEs_530(r),inEs_555(r),inEs_619(r),inEs_670(r),inEs_683(r),$
       inLwn_411(r),inLwn_443(r),inLwn_489(r),inLwn_510(r),inLwn_530(r),inLwn_555(r),inLwn_619(r),inLwn_670(r),inLwn_683(r), $
       inexLwn_411(r),inexLwn_443(r),inexLwn_489(r),inexLwn_510(r),inexLwn_530(r),inexLwn_555(r),inexLwn_619(r),inexLwn_670(r),inexLwn_683(r), $
       inRfl_411(r),inRfl_443(r),inRfl_489(r),inRfl_510(r),inRfl_530(r),inRfl_555(r),inRfl_619(r),inRfl_670(r),inRfl_683(r),$
       FORMAT='(2(I,","),49(f,","))'
    endfor
    ;--
    ;--
close,1
PRINT,'...FINISH...'
END