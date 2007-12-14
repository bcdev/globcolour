PRO subset_GCnetcdf, 	filename, DECOMPRESS=decompress, LON_LIMIT=lon_limit, LAT_LIMIT=lat_limit, sub_data, EXCLUDE_POINTS=exclude_points, $
											WRITE_CSV=write_csv, WRITE_PNG=write_png, ZEU=Zeu, ZSD=Zsd, ZHL=Zhl, $
											GET_LATS=get_lats, GET_LONS=get_lons, GET_ROWS=get_rows, GET_COLS=get_cols

;+
;Name:      subset_GCnetcdf
;
;Purpose:   Extract data for a sub-region from L3b Global GlobColour (4km) data
;
;Inputs:   	A 4km GlobColour netCDF file in Isin projection (1°=24 rows, total number of latitudinal rows in a 4km Global data = 4320)
;
;Output:		(Optional) 1. Extracted subset in 3-column (lon, lat, value) CSV file, 2. extracted data in variable sub_data
;
;Keywords:	DECOMPRESS -> If the input file is provided in gzip compressed format, this keyword will uncopmress the file
;						LON_LIMIT -> minimum (left) and maximum (right) limit of subset longitude; range-> -180., 180.
;						LAT_LIMIT -> minimum (bottom) and maximum (top) limit of subset latitude; range-> -78., 90.
;						EXCLUDE_POINTS -> Provide an additional csv file containing the Lon, Lat values to be masked out
;						WRITE_CSV -> if the output is required in a CSV spreadsheet file
;						WRITE_PNG -> if the output is required as a picture (PNG) format
;						ZEU -> Estimates the empirical Euphotic Depth (m) from Chl concentration (Morel et al 2007, RSE, 111, 69-88, obsolete - Morel 1988, JGR, 93, 10749-10768)
;						ZSD	-> Estimates the empirical Secchi Depth (m) from Chl concentration (Morel et al 2007, RSE, 111, 69-88)
;						ZHL -> Estimates the empirical Heated Layer Depth (m) from Kd490 (Morel et al 2007, RSE, 111, 69-88)
;						GET_LATS -> A named variable to store latitude vector of the sunset
;						GET_LONS -> A named variable to store longitude vector of the sunset
;						GET_ROWS -> A named variable to store the GlobColour ISIN grid row vector of the sunset
;						GET_COLS -> A named variable to store the GlobColour ISIN grid column vector of the sunset


;Syntax:		subset_GCnetcdf, Filename, LON_LIMIT=[min, max], LAT_LIMIT=[min, max] [,SUB_DATA] [,/EXCLUDE_POINTS] [,/WRITE_CSV] [/WRITE_PNG] [,/ZEU] [,/ZSD] [,/ZHL]
;
;Example: subset_GCnetcdf, 'L3b_20020226-20020305__GLOB_4_GSM-SWF_CHL1_8D_00.nc', LON_LIMIT=[-6.5,42.], LAT_LIMIT=[30., 47.], /WRITE_CSV
;
; MODIFICATION HISTORY:
;   09/11/2007    Yaswant Pradhan Original release of code, Version 1.00
;
; $Log: subset_GCnetcdf.pro,v $
; $Id: subset_GCnetcdf.pro,v 1.0 2007/11/09 14:50:00 yaswant Exp $
;-


if ( n_params() LT 1 ) then stop,'SYNTAX: Result = subset_GCnetcdf, Filename, LON_LIMIT=[min, max], LAT_LIMIT=[min, max] [,SUB_DATA] [,/EXCLUDE_POINTS] [,/WRITE_CSV] [/WRITE_PNG] [,/ZEU] [,/ZSD] [,/ZHL] [,/WRITE_CSV] [,GET_LATS=var] [,GET_LONS=var]'
if ~( keyword_set(lon_limit) and keyword_set(lat_limit) ) then $
  													stop,'SYNTAX: Result = subset_GCnetcdf, Filename, LON_LIMIT=[min, max], LAT_LIMIT=[min, max] [,SUB_DATA] [,/EXCLUDE_POINTS] [,/WRITE_CSV] [/WRITE_PNG] [,/ZEU] [,/ZSD] [,/ZHL][,/WRITE_CSV] [,GET_LATS=var] [,GET_LONS=var]'

