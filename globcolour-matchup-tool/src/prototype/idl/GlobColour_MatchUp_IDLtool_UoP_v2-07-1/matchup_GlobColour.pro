PRO matchup_GlobColour, L3M_DDS=l3m_dds, L3B_DDS=l3b_dds, $
    SeaWiFS=seawifs, MODIS=modis, MERIS=meris, $
    TIME_SERIES=time_series, $
    CV=cvar
    UPDATE=update
;+
;NAME:
;   matchup_GlobCOLOUR
;PURPOSE:
;   GlobCOLOUR DDS 1km and Global 4km data match-up with in-situ data.
;SYNTAX:
;   matchup_GlobCOLOUR  [ [,/l3m_dds | ,/l3b_dds] [,/seawifs] [,/modis] [,/meris] [,/time_series] [CV=value] [,/update]]
;
;KEYWORDS:
;   l3m_dds -> run match-up for 1km MAPPED (PC grid) DDS (contains all available layers in a single file)
;   l3b_dds -> run match-up for 4km BINNED (ISIN grid) DDS (contains all available layers in a single file)
;   seawifs -> run match-up for SeaWiFS only
;   modis -> run match-up for MODIS only
;   meris -> run match-up for MERIS only
;   time_series -> when the in-situ data were taken from a time-series location, pick only closest in time record
;   CV -> coefficient of variation
;   update -> update the matchup table (not implemented at the moment)

;Author: Yaswant Pradhan
;Last modification: Mar 07
;-

close,/all

;--------------------
;++Global parameters
if(~KEYWORD_SET(cvar)) then cvar = 0.2   ;Coefficient of variation used in the calculation of FILTERED_AVERAGE from l3m files

;--Global parameters
;--------------------



;--------------------
;++Machine Dependency
lilEndian=(BYTE(1,0,1))[0]
if(lilEndian) then separator='\' else separator='/'
;--Machine Dependency
;--------------------



;---------------------------
;++ READ IN-SITU DATA + INFO
;Read the 31-Column GlobCOLOUR (GC) insitu file.
;GlobCOLOUR in-situ Field Names
 ;01->ID         ;02->DDS_ID    ;03->DDS_Name   ;04->Year
 ;05->Month      ;06->Date      ;07->Hour       ;08->Minute
 ;09->Longitude  ;10->Latitude  ;11->Depth      ;12->Chla_hplc
 ;13->Chla_fluor ;14->Kd490     ;15->TSM        ;16->acdm443
 ;17->bbp443     ;18->T865      ;19->exLwn412   ;20->exLwn443
 ;21->exLwn490   ;22->exLwn510  ;23->exLwn531   ;24->exLwn555
 ;25->exLwn620   ;26->exLwn670  ;27->exLwn681   ;28->exLwn709
 ;29->Flag       ;30->Campaign  ;31->Comments

    insitu_data=read_gcINSITU31(/verb,GET_FILENAME=inFile, DB_NAME=inDBname)
    insitu_tags=TAG_NAMES(insitu_data)  ;Fields availabe in the GC insitu file.
    insitu_recs=n_elements(insitu_data.ID)
    ;Combine in-situ HPLC and Fluorometer Chl and use a flag to identify 1=HPLC, 0=Fluorometer or missing
    insituChl_Flag=MAKE_ARRAY(insitu_recs,value=1)
    insituChl=insitu_data.Chla_hplc
        no_hplc=where(finite(insituChl) LE 0.,cnt)
        if (cnt GT 0) then begin
            insituChl(no_hplc)=insitu_data.Chla_fluor(no_hplc)
            insituChl_Flag(no_hplc)=0
        endif
    insituTime=insitu_data.Hour + (insitu_data.Minute/60.)
    insituYearSDY=LONARR(insitu_recs)
    insituYMD=STRARR(insitu_recs)
    for i=0,insitu_recs-1 do begin
        insituYearSDY(i)=1000*insitu_data.Year(i)+sdy(insitu_data.Date(i),insitu_data.Month(i),insitu_data.Year(i))
        insituYMD(i)=string(insitu_data.Year(i),format='(I4.4)')+string(insitu_data.Month(i),format='(I2.2)')+$
              string(insitu_data.Date(i),format='(I2.2)')
    endfor

;-- READ IN-SITU DATA + INFO
;---------------------------



;----------------------------------------
;++ RETRIEVE GLOBCOLOUR DDS FILES + INFO
;All GlobCOLOUR products name are:
;   CHL1, CHL2, CDM, TSM, BBP, L412, L443, L490, L510, L531, L555, L620, L670, L681, L709, T865, CF, KD490, EL555
;There are also the special observation condition variables for DDS PC 1km only:
;   SZA, VZA, SAA, VAA, PRESSURE, WIND, (MOD/SWF have only SZA and SAA)

;Default is for DDS1KM match-ups

if(KEYWORD_SET(l3b_dds)) then begin
;Select L3 Binned files, default

    filDir=DIALOG_PICKFILE(/DIRECTORY,/Read,Title='Select GlobCOLOUR L3 Binned DDS File (4KM ISIN) Path')
    SearchResult=FILE_SEARCH(filDir, 'L3b_*.nc', count=nddsFiles)
    if(nddsFiles GT 0) then ddsFiles=SearchResult(sort(SearchResult)) $
    else RETALL
endif else begin

;Select L3 Mapped files, default
    filDir=DIALOG_PICKFILE(/DIRECTORY,/Read,Title='Select GlobCOLOUR L3 Mapped DDS File (1KM PC) Path')
    SearchResult=FILE_SEARCH(filDir, 'L3m_*.nc', count=nddsFiles)
    if(nddsFiles GT 0) then ddsFiles=SearchResult(sort(SearchResult)) $
    else RETALL
endelse

;Change dir to DDS directory and create a subdirectory where Matchup results go
CD,filDir
if(KEYWORD_SET(l3b_dds)) then MatchUpDirName='L3B_MatchUp' else MatchUpDirName='L3M_MatchUp'
FILE_MKDIR, MatchUpDirName

Sensor=4    ;Default is Find files for all sensors

p=where(STREGEX(ddsFiles,'_SWF_DDS_') NE -1, nSWF)
if(nSWF GT 1) then ddsSWFFiles=ddsFiles(p)
p=where(STREGEX(ddsFiles,'_MOD_DDS_') NE -1, nMOD)
if(nMOD GT 1) then ddsMODFiles=ddsFiles(p)
p=where(STREGEX(ddsFiles,'_MER_DDS_') NE -1, nMER)
if(nMER GT 1) then ddsMERFiles=ddsFiles(p)

;-- RETRIEVE GLOBCOLOUR DDS FILES + INFO
;---------------------------------------

wait,.1


;------------------------------------------------------------------
;++ OUTPUT FILES
header1='inID,inTime,inLat,inLon,ddsTime,ddsLat,ddsLon,'+$
        'inChl,inChl_Flag,inK490,inTSM,inaCDM,inBBP,inT865,'+$
        'inL412,inL443,inL490,inL510,inL531,inL555,inL620,inL670,inL681,inL709,'+$
        'ddsChl1,ddsChl2,ddsK490,ddsTSM,ddsaCDM,ddsBBP,ddsT865,'+$
        'ddsL412,ddsL443,ddsL490,ddsL510,ddsL531,ddsL555,ddsL620,ddsL670,ddsL681,ddsL709,'+$
        'ddsChl1_Flag,ddsChl2_Flag,ddsK490_Flag,ddsTSM_Flag,ddsaCDM_Flag,ddsBBP_Flag,ddsT865_Flag,'+$
        'ddsL412_Flag,ddsL443_Flag,ddsL490_Flag,ddsL510_Flag,ddsL531_Flag,ddsL555_Flag,ddsL620_Flag,ddsL670_Flag,ddsL681_Flag,ddsL709_Flag,'+$
        'ddsFilename,Input_file_Tag'
header2='inID,inTime,inLat,inLon,ddsTime,ddsLat,ddsLon,'+$
        'inChl,inChl_Flag,inK490,inTSM,inaCDM,inBBP,inT865,'+$
        'inL412,inL443,inL490,inL510,inL531,inL555,inL620,inL670,inL681,inL709,'+$
        'ddsChl1_avg,ddsChl2_avg,ddsK490_avg,ddsTSM_avg,ddsaCDM_avg,ddsBBP_avg,ddsT865_avg,'+$
        'ddsL412_avg,ddsL443_avg,ddsL490_avg,ddsL510_avg,ddsL531_avg,ddsL555_avg,ddsL620_avg,ddsL670_avg,ddsL681_avg,ddsL709_avg,'+$
        'ddsChl1_med,ddsChl2_med,ddsK490_med,ddsTSM_med,ddsaCDM_med,ddsBBP_med,ddsT865_med,'+$
        'ddsL412_med,ddsL443_med,ddsL490_med,ddsL510_med,ddsL531_med,ddsL555_med,ddsL620_med,ddsL670_med,ddsL681_med,ddsL709_med,'+$
        'ddsChl1_std,ddsChl2_std,ddsK490_std,ddsTSM_std,ddsaCDM_std,ddsBBP_std,ddsT865_std,'+$
        'ddsL412_std,ddsL443_std,ddsL490_std,ddsL510_std,ddsL531_std,ddsL555_std,ddsL620_std,ddsL670_std,ddsL681_std,ddsL709_std,'+$
        'ddsChl1_N,ddsChl2_N,ddsK490_N,ddsTSM_N,ddsaCDM_N,ddsBBP_N,ddsT865_N,'+$
        'ddsL412_N,ddsL443_N,ddsL490_N,ddsL510_N,ddsL531_N,ddsL555_N,ddsL620_N,ddsL670_N,ddsL681_N,ddsL709_N,'+$
        'ddsChl1_avg2,ddsChl2_avg2,ddsK490_avg2,ddsTSM_avg2,ddsaCDM_avg2,ddsBBP_avg2,ddsT865_avg2,'+$
        'ddsL412_avg2,ddsL443_avg2,ddsL490_avg2,ddsL510_avg2,ddsL531_avg2,ddsL555_avg2,ddsL620_avg2,ddsL670_avg2,ddsL681_avg2,ddsL709_avg2,'+$
        'ddsChl1_med2,ddsChl2_med2,ddsK490_med2,ddsTSM_med2,ddsaCDM_med2,ddsBBP_med2,ddsT865_med2,'+$
        'ddsL412_med2,ddsL443_med2,ddsL490_med2,ddsL510_med2,ddsL531_med2,ddsL555_med2,ddsL620_med2,ddsL670_med2,ddsL681_med2,ddsL709_med2,'+$
        'ddsChl1_std2,ddsChl2_std2,ddsK490_std2,ddsTSM_std2,ddsaCDM_std2,ddsBBP_std2,ddsT865_std2,'+$
        'ddsL412_std2,ddsL443_std2,ddsL490_std2,ddsL510_std2,ddsL531_std2,ddsL555_std2,ddsL620_std2,ddsL670_std2,ddsL681_std2,ddsL709_std2,'+$
        'ddsChl1_N2,ddsChl2_N2,ddsK490_N2,ddsTSM_N2,ddsaCDM_N2,ddsBBP_N2,ddsT865_N2,'+$
        'ddsL412_N2,ddsL443_N2,ddsL490_N2,ddsL510_N2,ddsL531_N2,ddsL555_N2,ddsL620_N2,ddsL670_N2,ddsL681_N2,ddsL709_N2,'+$
        'ddsFilename,Input_file_Tag'
;header3=''



if(KEYWORD_SET(seawifs)) then begin
;Filter DDS Files per Sensor
    Sensor=1
    if(nSWF GT 0) then begin
        openw,1,MatchUpDirName+separator+inDBname+'_v_SeaWiFS_DDS_Match_extract.csv'
        openw,2,MatchUpDirName+separator+inDBname+'_v_SeaWiFS_DDS_Match_average.csv'
        ;openw,3,MatchUpDirName+separator+inDBname+'_v_SeaWiFS_DDS_Match_stats.csv'
        printf,1,header1
        printf,2,header2
        ;printf,3,header3
    endif
endif
if(KEYWORD_SET(modis)) then begin
    Sensor=2
    if(nMOD GT 0) then begin
        openw,4,MatchUpDirName+separator+inDBname+'_v_MODIS_DDS_Match_extract.csv'
        openw,5,MatchUpDirName+separator+inDBname+'_v_MODIS_DDS_Match_average.csv'
        ;openw,6,MatchUpDirName+separator+inDBname+'_v_MODIS_DDS_Match_stats.csv'
        printf,4,header1
        printf,5,header2
        ;printf,6,header3
    endif
endif
if(KEYWORD_SET(meris)) then begin
    Sensor=3
    if(nMER GT 0) then begin
        openw,7,MatchUpDirName+separator+inDBname+'_v_MERIS_DDS_Match_extract.csv'
        openw,8,MatchUpDirName+separator+inDBname+'_v_MERIS_DDS_Match_average.csv'
        ;openw,9,MatchUpDirName+separator+inDBname+'_v_MERIS_DDS_Match_stats.csv'
        printf,7,header1
        printf,8,header2
        ;printf,9,header3
    endif
endif
if ~(KEYWORD_SET(seawifs) OR KEYWORD_SET(modis) OR KEYWORD_SET(meris))then begin
    if(nSWF GT 0) then begin
        openw,1,MatchUpDirName+separator+inDBname+'_v_SeaWiFS_DDS_Match_extract.csv'
        openw,2,MatchUpDirName+separator+inDBname+'_v_SeaWiFS_DDS_Match_average.csv'
        ;openw,3,MatchUpDirName+separator+inDBname+'_v_SeaWiFS_DDS_Match_stats.csv'
        printf,1,header1
        printf,2,header2
        ;printf,3,header3
    endif

    if(nMOD GT 0) then begin
        openw,4,MatchUpDirName+separator+inDBname+'_v_MODIS_DDS_Match_extract.csv'
        openw,5,MatchUpDirName+separator+inDBname+'_v_MODIS_DDS_Match_average.csv'
        ;openw,6,MatchUpDirName+separator+inDBname+'_v_MODIS_DDS_Match_stats.csv'
        printf,4,header1
        printf,5,header2
        ;printf,6,header3
    endif

    if(nMER GT 0) then begin
        openw,7,MatchUpDirName+separator+inDBname+'_v_MERIS_DDS_Match_extract.csv'
        openw,8,MatchUpDirName+separator+inDBname+'_v_MERIS_DDS_Match_average.csv'
        ;openw,9,MatchUpDirName+separator+inDBname+'_v_MERIS_DDS_Match_stats.csv'
        printf,7,header1
        printf,8,header2
        ;printf,9,header3
    endif
endif


;-- OUTPUT FILES
;------------------------------------------------------------------




print,'Total DDS Files', nddsFiles
;-----------------------------------------------------------------------------
if(nddsFiles LT 1) then begin
    print,'NO DDS FILES FOUND'
    RETALL
endif else begin
;Loop through each DDS file per sensor


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START SEAWIFS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;[+1]. SeaWiFS

    if((Sensor EQ 1 or Sensor EQ 4) and nSWF GT 0) then begin
       for i=0,nSWF-1 do begin
        ddsFile=FILE_BASENAME(ddsSWFFiles(i))
        ddsYear=FIX(strmid(ddsFile,4,4))
        ddsMonth=FIX(strmid(ddsFile,8,2))
        ddsDay=FIX(strmid(ddsFile,10,2))
        ddsYearSDY=1000L*ddsYear+sdy(ddsDay,ddsMonth,ddsYear)
        ddsYMD=strmid(ddsFile,4,8)
        ddsHour=FIX(strmid(ddsFile,13,2))
        ddsMinute=FIX(strmid(ddsFile,15,2))
        ddsTime=ddsHour + (ddsMinute/60.)



        day_match=where(insituYearSDY EQ ddsYearSDY, nr)
        if(keyword_set(time_series)) then begin
            if(nr GT 1) then begin
            tDiff=abs(ddsTime - insituTime(day_match))
            mintDiff=where(tDiff EQ min(tDiff))
            day_match=day_match(mintDiff)
            nr=1
            endif
        endif
        if(nr GT 0) then begin
            print,ddsFile+" matches with "+string(nr)+" in-situ record(s) for same day."
            ;print,insitu_data.ID(day_match)
            inLon=insitu_data.Longitude(day_match)
            inLat=insitu_data.Latitude(day_match)
            inYearSDY=insituYearSDY(day_match)




            ;read_netCDF, ddsFile[0], dds_data, dds_attr, status
            read_netCDF, ddsSWFFiles(i), dds_data, dds_attr, status
            dds_tags=TAG_NAMES(dds_data)    ;available variable names in the DDS file

            time_info=dds_attr[where(stregex(dds_attr,'start_time =') NE -1)] ;DDS Start time
            dds_time=strmid(time_info,stregex(time_info,'[0-9]'),100)
            dds_Hour=FIX(strmid(dds_time[0],9,2))
            dds_Minute=FIX(strmid(dds_time[0],11,2))
            ;print,dds_time

;Treat the match-up depending on the input_file type LAC=1.1km and GAC=4.4km effective resolution
            input_file_info=dds_attr[where(stregex(dds_attr,'input_files =') NE -1)] ;Input File
            split_string=strsplit(input_file_info,'_',/extract)
            ;input_file_tag=split_string[2] ;GAC or MLAC or LAC
            if((total(strmatch(split_string,'MLAC')) GE 1) or (total(strmatch(split_string,'LAC')) GE 1)) then input_file_tag='LAC'
            if((total(strmatch(split_string,'GAC')) GE 1) and (total(strmatch(split_string,'MLAC')) EQ 0) and (total(strmatch(split_string,'LAC')) EQ 0)) then input_file_tag='GAC'



;MAIN LOOP
            for k=0,nr-1 do begin
            ;print,inLon(k),inYearSDY(k),ddsYearSDY


              if(KEYWORD_SET(l3b_dds)) then begin
