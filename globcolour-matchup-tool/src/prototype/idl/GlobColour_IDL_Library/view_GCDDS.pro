PRO view_GCDDS,	DDSFilename, MN=mn,SD=sd,CNT=cnt,WT=wt,ER=er, $
								ALL_PRODUCTS=all_products,CHL1=chl1,CHL2=chl2,KD490=kd490,TSM=tsm,CDM=cdm,BBP=bbp,T865=t865, $
								L412=l412,L443=l443,L490=l490,L510=l510,L531=l531,L555=l555,L620=l620,L670=l670,L681=l681,L709=l709

;+
;NAME:
;	view_GCDDS

;PURPOSE:
;	Renders selected GlobCOLOUR DDS layers

;SYNTAX:
;	view_GCDDS [,DDSFilename] [,/MN | ,/SD | ,/CNT, | ,/WT | ,/ER] [,/ALL | [[,/CHL1] [,/CHL2] [,/KD490] [,/TSM] $
;	 					 [,/CDM] [,/BBP] [,/T865] [,/L412] [,/L443] [,/L490] [,/L510] [,/L531] [,/L555] [,/L620] [,/L670] [,/L681] [,/L709]]]

;INPUTS:
;	GlobColour DDS File (L3 mapped/binned)

;OUTPUTS:
;	Displays the selected layers (passed by keywords)

;KEYWORDS:
;	MN: 	Show  the mean/average fields (Default)
;	SD: 	Show  the Standard deviation fields
;	CNT:	Show  the Count fields
;	WT:		Show  the Weight fields
;	ER:		Show  the Error fields
;	CHL1:	Chlorophyll-a Case-1 type	(in mg/m3)	(Default)
;	CHL2:	Chlorophyll-a Case-2 type	(in mg/m3)
;	KD490:Diffuse attenuation coefficient at 490 nm	(in /m)
;	TSM:	Total Suspended Matter	(in g/m3)
;	CDM:	Coloured dissolved and detrital organic materials (in /m)
;	BBP:	Particle Backscattering coefficient (in /m)
;	T865:	Aerosol Optical Thickness ()
;	L412...L555: Exact normalised water-leaving radiance (in mW/cm2/um/sr)
;	L670...L709: Water-leaving radiance (in mW/cm2/um/sr)
;	ALL:	Opens all available layers in separate windows

;EXTERNAL ROUTINES/FUNCTIONS:
;	READ_NETCDF.pro:	Generic netcdf reader from SEE code library.
;	COLORBAR.pro:	David Fanning's colorbar routine. used to draw a colour bar for each variable.
;	SYMCAT.pro:	David Fanning's symcat function. used to plot solid squares.

;WARNING:
;	Make sure to install IDL high-resolution coastline vectors in default IDL resource/maps/ path for better rendering of the coastline

;ACKNOWLEDGEMENTS:
;	ESA-GlobColour

;	$Id: view_GCDDS.pro,v 2.0 05/06/2007 19:25:13 yaswant Exp $
; view_GCDDS.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;	Yaswant.Pradhan@plymouth.ac.uk
;-


;Define Variable type from keyword parameter
	var_type = 'MN' ;Default variable type to show
	if ( keyword_set(sd) ) then var_type='SD' else if ( keyword_set(cnt) ) then var_type='CNT' else if ( keyword_set(wt) ) then var_type='WT' else $
	if ( keyword_set(er) ) then var_type='ER' else if ( keyword_set(fl) ) then var_type='FL'