if ( lon_limit[0] LT -180.0 or lon_limit[1] GT 180.0 or lat_limit[0] LT -78.0 or lat_limit[1] GT 90.0 ) then stop, 'Lat-Lon Limit Error 1: LON_LIMIT=[-180.0, 180.], LAT_LIMIT=[-78.0, 90.0] '
if ( (lon_limit[0] GT lon_limit[1]) or (lat_limit[0] GT lat_limit[1]) ) then stop, 'Lat-Lon Limit Error 2: LON_LIMIT=[min_lon, max_lon], LAT_LIMIT=[min_lat, max_lat] '



;===========================================================================================================
plot_range = [0.01,10.0]	;default plot range to change product plot range go to line ;change plot range
bar_divisions = 6				;colour bar divisions

lon_diff = (lon_limit[1]-lon_limit[0])
lat_diff = (lat_limit[1]-lat_limit[0])

if(lat_diff LT 10. or lon_diff LT 10.) then begin
	filled_square=1b	;set this flag to 1b to use filled squares in stead of dots; needs additional SYMCAT.PRO function
	view_x_size = fix(lon_diff*24.*10)+10	;adjust the multiplication factor
	view_y_size = fix(lat_diff*24.*10)+130	;adjust the multiplication factor
endif else if (lat_diff GE 40. or lon_diff GE 40.) then begin
	filled_square=0b
	if( (fix(lon_diff*24) GT (get_screen_size())[0]) or (fix(lat_diff*24) GT (get_screen_size())[1]) ) then begin
		fract = ( lon_diff*24/ (get_screen_size())[0] ) > ( lat_diff*24 / (get_screen_size())[1] )
		;print,fract
		view_x_size = fix( (lon_diff*24)/ fract )-100+10
		view_y_size = fix( (lat_diff*24)/ fract )-100+130
	endif else begin
		view_x_size = fix(lon_diff*24)+10
		view_y_size = fix(lat_diff*24)+130
	endelse
endif
; else begin
;	filled_square=0b
;	view_x_size = fix(lon_diff*20)
;	view_y_size = fix(lat_diff*30)
;endelse

lat_cent = mean(lat_limit) ;central latitude
lon_cent = mean(lon_limit) ;central longitude

lon_lat_maskfile = 'D:\2003\CHL1\lon_lat_mask.csv' ;change appropriate
;print,lat_cent, lon_cent

n_rows = ceil( ((lat_limit[1] - lat_limit[0])*24.)/2 )
constrain_zsd = 0b	;if set as 1b then Zsd will be computed only for Chl values < 15mg/m3
;===========================================================================================================


