PRO combine_list1, MERGED=merged

;Combines all GlobColour "*matchup_list1.csv" files as per satellite (or method) per variable
;/MERGED	use this keyword to combine merged
;Last change: 08 Jul 2007 (YP)


	close,/all

;Configure
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	if( keyword_set(merged) ) then	Sensor=['AV','AVW','GSM'] else 	Sensor=['SeaWiFS','MODIS','MERIS']
	Param=['Chl1','Chl2','K490','CDM','TSM','T865','L412','L443','L490','L510','L531','L555','L620','L670','L681','L709']
	FileFilter='*_matchup_list1.csv'
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	filDir=DIALOG_PICKFILE(/DIRECTORY,/Read,Title='Select GlobColour Matchup List1 File Path',get_path=cwd)
	cd,cwd
  SearchResult=FILE_SEARCH(filDir, FileFilter, count=nFiles)
  if(nFiles GT 0) then list1Files=SearchResult(sort(SearchResult)) else RETALL

	if(nFiles GT 0) then begin

	for p=0,n_elements(Param)-1 do begin
		for s=0,n_elements(Sensor)-1 do begin
			wh=(where(STREGEX(list1Files,Sensor(s)) NE -1 and STREGEX(list1Files,Param(p)) NE -1, nF))

   		if(nF GT 0) then begin
   			print,Sensor(s)
   			files=list1Files(wh)

   			openr,lun,files(0),/get_lun
				header=strarr(1)
				readf,lun,header
				free_lun,lun
				print,header

				openw,lun,Sensor(s)+'_'+Param(p)+'_combo.csv',/get_lun
				printf,lun,header


   			for f=0,nF-1 do begin
					data=read_ascii(files(f),template=get_gclist1_template())

					for l=0,file_lines(files(f))-2 do begin
						printf,lun,data.(0)[l],data.(1)[l],data.(2)[l],data.(3)[l],data.(4)[l],data.(5)[l],data.(6)[l],data.(7)[l],data.(8)[l],data.(9)[l],data.(10)[l],data.(11)[l],$
									format='(3(A,","),8(F,","),A)'
					endfor

				endfor
				free_lun,lun
			endif

		endfor
	endfor

	endif
	print,string(10b)+'FINISH.';stop
END