;[+1.1] L3 Binned DDS (All data are in 1-D array form)

              offset=KM2DEG(5.0, inLon(k), inLat(k))    ;Maximum distance from the in-situ location is 5km for ISIN (4km) products
              inDist=SQRT(offset[0]^2. + offset[1]^2.)

                row_info=dds_attr[where(stregex(dds_attr,'first_row =') NE -1)]
                first_row=LONG(strmid(row_info,stregex(row_info,'[0-9]'),100))
                lat_step_info=dds_attr[where(stregex(dds_attr,'lat_step =') NE -1)]
                lat_step=DOUBLE(strmid(lat_step_info,stregex(lat_step_info,'[0-9]'),100))

                idx=dds_data.row-first_row[0]
                ddsLat=dds_data.center_lat(idx)
                ddsLon=dds_data.center_lon(idx) + dds_data.col*dds_data.lon_step(idx)

                p=NearestPoint(ddsLon, ddsLat, inLon(k), inLat(k), MaxDist=inDist, SR=inDist, nP=9)
                nPix=n_elements(p)
                if(nPix GT 1) then begin

                    ddsCHLm=(ddsCHL2m=(ddsKD490m=(ddsTSMm=(ddsCDMm=(ddsBBPm=(ddsT865m=FLTARR(nPix)))))))    ;MEAN
                    ddsL412m=(ddsL443m=(ddsL490m=(ddsL510m=(ddsL531m=(ddsL555m=(ddsL620m=(ddsL670m=(ddsL681m=(ddsL709m=FLTARR(nPix))))))))))
                    ddsCHLs=(ddsCHL2s=(ddsKD490s=(ddsTSMs=(ddsCDMs=(ddsBBPs=(ddsT865s=FLTARR(nPix)))))))    ;STDEV
                    ddsL412s=(ddsL443s=(ddsL490s=(ddsL510s=(ddsL531s=(ddsL555s=(ddsL620s=(ddsL670s=(ddsL681s=(ddsL709s=FLTARR(nPix))))))))))
                    ddsCHLn=(ddsCHL2n=(ddsKD490n=(ddsTSMn=(ddsCDMn=(ddsBBPn=(ddsT865n=FLTARR(nPix)))))))    ;COUNT
                    ddsL412n=(ddsL443n=(ddsL490n=(ddsL510n=(ddsL531n=(ddsL555n=(ddsL620n=(ddsL670n=(ddsL681n=(ddsL709n=FLTARR(nPix))))))))))
                    ddsCHLw=(ddsCHL2w=(ddsKD490w=(ddsTSMw=(ddsCDMw=(ddsBBPw=(ddsT865w=FLTARR(nPix)))))))    ;WEIGHT
                    ddsL412w=(ddsL443w=(ddsL490w=(ddsL510w=(ddsL531w=(ddsL555w=(ddsL620w=(ddsL670w=(ddsL681w=(ddsL709w=FLTARR(nPix))))))))))
                    ddsCHLf=(ddsCHL2f=(ddsKD490f=(ddsTSMf=(ddsCDMf=(ddsBBPf=(ddsT865f=FLTARR(nPix)))))))    ;FLAGS
                    ddsL412f=(ddsL443f=(ddsL490f=(ddsL510f=(ddsL531f=(ddsL555f=(ddsL620f=(ddsL670f=(ddsL681f=(ddsL709f=FLTARR(nPix))))))))))
                    ddsCHLe=(ddsCHL2e=(ddsKD490e=(ddsTSMe=(ddsCDMe=(ddsBBPe=(ddsT865e=FLTARR(nPix)))))))    ;ERROR
                    ddsL412e=(ddsL443e=(ddsL490e=(ddsL510e=(ddsL531e=(ddsL555e=(ddsL620e=(ddsL670e=(ddsL681e=(ddsL709e=FLTARR(nPix))))))))))
                    ddsLat=ddsLat(p)
                    ddsLon=ddsLon(p)
                    ddsCHLcv=(ddsCHL2cv=(ddsKD490cv=(ddsTSMcv=(ddsCDMcv=(ddsBBPcv=(ddsT865cv=MAKE_ARRAY(nPix,Value=1.)))))))    ;COEFFICIENT OF VARIATION
                    ddsL412cv=(ddsL443cv=(ddsL490cv=(ddsL510cv=(ddsL531cv=(ddsL555cv=(ddsL620cv=(ddsL670cv=(ddsL681cv=(ddsL709cv=MAKE_ARRAY(nPix,Value=1.))))))))))


                    if(TOTAL(strmatch(dds_tags,'CHL1_MEAN'))) then ddsCHLm=dds_data.CHL1_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_STDEV'))) then ddsCHLs=dds_data.CHL1_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_COUNT'))) then ddsCHLn=UINT(dds_data.CHL1_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CHL1_WEIGHT'))) then ddsCHLw=dds_data.CHL1_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_FLAGS'))) then ddsCHLf=UINT(dds_data.CHL1_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CHL1_ERROR'))) then ddsCHLe=UINT(dds_data.CHL1_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'CHL2_MEAN'))) then ddsCHL2m=dds_data.CHL2_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_STDEV'))) then ddsCHL2s=dds_data.CHL2_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_COUNT'))) then ddsCHL2n=UINT(dds_data.CHL2_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CHL2_WEIGHT'))) then ddsCHL2w=dds_data.CHL2_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_FLAGS'))) then ddsCHL2f=UINT(dds_data.CHL2_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CHL2_ERROR'))) then ddsCHL2e=UINT(dds_data.CHL2_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'KD490_MEAN'))) then ddsKD490m=dds_data.KD490_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_STDEV'))) then ddsKD490s=dds_data.KD490_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_COUNT'))) then ddsKD490n=UINT(dds_data.KD490_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'KD490_WEIGHT'))) then ddsKD490w=dds_data.KD490_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_FLAGS'))) then ddsKD490f=UINT(dds_data.KD490_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'KD490_ERROR'))) then ddsKD490e=UINT(dds_data.KD490_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'TSM_MEAN'))) then ddsTSMm=dds_data.TSM_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_STDEV'))) then ddsTSMs=dds_data.TSM_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_COUNT'))) then ddsTSMn=UINT(dds_data.TSM_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'TSM_WEIGHT'))) then ddsTSMw=dds_data.TSM_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_FLAGS'))) then ddsTSMf=UINT(dds_data.TSM_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'TSM_ERROR'))) then ddsTSMe=UINT(dds_data.TSM_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'CDM_MEAN'))) then ddsCDMm=dds_data.CDM_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_STDEV'))) then ddsCDMs=dds_data.CDM_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_COUNT'))) then ddsCDMn=UINT(dds_data.CDM_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CDM_WEIGHT'))) then ddsCDMw=dds_data.CDM_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_FLAGS'))) then ddsCDMf=UINT(dds_data.CDM_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CDM_ERROR'))) then ddsCDMe=UINT(dds_data.CDM_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'BBP_MEAN'))) then ddsBBPm=dds_data.BBP_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_STDEV'))) then ddsBBPs=dds_data.BBP_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_COUNT'))) then ddsBBPn=UINT(dds_data.BBP_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'BBP_WEIGHT'))) then ddsBBPw=dds_data.BBP_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_FLAGS'))) then ddsBBPf=UINT(dds_data.BBP_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'BBP_ERROR'))) then ddsBBPe=UINT(dds_data.BBP_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'T865_MEAN'))) then ddsT865m=dds_data.T865_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'T865_STDEV'))) then ddsT865s=dds_data.T865_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'T865_COUNT'))) then ddsT865n=UINT(dds_data.T865_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'T865_WEIGHT'))) then ddsT865w=dds_data.T865_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'T865_FLAGS'))) then ddsT865f=UINT(dds_data.T865_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'T865_ERROR'))) then ddsT865e=UINT(dds_data.T865_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L412_MEAN'))) then ddsL412m=dds_data.L412_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L412_STDEV'))) then ddsL412s=dds_data.L412_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L412_COUNT'))) then ddsL412n=UINT(dds_data.L412_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L412_WEIGHT'))) then ddsL412w=dds_data.L412_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L412_FLAGS'))) then ddsL412f=UINT(dds_data.L412_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L412_ERROR'))) then ddsL412e=UINT(dds_data.L412_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L443_MEAN'))) then ddsL443m=dds_data.L443_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L443_STDEV'))) then ddsL443s=dds_data.L443_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L443_COUNT'))) then ddsL443n=UINT(dds_data.L443_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L443_WEIGHT'))) then ddsL443w=dds_data.L443_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L443_FLAGS'))) then ddsL443f=UINT(dds_data.L443_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L443_ERROR'))) then ddsL443e=UINT(dds_data.L443_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L490_MEAN'))) then ddsL490m=dds_data.L490_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L490_STDEV'))) then ddsL490s=dds_data.L490_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L490_COUNT'))) then ddsL490n=UINT(dds_data.L490_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L490_WEIGHT'))) then ddsL490w=dds_data.L490_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L490_FLAGS'))) then ddsL490f=UINT(dds_data.L490_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L490_ERROR'))) then ddsL490e=UINT(dds_data.L490_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L510_MEAN'))) then ddsL510m=dds_data.L510_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L510_STDEV'))) then ddsL510s=dds_data.L510_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L510_COUNT'))) then ddsL510n=UINT(dds_data.L510_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L510_WEIGHT'))) then ddsL510w=dds_data.L510_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L510_FLAGS'))) then ddsL510f=UINT(dds_data.L510_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L510_ERROR'))) then ddsL510e=UINT(dds_data.L510_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L531_MEAN'))) then ddsL531m=dds_data.L531_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L531_STDEV'))) then ddsL531s=dds_data.L531_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L531_COUNT'))) then ddsL531n=UINT(dds_data.L531_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L531_WEIGHT'))) then ddsL531w=dds_data.L531_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L531_FLAGS'))) then ddsL531f=UINT(dds_data.L531_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L531_ERROR'))) then ddsL531e=UINT(dds_data.L531_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L555_MEAN'))) then ddsL555m=dds_data.L555_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L555_STDEV'))) then ddsL555s=dds_data.L555_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L555_COUNT'))) then ddsL555n=UINT(dds_data.L555_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L555_WEIGHT'))) then ddsL555w=dds_data.L555_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L555_FLAGS'))) then ddsL555f=UINT(dds_data.L555_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L555_ERROR'))) then ddsL555e=UINT(dds_data.L555_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L620_MEAN'))) then ddsL620m=dds_data.L620_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L620_STDEV'))) then ddsL620s=dds_data.L620_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L620_COUNT'))) then ddsL620n=UINT(dds_data.L620_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L620_WEIGHT'))) then ddsL620w=dds_data.L620_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L620_FLAGS'))) then ddsL620f=UINT(dds_data.L620_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L620_ERROR'))) then ddsL620e=UINT(dds_data.L620_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L670_MEAN'))) then ddsL670m=dds_data.L670_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L670_STDEV'))) then ddsL670s=dds_data.L670_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L670_COUNT'))) then ddsL670n=UINT(dds_data.L670_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L670_WEIGHT'))) then ddsL670w=dds_data.L670_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L670_FLAGS'))) then ddsL670f=UINT(dds_data.L670_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L670_ERROR'))) then ddsL670e=UINT(dds_data.L670_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L681_MEAN'))) then ddsL681m=dds_data.L681_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L681_STDEV'))) then ddsL681s=dds_data.L681_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L681_COUNT'))) then ddsL681n=UINT(dds_data.L681_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L681_WEIGHT'))) then ddsL681w=dds_data.L681_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L681_FLAGS'))) then ddsL681f=UINT(dds_data.L681_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L681_ERROR'))) then ddsL681e=UINT(dds_data.L681_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L709_MEAN'))) then ddsL709m=dds_data.L709_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L709_STDEV'))) then ddsL709s=dds_data.L709_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L709_COUNT'))) then ddsL709n=UINT(dds_data.L709_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L709_WEIGHT'))) then ddsL709w=dds_data.L709_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L709_FLAGS'))) then ddsL709f=UINT(dds_data.L709_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L709_ERROR'))) then ddsL709e=UINT(dds_data.L709_ERROR(p))


;[+1.1.a] Write extracted pixel to file----------------------------------------------------------------------------------
                    for pp=0, nPix-1 do begin
                     printf,1,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                        inLat(k),inLon(k),dds_time,ddsLat(pp),ddsLon(pp),$
                        insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                        insitu_data.T865(day_match(k)),$
                        insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                        insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                        ddsCHLm(pp),ddsCHL2m(pp),ddsKD490m(pp),ddsTSMm(pp),ddsCDMm(pp),ddsBBPm(pp),ddsT865m(pp),$
                        ddsL412m(pp),ddsL443m(pp),ddsL490m(pp),ddsL510m(pp),ddsL531m(pp),ddsL555m(pp),ddsL620m(pp),ddsL670m(pp),ddsL681m(pp),ddsL709m(pp),$
                        ddsCHLf(pp),ddsCHL2f(pp),ddsKD490f(pp),ddsTSMf(pp),ddsCDMf(pp),ddsBBPf(pp),ddsT865f(pp),$
                        ddsL412f(pp),ddsL443f(pp),ddsL490f(pp),ddsL510f(pp),ddsL531f(pp),ddsL555f(pp),ddsL620f(pp),ddsL670f(pp),ddsL681f(pp),ddsL709f(pp),$
                        ddsFile[0],input_file_tag,$
                        FORMAT='(2(A,","),2(F,","),A,",",36(F,","),18(A,","),A)'
                    endfor
;[-1.1.a] Write extracted pixel to file----------------------------------------------------------------------------------


;Initiate variable average, median, stdev for extracted pixels
                        ddsLonav=(ddsLatav=(ddsCHLav=(ddsCHL2av=(ddsKD490av=(ddsTSMav=(ddsCDMav=(ddsBBPav=(ddsT865av=!Values.F_NaN))))))))    ;Average of extracted pixels
                        ddsL412av=(ddsL443av=(ddsL490av=(ddsL510av=(ddsL531av=(ddsL555av=(ddsL620av=(ddsL670av=(ddsL681av=(ddsL709av=!Values.F_NaN)))))))))
                        ddsLonmd=(ddsLatmd=(ddsCHLmd=(ddsCHL2md=(ddsKD490md=(ddsTSMmd=(ddsCDMmd=(ddsBBPmd=(ddsT865md=!Values.F_NaN))))))))    ;Median of extracted pixels
                        ddsL412md=(ddsL443md=(ddsL490md=(ddsL510md=(ddsL531md=(ddsL555md=(ddsL620md=(ddsL670md=(ddsL681md=(ddsL709md=!Values.F_NaN)))))))))
                        ddsLonsd=(ddsLatsd=(ddsCHLsd=(ddsCHL2sd=(ddsKD490sd=(ddsTSMsd=(ddsCDMsd=(ddsBBPsd=(ddsT865sd=!Values.F_NaN))))))))    ;Standard deviation of extracted pixels
                        ddsL412sd=(ddsL443sd=(ddsL490sd=(ddsL510sd=(ddsL531sd=(ddsL555sd=(ddsL620sd=(ddsL670sd=(ddsL681sd=(ddsL709sd=!Values.F_NaN)))))))))

                        ddsCHLfilt=(ddsCHL2filt=(ddsKD490filt=(ddsTSMfilt=(ddsCDMfilt=(ddsBBPfilt=(ddsT865filt=MAKE_ARRAY(4,Value=!Values.F_NaN)))))))
                        ddsL412filt=(ddsL443filt=(ddsL490filt=(ddsL510filt=(ddsL531filt=(ddsL555filt=(ddsL620filt=(ddsL670filt=(ddsL681filt=(ddsL709filt=MAKE_ARRAY(4,Value=!Values.F_NaN))))))))))


                        c1_msk=(c2_msk=(kd_msk=(tsm_msk=(cdm_msk=(bbp_msk=(t865_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0))))))))
                        L412_msk=(L443_msk=(L490_msk=(L510_msk=(L531_msk=(L555_msk=(L620_msk=(L670_msk=(L681_msk=(L709_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0)))))))))))

                        for pp=0, nPix-1 do begin
                          if(ddsCHLs(pp) GT 0. and ddsCHLm(pp) GT 0.) then ddsCHLcv(pp)=ddsCHLs(pp)/ddsCHLm(pp)
                          if(ddsCHL2s(pp) GT 0. and ddsCHL2m(pp) GT 0.) then ddsCHL2cv(pp)=ddsCHL2s(pp)/ddsCHL2m(pp)
                          if(ddsKD490s(pp) GT 0. and ddsKD490m(pp) GT 0.) then ddsKD490cv(pp)=ddsKD490s(pp)/ddsKD490m(pp)
                          if(ddsTSMs(pp) GT 0. and ddsTSMm(pp) GT 0.) then ddsTSMcv(pp)=ddsTSMs(pp)/ddsTSMm(pp)
                          if(ddsCDMs(pp) GT 0. and ddsCDMm(pp) GT 0.) then ddsCDMcv(pp)=ddsCDMs(pp)/ddsCDMm(pp)
                          if(ddsBBPs(pp) GT 0. and ddsBBPm(pp) GT 0.) then ddsBBPcv(pp)=ddsBBPs(pp)/ddsBBPm(pp)
                          if(ddsT865s(pp) GT 0. and ddsT865m(pp) GT 0.) then ddsT865cv(pp)=ddsT865s(pp)/ddsT865m(pp)
                          if(ddsL412s(pp) GT 0. and ddsL412m(pp) GT 0.) then ddsL412cv(pp)=ddsL412s(pp)/ddsL412m(pp)
                          if(ddsL443s(pp) GT 0. and ddsL443m(pp) GT 0.) then ddsL443cv(pp)=ddsL443s(pp)/ddsL443m(pp)
                          if(ddsL490s(pp) GT 0. and ddsL490m(pp) GT 0.) then ddsL490cv(pp)=ddsL490s(pp)/ddsL490m(pp)
                          if(ddsL510s(pp) GT 0. and ddsL510m(pp) GT 0.) then ddsL510cv(pp)=ddsL510s(pp)/ddsL510m(pp)
                          if(ddsL531s(pp) GT 0. and ddsL531m(pp) GT 0.) then ddsL531cv(pp)=ddsL531s(pp)/ddsL531m(pp)
                          if(ddsL555s(pp) GT 0. and ddsL555m(pp) GT 0.) then ddsL555cv(pp)=ddsL555s(pp)/ddsL555m(pp)
                          if(ddsL620s(pp) GT 0. and ddsL620m(pp) GT 0.) then ddsL620cv(pp)=ddsL620s(pp)/ddsL620m(pp)
                          if(ddsL670s(pp) GT 0. and ddsL670m(pp) GT 0.) then ddsL670cv(pp)=ddsL670s(pp)/ddsL670m(pp)
                          if(ddsL681s(pp) GT 0. and ddsL681m(pp) GT 0.) then ddsL681cv(pp)=ddsL681s(pp)/ddsL681m(pp)
                          if(ddsL709s(pp) GT 0. and ddsL709m(pp) GT 0.) then ddsL709cv(pp)=ddsL709s(pp)/ddsL709m(pp)


                          flg=gcDDSFLAG2Name(ddsCHLf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4) and (ddsCHLcv(pp) LT cvar)) then c1_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCHL2f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LE 4) and (ddsCHL2cv(pp) LT cvar)) then c2_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsKD490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4) and (ddsKD490cv(pp) LT cvar)) then kd_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsTSMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsTSMcv(pp) LT cvar)) then tsm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCDMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsCDMcv(pp) LT cvar)) then cdm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsBBPf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsBBPcv(pp) LT cvar)) then bbp_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsT865f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsT865cv(pp) LT cvar)) then t865_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL412f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL412cv(pp) LT cvar)) then L412_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL443f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL443cv(pp) LT cvar)) then L443_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL490cv(pp) LT cvar)) then L490_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL510f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL510cv(pp) LT cvar)) then L510_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL531f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL531cv(pp) LT cvar)) then L531_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL555f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL555cv(pp) LT cvar)) then L555_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL620f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL620cv(pp) LT cvar)) then L620_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL670f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL670cv(pp) LT cvar)) then L670_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL681f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL681cv(pp) LT cvar)) then L681_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL709f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL709cv(pp) LT cvar)) then L709_msk(pp)=1
                        endfor

                        momddsLon=MOMENT(ddsLon,SDEV=ddsLonsd)
                        ddsLonav=momddsLon(0)
                        ;ddsLonmd=MEDIAN(ddsLon)
                        momddsLat=MOMENT(ddsLat,SDEV=ddsLatsd)
                        ddsLatav=momddsLat(0)
                        ;ddsLatmd=MEDIAN(ddsLat)

                        ;if(strcmp(input_file_tag,'LAC')) then NGP=5 else NGP=2
                        NGP=5
                        if(total(c1_msk) GE 2) then begin
                            momddsCHL=MOMENT(ddsCHLm(where(c1_msk)),SDEV=ddsCHLsd)
                            ddsCHLav=momddsCHL(0)
                            ddsCHLmd=MEDIAN(ddsCHLm(where(c1_msk)))
                            if(total(c1_msk) GE NGP) then ddsCHLfilt=FILTERED_AVERAGE(ddsCHLm(where(c1_msk)),CV=cvar)
                        endif
                        if(total(c2_msk) GE 2) then begin
                            momddsCHL2=MOMENT(ddsCHL2m(where(c2_msk)),SDEV=ddsCHL2sd)
                            ddsCHL2av=momddsCHL2(0)
                            ddsCHL2md=MEDIAN(ddsCHL2m(where(c2_msk)))
                            if(total(c2_msk) GE NGP) then ddsCHL2filt=FILTERED_AVERAGE(ddsCHL2m(where(c2_msk)),CV=cvar)
                        endif
                        if(total(kd_msk) GE 2) then begin
                            momddsKD490=MOMENT(ddsKD490m(where(kd_msk)),SDEV=ddsKD490sd)
                            ddsKD490av=momddsKD490(0)
                            ddsKD490md=MEDIAN(ddsKD490m(where(kd_msk)))
                            if(total(kd_msk) GE NGP) then ddsKD490filt=FILTERED_AVERAGE(ddsKD490m(where(kd_msk)),CV=cvar)
                        endif
                        if(total(tsm_msk) GE 2) then begin
                            momddsTSM=MOMENT(ddsTSMm(where(tsm_msk)),SDEV=ddsTSMsd)
                            ddsTSMav=momddsTSM(0)
                            ddsTSMmd=MEDIAN(ddsTSMm(where(tsm_msk)))
                            if(total(tsm_msk) GE NGP) then ddsTSMfilt=FILTERED_AVERAGE(ddsTSMm(where(tsm_msk)),CV=cvar)
                        endif
                        if(total(cdm_msk) GE 2) then begin
                            momddsCDM=MOMENT(ddsCDMm(where(cdm_msk)),SDEV=ddsCDMsd)
                            ddsCDMav=momddsCDM(0)
                            ddsCDMmd=MEDIAN(ddsCDMm(where(cdm_msk)))
                            if(total(cdm_msk) GE NGP) then ddsCDMfilt=FILTERED_AVERAGE(ddsCDMm(where(cdm_msk)),CV=cvar)
                        endif
                        if(total(bbp_msk) GE 2) then begin
                            momddsBBP=MOMENT(ddsBBPm(where(bbp_msk)),SDEV=ddsBBPsd)
                            ddsBBPav=momddsBBP(0)
                            ddsBBPmd=MEDIAN(ddsBBPm(where(bbp_msk)))
                            if(total(bbp_msk) GE NGP) then ddsBBPfilt=FILTERED_AVERAGE(ddsBBPm(where(bbp_msk)),CV=cvar)
                        endif
                        if(total(t865_msk) GE 2) then begin
                            momddsT865=MOMENT(ddsT865m(where(t865_msk)),SDEV=ddsT865sd)
                            ddsT865av=momddsT865(0)
                            ddsT865md=MEDIAN(ddsT865m(where(t865_msk)))
                            if(total(t865_msk) GE NGP) then ddsT865filt=FILTERED_AVERAGE(ddsT865m(where(t865_msk)),CV=cvar)
                        endif
                        if(total(L412_msk) GE 2) then begin
                            momddsL412=MOMENT(ddsL412m(where(L412_msk)),SDEV=ddsL412sd)
                            ddsL412av=momddsL412(0)
                            ddsL412md=MEDIAN(ddsL412m(where(L412_msk)))
                            if(total(L412_msk) GE NGP) then ddsL412filt=FILTERED_AVERAGE(ddsL412m(where(L412_msk)),CV=cvar)
                        endif
                        if(total(L443_msk) GE 2) then begin
                            momddsL443=MOMENT(ddsL443m(where(L443_msk)),SDEV=ddsL443sd)
                            ddsL443av=momddsL443(0)
                            ddsL443md=MEDIAN(ddsL443m(where(L443_msk)))
                            if(total(L443_msk) GE NGP) then ddsL443filt=FILTERED_AVERAGE(ddsL443m(where(L443_msk)),CV=cvar)
                        endif
                        if(total(L490_msk) GE 2) then begin
                            momddsL490=MOMENT(ddsL490m(where(L490_msk)),SDEV=ddsL490sd)
                            ddsL490av=momddsL490(0)
                            ddsL490md=MEDIAN(ddsL490m(where(L490_msk)))
                            if(total(L490_msk) GE NGP) then ddsL490filt=FILTERED_AVERAGE(ddsL490m(where(L490_msk)),CV=cvar)
                        endif
                        if(total(L510_msk) GE 2) then begin
                            momddsL510=MOMENT(ddsL510m(where(L510_msk)),SDEV=ddsL510sd)
                            ddsL510av=momddsL510(0)
                            ddsL510md=MEDIAN(ddsL510m(where(L510_msk)))
                            if(total(L510_msk) GE NGP) then ddsL510filt=FILTERED_AVERAGE(ddsL510m(where(L510_msk)),CV=cvar)
                        endif
                        if(total(L531_msk) GE 2) then begin
                            momddsL531=MOMENT(ddsL531m(where(L531_msk)),SDEV=ddsL531sd)
                            ddsL531av=momddsL531(0)
                            ddsL531md=MEDIAN(ddsL531m(where(L531_msk)))
                            if(total(L531_msk) GE NGP) then ddsL531filt=FILTERED_AVERAGE(ddsL531m(where(L531_msk)),CV=cvar)
                        endif
                        if(total(L555_msk) GE 2) then begin
                            momddsL555=MOMENT(ddsL555m(where(L555_msk)),SDEV=ddsL555sd)
                            ddsL555av=momddsL555(0)
                            ddsL555md=MEDIAN(ddsL555m(where(L555_msk)))
                            if(total(L555_msk) GE NGP) then ddsL555filt=FILTERED_AVERAGE(ddsL555m(where(L555_msk)),CV=cvar)
                        endif
                        if(total(L620_msk) GE 2) then begin
                            momddsL620=MOMENT(ddsL620m(where(L620_msk)),SDEV=ddsL620sd)
                            ddsL620av=momddsL620(0)
                            ddsL620md=MEDIAN(ddsL620m(where(L620_msk)))
                            if(total(L620_msk) GE NGP) then ddsL620filt=FILTERED_AVERAGE(ddsL620m(where(L620_msk)),CV=cvar)
                        endif
                        if(total(L670_msk) GE 2) then begin
                            momddsL670=MOMENT(ddsL670m(where(L670_msk)),SDEV=ddsL670sd)
                            ddsL670av=momddsL670(0)
                            ddsL670md=MEDIAN(ddsL670m(where(L670_msk)))
                            if(total(L670_msk) GE NGP) then ddsL670filt=FILTERED_AVERAGE(ddsL670m(where(L670_msk)),CV=cvar)
                        endif
                        if(total(L681_msk) GE 2) then begin
                            momddsL681=MOMENT(ddsL681m(where(L681_msk)),SDEV=ddsL681sd)
                            ddsL681av=momddsL681(0)
                            ddsL681md=MEDIAN(ddsL681m(where(L681_msk)))
                            if(total(L681_msk) GE NGP) then ddsL681filt=FILTERED_AVERAGE(ddsL681m(where(L681_msk)),CV=cvar)
                        endif
                        if(total(L709_msk) GE 2) then begin
                            momddsL709=MOMENT(ddsL709m(where(L709_msk)),SDEV=ddsL709sd)
                            ddsL709av=momddsL709(0)
                            ddsL709md=MEDIAN(ddsL709m(where(L709_msk)))
                            if(total(L709_msk) GE NGP) then ddsL709filt=FILTERED_AVERAGE(ddsL709m(where(L709_msk)),CV=cvar)
                        endif