;######################################################################################################
;Configuration structure (Change/Edit values as appropriate) DO NOT modify the tag names
	pconfig = { $
			color_tab: 		39, $									;Colour Tbale to load (39 is Rainbow-white)
			default_chl1:	0b, $									;If nothing passed as keyword chl_1 will be shown as default
			symid:		15, 	symsize:	2.37, $		;Symbol ID (15 for filled square) and size for L3B maps
			nXgrids:	5, 		nYgrids:	5,	 	$		;Number of grids on the map
			wXsize:		500.,	wYsize:		500. 	}		;Plot window size

	case var_type of

		'MN': begin
			rconfig = { $
			level_format:	'(F5.2)', $
			min_chl1:	0.01, max_chl1:	10.0, $		;Min and Max range for CHL1 average
			min_chl2:	0.01, max_chl2:	10.0, $		;Min and Max range for CHL2	average
			min_kd490:0.01,	max_kd490:01.0, $		;Min and Max range for KD490average
			min_tsm:	0.00, max_tsm:	10.0, $		;Min and Max range for TSM	average
			min_cdm:	0.0001,max_cdm:	01.0, $		;Min and Max range for CDM	average
			min_bbp:	0.0001,max_bbp:	01.0, $		;Min and Max range for BBP	average
			min_t865:	0.00, max_t865:	01.0, $		;Min and Max range for T865	average
			min_l412:	0.00,	max_l412:	05.0, $		;Min and Max range for L412	average
			min_l443:	0.00, max_l443:	05.0, $		;Min and Max range for L443	average
			min_l490:	0.00, max_l490:	05.0, $		;Min and Max range for L490	average
			min_l510:	0.00, max_l510:	05.0, $		;Min and Max range for L510	average
			min_l531:	0.00, max_l531:	05.0, $		;Min and Max range for L531	average
			min_l555:	0.00, max_l555:	05.0, $		;Min and Max range for L555	average
			min_l620:	0.00, max_l620:	02.5, $		;Min and Max range for L620	average
			min_l670:	0.00, max_l670:	01.0, $		;Min and Max range for L670	average
			min_l681:	0.00, max_l681:	01.0, $		;Min and Max range for L681	average
			min_l709:	0.00, max_l709:	01.0	}		;Min and Max range for L709	average
		end

		'SD': begin
			rconfig = { $
			level_format:	'(F5.2)', $
			min_chl1:	0.00, max_chl1:	10.0, $		;Min and Max range for CHL1 Standard Deviation
			min_chl2:	0.00, max_chl2:	10.0, $		;Min and Max range for CHL2	Standard Deviation
			min_kd490:0.00,	max_kd490:00.5, $		;Min and Max range for KD490Standard Deviation
			min_tsm:	0.00, max_tsm:	05.0, $		;Min and Max range for TSM	Standard Deviation
			min_cdm:	0.00,	max_cdm:	01.0, $		;Min and Max range for CDM	Standard Deviation
			min_bbp:	0.00,	max_bbp:	01.0, $		;Min and Max range for BBP	Standard Deviation
			min_t865:	0.00, max_t865:	01.0, $		;Min and Max range for T865	Standard Deviation
			min_l412:	0.00,	max_l412:	01.0, $		;Min and Max range for L412	Standard Deviation
			min_l443:	0.00, max_l443:	01.0, $		;Min and Max range for L443	Standard Deviation
			min_l490:	0.00, max_l490:	01.0, $		;Min and Max range for L490	Standard Deviation
			min_l510:	0.00, max_l510:	01.0, $		;Min and Max range for L510	Standard Deviation
			min_l531:	0.00, max_l531:	01.0, $		;Min and Max range for L531	Standard Deviation
			min_l555:	0.00, max_l555:	00.5, $		;Min and Max range for L555	Standard Deviation
			min_l620:	0.00, max_l620:	00.5, $		;Min and Max range for L620	Standard Deviation
			min_l670:	0.00, max_l670:	00.5, $		;Min and Max range for L670	Standard Deviation
			min_l681:	0.00, max_l681:	00.5, $		;Min and Max range for L681	Standard Deviation
			min_l709:	0.00, max_l709:	00.5	}		;Min and Max range for L709	Standard Deviation
		end

		'CNT': begin
			rconfig = { $
			level_format:	'(F5.2)', $
			min_chl1:	0.00, max_chl1:	35.0, $		;Min and Max range for CHL1 Count
			min_chl2:	0.00, max_chl2:	35.0, $		;Min and Max range for CHL2	Count
			min_kd490:0.00,	max_kd490:35.0, $		;Min and Max range for KD490Count
			min_tsm:	0.00, max_tsm:	35.0, $		;Min and Max range for TSM	Count
			min_cdm:	0.00,	max_cdm:	35.0, $		;Min and Max range for CDM	Count
			min_bbp:	0.00,	max_bbp:	35.0, $		;Min and Max range for BBP	Count
			min_t865:	0.00, max_t865:	35.0, $		;Min and Max range for T865	Count
			min_l412:	0.00,	max_l412:	35.0, $		;Min and Max range for L412	Count
			min_l443:	0.00, max_l443:	35.0, $		;Min and Max range for L443	Count
			min_l490:	0.00, max_l490:	35.0, $		;Min and Max range for L490	Count
			min_l510:	0.00, max_l510:	35.0, $		;Min and Max range for L510	Count
			min_l531:	0.00, max_l531:	35.0, $		;Min and Max range for L531	Count
			min_l555:	0.00, max_l555:	35.0, $		;Min and Max range for L555	Count
			min_l620:	0.00, max_l620:	35.0, $		;Min and Max range for L620	Count
			min_l670:	0.00, max_l670:	35.0, $		;Min and Max range for L670	Count
			min_l681:	0.00, max_l681:	35.0, $		;Min and Max range for L681	Count
			min_l709:	0.00, max_l709:	35.0	}		;Min and Max range for L709	Count
		end

		'WT': begin
			rconfig = { $
			level_format:	'(F5.2)', $
			min_chl1:	0.00, max_chl1:	1.0, $		;Min and Max range for CHL1 Weight
			min_chl2:	0.00, max_chl2:	1.0, $		;Min and Max range for CHL2	Weight
			min_kd490:0.00,	max_kd490:1.0, $		;Min and Max range for KD490Weight
			min_tsm:	0.00, max_tsm:	1.0, $		;Min and Max range for TSM	Weight
			min_cdm:	0.00,	max_cdm:	1.0, $		;Min and Max range for CDM	Weight
			min_bbp:	0.00,	max_bbp:	1.0, $		;Min and Max range for BBP	Weight
			min_t865:	0.00, max_t865:	1.0, $		;Min and Max range for T865	Weight
			min_l412:	0.00,	max_l412:	1.0, $		;Min and Max range for L412	Weight
			min_l443:	0.00, max_l443:	1.0, $		;Min and Max range for L443	Weight
			min_l490:	0.00, max_l490:	1.0, $		;Min and Max range for L490	Weight
			min_l510:	0.00, max_l510:	1.0, $		;Min and Max range for L510	Weight
			min_l531:	0.00, max_l531:	1.0, $		;Min and Max range for L531	Weight
			min_l555:	0.00, max_l555:	1.0, $		;Min and Max range for L555	Weight
			min_l620:	0.00, max_l620:	1.0, $		;Min and Max range for L620	Weight
			min_l670:	0.00, max_l670:	1.0, $		;Min and Max range for L670	Weight
			min_l681:	0.00, max_l681:	1.0, $		;Min and Max range for L681	Weight
			min_l709:	0.00, max_l709:	1.0	 }		;Min and Max range for L709	Weight
		end

		'ER': begin
			rconfig = { $
			level_format:	'(F5.2)', $
			min_chl1:	0.00, max_chl1:	10.0, $		;Min and Max range for CHL1 Error
			min_chl2:	0.00, max_chl2:	10.0, $		;Min and Max range for CHL2	Error
			min_kd490:0.00,	max_kd490:01.0, $		;Min and Max range for KD490Error
			min_tsm:	0.00, max_tsm:	10.0, $		;Min and Max range for TSM	Error
			min_cdm:	0.00,	max_cdm:	01.0, $		;Min and Max range for CDM	Error
			min_bbp:	0.00,	max_bbp:	01.0, $		;Min and Max range for BBP	Error
			min_t865:	0.00, max_t865:	01.0, $		;Min and Max range for T865	Error
			min_l412:	0.00,	max_l412:	05.0, $		;Min and Max range for L412	Error
			min_l443:	0.00, max_l443:	05.0, $		;Min and Max range for L443	Error
			min_l490:	0.00, max_l490:	05.0, $		;Min and Max range for L490	Error
			min_l510:	0.00, max_l510:	05.0, $		;Min and Max range for L510	Error
			min_l531:	0.00, max_l531:	05.0, $		;Min and Max range for L531	Error
			min_l555:	0.00, max_l555:	05.0, $		;Min and Max range for L555	Error
			min_l620:	0.00, max_l620:	02.5, $		;Min and Max range for L620	Error
			min_l670:	0.00, max_l670:	01.0, $		;Min and Max range for L670	Error
			min_l681:	0.00, max_l681:	01.0, $		;Min and Max range for L681	Error
			min_l709:	0.00, max_l709:	01.0	}		;Min and Max range for L709	Error
		end
	endcase

;######################################################################################################



;Parse error in command line
	if ( total([keyword_set(mn),keyword_set(sd),keyword_set(cnt),keyword_set(wt),keyword_set(er)]) gt 1 ) then begin
		print,'Only one keyword argument at a time is allowed [,/MN | ,/SD | ,/CNT | ,/WT | ,/ER ]'+string(10b)+'EXITing now'
		retall
	endif


;Parse error in command line
	if ( total([keyword_set(chl1),keyword_set(chl2),keyword_set(kd490),keyword_set(tsm),keyword_set(cdm),keyword_set(bbp),$
							keyword_set(l412),keyword_set(l443),keyword_set(l490),keyword_set(l510),keyword_set(l531),keyword_set(l555),$
							keyword_set(l620),keyword_set(l670),keyword_set(l709)]) eq 0 ) then begin
		pconfig.default_chl1=1b
	endif


	if ( n_params() lt 1 ) then begin