if( (lon_diff+lat_diff) GT 450.) then stop,string(10b)+'WARNING! Subset area is too large to allocate memory. Please reduce the area and try again!'+string(10b)
;if( (lat_limit[0] LT -78.0) then stop,string(10b)+'WARNING! minLat should be grater than -78. Please reduce the area and try again!'+string(10b)

separator = path_sep()
;+Decompress File
compress = 0b
if(keyword_set(DECOMPRESS)) then begin
	file_length = strlen(filename)
	pos = strpos(filename,'.',/reverse_search)
	suffix = strmid(filename, pos, file_length)

	if( strcmp(suffix,'.gz') ) then begin
		compress = 1b
		cfilename = filename
		spawn, 'gzip -d -k '+cfilename	;decompress gzip file keeping the original compressed file
		filename = strmid( cfilename,0,pos )
	endif else if( strcmp(suffix,'.nc') ) then filename = filename
endif
;-
;print,'debug',filename,compress

t0=systime(1)
offset_count=get_gcCntOffset(filename, lat_cent, NR=n_rows)	;NR = rows on either sides of the in-situ Latitude
;print,offset_count
;stop
sub_data=-999.0
get_lats=-999.0
get_lons=-999.0



if ( total(offset_count) GT 0 ) then begin

  read_gcnetCDF, filename, data, attr, /subset, COUNT=offset_count[1], OFFSET=offset_count[0]

	data_tags = tag_names(data)
  row_info = attr[where(stregex(attr,'first_row =') NE -1)]
  first_row = LONG(strmid(row_info,stregex(row_info,'[0-9]')))
  lat_step_info = attr[where(stregex(attr,'lat_step =') NE -1)]
  lat_step = DOUBLE(strmid(lat_step_info,stregex(lat_step_info,'[0-9]')))

	unit_info = attr[where(stregex(attr,'units =') NE -1)]
  unit = strmid(strtrim(unit_info[3],1),7)

  idx = data.row-first_row[0]
  Lat = data.center_lat(idx)
  Lon = data.center_lon(idx) + data.col*data.lon_step(idx)

  ;plot, Lon, Lat, psym=2, Xst=1, Yst=1
  ;p=NearestPoint(Lon, Lat, inLon, inLat, MaxDist=inDist, SR=inDist, nP=9)


	x=where(Lon GE lon_limit[0] and Lon LE lon_limit[1],n_x)

	if(n_x GT 0) then begin
		get_lats=(sub_lat=Lat(x))
		get_lons=(sub_lon=Lon(x))
		get_rows=(data.row)[x]
		get_cols=(data.col)[x]
		;decide which parameter is available in the data
		if (TOTAL(strmatch(data_tags,'CHL1_MEAN'))) then sub_data=(data.CHL1_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'CHL2_MEAN'))) then sub_data=(data.CHL2_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'KD490_MEAN'))) then sub_data=(data.KD490_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'TSM_MEAN'))) then sub_data=(data.TSM_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'CDM_MEAN'))) then sub_data=(data.CDM_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'BBP_MEAN'))) then sub_data=(data.BBP_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'T865_MEAN'))) then sub_data=(data.T865_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L412_MEAN'))) then sub_data=(data.L412_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L443_MEAN'))) then sub_data=(data.L443_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L490_MEAN'))) then sub_data=(data.L490_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L510_MEAN'))) then sub_data=(data.L510_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L531_MEAN'))) then sub_data=(data.L531_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L555_MEAN'))) then sub_data=(data.L555_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L620_MEAN'))) then sub_data=(data.L620_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L670_MEAN'))) then sub_data=(data.L670_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L681_MEAN'))) then sub_data=(data.L681_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'L709_MEAN'))) then sub_data=(data.L709_MEAN)[x] else $
		if (TOTAL(strmatch(data_tags,'EL555_MEAN'))) then sub_data=(data.EL555_MEAN)[x]

;+Exclude selective points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		if(keyword_set(EXCLUDE_POINTS)) then begin
 			lon_lat_template={$
 			VERSION : 1.0,$
 			DATASTART : 1,$
 			DELIMITER :  44b,$
 			MISSINGVALUE : !values.f_NaN,$
 			COMMENTSYMBOL : '',$
 			FIELDCOUNT : 2,$
 			FIELDTYPES : [4,4],$
 			FIELDNAMES : ['Lon','Lat'],$
 			FIELDLOCATIONS : [0,12],$
 			FIELDGROUPS : [0,1]}

			!EXCEPT=0
			mask=read_ascii(lon_lat_maskfile, template=lon_lat_template)
			for i=0,n_elements(mask.Lat)-1 do begin
				get_index=NearestPoint(sub_lon,sub_lat,(mask.Lon)[i],(mask.Lat)[i], SR=0.005)
				if(product(get_index) GE 0) then sub_data(get_index) = !values.f_nan
			endfor

		endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-


;+Derived products from CHL1
		chl1_flag=(kd490_flag=0b)

		if (TOTAL(strmatch(data_tags,'CHL1_MEAN'))) then begin
			chl1_flag=1b
;i) Euphotic Depth
			if( keyword_set(zeu) ) then Zeu_data = 10.^(1.524 - 0.436*alog10(sub_data) - 0.0145*alog10(sub_data)^2. + 0.0186*alog10(sub_data)^3. );Obsolete relation Zeu_data = 38.*sub_data^(-0.428)
;ii) Secchi Depth, Zsd = 8.50 - 12.6 X + 7.36 X2 - 1.43 X3, where X=log10(chl1)
			if( keyword_set(zsd) ) then begin
				Zsd_data = 8.5 - 12.6*alog10(sub_data) + 7.36*alog10(sub_data)^2. - 1.43*alog10(sub_data)^3.
				if(constrain_zsd) then Zsd_data[where(sub_data GT 15.0)] = !values.f_nan
			endif
		endif
;-


