PRO substat_GlobColour

;+
;Name:      substat_GlobColour
;
;Purpose:   Extract data for a sub-region from many L3b Global GlobColour (4km) data and create a time-series file
;
;Inputs:   	None (pop up prompt on run)
;
;Output:		Extracted subset in 3-column (lon, lat, value) CSV file (optional) + an area average time-series file
;
;Keywords:	None
;
;Syntax:		substat_GlobColour
;
;
; MODIFICATION HISTORY:
;   09/11/2007    Yaswant Pradhan Original release of code, Version 1.00
;
; $Log: substat_GlobColour.pro,v $
; $Id: substat_GlobColour.pro,v 1.0 2007/11/09 14:50:00 yaswant Exp $
;-

close,/all

;+Parameters Change Subset Limits here
LonLimit = [29.0, 34.5];[75.0, 100.0];[50,100];[-6.0, 42.0];[24.,44.];
LatLimit = [30.8, 32.0];[5.0, 25.0];[-25,25];[30.0, 47.0];[10.,36.];
product_name = 'CHL1'
product_filter = 'L3b_*_GSM*_MO*.nc*'
;-



	filDir=DIALOG_PICKFILE(/DIRECTORY,/Read,Title='Select GlobCOLOUR L3b Files (4KM ISIN) Path', get_path=cwd)
	if ( strcmp(filDir,'') ) then stop,'Nothing Selected!'
	cd,cwd
  SearchResult=FILE_SEARCH(filDir, product_filter, count=nFiles)
  if(nFiles GT 0) then Files=SearchResult(sort(SearchResult)) else stop, 'No Match'

	openw,10,product_name+'TimeSeries.csv'
	printf,10,'Time,Mean,Median,Stdev,N,Filename'

	for i=0,nFiles-1 do begin
		compress = 0b
		file_length = strlen(Files(i))
		pos = strpos(Files(i),'.',/reverse_search)
		suffix = strmid(Files(i), pos, file_length)

		if( strcmp(suffix,'.gz') ) then begin
			compress = 1b
			spawn, 'gzip -d -k '+Files(i)	;decompress gzip file keeping the original compressed file
			file = strmid( Files(i),0,pos )
		endif else file = Files(i)


		subset_GCnetcdf, file, LON_LIMIT=LonLimit, LAT_LIMIT=LatLimit, sub_data, /exclude_points, /WRITE_CSV, /WRITE_PNG, /ZEU, /ZSD, /ZHL
;stop
		if(compress) then file_delete, file ;delete the decompressed file

		split_filename = strsplit(file_basename(Files(i)),'_',/extract)
		time = split_filename[1]
		if(total(sub_data,/NaN) GT 0.0) then begin
			p = where(finite(sub_data))
			printf,10,time,mean(sub_data,/NaN),median(sub_data(p)),stddev(sub_data(p)),n_elements(p),file_basename(file), format='(A,",",3(F7.4,","),I7.7,",",A)'
		endif
		;stop
	endfor
	close,10

print,'Finish.'
END