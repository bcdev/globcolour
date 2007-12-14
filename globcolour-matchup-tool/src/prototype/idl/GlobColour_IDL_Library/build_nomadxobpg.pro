PRO BUILD_NOMADxOBPG

;Reads already created 31-column NOMAD and OBPG files and
;Creates a New NOMAD file for GlobColour, from which OBPG data are removed (to avoid duplicate use)

	close,/all

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;exclude criteria
	crit={$
		maxTimeDiff:	1.0,	$
		maxLatDiff:		0.01,	$
		maxLonDiff:		0.01}
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	nomad_file=	dialog_pickfile(/read,filter='*.csv',title='Please Select GlobColour NOMAD csv File',get_path=cwd)
	cd,cwd
	obpg_file=	dialog_pickfile(/read,filter='*.csv',title='Please Select GlobColour OBPG csv File')
	nomad_data=	read_gcinsitu31(nomad_file)
	obpg_data =	read_gcinsitu31(obpg_file)


;Date time and Location arrays
	nomad_date =	string(nomad_data.YEAR,format='(I4)') + string(nomad_data.MONTH,format='(I2)') + string(nomad_data.DATE,format='(I2)')
	nomad_time =	nomad_data.HOUR + (nomad_data.MINUTE/60.)

	obpg_date =	string(obpg_data.YEAR,format='(I4)') + string(obpg_data.MONTH,format='(I2)') + string(obpg_data.DATE,format='(I2)')
	obpg_time =	obpg_data.HOUR + (obpg_data.MINUTE/60.)


	nomad_recs=	n_elements(nomad_data.ID)

;Read NOMAD header
	openr,1,nomad_file
		nomad_head= strarr(10)
		readf,1,nomad_head
	close,1

	openw,2,'NOMADxOBPG.csv'
		printf,2,nomad_head
		exclude=0

		for i=0,nomad_recs-1 do begin

			match= where( strmatch(strtrim(obpg_data.CAMPAIGN,2), strtrim(nomad_data.CAMPAIGN(i),2)) and strmatch(obpg_date, nomad_date(i)) $
									   and (obpg_data.LATITUDE LE nomad_data.LATITUDE(i)+crit.maxLatDiff) and (obpg_data.LATITUDE GE nomad_data.LATITUDE(i)-crit.maxLatDiff) $
										 and (obpg_time LE nomad_time+crit.maxTimeDiff)	 and (obpg_time GE nomad_time-crit.maxTimeDiff)	, cnt )
			if( cnt GT 0) then begin
				print,''
				print,'NOMAD: ',nomad_data.CAMPAIGN(i),nomad_data.LATITUDE(i),nomad_data.LONGITUDE(i),format='(A10,A,2(F))'
				print,'OBPG : ',obpg_data.CAMPAIGN(match),obpg_data.LATITUDE(match),obpg_data.LONGITUDE(match),format='(A10,A,2(F))'
				exclude++
				;for k=0,n_tags(nomad_data)-1 do print,(nomad_data.(k))[i],format='(A,",",I,",",A,5(I,","),3(F,","),17(D,","),I,",",A,",",A)'
			endif else begin
				printf,2,nomad_data.ID[i],nomad_data.DDS_ID[i],nomad_data.DDS_NAME[i],nomad_data.YEAR[i],nomad_data.MONTH[i],nomad_data.DATE[i],nomad_data.HOUR[i],nomad_data.MINUTE[i],$
								 nomad_data.LONGITUDE[i],nomad_data.LATITUDE[i],nomad_data.DEPTH[i],nomad_data.CHLA_HPLC[i],nomad_data.CHLA_FLUOR[i],nomad_data.KD490[i],nomad_data.TSM[i],$
								 nomad_data.ACDM443[i],nomad_data.BBP443[i],nomad_data.T865[i],nomad_data.EXLWN412[i],nomad_data.EXLWN443[i],nomad_data.EXLWN490[i],nomad_data.EXLWN510[i],nomad_data.EXLWN531[i],$
								 nomad_data.EXLWN555[i],nomad_data.EXLWN620[i],nomad_data.EXLWN670[i],nomad_data.EXLWN681[i],nomad_data.EXLWN709[i],nomad_data.FLAG[i],nomad_data.CAMPAIGN[i],nomad_data.COMMENTS[i],$
								 format='(A,",",I,",",A,",",5(I,","),3(F,","),17(D,","),I,",",A,",",A)'
			endelse


		endfor
	close,2
	print,exclude,'Records excluded'
	print,'DONE!'

END