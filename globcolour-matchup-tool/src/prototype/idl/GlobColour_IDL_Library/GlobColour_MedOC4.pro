PRO GlobColour_MedOC4, SILENT=silent, DATA_TYPE=data_type

;+
;Name:      GlobColour_MedOC4
;
;Purpose:   Extract L[443-555] data for Mediterranean sub-region from many L3b Global GlobColour (4km) data and generate MedOC4 Chlrophyll product
;
;Inputs:   	None (pop up prompt on run)
;
;Output:		Extracted subset in 3-column (lon, lat, value) CSV file (optional) + an area average time-series file
;
;Keywords:	SILENT -> Run in silenat mode; Do not print processing status to console
;						DATA_TYPE -> input string indicating the data type (accepted strings are '[D]AILY' or '[W]EEKLY' or '[M]ONTHLY'
;
;Syntax:		GlobColour_MedOC4 [,/SILENT] [DATA_TYPE=value]
;
;Example: 	GlobColour_MedOC4, DATA_TYPE='D' ;to process from Daily data
;						GlobColour_MedOC4, DATA_TYPE='M' ;to process from Monthly data
;						GlobColour_MedOC4, DATA_TYPE='W' ;to process from 8Day data
;
;Mathematical expression: ChlmedOC4 = 10.^(0.4424 - 3.686*X + 1.076*X^2 + 1.684*X^3 - 1.437*X^4), where X = alog10( max([R443/R555, R490/R555, R510/R555]) )
;
; MODIFICATION HISTORY:
;   22/11/2007    Yaswant Pradhan Original release of code, Version 1.00
;
; $Log: GlobColour_MedOC4.pro,v $
; $Id: GlobColour_MedOC4.pro,v 1.0 2007/11/21 15:36:00 yaswant Exp $
;-

close,/all

;+Mediterranean (including Black Sea) Subset Limits
;--------------------------------------------------
	LonLimit = [-6.0, 42.0]
	LatLimit = [30.0, 47.0]
	lat_cent = mean(LatLimit)
	lon_cent = mean(LonLimit)
	lon_diff = (lonlimit[1]-lonlimit[0])
	lat_diff = (latlimit[1]-latlimit[0])
	view_x_size = fix(lon_diff*24)+10
	view_y_size = fix(lat_diff*24)+130
	product_name = 'MedOC4_CHL1'

	pct_int=10.	;print at % processing interval
;--------------------------------------------------

	if( keyword_set(data_type) ) then begin
		if( strmatch(data_type,'D*',/fold_case) ) then dt='DAY' else $
		if( strmatch(data_type,'W*',/fold_case) ) then dt='8D' else $
		if( strmatch(data_type,'M*',/fold_case) ) then dt='MO'
	endif else dt='DAY'


	product_filter ='L3b_*_'+dt+'*.nc*'
	L443_filter = 'L443_'+dt
	L490_filter = 'L490_'+dt
	L510_filter = 'L510_'+dt
	L555_filter = 'L555_'+dt



;------------------------------------
	chl_template={$
 	VERSION : 1.0,$
 	DATASTART : 1,$
 	DELIMITER : 44b,$
 	MISSINGVALUE : !values.f_NaN,$
 	COMMENTSYMBOL : '',$
 	FIELDCOUNT : 3,$
 	FIELDTYPES : [4,4,4],$
 	FIELDNAMES : ['LON','LAT','CHL'],$
 	FIELDLOCATIONS : [0,16,32],$
 	FIELDGROUPS : [0,1,2]}
;------------------------------------


	if(keyword_set(silent)) then silen=1b else silen=0b
	separator=path_sep()

	filDir=DIALOG_PICKFILE(/DIRECTORY,/Read,Title='Select GlobCOLOUR L3b L[443-555] Files (4KM ISIN) Path', get_path=cwd)
	if ( strcmp(filDir,'') ) then stop,'Nothing Selected!'
	cd,cwd

  SearchResult=FILE_SEARCH(filDir, product_filter, count=nFiles)
  if(nFiles GT 0) then Files=SearchResult(sort(SearchResult)) else stop, 'No Match'

	p443=where(STREGEX(Files,L443_filter) NE -1, n443)
	if(n443 GT 0) then L443Files=Files(p443) else stop,'No Radiance files found Band 443'

	p490=where(STREGEX(Files,L490_filter) NE -1, n490)
	if(n490 GT 0) then L490Files=Files(p490) else stop,'No Radiance files found Band 490'

	p510=where(STREGEX(Files,L510_filter) NE -1, n510)
	if(n510 GT 0) then L510Files=Files(p510) else stop,'No Radiance files found Band 510'

	p555=where(STREGEX(Files,L555_filter) NE -1, n555)
	if(n555 GT 0) then L555Files=Files(p555) else stop,'No Radiance files found Band 555'

	if( (n555 ne n510) or (n555 ne n490) or (n555 ne n443) ) then print,'WARNING - Some nLw files corresponding to L555 maybe missing.'+string(10b)


	for i=0,n555-1 do begin
		T_L555 = (strsplit(file_basename(L555Files(i)),'_',/extract))[1]
		split_name = strsplit(file_basename(L555Files(i)),'_\.',/extract)
		cut = strpos(file_basename(L555Files(i)),'__')
		f1 = where( strcmp(T_L555, strmid(file_basename(L443Files),4,cut-4)), nf1 )
		f2 = where( strcmp(T_L555, strmid(file_basename(L490Files),4,cut-4)), nf2 )
		f3 = where( strcmp(T_L555, strmid(file_basename(L510Files),4,cut-4)), nf3 )


		if(product([nf1,nf2,nf3]) GT 0) then begin
			MedOC4_filename = split_name[0]+'_'+split_name[1]+'__MED_'+split_name[3]+'_MEDOC4_CHL1_'+split_name[6]+'_'+split_name[7]+'.CSV'
			openw,10,MedOC4_filename
			printf,10,'Lon,Lat,ChlMedOC4'
			if (~silen) then print,'Reading File: '+L555Files(i)
			subset_GCnetcdf, L555Files(i), /decompress, LON_LIMIT=LonLimit, LAT_LIMIT=LatLimit, L555_data, GET_LATS=lat555, GET_LONS=lon555, GET_ROWS=r555, GET_COLS=c555;, /WRITE_PNG, /exclude_points, /WRITE_CSV, /ZEU, /ZSD, /ZHL
			if (~silen) then print,'Reading File: '+L443Files(f1[0])
			subset_GCnetcdf, L443Files(f1[0]), /decompress, LON_LIMIT=LonLimit, LAT_LIMIT=LatLimit, L443_data, GET_ROWS=r443, GET_COLS=c443;, /WRITE_PNG
			if (~silen) then print,'Reading File: '+L490Files(f2[0])
			subset_GCnetcdf, L490Files(f2[0]), /decompress, LON_LIMIT=LonLimit, LAT_LIMIT=LatLimit, L490_data, GET_ROWS=r490, GET_COLS=c490;, /WRITE_PNG
			if (~silen) then print,'Reading File: '+L510Files(f3[0])
			subset_GCnetcdf, L510Files(f3[0]), /decompress, LON_LIMIT=LonLimit, LAT_LIMIT=LatLimit, L510_data, GET_ROWS=r510, GET_COLS=c510;, /WRITE_PNG

			total_pix = n_elements(L555_data)
			pct_complete=0.
			for k=0L,total_pix-1 do begin
				f1=where( (r555(k) EQ r443) and (c555(k) EQ c443), nf1 )
				f2=where( (r555(k) EQ r490) and (c555(k) EQ c490), nf2 )
				f3=where( (r555(k) EQ r510) and (c555(k) EQ c510), nf3 )

				if((nf1*nf2*nf3) EQ 1) then begin
					MBR = alog10( MAX([L443_data(f1)/L555_data(k), L490_data(f2)/L555_data(k), L510_data(f3)/L555_data(k)]) )
					Chl_medOC4 = 10.^(0.4424 - 3.686*MBR + 1.076*MBR^2. + 1.684*MBR^3. - 1.437*MBR^4.)
					lon = lon555(k)
					lat = lat555(k)
					printf,10,lon,lat,Chl_medOC4,format='(2(F,","),F)'
				endif

				proc_inc = fix(double(total_pix)/pct_int)
				if(  (k mod proc_inc) EQ 0.) then begin
				if (~silen) then print,string(pct_int*pct_complete,format='(I3)')+'%  Complete...'
				pct_complete++
				endif
			endfor
			close,10
			if (~silen) then print,'WRITE_CSV Success: ',MedOC4_filename
			;wait,0.5



			medoc4_data=read_ascii(MedOC4_filename, template=chl_template)
			;------------------------
			device,decomposed=0
			!p.background='ffffff'x
			!p.color='000000'x
			loadct,39
			;------------------------
			window,1,title=file_basename(MedOC4_filename,'.CSV'),xsize=view_x_size,ysize=view_y_size
			plot_data = bytscl(alog10(medoc4_data.CHL), MAX=alog10(10.), MIN=alog10(0.01), TOP=254)
			map_set, lat_cent, lon_cent, 0, LIMIT=[latlimit(0)-0.05, lonlimit(0)-0.05, latlimit(1)+0.05, lonlimit(1)+0.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER

			plots, medoc4_data.LON, medoc4_data.LAT, COLOR=plot_data, PSYM=3;,PSYM=symcat(13), symsize=0.25

			map_continents, /COASTS, COLOR=0, /HIRES;, FILL_CONTINENTS=1;, FILL_CONTINENTS=2
			map_grid, /BOX_AXES,CLIP_TEXT=0, Label=2;,LONS=lons,LATS=lats;,/NO_GRID

			bar_divisions=6
			incr = (alog10(10.)-alog10(0.01))/bar_divisions
			tick_values = 10.^( alog10(0.01) + findgen(bar_divisions+1)*incr )
			tick_names = string(tick_values,format='(F5.2)')
			colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT='(F5.2)', TITLE='CHL_MedOC4 [mg/m!u3!n]',TICKNAMES=tick_names,CHARSIZE=1.1,/top
			xyouts,/normal,.5,.96,file_basename(MedOC4_filename,'.CSV'),alignment=0.5,charsize=1.5

			png_filename = file_basename(MedOC4_filename,'.CSV')+'.PNG'
			png_data=TVRD(True=1)
      TVLCT,r,g,b,/Get
      WRITE_PNG, 'PNG'+separator+png_filename, png_data, r, g, b, _Extra=extra
      print,"WRITE_PNG Success: ",png_filename

		endif else print,'WARNING - Some files are missing for '+T_L555


	endfor

	device,decomposed=1


print,'Finish.'
END