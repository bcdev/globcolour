PRO FULL_NORMALISE_NOMAD, NOMADFile, VERB=verb

;Applies f/Q correction to NOMAD data and writes the output in GlobColour in-situ format

	close,/all
	if(n_params() LT 1) then begin
		NOMADFile = dialog_pickfile(/read,filter='*.txt',title='Please Select "nomad_seabass_v1.3_2005262.txt" or a file in similar format',get_path=nomad_path)
		cd,nomad_path
	endif
	if( strcmp(NOMADFile, '') ) then retall


;Read NOMAD data to structure inData
	inData = read_ascii(NOMADFile, template=GET_NOMAD_TEMPLATE())
	if( keyword_set(verb) ) then help,inData,/struct

;++NOMAD meta
    inYear = 	inData.YEAR
    inMonth = inData.MONTH
    inDate = 	inData.DAY
    inID =		inData.ID
    inRows =	n_elements(inData.ID)
    inSDY =		LONARR(inRows)
    for i=0,inRows-1 do inSDY(i)=sdy(inDate(i),inMonth(i),inYear(i))
    inHour =	inData.HOUR
    inMin =		inData.MINUTE
    inLon =		inData.LON
    inLat =		inData.LAT
    Cruise =	inData.CRUISE
    inDay =		LONG((1000.*inYear)+inSDY)
    inTime =	(1000.*inYear)+inSDY+(double(inHour)/24.)+(double(inMin)/1440.)