;++Select GlobColour DDS files
		filter=['*.nc']
  	SearchResult = dialog_pickfile(/Read,/Multiple_Files,FILTER=filter,Title='Select one or more GlobColour DDS File(s)',Get_Path=curr_dir)
  	if ( n_elements(SearchResult) eq 1 ) then if ( strcmp(SearchResult,'') ) then begin
  		print,'No Files Selected. EXITing now'
  		retall
  	endif
  	fileArray = strmid( SearchResult,strlen(curr_dir) )
  	DDSFiles = fileArray[sort(fileArray)]
  	CD,curr_dir
;--
	endif else DDSFiles = DDSFilename
	NumFiles = n_elements(DDSFiles)





;Set colour table
	device, decomposed=0
	!p.background='ffffff'x
	!p.color='000000'x
	loadct,pconfig.color_tab
	hit=''


	;Main loop if multiple files are selected via dialog_pickfile()
	for f=0,NumFiles-1 do begin

		;Read the file and find out how many and which layers are present
		read_netcdf, DDSFiles(f), dds_data, dds_attr, status
		dds_tags = tag_names(dds_data)    ;available variable names in the DDS file
		product_name = dds_attr[where(stregex(dds_attr,'product_name =') NE -1)]
		dds_type = strmid( ((strsplit(product_name,"= ",/extract))[1]), 0,3 )	;'L3b' or 'L3m'

		if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
			;Conctruct Lat-Lon grid
			row_info = dds_attr[where(stregex(dds_attr,'first_row =') NE -1)]
      first_row = LONG(strmid(row_info,stregex(row_info,'[0-9]')))
      lat_step_info = dds_attr[where(stregex(dds_attr,'lat_step =') NE -1)]
      lat_step = DOUBLE(strmid(lat_step_info,stregex(lat_step_info,'[0-9]')))
      idx = dds_data.row-first_row[0]
      ddsLat = dds_data.center_lat(idx)
      ddsLon = dds_data.center_lon(idx) + dds_data.col*dds_data.lon_step(idx)
    endif

		west_info = dds_attr[where(stregex(dds_attr,'westernmost_longitude =') NE -1)]
		east_info = dds_attr[where(stregex(dds_attr,'easternmost_longitude =') NE -1)]
		south_info = dds_attr[where(stregex(dds_attr,'southernmost_latitude =') NE -1)]
		north_info = dds_attr[where(stregex(dds_attr,'northernmost_latitude =') NE -1)]
		west = (double( strmid(west_info,stregex(west_info,'[0-9\-]')) ))[0] & east = (double( strmid(east_info,stregex(east_info,'[0-9\-]')) ))[0]
		south = (double( strmid(south_info,stregex(south_info,'[0-9\-]')) ))[0] & north = (double( strmid(north_info,stregex(north_info,'[0-9\-]')) ))[0]
		Lon0 = ( west + east ) / 2.
		Lat0 = ( south + north ) / 2.
		dLon = ( east - west)/(pconfig.nXgrids-1)
    dLat = ( north - south)/(pconfig.nYgrids-1)
    lons = [west + indgen(pconfig.nXgrids)*dLon, east] 	;[west, west+dLon, westsub_lon1+2*d_lon,sub_lon1+3*d_lon,sub_lon1+4*d_lon]
    lats = [south + indgen(pconfig.nYgrids)*dLat, north]	;[sub_lat1, sub_lat1+d_lat, sub_lat1+2*d_lat,sub_lat1+3*d_lat,sub_lat1+4*d_lat]

;print,pconfig.nXgrids,west,east,dLon,dLat;,lons,lats

	win_arr=0
;Window [1] :: Chl1
		if ( keyword_set(all_products) or keyword_set(chl1) or pconfig.default_chl1 ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'CHL1_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL1_VALUE > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254), 2) & found=1b
					win_title = 'CHL1_AVERAGE' & bar_title = 'GlobColour Chl1 mean [mg m!u-3!n]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'CHL1_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL1_STDEV > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254), 2) & found=1b
					win_title = 'CHL1_STDEV' & bar_title = 'GlobColour Chl1 Stdev [mg m!u-3!n]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'CHL1_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL1_COUNT > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254), 2) & found=1b
					win_title = 'CHL1_COUNT' & bar_title = 'GlobColour Chl1 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'CHL1_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL1_WEIGHT > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254), 2) & found=1b
					win_title = 'CHL1_WEIGHT' & bar_title = 'GlobColour Chl1 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'CHL1_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL1_ERROR > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254), 2) & found=1b
					win_title = 'CHL1_ERROR' & bar_title = 'GlobColour Chl1 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,1,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=0,YPOS=0, Title=win_title
					win_arr = [1]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_chl1,rconfig.max_chl1],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_CHL1 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'CHL1_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.CHL1_MEAN > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254) & found=1b
					win_title = 'CHL1_MEAN' & bar_title = 'GlobColour Chl1 mean [mg m!u-3!n]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'CHL1_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.CHL1_STDEV > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254) & found=1b
					win_title = 'CHL1_STDEV' & bar_title = 'GlobColour Chl1 Stdev [mg m!u-3!n]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'CHL1_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.CHL1_COUNT > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254) & found=1b
					win_title = 'CHL1_COUNT' & bar_title = 'GlobColour Chl1 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'CHL1_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.CHL1_WEIGHT > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254) & found=1b
					win_title = 'CHL1_WEIGHT' & bar_title = 'GlobColour Chl1 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'CHL1_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.CHL1_ERROR > 0., MAX=rconfig.max_chl1, MIN=rconfig.min_chl1, TOP=254) & found=1b
					win_title = 'CHL1_ERROR' & bar_title = 'GlobColour Chl1 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,1,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=0,YPOS=0, Title=win_title
					win_arr = [1]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_chl1,rconfig.max_chl1],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_CHL1 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(chl1) or rconfig.default_chl1 ) then begin