;[+1.1.b] Write macro average data to file----------------------------------------------------------------------------------
                        printf,2,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLatav,ddsLonav,$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLav,ddsCHL2av,ddsKD490av,ddsTSMav,ddsCDMav,ddsBBPav,ddsT865av,$
                            ddsL412av,ddsL443av,ddsL490av,ddsL510av,ddsL531av,ddsL555av,ddsL620av,ddsL670av,ddsL681av,ddsL709av,$
                            ddsCHLmd,ddsCHL2md,ddsKD490md,ddsTSMmd,ddsCDMmd,ddsBBPmd,ddsT865md,$
                            ddsL412md,ddsL443md,ddsL490md,ddsL510md,ddsL531md,ddsL555md,ddsL620md,ddsL670md,ddsL681md,ddsL709md,$
                            ddsCHLsd,ddsCHL2sd,ddsKD490sd,ddsTSMsd,ddsCDMsd,ddsBBPsd,ddsT865sd,$
                            ddsL412sd,ddsL443sd,ddsL490sd,ddsL510sd,ddsL531sd,ddsL555sd,ddsL620sd,ddsL670sd,ddsL681sd,ddsL709sd,$
                            total(c1_msk),total(c2_msk),total(kd_msk),total(tsm_msk),total(cdm_msk),total(bbp_msk),total(t865_msk),$
                            total(L412_msk),total(L443_msk),total(L490_msk),total(L510_msk),total(L531_msk),total(L555_msk),total(L620_msk),total(L670_msk),total(L681_msk),total(L709_msk),$
                            ddsCHLfilt(0),ddsCHL2filt(0),ddsKD490filt(0),ddsTSMfilt(0),ddsCDMfilt(0),ddsBBPfilt(0),ddsT865filt(0),$
                            ddsL412filt(0),ddsL443filt(0),ddsL490filt(0),ddsL510filt(0),ddsL531filt(0),ddsL555filt(0),ddsL620filt(0),ddsL670filt(0),ddsL681filt(0),ddsL709filt(0),$
                            ddsCHLfilt(1),ddsCHL2filt(1),ddsKD490filt(1),ddsTSMfilt(1),ddsCDMfilt(1),ddsBBPfilt(1),ddsT865filt(1),$
                            ddsL412filt(1),ddsL443filt(1),ddsL490filt(1),ddsL510filt(1),ddsL531filt(1),ddsL555filt(1),ddsL620filt(1),ddsL670filt(1),ddsL681filt(1),ddsL709filt(1),$
                            ddsCHLfilt(2),ddsCHL2filt(2),ddsKD490filt(2),ddsTSMfilt(2),ddsCDMfilt(2),ddsBBPfilt(2),ddsT865filt(2),$
                            ddsL412filt(2),ddsL443filt(2),ddsL490filt(2),ddsL510filt(2),ddsL531filt(2),ddsL555filt(2),ddsL620filt(2),ddsL670filt(2),ddsL681filt(2),ddsL709filt(2),$
                            ddsCHLfilt(3),ddsCHL2filt(3),ddsKD490filt(3),ddsTSMfilt(3),ddsCDMfilt(3),ddsBBPfilt(3),ddsT865filt(3),$
                            ddsL412filt(3),ddsL443filt(3),ddsL490filt(3),ddsL510filt(3),ddsL531filt(3),ddsL555filt(3),ddsL620filt(3),ddsL670filt(3),ddsL681filt(3),ddsL709filt(3),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",155(F,","),(A,",",A))'
;[-1.1.b] Write macro average data to file----------------------------------------------------------------------------------

                endif

              endif else begin
;[-1.1]-------------------------




;[+1.2] L3 Mapped DDS (All data are in 2-D array form; Lat/Lon are 1-D arrays
              offset=KM2DEG(1.1, inLon(k), inLat(k))    ;Maximum distance from the in-situ location is 1.1km for PC (1km) products
              inDist=SQRT(offset[0]^2. + offset[1]^2.)


                mapped_x=n_elements(dds_data.Lon)
                mapped_y=n_elements(dds_data.Lat)
                subLon=fltarr(mapped_x, mapped_y)
                subLat=fltarr(mapped_x, mapped_y)
                for m=0,mapped_x-1 do for n=0,mapped_y-1 do begin
                    subLon(m,n)=dds_data.Lon(m)
                    subLat(m,n)=dds_data.Lat(n)
                endfor

                p=NearestPoint(subLon, subLat, inLon(k), inLat(k), MaxDist=inDist, nP=2)
                if(n_elements(p) GT 1) then begin
                    nPix=((p(1)-p(0))+1)*((p(3)-p(2))+1)
                    if(nPix GT 1) then begin
                        ddsCHLm=(ddsCHL2m=(ddsKD490m=(ddsTSMm=(ddsCDMm=(ddsBBPm=(ddsT865m=FLTARR(nPix)))))))    ;This is the set of pixels to be used for mean stats
                        ddsL412m=(ddsL443m=(ddsL490m=(ddsL510m=(ddsL531m=(ddsL555m=(ddsL620m=(ddsL670m=(ddsL681m=(ddsL709m=FLTARR(nPix))))))))))
                        ddsCHLf=(ddsCHL2f=(ddsKD490f=(ddsTSMf=(ddsCDMf=(ddsBBPf=(ddsT865f=MAKE_ARRAY(nPix,Value=1)))))))    ;FLAGS
                        ddsL412f=(ddsL443f=(ddsL490f=(ddsL510f=(ddsL531f=(ddsL555f=(ddsL620f=(ddsL670f=(ddsL681f=(ddsL709f=MAKE_ARRAY(nPix,Value=1))))))))))

                        ddsLon=REFORM(subLon(p(0):p(1),p(2):p(3)),nPix)
                        ddsLat=REFORM(subLat(p(0):p(1),p(2):p(3)),nPix)

                        if(TOTAL(strmatch(dds_tags,'CHL1_VALUE'))) then ddsCHLm=REFORM(dds_data.CHL1_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CHL1_FLAGS'))) then ddsCHLf=UINT(REFORM(dds_data.CHL1_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'CHL2_VALUE'))) then ddsCHL2m=REFORM(dds_data.CHL2_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CHL2_FLAGS'))) then ddsCHL2f=UINT(REFORM(dds_data.CHL2_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'KD490_VALUE'))) then ddsKD490m=REFORM(dds_data.KD490_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'KD490_FLAGS'))) then ddsKD490f=UINT(REFORM(dds_data.KD490_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'TSM_VALUE'))) then ddsTSMm=REFORM(dds_data.TSM_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'TSM_FLAGS'))) then ddsTSMf=UINT(REFORM(dds_data.TSM_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'CDM_VALUE'))) then ddsCDMm=REFORM(dds_data.CDM_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CDM_FLAGS'))) then ddsCDMf=UINT(REFORM(dds_data.CDM_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'BBP_VALUE'))) then ddsBBPm=REFORM(dds_data.BBP_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'BBP_FLAGS'))) then ddsBBPf=UINT(REFORM(dds_data.BBP_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'T865_VALUE'))) then ddsT865m=REFORM(dds_data.T865_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'T865_FLAGS'))) then ddsT865f=UINT(REFORM(dds_data.T865_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L412_VALUE'))) then ddsL412m=REFORM(dds_data.L412_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L412_FLAGS'))) then ddsL412f=UINT(REFORM(dds_data.L412_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L443_VALUE'))) then ddsL443m=REFORM(dds_data.L443_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L443_FLAGS'))) then ddsL443f=UINT(REFORM(dds_data.L443_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L490_VALUE'))) then ddsL490m=REFORM(dds_data.L490_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L490_FLAGS'))) then ddsL490f=UINT(REFORM(dds_data.L490_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L510_VALUE'))) then ddsL510m=REFORM(dds_data.L510_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L510_FLAGS'))) then ddsL510f=UINT(REFORM(dds_data.L510_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L531_VALUE'))) then ddsL531m=REFORM(dds_data.L531_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L531_FLAGS'))) then ddsL531f=UINT(REFORM(dds_data.L531_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L555_VALUE'))) then ddsL555m=REFORM(dds_data.L555_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L555_FLAGS'))) then ddsL555f=UINT(REFORM(dds_data.L555_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L620_VALUE'))) then ddsL620m=REFORM(dds_data.L620_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L620_FLAGS'))) then ddsL620f=UINT(REFORM(dds_data.L620_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L670_VALUE'))) then ddsL670m=REFORM(dds_data.L670_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L670_FLAGS'))) then ddsL670f=UINT(REFORM(dds_data.L670_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L681_VALUE'))) then ddsL681m=REFORM(dds_data.L681_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L681_FLAGS'))) then ddsL681f=UINT(REFORM(dds_data.L681_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L709_VALUE'))) then ddsL709m=REFORM(dds_data.L709_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L709_FLAGS'))) then ddsL709f=UINT(REFORM(dds_data.L709_FLAGS(p(0):p(1),p(2):p(3)),nPix))


;[+1.2.a] Write extracted pixel to file----------------------------------------------------------------------------------
                        for pp=0, nPix-1 do begin
                        printf,1,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLat(pp),ddsLon(pp),$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLm(pp),ddsCHL2m(pp),ddsKD490m(pp),ddsTSMm(pp),ddsCDMm(pp),ddsBBPm(pp),ddsT865m(pp),$
                            ddsL412m(pp),ddsL443m(pp),ddsL490m(pp),ddsL510m(pp),ddsL531m(pp),ddsL555m(pp),ddsL620m(pp),ddsL670m(pp),ddsL681m(pp),ddsL709m(pp),$
                            ddsCHLf(pp),ddsCHL2f(pp),ddsKD490f(pp),ddsTSMf(pp),ddsCDMf(pp),ddsBBPf(pp),ddsT865f(pp),$
                            ddsL412f(pp),ddsL443f(pp),ddsL490f(pp),ddsL510f(pp),ddsL531f(pp),ddsL555f(pp),ddsL620f(pp),ddsL670f(pp),ddsL681f(pp),ddsL709f(pp),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",36(F,","),18(A,","),A)'
                        endfor
;[-1.2.a] Write extracted pixel to file----------------------------------------------------------------------------------

;Initiate variable average, median, stdev for extracted pixels
                        ddsLonav=(ddsLatav=(ddsCHLav=(ddsCHL2av=(ddsKD490av=(ddsTSMav=(ddsCDMav=(ddsBBPav=(ddsT865av=!Values.F_NaN))))))))    ;Average of extracted pixels
                        ddsL412av=(ddsL443av=(ddsL490av=(ddsL510av=(ddsL531av=(ddsL555av=(ddsL620av=(ddsL670av=(ddsL681av=(ddsL709av=!Values.F_NaN)))))))))
                        ddsLonmd=(ddsLatmd=(ddsCHLmd=(ddsCHL2md=(ddsKD490md=(ddsTSMmd=(ddsCDMmd=(ddsBBPmd=(ddsT865md=!Values.F_NaN))))))))    ;Median of extracted pixels
                        ddsL412md=(ddsL443md=(ddsL490md=(ddsL510md=(ddsL531md=(ddsL555md=(ddsL620md=(ddsL670md=(ddsL681md=(ddsL709md=!Values.F_NaN)))))))))
                        ddsLonsd=(ddsLatsd=(ddsCHLsd=(ddsCHL2sd=(ddsKD490sd=(ddsTSMsd=(ddsCDMsd=(ddsBBPsd=(ddsT865sd=!Values.F_NaN))))))))    ;Standard deviation of extracted pixels
                        ddsL412sd=(ddsL443sd=(ddsL490sd=(ddsL510sd=(ddsL531sd=(ddsL555sd=(ddsL620sd=(ddsL670sd=(ddsL681sd=(ddsL709sd=!Values.F_NaN)))))))))

                        ddsCHLfilt=(ddsCHL2filt=(ddsKD490filt=(ddsTSMfilt=(ddsCDMfilt=(ddsBBPfilt=(ddsT865filt=MAKE_ARRAY(4,Value=!Values.F_NaN)))))))
                        ddsL412filt=(ddsL443filt=(ddsL490filt=(ddsL510filt=(ddsL531filt=(ddsL555filt=(ddsL620filt=(ddsL670filt=(ddsL681filt=(ddsL709filt=MAKE_ARRAY(4,Value=!Values.F_NaN))))))))))


                        c1_msk=(c2_msk=(kd_msk=(tsm_msk=(cdm_msk=(bbp_msk=(t865_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0))))))))
                        L412_msk=(L443_msk=(L490_msk=(L510_msk=(L531_msk=(L555_msk=(L620_msk=(L670_msk=(L681_msk=(L709_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0)))))))))))

                        for pp=0, nPix-1 do begin
                          flg=gcDDSFLAG2Name(ddsCHLf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4)) then c1_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCHL2f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LE 4)) then c2_msk(pp)=1   ;(df LT 4)
                          flg=gcDDSFLAG2Name(ddsKD490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4)) then kd_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsTSMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then tsm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCDMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then cdm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsBBPf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then bbp_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsT865f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then t865_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL412f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L412_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL443f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L443_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L490_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL510f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L510_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL531f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L531_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL555f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L555_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL620f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L620_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL670f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L670_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL681f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L681_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL709f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L709_msk(pp)=1
                        endfor

                        momddsLon=MOMENT(ddsLon,SDEV=ddsLonsd)
                        ddsLonav=momddsLon(0)
                        ;ddsLonmd=MEDIAN(ddsLon)
                        momddsLat=MOMENT(ddsLat,SDEV=ddsLatsd)
                        ddsLatav=momddsLat(0)
                        ;ddsLatmd=MEDIAN(ddsLat)

                        if(strcmp(input_file_tag,'LAC')) then NGP=13 else NGP=2
                        ;cvar=0.2    ;Set Coefficient of variation
                        if(total(c1_msk) GE 2) then begin
                            momddsCHL=MOMENT(ddsCHLm(where(c1_msk)),SDEV=ddsCHLsd)
                            ddsCHLav=momddsCHL(0)
                            ddsCHLmd=MEDIAN(ddsCHLm(where(c1_msk)))
                            if(total(c1_msk) GE NGP) then ddsCHLfilt=FILTERED_AVERAGE(ddsCHLm(where(c1_msk)),CV=cvar)
                        endif
                        if(total(c2_msk) GE 2) then begin
                            momddsCHL2=MOMENT(ddsCHL2m(where(c2_msk)),SDEV=ddsCHL2sd)
                            ddsCHL2av=momddsCHL2(0)
                            ddsCHL2md=MEDIAN(ddsCHL2m(where(c2_msk)))
                            if(total(c2_msk) GE NGP) then ddsCHL2filt=FILTERED_AVERAGE(ddsCHL2m(where(c2_msk)),CV=cvar)
                        endif
                        if(total(kd_msk) GE 2) then begin
                            momddsKD490=MOMENT(ddsKD490m(where(kd_msk)),SDEV=ddsKD490sd)
                            ddsKD490av=momddsKD490(0)
                            ddsKD490md=MEDIAN(ddsKD490m(where(kd_msk)))
                            if(total(kd_msk) GE NGP) then ddsKD490filt=FILTERED_AVERAGE(ddsKD490m(where(kd_msk)),CV=cvar)
                        endif
                        if(total(tsm_msk) GE 2) then begin
                            momddsTSM=MOMENT(ddsTSMm(where(tsm_msk)),SDEV=ddsTSMsd)
                            ddsTSMav=momddsTSM(0)
                            ddsTSMmd=MEDIAN(ddsTSMm(where(tsm_msk)))
                            if(total(tsm_msk) GE NGP) then ddsTSMfilt=FILTERED_AVERAGE(ddsTSMm(where(tsm_msk)),CV=cvar)
                        endif
                        if(total(cdm_msk) GE 2) then begin
                            momddsCDM=MOMENT(ddsCDMm(where(cdm_msk)),SDEV=ddsCDMsd)
                            ddsCDMav=momddsCDM(0)
                            ddsCDMmd=MEDIAN(ddsCDMm(where(cdm_msk)))
                            if(total(cdm_msk) GE NGP) then ddsCDMfilt=FILTERED_AVERAGE(ddsCDMm(where(cdm_msk)),CV=cvar)
                        endif
                        if(total(bbp_msk) GE 2) then begin
                            momddsBBP=MOMENT(ddsBBPm(where(bbp_msk)),SDEV=ddsBBPsd)
                            ddsBBPav=momddsBBP(0)
                            ddsBBPmd=MEDIAN(ddsBBPm(where(bbp_msk)))
                            if(total(bbp_msk) GE NGP) then ddsBBPfilt=FILTERED_AVERAGE(ddsBBPm(where(bbp_msk)),CV=cvar)
                        endif
                        if(total(t865_msk) GE 2) then begin
                            momddsT865=MOMENT(ddsT865m(where(t865_msk)),SDEV=ddsT865sd)
                            ddsT865av=momddsT865(0)
                            ddsT865md=MEDIAN(ddsT865m(where(t865_msk)))
                            if(total(t865_msk) GE NGP) then ddsT865filt=FILTERED_AVERAGE(ddsT865m(where(t865_msk)),CV=cvar)
                        endif
                        if(total(L412_msk) GE 2) then begin
                            momddsL412=MOMENT(ddsL412m(where(L412_msk)),SDEV=ddsL412sd)
                            ddsL412av=momddsL412(0)
                            ddsL412md=MEDIAN(ddsL412m(where(L412_msk)))
                            if(total(L412_msk) GE NGP) then ddsL412filt=FILTERED_AVERAGE(ddsL412m(where(L412_msk)),CV=cvar)
                        endif
                        if(total(L443_msk) GE 2) then begin
                            momddsL443=MOMENT(ddsL443m(where(L443_msk)),SDEV=ddsL443sd)
                            ddsL443av=momddsL443(0)
                            ddsL443md=MEDIAN(ddsL443m(where(L443_msk)))
                            if(total(L443_msk) GE NGP) then ddsL443filt=FILTERED_AVERAGE(ddsL443m(where(L443_msk)),CV=cvar)
                        endif
                        if(total(L490_msk) GE 2) then begin
                            momddsL490=MOMENT(ddsL490m(where(L490_msk)),SDEV=ddsL490sd)
                            ddsL490av=momddsL490(0)
                            ddsL490md=MEDIAN(ddsL490m(where(L490_msk)))
                            if(total(L490_msk) GE NGP) then ddsL490filt=FILTERED_AVERAGE(ddsL490m(where(L490_msk)),CV=cvar)
                        endif
                        if(total(L510_msk) GE 2) then begin
                            momddsL510=MOMENT(ddsL510m(where(L510_msk)),SDEV=ddsL510sd)
                            ddsL510av=momddsL510(0)
                            ddsL510md=MEDIAN(ddsL510m(where(L510_msk)))
                            if(total(L510_msk) GE NGP) then ddsL510filt=FILTERED_AVERAGE(ddsL510m(where(L510_msk)),CV=cvar)
                        endif
                        if(total(L531_msk) GE 2) then begin
                            momddsL531=MOMENT(ddsL531m(where(L531_msk)),SDEV=ddsL531sd)
                            ddsL531av=momddsL531(0)
                            ddsL531md=MEDIAN(ddsL531m(where(L531_msk)))
                            if(total(L531_msk) GE NGP) then ddsL531filt=FILTERED_AVERAGE(ddsL531m(where(L531_msk)),CV=cvar)
                        endif
                        if(total(L555_msk) GE 2) then begin
                            momddsL555=MOMENT(ddsL555m(where(L555_msk)),SDEV=ddsL555sd)
                            ddsL555av=momddsL555(0)
                            ddsL555md=MEDIAN(ddsL555m(where(L555_msk)))
                            if(total(L555_msk) GE NGP) then ddsL555filt=FILTERED_AVERAGE(ddsL555m(where(L555_msk)),CV=cvar)
                        endif
                        if(total(L620_msk) GE 2) then begin
                            momddsL620=MOMENT(ddsL620m(where(L620_msk)),SDEV=ddsL620sd)
                            ddsL620av=momddsL620(0)
                            ddsL620md=MEDIAN(ddsL620m(where(L620_msk)))
                            if(total(L620_msk) GE NGP) then ddsL620filt=FILTERED_AVERAGE(ddsL620m(where(L620_msk)),CV=cvar)
                        endif
                        if(total(L670_msk) GE 2) then begin
                            momddsL670=MOMENT(ddsL670m(where(L670_msk)),SDEV=ddsL670sd)
                            ddsL670av=momddsL670(0)
                            ddsL670md=MEDIAN(ddsL670m(where(L670_msk)))
                            if(total(L670_msk) GE NGP) then ddsL670filt=FILTERED_AVERAGE(ddsL670m(where(L670_msk)),CV=cvar)
                        endif
                        if(total(L681_msk) GE 2) then begin
                            momddsL681=MOMENT(ddsL681m(where(L681_msk)),SDEV=ddsL681sd)
                            ddsL681av=momddsL681(0)
                            ddsL681md=MEDIAN(ddsL681m(where(L681_msk)))
                            if(total(L681_msk) GE NGP) then ddsL681filt=FILTERED_AVERAGE(ddsL681m(where(L681_msk)),CV=cvar)
                        endif
                        if(total(L709_msk) GE 2) then begin
                            momddsL709=MOMENT(ddsL709m(where(L709_msk)),SDEV=ddsL709sd)
                            ddsL709av=momddsL709(0)
                            ddsL709md=MEDIAN(ddsL709m(where(L709_msk)))
                            if(total(L709_msk) GE NGP) then ddsL709filt=FILTERED_AVERAGE(ddsL709m(where(L709_msk)),CV=cvar)
                        endif


;[+1.2.b] Write macro average data to file----------------------------------------------------------------------------------
                        printf,2,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLatav,ddsLonav,$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLav,ddsCHL2av,ddsKD490av,ddsTSMav,ddsCDMav,ddsBBPav,ddsT865av,$
                            ddsL412av,ddsL443av,ddsL490av,ddsL510av,ddsL531av,ddsL555av,ddsL620av,ddsL670av,ddsL681av,ddsL709av,$
                            ddsCHLmd,ddsCHL2md,ddsKD490md,ddsTSMmd,ddsCDMmd,ddsBBPmd,ddsT865md,$
                            ddsL412md,ddsL443md,ddsL490md,ddsL510md,ddsL531md,ddsL555md,ddsL620md,ddsL670md,ddsL681md,ddsL709md,$
                            ddsCHLsd,ddsCHL2sd,ddsKD490sd,ddsTSMsd,ddsCDMsd,ddsBBPsd,ddsT865sd,$
                            ddsL412sd,ddsL443sd,ddsL490sd,ddsL510sd,ddsL531sd,ddsL555sd,ddsL620sd,ddsL670sd,ddsL681sd,ddsL709sd,$
                            total(c1_msk),total(c2_msk),total(kd_msk),total(tsm_msk),total(cdm_msk),total(bbp_msk),total(t865_msk),$
                            total(L412_msk),total(L443_msk),total(L490_msk),total(L510_msk),total(L531_msk),total(L555_msk),total(L620_msk),total(L670_msk),total(L681_msk),total(L709_msk),$
                            ddsCHLfilt(0),ddsCHL2filt(0),ddsKD490filt(0),ddsTSMfilt(0),ddsCDMfilt(0),ddsBBPfilt(0),ddsT865filt(0),$
                            ddsL412filt(0),ddsL443filt(0),ddsL490filt(0),ddsL510filt(0),ddsL531filt(0),ddsL555filt(0),ddsL620filt(0),ddsL670filt(0),ddsL681filt(0),ddsL709filt(0),$
                            ddsCHLfilt(1),ddsCHL2filt(1),ddsKD490filt(1),ddsTSMfilt(1),ddsCDMfilt(1),ddsBBPfilt(1),ddsT865filt(1),$
                            ddsL412filt(1),ddsL443filt(1),ddsL490filt(1),ddsL510filt(1),ddsL531filt(1),ddsL555filt(1),ddsL620filt(1),ddsL670filt(1),ddsL681filt(1),ddsL709filt(1),$
                            ddsCHLfilt(2),ddsCHL2filt(2),ddsKD490filt(2),ddsTSMfilt(2),ddsCDMfilt(2),ddsBBPfilt(2),ddsT865filt(2),$
                            ddsL412filt(2),ddsL443filt(2),ddsL490filt(2),ddsL510filt(2),ddsL531filt(2),ddsL555filt(2),ddsL620filt(2),ddsL670filt(2),ddsL681filt(2),ddsL709filt(2),$
                            ddsCHLfilt(3),ddsCHL2filt(3),ddsKD490filt(3),ddsTSMfilt(3),ddsCDMfilt(3),ddsBBPfilt(3),ddsT865filt(3),$
                            ddsL412filt(3),ddsL443filt(3),ddsL490filt(3),ddsL510filt(3),ddsL531filt(3),ddsL555filt(3),ddsL620filt(3),ddsL670filt(3),ddsL681filt(3),ddsL709filt(3),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",155(F,","),(A,",",A))'