;+Derived products from Kd490
		if (TOTAL(strmatch(data_tags,'KD490_MEAN'))) then begin
			kd490_flag=1b
			print,'Kd490 data found.................'
;i) Heated Layer, Zhl
			if( keyword_set(zhl) ) then begin
				;KdPAR_data = sub_data*1.48 ;(Kratzer et al 2003, Ambio, 32(8), 577-585)
				KdPAR_data = 0.0665 + 0.874*sub_data - 0.00121/sub_data	;as defined by Morel et al 2007 (Kd(PAR)2
				Zhl_data = 2./KdPAR_data
			endif
		endif
;-



;+write subset data to png file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		if( keyword_set(WRITE_PNG) ) then begin
			FILE_MKDIR,'PNG'
;===============================================================================
;change plot range
			if (TOTAL(strmatch(data_tags,'CHL1_MEAN'))) then plot_range = [0.01,10.0]
			if (TOTAL(strmatch(data_tags,'CHL2_MEAN'))) then plot_range = [0.01,20.0]
			if (TOTAL(strmatch(data_tags,'KD490_MEAN'))) then plot_range = [0.01,1.0]
			if (TOTAL(strmatch(data_tags,'TSM_MEAN'))) then plot_range = [0.01,20.0]
			if (TOTAL(strmatch(data_tags,'CDM_MEAN'))) then plot_range = [0.001,0.10]
			if (TOTAL(strmatch(data_tags,'BBP_MEAN'))) then plot_range = [0.001,0.10]
			if (TOTAL(strmatch(data_tags,'T865_MEAN'))) then plot_range = [0.01,0.5]
			if (TOTAL(strmatch(data_tags,'L412_MEAN'))) then plot_range = [0.01,5.0]
			if (TOTAL(strmatch(data_tags,'L443_MEAN'))) then plot_range = [0.01,4.0]
			if (TOTAL(strmatch(data_tags,'L490_MEAN'))) then plot_range = [0.01,2.5]
			if (TOTAL(strmatch(data_tags,'L510_MEAN'))) then plot_range = [0.01,2.5]
			if (TOTAL(strmatch(data_tags,'L531_MEAN'))) then plot_range = [0.01,2.5]
			if (TOTAL(strmatch(data_tags,'L555_MEAN'))) then plot_range = [0.01,1.5]
			if (TOTAL(strmatch(data_tags,'L620_MEAN'))) then plot_range = [0.01,1.0]
			if (TOTAL(strmatch(data_tags,'L670_MEAN'))) then plot_range = [0.01,1.0]
			if (TOTAL(strmatch(data_tags,'L681_MEAN'))) then plot_range = [0.01,0.5]
			if (TOTAL(strmatch(data_tags,'L709_MEAN'))) then plot_range = [0.01,0.2]
;===============================================================================

			device,decomposed=0
			!p.background='ffffff'x
			!p.color='000000'x
			loadct,39
			;plots,sub_lon,sub_lat,bytscl(sub_data),psym=3;psym=symcat(15),symsize=0.2;,xstyle=1,ystyle=1,/iso,title=file_basename(filename)
			window,1,title=file_basename(filename,'.nc'),xsize=view_x_size,ysize=view_y_size
			plot_data = bytscl(alog10(sub_data), MAX=alog10(plot_range[1]), MIN=alog10(plot_range[0]), TOP=254)
			if(lon_diff LT 359. and lat_diff LT 179.) then map_set,  lat_cent, lon_cent, 0, LIMIT=[lat_limit(0)-0.05, lon_limit(0)-0.05, lat_limit(1)+0.05, lon_limit(1)+0.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER $
			else map_set, lat_cent, lon_cent, 0, LIMIT=[lat_limit(0), lon_limit(0), lat_limit(1), lon_limit(1)], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER

			if(filled_square) then plots, sub_lon, sub_lat, PSYM=symcat(15), symsize=1.1, COLOR=plot_data $
			else plots, sub_lon, sub_lat, PSYM=3, COLOR=plot_data

			map_continents, /COASTS, COLOR=0, /HIRES;, FILL_CONTINENTS=1;, FILL_CONTINENTS=2
			map_grid, /BOX_AXES,CLIP_TEXT=0, Label=2;,LONS=lons,LATS=lats;,/NO_GRID

			incr = (alog10(plot_range[1])-alog10(plot_range[0]))/bar_divisions
			tick_values = 10.^( alog10(plot_range[0]) + findgen(bar_divisions+1)*incr )
			tick_names = string(tick_values,format='(F5.2)')
			colorbar, POSITION=[0.15, 0.00, 0.85, 0.02], FORMAT='(F5.2)', TITLE=unit,TICKNAMES=tick_names,CHARSIZE=1.1,/top
			xyouts,/normal,.5,.96,file_basename(filename),alignment=0.5,charsize=1.5

			png_filename = file_basename(filename,'.nc')+'.PNG'
			png_data=TVRD(True=1)
      TVLCT,r,g,b,/Get
      WRITE_PNG, 'PNG'+separator+png_filename, png_data, r, g, b, _Extra=extra
      print,"WRITE_PNG Success: ",png_filename


;+Zeu Euphotic Depth
			if( keyword_set(zeu) and chl1_flag) then begin
				window,2,title=file_basename(filename,'.nc')+'.zeu',xsize=view_x_size,ysize=view_y_size
				plot_Zeu_data = bytscl(Zeu_data, MAX=150, MIN=0, TOP=254)
				if(lon_diff LT 359. and lat_diff LT 179.) then map_set, lat_cent, lon_cent, 0, LIMIT=[lat_limit(0)-0.05, lon_limit(0)-0.05, lat_limit(1)+0.05, lon_limit(1)+0.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER $
				else map_set, lat_cent, lon_cent, 0, LIMIT=[lat_limit(0), lon_limit(0), lat_limit(1), lon_limit(1)], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER

				if(filled_square) then plots, sub_lon, sub_lat, PSYM=symcat(15), symsize=1.1, COLOR=plot_Zeu_data $
				else plots, sub_lon, sub_lat, PSYM=3, COLOR=plot_Zeu_data

				map_continents, /COAST, COLOR=0, /HIRES;, FILL_CONTINENTS=2
				map_grid, /BOX_AXES,CLIP_TEXT=0, Label=2;,LONS=lons,LATS=lats;,/NO_GRID

				colorbar, POSITION=[0.15, 0.00, 0.85, 0.02], TITLE='Z!dEU!u!n [m]', RANGE=[0,150], DIVISIONS=4, CHARSIZE=1.1,/top
				xyouts,/normal,.5,.96,'Z!dEU!u!n from '+file_basename(filename),alignment=0.5,charsize=1.5

				png_Zeu_filename = 'PNG'+separator+file_basename(filename,'.nc')+'.Zeu.PNG'
				png_Zeu_data=TVRD(True=1)
      	TVLCT,r,g,b,/Get
      	WRITE_PNG, png_Zeu_filename, png_Zeu_data, r, g, b, _Extra=extra
      	print,"WRITE_PNG Success: ",png_Zeu_filename
			endif
;-


;+Zsd Sechhi Depth
			if( keyword_set(zsd) and chl1_flag) then begin
				window,3,title=file_basename(filename,'.nc')+'.zsd',xsize=view_x_size,ysize=view_y_size
				plot_Zsd_data = bytscl(Zsd_data, MAX=80, MIN=0, TOP=254)
				if(lon_diff LT 359. and lat_diff LT 179.) then map_set, lat_cent, lon_cent, 0, LIMIT=[lat_limit(0)-0.05, lon_limit(0)-0.05, lat_limit(1)+0.05, lon_limit(1)+0.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER $
				else map_set, lat_cent, lon_cent, 0, LIMIT=[lat_limit(0), lon_limit(0), lat_limit(1), lon_limit(1)], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER

				if(filled_square) then plots, sub_lon, sub_lat, PSYM=symcat(15), symsize=1.1, COLOR=plot_Zsd_data $
				else plots, sub_lon, sub_lat, PSYM=3, COLOR=plot_Zsd_data

				map_continents, /COAST, COLOR=0, /HIRES;, FILL_CONTINENTS=2
				map_grid, /BOX_AXES,CLIP_TEXT=0, Label=2;,LONS=lons,LATS=lats;,/NO_GRID

				colorbar, POSITION=[0.15, 0.00, 0.85, 0.02], TITLE='Z!dSD!u!n [m]', RANGE=[0,80], DIVISIONS=4, CHARSIZE=1.1,/top
				xyouts,/normal,.5,.96,'Z!dSD!u!n from '+file_basename(filename),alignment=0.5,charsize=1.5

				png_Zsd_filename = 'PNG'+separator+file_basename(filename,'.nc')+'.Zsd.PNG'
				png_Zsd_data=TVRD(True=1)
      	TVLCT,r,g,b,/Get
      	WRITE_PNG, png_Zsd_filename, png_Zsd_data, r, g, b, _Extra=extra
      	print,"WRITE_PNG Success: ",png_Zsd_filename
			endif
;-

;+Zhl Heated Layer
			if( keyword_set(zhl) and kd490_flag) then begin
				window,2,title=file_basename(filename,'.nc')+'.zhl',xsize=view_x_size,ysize=view_y_size
				plot_Zhl_data = bytscl(Zhl_data, MAX=60, MIN=0, TOP=254)
				if(lon_diff LT 359. and lat_diff LT 179.) then map_set, lat_cent, lon_cent, 0, LIMIT=[lat_limit(0)-0.05, lon_limit(0)-0.05, lat_limit(1)+0.05, lon_limit(1)+0.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER $
				else map_set, lat_cent, lon_cent, 0, LIMIT=[lat_limit(0), lon_limit(0), lat_limit(1), lon_limit(1)], /ISOTROPIC, /CYLINDRICAL, XMARGIN=[4,4], YMARGIN=[6,5], /CLIP, /NOBORDER

				if(filled_square) then plots, sub_lon, sub_lat, PSYM=symcat(15), symsize=1.1, COLOR=plot_Zhl_data $
				else plots, sub_lon, sub_lat, PSYM=3, COLOR=plot_Zhl_data

				map_continents, /COAST, COLOR=0, /HIRES;, FILL_CONTINENTS=2
				map_grid, /BOX_AXES,CLIP_TEXT=0, Label=2;,LONS=lons,LATS=lats;,/NO_GRID

				colorbar, POSITION=[0.15, 0.00, 0.85, 0.02], TITLE='Z!dHL!u!n [m]', RANGE=[0,60], DIVISIONS=4, CHARSIZE=1.1,/top
				xyouts,/normal,.5,.96,'Z!dHL!u!n from '+file_basename(filename),alignment=0.5,charsize=1.5

				png_Zhl_filename = 'PNG'+separator+file_basename(filename,'.nc')+'.Zhl.PNG'
				png_Zhl_data=TVRD(True=1)
      	TVLCT,r,g,b,/Get
      	WRITE_PNG, png_Zhl_filename, png_Zhl_data, r, g, b, _Extra=extra
      	print,"WRITE_PNG Success: ",png_Zhl_filename
			endif
;-

		endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-



;--------------------------------------------------
;+write subset data to csv file (lon, lat, value)
		if( keyword_set(WRITE_CSV) ) then begin
			FILE_MKDIR,'CSV'
			csv_filename = 'CSV'+separator+file_basename(filename,'.nc')+'.csv'
			split_csv_filename = strsplit(csv_filename,'_',/extract)
			p = where( strcmp(split_csv_filename,'GLOB') )

			if(p[0] GE 0) then begin
				split_csv_filename(p[0])=strtrim(string(lon_limit[0],format='(f6.1)'),2)+'-'+strtrim(string(lon_limit[1],format='(f6.1)'),2)+'-'+strtrim(string(lat_limit[0],format='(f6.1)'),2)+'-'+strtrim(string(lat_limit[1],format='(f6.1)'),2)
				csv_filename = strjoin(split_csv_filename,'_')
			endif else stop,'The input file does not seem to be a valid GlobColour Global File. Please check the Filename'+filename
			print,'Writing file '+csv_filename+' ...'
			openw,1,csv_filename
			printf,1,'Lon,Lat,Value'
			for r=0D,n_x-1 do begin
				printf,1,sub_lon(r),sub_lat(r),sub_data(r),format='(2(f,","),f)'
			endfor
			close,1
		endif; if( keyword_set(write_csv) ) then begin
;--------------------------------------------------

	endif else print,'No Valid Bins found for subsetting! in '+filename
	PRINT,'Time Taken (in secs): ',systime(1)-t0
	;stop, 'Success STOP!'

	if(compress) then FILE_DELETE,filename
endif
device,decomposed=1


END