;Window [2] :: Chl2
		if ( keyword_set(all_products) or keyword_set(chl2) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'CHL2_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL2_VALUE > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254), 2) & found=1b
					win_title = 'CHL2_AVERAGE' & bar_title = 'GlobColour Chl2 mean [mg m!u-3!n]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'CHL2_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL2_STDEV > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254), 2) & found=1b
					win_title = 'CHL2_STDEV' & bar_title = 'GlobColour Chl2 Stdev [mg m!u-3!n]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'CHL2_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL2_COUNT > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254), 2) & found=1b
					win_title = 'CHL2_COUNT' & bar_title = 'GlobColour Chl2 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'CHL2_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL2_WEIGHT > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254), 2) & found=1b
					win_title = 'CHL2_WEIGHT' & bar_title = 'GlobColour Chl2 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'CHL2_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CHL2_ERROR > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254), 2) & found=1b
					win_title = 'CHL2_ERROR' & bar_title = 'GlobColour Chl2 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,2,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize,YPOS=0, Title=win_title
					win_arr = [win_arr,2]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_chl2,rconfig.max_chl2],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_CHL2 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'CHL2_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.CHL2_MEAN > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254) & found=1b
					win_title = 'CHL2_MEAN' & bar_title = 'GlobColour Chl2 mean [mg m!u-3!n]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'CHL2_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.CHL2_STDEV > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254) & found=1b
					win_title = 'CHL2_STDEV' & bar_title = 'GlobColour Chl2 Stdev [mg m!u-3!n]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'CHL2_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.CHL2_COUNT > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254) & found=1b
					win_title = 'CHL2_COUNT' & bar_title = 'GlobColour Chl2 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'CHL2_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.CHL2_WEIGHT > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254) & found=1b
					win_title = 'CHL2_WEIGHT' & bar_title = 'GlobColour Chl2 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'CHL2_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.CHL2_ERROR > 0., MAX=rconfig.max_chl2, MIN=rconfig.min_chl2, TOP=254) & found=1b
					win_title = 'CHL2_ERROR' & bar_title = 'GlobColour Chl2 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,2,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize,YPOS=0, Title=win_title
					win_arr = [win_arr,2]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_chl2,rconfig.max_chl2],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_CHL2 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(chl2) ) then begin



;Window [3] :: Kd490
		if ( keyword_set(all_products) or keyword_set(kd490) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'KD490_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.KD490_VALUE > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254), 2) & found=1b
					win_title = 'KD490_AVERAGE' & bar_title = 'GlobColour Kd490 mean [m!u-1!n]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'KD490_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.KD490_STDEV > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254), 2) & found=1b
					win_title = 'KD490_STDEV' & bar_title = 'GlobColour Kd490 Stdev [m!u-1!n]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'KD490_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.KD490_COUNT > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254), 2) & found=1b
					win_title = 'KD490_COUNT' & bar_title = 'GlobColour Kd490 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'KD490_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.KD490_WEIGHT > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254), 2) & found=1b
					win_title = 'KD490_WEIGHT' & bar_title = 'GlobColour Kd490 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'KD490_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.KD490_ERROR > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254), 2) & found=1b
					win_title = 'KD490_ERROR' & bar_title = 'GlobColour Kd490 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,3,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=50,YPOS=50, Title=win_title
					win_arr = [win_arr,3]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_kd490,rconfig.max_kd490],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_KD490 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'KD490_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.KD490_MEAN > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254) & found=1b
					win_title = 'KD490_MEAN' & bar_title = 'GlobColour Kd490 mean [m!u-1!n]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'KD490_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.KD490_STDEV > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254) & found=1b
					win_title = 'KD490_STDEV' & bar_title = 'GlobColour Kd490 Stdev [m!u-1!n]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'KD490_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.KD490_COUNT > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254) & found=1b
					win_title = 'KD490_COUNT' & bar_title = 'GlobColour Kd490 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'KD490_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.KD490_WEIGHT > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254) & found=1b
					win_title = 'KD490_WEIGHT' & bar_title = 'GlobColour Kd490 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'KD490_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.KD490_ERROR > 0., MAX=rconfig.max_kd490, MIN=rconfig.min_kd490, TOP=254) & found=1b
					win_title = 'KD490_ERROR' & bar_title = 'GlobColour Kd490 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,3,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=50,YPOS=50, Title=win_title
					win_arr = [win_arr,3]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_kd490,rconfig.max_kd490],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_KD490 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(kd490) ) then begin



;Window [4] :: TSM
		if ( keyword_set(all_products) or keyword_set(tsm) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'TSM_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.TSM_VALUE > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254), 2) & found=1b
					win_title = 'TSM_AVERAGE' & bar_title = 'GlobColour TSM mean [g m!u-3!n]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'TSM_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.TSM_STDEV > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254), 2) & found=1b
					win_title = 'TSM_STDEV' & bar_title = 'GlobColour TSM Stdev [g m!u-3!n]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'TSM_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.TSM_COUNT > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254), 2) & found=1b
					win_title = 'TSM_COUNT' & bar_title = 'GlobColour TSM Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'TSM_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.TSM_WEIGHT > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254), 2) & found=1b
					win_title = 'TSM_WEIGHT' & bar_title = 'GlobColour TSM Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'TSM_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.TSM_ERROR > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254), 2) & found=1b
					win_title = 'TSM_ERROR' & bar_title = 'GlobColour TSM Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,4,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+50,YPOS=50, Title=win_title
					win_arr = [win_arr,4]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_tsm,rconfig.max_tsm],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_TSM - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'TSM_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.TSM_MEAN > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254) & found=1b
					win_title = 'TSM_MEAN' & bar_title = 'GlobColour TSM mean [g m!u-3!n]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'TSM_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.TSM_STDEV > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254) & found=1b
					win_title = 'TSM_STDEV' & bar_title = 'GlobColour TSM Stdev [g m!u-3!n]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'TSM_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.TSM_COUNT > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254) & found=1b
					win_title = 'TSM_COUNT' & bar_title = 'GlobColour TSM Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'TSM_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.TSM_WEIGHT > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254) & found=1b
					win_title = 'TSM_WEIGHT' & bar_title = 'GlobColour TSM Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'TSM_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.TSM_ERROR > 0., MAX=rconfig.max_tsm, MIN=rconfig.min_tsm, TOP=254) & found=1b
					win_title = 'TSM_ERROR' & bar_title = 'GlobColour TSM Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,4,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+50,YPOS=50, Title=win_title
					win_arr = [win_arr,4]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_tsm,rconfig.max_tsm],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_TSM - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(tsm) ) then begin



;Window [5] :: CDM
		if ( keyword_set(all_products) or keyword_set(cdm) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'CDM_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CDM_VALUE > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254), 2) & found=1b
					win_title = 'CDM_AVERAGE' & bar_title = 'GlobColour CDM mean [m!u-1!n]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'CDM_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CDM_STDEV > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254), 2) & found=1b
					win_title = 'CDM_STDEV' & bar_title = 'GlobColour CDM Stdev [m!u-1!n]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'CDM_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CDM_COUNT > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254), 2) & found=1b
					win_title = 'CDM_COUNT' & bar_title = 'GlobColour CDM Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'CDM_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CDM_WEIGHT > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254), 2) & found=1b
					win_title = 'CDM_WEIGHT' & bar_title = 'GlobColour CDM Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'CDM_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.CDM_ERROR > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254), 2) & found=1b
					win_title = 'CDM_ERROR' & bar_title = 'GlobColour CDM Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,5,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=100,YPOS=100, Title=win_title
					win_arr = [win_arr,5]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_cdm,rconfig.max_cdm],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_CDM - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'CDM_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.CDM_MEAN > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254) & found=1b
					win_title = 'CDM_MEAN' & bar_title = 'GlobColour CDM mean [m!u-1!n]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'CDM_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.CDM_STDEV > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254) & found=1b
					win_title = 'CDM_STDEV' & bar_title = 'GlobColour CDM Stdev [m!u-1!n]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'CDM_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.CDM_COUNT > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254) & found=1b
					win_title = 'CDM_COUNT' & bar_title = 'GlobColour CDM Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'CDM_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.CDM_WEIGHT > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254) & found=1b
					win_title = 'CDM_WEIGHT' & bar_title = 'GlobColour CDM Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'CDM_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.CDM_ERROR > 0., MAX=rconfig.max_cdm, MIN=rconfig.min_cdm, TOP=254) & found=1b
					win_title = 'CDM_ERROR' & bar_title = 'GlobColour CDM Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,5,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=100,YPOS=100, Title=win_title
					win_arr = [win_arr,5]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_cdm,rconfig.max_cdm],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_CDM - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(cdm) ) then begin