;--NOMAD meta

	wait,0.5

    ;++Select Output Normalised File Name
    exactNormalisedFile= DIALOG_PICKFILE(FILTER='*.csv',/WRITE,Title='Please Enter Exact normalised File Name.')
    openw,lun,exactNormalisedFile,/get_lun
		printf,lun, 'ID,DDS_ID,DDS_NAME,Year,Month,Date,Hour,Minute,Longitude,Latitude,Depth,Chla_hplc,Chla_fluor,Kd490,TSM,' + $
								'acdm443,bbp443,T865,exLwn412,exLwn443,exLwn490,exLwn510,exLwn531,exLwn555,exLwn620,Lwn670,Lwn681,Lwn709,'+ $
								'Flag,Campaign,Comments'	; Note that bbp443 is actually bb443 (total backscattering) from NOMAD database

		printf,lun, 'ID,ii,dds_name,YYYY,MM,DD,hh,mm,decimal_degrees,decimal_degrees,metre,mg/m3,mg/m3,1/m,g/m3,1/m,1/m,None,'+ $
								'mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,mW/cm2/um/sr,BinaryCode,Cruisename,None'
		printf,lun, 'String,Integer,String,Long,Integer,Integer,Integer,Integer,Float,Float,Float,Double,Double,Double,Double,'+$
								'Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Long,String,String'

    ;printf,lun, 'ID,YYYY,MM,DD,hour,minute,LON,LAT,Chl_a,Chl_f,K490,nLw412,nLw443,nLw490,nLw510,nLw531,nLw555,nLw620,nLw670,nLw683,Cruise'


    ;++in-situ data
    inChl_a	=	inData.CHL_A    ;SeaWiFS, MODISA, MERIS
    inChl_f	=	inData.CHL   ;SeaWiFS, MODISA, MERIS
    inChl_af=	inChl_a        ;Cobined inChl_a and inChl_f
        no_a=	where(inChl_a LT 0.,cnt)
        if (cnt GT 0.) then inChl_af(no_a)=inChl_f(no_a)

		inad443 =	inData.AD443 > 0.
		inag443 =	inData.AG443 > 0.
		inCDM443=	inad443 + inag443	;GlobColour definition of CDM
		inCDM443[where(inCDM443 EQ 0.)] = -999.

		inbb_443=	inData.bb443	 ;MERIS, GSM01

    inKd_490=	inData.KD489   ;SeaWiFS, MODISA, MERIS

    inLw_411=	inData.LW411   ;SeaWiFS,MODISA,MERIS
    inLw_443=	inData.LW443   ;SeaWiFS,MODISA,MERIS
    inLw_489=	inData.LW489   ;SeaWiFS,MODISA,MERIS
    inLw_510=	inData.LW510   ;SeaWiFS,MERIS
    inLw_530=	inData.LW530   ;MODISA
    inLw_555=	inData.LW555   ;SeaWiFS,MODISA,MERIS
    inLw_619=	inData.LW619   ;MERIS
    inLw_670=	inData.LW670   ;SeaWiFS,MODISA,MERIS
        pos=	where(inData.LW670 LT 0.)
        inLw_670(pos)=inData.LW665(pos)
    inLw_683=	inData.LW683   ;MERIS


    inEs_411=	inData.ES411   ;SeaWiFS,MODISA,MERIS
    inEs_443=	inData.ES443   ;SeaWiFS,MODISA,MERIS
    inEs_489=	inData.ES489   ;SeaWiFS,MODISA,MERIS
    inEs_510=	inData.ES510   ;SeaWiFS,MERIS
    inEs_530=	inData.ES530   ;MODISA
    inEs_555=	inData.ES555   ;SeaWiFS,MODISA,MERIS
    inEs_619=	inData.ES619   ;MERIS
    inEs_670=	inData.ES670   ;SeaWiFS,MODISA,MERIS
        pos=	where(inData.ES670 LT 0.)
        inEs_670(pos)=inData.ES665(pos)
    inEs_683=	inData.ES683   ;MERIS


    ;++Normalise in-situ Lw [Ref: http://oceancolor.gsfc.nasa.gov/DOCS/RSR_tables.html]
    inWL = [411.,443.,489.,510.,530.,555.,619.,667.,683.] ;Actual in-situ wavelengths
    print,'Loading Thuillier F0 Table'
    openr,33,'Thuillier_F0.DAT'
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

;++Initiate Variable for
	;1- standard normalisatio
    inLwn_411=	fltarr(inRows)
    inLwn_443=	fltarr(inRows)
    inLwn_489=	fltarr(inRows)
    inLwn_510=	fltarr(inRows)
    inLwn_530=	fltarr(inRows)
    inLwn_555=	fltarr(inRows)
    inLwn_619=	fltarr(inRows)
    inLwn_670=	fltarr(inRows)
    inLwn_683=	fltarr(inRows)

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
;--Initiate Variable

;Read Morel f/Q LUT
		fqtab=read_MorelfQ_LUT()

;Begin Normalisation loop
    for r=0,inRows-1 do begin
    ;for r=0,10 do begin
			;++Calulate the standard normalised Lw
    	inLwn_411(r)= (inLw_411(r) GT 0. AND inEs_411(r) GT 0.) ? (inLw_411(r)*F0(0)/inEs_411(r)) : -999.
      inLwn_443(r)= (inLw_443(r) GT 0. AND inEs_443(r) GT 0.) ? (inLw_443(r)*F0(1)/inEs_443(r)) : -999.
      inLwn_489(r)= (inLw_489(r) GT 0. AND inEs_489(r) GT 0.) ? (inLw_489(r)*F0(2)/inEs_489(r)) : -999.
      inLwn_510(r)= (inLw_510(r) GT 0. AND inEs_510(r) GT 0.) ? (inLw_510(r)*F0(3)/inEs_510(r)) : -999.
      inLwn_530(r)= (inLw_530(r) GT 0. AND inEs_530(r) GT 0.) ? (inLw_530(r)*F0(4)/inEs_530(r)) : -999.
      inLwn_555(r)= (inLw_555(r) GT 0. AND inEs_555(r) GT 0.) ? (inLw_555(r)*F0(5)/inEs_555(r)) : -999.
      inLwn_619(r)= (inLw_619(r) GT 0. AND inEs_619(r) GT 0.) ? (inLw_619(r)*F0(6)/inEs_619(r)) : -999.
      inLwn_670(r)= (inLw_670(r) GT 0. AND inEs_670(r) GT 0.) ? (inLw_670(r)*F0(7)/inEs_670(r)) : -999.
      inLwn_683(r)= (inLw_683(r) GT 0. AND inEs_683(r) GT 0.) ? (inLw_683(r)*F0(8)/inEs_683(r)) : -999.
      ;--Calulate the standard normalised Lw

   ;++BRDF correction
      solz=solar(inSDY(r),inHour(r),inMin(r),inLat(r),inLon(r))   ;Returns the Sun Zenith Angle in radians
      if (inChl_a(r) GT 0.) then inChl=inChl_a(r) $
      else if (inChl_a(r) LT 0. AND inChl_f(r) GT 0.) then inChl=inChl_f(r) $
      else inChl=0.1  ;Set Chl value to 0.1, if there are no measurements


		  ;Get f/Q correction factor
      get_morel_fQ, fqtab, inWL, 9, solz*!RADEG, 0., 0., inChl, f_Q

        ;print,'f_Q correction factors : ',f_Q
      ;++Calulate the exact normalised Lw
      inexLwn_411(r)= (inLwn_411(r) GT 0.) ? inLwn_411(r)*f_Q[0] : -999.
      inexLwn_443(r)= (inLwn_443(r) GT 0.) ? inLwn_443(r)*f_Q[1] : -999.
      inexLwn_489(r)= (inLwn_489(r) GT 0.) ? inLwn_489(r)*f_Q[2] : -999.
      inexLwn_510(r)= (inLwn_510(r) GT 0.) ? inLwn_510(r)*f_Q[3] : -999.
      inexLwn_530(r)= (inLwn_530(r) GT 0.) ? inLwn_530(r)*f_Q[4] : -999.
      inexLwn_555(r)= (inLwn_555(r) GT 0.) ? inLwn_555(r)*f_Q[5] : -999.
      inexLwn_619(r)= (inLwn_619(r) GT 0.) ? inLwn_619(r)*f_Q[6] : -999.
      inexLwn_670(r)= (inLwn_670(r) GT 0.) ? inLwn_670(r)*f_Q[7] : -999.
      inexLwn_683(r)= (inLwn_683(r) GT 0.) ? inLwn_683(r)*f_Q[8] : -999.
      ;--Calulate the exact normalised Lw
   ;--BRDF correction

			printf,lun, 'GC_ID','DDS_ID','DDS_NAME',inYear(r),inMonth(r),inDate(r),inHour(r),inMin(r),inLon(r),inLat(r),0.0,inChl_a(r),inChl_f(r),inKd_490(r), $
									-999.,inCDM443(r),inbb_443(r),-999.,$
									inexLwn_411(r),inexLwn_443(r),inexLwn_489(r),inexLwn_510(r),inexLwn_530(r),inexLwn_555(r),inexLwn_619(r),inLwn_670(r),inLwn_683(r),-999., $
									(inData.FLAG)[r],Cruise(r),inID(r),format='(3(A,","),5(I,","),20(F,","),I,",",A,",",I)'

    endfor;for r=0,inRows-1 do begin
;End Normalisation loop

	free_lun,lun
	close,/all


print,'===>DONE<==='

END