;[-1.2.b] Write macro average data to file----------------------------------------------------------------------------------

                    endif   ;if(nPix GT 1) then begin
                endif   ;(n_elements(p) GT 1) then begin
              endelse
;[-1.2]----------------

            endfor   ;for k=0,nr-1 do begin
         endif else $  ;if(nr GT 0) then begin
         print,ddsFile+" matches with "+string(nr)+" in-situ record(s) for same day."
       endfor   ;for i=0,nSWF-1 do begin
    endif   ;if((Sensor EQ 1 or Sensor EQ 4) and nSWF GT 0) then begin

;[-1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END SEAWIFS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;[+2]. MODIS

    if((Sensor EQ 2 or Sensor EQ 4) and nMOD GT 0) then begin
       for i=0,nMOD-1 do begin
        ddsFile=FILE_BASENAME(ddsMODFiles(i))
        ddsYear=FIX(strmid(ddsFile,4,4))
        ddsMonth=FIX(strmid(ddsFile,8,2))
        ddsDay=FIX(strmid(ddsFile,10,2))
        ddsYearSDY=1000L*ddsYear+sdy(ddsDay,ddsMonth,ddsYear)
        ddsYMD=strmid(ddsFile,4,8)
        ddsHour=FIX(strmid(ddsFile,13,2))
        ddsMinute=FIX(strmid(ddsFile,15,2))
        ddsTime=ddsHour + (ddsMinute/60.)



        day_match=where(insituYearSDY EQ ddsYearSDY, nr)
        ;For time-series type in-situ pick only the closest in-situ record
        if(keyword_set(time_series)) then begin
            if(nr GT 1) then begin
            tDiff=abs(ddsTime - insituTime(day_match))
            mintDiff=where(tDiff EQ min(tDiff))
            day_match=day_match(mintDiff)
            nr=1
            endif
        endif
        if(nr GT 0) then begin
            print,ddsFile+" matches with "+string(nr)+" in-situ record(s) for same day."
            ;print,insitu_data.ID(day_match)
            inLon=insitu_data.Longitude(day_match)
            inLat=insitu_data.Latitude(day_match)
            inYearSDY=insituYearSDY(day_match)


            ;read_netCDF, ddsFile[0], dds_data, dds_attr, status
            read_netCDF, ddsMODFiles(i), dds_data, dds_attr, status
            dds_tags=TAG_NAMES(dds_data)    ;available variable names in the DDS file

            time_info=dds_attr[where(stregex(dds_attr,'start_time =') NE -1)] ;DDS Start time
            dds_time=strmid(time_info,stregex(time_info,'[0-9]'),100)
            dds_Hour=FIX(strmid(dds_time[0],9,2))
            dds_Minute=FIX(strmid(dds_time[0],11,2))
            ;print,dds_time

;Treat the match-up depending on the input_file type LAC=1.1km and GAC=4.4km effective resolution
            input_file_info=dds_attr[where(stregex(dds_attr,'input_files =') NE -1)] ;Input File
            split_string=strsplit(input_file_info,'_',/extract)
            ;input_file_tag=split_string[2] ;GAC or MLAC or LAC
            if((total(strmatch(split_string,'MLAC')) GE 1) or (total(strmatch(split_string,'LAC')) GE 1)) then input_file_tag='LAC'
            if((total(strmatch(split_string,'GAC')) GE 1) and (total(strmatch(split_string,'MLAC')) EQ 0) and (total(strmatch(split_string,'LAC')) EQ 0)) then input_file_tag='GAC'



;MAIN LOOP
            for k=0,nr-1 do begin
            ;print,inLon(k),inYearSDY(k),ddsYearSDY


              if(KEYWORD_SET(l3b_dds)) then begin
;[+2.1] L3 Binned DDS (All data are in 1-D array form)

              offset=KM2DEG(5.0, inLon(k), inLat(k))    ;Maximum distance from the in-situ location is 5km for ISIN (4km) products
              inDist=SQRT(offset[0]^2. + offset[1]^2.)

                row_info=dds_attr[where(stregex(dds_attr,'first_row =') NE -1)]
                first_row=LONG(strmid(row_info,stregex(row_info,'[0-9]'),100))
                lat_step_info=dds_attr[where(stregex(dds_attr,'lat_step =') NE -1)]
                lat_step=DOUBLE(strmid(lat_step_info,stregex(lat_step_info,'[0-9]'),100))

                idx=dds_data.row-first_row[0]
                ddsLat=dds_data.center_lat(idx)
                ddsLon=dds_data.center_lon(idx) + dds_data.col*dds_data.lon_step(idx)

                p=NearestPoint(ddsLon, ddsLat, inLon(k), inLat(k), MaxDist=inDist, SR=inDist, nP=9)
                nPix=n_elements(p)
                if(nPix GT 1) then begin

                    ddsCHLm=(ddsCHL2m=(ddsKD490m=(ddsTSMm=(ddsCDMm=(ddsBBPm=(ddsT865m=FLTARR(nPix)))))))    ;MEAN
                    ddsL412m=(ddsL443m=(ddsL490m=(ddsL510m=(ddsL531m=(ddsL555m=(ddsL620m=(ddsL670m=(ddsL681m=(ddsL709m=FLTARR(nPix))))))))))
                    ddsCHLs=(ddsCHL2s=(ddsKD490s=(ddsTSMs=(ddsCDMs=(ddsBBPs=(ddsT865s=FLTARR(nPix)))))))    ;STDEV
                    ddsL412s=(ddsL443s=(ddsL490s=(ddsL510s=(ddsL531s=(ddsL555s=(ddsL620s=(ddsL670s=(ddsL681s=(ddsL709s=FLTARR(nPix))))))))))
                    ddsCHLn=(ddsCHL2n=(ddsKD490n=(ddsTSMn=(ddsCDMn=(ddsBBPn=(ddsT865n=FLTARR(nPix)))))))    ;COUNT
                    ddsL412n=(ddsL443n=(ddsL490n=(ddsL510n=(ddsL531n=(ddsL555n=(ddsL620n=(ddsL670n=(ddsL681n=(ddsL709n=FLTARR(nPix))))))))))
                    ddsCHLw=(ddsCHL2w=(ddsKD490w=(ddsTSMw=(ddsCDMw=(ddsBBPw=(ddsT865w=FLTARR(nPix)))))))    ;WEIGHT
                    ddsL412w=(ddsL443w=(ddsL490w=(ddsL510w=(ddsL531w=(ddsL555w=(ddsL620w=(ddsL670w=(ddsL681w=(ddsL709w=FLTARR(nPix))))))))))
                    ddsCHLf=(ddsCHL2f=(ddsKD490f=(ddsTSMf=(ddsCDMf=(ddsBBPf=(ddsT865f=FLTARR(nPix)))))))    ;FLAGS
                    ddsL412f=(ddsL443f=(ddsL490f=(ddsL510f=(ddsL531f=(ddsL555f=(ddsL620f=(ddsL670f=(ddsL681f=(ddsL709f=FLTARR(nPix))))))))))
                    ddsCHLe=(ddsCHL2e=(ddsKD490e=(ddsTSMe=(ddsCDMe=(ddsBBPe=(ddsT865e=FLTARR(nPix)))))))    ;ERROR
                    ddsL412e=(ddsL443e=(ddsL490e=(ddsL510e=(ddsL531e=(ddsL555e=(ddsL620e=(ddsL670e=(ddsL681e=(ddsL709e=FLTARR(nPix))))))))))
                    ddsLat=ddsLat(p)
                    ddsLon=ddsLon(p)
                    ddsCHLcv=(ddsCHL2cv=(ddsKD490cv=(ddsTSMcv=(ddsCDMcv=(ddsBBPcv=(ddsT865cv=MAKE_ARRAY(nPix,Value=1.)))))))    ;COEFFICIENT OF VARIATION
                    ddsL412cv=(ddsL443cv=(ddsL490cv=(ddsL510cv=(ddsL531cv=(ddsL555cv=(ddsL620cv=(ddsL670cv=(ddsL681cv=(ddsL709cv=MAKE_ARRAY(nPix,Value=1.))))))))))


                    if(TOTAL(strmatch(dds_tags,'CHL1_MEAN'))) then ddsCHLm=dds_data.CHL1_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_STDEV'))) then ddsCHLs=dds_data.CHL1_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_COUNT'))) then ddsCHLn=UINT(dds_data.CHL1_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CHL1_WEIGHT'))) then ddsCHLw=dds_data.CHL1_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_FLAGS'))) then ddsCHLf=UINT(dds_data.CHL1_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CHL1_ERROR'))) then ddsCHLe=UINT(dds_data.CHL1_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'CHL2_MEAN'))) then ddsCHL2m=dds_data.CHL2_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_STDEV'))) then ddsCHL2s=dds_data.CHL2_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_COUNT'))) then ddsCHL2n=UINT(dds_data.CHL2_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CHL2_WEIGHT'))) then ddsCHL2w=dds_data.CHL2_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_FLAGS'))) then ddsCHL2f=UINT(dds_data.CHL2_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CHL2_ERROR'))) then ddsCHL2e=UINT(dds_data.CHL2_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'KD490_MEAN'))) then ddsKD490m=dds_data.KD490_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_STDEV'))) then ddsKD490s=dds_data.KD490_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_COUNT'))) then ddsKD490n=UINT(dds_data.KD490_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'KD490_WEIGHT'))) then ddsKD490w=dds_data.KD490_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_FLAGS'))) then ddsKD490f=UINT(dds_data.KD490_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'KD490_ERROR'))) then ddsKD490e=UINT(dds_data.KD490_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'TSM_MEAN'))) then ddsTSMm=dds_data.TSM_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_STDEV'))) then ddsTSMs=dds_data.TSM_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_COUNT'))) then ddsTSMn=UINT(dds_data.TSM_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'TSM_WEIGHT'))) then ddsTSMw=dds_data.TSM_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_FLAGS'))) then ddsTSMf=UINT(dds_data.TSM_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'TSM_ERROR'))) then ddsTSMe=UINT(dds_data.TSM_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'CDM_MEAN'))) then ddsCDMm=dds_data.CDM_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_STDEV'))) then ddsCDMs=dds_data.CDM_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_COUNT'))) then ddsCDMn=UINT(dds_data.CDM_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CDM_WEIGHT'))) then ddsCDMw=dds_data.CDM_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_FLAGS'))) then ddsCDMf=UINT(dds_data.CDM_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CDM_ERROR'))) then ddsCDMe=UINT(dds_data.CDM_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'BBP_MEAN'))) then ddsBBPm=dds_data.BBP_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_STDEV'))) then ddsBBPs=dds_data.BBP_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_COUNT'))) then ddsBBPn=UINT(dds_data.BBP_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'BBP_WEIGHT'))) then ddsBBPw=dds_data.BBP_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_FLAGS'))) then ddsBBPf=UINT(dds_data.BBP_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'BBP_ERROR'))) then ddsBBPe=UINT(dds_data.BBP_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'T865_MEAN'))) then ddsT865m=dds_data.T865_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'T865_STDEV'))) then ddsT865s=dds_data.T865_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'T865_COUNT'))) then ddsT865n=UINT(dds_data.T865_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'T865_WEIGHT'))) then ddsT865w=dds_data.T865_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'T865_FLAGS'))) then ddsT865f=UINT(dds_data.T865_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'T865_ERROR'))) then ddsT865e=UINT(dds_data.T865_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L412_MEAN'))) then ddsL412m=dds_data.L412_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L412_STDEV'))) then ddsL412s=dds_data.L412_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L412_COUNT'))) then ddsL412n=UINT(dds_data.L412_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L412_WEIGHT'))) then ddsL412w=dds_data.L412_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L412_FLAGS'))) then ddsL412f=UINT(dds_data.L412_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L412_ERROR'))) then ddsL412e=UINT(dds_data.L412_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L443_MEAN'))) then ddsL443m=dds_data.L443_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L443_STDEV'))) then ddsL443s=dds_data.L443_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L443_COUNT'))) then ddsL443n=UINT(dds_data.L443_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L443_WEIGHT'))) then ddsL443w=dds_data.L443_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L443_FLAGS'))) then ddsL443f=UINT(dds_data.L443_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L443_ERROR'))) then ddsL443e=UINT(dds_data.L443_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L490_MEAN'))) then ddsL490m=dds_data.L490_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L490_STDEV'))) then ddsL490s=dds_data.L490_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L490_COUNT'))) then ddsL490n=UINT(dds_data.L490_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L490_WEIGHT'))) then ddsL490w=dds_data.L490_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L490_FLAGS'))) then ddsL490f=UINT(dds_data.L490_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L490_ERROR'))) then ddsL490e=UINT(dds_data.L490_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L510_MEAN'))) then ddsL510m=dds_data.L510_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L510_STDEV'))) then ddsL510s=dds_data.L510_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L510_COUNT'))) then ddsL510n=UINT(dds_data.L510_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L510_WEIGHT'))) then ddsL510w=dds_data.L510_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L510_FLAGS'))) then ddsL510f=UINT(dds_data.L510_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L510_ERROR'))) then ddsL510e=UINT(dds_data.L510_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L531_MEAN'))) then ddsL531m=dds_data.L531_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L531_STDEV'))) then ddsL531s=dds_data.L531_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L531_COUNT'))) then ddsL531n=UINT(dds_data.L531_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L531_WEIGHT'))) then ddsL531w=dds_data.L531_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L531_FLAGS'))) then ddsL531f=UINT(dds_data.L531_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L531_ERROR'))) then ddsL531e=UINT(dds_data.L531_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L555_MEAN'))) then ddsL555m=dds_data.L555_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L555_STDEV'))) then ddsL555s=dds_data.L555_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L555_COUNT'))) then ddsL555n=UINT(dds_data.L555_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L555_WEIGHT'))) then ddsL555w=dds_data.L555_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L555_FLAGS'))) then ddsL555f=UINT(dds_data.L555_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L555_ERROR'))) then ddsL555e=UINT(dds_data.L555_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L620_MEAN'))) then ddsL620m=dds_data.L620_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L620_STDEV'))) then ddsL620s=dds_data.L620_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L620_COUNT'))) then ddsL620n=UINT(dds_data.L620_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L620_WEIGHT'))) then ddsL620w=dds_data.L620_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L620_FLAGS'))) then ddsL620f=UINT(dds_data.L620_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L620_ERROR'))) then ddsL620e=UINT(dds_data.L620_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L670_MEAN'))) then ddsL670m=dds_data.L670_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L670_STDEV'))) then ddsL670s=dds_data.L670_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L670_COUNT'))) then ddsL670n=UINT(dds_data.L670_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L670_WEIGHT'))) then ddsL670w=dds_data.L670_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L670_FLAGS'))) then ddsL670f=UINT(dds_data.L670_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L670_ERROR'))) then ddsL670e=UINT(dds_data.L670_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L681_MEAN'))) then ddsL681m=dds_data.L681_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L681_STDEV'))) then ddsL681s=dds_data.L681_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L681_COUNT'))) then ddsL681n=UINT(dds_data.L681_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L681_WEIGHT'))) then ddsL681w=dds_data.L681_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L681_FLAGS'))) then ddsL681f=UINT(dds_data.L681_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L681_ERROR'))) then ddsL681e=UINT(dds_data.L681_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L709_MEAN'))) then ddsL709m=dds_data.L709_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L709_STDEV'))) then ddsL709s=dds_data.L709_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L709_COUNT'))) then ddsL709n=UINT(dds_data.L709_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L709_WEIGHT'))) then ddsL709w=dds_data.L709_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L709_FLAGS'))) then ddsL709f=UINT(dds_data.L709_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L709_ERROR'))) then ddsL709e=UINT(dds_data.L709_ERROR(p))


;[+2.1.a] Write extracted pixel to file----------------------------------------------------------------------------------
                    for pp=0, nPix-1 do begin
                     printf,4,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                        inLat(k),inLon(k),dds_time,ddsLat(pp),ddsLon(pp),$
                        insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                        insitu_data.T865(day_match(k)),$
                        insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                        insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                        ddsCHLm(pp),ddsCHL2m(pp),ddsKD490m(pp),ddsTSMm(pp),ddsCDMm(pp),ddsBBPm(pp),ddsT865m(pp),$
                        ddsL412m(pp),ddsL443m(pp),ddsL490m(pp),ddsL510m(pp),ddsL531m(pp),ddsL555m(pp),ddsL620m(pp),ddsL670m(pp),ddsL681m(pp),ddsL709m(pp),$
                        ddsCHLf(pp),ddsCHL2f(pp),ddsKD490f(pp),ddsTSMf(pp),ddsCDMf(pp),ddsBBPf(pp),ddsT865f(pp),$
                        ddsL412f(pp),ddsL443f(pp),ddsL490f(pp),ddsL510f(pp),ddsL531f(pp),ddsL555f(pp),ddsL620f(pp),ddsL670f(pp),ddsL681f(pp),ddsL709f(pp),$
                        ddsFile[0],input_file_tag,$
                        FORMAT='(2(A,","),2(F,","),A,",",36(F,","),18(A,","),A)'
                    endfor
;[-2.1.a] Write extracted pixel to file----------------------------------------------------------------------------------