;Window [6] :: BBP
		if ( keyword_set(all_products) or keyword_set(bbp) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'BBP_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.BBP_VALUE > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254), 2) & found=1b
					win_title = 'BBP_AVERAGE' & bar_title = 'GlobColour BBP mean [m!u-1!n]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'BBP_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.BBP_STDEV > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254), 2) & found=1b
					win_title = 'BBP_STDEV' & bar_title = 'GlobColour BBP Stdev [m!u-1!n]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'BBP_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.BBP_COUNT > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254), 2) & found=1b
					win_title = 'BBP_COUNT' & bar_title = 'GlobColour BBP Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'BBP_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.BBP_WEIGHT > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254), 2) & found=1b
					win_title = 'BBP_WEIGHT' & bar_title = 'GlobColour BBP Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'BBP_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.BBP_ERROR > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254), 2) & found=1b
					win_title = 'BBP_ERROR' & bar_title = 'GlobColour BBP Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,6,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+100,YPOS=100, Title=win_title
					win_arr = [win_arr,6]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_bbp,rconfig.max_bbp],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_BBP - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'BBP_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.BBP_MEAN > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254) & found=1b
					win_title = 'BBP_MEAN' & bar_title = 'GlobColour BBP mean [m!u-1!n]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'BBP_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.BBP_STDEV > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254) & found=1b
					win_title = 'BBP_STDEV' & bar_title = 'GlobColour BBP Stdev [m!u-1!n]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'BBP_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.BBP_COUNT > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254) & found=1b
					win_title = 'BBP_COUNT' & bar_title = 'GlobColour BBP Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'BBP_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.BBP_WEIGHT > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254) & found=1b
					win_title = 'BBP_WEIGHT' & bar_title = 'GlobColour BBP Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'BBP_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.BBP_ERROR > 0., MAX=rconfig.max_bbp, MIN=rconfig.min_bbp, TOP=254) & found=1b
					win_title = 'BBP_ERROR' & bar_title = 'GlobColour BBP Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,6,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+100,YPOS=100, Title=win_title
					win_arr = [win_arr,6]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_bbp,rconfig.max_bbp],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_BBP - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(bbp) ) then begin


;Window [7] :: T865
		if ( keyword_set(all_products) or keyword_set(t865) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'T865_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.T865_VALUE > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254), 2) & found=1b
					win_title = 'T865_AVERAGE' & bar_title = 'GlobColour T865 mean []'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'T865_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.T865_STDEV > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254), 2) & found=1b
					win_title = 'T865_STDEV' & bar_title = 'GlobColour T865 Stdev []'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'T865_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.T865_COUNT > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254), 2) & found=1b
					win_title = 'T865_COUNT' & bar_title = 'GlobColour T865 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'T865_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.T865_WEIGHT > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254), 2) & found=1b
					win_title = 'T865_WEIGHT' & bar_title = 'GlobColour T865 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'T865_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.T865_ERROR > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254), 2) & found=1b
					win_title = 'T865_ERROR' & bar_title = 'GlobColour T865 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,7,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=150,YPOS=150, Title=win_title
					win_arr = [win_arr,7]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_t865,rconfig.max_t865],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_T865 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'T865_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.T865_MEAN > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254) & found=1b
					win_title = 'T865_MEAN' & bar_title = 'GlobColour T865 mean []'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'T865_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.T865_STDEV > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254) & found=1b
					win_title = 'T865_STDEV' & bar_title = 'GlobColour T865 Stdev []'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'T865_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.T865_COUNT > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254) & found=1b
					win_title = 'T865_COUNT' & bar_title = 'GlobColour T865 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'T865_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.T865_WEIGHT > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254) & found=1b
					win_title = 'T865_WEIGHT' & bar_title = 'GlobColour T865 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'T865_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.T865_ERROR > 0., MAX=rconfig.max_t865, MIN=rconfig.min_t865, TOP=254) & found=1b
					win_title = 'T865_ERROR' & bar_title = 'GlobColour T865 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,7,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=150,YPOS=150, Title=win_title
					win_arr = [win_arr,7]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_t865,rconfig.max_t865],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_T865 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(t865) ) then begin



;Window [8] :: L412
		if ( keyword_set(all_products) or keyword_set(l412) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L412_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L412_VALUE > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254), 2) & found=1b
					win_title = 'L412_AVERAGE' & bar_title = 'GlobColour L412 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L412_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L412_STDEV > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254), 2) & found=1b
					win_title = 'L412_STDEV' & bar_title = 'GlobColour L412 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L412_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L412_COUNT > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254), 2) & found=1b
					win_title = 'L412_COUNT' & bar_title = 'GlobColour L412 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L412_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L412_WEIGHT > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254), 2) & found=1b
					win_title = 'L412_WEIGHT' & bar_title = 'GlobColour L412 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L412_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L412_ERROR > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254), 2) & found=1b
					win_title = 'L412_ERROR' & bar_title = 'GlobColour L412 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,8,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+150,YPOS=150, Title=win_title
					win_arr = [win_arr,8]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l412,rconfig.max_l412],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L412 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L412_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L412_MEAN > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254) & found=1b
					win_title = 'L412_MEAN' & bar_title = 'GlobColour L412 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L412_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L412_STDEV > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254) & found=1b
					win_title = 'L412_STDEV' & bar_title = 'GlobColour L412 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L412_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L412_COUNT > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254) & found=1b
					win_title = 'L412_COUNT' & bar_title = 'GlobColour L412 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L412_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L412_WEIGHT > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254) & found=1b
					win_title = 'L412_WEIGHT' & bar_title = 'GlobColour L412 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L412_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L412_ERROR > 0., MAX=rconfig.max_l412, MIN=rconfig.min_l412, TOP=254) & found=1b
					win_title = 'L412_ERROR' & bar_title = 'GlobColour L412 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,8,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+150,YPOS=150, Title=win_title
					win_arr = [win_arr,8]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l412,rconfig.max_l412],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L412 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l412) ) then begin



;Window [9] :: L443
		if ( keyword_set(all_products) or keyword_set(l443) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L443_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L443_VALUE > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254), 2) & found=1b
					win_title = 'L443_AVERAGE' & bar_title = 'GlobColour L443 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L443_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L443_STDEV > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254), 2) & found=1b
					win_title = 'L443_STDEV' & bar_title = 'GlobColour L443 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L443_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L443_COUNT > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254), 2) & found=1b
					win_title = 'L443_COUNT' & bar_title = 'GlobColour L443 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L443_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L443_WEIGHT > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254), 2) & found=1b
					win_title = 'L443_WEIGHT' & bar_title = 'GlobColour L443 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L443_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L443_ERROR > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254), 2) & found=1b
					win_title = 'L443_ERROR' & bar_title = 'GlobColour L443 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,9,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=200,YPOS=200, Title=win_title
					win_arr = [win_arr,9]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l443,rconfig.max_l443],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L443 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L443_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L443_MEAN > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254) & found=1b
					win_title = 'L443_MEAN' & bar_title = 'GlobColour L443 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L443_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L443_STDEV > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254) & found=1b
					win_title = 'L443_STDEV' & bar_title = 'GlobColour L443 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L443_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L443_COUNT > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254) & found=1b
					win_title = 'L443_COUNT' & bar_title = 'GlobColour L443 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L443_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L443_WEIGHT > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254) & found=1b
					win_title = 'L443_WEIGHT' & bar_title = 'GlobColour L443 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L443_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L443_ERROR > 0., MAX=rconfig.max_l443, MIN=rconfig.min_l443, TOP=254) & found=1b
					win_title = 'L443_ERROR' & bar_title = 'GlobColour L443 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,9,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=200,YPOS=200, Title=win_title
					win_arr = [win_arr,9]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l443,rconfig.max_l443],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L443 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l443) ) then begin



;Window [10] :: L490
		if ( keyword_set(all_products) or keyword_set(l490) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L490_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L490_VALUE > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254), 2) & found=1b
					win_title = 'L490_AVERAGE' & bar_title = 'GlobColour L490 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L490_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L490_STDEV > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254), 2) & found=1b
					win_title = 'L490_STDEV' & bar_title = 'GlobColour L490 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L490_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L490_COUNT > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254), 2) & found=1b
					win_title = 'L490_COUNT' & bar_title = 'GlobColour L490 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L490_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L490_WEIGHT > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254), 2) & found=1b
					win_title = 'L490_WEIGHT' & bar_title = 'GlobColour L490 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L490_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L490_ERROR > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254), 2) & found=1b
					win_title = 'L490_ERROR' & bar_title = 'GlobColour L490 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,10,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+200,YPOS=200, Title=win_title
					win_arr = [win_arr,10]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l490,rconfig.max_l490],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L490 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L490_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L490_MEAN > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254) & found=1b
					win_title = 'L490_MEAN' & bar_title = 'GlobColour L490 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L490_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L490_STDEV > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254) & found=1b
					win_title = 'L490_STDEV' & bar_title = 'GlobColour L490 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L490_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L490_COUNT > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254) & found=1b
					win_title = 'L490_COUNT' & bar_title = 'GlobColour L490 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L490_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L490_WEIGHT > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254) & found=1b
					win_title = 'L490_WEIGHT' & bar_title = 'GlobColour L490 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L490_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L490_ERROR > 0., MAX=rconfig.max_l490, MIN=rconfig.min_l490, TOP=254) & found=1b
					win_title = 'L490_ERROR' & bar_title = 'GlobColour L490 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,10,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+200,YPOS=200, Title=win_title
					win_arr = [win_arr,10]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l490,rconfig.max_l490],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L490 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l490) ) then begin



;Window [11] :: L510
		if ( keyword_set(all_products) or keyword_set(l510) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L510_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L510_VALUE > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254), 2) & found=1b
					win_title = 'L510_AVERAGE' & bar_title = 'GlobColour L510 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L510_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L510_STDEV > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254), 2) & found=1b
					win_title = 'L510_STDEV' & bar_title = 'GlobColour L510 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L510_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L510_COUNT > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254), 2) & found=1b
					win_title = 'L510_COUNT' & bar_title = 'GlobColour L510 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L510_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L510_WEIGHT > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254), 2) & found=1b
					win_title = 'L510_WEIGHT' & bar_title = 'GlobColour L510 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L510_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L510_ERROR > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254), 2) & found=1b
					win_title = 'L510_ERROR' & bar_title = 'GlobColour L510 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,11,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=250,YPOS=250, Title=win_title
					win_arr = [win_arr,11]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l510,rconfig.max_l510],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L510 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L510_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L510_MEAN > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254) & found=1b
					win_title = 'L510_MEAN' & bar_title = 'GlobColour L510 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L510_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L510_STDEV > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254) & found=1b
					win_title = 'L510_STDEV' & bar_title = 'GlobColour L510 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L510_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L510_COUNT > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254) & found=1b
					win_title = 'L510_COUNT' & bar_title = 'GlobColour L510 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L510_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L510_WEIGHT > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254) & found=1b
					win_title = 'L510_WEIGHT' & bar_title = 'GlobColour L510 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L510_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L510_ERROR > 0., MAX=rconfig.max_l510, MIN=rconfig.min_l510, TOP=254) & found=1b
					win_title = 'L510_ERROR' & bar_title = 'GlobColour L510 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,11,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=250,YPOS=250, Title=win_title
					win_arr = [win_arr,11]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l510,rconfig.max_l510],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L510 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l510) ) then begin



;Window [12] :: L531
		if ( keyword_set(all_products) or keyword_set(l531) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L531_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L531_VALUE > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254), 2) & found=1b
					win_title = 'L531_AVERAGE' & bar_title = 'GlobColour L531 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L531_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L531_STDEV > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254), 2) & found=1b
					win_title = 'L531_STDEV' & bar_title = 'GlobColour L531 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L531_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L531_COUNT > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254), 2) & found=1b
					win_title = 'L531_COUNT' & bar_title = 'GlobColour L531 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L531_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L531_WEIGHT > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254), 2) & found=1b
					win_title = 'L531_WEIGHT' & bar_title = 'GlobColour L531 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L531_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L531_ERROR > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254), 2) & found=1b
					win_title = 'L531_ERROR' & bar_title = 'GlobColour L531 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,12,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+250,YPOS=250, Title=win_title
					win_arr = [win_arr,12]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l531,rconfig.max_l531],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L531 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L531_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L531_MEAN > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254) & found=1b
					win_title = 'L531_MEAN' & bar_title = 'GlobColour L531 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L531_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L531_STDEV > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254) & found=1b
					win_title = 'L531_STDEV' & bar_title = 'GlobColour L531 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L531_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L531_COUNT > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254) & found=1b
					win_title = 'L531_COUNT' & bar_title = 'GlobColour L531 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L531_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L531_WEIGHT > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254) & found=1b
					win_title = 'L531_WEIGHT' & bar_title = 'GlobColour L531 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L531_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L531_ERROR > 0., MAX=rconfig.max_l531, MIN=rconfig.min_l531, TOP=254) & found=1b
					win_title = 'L531_ERROR' & bar_title = 'GlobColour L531 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,12,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+250,YPOS=250, Title=win_title
					win_arr = [win_arr,12]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l531,rconfig.max_l531],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L531 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l531) ) then begin