;Initiate variable average, median, stdev for extracted pixels
                        ddsLonav=(ddsLatav=(ddsCHLav=(ddsCHL2av=(ddsKD490av=(ddsTSMav=(ddsCDMav=(ddsBBPav=(ddsT865av=!Values.F_NaN))))))))    ;Average of extracted pixels
                        ddsL412av=(ddsL443av=(ddsL490av=(ddsL510av=(ddsL531av=(ddsL555av=(ddsL620av=(ddsL670av=(ddsL681av=(ddsL709av=!Values.F_NaN)))))))))
                        ddsLonmd=(ddsLatmd=(ddsCHLmd=(ddsCHL2md=(ddsKD490md=(ddsTSMmd=(ddsCDMmd=(ddsBBPmd=(ddsT865md=!Values.F_NaN))))))))    ;Median of extracted pixels
                        ddsL412md=(ddsL443md=(ddsL490md=(ddsL510md=(ddsL531md=(ddsL555md=(ddsL620md=(ddsL670md=(ddsL681md=(ddsL709md=!Values.F_NaN)))))))))
                        ddsLonsd=(ddsLatsd=(ddsCHLsd=(ddsCHL2sd=(ddsKD490sd=(ddsTSMsd=(ddsCDMsd=(ddsBBPsd=(ddsT865sd=!Values.F_NaN))))))))    ;Standard deviation of extracted pixels
                        ddsL412sd=(ddsL443sd=(ddsL490sd=(ddsL510sd=(ddsL531sd=(ddsL555sd=(ddsL620sd=(ddsL670sd=(ddsL681sd=(ddsL709sd=!Values.F_NaN)))))))))

                        ddsCHLfilt=(ddsCHL2filt=(ddsKD490filt=(ddsTSMfilt=(ddsCDMfilt=(ddsBBPfilt=(ddsT865filt=MAKE_ARRAY(4,Value=!Values.F_NaN)))))))
                        ddsL412filt=(ddsL443filt=(ddsL490filt=(ddsL510filt=(ddsL531filt=(ddsL555filt=(ddsL620filt=(ddsL670filt=(ddsL681filt=(ddsL709filt=MAKE_ARRAY(4,Value=!Values.F_NaN))))))))))


                        c1_msk=(c2_msk=(kd_msk=(tsm_msk=(cdm_msk=(bbp_msk=(t865_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0))))))))
                        L412_msk=(L443_msk=(L490_msk=(L510_msk=(L531_msk=(L555_msk=(L620_msk=(L670_msk=(L681_msk=(L709_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0)))))))))))

                        for pp=0, nPix-1 do begin
                          if(ddsCHLs(pp) GT 0. and ddsCHLm(pp) GT 0.) then ddsCHLcv(pp)=ddsCHLs(pp)/ddsCHLm(pp)
                          if(ddsCHL2s(pp) GT 0. and ddsCHL2m(pp) GT 0.) then ddsCHL2cv(pp)=ddsCHL2s(pp)/ddsCHL2m(pp)
                          if(ddsKD490s(pp) GT 0. and ddsKD490m(pp) GT 0.) then ddsKD490cv(pp)=ddsKD490s(pp)/ddsKD490m(pp)
                          if(ddsTSMs(pp) GT 0. and ddsTSMm(pp) GT 0.) then ddsTSMcv(pp)=ddsTSMs(pp)/ddsTSMm(pp)
                          if(ddsCDMs(pp) GT 0. and ddsCDMm(pp) GT 0.) then ddsCDMcv(pp)=ddsCDMs(pp)/ddsCDMm(pp)
                          if(ddsBBPs(pp) GT 0. and ddsBBPm(pp) GT 0.) then ddsBBPcv(pp)=ddsBBPs(pp)/ddsBBPm(pp)
                          if(ddsT865s(pp) GT 0. and ddsT865m(pp) GT 0.) then ddsT865cv(pp)=ddsT865s(pp)/ddsT865m(pp)
                          if(ddsL412s(pp) GT 0. and ddsL412m(pp) GT 0.) then ddsL412cv(pp)=ddsL412s(pp)/ddsL412m(pp)
                          if(ddsL443s(pp) GT 0. and ddsL443m(pp) GT 0.) then ddsL443cv(pp)=ddsL443s(pp)/ddsL443m(pp)
                          if(ddsL490s(pp) GT 0. and ddsL490m(pp) GT 0.) then ddsL490cv(pp)=ddsL490s(pp)/ddsL490m(pp)
                          if(ddsL510s(pp) GT 0. and ddsL510m(pp) GT 0.) then ddsL510cv(pp)=ddsL510s(pp)/ddsL510m(pp)
                          if(ddsL531s(pp) GT 0. and ddsL531m(pp) GT 0.) then ddsL531cv(pp)=ddsL531s(pp)/ddsL531m(pp)
                          if(ddsL555s(pp) GT 0. and ddsL555m(pp) GT 0.) then ddsL555cv(pp)=ddsL555s(pp)/ddsL555m(pp)
                          if(ddsL620s(pp) GT 0. and ddsL620m(pp) GT 0.) then ddsL620cv(pp)=ddsL620s(pp)/ddsL620m(pp)
                          if(ddsL670s(pp) GT 0. and ddsL670m(pp) GT 0.) then ddsL670cv(pp)=ddsL670s(pp)/ddsL670m(pp)
                          if(ddsL681s(pp) GT 0. and ddsL681m(pp) GT 0.) then ddsL681cv(pp)=ddsL681s(pp)/ddsL681m(pp)
                          if(ddsL709s(pp) GT 0. and ddsL709m(pp) GT 0.) then ddsL709cv(pp)=ddsL709s(pp)/ddsL709m(pp)


                          flg=gcDDSFLAG2Name(ddsCHLf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4) and (ddsCHLcv(pp) LT cvar)) then c1_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCHL2f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LE 4) and (ddsCHL2cv(pp) LT cvar)) then c2_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsKD490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4) and (ddsKD490cv(pp) LT cvar)) then kd_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsTSMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsTSMcv(pp) LT cvar)) then tsm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCDMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsCDMcv(pp) LT cvar)) then cdm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsBBPf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsBBPcv(pp) LT cvar)) then bbp_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsT865f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsT865cv(pp) LT cvar)) then t865_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL412f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL412cv(pp) LT cvar)) then L412_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL443f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL443cv(pp) LT cvar)) then L443_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL490cv(pp) LT cvar)) then L490_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL510f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL510cv(pp) LT cvar)) then L510_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL531f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL531cv(pp) LT cvar)) then L531_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL555f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL555cv(pp) LT cvar)) then L555_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL620f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL620cv(pp) LT cvar)) then L620_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL670f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL670cv(pp) LT cvar)) then L670_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL681f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL681cv(pp) LT cvar)) then L681_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL709f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL709cv(pp) LT cvar)) then L709_msk(pp)=1
                        endfor

                        momddsLon=MOMENT(ddsLon,SDEV=ddsLonsd)
                        ddsLonav=momddsLon(0)
                        ;ddsLonmd=MEDIAN(ddsLon)
                        momddsLat=MOMENT(ddsLat,SDEV=ddsLatsd)
                        ddsLatav=momddsLat(0)
                        ;ddsLatmd=MEDIAN(ddsLat)


                        ;if(strcmp(input_file_tag,'LAC')) then NGP=5 else NGP=2
                        NGP=5   ;For binned files Replica is not an issue as flux conservative method is implemented.
                        if(total(c1_msk) GE 2) then begin
                            momddsCHL=MOMENT(ddsCHLm(where(c1_msk)),SDEV=ddsCHLsd)
                            ddsCHLav=momddsCHL(0)
                            ddsCHLmd=MEDIAN(ddsCHLm(where(c1_msk)))
                            if(total(c1_msk) GE NGP) then ddsCHLfilt=FILTERED_AVERAGE(ddsCHLm(where(c1_msk)),CV=cvar)
                        endif
                        if(total(c2_msk) GE 2) then begin
                            momddsCHL2=MOMENT(ddsCHL2m(where(c2_msk)),SDEV=ddsCHL2sd)
                            ddsCHL2av=momddsCHL2(0)
                            ddsCHL2md=MEDIAN(ddsCHL2m(where(c2_msk)))
                            if(total(c2_msk) GE NGP) then ddsCHL2filt=FILTERED_AVERAGE(ddsCHL2m(where(c2_msk)),CV=cvar)
                        endif
                        if(total(kd_msk) GE 2) then begin
                            momddsKD490=MOMENT(ddsKD490m(where(kd_msk)),SDEV=ddsKD490sd)
                            ddsKD490av=momddsKD490(0)
                            ddsKD490md=MEDIAN(ddsKD490m(where(kd_msk)))
                            if(total(kd_msk) GE NGP) then ddsKD490filt=FILTERED_AVERAGE(ddsKD490m(where(kd_msk)),CV=cvar)
                        endif
                        if(total(tsm_msk) GE 2) then begin
                            momddsTSM=MOMENT(ddsTSMm(where(tsm_msk)),SDEV=ddsTSMsd)
                            ddsTSMav=momddsTSM(0)
                            ddsTSMmd=MEDIAN(ddsTSMm(where(tsm_msk)))
                            if(total(tsm_msk) GE NGP) then ddsTSMfilt=FILTERED_AVERAGE(ddsTSMm(where(tsm_msk)),CV=cvar)
                        endif
                        if(total(cdm_msk) GE 2) then begin
                            momddsCDM=MOMENT(ddsCDMm(where(cdm_msk)),SDEV=ddsCDMsd)
                            ddsCDMav=momddsCDM(0)
                            ddsCDMmd=MEDIAN(ddsCDMm(where(cdm_msk)))
                            if(total(cdm_msk) GE NGP) then ddsCDMfilt=FILTERED_AVERAGE(ddsCDMm(where(cdm_msk)),CV=cvar)
                        endif
                        if(total(bbp_msk) GE 2) then begin
                            momddsBBP=MOMENT(ddsBBPm(where(bbp_msk)),SDEV=ddsBBPsd)
                            ddsBBPav=momddsBBP(0)
                            ddsBBPmd=MEDIAN(ddsBBPm(where(bbp_msk)))
                            if(total(bbp_msk) GE NGP) then ddsBBPfilt=FILTERED_AVERAGE(ddsBBPm(where(bbp_msk)),CV=cvar)
                        endif
                        if(total(t865_msk) GE 2) then begin
                            momddsT865=MOMENT(ddsT865m(where(t865_msk)),SDEV=ddsT865sd)
                            ddsT865av=momddsT865(0)
                            ddsT865md=MEDIAN(ddsT865m(where(t865_msk)))
                            if(total(t865_msk) GE NGP) then ddsT865filt=FILTERED_AVERAGE(ddsT865m(where(t865_msk)),CV=cvar)
                        endif
                        if(total(L412_msk) GE 2) then begin
                            momddsL412=MOMENT(ddsL412m(where(L412_msk)),SDEV=ddsL412sd)
                            ddsL412av=momddsL412(0)
                            ddsL412md=MEDIAN(ddsL412m(where(L412_msk)))
                            if(total(L412_msk) GE NGP) then ddsL412filt=FILTERED_AVERAGE(ddsL412m(where(L412_msk)),CV=cvar)
                        endif
                        if(total(L443_msk) GE 2) then begin
                            momddsL443=MOMENT(ddsL443m(where(L443_msk)),SDEV=ddsL443sd)
                            ddsL443av=momddsL443(0)
                            ddsL443md=MEDIAN(ddsL443m(where(L443_msk)))
                            if(total(L443_msk) GE NGP) then ddsL443filt=FILTERED_AVERAGE(ddsL443m(where(L443_msk)),CV=cvar)
                        endif
                        if(total(L490_msk) GE 2) then begin
                            momddsL490=MOMENT(ddsL490m(where(L490_msk)),SDEV=ddsL490sd)
                            ddsL490av=momddsL490(0)
                            ddsL490md=MEDIAN(ddsL490m(where(L490_msk)))
                            if(total(L490_msk) GE NGP) then ddsL490filt=FILTERED_AVERAGE(ddsL490m(where(L490_msk)),CV=cvar)
                        endif
                        if(total(L510_msk) GE 2) then begin
                            momddsL510=MOMENT(ddsL510m(where(L510_msk)),SDEV=ddsL510sd)
                            ddsL510av=momddsL510(0)
                            ddsL510md=MEDIAN(ddsL510m(where(L510_msk)))
                            if(total(L510_msk) GE NGP) then ddsL510filt=FILTERED_AVERAGE(ddsL510m(where(L510_msk)),CV=cvar)
                        endif
                        if(total(L531_msk) GE 2) then begin
                            momddsL531=MOMENT(ddsL531m(where(L531_msk)),SDEV=ddsL531sd)
                            ddsL531av=momddsL531(0)
                            ddsL531md=MEDIAN(ddsL531m(where(L531_msk)))
                            if(total(L531_msk) GE NGP) then ddsL531filt=FILTERED_AVERAGE(ddsL531m(where(L531_msk)),CV=cvar)
                        endif
                        if(total(L555_msk) GE 2) then begin
                            momddsL555=MOMENT(ddsL555m(where(L555_msk)),SDEV=ddsL555sd)
                            ddsL555av=momddsL555(0)
                            ddsL555md=MEDIAN(ddsL555m(where(L555_msk)))
                            if(total(L555_msk) GE NGP) then ddsL555filt=FILTERED_AVERAGE(ddsL555m(where(L555_msk)),CV=cvar)
                        endif
                        if(total(L620_msk) GE 2) then begin
                            momddsL620=MOMENT(ddsL620m(where(L620_msk)),SDEV=ddsL620sd)
                            ddsL620av=momddsL620(0)
                            ddsL620md=MEDIAN(ddsL620m(where(L620_msk)))
                            if(total(L620_msk) GE NGP) then ddsL620filt=FILTERED_AVERAGE(ddsL620m(where(L620_msk)),CV=cvar)
                        endif
                        if(total(L670_msk) GE 2) then begin
                            momddsL670=MOMENT(ddsL670m(where(L670_msk)),SDEV=ddsL670sd)
                            ddsL670av=momddsL670(0)
                            ddsL670md=MEDIAN(ddsL670m(where(L670_msk)))
                            if(total(L670_msk) GE NGP) then ddsL670filt=FILTERED_AVERAGE(ddsL670m(where(L670_msk)),CV=cvar)
                        endif
                        if(total(L681_msk) GE 2) then begin
                            momddsL681=MOMENT(ddsL681m(where(L681_msk)),SDEV=ddsL681sd)
                            ddsL681av=momddsL681(0)
                            ddsL681md=MEDIAN(ddsL681m(where(L681_msk)))
                            if(total(L681_msk) GE NGP) then ddsL681filt=FILTERED_AVERAGE(ddsL681m(where(L681_msk)),CV=cvar)
                        endif
                        if(total(L709_msk) GE 2) then begin
                            momddsL709=MOMENT(ddsL709m(where(L709_msk)),SDEV=ddsL709sd)
                            ddsL709av=momddsL709(0)
                            ddsL709md=MEDIAN(ddsL709m(where(L709_msk)))
                            if(total(L709_msk) GE NGP) then ddsL709filt=FILTERED_AVERAGE(ddsL709m(where(L709_msk)),CV=cvar)
                        endif


;[+2.1.b] Write macro average data to file----------------------------------------------------------------------------------
                        printf,5,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLatav,ddsLonav,$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLav,ddsCHL2av,ddsKD490av,ddsTSMav,ddsCDMav,ddsBBPav,ddsT865av,$
                            ddsL412av,ddsL443av,ddsL490av,ddsL510av,ddsL531av,ddsL555av,ddsL620av,ddsL670av,ddsL681av,ddsL709av,$
                            ddsCHLmd,ddsCHL2md,ddsKD490md,ddsTSMmd,ddsCDMmd,ddsBBPmd,ddsT865md,$
                            ddsL412md,ddsL443md,ddsL490md,ddsL510md,ddsL531md,ddsL555md,ddsL620md,ddsL670md,ddsL681md,ddsL709md,$
                            ddsCHLsd,ddsCHL2sd,ddsKD490sd,ddsTSMsd,ddsCDMsd,ddsBBPsd,ddsT865sd,$
                            ddsL412sd,ddsL443sd,ddsL490sd,ddsL510sd,ddsL531sd,ddsL555sd,ddsL620sd,ddsL670sd,ddsL681sd,ddsL709sd,$
                            total(c1_msk),total(c2_msk),total(kd_msk),total(tsm_msk),total(cdm_msk),total(bbp_msk),total(t865_msk),$
                            total(L412_msk),total(L443_msk),total(L490_msk),total(L510_msk),total(L531_msk),total(L555_msk),total(L620_msk),total(L670_msk),total(L681_msk),total(L709_msk),$
                            ddsCHLfilt(0),ddsCHL2filt(0),ddsKD490filt(0),ddsTSMfilt(0),ddsCDMfilt(0),ddsBBPfilt(0),ddsT865filt(0),$
                            ddsL412filt(0),ddsL443filt(0),ddsL490filt(0),ddsL510filt(0),ddsL531filt(0),ddsL555filt(0),ddsL620filt(0),ddsL670filt(0),ddsL681filt(0),ddsL709filt(0),$
                            ddsCHLfilt(1),ddsCHL2filt(1),ddsKD490filt(1),ddsTSMfilt(1),ddsCDMfilt(1),ddsBBPfilt(1),ddsT865filt(1),$
                            ddsL412filt(1),ddsL443filt(1),ddsL490filt(1),ddsL510filt(1),ddsL531filt(1),ddsL555filt(1),ddsL620filt(1),ddsL670filt(1),ddsL681filt(1),ddsL709filt(1),$
                            ddsCHLfilt(2),ddsCHL2filt(2),ddsKD490filt(2),ddsTSMfilt(2),ddsCDMfilt(2),ddsBBPfilt(2),ddsT865filt(2),$
                            ddsL412filt(2),ddsL443filt(2),ddsL490filt(2),ddsL510filt(2),ddsL531filt(2),ddsL555filt(2),ddsL620filt(2),ddsL670filt(2),ddsL681filt(2),ddsL709filt(2),$
                            ddsCHLfilt(3),ddsCHL2filt(3),ddsKD490filt(3),ddsTSMfilt(3),ddsCDMfilt(3),ddsBBPfilt(3),ddsT865filt(3),$
                            ddsL412filt(3),ddsL443filt(3),ddsL490filt(3),ddsL510filt(3),ddsL531filt(3),ddsL555filt(3),ddsL620filt(3),ddsL670filt(3),ddsL681filt(3),ddsL709filt(3),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",155(F,","),(A,",",A))'
;[-2.1.b] Write macro average data to file----------------------------------------------------------------------------------

                endif

              endif else begin
;[-2.1]-------------------------




;[+2.2] L3 Mapped DDS (All data are in 2-D array form; Lat/Lon are 1-D arrays
              offset=KM2DEG(1.1, inLon(k), inLat(k))    ;Maximum distance from the in-situ location is 1.1km for PC (1km) products
              inDist=SQRT(offset[0]^2. + offset[1]^2.)


                mapped_x=n_elements(dds_data.Lon)
                mapped_y=n_elements(dds_data.Lat)
                subLon=fltarr(mapped_x, mapped_y)
                subLat=fltarr(mapped_x, mapped_y)
                for m=0,mapped_x-1 do for n=0,mapped_y-1 do begin
                    subLon(m,n)=dds_data.Lon(m)
                    subLat(m,n)=dds_data.Lat(n)
                endfor

                p=NearestPoint(subLon, subLat, inLon(k), inLat(k), MaxDist=inDist, nP=2)
                if(n_elements(p) GT 1) then begin
                    nPix=((p(1)-p(0))+1)*((p(3)-p(2))+1)
                    if(nPix GT 1) then begin
                        ddsCHLm=(ddsCHL2m=(ddsKD490m=(ddsTSMm=(ddsCDMm=(ddsBBPm=(ddsT865m=FLTARR(nPix)))))))    ;This is not pixel average value, but the Var associated with 'Mean' tag
                        ddsL412m=(ddsL443m=(ddsL490m=(ddsL510m=(ddsL531m=(ddsL555m=(ddsL620m=(ddsL670m=(ddsL681m=(ddsL709m=FLTARR(nPix))))))))))
                        ddsCHLf=(ddsCHL2f=(ddsKD490f=(ddsTSMf=(ddsCDMf=(ddsBBPf=(ddsT865f=MAKE_ARRAY(nPix,Value=1)))))))    ;FLAGS
                        ddsL412f=(ddsL443f=(ddsL490f=(ddsL510f=(ddsL531f=(ddsL555f=(ddsL620f=(ddsL670f=(ddsL681f=(ddsL709f=MAKE_ARRAY(nPix,Value=1))))))))))

                        ddsLon=REFORM(subLon(p(0):p(1),p(2):p(3)),nPix)
                        ddsLat=REFORM(subLat(p(0):p(1),p(2):p(3)),nPix)

                        if(TOTAL(strmatch(dds_tags,'CHL1_VALUE'))) then ddsCHLm=REFORM(dds_data.CHL1_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CHL1_FLAGS'))) then ddsCHLf=UINT(REFORM(dds_data.CHL1_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'CHL2_VALUE'))) then ddsCHL2m=REFORM(dds_data.CHL2_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CHL2_FLAGS'))) then ddsCHL2f=UINT(REFORM(dds_data.CHL2_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'KD490_VALUE'))) then ddsKD490m=REFORM(dds_data.KD490_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'KD490_FLAGS'))) then ddsKD490f=UINT(REFORM(dds_data.KD490_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'TSM_VALUE'))) then ddsTSMm=REFORM(dds_data.TSM_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'TSM_FLAGS'))) then ddsTSMf=UINT(REFORM(dds_data.TSM_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'CDM_VALUE'))) then ddsCDMm=REFORM(dds_data.CDM_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CDM_FLAGS'))) then ddsCDMf=UINT(REFORM(dds_data.CDM_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'BBP_VALUE'))) then ddsBBPm=REFORM(dds_data.BBP_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'BBP_FLAGS'))) then ddsBBPf=UINT(REFORM(dds_data.BBP_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'T865_VALUE'))) then ddsT865m=REFORM(dds_data.T865_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'T865_FLAGS'))) then ddsT865f=UINT(REFORM(dds_data.T865_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L412_VALUE'))) then ddsL412m=REFORM(dds_data.L412_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L412_FLAGS'))) then ddsL412f=UINT(REFORM(dds_data.L412_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L443_VALUE'))) then ddsL443m=REFORM(dds_data.L443_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L443_FLAGS'))) then ddsL443f=UINT(REFORM(dds_data.L443_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L490_VALUE'))) then ddsL490m=REFORM(dds_data.L490_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L490_FLAGS'))) then ddsL490f=UINT(REFORM(dds_data.L490_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L510_VALUE'))) then ddsL510m=REFORM(dds_data.L510_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L510_FLAGS'))) then ddsL510f=UINT(REFORM(dds_data.L510_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L531_VALUE'))) then ddsL531m=REFORM(dds_data.L531_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L531_FLAGS'))) then ddsL531f=UINT(REFORM(dds_data.L531_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L555_VALUE'))) then ddsL555m=REFORM(dds_data.L555_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L555_FLAGS'))) then ddsL555f=UINT(REFORM(dds_data.L555_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L620_VALUE'))) then ddsL620m=REFORM(dds_data.L620_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L620_FLAGS'))) then ddsL620f=UINT(REFORM(dds_data.L620_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L670_VALUE'))) then ddsL670m=REFORM(dds_data.L670_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L670_FLAGS'))) then ddsL670f=UINT(REFORM(dds_data.L670_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L681_VALUE'))) then ddsL681m=REFORM(dds_data.L681_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L681_FLAGS'))) then ddsL681f=UINT(REFORM(dds_data.L681_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L709_VALUE'))) then ddsL709m=REFORM(dds_data.L709_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L709_FLAGS'))) then ddsL709f=UINT(REFORM(dds_data.L709_FLAGS(p(0):p(1),p(2):p(3)),nPix))


;[+2.2.a] Write extracted pixel to file----------------------------------------------------------------------------------
                        for pp=0, nPix-1 do begin
                        printf,4,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLat(pp),ddsLon(pp),$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLm(pp),ddsCHL2m(pp),ddsKD490m(pp),ddsTSMm(pp),ddsCDMm(pp),ddsBBPm(pp),ddsT865m(pp),$
                            ddsL412m(pp),ddsL443m(pp),ddsL490m(pp),ddsL510m(pp),ddsL531m(pp),ddsL555m(pp),ddsL620m(pp),ddsL670m(pp),ddsL681m(pp),ddsL709m(pp),$
                            ddsCHLf(pp),ddsCHL2f(pp),ddsKD490f(pp),ddsTSMf(pp),ddsCDMf(pp),ddsBBPf(pp),ddsT865f(pp),$
                            ddsL412f(pp),ddsL443f(pp),ddsL490f(pp),ddsL510f(pp),ddsL531f(pp),ddsL555f(pp),ddsL620f(pp),ddsL670f(pp),ddsL681f(pp),ddsL709f(pp),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",36(F,","),18(A,","),A)'
                        endfor
;[-2.2.a] Write extracted pixel to file----------------------------------------------------------------------------------

;Initiate variable average, median, stdev for extracted pixels
                        ddsLonav=(ddsLatav=(ddsCHLav=(ddsCHL2av=(ddsKD490av=(ddsTSMav=(ddsCDMav=(ddsBBPav=(ddsT865av=!Values.F_NaN))))))))    ;Average of extracted pixels
                        ddsL412av=(ddsL443av=(ddsL490av=(ddsL510av=(ddsL531av=(ddsL555av=(ddsL620av=(ddsL670av=(ddsL681av=(ddsL709av=!Values.F_NaN)))))))))
                        ddsLonmd=(ddsLatmd=(ddsCHLmd=(ddsCHL2md=(ddsKD490md=(ddsTSMmd=(ddsCDMmd=(ddsBBPmd=(ddsT865md=!Values.F_NaN))))))))    ;Median of extracted pixels
                        ddsL412md=(ddsL443md=(ddsL490md=(ddsL510md=(ddsL531md=(ddsL555md=(ddsL620md=(ddsL670md=(ddsL681md=(ddsL709md=!Values.F_NaN)))))))))
                        ddsLonsd=(ddsLatsd=(ddsCHLsd=(ddsCHL2sd=(ddsKD490sd=(ddsTSMsd=(ddsCDMsd=(ddsBBPsd=(ddsT865sd=!Values.F_NaN))))))))    ;Standard deviation of extracted pixels
                        ddsL412sd=(ddsL443sd=(ddsL490sd=(ddsL510sd=(ddsL531sd=(ddsL555sd=(ddsL620sd=(ddsL670sd=(ddsL681sd=(ddsL709sd=!Values.F_NaN)))))))))

                        ddsCHLfilt=(ddsCHL2filt=(ddsKD490filt=(ddsTSMfilt=(ddsCDMfilt=(ddsBBPfilt=(ddsT865filt=MAKE_ARRAY(4,Value=!Values.F_NaN)))))))
                        ddsL412filt=(ddsL443filt=(ddsL490filt=(ddsL510filt=(ddsL531filt=(ddsL555filt=(ddsL620filt=(ddsL670filt=(ddsL681filt=(ddsL709filt=MAKE_ARRAY(4,Value=!Values.F_NaN))))))))))


                        c1_msk=(c2_msk=(kd_msk=(tsm_msk=(cdm_msk=(bbp_msk=(t865_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0))))))))
                        L412_msk=(L443_msk=(L490_msk=(L510_msk=(L531_msk=(L555_msk=(L620_msk=(L670_msk=(L681_msk=(L709_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0)))))))))))

                        for pp=0, nPix-1 do begin
                          flg=gcDDSFLAG2Name(ddsCHLf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4)) then c1_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCHL2f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LE 4)) then c2_msk(pp)=1   ;(df LT 4)
                          flg=gcDDSFLAG2Name(ddsKD490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4)) then kd_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsTSMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then tsm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCDMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then cdm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsBBPf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then bbp_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsT865f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then t865_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL412f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L412_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL443f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L443_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L490_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL510f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L510_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL531f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L531_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL555f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L555_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL620f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L620_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL670f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L670_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL681f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L681_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL709f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L709_msk(pp)=1
                        endfor

                        momddsLon=MOMENT(ddsLon,SDEV=ddsLonsd)
                        ddsLonav=momddsLon(0)
                        ;ddsLonmd=MEDIAN(ddsLon)
                        momddsLat=MOMENT(ddsLat,SDEV=ddsLatsd)
                        ddsLatav=momddsLat(0)
                        ;ddsLatmd=MEDIAN(ddsLat)

                        if(strcmp(input_file_tag,'LAC')) then NGP=13 else NGP=2
                        ;cvar=0.2    ;Set Coefficient of variation
                        if(total(c1_msk) GE 2) then begin
                            momddsCHL=MOMENT(ddsCHLm(where(c1_msk)),SDEV=ddsCHLsd)
                            ddsCHLav=momddsCHL(0)
                            ddsCHLmd=MEDIAN(ddsCHLm(where(c1_msk)))
                            if(total(c1_msk) GE NGP) then ddsCHLfilt=FILTERED_AVERAGE(ddsCHLm(where(c1_msk)),CV=cvar)
                        endif
                        if(total(c2_msk) GE 2) then begin
                            momddsCHL2=MOMENT(ddsCHL2m(where(c2_msk)),SDEV=ddsCHL2sd)
                            ddsCHL2av=momddsCHL2(0)
                            ddsCHL2md=MEDIAN(ddsCHL2m(where(c2_msk)))
                            if(total(c2_msk) GE NGP) then ddsCHL2filt=FILTERED_AVERAGE(ddsCHL2m(where(c2_msk)),CV=cvar)
                        endif
                        if(total(kd_msk) GE 2) then begin
                            momddsKD490=MOMENT(ddsKD490m(where(kd_msk)),SDEV=ddsKD490sd)
                            ddsKD490av=momddsKD490(0)
                            ddsKD490md=MEDIAN(ddsKD490m(where(kd_msk)))
                            if(total(kd_msk) GE NGP) then ddsKD490filt=FILTERED_AVERAGE(ddsKD490m(where(kd_msk)),CV=cvar)
                        endif
                        if(total(tsm_msk) GE 2) then begin
                            momddsTSM=MOMENT(ddsTSMm(where(tsm_msk)),SDEV=ddsTSMsd)
                            ddsTSMav=momddsTSM(0)
                            ddsTSMmd=MEDIAN(ddsTSMm(where(tsm_msk)))
                            if(total(tsm_msk) GE NGP) then ddsTSMfilt=FILTERED_AVERAGE(ddsTSMm(where(tsm_msk)),CV=cvar)
                        endif
                        if(total(cdm_msk) GE 2) then begin
                            momddsCDM=MOMENT(ddsCDMm(where(cdm_msk)),SDEV=ddsCDMsd)
                            ddsCDMav=momddsCDM(0)
                            ddsCDMmd=MEDIAN(ddsCDMm(where(cdm_msk)))
                            if(total(cdm_msk) GE NGP) then ddsCDMfilt=FILTERED_AVERAGE(ddsCDMm(where(cdm_msk)),CV=cvar)
                        endif
                        if(total(bbp_msk) GE 2) then begin
                            momddsBBP=MOMENT(ddsBBPm(where(bbp_msk)),SDEV=ddsBBPsd)
                            ddsBBPav=momddsBBP(0)
                            ddsBBPmd=MEDIAN(ddsBBPm(where(bbp_msk)))
                            if(total(bbp_msk) GE NGP) then ddsBBPfilt=FILTERED_AVERAGE(ddsBBPm(where(bbp_msk)),CV=cvar)
                        endif
                        if(total(t865_msk) GE 2) then begin
                            momddsT865=MOMENT(ddsT865m(where(t865_msk)),SDEV=ddsT865sd)
                            ddsT865av=momddsT865(0)
                            ddsT865md=MEDIAN(ddsT865m(where(t865_msk)))
                            if(total(t865_msk) GE NGP) then ddsT865filt=FILTERED_AVERAGE(ddsT865m(where(t865_msk)),CV=cvar)
                        endif
                        if(total(L412_msk) GE 2) then begin
                            momddsL412=MOMENT(ddsL412m(where(L412_msk)),SDEV=ddsL412sd)
                            ddsL412av=momddsL412(0)
                            ddsL412md=MEDIAN(ddsL412m(where(L412_msk)))
                            if(total(L412_msk) GE NGP) then ddsL412filt=FILTERED_AVERAGE(ddsL412m(where(L412_msk)),CV=cvar)
                        endif
                        if(total(L443_msk) GE 2) then begin
                            momddsL443=MOMENT(ddsL443m(where(L443_msk)),SDEV=ddsL443sd)
                            ddsL443av=momddsL443(0)
                            ddsL443md=MEDIAN(ddsL443m(where(L443_msk)))
                            if(total(L443_msk) GE NGP) then ddsL443filt=FILTERED_AVERAGE(ddsL443m(where(L443_msk)),CV=cvar)
                        endif
                        if(total(L490_msk) GE 2) then begin
                            momddsL490=MOMENT(ddsL490m(where(L490_msk)),SDEV=ddsL490sd)
                            ddsL490av=momddsL490(0)
                            ddsL490md=MEDIAN(ddsL490m(where(L490_msk)))
                            if(total(L490_msk) GE NGP) then ddsL490filt=FILTERED_AVERAGE(ddsL490m(where(L490_msk)),CV=cvar)
                        endif
                        if(total(L510_msk) GE 2) then begin
                            momddsL510=MOMENT(ddsL510m(where(L510_msk)),SDEV=ddsL510sd)
                            ddsL510av=momddsL510(0)
                            ddsL510md=MEDIAN(ddsL510m(where(L510_msk)))
                            if(total(L510_msk) GE NGP) then ddsL510filt=FILTERED_AVERAGE(ddsL510m(where(L510_msk)),CV=cvar)
                        endif
                        if(total(L531_msk) GE 2) then begin
                            momddsL531=MOMENT(ddsL531m(where(L531_msk)),SDEV=ddsL531sd)
                            ddsL531av=momddsL531(0)
                            ddsL531md=MEDIAN(ddsL531m(where(L531_msk)))
                            if(total(L531_msk) GE NGP) then ddsL531filt=FILTERED_AVERAGE(ddsL531m(where(L531_msk)),CV=cvar)
                        endif
                        if(total(L555_msk) GE 2) then begin
                            momddsL555=MOMENT(ddsL555m(where(L555_msk)),SDEV=ddsL555sd)
                            ddsL555av=momddsL555(0)
                            ddsL555md=MEDIAN(ddsL555m(where(L555_msk)))
                            if(total(L555_msk) GE NGP) then ddsL555filt=FILTERED_AVERAGE(ddsL555m(where(L555_msk)),CV=cvar)
                        endif
                        if(total(L620_msk) GE 2) then begin
                            momddsL620=MOMENT(ddsL620m(where(L620_msk)),SDEV=ddsL620sd)
                            ddsL620av=momddsL620(0)
                            ddsL620md=MEDIAN(ddsL620m(where(L620_msk)))
                            if(total(L620_msk) GE NGP) then ddsL620filt=FILTERED_AVERAGE(ddsL620m(where(L620_msk)),CV=cvar)
                        endif
                        if(total(L670_msk) GE 2) then begin
                            momddsL670=MOMENT(ddsL670m(where(L670_msk)),SDEV=ddsL670sd)
                            ddsL670av=momddsL670(0)
                            ddsL670md=MEDIAN(ddsL670m(where(L670_msk)))
                            if(total(L670_msk) GE NGP) then ddsL670filt=FILTERED_AVERAGE(ddsL670m(where(L670_msk)),CV=cvar)
                        endif
                        if(total(L681_msk) GE 2) then begin
                            momddsL681=MOMENT(ddsL681m(where(L681_msk)),SDEV=ddsL681sd)
                            ddsL681av=momddsL681(0)
                            ddsL681md=MEDIAN(ddsL681m(where(L681_msk)))
                            if(total(L681_msk) GE NGP) then ddsL681filt=FILTERED_AVERAGE(ddsL681m(where(L681_msk)),CV=cvar)
                        endif
                        if(total(L709_msk) GE 2) then begin
                            momddsL709=MOMENT(ddsL709m(where(L709_msk)),SDEV=ddsL709sd)
                            ddsL709av=momddsL709(0)
                            ddsL709md=MEDIAN(ddsL709m(where(L709_msk)))
                            if(total(L709_msk) GE NGP) then ddsL709filt=FILTERED_AVERAGE(ddsL709m(where(L709_msk)),CV=cvar)
                        endif