;Window [13] :: L555
		if ( keyword_set(all_products) or keyword_set(l555) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L555_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L555_VALUE > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254), 2) & found=1b
					win_title = 'L555_AVERAGE' & bar_title = 'GlobColour L555 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L555_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L555_STDEV > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254), 2) & found=1b
					win_title = 'L555_STDEV' & bar_title = 'GlobColour L555 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L555_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L555_COUNT > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254), 2) & found=1b
					win_title = 'L555_COUNT' & bar_title = 'GlobColour L555 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L555_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L555_WEIGHT > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254), 2) & found=1b
					win_title = 'L555_WEIGHT' & bar_title = 'GlobColour L555 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L555_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L555_ERROR > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254), 2) & found=1b
					win_title = 'L555_ERROR' & bar_title = 'GlobColour L555 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,13,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=300,YPOS=300, Title=win_title
					win_arr = [win_arr,13]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l555,rconfig.max_l555],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L555 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L555_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L555_MEAN > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254) & found=1b
					win_title = 'L555_MEAN' & bar_title = 'GlobColour L555 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L555_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L555_STDEV > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254) & found=1b
					win_title = 'L555_STDEV' & bar_title = 'GlobColour L555 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L555_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L555_COUNT > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254) & found=1b
					win_title = 'L555_COUNT' & bar_title = 'GlobColour L555 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L555_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L555_WEIGHT > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254) & found=1b
					win_title = 'L555_WEIGHT' & bar_title = 'GlobColour L555 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L555_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L555_ERROR > 0., MAX=rconfig.max_l555, MIN=rconfig.min_l555, TOP=254) & found=1b
					win_title = 'L555_ERROR' & bar_title = 'GlobColour L555 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,13,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=300,YPOS=300, Title=win_title
					win_arr = [win_arr,13]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l555,rconfig.max_l555],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L555 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l555) ) then begin



;Window [14] :: L620
		if ( keyword_set(all_products) or keyword_set(l620) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L620_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L620_VALUE > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254), 2) & found=1b
					win_title = 'L620_AVERAGE' & bar_title = 'GlobColour L620 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L620_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L620_STDEV > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254), 2) & found=1b
					win_title = 'L620_STDEV' & bar_title = 'GlobColour L620 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L620_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L620_COUNT > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254), 2) & found=1b
					win_title = 'L620_COUNT' & bar_title = 'GlobColour L620 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L620_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L620_WEIGHT > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254), 2) & found=1b
					win_title = 'L620_WEIGHT' & bar_title = 'GlobColour L620 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L620_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L620_ERROR > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254), 2) & found=1b
					win_title = 'L620_ERROR' & bar_title = 'GlobColour L620 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,14,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+300,YPOS=300, Title=win_title
					win_arr = [win_arr,14]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l620,rconfig.max_l620],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L620 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L620_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L620_MEAN > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254) & found=1b
					win_title = 'L620_MEAN' & bar_title = 'GlobColour L620 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L620_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L620_STDEV > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254) & found=1b
					win_title = 'L620_STDEV' & bar_title = 'GlobColour L620 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L620_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L620_COUNT > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254) & found=1b
					win_title = 'L620_COUNT' & bar_title = 'GlobColour L620 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L620_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L620_WEIGHT > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254) & found=1b
					win_title = 'L620_WEIGHT' & bar_title = 'GlobColour L620 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L620_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L620_ERROR > 0., MAX=rconfig.max_l620, MIN=rconfig.min_l620, TOP=254) & found=1b
					win_title = 'L620_ERROR' & bar_title = 'GlobColour L620 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,14,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+300,YPOS=300, Title=win_title
					win_arr = [win_arr,14]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l620,rconfig.max_l620],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L620 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l620) ) then begin



;Window [15] :: L670
		if ( keyword_set(all_products) or keyword_set(l670) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L670_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L670_VALUE > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254), 2) & found=1b
					win_title = 'L670_AVERAGE' & bar_title = 'GlobColour L670 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L670_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L670_STDEV > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254), 2) & found=1b
					win_title = 'L670_STDEV' & bar_title = 'GlobColour L670 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L670_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L670_COUNT > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254), 2) & found=1b
					win_title = 'L670_COUNT' & bar_title = 'GlobColour L670 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L670_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L670_WEIGHT > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254), 2) & found=1b
					win_title = 'L670_WEIGHT' & bar_title = 'GlobColour L670 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L670_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L670_ERROR > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254), 2) & found=1b
					win_title = 'L670_ERROR' & bar_title = 'GlobColour L670 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,15,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=350,YPOS=350, Title=win_title
					win_arr = [win_arr,15]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l670,rconfig.max_l670],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L670 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L670_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L670_MEAN > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254) & found=1b
					win_title = 'L670_MEAN' & bar_title = 'GlobColour L670 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L670_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L670_STDEV > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254) & found=1b
					win_title = 'L670_STDEV' & bar_title = 'GlobColour L670 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L670_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L670_COUNT > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254) & found=1b
					win_title = 'L670_COUNT' & bar_title = 'GlobColour L670 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L670_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L670_WEIGHT > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254) & found=1b
					win_title = 'L670_WEIGHT' & bar_title = 'GlobColour L670 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L670_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L670_ERROR > 0., MAX=rconfig.max_l670, MIN=rconfig.min_l670, TOP=254) & found=1b
					win_title = 'L670_ERROR' & bar_title = 'GlobColour L670 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,15,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=350,YPOS=350, Title=win_title
					win_arr = [win_arr,15]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l670,rconfig.max_l670],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L670 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l670) ) then begin



;Window [16] :: L681
		if ( keyword_set(all_products) or keyword_set(l681) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L681_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L681_VALUE > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254), 2) & found=1b
					win_title = 'L681_AVERAGE' & bar_title = 'GlobColour L681 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L681_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L681_STDEV > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254), 2) & found=1b
					win_title = 'L681_STDEV' & bar_title = 'GlobColour L681 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L681_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L681_COUNT > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254), 2) & found=1b
					win_title = 'L681_COUNT' & bar_title = 'GlobColour L681 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L681_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L681_WEIGHT > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254), 2) & found=1b
					win_title = 'L681_WEIGHT' & bar_title = 'GlobColour L681 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L681_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L681_ERROR > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254), 2) & found=1b
					win_title = 'L681_ERROR' & bar_title = 'GlobColour L681 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,16,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+350,YPOS=350, Title=win_title
					win_arr = [win_arr,16]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l681,rconfig.max_l681],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L681 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L681_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L681_MEAN > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254) & found=1b
					win_title = 'L681_MEAN' & bar_title = 'GlobColour L681 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L681_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L681_STDEV > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254) & found=1b
					win_title = 'L681_STDEV' & bar_title = 'GlobColour L681 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L681_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L681_COUNT > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254) & found=1b
					win_title = 'L681_COUNT' & bar_title = 'GlobColour L681 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L681_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L681_WEIGHT > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254) & found=1b
					win_title = 'L681_WEIGHT' & bar_title = 'GlobColour L681 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L681_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L681_ERROR > 0., MAX=rconfig.max_l681, MIN=rconfig.min_l681, TOP=254) & found=1b
					win_title = 'L681_ERROR' & bar_title = 'GlobColour L681 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,16,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=pconfig.wXsize+350,YPOS=350, Title=win_title
					win_arr = [win_arr,16]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l681,rconfig.max_l681],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L681 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l681) ) then begin



;Window [17] :: L709
		if ( keyword_set(all_products) or keyword_set(l709) ) then begin
		found=0b
			if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			;Bytscl data ignore -ve data
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L709_VALUE')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L709_VALUE > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254), 2) & found=1b
					win_title = 'L709_AVERAGE' & bar_title = 'GlobColour L709 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD')  and total(strmatch(dds_tags,'L709_STDEV')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L709_STDEV > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254), 2) & found=1b
					win_title = 'L709_STDEV' & bar_title = 'GlobColour L709 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT')  and total(strmatch(dds_tags,'L709_COUNT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L709_COUNT > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254), 2) & found=1b
					win_title = 'L709_COUNT' & bar_title = 'GlobColour L709 Count'
				endif else if ( (var_type eq 'WT')  and total(strmatch(dds_tags,'L709_WEIGHT')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L709_WEIGHT > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254), 2) & found=1b
					win_title = 'L709_WEIGHT' & bar_title = 'GlobColour L709 Weight'
				endif else if ( (var_type eq 'ER')  and total(strmatch(dds_tags,'L709_ERROR')) eq 1.) then begin
					data = reverse( bytscl(dds_data.L709_ERROR > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254), 2) & found=1b
					win_title = 'L709_ERROR' & bar_title = 'GlobColour L709 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,17,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=400,YPOS=400, Title=win_title
					win_arr = [win_arr,17]

					;Set Map Reference and wrap data to map
					map_set, Lat0, Lon0, 0, LIMIT=[south-0.02, west-0.02, north+0.02, east+0.02], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER
					m_data = map_image( data, Startx, Starty, Xsize, Ysize,  COMPRESS=1, LATMIN=south, LONMIN=west, LATMAX=north, LONMAX=east)

					tv,m_data, startx, starty

					map_continents, /COAST, COLOR=100, /HIRES
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format,TITLE=bar_title, RANGE=[rconfig.min_l709,rconfig.max_l709],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3m_L709 - No match.';if (found) then begin

			endif $;if ( strcmp(dds_type,'L3m',/fold_case) ) then begin
			else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
				if ( (var_type eq 'MN') and total(strmatch(dds_tags,'L709_MEAN')) eq 1.) then begin
					data = bytscl(dds_data.L709_MEAN > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254) & found=1b
					win_title = 'L709_MEAN' & bar_title = 'GlobColour L709 mean [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'SD') and total(strmatch(dds_tags,'L709_STDEV')) eq 1.) then begin
					data = bytscl(dds_data.L709_STDEV > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254) & found=1b
					win_title = 'L709_STDEV' & bar_title = 'GlobColour L709 Stdev [mW/cm!u2!n/!7l!5m/sr]'
				endif else if ( (var_type eq 'CNT') and total(strmatch(dds_tags,'L709_COUNT')) eq 1.) then begin
					data = bytscl(dds_data.L709_COUNT > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254) & found=1b
					win_title = 'L709_COUNT' & bar_title = 'GlobColour L709 Count'
				endif else if ( (var_type eq 'WT') and total(strmatch(dds_tags,'L709_WEIGHT')) eq 1.) then begin
					data = bytscl(dds_data.L709_WEIGHT > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254) & found=1b
					win_title = 'L709_WEIGHT' & bar_title = 'GlobColour L709 Weight'
				endif else if ( (var_type eq 'ER') and total(strmatch(dds_tags,'L709_ERROR')) eq 1.) then begin
					data = bytscl(dds_data.L709_ERROR > 0., MAX=rconfig.max_l709, MIN=rconfig.min_l709, TOP=254) & found=1b
					win_title = 'L709_ERROR' & bar_title = 'GlobColour L709 Error [%]'
				endif

				;If data is a valid array
				if (found) then begin
					window,17,XSIZE=pconfig.wXsize,YSIZE=pconfig.wYsize,XPOS=400,YPOS=400, Title=win_title
					win_arr = [win_arr,17]

  				;Set Map Reference and wrap data to map
 					map_set, Lat0, Lon0, 0, LIMIT=[south-0.05, west-0.05, north+.05, east+.05], /ISOTROPIC, /CYLINDRICAL, XMARGIN=3, YMARGIN=5, /CLIP, /NOBORDER

					plots, ddsLon, ddsLat, PSYM=SYMCAT(pconfig.symid), SYMSIZE=pconfig.symsize, COLOR=data

					map_continents, /COAST, COLOR=100, /HIRES;, FILL_CONTINENTS=2
					map_grid, /BOX_AXES,CLIP_TEXT=0,LONS=lons,LATS=lats;,/NO_GRID
					colorbar, POSITION=[0.10, 0.00, 0.90, 0.02], FORMAT=rconfig.level_format, TITLE=bar_title,RANGE=[rconfig.min_l709,rconfig.max_l709],CHARSIZE=0.9,/top
					xyouts,/normal,.5,.98,file_basename(DDSFiles(f)),alignment=0.5
				endif else print,'Warning! L3b_L709 - No match.';if (found) then begin
			endif;endif else if ( strcmp(dds_type,'L3b',/fold_case) ) then begin
		endif ;if (keyword_set(all_products) or keyword_set(l709) ) then begin



		;Press enter to view next file
    if (NumFiles GT 1) then begin
        if (f LT NumFiles-1) then read,string(10b)+"Press Enter to view the Next Image ",hit $
        else print,string(10b)+"FINISHED."
    endif


	endfor;for f=0,NumFiles-1 do begin


	;Prompt to close all opened windows
	;close_all = dialog_message('Close [ALL] open windows?',/question, title='Close Window')
	;if ( strcmp(close_all,'Yes') ) then for i=0,n_elements(win_arr)-1 do begin
	;	if (!d.window gt 0) then wdelete,!d.window
	;endfor



END