;[+2.2.b] Write macro average data to file----------------------------------------------------------------------------------
                        printf,5,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLatav,ddsLonav,$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLav,ddsCHL2av,ddsKD490av,ddsTSMav,ddsCDMav,ddsBBPav,ddsT865av,$
                            ddsL412av,ddsL443av,ddsL490av,ddsL510av,ddsL531av,ddsL555av,ddsL620av,ddsL670av,ddsL681av,ddsL709av,$
                            ddsCHLmd,ddsCHL2md,ddsKD490md,ddsTSMmd,ddsCDMmd,ddsBBPmd,ddsT865md,$
                            ddsL412md,ddsL443md,ddsL490md,ddsL510md,ddsL531md,ddsL555md,ddsL620md,ddsL670md,ddsL681md,ddsL709md,$
                            ddsCHLsd,ddsCHL2sd,ddsKD490sd,ddsTSMsd,ddsCDMsd,ddsBBPsd,ddsT865sd,$
                            ddsL412sd,ddsL443sd,ddsL490sd,ddsL510sd,ddsL531sd,ddsL555sd,ddsL620sd,ddsL670sd,ddsL681sd,ddsL709sd,$
                            total(c1_msk),total(c2_msk),total(kd_msk),total(tsm_msk),total(cdm_msk),total(bbp_msk),total(t865_msk),$
                            total(L412_msk),total(L443_msk),total(L490_msk),total(L510_msk),total(L531_msk),total(L555_msk),total(L620_msk),total(L670_msk),total(L681_msk),total(L709_msk),$
                            ddsCHLfilt(0),ddsCHL2filt(0),ddsKD490filt(0),ddsTSMfilt(0),ddsCDMfilt(0),ddsBBPfilt(0),ddsT865filt(0),$
                            ddsL412filt(0),ddsL443filt(0),ddsL490filt(0),ddsL510filt(0),ddsL531filt(0),ddsL555filt(0),ddsL620filt(0),ddsL670filt(0),ddsL681filt(0),ddsL709filt(0),$
                            ddsCHLfilt(1),ddsCHL2filt(1),ddsKD490filt(1),ddsTSMfilt(1),ddsCDMfilt(1),ddsBBPfilt(1),ddsT865filt(1),$
                            ddsL412filt(1),ddsL443filt(1),ddsL490filt(1),ddsL510filt(1),ddsL531filt(1),ddsL555filt(1),ddsL620filt(1),ddsL670filt(1),ddsL681filt(1),ddsL709filt(1),$
                            ddsCHLfilt(2),ddsCHL2filt(2),ddsKD490filt(2),ddsTSMfilt(2),ddsCDMfilt(2),ddsBBPfilt(2),ddsT865filt(2),$
                            ddsL412filt(2),ddsL443filt(2),ddsL490filt(2),ddsL510filt(2),ddsL531filt(2),ddsL555filt(2),ddsL620filt(2),ddsL670filt(2),ddsL681filt(2),ddsL709filt(2),$
                            ddsCHLfilt(3),ddsCHL2filt(3),ddsKD490filt(3),ddsTSMfilt(3),ddsCDMfilt(3),ddsBBPfilt(3),ddsT865filt(3),$
                            ddsL412filt(3),ddsL443filt(3),ddsL490filt(3),ddsL510filt(3),ddsL531filt(3),ddsL555filt(3),ddsL620filt(3),ddsL670filt(3),ddsL681filt(3),ddsL709filt(3),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",155(F,","),(A,",",A))'
;[2.2.b] Write macro average data to file----------------------------------------------------------------------------------

                    endif   ;if(nPix GT 1) then begin
                endif   ;(n_elements(p) GT 1) then begin
              endelse
;[-2.2]----------------

            endfor   ;for k=0,nr-1 do begin
         endif else $  ;if(nr GT 0) then begin
         print,ddsFile+" matches with "+string(nr)+" in-situ record(s) for same day."
       endfor   ;for i=0,nMOD-1 do begin
    endif   ;if((Sensor EQ 1 or Sensor EQ 4) and nMOD GT 0) then begin
;[-2]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END MODIS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;[+3]. MERIS

    if((Sensor EQ 3 or Sensor EQ 4) and nMER GT 0) then begin
       for i=0,nMER-1 do begin
        ddsFile=FILE_BASENAME(ddsMERFiles(i))
        ddsYear=FIX(strmid(ddsFile,4,4))
        ddsMonth=FIX(strmid(ddsFile,8,2))
        ddsDay=FIX(strmid(ddsFile,10,2))
        ddsYearSDY=1000L*ddsYear+sdy(ddsDay,ddsMonth,ddsYear)
        ddsYMD=strmid(ddsFile,4,8)
        ddsHour=FIX(strmid(ddsFile,13,2))
        ddsMinute=FIX(strmid(ddsFile,15,2))
        ddsTime=ddsHour + (ddsMinute/60.)



        day_match=where(insituYearSDY EQ ddsYearSDY, nr)
        if(keyword_set(time_series)) then begin
            if(nr GT 1) then begin
            tDiff=abs(ddsTime - insituTime(day_match))
            mintDiff=where(tDiff EQ min(tDiff))
            day_match=day_match(mintDiff)
            nr=1
            endif
        endif
        if(nr GT 0) then begin
            print,ddsFile+" matches with "+string(nr)+" in-situ record(s) for same day."
            ;print,insitu_data.ID(day_match)
            inLon=insitu_data.Longitude(day_match)
            inLat=insitu_data.Latitude(day_match)
            inYearSDY=insituYearSDY(day_match)


            ;read_netCDF, ddsFile[0], dds_data, dds_attr, status
            read_netCDF, ddsMERFiles(i), dds_data, dds_attr, status
            dds_tags=TAG_NAMES(dds_data)    ;available variable names in the DDS file

            time_info=dds_attr[where(stregex(dds_attr,'start_time =') NE -1)] ;DDS Start time
            dds_time=strmid(time_info,stregex(time_info,'[0-9]'),100)
            dds_Hour=FIX(strmid(dds_time[0],9,2))
            dds_Minute=FIX(strmid(dds_time[0],11,2))
            ;print,dds_time

;Treat the match-up depending on the input_file type LAC=1.1km and GAC=4.4km effective resolution
            input_file_info=dds_attr[where(stregex(dds_attr,'input_files =') NE -1)] ;Input File
            split_string=strsplit(input_file_info,'_',/extract)
            ;input_file_tag=split_string[2] ;GAC or MLAC or LAC
            if((total(strmatch(split_string,'MLAC')) GE 1) or (total(strmatch(split_string,'LAC')) GE 1) or (total(strmatch(split_string,'0000.N1')) GE 1)) then input_file_tag='LAC'
            if((total(strmatch(split_string,'GAC')) GE 1) and (total(strmatch(split_string,'MLAC')) EQ 0) and (total(strmatch(split_string,'LAC')) EQ 0)) then input_file_tag='GAC'

;print,input_file_tag

;MAIN LOOP
            for k=0,nr-1 do begin
            ;print,inLon(k),inYearSDY(k),ddsYearSDY


              if(KEYWORD_SET(l3b_dds)) then begin
;[+3.1] L3 Binned DDS (All data are in 1-D array form)

              offset=KM2DEG(5.0, inLon(k), inLat(k))    ;Maximum distance from the in-situ location is 5km for ISIN (4km) products
              inDist=SQRT(offset[0]^2. + offset[1]^2.)

                row_info=dds_attr[where(stregex(dds_attr,'first_row =') NE -1)]
                first_row=LONG(strmid(row_info,stregex(row_info,'[0-9]'),100))
                lat_step_info=dds_attr[where(stregex(dds_attr,'lat_step =') NE -1)]
                lat_step=DOUBLE(strmid(lat_step_info,stregex(lat_step_info,'[0-9]'),100))

                idx=dds_data.row-first_row[0]
                ddsLat=dds_data.center_lat(idx)
                ddsLon=dds_data.center_lon(idx) + dds_data.col*dds_data.lon_step(idx)

                p=NearestPoint(ddsLon, ddsLat, inLon(k), inLat(k), MaxDist=inDist, SR=inDist, nP=9)
                nPix=n_elements(p)
                if(nPix GT 1) then begin

                    ddsCHLm=(ddsCHL2m=(ddsKD490m=(ddsTSMm=(ddsCDMm=(ddsBBPm=(ddsT865m=FLTARR(nPix)))))))    ;MEAN
                    ddsL412m=(ddsL443m=(ddsL490m=(ddsL510m=(ddsL531m=(ddsL555m=(ddsL620m=(ddsL670m=(ddsL681m=(ddsL709m=FLTARR(nPix))))))))))
                    ddsCHLs=(ddsCHL2s=(ddsKD490s=(ddsTSMs=(ddsCDMs=(ddsBBPs=(ddsT865s=FLTARR(nPix)))))))    ;STDEV
                    ddsL412s=(ddsL443s=(ddsL490s=(ddsL510s=(ddsL531s=(ddsL555s=(ddsL620s=(ddsL670s=(ddsL681s=(ddsL709s=FLTARR(nPix))))))))))
                    ddsCHLn=(ddsCHL2n=(ddsKD490n=(ddsTSMn=(ddsCDMn=(ddsBBPn=(ddsT865n=FLTARR(nPix)))))))    ;COUNT
                    ddsL412n=(ddsL443n=(ddsL490n=(ddsL510n=(ddsL531n=(ddsL555n=(ddsL620n=(ddsL670n=(ddsL681n=(ddsL709n=FLTARR(nPix))))))))))
                    ddsCHLw=(ddsCHL2w=(ddsKD490w=(ddsTSMw=(ddsCDMw=(ddsBBPw=(ddsT865w=FLTARR(nPix)))))))    ;WEIGHT
                    ddsL412w=(ddsL443w=(ddsL490w=(ddsL510w=(ddsL531w=(ddsL555w=(ddsL620w=(ddsL670w=(ddsL681w=(ddsL709w=FLTARR(nPix))))))))))
                    ddsCHLf=(ddsCHL2f=(ddsKD490f=(ddsTSMf=(ddsCDMf=(ddsBBPf=(ddsT865f=FLTARR(nPix)))))))    ;FLAGS
                    ddsL412f=(ddsL443f=(ddsL490f=(ddsL510f=(ddsL531f=(ddsL555f=(ddsL620f=(ddsL670f=(ddsL681f=(ddsL709f=FLTARR(nPix))))))))))
                    ddsCHLe=(ddsCHL2e=(ddsKD490e=(ddsTSMe=(ddsCDMe=(ddsBBPe=(ddsT865e=FLTARR(nPix)))))))    ;ERROR
                    ddsL412e=(ddsL443e=(ddsL490e=(ddsL510e=(ddsL531e=(ddsL555e=(ddsL620e=(ddsL670e=(ddsL681e=(ddsL709e=FLTARR(nPix))))))))))
                    ddsLat=ddsLat(p)
                    ddsLon=ddsLon(p)
                    ddsCHLcv=(ddsCHL2cv=(ddsKD490cv=(ddsTSMcv=(ddsCDMcv=(ddsBBPcv=(ddsT865cv=MAKE_ARRAY(nPix,Value=1.)))))))    ;COEFFICIENT OF VARIATION
                    ddsL412cv=(ddsL443cv=(ddsL490cv=(ddsL510cv=(ddsL531cv=(ddsL555cv=(ddsL620cv=(ddsL670cv=(ddsL681cv=(ddsL709cv=MAKE_ARRAY(nPix,Value=1.))))))))))


                    if(TOTAL(strmatch(dds_tags,'CHL1_MEAN'))) then ddsCHLm=dds_data.CHL1_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_STDEV'))) then ddsCHLs=dds_data.CHL1_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_COUNT'))) then ddsCHLn=UINT(dds_data.CHL1_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CHL1_WEIGHT'))) then ddsCHLw=dds_data.CHL1_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CHL1_FLAGS'))) then ddsCHLf=UINT(dds_data.CHL1_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CHL1_ERROR'))) then ddsCHLe=UINT(dds_data.CHL1_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'CHL2_MEAN'))) then ddsCHL2m=dds_data.CHL2_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_STDEV'))) then ddsCHL2s=dds_data.CHL2_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_COUNT'))) then ddsCHL2n=UINT(dds_data.CHL2_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CHL2_WEIGHT'))) then ddsCHL2w=dds_data.CHL2_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CHL2_FLAGS'))) then ddsCHL2f=UINT(dds_data.CHL2_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CHL2_ERROR'))) then ddsCHL2e=UINT(dds_data.CHL2_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'KD490_MEAN'))) then ddsKD490m=dds_data.KD490_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_STDEV'))) then ddsKD490s=dds_data.KD490_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_COUNT'))) then ddsKD490n=UINT(dds_data.KD490_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'KD490_WEIGHT'))) then ddsKD490w=dds_data.KD490_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'KD490_FLAGS'))) then ddsKD490f=UINT(dds_data.KD490_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'KD490_ERROR'))) then ddsKD490e=UINT(dds_data.KD490_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'TSM_MEAN'))) then ddsTSMm=dds_data.TSM_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_STDEV'))) then ddsTSMs=dds_data.TSM_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_COUNT'))) then ddsTSMn=UINT(dds_data.TSM_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'TSM_WEIGHT'))) then ddsTSMw=dds_data.TSM_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'TSM_FLAGS'))) then ddsTSMf=UINT(dds_data.TSM_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'TSM_ERROR'))) then ddsTSMe=UINT(dds_data.TSM_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'CDM_MEAN'))) then ddsCDMm=dds_data.CDM_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_STDEV'))) then ddsCDMs=dds_data.CDM_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_COUNT'))) then ddsCDMn=UINT(dds_data.CDM_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'CDM_WEIGHT'))) then ddsCDMw=dds_data.CDM_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'CDM_FLAGS'))) then ddsCDMf=UINT(dds_data.CDM_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'CDM_ERROR'))) then ddsCDMe=UINT(dds_data.CDM_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'BBP_MEAN'))) then ddsBBPm=dds_data.BBP_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_STDEV'))) then ddsBBPs=dds_data.BBP_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_COUNT'))) then ddsBBPn=UINT(dds_data.BBP_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'BBP_WEIGHT'))) then ddsBBPw=dds_data.BBP_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'BBP_FLAGS'))) then ddsBBPf=UINT(dds_data.BBP_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'BBP_ERROR'))) then ddsBBPe=UINT(dds_data.BBP_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'T865_MEAN'))) then ddsT865m=dds_data.T865_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'T865_STDEV'))) then ddsT865s=dds_data.T865_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'T865_COUNT'))) then ddsT865n=UINT(dds_data.T865_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'T865_WEIGHT'))) then ddsT865w=dds_data.T865_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'T865_FLAGS'))) then ddsT865f=UINT(dds_data.T865_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'T865_ERROR'))) then ddsT865e=UINT(dds_data.T865_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L412_MEAN'))) then ddsL412m=dds_data.L412_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L412_STDEV'))) then ddsL412s=dds_data.L412_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L412_COUNT'))) then ddsL412n=UINT(dds_data.L412_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L412_WEIGHT'))) then ddsL412w=dds_data.L412_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L412_FLAGS'))) then ddsL412f=UINT(dds_data.L412_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L412_ERROR'))) then ddsL412e=UINT(dds_data.L412_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L443_MEAN'))) then ddsL443m=dds_data.L443_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L443_STDEV'))) then ddsL443s=dds_data.L443_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L443_COUNT'))) then ddsL443n=UINT(dds_data.L443_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L443_WEIGHT'))) then ddsL443w=dds_data.L443_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L443_FLAGS'))) then ddsL443f=UINT(dds_data.L443_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L443_ERROR'))) then ddsL443e=UINT(dds_data.L443_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L490_MEAN'))) then ddsL490m=dds_data.L490_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L490_STDEV'))) then ddsL490s=dds_data.L490_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L490_COUNT'))) then ddsL490n=UINT(dds_data.L490_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L490_WEIGHT'))) then ddsL490w=dds_data.L490_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L490_FLAGS'))) then ddsL490f=UINT(dds_data.L490_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L490_ERROR'))) then ddsL490e=UINT(dds_data.L490_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L510_MEAN'))) then ddsL510m=dds_data.L510_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L510_STDEV'))) then ddsL510s=dds_data.L510_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L510_COUNT'))) then ddsL510n=UINT(dds_data.L510_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L510_WEIGHT'))) then ddsL510w=dds_data.L510_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L510_FLAGS'))) then ddsL510f=UINT(dds_data.L510_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L510_ERROR'))) then ddsL510e=UINT(dds_data.L510_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L531_MEAN'))) then ddsL531m=dds_data.L531_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L531_STDEV'))) then ddsL531s=dds_data.L531_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L531_COUNT'))) then ddsL531n=UINT(dds_data.L531_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L531_WEIGHT'))) then ddsL531w=dds_data.L531_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L531_FLAGS'))) then ddsL531f=UINT(dds_data.L531_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L531_ERROR'))) then ddsL531e=UINT(dds_data.L531_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L555_MEAN'))) then ddsL555m=dds_data.L555_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L555_STDEV'))) then ddsL555s=dds_data.L555_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L555_COUNT'))) then ddsL555n=UINT(dds_data.L555_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L555_WEIGHT'))) then ddsL555w=dds_data.L555_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L555_FLAGS'))) then ddsL555f=UINT(dds_data.L555_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L555_ERROR'))) then ddsL555e=UINT(dds_data.L555_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L620_MEAN'))) then ddsL620m=dds_data.L620_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L620_STDEV'))) then ddsL620s=dds_data.L620_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L620_COUNT'))) then ddsL620n=UINT(dds_data.L620_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L620_WEIGHT'))) then ddsL620w=dds_data.L620_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L620_FLAGS'))) then ddsL620f=UINT(dds_data.L620_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L620_ERROR'))) then ddsL620e=UINT(dds_data.L620_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L670_MEAN'))) then ddsL670m=dds_data.L670_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L670_STDEV'))) then ddsL670s=dds_data.L670_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L670_COUNT'))) then ddsL670n=UINT(dds_data.L670_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L670_WEIGHT'))) then ddsL670w=dds_data.L670_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L670_FLAGS'))) then ddsL670f=UINT(dds_data.L670_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L670_ERROR'))) then ddsL670e=UINT(dds_data.L670_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L681_MEAN'))) then ddsL681m=dds_data.L681_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L681_STDEV'))) then ddsL681s=dds_data.L681_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L681_COUNT'))) then ddsL681n=UINT(dds_data.L681_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L681_WEIGHT'))) then ddsL681w=dds_data.L681_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L681_FLAGS'))) then ddsL681f=UINT(dds_data.L681_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L681_ERROR'))) then ddsL681e=UINT(dds_data.L681_ERROR(p))

                    if(TOTAL(strmatch(dds_tags,'L709_MEAN'))) then ddsL709m=dds_data.L709_MEAN(p)
                    if(TOTAL(strmatch(dds_tags,'L709_STDEV'))) then ddsL709s=dds_data.L709_STDEV(p)
                    if(TOTAL(strmatch(dds_tags,'L709_COUNT'))) then ddsL709n=UINT(dds_data.L709_COUNT(p))
                    if(TOTAL(strmatch(dds_tags,'L709_WEIGHT'))) then ddsL709w=dds_data.L709_WEIGHT(p)
                    if(TOTAL(strmatch(dds_tags,'L709_FLAGS'))) then ddsL709f=UINT(dds_data.L709_FLAGS(p))
                    if(TOTAL(strmatch(dds_tags,'L709_ERROR'))) then ddsL709e=UINT(dds_data.L709_ERROR(p))


;[+3.1.a] Write extracted pixel to file----------------------------------------------------------------------------------
                    for pp=0, nPix-1 do begin
                     printf,7,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                        inLat(k),inLon(k),dds_time,ddsLat(pp),ddsLon(pp),$
                        insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                        insitu_data.T865(day_match(k)),$
                        insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                        insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                        ddsCHLm(pp),ddsCHL2m(pp),ddsKD490m(pp),ddsTSMm(pp),ddsCDMm(pp),ddsBBPm(pp),ddsT865m(pp),$
                        ddsL412m(pp),ddsL443m(pp),ddsL490m(pp),ddsL510m(pp),ddsL531m(pp),ddsL555m(pp),ddsL620m(pp),ddsL670m(pp),ddsL681m(pp),ddsL709m(pp),$
                        ddsCHLf(pp),ddsCHL2f(pp),ddsKD490f(pp),ddsTSMf(pp),ddsCDMf(pp),ddsBBPf(pp),ddsT865f(pp),$
                        ddsL412f(pp),ddsL443f(pp),ddsL490f(pp),ddsL510f(pp),ddsL531f(pp),ddsL555f(pp),ddsL620f(pp),ddsL670f(pp),ddsL681f(pp),ddsL709f(pp),$
                        ddsFile[0],input_file_tag,$
                        FORMAT='(2(A,","),2(F,","),A,",",36(F,","),18(A,","),A)'
                    endfor
;[-3.1.a] Write extracted pixel to file----------------------------------------------------------------------------------


;Initiate variable average, median, stdev for extracted pixels
                        ddsLonav=(ddsLatav=(ddsCHLav=(ddsCHL2av=(ddsKD490av=(ddsTSMav=(ddsCDMav=(ddsBBPav=(ddsT865av=!Values.F_NaN))))))))    ;Average of extracted pixels
                        ddsL412av=(ddsL443av=(ddsL490av=(ddsL510av=(ddsL531av=(ddsL555av=(ddsL620av=(ddsL670av=(ddsL681av=(ddsL709av=!Values.F_NaN)))))))))
                        ddsLonmd=(ddsLatmd=(ddsCHLmd=(ddsCHL2md=(ddsKD490md=(ddsTSMmd=(ddsCDMmd=(ddsBBPmd=(ddsT865md=!Values.F_NaN))))))))    ;Median of extracted pixels
                        ddsL412md=(ddsL443md=(ddsL490md=(ddsL510md=(ddsL531md=(ddsL555md=(ddsL620md=(ddsL670md=(ddsL681md=(ddsL709md=!Values.F_NaN)))))))))
                        ddsLonsd=(ddsLatsd=(ddsCHLsd=(ddsCHL2sd=(ddsKD490sd=(ddsTSMsd=(ddsCDMsd=(ddsBBPsd=(ddsT865sd=!Values.F_NaN))))))))    ;Standard deviation of extracted pixels
                        ddsL412sd=(ddsL443sd=(ddsL490sd=(ddsL510sd=(ddsL531sd=(ddsL555sd=(ddsL620sd=(ddsL670sd=(ddsL681sd=(ddsL709sd=!Values.F_NaN)))))))))

                        ddsCHLfilt=(ddsCHL2filt=(ddsKD490filt=(ddsTSMfilt=(ddsCDMfilt=(ddsBBPfilt=(ddsT865filt=MAKE_ARRAY(4,Value=!Values.F_NaN)))))))
                        ddsL412filt=(ddsL443filt=(ddsL490filt=(ddsL510filt=(ddsL531filt=(ddsL555filt=(ddsL620filt=(ddsL670filt=(ddsL681filt=(ddsL709filt=MAKE_ARRAY(4,Value=!Values.F_NaN))))))))))


                        c1_msk=(c2_msk=(kd_msk=(tsm_msk=(cdm_msk=(bbp_msk=(t865_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0))))))))
                        L412_msk=(L443_msk=(L490_msk=(L510_msk=(L531_msk=(L555_msk=(L620_msk=(L670_msk=(L681_msk=(L709_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0)))))))))))

                        for pp=0, nPix-1 do begin
                          if(ddsCHLs(pp) GT 0. and ddsCHLm(pp) GT 0.) then ddsCHLcv(pp)=ddsCHLs(pp)/ddsCHLm(pp)
                          if(ddsCHL2s(pp) GT 0. and ddsCHL2m(pp) GT 0.) then ddsCHL2cv(pp)=ddsCHL2s(pp)/ddsCHL2m(pp)
                          if(ddsKD490s(pp) GT 0. and ddsKD490m(pp) GT 0.) then ddsKD490cv(pp)=ddsKD490s(pp)/ddsKD490m(pp)
                          if(ddsTSMs(pp) GT 0. and ddsTSMm(pp) GT 0.) then ddsTSMcv(pp)=ddsTSMs(pp)/ddsTSMm(pp)
                          if(ddsCDMs(pp) GT 0. and ddsCDMm(pp) GT 0.) then ddsCDMcv(pp)=ddsCDMs(pp)/ddsCDMm(pp)
                          if(ddsBBPs(pp) GT 0. and ddsBBPm(pp) GT 0.) then ddsBBPcv(pp)=ddsBBPs(pp)/ddsBBPm(pp)
                          if(ddsT865s(pp) GT 0. and ddsT865m(pp) GT 0.) then ddsT865cv(pp)=ddsT865s(pp)/ddsT865m(pp)
                          if(ddsL412s(pp) GT 0. and ddsL412m(pp) GT 0.) then ddsL412cv(pp)=ddsL412s(pp)/ddsL412m(pp)
                          if(ddsL443s(pp) GT 0. and ddsL443m(pp) GT 0.) then ddsL443cv(pp)=ddsL443s(pp)/ddsL443m(pp)
                          if(ddsL490s(pp) GT 0. and ddsL490m(pp) GT 0.) then ddsL490cv(pp)=ddsL490s(pp)/ddsL490m(pp)
                          if(ddsL510s(pp) GT 0. and ddsL510m(pp) GT 0.) then ddsL510cv(pp)=ddsL510s(pp)/ddsL510m(pp)
                          if(ddsL531s(pp) GT 0. and ddsL531m(pp) GT 0.) then ddsL531cv(pp)=ddsL531s(pp)/ddsL531m(pp)
                          if(ddsL555s(pp) GT 0. and ddsL555m(pp) GT 0.) then ddsL555cv(pp)=ddsL555s(pp)/ddsL555m(pp)
                          if(ddsL620s(pp) GT 0. and ddsL620m(pp) GT 0.) then ddsL620cv(pp)=ddsL620s(pp)/ddsL620m(pp)
                          if(ddsL670s(pp) GT 0. and ddsL670m(pp) GT 0.) then ddsL670cv(pp)=ddsL670s(pp)/ddsL670m(pp)
                          if(ddsL681s(pp) GT 0. and ddsL681m(pp) GT 0.) then ddsL681cv(pp)=ddsL681s(pp)/ddsL681m(pp)
                          if(ddsL709s(pp) GT 0. and ddsL709m(pp) GT 0.) then ddsL709cv(pp)=ddsL709s(pp)/ddsL709m(pp)


                          flg=gcDDSFLAG2Name(ddsCHLf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4) and (ddsCHLcv(pp) LT cvar)) then c1_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCHL2f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LE 4) and (ddsCHL2cv(pp) LT cvar)) then c2_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsKD490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4) and (ddsKD490cv(pp) LT cvar)) then kd_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsTSMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsTSMcv(pp) LT cvar)) then tsm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCDMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsCDMcv(pp) LT cvar)) then cdm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsBBPf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsBBPcv(pp) LT cvar)) then bbp_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsT865f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsT865cv(pp) LT cvar)) then t865_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL412f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL412cv(pp) LT cvar)) then L412_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL443f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL443cv(pp) LT cvar)) then L443_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL490cv(pp) LT cvar)) then L490_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL510f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL510cv(pp) LT cvar)) then L510_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL531f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL531cv(pp) LT cvar)) then L531_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL555f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL555cv(pp) LT cvar)) then L555_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL620f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL620cv(pp) LT cvar)) then L620_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL670f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL670cv(pp) LT cvar)) then L670_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL681f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL681cv(pp) LT cvar)) then L681_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL709f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4) and (ddsL709cv(pp) LT cvar)) then L709_msk(pp)=1
                        endfor

                        momddsLon=MOMENT(ddsLon,SDEV=ddsLonsd)
                        ddsLonav=momddsLon(0)
                        ;ddsLonmd=MEDIAN(ddsLon)
                        momddsLat=MOMENT(ddsLat,SDEV=ddsLatsd)
                        ddsLatav=momddsLat(0)
                        ;ddsLatmd=MEDIAN(ddsLat)

                        ;if(strcmp(input_file_tag,'LAC')) then NGP=5 else NGP=2
                        NGP=5
                        if(total(c1_msk) GE 2) then begin
                            momddsCHL=MOMENT(ddsCHLm(where(c1_msk)),SDEV=ddsCHLsd)
                            ddsCHLav=momddsCHL(0)
                            ddsCHLmd=MEDIAN(ddsCHLm(where(c1_msk)))
                            if(total(c1_msk) GE NGP) then ddsCHLfilt=FILTERED_AVERAGE(ddsCHLm(where(c1_msk)),CV=cvar)
                        endif
                        if(total(c2_msk) GE 2) then begin
                            momddsCHL2=MOMENT(ddsCHL2m(where(c2_msk)),SDEV=ddsCHL2sd)
                            ddsCHL2av=momddsCHL2(0)
                            ddsCHL2md=MEDIAN(ddsCHL2m(where(c2_msk)))
                            if(total(c2_msk) GE NGP) then ddsCHL2filt=FILTERED_AVERAGE(ddsCHL2m(where(c2_msk)),CV=cvar)
                        endif
                        if(total(kd_msk) GE 2) then begin
                            momddsKD490=MOMENT(ddsKD490m(where(kd_msk)),SDEV=ddsKD490sd)
                            ddsKD490av=momddsKD490(0)
                            ddsKD490md=MEDIAN(ddsKD490m(where(kd_msk)))
                            if(total(kd_msk) GE NGP) then ddsKD490filt=FILTERED_AVERAGE(ddsKD490m(where(kd_msk)),CV=cvar)
                        endif
                        if(total(tsm_msk) GE 2) then begin
                            momddsTSM=MOMENT(ddsTSMm(where(tsm_msk)),SDEV=ddsTSMsd)
                            ddsTSMav=momddsTSM(0)
                            ddsTSMmd=MEDIAN(ddsTSMm(where(tsm_msk)))
                            if(total(tsm_msk) GE NGP) then ddsTSMfilt=FILTERED_AVERAGE(ddsTSMm(where(tsm_msk)),CV=cvar)
                        endif
                        if(total(cdm_msk) GE 2) then begin
                            momddsCDM=MOMENT(ddsCDMm(where(cdm_msk)),SDEV=ddsCDMsd)
                            ddsCDMav=momddsCDM(0)
                            ddsCDMmd=MEDIAN(ddsCDMm(where(cdm_msk)))
                            if(total(cdm_msk) GE NGP) then ddsCDMfilt=FILTERED_AVERAGE(ddsCDMm(where(cdm_msk)),CV=cvar)
                        endif
                        if(total(bbp_msk) GE 2) then begin
                            momddsBBP=MOMENT(ddsBBPm(where(bbp_msk)),SDEV=ddsBBPsd)
                            ddsBBPav=momddsBBP(0)
                            ddsBBPmd=MEDIAN(ddsBBPm(where(bbp_msk)))
                            if(total(bbp_msk) GE NGP) then ddsBBPfilt=FILTERED_AVERAGE(ddsBBPm(where(bbp_msk)),CV=cvar)
                        endif
                        if(total(t865_msk) GE 2) then begin
                            momddsT865=MOMENT(ddsT865m(where(t865_msk)),SDEV=ddsT865sd)
                            ddsT865av=momddsT865(0)
                            ddsT865md=MEDIAN(ddsT865m(where(t865_msk)))
                            if(total(t865_msk) GE NGP) then ddsT865filt=FILTERED_AVERAGE(ddsT865m(where(t865_msk)),CV=cvar)
                        endif
                        if(total(L412_msk) GE 2) then begin
                            momddsL412=MOMENT(ddsL412m(where(L412_msk)),SDEV=ddsL412sd)
                            ddsL412av=momddsL412(0)
                            ddsL412md=MEDIAN(ddsL412m(where(L412_msk)))
                            if(total(L412_msk) GE NGP) then ddsL412filt=FILTERED_AVERAGE(ddsL412m(where(L412_msk)),CV=cvar)
                        endif
                        if(total(L443_msk) GE 2) then begin
                            momddsL443=MOMENT(ddsL443m(where(L443_msk)),SDEV=ddsL443sd)
                            ddsL443av=momddsL443(0)
                            ddsL443md=MEDIAN(ddsL443m(where(L443_msk)))
                            if(total(L443_msk) GE NGP) then ddsL443filt=FILTERED_AVERAGE(ddsL443m(where(L443_msk)),CV=cvar)
                        endif
                        if(total(L490_msk) GE 2) then begin
                            momddsL490=MOMENT(ddsL490m(where(L490_msk)),SDEV=ddsL490sd)
                            ddsL490av=momddsL490(0)
                            ddsL490md=MEDIAN(ddsL490m(where(L490_msk)))
                            if(total(L490_msk) GE NGP) then ddsL490filt=FILTERED_AVERAGE(ddsL490m(where(L490_msk)),CV=cvar)
                        endif
                        if(total(L510_msk) GE 2) then begin
                            momddsL510=MOMENT(ddsL510m(where(L510_msk)),SDEV=ddsL510sd)
                            ddsL510av=momddsL510(0)
                            ddsL510md=MEDIAN(ddsL510m(where(L510_msk)))
                            if(total(L510_msk) GE NGP) then ddsL510filt=FILTERED_AVERAGE(ddsL510m(where(L510_msk)),CV=cvar)
                        endif
                        if(total(L531_msk) GE 2) then begin
                            momddsL531=MOMENT(ddsL531m(where(L531_msk)),SDEV=ddsL531sd)
                            ddsL531av=momddsL531(0)
                            ddsL531md=MEDIAN(ddsL531m(where(L531_msk)))
                            if(total(L531_msk) GE NGP) then ddsL531filt=FILTERED_AVERAGE(ddsL531m(where(L531_msk)),CV=cvar)
                        endif
                        if(total(L555_msk) GE 2) then begin
                            momddsL555=MOMENT(ddsL555m(where(L555_msk)),SDEV=ddsL555sd)
                            ddsL555av=momddsL555(0)
                            ddsL555md=MEDIAN(ddsL555m(where(L555_msk)))
                            if(total(L555_msk) GE NGP) then ddsL555filt=FILTERED_AVERAGE(ddsL555m(where(L555_msk)),CV=cvar)
                        endif
                        if(total(L620_msk) GE 2) then begin
                            momddsL620=MOMENT(ddsL620m(where(L620_msk)),SDEV=ddsL620sd)
                            ddsL620av=momddsL620(0)
                            ddsL620md=MEDIAN(ddsL620m(where(L620_msk)))
                            if(total(L620_msk) GE NGP) then ddsL620filt=FILTERED_AVERAGE(ddsL620m(where(L620_msk)),CV=cvar)
                        endif
                        if(total(L670_msk) GE 2) then begin
                            momddsL670=MOMENT(ddsL670m(where(L670_msk)),SDEV=ddsL670sd)
                            ddsL670av=momddsL670(0)
                            ddsL670md=MEDIAN(ddsL670m(where(L670_msk)))
                            if(total(L670_msk) GE NGP) then ddsL670filt=FILTERED_AVERAGE(ddsL670m(where(L670_msk)),CV=cvar)
                        endif
                        if(total(L681_msk) GE 2) then begin
                            momddsL681=MOMENT(ddsL681m(where(L681_msk)),SDEV=ddsL681sd)
                            ddsL681av=momddsL681(0)
                            ddsL681md=MEDIAN(ddsL681m(where(L681_msk)))
                            if(total(L681_msk) GE NGP) then ddsL681filt=FILTERED_AVERAGE(ddsL681m(where(L681_msk)),CV=cvar)
                        endif
                        if(total(L709_msk) GE 2) then begin
                            momddsL709=MOMENT(ddsL709m(where(L709_msk)),SDEV=ddsL709sd)
                            ddsL709av=momddsL709(0)
                            ddsL709md=MEDIAN(ddsL709m(where(L709_msk)))
                            if(total(L709_msk) GE NGP) then ddsL709filt=FILTERED_AVERAGE(ddsL709m(where(L709_msk)),CV=cvar)
                        endif


;[+3.1.b] Write macro average data to file----------------------------------------------------------------------------------
                        printf,8,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLatav,ddsLonav,$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLav,ddsCHL2av,ddsKD490av,ddsTSMav,ddsCDMav,ddsBBPav,ddsT865av,$
                            ddsL412av,ddsL443av,ddsL490av,ddsL510av,ddsL531av,ddsL555av,ddsL620av,ddsL670av,ddsL681av,ddsL709av,$
                            ddsCHLmd,ddsCHL2md,ddsKD490md,ddsTSMmd,ddsCDMmd,ddsBBPmd,ddsT865md,$
                            ddsL412md,ddsL443md,ddsL490md,ddsL510md,ddsL531md,ddsL555md,ddsL620md,ddsL670md,ddsL681md,ddsL709md,$
                            ddsCHLsd,ddsCHL2sd,ddsKD490sd,ddsTSMsd,ddsCDMsd,ddsBBPsd,ddsT865sd,$
                            ddsL412sd,ddsL443sd,ddsL490sd,ddsL510sd,ddsL531sd,ddsL555sd,ddsL620sd,ddsL670sd,ddsL681sd,ddsL709sd,$
                            total(c1_msk),total(c2_msk),total(kd_msk),total(tsm_msk),total(cdm_msk),total(bbp_msk),total(t865_msk),$
                            total(L412_msk),total(L443_msk),total(L490_msk),total(L510_msk),total(L531_msk),total(L555_msk),total(L620_msk),total(L670_msk),total(L681_msk),total(L709_msk),$
                            ddsCHLfilt(0),ddsCHL2filt(0),ddsKD490filt(0),ddsTSMfilt(0),ddsCDMfilt(0),ddsBBPfilt(0),ddsT865filt(0),$
                            ddsL412filt(0),ddsL443filt(0),ddsL490filt(0),ddsL510filt(0),ddsL531filt(0),ddsL555filt(0),ddsL620filt(0),ddsL670filt(0),ddsL681filt(0),ddsL709filt(0),$
                            ddsCHLfilt(1),ddsCHL2filt(1),ddsKD490filt(1),ddsTSMfilt(1),ddsCDMfilt(1),ddsBBPfilt(1),ddsT865filt(1),$
                            ddsL412filt(1),ddsL443filt(1),ddsL490filt(1),ddsL510filt(1),ddsL531filt(1),ddsL555filt(1),ddsL620filt(1),ddsL670filt(1),ddsL681filt(1),ddsL709filt(1),$
                            ddsCHLfilt(2),ddsCHL2filt(2),ddsKD490filt(2),ddsTSMfilt(2),ddsCDMfilt(2),ddsBBPfilt(2),ddsT865filt(2),$
                            ddsL412filt(2),ddsL443filt(2),ddsL490filt(2),ddsL510filt(2),ddsL531filt(2),ddsL555filt(2),ddsL620filt(2),ddsL670filt(2),ddsL681filt(2),ddsL709filt(2),$
                            ddsCHLfilt(3),ddsCHL2filt(3),ddsKD490filt(3),ddsTSMfilt(3),ddsCDMfilt(3),ddsBBPfilt(3),ddsT865filt(3),$
                            ddsL412filt(3),ddsL443filt(3),ddsL490filt(3),ddsL510filt(3),ddsL531filt(3),ddsL555filt(3),ddsL620filt(3),ddsL670filt(3),ddsL681filt(3),ddsL709filt(3),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",155(F,","),(A,",",A))'
;[-3.1.b] Write macro average data to file----------------------------------------------------------------------------------

                endif

              endif else begin
;[-3.1]-------------------------



;[+3.2] L3 Mapped DDS (All data are in 2-D array form; Lat/Lon are 1-D arrays
              offset=KM2DEG(1.1, inLon(k), inLat(k))    ;Maximum distance from the in-situ location is 1.1km for PC (1km) products
              inDist=SQRT(offset[0]^2. + offset[1]^2.)


                mapped_x=n_elements(dds_data.Lon)
                mapped_y=n_elements(dds_data.Lat)
                subLon=fltarr(mapped_x, mapped_y)
                subLat=fltarr(mapped_x, mapped_y)
                for m=0,mapped_x-1 do for n=0,mapped_y-1 do begin
                    subLon(m,n)=dds_data.Lon(m)
                    subLat(m,n)=dds_data.Lat(n)
                endfor

                p=NearestPoint(subLon, subLat, inLon(k), inLat(k), MaxDist=inDist, nP=2)
                if(n_elements(p) GT 1) then begin
                    nPix=((p(1)-p(0))+1)*((p(3)-p(2))+1)
                    if(nPix GT 1) then begin
                        ddsCHLm=(ddsCHL2m=(ddsKD490m=(ddsTSMm=(ddsCDMm=(ddsBBPm=(ddsT865m=FLTARR(nPix)))))))    ;This is not pixel average value, but the Var associated with 'Mean' tag
                        ddsL412m=(ddsL443m=(ddsL490m=(ddsL510m=(ddsL531m=(ddsL555m=(ddsL620m=(ddsL670m=(ddsL681m=(ddsL709m=FLTARR(nPix))))))))))
                        ddsCHLf=(ddsCHL2f=(ddsKD490f=(ddsTSMf=(ddsCDMf=(ddsBBPf=(ddsT865f=MAKE_ARRAY(nPix,Value=1)))))))    ;FLAGS
                        ddsL412f=(ddsL443f=(ddsL490f=(ddsL510f=(ddsL531f=(ddsL555f=(ddsL620f=(ddsL670f=(ddsL681f=(ddsL709f=MAKE_ARRAY(nPix,Value=1))))))))))

                        ddsLon=REFORM(subLon(p(0):p(1),p(2):p(3)),nPix)
                        ddsLat=REFORM(subLat(p(0):p(1),p(2):p(3)),nPix)

                        if(TOTAL(strmatch(dds_tags,'CHL1_VALUE'))) then ddsCHLm=REFORM(dds_data.CHL1_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CHL1_FLAGS'))) then ddsCHLf=UINT(REFORM(dds_data.CHL1_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'CHL2_VALUE'))) then ddsCHL2m=REFORM(dds_data.CHL2_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CHL2_FLAGS'))) then ddsCHL2f=UINT(REFORM(dds_data.CHL2_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'KD490_VALUE'))) then ddsKD490m=REFORM(dds_data.KD490_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'KD490_FLAGS'))) then ddsKD490f=UINT(REFORM(dds_data.KD490_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'TSM_VALUE'))) then ddsTSMm=REFORM(dds_data.TSM_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'TSM_FLAGS'))) then ddsTSMf=UINT(REFORM(dds_data.TSM_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'CDM_VALUE'))) then ddsCDMm=REFORM(dds_data.CDM_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'CDM_FLAGS'))) then ddsCDMf=UINT(REFORM(dds_data.CDM_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'BBP_VALUE'))) then ddsBBPm=REFORM(dds_data.BBP_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'BBP_FLAGS'))) then ddsBBPf=UINT(REFORM(dds_data.BBP_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'T865_VALUE'))) then ddsT865m=REFORM(dds_data.T865_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'T865_FLAGS'))) then ddsT865f=UINT(REFORM(dds_data.T865_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L412_VALUE'))) then ddsL412m=REFORM(dds_data.L412_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L412_FLAGS'))) then ddsL412f=UINT(REFORM(dds_data.L412_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L443_VALUE'))) then ddsL443m=REFORM(dds_data.L443_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L443_FLAGS'))) then ddsL443f=UINT(REFORM(dds_data.L443_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L490_VALUE'))) then ddsL490m=REFORM(dds_data.L490_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L490_FLAGS'))) then ddsL490f=UINT(REFORM(dds_data.L490_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L510_VALUE'))) then ddsL510m=REFORM(dds_data.L510_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L510_FLAGS'))) then ddsL510f=UINT(REFORM(dds_data.L510_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L531_VALUE'))) then ddsL531m=REFORM(dds_data.L531_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L531_FLAGS'))) then ddsL531f=UINT(REFORM(dds_data.L531_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L555_VALUE'))) then ddsL555m=REFORM(dds_data.L555_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L555_FLAGS'))) then ddsL555f=UINT(REFORM(dds_data.L555_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L620_VALUE'))) then ddsL620m=REFORM(dds_data.L620_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L620_FLAGS'))) then ddsL620f=UINT(REFORM(dds_data.L620_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L670_VALUE'))) then ddsL670m=REFORM(dds_data.L670_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L670_FLAGS'))) then ddsL670f=UINT(REFORM(dds_data.L670_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L681_VALUE'))) then ddsL681m=REFORM(dds_data.L681_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L681_FLAGS'))) then ddsL681f=UINT(REFORM(dds_data.L681_FLAGS(p(0):p(1),p(2):p(3)),nPix))

                        if(TOTAL(strmatch(dds_tags,'L709_VALUE'))) then ddsL709m=REFORM(dds_data.L709_VALUE(p(0):p(1),p(2):p(3)),nPix)
                        if(TOTAL(strmatch(dds_tags,'L709_FLAGS'))) then ddsL709f=UINT(REFORM(dds_data.L709_FLAGS(p(0):p(1),p(2):p(3)),nPix))


;[+3.2.a] Write extracted pixel to file----------------------------------------------------------------------------------
                        for pp=0, nPix-1 do begin
                        printf,7,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLat(pp),ddsLon(pp),$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLm(pp),ddsCHL2m(pp),ddsKD490m(pp),ddsTSMm(pp),ddsCDMm(pp),ddsBBPm(pp),ddsT865m(pp),$
                            ddsL412m(pp),ddsL443m(pp),ddsL490m(pp),ddsL510m(pp),ddsL531m(pp),ddsL555m(pp),ddsL620m(pp),ddsL670m(pp),ddsL681m(pp),ddsL709m(pp),$
                            ddsCHLf(pp),ddsCHL2f(pp),ddsKD490f(pp),ddsTSMf(pp),ddsCDMf(pp),ddsBBPf(pp),ddsT865f(pp),$
                            ddsL412f(pp),ddsL443f(pp),ddsL490f(pp),ddsL510f(pp),ddsL531f(pp),ddsL555f(pp),ddsL620f(pp),ddsL670f(pp),ddsL681f(pp),ddsL709f(pp),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",36(F,","),18(A,","),A)'
                        endfor
;[-3.2.a] Write extracted pixel to file----------------------------------------------------------------------------------

;Initiate variable average, median, stdev for extracted pixels
                        ddsLonav=(ddsLatav=(ddsCHLav=(ddsCHL2av=(ddsKD490av=(ddsTSMav=(ddsCDMav=(ddsBBPav=(ddsT865av=!Values.F_NaN))))))))    ;Average of extracted pixels
                        ddsL412av=(ddsL443av=(ddsL490av=(ddsL510av=(ddsL531av=(ddsL555av=(ddsL620av=(ddsL670av=(ddsL681av=(ddsL709av=!Values.F_NaN)))))))))
                        ddsLonmd=(ddsLatmd=(ddsCHLmd=(ddsCHL2md=(ddsKD490md=(ddsTSMmd=(ddsCDMmd=(ddsBBPmd=(ddsT865md=!Values.F_NaN))))))))    ;Median of extracted pixels
                        ddsL412md=(ddsL443md=(ddsL490md=(ddsL510md=(ddsL531md=(ddsL555md=(ddsL620md=(ddsL670md=(ddsL681md=(ddsL709md=!Values.F_NaN)))))))))
                        ddsLonsd=(ddsLatsd=(ddsCHLsd=(ddsCHL2sd=(ddsKD490sd=(ddsTSMsd=(ddsCDMsd=(ddsBBPsd=(ddsT865sd=!Values.F_NaN))))))))    ;Standard deviation of extracted pixels
                        ddsL412sd=(ddsL443sd=(ddsL490sd=(ddsL510sd=(ddsL531sd=(ddsL555sd=(ddsL620sd=(ddsL670sd=(ddsL681sd=(ddsL709sd=!Values.F_NaN)))))))))

                        ddsCHLfilt=(ddsCHL2filt=(ddsKD490filt=(ddsTSMfilt=(ddsCDMfilt=(ddsBBPfilt=(ddsT865filt=MAKE_ARRAY(4,Value=!Values.F_NaN)))))))
                        ddsL412filt=(ddsL443filt=(ddsL490filt=(ddsL510filt=(ddsL531filt=(ddsL555filt=(ddsL620filt=(ddsL670filt=(ddsL681filt=(ddsL709filt=MAKE_ARRAY(4,Value=!Values.F_NaN))))))))))


                        c1_msk=(c2_msk=(kd_msk=(tsm_msk=(cdm_msk=(bbp_msk=(t865_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0))))))))
                        L412_msk=(L443_msk=(L490_msk=(L510_msk=(L531_msk=(L555_msk=(L620_msk=(L670_msk=(L681_msk=(L709_msk=(MAKE_ARRAY(nPix,/BYTE,VALUE=0)))))))))))

                        for pp=0, nPix-1 do begin
                          flg=gcDDSFLAG2Name(ddsCHLf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4)) then c1_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCHL2f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LE 4)) then c2_msk(pp)=1   ;(df LT 4)
                          flg=gcDDSFLAG2Name(ddsKD490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (tf EQ 0) and (cf LT 4) and (df LT 4)) then kd_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsTSMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then tsm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsCDMf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then cdm_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsBBPf(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then bbp_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsT865f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then t865_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL412f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L412_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL443f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L443_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL490f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L490_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL510f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L510_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL531f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L531_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL555f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L555_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL620f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L620_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL670f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L670_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL681f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L681_msk(pp)=1
                          flg=gcDDSFLAG2Name(ddsL709f(pp), DEPTH=df, CLOUD=cf, TURBID=tf, VALID=vf)
                            if((vf EQ 1) and (cf LT 4) and (df LE 4)) then L709_msk(pp)=1
                        endfor

                        momddsLon=MOMENT(ddsLon,SDEV=ddsLonsd)
                        ddsLonav=momddsLon(0)
                        ;ddsLonmd=MEDIAN(ddsLon)
                        momddsLat=MOMENT(ddsLat,SDEV=ddsLatsd)
                        ddsLatav=momddsLat(0)
                        ;ddsLatmd=MEDIAN(ddsLat)

                        if(strcmp(input_file_tag,'LAC')) then NGP=13 else NGP=2
                        ;cvar=0.2    ;Set Coefficient of variation

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        ;print,'C1_MSK',total(c1_msk)
                        ;print,'L3_MSK',total(L490_msk)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        if(total(c1_msk) GE 2) then begin
                            momddsCHL=MOMENT(ddsCHLm(where(c1_msk)),SDEV=ddsCHLsd)
                            ddsCHLav=momddsCHL(0)
                            ddsCHLmd=MEDIAN(ddsCHLm(where(c1_msk)))
                            if(total(c1_msk) GE NGP) then ddsCHLfilt=FILTERED_AVERAGE(ddsCHLm(where(c1_msk)),CV=cvar)
                        endif
                        if(total(c2_msk) GE 2) then begin
                            momddsCHL2=MOMENT(ddsCHL2m(where(c2_msk)),SDEV=ddsCHL2sd)
                            ddsCHL2av=momddsCHL2(0)
                            ddsCHL2md=MEDIAN(ddsCHL2m(where(c2_msk)))
                            if(total(c2_msk) GE NGP) then ddsCHL2filt=FILTERED_AVERAGE(ddsCHL2m(where(c2_msk)),CV=cvar)
                        endif
                        if(total(kd_msk) GE 2) then begin
                            momddsKD490=MOMENT(ddsKD490m(where(kd_msk)),SDEV=ddsKD490sd)
                            ddsKD490av=momddsKD490(0)
                            ddsKD490md=MEDIAN(ddsKD490m(where(kd_msk)))
                            if(total(kd_msk) GE NGP) then ddsKD490filt=FILTERED_AVERAGE(ddsKD490m(where(kd_msk)),CV=cvar)
                        endif
                        if(total(tsm_msk) GE 2) then begin
                            momddsTSM=MOMENT(ddsTSMm(where(tsm_msk)),SDEV=ddsTSMsd)
                            ddsTSMav=momddsTSM(0)
                            ddsTSMmd=MEDIAN(ddsTSMm(where(tsm_msk)))
                            if(total(tsm_msk) GE NGP) then ddsTSMfilt=FILTERED_AVERAGE(ddsTSMm(where(tsm_msk)),CV=cvar)
                        endif
                        if(total(cdm_msk) GE 2) then begin
                            momddsCDM=MOMENT(ddsCDMm(where(cdm_msk)),SDEV=ddsCDMsd)
                            ddsCDMav=momddsCDM(0)
                            ddsCDMmd=MEDIAN(ddsCDMm(where(cdm_msk)))
                            if(total(cdm_msk) GE NGP) then ddsCDMfilt=FILTERED_AVERAGE(ddsCDMm(where(cdm_msk)),CV=cvar)
                        endif
                        if(total(bbp_msk) GE 2) then begin
                            momddsBBP=MOMENT(ddsBBPm(where(bbp_msk)),SDEV=ddsBBPsd)
                            ddsBBPav=momddsBBP(0)
                            ddsBBPmd=MEDIAN(ddsBBPm(where(bbp_msk)))
                            if(total(bbp_msk) GE NGP) then ddsBBPfilt=FILTERED_AVERAGE(ddsBBPm(where(bbp_msk)),CV=cvar)
                        endif
                        if(total(t865_msk) GE 2) then begin
                            momddsT865=MOMENT(ddsT865m(where(t865_msk)),SDEV=ddsT865sd)
                            ddsT865av=momddsT865(0)
                            ddsT865md=MEDIAN(ddsT865m(where(t865_msk)))
                            if(total(t865_msk) GE NGP) then ddsT865filt=FILTERED_AVERAGE(ddsT865m(where(t865_msk)),CV=cvar)
                        endif
                        if(total(L412_msk) GE 2) then begin
                            momddsL412=MOMENT(ddsL412m(where(L412_msk)),SDEV=ddsL412sd)
                            ddsL412av=momddsL412(0)
                            ddsL412md=MEDIAN(ddsL412m(where(L412_msk)))
                            if(total(L412_msk) GE NGP) then ddsL412filt=FILTERED_AVERAGE(ddsL412m(where(L412_msk)),CV=cvar)
                        endif
                        if(total(L443_msk) GE 2) then begin
                            momddsL443=MOMENT(ddsL443m(where(L443_msk)),SDEV=ddsL443sd)
                            ddsL443av=momddsL443(0)
                            ddsL443md=MEDIAN(ddsL443m(where(L443_msk)))
                            if(total(L443_msk) GE NGP) then ddsL443filt=FILTERED_AVERAGE(ddsL443m(where(L443_msk)),CV=cvar)
                        endif
                        if(total(L490_msk) GE 2) then begin
                            momddsL490=MOMENT(ddsL490m(where(L490_msk)),SDEV=ddsL490sd)
                            ddsL490av=momddsL490(0)
                            ddsL490md=MEDIAN(ddsL490m(where(L490_msk)))
                            if(total(L490_msk) GE NGP) then ddsL490filt=FILTERED_AVERAGE(ddsL490m(where(L490_msk)),CV=cvar)
                        endif
                        if(total(L510_msk) GE 2) then begin
                            momddsL510=MOMENT(ddsL510m(where(L510_msk)),SDEV=ddsL510sd)
                            ddsL510av=momddsL510(0)
                            ddsL510md=MEDIAN(ddsL510m(where(L510_msk)))
                            if(total(L510_msk) GE NGP) then ddsL510filt=FILTERED_AVERAGE(ddsL510m(where(L510_msk)),CV=cvar)
                        endif
                        if(total(L531_msk) GE 2) then begin
                            momddsL531=MOMENT(ddsL531m(where(L531_msk)),SDEV=ddsL531sd)
                            ddsL531av=momddsL531(0)
                            ddsL531md=MEDIAN(ddsL531m(where(L531_msk)))
                            if(total(L531_msk) GE NGP) then ddsL531filt=FILTERED_AVERAGE(ddsL531m(where(L531_msk)),CV=cvar)
                        endif
                        if(total(L555_msk) GE 2) then begin
                            momddsL555=MOMENT(ddsL555m(where(L555_msk)),SDEV=ddsL555sd)
                            ddsL555av=momddsL555(0)
                            ddsL555md=MEDIAN(ddsL555m(where(L555_msk)))
                            if(total(L555_msk) GE NGP) then ddsL555filt=FILTERED_AVERAGE(ddsL555m(where(L555_msk)),CV=cvar)
                        endif
                        if(total(L620_msk) GE 2) then begin
                            momddsL620=MOMENT(ddsL620m(where(L620_msk)),SDEV=ddsL620sd)
                            ddsL620av=momddsL620(0)
                            ddsL620md=MEDIAN(ddsL620m(where(L620_msk)))
                            if(total(L620_msk) GE NGP) then ddsL620filt=FILTERED_AVERAGE(ddsL620m(where(L620_msk)),CV=cvar)
                        endif
                        if(total(L670_msk) GE 2) then begin
                            momddsL670=MOMENT(ddsL670m(where(L670_msk)),SDEV=ddsL670sd)
                            ddsL670av=momddsL670(0)
                            ddsL670md=MEDIAN(ddsL670m(where(L670_msk)))
                            if(total(L670_msk) GE NGP) then ddsL670filt=FILTERED_AVERAGE(ddsL670m(where(L670_msk)),CV=cvar)
                        endif
                        if(total(L681_msk) GE 2) then begin
                            momddsL681=MOMENT(ddsL681m(where(L681_msk)),SDEV=ddsL681sd)
                            ddsL681av=momddsL681(0)
                            ddsL681md=MEDIAN(ddsL681m(where(L681_msk)))
                            if(total(L681_msk) GE NGP) then ddsL681filt=FILTERED_AVERAGE(ddsL681m(where(L681_msk)),CV=cvar)
                        endif
                        if(total(L709_msk) GE 2) then begin
                            momddsL709=MOMENT(ddsL709m(where(L709_msk)),SDEV=ddsL709sd)
                            ddsL709av=momddsL709(0)
                            ddsL709md=MEDIAN(ddsL709m(where(L709_msk)))
                            if(total(L709_msk) GE NGP) then ddsL709filt=FILTERED_AVERAGE(ddsL709m(where(L709_msk)),CV=cvar)
                        endif


;[+3.2.b] Write macro average data to file----------------------------------------------------------------------------------
                        printf,8,insitu_data.ID(day_match(k)),YMDhms2isoTIME(insitu_data.Year(day_match(k)),insitu_data.Month(day_match(k)),insitu_data.Date(day_match(k)),insitu_data.Hour(day_match(k)),insitu_data.Minute(day_match(k))),$
                            inLat(k),inLon(k),dds_time,ddsLatav,ddsLonav,$
                            insituChl(day_match(k)),insituChl_flag(day_match(k)),insitu_data.Kd490(day_match(k)),insitu_data.TSM(day_match(k)),insitu_data.acdm443(day_match(k)),insitu_data.bbp443(day_match(k)),$
                            insitu_data.T865(day_match(k)),$
                            insitu_data.exLwn412(day_match(k)),insitu_data.exLwn443(day_match(k)),insitu_data.exLwn490(day_match(k)),insitu_data.exLwn510(day_match(k)),insitu_data.exLwn531(day_match(k)),$
                            insitu_data.exLwn555(day_match(k)),insitu_data.exLwn620(day_match(k)),insitu_data.exLwn670(day_match(k)),insitu_data.exLwn681(day_match(k)),insitu_data.exLwn709(day_match(k)),$
                            ddsCHLav,ddsCHL2av,ddsKD490av,ddsTSMav,ddsCDMav,ddsBBPav,ddsT865av,$
                            ddsL412av,ddsL443av,ddsL490av,ddsL510av,ddsL531av,ddsL555av,ddsL620av,ddsL670av,ddsL681av,ddsL709av,$
                            ddsCHLmd,ddsCHL2md,ddsKD490md,ddsTSMmd,ddsCDMmd,ddsBBPmd,ddsT865md,$
                            ddsL412md,ddsL443md,ddsL490md,ddsL510md,ddsL531md,ddsL555md,ddsL620md,ddsL670md,ddsL681md,ddsL709md,$
                            ddsCHLsd,ddsCHL2sd,ddsKD490sd,ddsTSMsd,ddsCDMsd,ddsBBPsd,ddsT865sd,$
                            ddsL412sd,ddsL443sd,ddsL490sd,ddsL510sd,ddsL531sd,ddsL555sd,ddsL620sd,ddsL670sd,ddsL681sd,ddsL709sd,$
                            total(c1_msk),total(c2_msk),total(kd_msk),total(tsm_msk),total(cdm_msk),total(bbp_msk),total(t865_msk),$
                            total(L412_msk),total(L443_msk),total(L490_msk),total(L510_msk),total(L531_msk),total(L555_msk),total(L620_msk),total(L670_msk),total(L681_msk),total(L709_msk),$
                            ddsCHLfilt(0),ddsCHL2filt(0),ddsKD490filt(0),ddsTSMfilt(0),ddsCDMfilt(0),ddsBBPfilt(0),ddsT865filt(0),$
                            ddsL412filt(0),ddsL443filt(0),ddsL490filt(0),ddsL510filt(0),ddsL531filt(0),ddsL555filt(0),ddsL620filt(0),ddsL670filt(0),ddsL681filt(0),ddsL709filt(0),$
                            ddsCHLfilt(1),ddsCHL2filt(1),ddsKD490filt(1),ddsTSMfilt(1),ddsCDMfilt(1),ddsBBPfilt(1),ddsT865filt(1),$
                            ddsL412filt(1),ddsL443filt(1),ddsL490filt(1),ddsL510filt(1),ddsL531filt(1),ddsL555filt(1),ddsL620filt(1),ddsL670filt(1),ddsL681filt(1),ddsL709filt(1),$
                            ddsCHLfilt(2),ddsCHL2filt(2),ddsKD490filt(2),ddsTSMfilt(2),ddsCDMfilt(2),ddsBBPfilt(2),ddsT865filt(2),$
                            ddsL412filt(2),ddsL443filt(2),ddsL490filt(2),ddsL510filt(2),ddsL531filt(2),ddsL555filt(2),ddsL620filt(2),ddsL670filt(2),ddsL681filt(2),ddsL709filt(2),$
                            ddsCHLfilt(3),ddsCHL2filt(3),ddsKD490filt(3),ddsTSMfilt(3),ddsCDMfilt(3),ddsBBPfilt(3),ddsT865filt(3),$
                            ddsL412filt(3),ddsL443filt(3),ddsL490filt(3),ddsL510filt(3),ddsL531filt(3),ddsL555filt(3),ddsL620filt(3),ddsL670filt(3),ddsL681filt(3),ddsL709filt(3),$
                            ddsFile[0],input_file_tag,$
                            FORMAT='(2(A,","),2(F,","),A,",",155(F,","),(A,",",A))'
;[-3.2.b] Write macro average data to file----------------------------------------------------------------------------------


                    endif   ;if(nPix GT 1) then begin
                endif   ;(n_elements(p) GT 1) then begin
              endelse
;[-3.2]----------------

            endfor   ;for k=0,nr-1 do begin
         endif else $  ;if(nr GT 0) then begin
         print,ddsFile+" matches with "+string(nr)+" in-situ record(s) for same day."
       endfor   ;for i=0,nMER-1 do begin
    endif   ;if((Sensor EQ 1 or Sensor EQ 4) and nMER GT 0) then begin
;[-3]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END MERIS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


endelse

close,/all
print,string(10b)+'FINISH.'+string(10b)
;stop

END