PRO matchup_Stat_GlobColour, Max_Time_Diff=mtd, CATCH_DUPLICATES=catch_duplicates, SHOW=show


;+
;NAME:
;   matchup_Stat_GlobColour
;PURPOSE:
;   Compute stat summary from GlobColour DDS 1km and Global 4km data match-up with in-situ data.
;SYNTAX:
;   matchup_Stat_GlobColour [,Max_Time_Diff=value] [,/catch_duplicates] [,/show]
;INPUT FILE:
;   '....DDS_Match_average.csv'
;OUTPUTS:
;   '..._DDS_Match_summary1.csv'
;   '..._DDS_Match_summary1.csv'
;   '..._DDS_Match_average.eps'
;
;KEYWORDS:
;   Max_Time_Diff -> Maximum allowed time difference between in-situ and satellite observation (in hours); default [12]
;   catch_duplicates -> Flags duplicate entried in the match-up file based on inID
;   show -> shows the stat plots

;Author: Yaswant Pradhan
;Last modification: Mar 07, Apr'07 (show keyword is not mandatory to write the eps file)
;-

close,/all


;--------------------
;++Global parameters

 if(~KEYWORD_SET(mtd)) then mtd=12.0    ;Maximu Time difference
 if(KEYWORD_SET(catch_duplicates)) then noDup=1B else noDup=0B
 cvar = 0.2   ;Coefficient of variation is already used in the calculation of FILTERED_AVERAGE from l3m files


;++Machine Dependency
lilEndian=(BYTE(1,0,1))[0]
if(lilEndian) then separator='\' else separator='/'
;--Machine Dependency

;--Global parameters
;--------------------


;---------------------------------
;+Average File template
avg_template={$
 VERSION : 1.0,$
 DATASTART : 1,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 162,$
 FIELDTYPES : [7,7,4,4,7,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4, $
          4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4, $
          4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4, $
          4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,7,7],$
 FIELDNAMES : ['inID','inTime','inLat','inLon','ddsTime','ddsLat','ddsLon','inChl','inChl_Flag','inK490','inTSM','inaCDM','inBBP','inT865','inL412','inL443','inL490','inL510','inL531','inL555','inL620','inL670','inL681','inL709', $
 'ddsChl1_avg','ddsChl2_avg','ddsK490_avg','ddsTSM_avg','ddsaCDM_avg','ddsBBP_avg','ddsT865_avg','ddsL412_avg','ddsL443_avg','ddsL490_avg','ddsL510_avg','ddsL531_avg','ddsL555_avg','ddsL620_avg','ddsL670_avg','ddsL681_avg','ddsL709_avg', $
 'ddsChl1_med','ddsChl2_med','ddsK490_med','ddsTSM_med','ddsaCDM_med','ddsBBP_med','ddsT865_med','ddsL412_med','ddsL443_med','ddsL490_med','ddsL510_med','ddsL531_med','ddsL555_med','ddsL620_med','ddsL670_med','ddsL681_med','ddsL709_med', $
 'ddsChl1_std','ddsChl2_std','ddsK490_std','ddsTSM_std','ddsaCDM_std','ddsBBP_std','ddsT865_std','ddsL412_std','ddsL443_std','ddsL490_std','ddsL510_std','ddsL531_std','ddsL555_std','ddsL620_std','ddsL670_std','ddsL681_std','ddsL709_std', $
 'ddsChl1_N','ddsChl2_N','ddsK490_N','ddsTSM_N','ddsaCDM_N','ddsBBP_N','ddsT865_N','ddsL412_N','ddsL443_N','ddsL490_N','ddsL510_N','ddsL531_N','ddsL555_N','ddsL620_N','ddsL670_N','ddsL681_N','ddsL709_N', $
 'ddsChl1_avg2','ddsChl2_avg2','ddsK490_avg2','ddsTSM_avg2','ddsaCDM_avg2','ddsBBP_avg2','ddsT865_avg2', $
 'ddsL412_avg2','ddsL443_avg2','ddsL490_avg2','ddsL510_avg2','ddsL531_avg2','ddsL555_avg2','ddsL620_avg2','ddsL670_avg2','ddsL681_avg2','ddsL709_avg2', $
 'ddsChl1_med2','ddsChl2_med2','ddsK490_med2','ddsTSM_med2','ddsaCDM_med2','ddsBBP_med2','ddsT865_med2', $
 'ddsL412_med2','ddsL443_med2','ddsL490_med2','ddsL510_med2','ddsL531_med2','ddsL555_med2','ddsL620_med2','ddsL670_med2','ddsL681_med2','ddsL709_med2', $
 'ddsChl1_std2','ddsChl2_std2','ddsK490_std2','ddsTSM_std2','ddsaCDM_std2','ddsBBP_std2','ddsT865_std2', $
 'ddsL412_std2','ddsL443_std2','ddsL490_std2','ddsL510_std2','ddsL531_std2','ddsL555_std2','ddsL620_std2','ddsL670_std2','ddsL681_std2','ddsL709_std2', $
 'ddsChl1_N2','ddsChl2_N2','ddsK490_N2','ddsTSM_N2','ddsaCDM_N2','ddsBBP_N2','ddsT865_N2','ddsL412_N2','ddsL443_N2','ddsL490_N2','ddsL510_N2','ddsL531_N2','ddsL555_N2','ddsL620_N2','ddsL670_N2','ddsL681_N2','ddsL709_N2', $
 'ddsFilename','Input_file_Tag'],$
 FIELDLOCATIONS : [0,11,28,44,60,77,93,109,135,161,187,213,239,265,291,317,343,369,395,421,447,473,499,525,551,567,583,599,615,631,647,663,679,695,711,727,743,759,775,791,807,823,839,855,871, $
 887,903,919,935,951,967,983,999,1015,1031,1047,1063,1079,1095,1111,1127,1143,1159,1175,1191,1207,1223,1239,1255,1271,1287,1303,1319,1335,1351,1367,1383,1399,1415,1431,1447,1463,1479,1495, $
 1511,1527,1543,1559,1575,1591,1607,1623,1639,1655,1671,1687,1703,1719,1735,1751,1767,1783,1799,1815,1831,1847,1863,1879,1895,1911,1927,1943,1959,1975,1991,2007,2023,2039,2055,2071,2087, $
 2103,2119,2135,2151,2167,2183,2199,2215,2231,2247,2263,2279,2295,2311,2327,2343,2359,2375,2391,2407,2423,2439,2455,2471,2487,2503,2519,2535,2551,2567,2583,2599,2615,2631,2647,2663, $
 2679,2695,2711,2727,2778], $
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50, $
 51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102, $
 103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142, $
 143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161] }
;-Average File template
;---------------------------------
;stop
;--------------------------------------
;+Read data and records to a structure
 filename=DIALOG_PICKFILE(/READ,FILTER="*_Match_average.csv",TITLE='SELECT GlobCOLOUR Match_Average CSV FILE',GET_PATH=cwd)
 if(STRCMP(filename,'')) then begin
   print,'Error! Insitu file was not selected.'
   retall
 endif  ;if(STRCMP(filename,'')) then begin
 ;CD,FILE_DIRNAME(filename), CURR=dir
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 newdir=cwd+file_basename(filename,'_average.csv')+'_summary__'+file_basename(cwd,'_MatchUp')
 FILE_MKDIR,newdir
 CD,newdir
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 data=READ_ASCII(filename,TEMPLATE=avg_template)
 file_rows=FILE_LINES(filename)
 records=file_rows - avg_template.DATASTART
 tmp=strsplit(file_basename(filename),'_',/extract)
 sen_name=tmp[2]    ;Sensor Name
;-Read data and records to a structure
;--------------------------------------

!EXCEPT=0   ;Avoid confusing math error message while handling NaNs

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;+Flag Duplicate records as NaN [Tested OK.]
if(noDup) then begin

  for i=0, records-1 do begin
    wh=where(strcmp(data.inID[i], data.inID),cnt)
      if(cnt GT 1) then begin
      print,'[CATCH_DUPLICATE] First duplicate records found at record number',i+1,wh+1
        tot=intarr(cnt)
        for m=0,cnt-1 do tot(m)=total([data.ddsChl1_N2[wh(m)],data.ddsChl2_N2[wh(m)],data.ddsK490_N2[wh(m)],$
            data.ddsTSM_N2[wh(m)],data.ddsaCDM_N2[wh(m)],data.ddsBBP_N2[wh(m)],data.ddsT865_N2[wh(m)],$
            data.ddsL412_N2[wh(m)],data.ddsL443_N2[wh(m)],data.ddsL490_N2[wh(m)],data.ddsL510_N2[wh(m)],$
            data.ddsL531_N2[wh(m)],data.ddsL555_N2[wh(m)],data.ddsL620_N2[wh(m)],data.ddsL670_N2[wh(m)],$
            data.ddsL681_N2[wh(m)],data.ddsL709_N2[wh(m)]],/NaN)
        r=where(tot EQ max(tot), complement=x)
        if(total(x) GE 0) then begin
          for k=0,n_tags(data)-1 do data.(k)[wh(x)]=!Values.F_NaN
          data.inTime[wh(x)]='00000000T000000Z' ;To avoid the type conversion error message
          data.ddsTime[wh(x)]='00000000T000000Z'
        endif else begin
          dist=fltarr(cnt)
          for m=0,cnt-1 do begin
            diffLat=data.inLat[wh(m)]-data.ddsLat[wh(m)]
            diffLon=data.inLon[wh(m)]-data.ddsLon[wh(m)]
            dist(m)=sqrt(diffLon^2. + diffLat^2.)
          endfor
          r=where(dist EQ min(dist), complement=x)
          if(total(x) GE 0) then begin
            for k=0,n_tags(data)-1 do data.(k)[wh(x)]=!Values.F_NaN
            data.inTime[wh(x)]='00000000T000000Z'   ;To avoid the type conversion error message
            data.ddsTime[wh(x)]='00000000T000000Z'
          endif
        endelse
      endif
  endfor

endif
;-Flag Duplicate records as NaN
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;stop
;----------------------------------------
;+Open output stat summary files
 openw,1,file_basename(filename,'average.csv')+'summary1.csv'
 printf,1,'PROD,N,SLOPE,INTCPT,r^2,MEAN_RATIO,MEDIAN_RATIO,MEAN%DIFF,MEDIAN%DIFF,MEAN_BIAS,RMS,REL_BIAS,REL_RMS,IN-SITU_RANGE,,SAT_RANGE,'

 openw,2,file_basename(filename,'average.csv')+'summary2.csv'
 printf,2,'PROD,N,SLOPE,INTCPT,r^2,MEAN_RATIO,MEDIAN_RATIO,MEAN%DIFF,MEDIAN%DIFF,MEAN_BIAS,RMS,REL_BIAS,REL_RMS,IN-SITU_RANGE,,SAT_RANGE,'

;-Open output stat summary files
;-----------------------------------------

;---------------------------------------------
;+Set device as postscript for plotting [3col, 5rows]
 ;if(KEYWORD_SET(show)) then begin
    SET_PLOT, 'PS'
    psFileName=FILE_BASENAME(filename,'csv')+'eps'
    DEVICE, /COLOR,/ENCAPSUL,xSize=24.,ySize=80,BITS_PER_PIXEL=8,FILENAME=psFileName
    !P.MULTI = [0, 3, 10]
 ;endif  ;if(KEYWORD_SET(show)) then begin
;-Set device as postscript for plotting [3col, 5rows]
;---------------------------------------------

;-------------------------------------------------
;+Get data index satisfying the max_time_diff
 inTime=(ddsTime=(tDiff=fltarr(records)))
 for i=0,records-1 do begin
    inTime(i)=fix(strmid(data.inTime(i),9,2)) + fix(strmid(data.inTime(i),11,2))/60.
    ddsTime(i)=fix(strmid(data.ddsTime(i),9,2)) + fix(strmid(data.ddsTime(i),11,2))/60.
    tDiff(i)=abs(ddsTime(i) - inTime(i))
 endfor ;for i=0,records-1 do begin
 p=where(tdiff LE mtd, cnt1)
;-Get data index satisfying the max_time_diff
;-------------------------------------------------

 if(cnt1 GT 0) then begin

 ;+1. CHL1
 ;+1.1 With standard average data
    inChl=data.inChl(p)
    ddsCHL1_a = data.ddsCHL1_avg(p)
    ddsCHL1_s = data.ddsCHL1_std(p)
    pp=where(inChl GT 0. and ddsCHL1_a GT 0 and (ddsCHL1_s/ddsCHL1_a) LT cvar, nCHL1_a)
    if(nCHL1_a GE 2) then begin
       inChl1 = inChl(pp)
       ddsCHL1_a = ddsCHL1_a(pp)
       ddsCHL1_s = ddsCHL1_s(pp)

       fit_CHL1_a = [LINFIT(alog10(inChl1),alog10(ddsCHL1_a)), (CORRELATE(alog10(inChl1),alog10(ddsCHL1_a),/DOUBLE))^2.]
       relrms_CHL1_a = sqrt(mean(alog10(ddsCHL1_a/inChl1)^2.))   ;Relative RMS
       relbias_CHL1_a = mean(alog10(ddsCHL1_a/inChl1))   ;Relative bias
       rms_CHL1_a = sqrt(mean((ddsCHL1_a-inChl1)^2.))    ;Not to be considered for CHL1
       bias_CHL1_a = mean(ddsCHL1_a-inChl1)          ;Not to be considered for CHL1

       avgratio_CHL1_a = mean(ddsCHL1_a/inChl1)   ;Mean Ratio
       medratio_CHL1_a = median(ddsCHL1_a/inChl1)    ;Median Ratio
       avgpd_CHL1_a = mean(abs((ddsCHL1_a-inChl1)/inChl1))*100.   ;Mean % diff
       medpd_CHL1_a = median(abs((ddsCHL1_a-inChl1)/inChl1))*100. ;Median % diff
       range_inChl1 = [min(inChl1),max(inChl1)]    ;in-situ range
       range_ddsCHL1_a = [min(ddsCHL1_a),max(ddsCHL1_a)]    ;DDS range

       printf,1,'CHL1',nCHL1_a,fit_CHL1_a(1),fit_CHL1_a(0),fit_CHL1_a(2),avgratio_CHL1_a,medratio_CHL1_a, $
               avgpd_CHL1_a,medpd_CHL1_a,bias_CHL1_a,rms_CHL1_a,relbias_CHL1_a,relrms_CHL1_a, $
               range_inChl1,range_ddsCHL1_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nCHL1_a GT 0) then begin
;-1.1 With standard average data
;+1.2 With filtered average data
    inChl=data.inChl(p)
    ddsCHL1_a2 = data.ddsCHL1_avg2(p)
    ddsCHL1_s2 = data.ddsCHL1_std2(p)
    pp=where(inChl GT 0. and ddsCHL1_a2 GT 0, nCHL1_a2)
    if(nCHL1_a2 GE 2) then begin
       inChl12 = inChl(pp)
       ddsCHL1_a2 = ddsCHL1_a2(pp)
       ddsCHL1_s2 = ddsCHL1_s2(pp)

       fit_CHL1_a2 = [LINFIT(alog10(inChl12),alog10(ddsCHL1_a2)), (CORRELATE(alog10(inChl12),alog10(ddsCHL1_a2),/DOUBLE))^2.]
       relrms_CHL1_a2 = sqrt(mean(alog10(ddsCHL1_a2/inChl12)^2.))   ;Relative RMS
       relbias_CHL1_a2 = mean(alog10(ddsCHL1_a2/inChl12))   ;Relative bias
       rms_CHL1_a2 = sqrt(mean((ddsCHL1_a2-inChl12)^2.))    ;Not to be considered for CHL1
       bias_CHL1_a2 = mean(ddsCHL1_a2-inChl12)          ;Not to be considered for CHL1

       avgratio_CHL1_a2 = mean(ddsCHL1_a2/inChl12)   ;Mean Ratio
       medratio_CHL1_a2 = median(ddsCHL1_a2/inChl12)    ;Median Ratio
       avgpd_CHL1_a2 = mean(abs((ddsCHL1_a2-inChl12)/inChl12))*100.   ;Mean % diff
       medpd_CHL1_a2 = median(abs((ddsCHL1_a2-inChl12)/inChl12))*100. ;Median % diff

       range_inChl12 = [min(inChl12),max(inChl12)]    ;in-situ range
       range_ddsCHL1_a2 = [min(ddsCHL1_a2),max(ddsCHL1_a2)]    ;DDS range


       printf,2,'CHL1',nCHL1_a2,fit_CHL1_a2(1),fit_CHL1_a2(0),fit_CHL1_a2(2),avgratio_CHL1_a2,medratio_CHL1_a2, $
               avgpd_CHL1_a2,medpd_CHL1_a2,bias_CHL1_a2,rms_CHL1_a2,relbias_CHL1_a2,relrms_CHL1_a2, $
               range_inChl12,range_ddsCHL1_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nCHL1_a2 GT 0) then begin
;-1.2 With filtered average data
;-1. CHL1


;+2. CHL2
 ;+2.1 With standard average data
    inChl=data.inChl(p)
    ddsCHL2_a = data.ddsCHL2_avg(p)
    ddsCHL2_s = data.ddsCHL2_std(p)
    pp=where(inChl GT 0. and ddsCHL2_a GT 0 and (ddsCHL2_s/ddsCHL2_a) LT cvar, nCHL2_a)
    if(nCHL2_a GE 2) then begin
       inChl2 = inChl(pp)
       ddsCHL2_a = ddsCHL2_a(pp)
       ddsCHL2_s = ddsCHL2_s(pp)

       fit_CHL2_a = [LINFIT(alog10(inChl2),alog10(ddsCHL2_a)), (CORRELATE(alog10(inChl2),alog10(ddsCHL2_a),/DOUBLE))^2.]
       relrms_CHL2_a = sqrt(mean(alog10(ddsCHL2_a/inChl2)^2.))   ;Relative RMS
       relbias_CHL2_a = mean(alog10(ddsCHL2_a/inChl2))   ;Relative bias
       rms_CHL2_a = sqrt(mean((ddsCHL2_a-inChl2)^2.))    ;Not to be considered for CHL2
       bias_CHL2_a = mean(ddsCHL2_a-inChl2)          ;Not to be considered for CHL2

       avgratio_CHL2_a = mean(ddsCHL2_a/inChl2)   ;Mean Ratio
       medratio_CHL2_a = median(ddsCHL2_a/inChl2)    ;Median Ratio
       avgpd_CHL2_a = mean(abs((ddsCHL2_a-inChl2)/inChl2))*100.   ;Mean % diff
       medpd_CHL2_a = median(abs((ddsCHL2_a-inChl2)/inChl2))*100. ;Median % diff
       range_inChl2 = [min(inChl2),max(inChl2)]    ;in-situ range
       range_ddsCHL2_a = [min(ddsCHL2_a),max(ddsCHL2_a)]    ;DDS range

       printf,1,'CHL2',nCHL2_a,fit_CHL2_a(1),fit_CHL2_a(0),fit_CHL2_a(2),avgratio_CHL2_a,medratio_CHL2_a, $
               avgpd_CHL2_a,medpd_CHL2_a,bias_CHL2_a,rms_CHL2_a,relbias_CHL2_a,relrms_CHL2_a, $
               range_inChl2,range_ddsCHL2_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nCHL2_a GT 0) then begin
;-2.1 With standard average data
;+2.2 With filtered average data
    inChl=data.inChl(p)
    ddsCHL2_a2 = data.ddsCHL2_avg2(p)
    ddsCHL2_s2 = data.ddsCHL2_std2(p)
    pp=where(inChl GT 0. and ddsCHL2_a2 GT 0, nCHL2_a2)
    if(nCHL2_a2 GE 2) then begin
       inChl22 = inChl(pp)
       ddsCHL2_a2 = ddsCHL2_a2(pp)
       ddsCHL2_s2 = ddsCHL2_s2(pp)

       fit_CHL2_a2 = [LINFIT(alog10(inChl22),alog10(ddsCHL2_a2)), (CORRELATE(alog10(inChl22),alog10(ddsCHL2_a2),/DOUBLE))^2.]
       relrms_CHL2_a2 = sqrt(mean(alog10(ddsCHL2_a2/inChl22)^2.))   ;Relative RMS
       relbias_CHL2_a2 = mean(alog10(ddsCHL2_a2/inChl22))   ;Relative bias
       rms_CHL2_a2 = sqrt(mean((ddsCHL2_a2-inChl22)^2.))    ;Not to be considered for CHL2
       bias_CHL2_a2 = mean(ddsCHL2_a2-inChl22)          ;Not to be considered for CHL2

       avgratio_CHL2_a2 = mean(ddsCHL2_a2/inChl22)   ;Mean Ratio
       medratio_CHL2_a2 = median(ddsCHL2_a2/inChl22)    ;Median Ratio
       avgpd_CHL2_a2 = mean(abs((ddsCHL2_a2-inChl22)/inChl22))*100.   ;Mean % diff
       medpd_CHL2_a2 = median(abs((ddsCHL2_a2-inChl22)/inChl22))*100. ;Median % diff

       range_inChl22 = [min(inChl22),max(inChl22)]    ;in-situ range
       range_ddsCHL2_a2 = [min(ddsCHL2_a2),max(ddsCHL2_a2)]    ;DDS range


       printf,2,'CHL2',nCHL2_a2,fit_CHL2_a2(1),fit_CHL2_a2(0),fit_CHL2_a2(2),avgratio_CHL2_a2,medratio_CHL2_a2, $
               avgpd_CHL2_a2,medpd_CHL2_a2,bias_CHL2_a2,rms_CHL2_a2,relbias_CHL2_a2,relrms_CHL2_a2, $
               range_inChl22,range_ddsCHL2_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nCHL2_a2 GT 0) then begin
;-2.2 With filtered average data
;-2. CHL2


;+3. KD490
 ;+3.1 With standard average data
    inK490=data.inK490(p)
    ddsK490_a = data.ddsK490_avg(p)
    ddsK490_s = data.ddsK490_std(p)
    pp=where(inK490 GT 0. and ddsK490_a GT 0 and (ddsK490_s/ddsK490_a) LT cvar, nK490_a)
    if(nK490_a GE 2) then begin
       inK4901 = inK490(pp)
       ddsK490_a = ddsK490_a(pp)
       ddsK490_s = ddsK490_s(pp)

       fit_K490_a = [LINFIT(alog10(inK4901),alog10(ddsK490_a)), (CORRELATE(alog10(inK4901),alog10(ddsK490_a),/DOUBLE))^2.]
       relrms_K490_a = sqrt(mean(alog10(ddsK490_a/inK4901)^2.))   ;Relative RMS
       relbias_K490_a = mean(alog10(ddsK490_a/inK4901))   ;Relative bias
       rms_K490_a = sqrt(mean((ddsK490_a-inK4901)^2.))    ;Not to be considered for K490
       bias_K490_a = mean(ddsK490_a-inK4901)          ;Not to be considered for K490

       avgratio_K490_a = mean(ddsK490_a/inK4901)   ;Mean Ratio
       medratio_K490_a = median(ddsK490_a/inK4901)    ;Median Ratio
       avgpd_K490_a = mean(abs((ddsK490_a-inK4901)/inK4901))*100.   ;Mean % diff
       medpd_K490_a = median(abs((ddsK490_a-inK4901)/inK4901))*100. ;Median % diff
       range_inK4901 = [min(inK4901),max(inK4901)]    ;in-situ range
       range_ddsK490_a = [min(ddsK490_a),max(ddsK490_a)]    ;DDS range

       printf,1,'KD490',nK490_a,fit_K490_a(1),fit_K490_a(0),fit_K490_a(2),avgratio_K490_a,medratio_K490_a, $
               avgpd_K490_a,medpd_K490_a,bias_K490_a,rms_K490_a,relbias_K490_a,relrms_K490_a, $
               range_inK4901,range_ddsK490_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nK490_a GT 0) then begin
;-3.1 With standard average data
;+3.2 With filtered average data
    inK490=data.inK490(p)
    ddsK490_a2 = data.ddsK490_avg2(p)
    ddsK490_s2 = data.ddsK490_std2(p)
    pp=where(inK490 GT 0. and ddsK490_a2 GT 0, nK490_a2)
    if(nK490_a2 GE 2) then begin
       inK4902 = inK490(pp)
       ddsK490_a2 = ddsK490_a2(pp)
       ddsK490_s2 = ddsK490_s2(pp)

       fit_K490_a2 = [LINFIT(alog10(inK4902),alog10(ddsK490_a2)), (CORRELATE(alog10(inK4902),alog10(ddsK490_a2),/DOUBLE))^2.]
       relrms_K490_a2 = sqrt(mean(alog10(ddsK490_a2/inK4902)^2.))   ;Relative RMS
       relbias_K490_a2 = mean(alog10(ddsK490_a2/inK4902))   ;Relative bias
       rms_K490_a2 = sqrt(mean((ddsK490_a2-inK4902)^2.))    ;Not to be considered for K490
       bias_K490_a2 = mean(ddsK490_a2-inK4902)          ;Not to be considered for K490

       avgratio_K490_a2 = mean(ddsK490_a2/inK4902)   ;Mean Ratio
       medratio_K490_a2 = median(ddsK490_a2/inK4902)    ;Median Ratio
       avgpd_K490_a2 = mean(abs((ddsK490_a2-inK4902)/inK4902))*100.   ;Mean % diff
       medpd_K490_a2 = median(abs((ddsK490_a2-inK4902)/inK4902))*100. ;Median % diff

       range_inK4902 = [min(inK4902),max(inK4902)]    ;in-situ range
       range_ddsK490_a2 = [min(ddsK490_a2),max(ddsK490_a2)]    ;DDS range


       printf,2,'KD490',nK490_a2,fit_K490_a2(1),fit_K490_a2(0),fit_K490_a2(2),avgratio_K490_a2,medratio_K490_a2, $
               avgpd_K490_a2,medpd_K490_a2,bias_K490_a2,rms_K490_a2,relbias_K490_a2,relrms_K490_a2, $
               range_inK4902,range_ddsK490_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nK490_a2 GT 0) then begin
;-3.2 With filtered average data
;-3. KD490


;+4. CDM
 ;+4.1 With standard average data
    inaCDM=data.inaCDM(p)
    ddsaCDM_a = data.ddsaCDM_avg(p)
    ddsaCDM_s = data.ddsaCDM_std(p)
    pp=where(inaCDM GT 0. and ddsaCDM_a GT 0 and (ddsaCDM_s/ddsaCDM_a) LT cvar, nCDM_a)
    if(nCDM_a GE 2) then begin
       inaCDM1 = inaCDM(pp)
       ddsaCDM_a = ddsaCDM_a(pp)
       ddsaCDM_s = ddsaCDM_s(pp)

       fit_CDM_a = [LINFIT(alog10(inaCDM1),alog10(ddsaCDM_a)), (CORRELATE(alog10(inaCDM1),alog10(ddsaCDM_a),/DOUBLE))^2.]
       relrms_CDM_a = sqrt(mean(alog10(ddsaCDM_a/inaCDM1)^2.))   ;Relative RMS
       relbias_CDM_a = mean(alog10(ddsaCDM_a/inaCDM1))   ;Relative bias
       rms_CDM_a = sqrt(mean((ddsaCDM_a-inaCDM1)^2.))    ;Not to be considered for CDM
       bias_CDM_a = mean(ddsaCDM_a-inaCDM1)          ;Not to be considered for CDM

       avgratio_CDM_a = mean(ddsaCDM_a/inaCDM1)   ;Mean Ratio
       medratio_CDM_a = median(ddsaCDM_a/inaCDM1)    ;Median Ratio
       avgpd_CDM_a = mean(abs((ddsaCDM_a-inaCDM1)/inaCDM1))*100.   ;Mean % diff
       medpd_CDM_a = median(abs((ddsaCDM_a-inaCDM1)/inaCDM1))*100. ;Median % diff
       range_inaCDM1 = [min(inaCDM1),max(inaCDM1)]    ;in-situ range
       range_ddsaCDM_a = [min(ddsaCDM_a),max(ddsaCDM_a)]    ;DDS range

       printf,1,'CDM',nCDM_a,fit_CDM_a(1),fit_CDM_a(0),fit_CDM_a(2),avgratio_CDM_a,medratio_CDM_a, $
               avgpd_CDM_a,medpd_CDM_a,bias_CDM_a,rms_CDM_a,relbias_CDM_a,relrms_CDM_a, $
               range_inaCDM1,range_ddsaCDM_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nCDM_a GT 0) then begin
;-4.1 With standard average data
;+4.2 With filtered average data
    inaCDM=data.inaCDM(p)
    ddsaCDM_a2 = data.ddsaCDM_avg2(p)
    ddsaCDM_s2 = data.ddsaCDM_std2(p)
    pp=where(inaCDM GT 0. and ddsaCDM_a2 GT 0, nCDM_a2)
    if(nCDM_a2 GE 2) then begin
       inaCDM2 = inaCDM(pp)
       ddsaCDM_a2 = ddsaCDM_a2(pp)
       ddsaCDM_s2 = ddsaCDM_s2(pp)

       fit_CDM_a2 = [LINFIT(alog10(inaCDM2),alog10(ddsaCDM_a2)), (CORRELATE(alog10(inaCDM2),alog10(ddsaCDM_a2),/DOUBLE))^2.]
       relrms_CDM_a2 = sqrt(mean(alog10(ddsaCDM_a2/inaCDM2)^2.))   ;Relative RMS
       relbias_CDM_a2 = mean(alog10(ddsaCDM_a2/inaCDM2))   ;Relative bias
       rms_CDM_a2 = sqrt(mean((ddsaCDM_a2-inaCDM2)^2.))    ;Not to be considered for CDM
       bias_CDM_a2 = mean(ddsaCDM_a2-inaCDM2)          ;Not to be considered for CDM

       avgratio_CDM_a2 = mean(ddsaCDM_a2/inaCDM2)   ;Mean Ratio
       medratio_CDM_a2 = median(ddsaCDM_a2/inaCDM2)    ;Median Ratio
       avgpd_CDM_a2 = mean(abs((ddsaCDM_a2-inaCDM2)/inaCDM2))*100.   ;Mean % diff
       medpd_CDM_a2 = median(abs((ddsaCDM_a2-inaCDM2)/inaCDM2))*100. ;Median % diff

       range_inaCDM2 = [min(inaCDM2),max(inaCDM2)]    ;in-situ range
       range_ddsaCDM_a2 = [min(ddsaCDM_a2),max(ddsaCDM_a2)]    ;DDS range


       printf,2,'CDM',nCDM_a2,fit_CDM_a2(1),fit_CDM_a2(0),fit_CDM_a2(2),avgratio_CDM_a2,medratio_CDM_a2, $
               avgpd_CDM_a2,medpd_CDM_a2,bias_CDM_a2,rms_CDM_a2,relbias_CDM_a2,relrms_CDM_a2, $
               range_inaCDM2,range_ddsaCDM_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nCDM_a2 GT 0) then begin
;-4.2 With filtered average data
;-4. CDM


;+5. BBP
 ;+5.1 With standard average data
    inBBP=data.inBBP(p)
    ddsBBP_a = data.ddsBBP_avg(p)
    ddsBBP_s = data.ddsBBP_std(p)
    pp=where(inBBP GT 0. and ddsBBP_a GT 0 and (ddsBBP_s/ddsBBP_a) LT cvar, nBBP_a)
    if(nBBP_a GE 2) then begin
       inBBP1 = inBBP(pp)
       ddsBBP_a = ddsBBP_a(pp)
       ddsBBP_s = ddsBBP_s(pp)

       fit_BBP_a = [LINFIT(alog10(inBBP1),alog10(ddsBBP_a)), (CORRELATE(alog10(inBBP1),alog10(ddsBBP_a),/DOUBLE))^2.]
       relrms_BBP_a = sqrt(mean(alog10(ddsBBP_a/inBBP1)^2.))   ;Relative RMS
       relbias_BBP_a = mean(alog10(ddsBBP_a/inBBP1))   ;Relative bias
       rms_BBP_a = sqrt(mean((ddsBBP_a-inBBP1)^2.))    ;Not to be considered for BBP
       bias_BBP_a = mean(ddsBBP_a-inBBP1)          ;Not to be considered for BBP

       avgratio_BBP_a = mean(ddsBBP_a/inBBP1)   ;Mean Ratio
       medratio_BBP_a = median(ddsBBP_a/inBBP1)    ;Median Ratio
       avgpd_BBP_a = mean(abs((ddsBBP_a-inBBP1)/inBBP1))*100.   ;Mean % diff
       medpd_BBP_a = median(abs((ddsBBP_a-inBBP1)/inBBP1))*100. ;Median % diff
       range_inBBP1 = [min(inBBP1),max(inBBP1)]    ;in-situ range
       range_ddsBBP_a = [min(ddsBBP_a),max(ddsBBP_a)]    ;DDS range

       printf,1,'BBP',nBBP_a,fit_BBP_a(1),fit_BBP_a(0),fit_BBP_a(2),avgratio_BBP_a,medratio_BBP_a, $
               avgpd_BBP_a,medpd_BBP_a,bias_BBP_a,rms_BBP_a,relbias_BBP_a,relrms_BBP_a, $
               range_inBBP1,range_ddsBBP_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nBBP_a GT 0) then begin
;-5.1 With standard average data
;+5.2 With filtered average data
    inBBP=data.inBBP(p)
    ddsBBP_a2 = data.ddsBBP_avg2(p)
    ddsBBP_s2 = data.ddsBBP_std2(p)
    pp=where(inBBP GT 0. and ddsBBP_a2 GT 0, nBBP_a2)
    if(nBBP_a2 GE 2) then begin
       inBBP2 = inBBP(pp)
       ddsBBP_a2 = ddsBBP_a2(pp)
       ddsBBP_s2 = ddsBBP_s2(pp)

       fit_BBP_a2 = [LINFIT(alog10(inBBP2),alog10(ddsBBP_a2)), (CORRELATE(alog10(inBBP2),alog10(ddsBBP_a2),/DOUBLE))^2.]
       relrms_BBP_a2 = sqrt(mean(alog10(ddsBBP_a2/inBBP2)^2.))   ;Relative RMS
       relbias_BBP_a2 = mean(alog10(ddsBBP_a2/inBBP2))   ;Relative bias
       rms_BBP_a2 = sqrt(mean((ddsBBP_a2-inBBP2)^2.))    ;Not to be considered for BBP
       bias_BBP_a2 = mean(ddsBBP_a2-inBBP2)          ;Not to be considered for BBP

       avgratio_BBP_a2 = mean(ddsBBP_a2/inBBP2)   ;Mean Ratio
       medratio_BBP_a2 = median(ddsBBP_a2/inBBP2)    ;Median Ratio
       avgpd_BBP_a2 = mean(abs((ddsBBP_a2-inBBP2)/inBBP2))*100.   ;Mean % diff
       medpd_BBP_a2 = median(abs((ddsBBP_a2-inBBP2)/inBBP2))*100. ;Median % diff

       range_inBBP2 = [min(inBBP2),max(inBBP2)]    ;in-situ range
       range_ddsBBP_a2 = [min(ddsBBP_a2),max(ddsBBP_a2)]    ;DDS range


       printf,2,'BBP',nBBP_a2,fit_BBP_a2(1),fit_BBP_a2(0),fit_BBP_a2(2),avgratio_BBP_a2,medratio_BBP_a2, $
               avgpd_BBP_a2,medpd_BBP_a2,bias_BBP_a2,rms_BBP_a2,relbias_BBP_a2,relrms_BBP_a2, $
               range_inBBP2,range_ddsBBP_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nBBP_a2 GT 0) then begin
;-5.2 With filtered average data
;-5. BBP

;+6. TSM
 ;+6.1 With standard average data
    inTSM=data.inTSM(p)
    ddsTSM_a = data.ddsTSM_avg(p)
    ddsTSM_s = data.ddsTSM_std(p)
    pp=where(inTSM GT 0. and ddsTSM_a GT 0 and (ddsTSM_s/ddsTSM_a) LT cvar, nTSM_a)
    if(nTSM_a GE 2) then begin
       inTSM1 = inTSM(pp)
       ddsTSM_a = ddsTSM_a(pp)
       ddsTSM_s = ddsTSM_s(pp)

       fit_TSM_a = [LINFIT(alog10(inTSM1),alog10(ddsTSM_a)), (CORRELATE(alog10(inTSM1),alog10(ddsTSM_a),/DOUBLE))^2.]
       relrms_TSM_a = sqrt(mean(alog10(ddsTSM_a/inTSM1)^2.))   ;Relative RMS
       relbias_TSM_a = mean(alog10(ddsTSM_a/inTSM1))   ;Relative bias
       rms_TSM_a = sqrt(mean((ddsTSM_a-inTSM1)^2.))    ;Not to be considered for TSM
       bias_TSM_a = mean(ddsTSM_a-inTSM1)          ;Not to be considered for TSM

       avgratio_TSM_a = mean(ddsTSM_a/inTSM1)   ;Mean Ratio
       medratio_TSM_a = median(ddsTSM_a/inTSM1)    ;Median Ratio
       avgpd_TSM_a = mean(abs((ddsTSM_a-inTSM1)/inTSM1))*100.   ;Mean % diff
       medpd_TSM_a = median(abs((ddsTSM_a-inTSM1)/inTSM1))*100. ;Median % diff
       range_inTSM1 = [min(inTSM1),max(inTSM1)]    ;in-situ range
       range_ddsTSM_a = [min(ddsTSM_a),max(ddsTSM_a)]    ;DDS range

       printf,1,'TSM',nTSM_a,fit_TSM_a(1),fit_TSM_a(0),fit_TSM_a(2),avgratio_TSM_a,medratio_TSM_a, $
               avgpd_TSM_a,medpd_TSM_a,bias_TSM_a,rms_TSM_a,relbias_TSM_a,relrms_TSM_a, $
               range_inTSM1,range_ddsTSM_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nTSM_a GT 0) then begin
;-6.1 With standard average data
;+6.2 With filtered average data
    inTSM=data.inTSM(p)
    ddsTSM_a2 = data.ddsTSM_avg2(p)
    ddsTSM_s2 = data.ddsTSM_std2(p)
    pp=where(inTSM GT 0. and ddsTSM_a2 GT 0, nTSM_a2)
    if(nTSM_a2 GE 2) then begin
       inTSM2 = inTSM(pp)
       ddsTSM_a2 = ddsTSM_a2(pp)
       ddsTSM_s2 = ddsTSM_s2(pp)

       fit_TSM_a2 = [LINFIT(alog10(inTSM2),alog10(ddsTSM_a2)), (CORRELATE(alog10(inTSM2),alog10(ddsTSM_a2),/DOUBLE))^2.]
       relrms_TSM_a2 = sqrt(mean(alog10(ddsTSM_a2/inTSM2)^2.))   ;Relative RMS
       relbias_TSM_a2 = mean(alog10(ddsTSM_a2/inTSM2))   ;Relative bias
       rms_TSM_a2 = sqrt(mean((ddsTSM_a2-inTSM2)^2.))    ;Not to be considered for TSM
       bias_TSM_a2 = mean(ddsTSM_a2-inTSM2)          ;Not to be considered for TSM

       avgratio_TSM_a2 = mean(ddsTSM_a2/inTSM2)   ;Mean Ratio
       medratio_TSM_a2 = median(ddsTSM_a2/inTSM2)    ;Median Ratio
       avgpd_TSM_a2 = mean(abs((ddsTSM_a2-inTSM2)/inTSM2))*100.   ;Mean % diff
       medpd_TSM_a2 = median(abs((ddsTSM_a2-inTSM2)/inTSM2))*100. ;Median % diff

       range_inTSM2 = [min(inTSM2),max(inTSM2)]    ;in-situ range
       range_ddsTSM_a2 = [min(ddsTSM_a2),max(ddsTSM_a2)]    ;DDS range


       printf,2,'TSM',nTSM_a2,fit_TSM_a2(1),fit_TSM_a2(0),fit_TSM_a2(2),avgratio_TSM_a2,medratio_TSM_a2, $
               avgpd_TSM_a2,medpd_TSM_a2,bias_TSM_a2,rms_TSM_a2,relbias_TSM_a2,relrms_TSM_a2, $
               range_inTSM2,range_ddsTSM_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nTSM_a2 GT 0) then begin
;-6.2 With filtered average data
;-6. TSM



;+7. T865
 ;+7.1 With standard average data
    inT865=data.inT865(p)
    ddsT865_a = data.ddsT865_avg(p)
    ddsT865_s = data.ddsT865_std(p)
    pp=where(inT865 GT 0. and ddsT865_a GT 0 and (ddsT865_s/ddsT865_a) LT cvar, nT865_a)
    if(nT865_a GE 2) then begin
       inT8651 = inT865(pp)
       ddsT865_a = ddsT865_a(pp)
       ddsT865_s = ddsT865_s(pp)

       fit_T865_a = [LINFIT(inT8651,ddsT865_a), (CORRELATE(inT8651,ddsT865_a,/DOUBLE))^2.]
       relrms_T865_a = sqrt(mean(alog10(ddsT865_a/inT8651)^2.))   ;Relative RMS
       relbias_T865_a = mean(alog10(ddsT865_a/inT8651))   ;Relative bias
       rms_T865_a = sqrt(mean((ddsT865_a-inT8651)^2.))    ;Not to be considered for T865
       bias_T865_a = mean(ddsT865_a-inT8651)          ;Not to be considered for T865

       avgratio_T865_a = mean(ddsT865_a/inT8651)   ;Mean Ratio
       medratio_T865_a = median(ddsT865_a/inT8651)    ;Median Ratio
       avgpd_T865_a = mean(abs((ddsT865_a-inT8651)/inT8651))*100.   ;Mean % diff
       medpd_T865_a = median(abs((ddsT865_a-inT8651)/inT8651))*100. ;Median % diff
       range_inT8651 = [min(inT8651),max(inT8651)]    ;in-situ range
       range_ddsT865_a = [min(ddsT865_a),max(ddsT865_a)]    ;DDS range

       printf,1,'T865',nT865_a,fit_T865_a(1),fit_T865_a(0),fit_T865_a(2),avgratio_T865_a,medratio_T865_a, $
               avgpd_T865_a,medpd_T865_a,bias_T865_a,rms_T865_a,relbias_T865_a,relrms_T865_a, $
               range_inT8651,range_ddsT865_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nT865_a GT 0) then begin
;-7.1 With standard average data
;+7.2 With filtered average data
    inT865=data.inT865(p)
    ddsT865_a2 = data.ddsT865_avg2(p)
    ddsT865_s2 = data.ddsT865_std2(p)
    pp=where(inT865 GT 0. and ddsT865_a2 GT 0, nT865_a2)
    if(nT865_a2 GE 2) then begin
       inT8652 = inT865(pp)
       ddsT865_a2 = ddsT865_a2(pp)
       ddsT865_s2 = ddsT865_s2(pp)

       fit_T865_a2 = [LINFIT(inT8652,ddsT865_a2), (CORRELATE(inT8652,ddsT865_a2,/DOUBLE))^2.]
       relrms_T865_a2 = sqrt(mean(alog10(ddsT865_a2/inT8652)^2.))   ;Relative RMS
       relbias_T865_a2 = mean(alog10(ddsT865_a2/inT8652))   ;Relative bias
       rms_T865_a2 = sqrt(mean((ddsT865_a2-inT8652)^2.))    ;Not to be considered for T865
       bias_T865_a2 = mean(ddsT865_a2-inT8652)          ;Not to be considered for T865

       avgratio_T865_a2 = mean(ddsT865_a2/inT8652)   ;Mean Ratio
       medratio_T865_a2 = median(ddsT865_a2/inT8652)    ;Median Ratio
       avgpd_T865_a2 = mean(abs((ddsT865_a2-inT8652)/inT8652))*100.   ;Mean % diff
       medpd_T865_a2 = median(abs((ddsT865_a2-inT8652)/inT8652))*100. ;Median % diff

       range_inT8652 = [min(inT8652),max(inT8652)]    ;in-situ range
       range_ddsT865_a2 = [min(ddsT865_a2),max(ddsT865_a2)]    ;DDS range


       printf,2,'T865',nT865_a2,fit_T865_a2(1),fit_T865_a2(0),fit_T865_a2(2),avgratio_T865_a2,medratio_T865_a2, $
               avgpd_T865_a2,medpd_T865_a2,bias_T865_a2,rms_T865_a2,relbias_T865_a2,relrms_T865_a2, $
               range_inT8652,range_ddsT865_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nT865_a2 GT 0) then begin
;-7.2 With filtered average data
;-7. T865





;+8. L412
 ;+8.1 With standard average data
    inL412=data.inL412(p)
    ddsL412_a = data.ddsL412_avg(p)
    ddsL412_s = data.ddsL412_std(p)
    pp=where(inL412 GT 0. and ddsL412_a GT 0 and (ddsL412_s/ddsL412_a) LT cvar, nL412_a)
    if(nL412_a GE 2) then begin
       inL4121 = inL412(pp)
       ddsL412_a = ddsL412_a(pp)
       ddsL412_s = ddsL412_s(pp)

       fit_L412_a = [LINFIT(inL4121,ddsL412_a), (CORRELATE(inL4121,ddsL412_a,/DOUBLE))^2.]
       relrms_L412_a = sqrt(mean(alog10(ddsL412_a/inL4121)^2.))   ;Relative RMS
       relbias_L412_a = mean(alog10(ddsL412_a/inL4121))   ;Relative bias
       rms_L412_a = sqrt(mean((ddsL412_a-inL4121)^2.))    ;Not to be considered for L412
       bias_L412_a = mean(ddsL412_a-inL4121)          ;Not to be considered for L412

       avgratio_L412_a = mean(ddsL412_a/inL4121)   ;Mean Ratio
       medratio_L412_a = median(ddsL412_a/inL4121)    ;Median Ratio
       avgpd_L412_a = mean(abs((ddsL412_a-inL4121)/inL4121))*100.   ;Mean % diff
       medpd_L412_a = median(abs((ddsL412_a-inL4121)/inL4121))*100. ;Median % diff
       range_inL4121 = [min(inL4121),max(inL4121)]    ;in-situ range
       range_ddsL412_a = [min(ddsL412_a),max(ddsL412_a)]    ;DDS range

       printf,1,'L412',nL412_a,fit_L412_a(1),fit_L412_a(0),fit_L412_a(2),avgratio_L412_a,medratio_L412_a, $
               avgpd_L412_a,medpd_L412_a,bias_L412_a,rms_L412_a,relbias_L412_a,relrms_L412_a, $
               range_inL4121,range_ddsL412_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL412_a GT 0) then begin
;-8.1 With standard average data
;+8.2 With filtered average data
    inL412=data.inL412(p)
    ddsL412_a2 = data.ddsL412_avg2(p)
    ddsL412_s2 = data.ddsL412_std2(p)
    pp=where(inL412 GT 0. and ddsL412_a2 GT 0, nL412_a2)
    if(nL412_a2 GE 2) then begin
       inL4122 = inL412(pp)
       ddsL412_a2 = ddsL412_a2(pp)
       ddsL412_s2 = ddsL412_s2(pp)

       fit_L412_a2 = [LINFIT(inL4122,ddsL412_a2), (CORRELATE(inL4122,ddsL412_a2,/DOUBLE))^2.]
       relrms_L412_a2 = sqrt(mean(alog10(ddsL412_a2/inL4122)^2.))   ;Relative RMS
       relbias_L412_a2 = mean(alog10(ddsL412_a2/inL4122))   ;Relative bias
       rms_L412_a2 = sqrt(mean((ddsL412_a2-inL4122)^2.))    ;Not to be considered for L412
       bias_L412_a2 = mean(ddsL412_a2-inL4122)          ;Not to be considered for L412

       avgratio_L412_a2 = mean(ddsL412_a2/inL4122)   ;Mean Ratio
       medratio_L412_a2 = median(ddsL412_a2/inL4122)    ;Median Ratio
       avgpd_L412_a2 = mean(abs((ddsL412_a2-inL4122)/inL4122))*100.   ;Mean % diff
       medpd_L412_a2 = median(abs((ddsL412_a2-inL4122)/inL4122))*100. ;Median % diff

       range_inL4122 = [min(inL4122),max(inL4122)]    ;in-situ range
       range_ddsL412_a2 = [min(ddsL412_a2),max(ddsL412_a2)]    ;DDS range


       printf,2,'L412',nL412_a2,fit_L412_a2(1),fit_L412_a2(0),fit_L412_a2(2),avgratio_L412_a2,medratio_L412_a2, $
               avgpd_L412_a2,medpd_L412_a2,bias_L412_a2,rms_L412_a2,relbias_L412_a2,relrms_L412_a2, $
               range_inL4122,range_ddsL412_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL412_a2 GT 0) then begin
;-8.2 With filtered average data
;-8. L412


;+9. L443
 ;+9.1 With standard average data
    inL443=data.inL443(p)
    ddsL443_a = data.ddsL443_avg(p)
    ddsL443_s = data.ddsL443_std(p)
    pp=where(inL443 GT 0. and ddsL443_a GT 0 and (ddsL443_s/ddsL443_a) LT cvar, nL443_a)
    if(nL443_a GE 2) then begin
       inL4431 = inL443(pp)
       ddsL443_a = ddsL443_a(pp)
       ddsL443_s = ddsL443_s(pp)

       fit_L443_a = [LINFIT(inL4431,ddsL443_a), (CORRELATE(inL4431,ddsL443_a,/DOUBLE))^2.]
       relrms_L443_a = sqrt(mean(alog10(ddsL443_a/inL4431)^2.))   ;Relative RMS
       relbias_L443_a = mean(alog10(ddsL443_a/inL4431))   ;Relative bias
       rms_L443_a = sqrt(mean((ddsL443_a-inL4431)^2.))    ;Not to be considered for L443
       bias_L443_a = mean(ddsL443_a-inL4431)          ;Not to be considered for L443

       avgratio_L443_a = mean(ddsL443_a/inL4431)   ;Mean Ratio
       medratio_L443_a = median(ddsL443_a/inL4431)    ;Median Ratio
       avgpd_L443_a = mean(abs((ddsL443_a-inL4431)/inL4431))*100.   ;Mean % diff
       medpd_L443_a = median(abs((ddsL443_a-inL4431)/inL4431))*100. ;Median % diff
       range_inL4431 = [min(inL4431),max(inL4431)]    ;in-situ range
       range_ddsL443_a = [min(ddsL443_a),max(ddsL443_a)]    ;DDS range

       printf,1,'L443',nL443_a,fit_L443_a(1),fit_L443_a(0),fit_L443_a(2),avgratio_L443_a,medratio_L443_a, $
               avgpd_L443_a,medpd_L443_a,bias_L443_a,rms_L443_a,relbias_L443_a,relrms_L443_a, $
               range_inL4431,range_ddsL443_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL443_a GT 0) then begin
;-9.1 With standard average data
;+9.2 With filtered average data
    inL443=data.inL443(p)
    ddsL443_a2 = data.ddsL443_avg2(p)
    ddsL443_s2 = data.ddsL443_std2(p)
    pp=where(inL443 GT 0. and ddsL443_a2 GT 0, nL443_a2)
    if(nL443_a2 GE 2) then begin
       inL4432 = inL443(pp)
       ddsL443_a2 = ddsL443_a2(pp)
       ddsL443_s2 = ddsL443_s2(pp)

       fit_L443_a2 = [LINFIT(inL4432,ddsL443_a2), (CORRELATE(inL4432,ddsL443_a2,/DOUBLE))^2.]
       relrms_L443_a2 = sqrt(mean(alog10(ddsL443_a2/inL4432)^2.))   ;Relative RMS
       relbias_L443_a2 = mean(alog10(ddsL443_a2/inL4432))   ;Relative bias
       rms_L443_a2 = sqrt(mean((ddsL443_a2-inL4432)^2.))    ;Not to be considered for L443
       bias_L443_a2 = mean(ddsL443_a2-inL4432)          ;Not to be considered for L443

       avgratio_L443_a2 = mean(ddsL443_a2/inL4432)   ;Mean Ratio
       medratio_L443_a2 = median(ddsL443_a2/inL4432)    ;Median Ratio
       avgpd_L443_a2 = mean(abs((ddsL443_a2-inL4432)/inL4432))*100.   ;Mean % diff
       medpd_L443_a2 = median(abs((ddsL443_a2-inL4432)/inL4432))*100. ;Median % diff

       range_inL4432 = [min(inL4432),max(inL4432)]    ;in-situ range
       range_ddsL443_a2 = [min(ddsL443_a2),max(ddsL443_a2)]    ;DDS range


       printf,2,'L443',nL443_a2,fit_L443_a2(1),fit_L443_a2(0),fit_L443_a2(2),avgratio_L443_a2,medratio_L443_a2, $
               avgpd_L443_a2,medpd_L443_a2,bias_L443_a2,rms_L443_a2,relbias_L443_a2,relrms_L443_a2, $
               range_inL4432,range_ddsL443_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL443_a2 GT 0) then begin
;-9.2 With filtered average data
;-9. L443


;+10. L490
 ;+10.1 With standard average data
    inL490=data.inL490(p)
    ddsL490_a = data.ddsL490_avg(p)
    ddsL490_s = data.ddsL490_std(p)
    pp=where(inL490 GT 0. and ddsL490_a GT 0 and (ddsL490_s/ddsL490_a) LT cvar, nL490_a)
    if(nL490_a GE 2) then begin
       inL4901 = inL490(pp)
       ddsL490_a = ddsL490_a(pp)
       ddsL490_s = ddsL490_s(pp)

       fit_L490_a = [LINFIT(inL4901,ddsL490_a), (CORRELATE(inL4901,ddsL490_a,/DOUBLE))^2.]
       relrms_L490_a = sqrt(mean(alog10(ddsL490_a/inL4901)^2.))   ;Relative RMS
       relbias_L490_a = mean(alog10(ddsL490_a/inL4901))   ;Relative bias
       rms_L490_a = sqrt(mean((ddsL490_a-inL4901)^2.))    ;Not to be considered for L490
       bias_L490_a = mean(ddsL490_a-inL4901)          ;Not to be considered for L490

       avgratio_L490_a = mean(ddsL490_a/inL4901)   ;Mean Ratio
       medratio_L490_a = median(ddsL490_a/inL4901)    ;Median Ratio
       avgpd_L490_a = mean(abs((ddsL490_a-inL4901)/inL4901))*100.   ;Mean % diff
       medpd_L490_a = median(abs((ddsL490_a-inL4901)/inL4901))*100. ;Median % diff
       range_inL4901 = [min(inL4901),max(inL4901)]    ;in-situ range
       range_ddsL490_a = [min(ddsL490_a),max(ddsL490_a)]    ;DDS range

       printf,1,'L490',nL490_a,fit_L490_a(1),fit_L490_a(0),fit_L490_a(2),avgratio_L490_a,medratio_L490_a, $
               avgpd_L490_a,medpd_L490_a,bias_L490_a,rms_L490_a,relbias_L490_a,relrms_L490_a, $
               range_inL4901,range_ddsL490_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL490_a GT 0) then begin
;-10.1 With standard average data
;+10.2 With filtered average data
    inL490=data.inL490(p)
    ddsL490_a2 = data.ddsL490_avg2(p)
    ddsL490_s2 = data.ddsL490_std2(p)
    pp=where(inL490 GT 0. and ddsL490_a2 GT 0, nL490_a2)
    if(nL490_a2 GE 2) then begin
       inL4902 = inL490(pp)
       ddsL490_a2 = ddsL490_a2(pp)
       ddsL490_s2 = ddsL490_s2(pp)

       fit_L490_a2 = [LINFIT(inL4902,ddsL490_a2), (CORRELATE(inL4902,ddsL490_a2,/DOUBLE))^2.]
       relrms_L490_a2 = sqrt(mean(alog10(ddsL490_a2/inL4902)^2.))   ;Relative RMS
       relbias_L490_a2 = mean(alog10(ddsL490_a2/inL4902))   ;Relative bias
       rms_L490_a2 = sqrt(mean((ddsL490_a2-inL4902)^2.))    ;Not to be considered for L490
       bias_L490_a2 = mean(ddsL490_a2-inL4902)          ;Not to be considered for L490

       avgratio_L490_a2 = mean(ddsL490_a2/inL4902)   ;Mean Ratio
       medratio_L490_a2 = median(ddsL490_a2/inL4902)    ;Median Ratio
       avgpd_L490_a2 = mean(abs((ddsL490_a2-inL4902)/inL4902))*100.   ;Mean % diff
       medpd_L490_a2 = median(abs((ddsL490_a2-inL4902)/inL4902))*100. ;Median % diff

       range_inL4902 = [min(inL4902),max(inL4902)]    ;in-situ range
       range_ddsL490_a2 = [min(ddsL490_a2),max(ddsL490_a2)]    ;DDS range


       printf,2,'L490',nL490_a2,fit_L490_a2(1),fit_L490_a2(0),fit_L490_a2(2),avgratio_L490_a2,medratio_L490_a2, $
               avgpd_L490_a2,medpd_L490_a2,bias_L490_a2,rms_L490_a2,relbias_L490_a2,relrms_L490_a2, $
               range_inL4902,range_ddsL490_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL490_a2 GT 0) then begin
;-10.2 With filtered average data
;-10. L490


;+11. L510
 ;+11.1 With standard average data
    inL510=data.inL510(p)
    ddsL510_a = data.ddsL510_avg(p)
    ddsL510_s = data.ddsL510_std(p)
    pp=where(inL510 GT 0. and ddsL510_a GT 0 and (ddsL510_s/ddsL510_a) LT cvar, nL510_a)
    if(nL510_a GE 2) then begin
       inL5101 = inL510(pp)
       ddsL510_a = ddsL510_a(pp)
       ddsL510_s = ddsL510_s(pp)

       fit_L510_a = [LINFIT(inL5101,ddsL510_a), (CORRELATE(inL5101,ddsL510_a,/DOUBLE))^2.]
       relrms_L510_a = sqrt(mean(alog10(ddsL510_a/inL5101)^2.))   ;Relative RMS
       relbias_L510_a = mean(alog10(ddsL510_a/inL5101))   ;Relative bias
       rms_L510_a = sqrt(mean((ddsL510_a-inL5101)^2.))    ;Not to be considered for L510
       bias_L510_a = mean(ddsL510_a-inL5101)          ;Not to be considered for L510

       avgratio_L510_a = mean(ddsL510_a/inL5101)   ;Mean Ratio
       medratio_L510_a = median(ddsL510_a/inL5101)    ;Median Ratio
       avgpd_L510_a = mean(abs((ddsL510_a-inL5101)/inL5101))*100.   ;Mean % diff
       medpd_L510_a = median(abs((ddsL510_a-inL5101)/inL5101))*100. ;Median % diff
       range_inL5101 = [min(inL5101),max(inL5101)]    ;in-situ range
       range_ddsL510_a = [min(ddsL510_a),max(ddsL510_a)]    ;DDS range

       printf,1,'L510',nL510_a,fit_L510_a(1),fit_L510_a(0),fit_L510_a(2),avgratio_L510_a,medratio_L510_a, $
               avgpd_L510_a,medpd_L510_a,bias_L510_a,rms_L510_a,relbias_L510_a,relrms_L510_a, $
               range_inL5101,range_ddsL510_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL510_a GT 0) then begin
;-11.1 With standard average data
;+11.2 With filtered average data
    inL510=data.inL510(p)
    ddsL510_a2 = data.ddsL510_avg2(p)
    ddsL510_s2 = data.ddsL510_std2(p)
    pp=where(inL510 GT 0. and ddsL510_a2 GT 0, nL510_a2)
    if(nL510_a2 GE 2) then begin
       inL5102 = inL510(pp)
       ddsL510_a2 = ddsL510_a2(pp)
       ddsL510_s2 = ddsL510_s2(pp)

       fit_L510_a2 = [LINFIT(inL5102,ddsL510_a2), (CORRELATE(inL5102,ddsL510_a2,/DOUBLE))^2.]
       relrms_L510_a2 = sqrt(mean(alog10(ddsL510_a2/inL5102)^2.))   ;Relative RMS
       relbias_L510_a2 = mean(alog10(ddsL510_a2/inL5102))   ;Relative bias
       rms_L510_a2 = sqrt(mean((ddsL510_a2-inL5102)^2.))    ;Not to be considered for L510
       bias_L510_a2 = mean(ddsL510_a2-inL5102)          ;Not to be considered for L510

       avgratio_L510_a2 = mean(ddsL510_a2/inL5102)   ;Mean Ratio
       medratio_L510_a2 = median(ddsL510_a2/inL5102)    ;Median Ratio
       avgpd_L510_a2 = mean(abs((ddsL510_a2-inL5102)/inL5102))*100.   ;Mean % diff
       medpd_L510_a2 = median(abs((ddsL510_a2-inL5102)/inL5102))*100. ;Median % diff

       range_inL5102 = [min(inL5102),max(inL5102)]    ;in-situ range
       range_ddsL510_a2 = [min(ddsL510_a2),max(ddsL510_a2)]    ;DDS range


       printf,2,'L510',nL510_a2,fit_L510_a2(1),fit_L510_a2(0),fit_L510_a2(2),avgratio_L510_a2,medratio_L510_a2, $
               avgpd_L510_a2,medpd_L510_a2,bias_L510_a2,rms_L510_a2,relbias_L510_a2,relrms_L510_a2, $
               range_inL5102,range_ddsL510_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL510_a2 GT 0) then begin
;-11.2 With filtered average data
;-11. L510


;+12. L531
 ;+12.1 With standard average data
    inL531=data.inL531(p)
    ddsL531_a = data.ddsL531_avg(p)
    ddsL531_s = data.ddsL531_std(p)
    pp=where(inL531 GT 0. and ddsL531_a GT 0 and (ddsL531_s/ddsL531_a) LT cvar, nL531_a)
    if(nL531_a GE 2) then begin
       inL5311 = inL531(pp)
       ddsL531_a = ddsL531_a(pp)
       ddsL531_s = ddsL531_s(pp)

       fit_L531_a = [LINFIT(inL5311,ddsL531_a), (CORRELATE(inL5311,ddsL531_a,/DOUBLE))^2.]
       relrms_L531_a = sqrt(mean(alog10(ddsL531_a/inL5311)^2.))   ;Relative RMS
       relbias_L531_a = mean(alog10(ddsL531_a/inL5311))   ;Relative bias
       rms_L531_a = sqrt(mean((ddsL531_a-inL5311)^2.))    ;Not to be considered for L531
       bias_L531_a = mean(ddsL531_a-inL5311)          ;Not to be considered for L531

       avgratio_L531_a = mean(ddsL531_a/inL5311)   ;Mean Ratio
       medratio_L531_a = median(ddsL531_a/inL5311)    ;Median Ratio
       avgpd_L531_a = mean(abs((ddsL531_a-inL5311)/inL5311))*100.   ;Mean % diff
       medpd_L531_a = median(abs((ddsL531_a-inL5311)/inL5311))*100. ;Median % diff
       range_inL5311 = [min(inL5311),max(inL5311)]    ;in-situ range
       range_ddsL531_a = [min(ddsL531_a),max(ddsL531_a)]    ;DDS range

       printf,1,'L531',nL531_a,fit_L531_a(1),fit_L531_a(0),fit_L531_a(2),avgratio_L531_a,medratio_L531_a, $
               avgpd_L531_a,medpd_L531_a,bias_L531_a,rms_L531_a,relbias_L531_a,relrms_L531_a, $
               range_inL5311,range_ddsL531_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL531_a GT 0) then begin
;-12.1 With standard average data
;+12.2 With filtered average data
    inL531=data.inL531(p)
    ddsL531_a2 = data.ddsL531_avg2(p)
    ddsL531_s2 = data.ddsL531_std2(p)
    pp=where(inL531 GT 0. and ddsL531_a2 GT 0, nL531_a2)
    if(nL531_a2 GE 2) then begin
       inL5312 = inL531(pp)
       ddsL531_a2 = ddsL531_a2(pp)
       ddsL531_s2 = ddsL531_s2(pp)

       fit_L531_a2 = [LINFIT(inL5312,ddsL531_a2), (CORRELATE(inL5312,ddsL531_a2,/DOUBLE))^2.]
       relrms_L531_a2 = sqrt(mean(alog10(ddsL531_a2/inL5312)^2.))   ;Relative RMS
       relbias_L531_a2 = mean(alog10(ddsL531_a2/inL5312))   ;Relative bias
       rms_L531_a2 = sqrt(mean((ddsL531_a2-inL5312)^2.))    ;Not to be considered for L531
       bias_L531_a2 = mean(ddsL531_a2-inL5312)          ;Not to be considered for L531

       avgratio_L531_a2 = mean(ddsL531_a2/inL5312)   ;Mean Ratio
       medratio_L531_a2 = median(ddsL531_a2/inL5312)    ;Median Ratio
       avgpd_L531_a2 = mean(abs((ddsL531_a2-inL5312)/inL5312))*100.   ;Mean % diff
       medpd_L531_a2 = median(abs((ddsL531_a2-inL5312)/inL5312))*100. ;Median % diff

       range_inL5312 = [min(inL5312),max(inL5312)]    ;in-situ range
       range_ddsL531_a2 = [min(ddsL531_a2),max(ddsL531_a2)]    ;DDS range


       printf,2,'L531',nL531_a2,fit_L531_a2(1),fit_L531_a2(0),fit_L531_a2(2),avgratio_L531_a2,medratio_L531_a2, $
               avgpd_L531_a2,medpd_L531_a2,bias_L531_a2,rms_L531_a2,relbias_L531_a2,relrms_L531_a2, $
               range_inL5312,range_ddsL531_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL531_a2 GT 0) then begin
;-12.2 With filtered average data
;-12. L531


;+13. L555
 ;+13.1 With standard average data
    inL555=data.inL555(p)
    ddsL555_a = data.ddsL555_avg(p)
    ddsL555_s = data.ddsL555_std(p)
    pp=where(inL555 GT 0. and ddsL555_a GT 0 and (ddsL555_s/ddsL555_a) LT cvar, nL555_a)
    if(nL555_a GE 2) then begin
       inL5551 = inL555(pp)
       ddsL555_a = ddsL555_a(pp)
       ddsL555_s = ddsL555_s(pp)

       fit_L555_a = [LINFIT(inL5551,ddsL555_a), (CORRELATE(inL5551,ddsL555_a,/DOUBLE))^2.]
       relrms_L555_a = sqrt(mean(alog10(ddsL555_a/inL5551)^2.))   ;Relative RMS
       relbias_L555_a = mean(alog10(ddsL555_a/inL5551))   ;Relative bias
       rms_L555_a = sqrt(mean((ddsL555_a-inL5551)^2.))    ;Not to be considered for L555
       bias_L555_a = mean(ddsL555_a-inL5551)          ;Not to be considered for L555

       avgratio_L555_a = mean(ddsL555_a/inL5551)   ;Mean Ratio
       medratio_L555_a = median(ddsL555_a/inL5551)    ;Median Ratio
       avgpd_L555_a = mean(abs((ddsL555_a-inL5551)/inL5551))*100.   ;Mean % diff
       medpd_L555_a = median(abs((ddsL555_a-inL5551)/inL5551))*100. ;Median % diff
       range_inL5551 = [min(inL5551),max(inL5551)]    ;in-situ range
       range_ddsL555_a = [min(ddsL555_a),max(ddsL555_a)]    ;DDS range

       printf,1,'L555',nL555_a,fit_L555_a(1),fit_L555_a(0),fit_L555_a(2),avgratio_L555_a,medratio_L555_a, $
               avgpd_L555_a,medpd_L555_a,bias_L555_a,rms_L555_a,relbias_L555_a,relrms_L555_a, $
               range_inL5551,range_ddsL555_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL555_a GT 0) then begin
;-13.1 With standard average data
;+13.2 With filtered average data
    inL555=data.inL555(p)
    ddsL555_a2 = data.ddsL555_avg2(p)
    ddsL555_s2 = data.ddsL555_std2(p)
    pp=where(inL555 GT 0. and ddsL555_a2 GT 0, nL555_a2)
    if(nL555_a2 GE 2) then begin
       inL5552 = inL555(pp)
       ddsL555_a2 = ddsL555_a2(pp)
       ddsL555_s2 = ddsL555_s2(pp)

       fit_L555_a2 = [LINFIT(inL5552,ddsL555_a2), (CORRELATE(inL5552,ddsL555_a2,/DOUBLE))^2.]
       relrms_L555_a2 = sqrt(mean(alog10(ddsL555_a2/inL5552)^2.))   ;Relative RMS
       relbias_L555_a2 = mean(alog10(ddsL555_a2/inL5552))   ;Relative bias
       rms_L555_a2 = sqrt(mean((ddsL555_a2-inL5552)^2.))    ;Not to be considered for L555
       bias_L555_a2 = mean(ddsL555_a2-inL5552)          ;Not to be considered for L555

       avgratio_L555_a2 = mean(ddsL555_a2/inL5552)   ;Mean Ratio
       medratio_L555_a2 = median(ddsL555_a2/inL5552)    ;Median Ratio
       avgpd_L555_a2 = mean(abs((ddsL555_a2-inL5552)/inL5552))*100.   ;Mean % diff
       medpd_L555_a2 = median(abs((ddsL555_a2-inL5552)/inL5552))*100. ;Median % diff

       range_inL5552 = [min(inL5552),max(inL5552)]    ;in-situ range
       range_ddsL555_a2 = [min(ddsL555_a2),max(ddsL555_a2)]    ;DDS range


       printf,2,'L555',nL555_a2,fit_L555_a2(1),fit_L555_a2(0),fit_L555_a2(2),avgratio_L555_a2,medratio_L555_a2, $
               avgpd_L555_a2,medpd_L555_a2,bias_L555_a2,rms_L555_a2,relbias_L555_a2,relrms_L555_a2, $
               range_inL5552,range_ddsL555_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL555_a2 GT 0) then begin
;-13.2 With filtered average data
;-13. L555


;+14. L620
 ;+14.1 With standard average data
    inL620=data.inL620(p)
    ddsL620_a = data.ddsL620_avg(p)
    ddsL620_s = data.ddsL620_std(p)
    pp=where(inL620 GT 0. and ddsL620_a GT 0 and (ddsL620_s/ddsL620_a) LT cvar, nL620_a)
    if(nL620_a GE 2) then begin
       inL6201 = inL620(pp)
       ddsL620_a = ddsL620_a(pp)
       ddsL620_s = ddsL620_s(pp)

       fit_L620_a = [LINFIT(inL6201,ddsL620_a), (CORRELATE(inL6201,ddsL620_a,/DOUBLE))^2.]
       relrms_L620_a = sqrt(mean(alog10(ddsL620_a/inL6201)^2.))   ;Relative RMS
       relbias_L620_a = mean(alog10(ddsL620_a/inL6201))   ;Relative bias
       rms_L620_a = sqrt(mean((ddsL620_a-inL6201)^2.))    ;Not to be considered for L620
       bias_L620_a = mean(ddsL620_a-inL6201)          ;Not to be considered for L620

       avgratio_L620_a = mean(ddsL620_a/inL6201)   ;Mean Ratio
       medratio_L620_a = median(ddsL620_a/inL6201)    ;Median Ratio
       avgpd_L620_a = mean(abs((ddsL620_a-inL6201)/inL6201))*100.   ;Mean % diff
       medpd_L620_a = median(abs((ddsL620_a-inL6201)/inL6201))*100. ;Median % diff
       range_inL6201 = [min(inL6201),max(inL6201)]    ;in-situ range
       range_ddsL620_a = [min(ddsL620_a),max(ddsL620_a)]    ;DDS range

       printf,1,'L620',nL620_a,fit_L620_a(1),fit_L620_a(0),fit_L620_a(2),avgratio_L620_a,medratio_L620_a, $
               avgpd_L620_a,medpd_L620_a,bias_L620_a,rms_L620_a,relbias_L620_a,relrms_L620_a, $
               range_inL6201,range_ddsL620_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL620_a GT 0) then begin
;-14.1 With standard average data
;+14.2 With filtered average data
    inL620=data.inL620(p)
    ddsL620_a2 = data.ddsL620_avg2(p)
    ddsL620_s2 = data.ddsL620_std2(p)
    pp=where(inL620 GT 0. and ddsL620_a2 GT 0, nL620_a2)
    if(nL620_a2 GE 2) then begin
       inL6202 = inL620(pp)
       ddsL620_a2 = ddsL620_a2(pp)
       ddsL620_s2 = ddsL620_s2(pp)

       fit_L620_a2 = [LINFIT(inL6202,ddsL620_a2), (CORRELATE(inL6202,ddsL620_a2,/DOUBLE))^2.]
       relrms_L620_a2 = sqrt(mean(alog10(ddsL620_a2/inL6202)^2.))   ;Relative RMS
       relbias_L620_a2 = mean(alog10(ddsL620_a2/inL6202))   ;Relative bias
       rms_L620_a2 = sqrt(mean((ddsL620_a2-inL6202)^2.))    ;Not to be considered for L620
       bias_L620_a2 = mean(ddsL620_a2-inL6202)          ;Not to be considered for L620

       avgratio_L620_a2 = mean(ddsL620_a2/inL6202)   ;Mean Ratio
       medratio_L620_a2 = median(ddsL620_a2/inL6202)    ;Median Ratio
       avgpd_L620_a2 = mean(abs((ddsL620_a2-inL6202)/inL6202))*100.   ;Mean % diff
       medpd_L620_a2 = median(abs((ddsL620_a2-inL6202)/inL6202))*100. ;Median % diff

       range_inL6202 = [min(inL6202),max(inL6202)]    ;in-situ range
       range_ddsL620_a2 = [min(ddsL620_a2),max(ddsL620_a2)]    ;DDS range


       printf,2,'L620',nL620_a2,fit_L620_a2(1),fit_L620_a2(0),fit_L620_a2(2),avgratio_L620_a2,medratio_L620_a2, $
               avgpd_L620_a2,medpd_L620_a2,bias_L620_a2,rms_L620_a2,relbias_L620_a2,relrms_L620_a2, $
               range_inL6202,range_ddsL620_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL620_a2 GT 0) then begin
;-14.2 With filtered average data
;-14. L620


;+15. L670
 ;+15.1 With standard average data
    inL670=data.inL670(p)
    ddsL670_a = data.ddsL670_avg(p)
    ddsL670_s = data.ddsL670_std(p)
    pp=where(inL670 GT 0. and ddsL670_a GT 0 and (ddsL670_s/ddsL670_a) LT cvar, nL670_a)
    if(nL670_a GE 2) then begin
       inL6701 = inL670(pp)
       ddsL670_a = ddsL670_a(pp)
       ddsL670_s = ddsL670_s(pp)

       fit_L670_a = [LINFIT(inL6701,ddsL670_a), (CORRELATE(inL6701,ddsL670_a,/DOUBLE))^2.]
       relrms_L670_a = sqrt(mean(alog10(ddsL670_a/inL6701)^2.))   ;Relative RMS
       relbias_L670_a = mean(alog10(ddsL670_a/inL6701))   ;Relative bias
       rms_L670_a = sqrt(mean((ddsL670_a-inL6701)^2.))    ;Not to be considered for L670
       bias_L670_a = mean(ddsL670_a-inL6701)          ;Not to be considered for L670

       avgratio_L670_a = mean(ddsL670_a/inL6701)   ;Mean Ratio
       medratio_L670_a = median(ddsL670_a/inL6701)    ;Median Ratio
       avgpd_L670_a = mean(abs((ddsL670_a-inL6701)/inL6701))*100.   ;Mean % diff
       medpd_L670_a = median(abs((ddsL670_a-inL6701)/inL6701))*100. ;Median % diff
       range_inL6701 = [min(inL6701),max(inL6701)]    ;in-situ range
       range_ddsL670_a = [min(ddsL670_a),max(ddsL670_a)]    ;DDS range

       printf,1,'L670',nL670_a,fit_L670_a(1),fit_L670_a(0),fit_L670_a(2),avgratio_L670_a,medratio_L670_a, $
               avgpd_L670_a,medpd_L670_a,bias_L670_a,rms_L670_a,relbias_L670_a,relrms_L670_a, $
               range_inL6701,range_ddsL670_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL670_a GT 0) then begin
;-15.1 With standard average data
;+15.2 With filtered average data
    inL670=data.inL670(p)
    ddsL670_a2 = data.ddsL670_avg2(p)
    ddsL670_s2 = data.ddsL670_std2(p)
    pp=where(inL670 GT 0. and ddsL670_a2 GT 0, nL670_a2)
    if(nL670_a2 GE 2) then begin
       inL6702 = inL670(pp)
       ddsL670_a2 = ddsL670_a2(pp)
       ddsL670_s2 = ddsL670_s2(pp)

       fit_L670_a2 = [LINFIT(inL6702,ddsL670_a2), (CORRELATE(inL6702,ddsL670_a2,/DOUBLE))^2.]
       relrms_L670_a2 = sqrt(mean(alog10(ddsL670_a2/inL6702)^2.))   ;Relative RMS
       relbias_L670_a2 = mean(alog10(ddsL670_a2/inL6702))   ;Relative bias
       rms_L670_a2 = sqrt(mean((ddsL670_a2-inL6702)^2.))    ;Not to be considered for L670
       bias_L670_a2 = mean(ddsL670_a2-inL6702)          ;Not to be considered for L670

       avgratio_L670_a2 = mean(ddsL670_a2/inL6702)   ;Mean Ratio
       medratio_L670_a2 = median(ddsL670_a2/inL6702)    ;Median Ratio
       avgpd_L670_a2 = mean(abs((ddsL670_a2-inL6702)/inL6702))*100.   ;Mean % diff
       medpd_L670_a2 = median(abs((ddsL670_a2-inL6702)/inL6702))*100. ;Median % diff

       range_inL6702 = [min(inL6702),max(inL6702)]    ;in-situ range
       range_ddsL670_a2 = [min(ddsL670_a2),max(ddsL670_a2)]    ;DDS range


       printf,2,'L670',nL670_a2,fit_L670_a2(1),fit_L670_a2(0),fit_L670_a2(2),avgratio_L670_a2,medratio_L670_a2, $
               avgpd_L670_a2,medpd_L670_a2,bias_L670_a2,rms_L670_a2,relbias_L670_a2,relrms_L670_a2, $
               range_inL6702,range_ddsL670_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL670_a2 GT 0) then begin
;-15.2 With filtered average data
;-15. L670


;+16. L681
 ;+16.1 With standard average data
    inL681=data.inL681(p)
    ddsL681_a = data.ddsL681_avg(p)
    ddsL681_s = data.ddsL681_std(p)
    pp=where(inL681 GT 0. and ddsL681_a GT 0 and (ddsL681_s/ddsL681_a) LT cvar, nL681_a)
    if(nL681_a GE 2) then begin
       inL6811 = inL681(pp)
       ddsL681_a = ddsL681_a(pp)
       ddsL681_s = ddsL681_s(pp)

       fit_L681_a = [LINFIT(inL6811,ddsL681_a), (CORRELATE(inL6811,ddsL681_a,/DOUBLE))^2.]
       relrms_L681_a = sqrt(mean(alog10(ddsL681_a/inL6811)^2.))   ;Relative RMS
       relbias_L681_a = mean(alog10(ddsL681_a/inL6811))   ;Relative bias
       rms_L681_a = sqrt(mean((ddsL681_a-inL6811)^2.))    ;Not to be considered for L681
       bias_L681_a = mean(ddsL681_a-inL6811)          ;Not to be considered for L681

       avgratio_L681_a = mean(ddsL681_a/inL6811)   ;Mean Ratio
       medratio_L681_a = median(ddsL681_a/inL6811)    ;Median Ratio
       avgpd_L681_a = mean(abs((ddsL681_a-inL6811)/inL6811))*100.   ;Mean % diff
       medpd_L681_a = median(abs((ddsL681_a-inL6811)/inL6811))*100. ;Median % diff
       range_inL6811 = [min(inL6811),max(inL6811)]    ;in-situ range
       range_ddsL681_a = [min(ddsL681_a),max(ddsL681_a)]    ;DDS range

       printf,1,'L681',nL681_a,fit_L681_a(1),fit_L681_a(0),fit_L681_a(2),avgratio_L681_a,medratio_L681_a, $
               avgpd_L681_a,medpd_L681_a,bias_L681_a,rms_L681_a,relbias_L681_a,relrms_L681_a, $
               range_inL6811,range_ddsL681_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL681_a GT 0) then begin
;-16.1 With standard average data
;+16.2 With filtered average data
    inL681=data.inL681(p)
    ddsL681_a2 = data.ddsL681_avg2(p)
    ddsL681_s2 = data.ddsL681_std2(p)
    pp=where(inL681 GT 0. and ddsL681_a2 GT 0, nL681_a2)
    if(nL681_a2 GE 2) then begin
       inL6812 = inL681(pp)
       ddsL681_a2 = ddsL681_a2(pp)
       ddsL681_s2 = ddsL681_s2(pp)

       fit_L681_a2 = [LINFIT(inL6812,ddsL681_a2), (CORRELATE(inL6812,ddsL681_a2,/DOUBLE))^2.]
       relrms_L681_a2 = sqrt(mean(alog10(ddsL681_a2/inL6812)^2.))   ;Relative RMS
       relbias_L681_a2 = mean(alog10(ddsL681_a2/inL6812))   ;Relative bias
       rms_L681_a2 = sqrt(mean((ddsL681_a2-inL6812)^2.))    ;Not to be considered for L681
       bias_L681_a2 = mean(ddsL681_a2-inL6812)          ;Not to be considered for L681

       avgratio_L681_a2 = mean(ddsL681_a2/inL6812)   ;Mean Ratio
       medratio_L681_a2 = median(ddsL681_a2/inL6812)    ;Median Ratio
       avgpd_L681_a2 = mean(abs((ddsL681_a2-inL6812)/inL6812))*100.   ;Mean % diff
       medpd_L681_a2 = median(abs((ddsL681_a2-inL6812)/inL6812))*100. ;Median % diff

       range_inL6812 = [min(inL6812),max(inL6812)]    ;in-situ range
       range_ddsL681_a2 = [min(ddsL681_a2),max(ddsL681_a2)]    ;DDS range


       printf,2,'L681',nL681_a2,fit_L681_a2(1),fit_L681_a2(0),fit_L681_a2(2),avgratio_L681_a2,medratio_L681_a2, $
               avgpd_L681_a2,medpd_L681_a2,bias_L681_a2,rms_L681_a2,relbias_L681_a2,relrms_L681_a2, $
               range_inL6812,range_ddsL681_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL681_a2 GT 0) then begin
;-16.2 With filtered average data
;-16. L681


;+17. L709
 ;+17.1 With standard average data
    inL709=data.inL709(p)
    ddsL709_a = data.ddsL709_avg(p)
    ddsL709_s = data.ddsL709_std(p)
    pp=where(inL709 GT 0. and ddsL709_a GT 0 and (ddsL709_s/ddsL709_a) LT cvar, nL709_a)
    if(nL709_a GE 2) then begin
       inL7091 = inL709(pp)
       ddsL709_a = ddsL709_a(pp)
       ddsL709_s = ddsL709_s(pp)

       fit_L709_a = [LINFIT(inL7091,ddsL709_a), (CORRELATE(inL7091,ddsL709_a,/DOUBLE))^2.]
       relrms_L709_a = sqrt(mean(alog10(ddsL709_a/inL7091)^2.))   ;Relative RMS
       relbias_L709_a = mean(alog10(ddsL709_a/inL7091))   ;Relative bias
       rms_L709_a = sqrt(mean((ddsL709_a-inL7091)^2.))    ;Not to be considered for L709
       bias_L709_a = mean(ddsL709_a-inL7091)          ;Not to be considered for L709

       avgratio_L709_a = mean(ddsL709_a/inL7091)   ;Mean Ratio
       medratio_L709_a = median(ddsL709_a/inL7091)    ;Median Ratio
       avgpd_L709_a = mean(abs((ddsL709_a-inL7091)/inL7091))*100.   ;Mean % diff
       medpd_L709_a = median(abs((ddsL709_a-inL7091)/inL7091))*100. ;Median % diff
       range_inL7091 = [min(inL7091),max(inL7091)]    ;in-situ range
       range_ddsL709_a = [min(ddsL709_a),max(ddsL709_a)]    ;DDS range

       printf,1,'L709',nL709_a,fit_L709_a(1),fit_L709_a(0),fit_L709_a(2),avgratio_L709_a,medratio_L709_a, $
               avgpd_L709_a,medpd_L709_a,bias_L709_a,rms_L709_a,relbias_L709_a,relrms_L709_a, $
               range_inL7091,range_ddsL709_a,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL709_a GT 0) then begin
;-17.1 With standard average data
;+17.2 With filtered average data
    inL709=data.inL709(p)
    ddsL709_a2 = data.ddsL709_avg2(p)
    ddsL709_s2 = data.ddsL709_std2(p)
    pp=where(inL709 GT 0. and ddsL709_a2 GT 0, nL709_a2)
    if(nL709_a2 GE 2) then begin
       inL7092 = inL709(pp)
       ddsL709_a2 = ddsL709_a2(pp)
       ddsL709_s2 = ddsL709_s2(pp)

       fit_L709_a2 = [LINFIT(inL7092,ddsL709_a2), (CORRELATE(inL7092,ddsL709_a2,/DOUBLE))^2.]
       relrms_L709_a2 = sqrt(mean(alog10(ddsL709_a2/inL7092)^2.))   ;Relative RMS
       relbias_L709_a2 = mean(alog10(ddsL709_a2/inL7092))   ;Relative bias
       rms_L709_a2 = sqrt(mean((ddsL709_a2-inL7092)^2.))    ;Not to be considered for L709
       bias_L709_a2 = mean(ddsL709_a2-inL7092)          ;Not to be considered for L709

       avgratio_L709_a2 = mean(ddsL709_a2/inL7092)   ;Mean Ratio
       medratio_L709_a2 = median(ddsL709_a2/inL7092)    ;Median Ratio
       avgpd_L709_a2 = mean(abs((ddsL709_a2-inL7092)/inL7092))*100.   ;Mean % diff
       medpd_L709_a2 = median(abs((ddsL709_a2-inL7092)/inL7092))*100. ;Median % diff

       range_inL7092 = [min(inL7092),max(inL7092)]    ;in-situ range
       range_ddsL709_a2 = [min(ddsL709_a2),max(ddsL709_a2)]    ;DDS range


       printf,2,'L709',nL709_a2,fit_L709_a2(1),fit_L709_a2(0),fit_L709_a2(2),avgratio_L709_a2,medratio_L709_a2, $
               avgpd_L709_a2,medpd_L709_a2,bias_L709_a2,rms_L709_a2,relbias_L709_a2,relrms_L709_a2, $
               range_inL7092,range_ddsL709_a2,FORMAT='(A,",",I,",",14(F,","),F)'
    endif   ;if(nL709_a2 GT 0) then begin
;-17.2 With filtered average data
;-17. L709






;-------------------------------------------------
;+Plot Stat
 ;if(KEYWORD_SET(show)) then begin
 tek_color
 !P.CHARTHICK=3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PLOTS-1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;--------
 ;+1.CHL1
    xr=(yr=[0.01,100])
    PLOT,xr,yr,/NODATA,Title='CHL1 [mg/m!u3!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nCHL1_a GE 2) then begin
      OPLOT,inChl1,ddsCHL1_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inChl1,ddsCHL1_a-ddsCHL1_s,ddsCHL1_a+ddsCHL1_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_CHL1_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_CHL1_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_CHL1_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_CHL1_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_CHL1_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nCHL1_a,format='(I4)')
      if(nCHL1_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nCHL1_a LT 6) then begin
    endif $ ;if(nCHL1_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-1.CHL1
;--------
 ;+2.CHL2
    xr=(yr=[0.01,100])
    PLOT,xr,yr,/NODATA,Title='CHL2 [mg/m!u3!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nCHL2_a GE 2) then begin
      OPLOT,inChl2,ddsCHL2_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inChl2,ddsCHL2_a-ddsCHL2_s,ddsCHL2_a+ddsCHL2_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_CHL2_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_CHL2_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_CHL2_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_CHL2_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_CHL2_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nCHL2_a,format='(I4)')
      if(nCHL2_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nCHL2_a LT 6) then begin
    endif $ ;if(nCHL2_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-2.CHL2
;--------
 ;+3.KD490
    xr=(yr=[0.001,1])
    PLOT,xr,yr,/NODATA,Title='Kd490 [m!u-1!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nK490_a GE 2) then begin
      OPLOT,inK4901,ddsK490_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inK4901,ddsK490_a-ddsK490_s,ddsK490_a+ddsK490_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_K490_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_K490_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_K490_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_K490_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_K490_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nK490_a,format='(I4)')
      if(nK490_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nK490_a LT 6) then begin
    endif $ ;if(nK490_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-3.KD490
;--------
 ;+4.CDM
    xr=(yr=[0.0001,2])
    PLOT,xr,yr,/NODATA,Title='CDM [m!u-1!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nCDM_a GE 2) then begin
      OPLOT,inaCDM1,ddsaCDM_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inaCDM1,ddsaCDM_a-ddsaCDM_s,ddsaCDM_a+ddsaCDM_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_CDM_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_CDM_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_CDM_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_CDM_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_CDM_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nCDM_a,format='(I4)')
      if(nCDM_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nCDM_a LT 6) then begin
    endif $ ;if(nCDM_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-4.CDM
;--------
 ;+5.BBP
    xr=(yr=[0.0001,.1])
    PLOT,xr,yr,/NODATA,Title='BBP [m!u-1!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nBBP_a GE 2) then begin
      OPLOT,inBBP1,ddsBBP_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inBBP1,ddsBBP_a-ddsBBP_s,ddsBBP_a+ddsBBP_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_BBP_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_BBP_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_BBP_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_BBP_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_BBP_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nBBP_a,format='(I4)')
      if(nBBP_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nBBP_a LT 6) then begin
    endif $ ;if(nBBP_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-5.BBP
;--------
 ;+6.T865
    xr=(yr=[-0.1,1])
    PLOT,xr,yr,/NODATA,Title='T865 []',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nT865_a GE 2) then begin
      OPLOT,inT8651,ddsT865_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inT8651,ddsT865_a-ddsT865_s,ddsT865_a+ddsT865_s
      OPLOT,xr,yr
;print,min(inT8651),max(inT8651),min(ddsT865_a),max(ddsT865_a)
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_T865_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_T865_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_T865_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_T865_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_T865_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nT865_a,format='(I4)')
      if(nT865_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nT865_a LT 6) then begin
    endif $ ;if(nT865_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-6.T865
;--------
 ;+7.L412
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L412 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL412_a GE 2) then begin
      OPLOT,inL4121,ddsL412_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL4121,ddsL412_a-ddsL412_s,ddsL412_a+ddsL412_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L412_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L412_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L412_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L412_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L412_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL412_a,format='(I4)')
      if(nL412_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL412_a LT 6) then begin
    endif $ ;if(nL412_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-7.L412
;--------
 ;+8.L443
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L443 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL443_a GE 2) then begin
      OPLOT,inL4431,ddsL443_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL4431,ddsL443_a-ddsL443_s,ddsL443_a+ddsL443_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L443_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L443_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L443_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L443_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L443_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL443_a,format='(I4)')
      if(nL443_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL443_a LT 6) then begin
    endif $ ;if(nL443_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-8.L443
;--------
 ;+9.L490
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L490 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL490_a GE 2) then begin
      OPLOT,inL4901,ddsL490_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL4901,ddsL490_a-ddsL490_s,ddsL490_a+ddsL490_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L490_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L490_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L490_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L490_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L490_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL490_a,format='(I4)')
      if(nL490_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL490_a LT 6) then begin
    endif $ ;if(nL490_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-9.L490
;--------
 ;+108.L510
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L510 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL510_a GE 2) then begin
      OPLOT,inL5101,ddsL510_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL5101,ddsL510_a-ddsL510_s,ddsL510_a+ddsL510_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L510_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L510_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L510_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L510_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L510_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL510_a,format='(I4)')
      if(nL510_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL510_a LT 6) then begin
    endif $ ;if(nL510_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-10.L510
;--------
 ;+11.L531
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L531 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL531_a GE 2) then begin
      OPLOT,inL5311,ddsL531_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL5311,ddsL531_a-ddsL531_s,ddsL531_a+ddsL531_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L531_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L531_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L531_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L531_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L531_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL531_a,format='(I4)')
      if(nL531_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL531_a LT 6) then begin
    endif $ ;if(nL531_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-11.L531
;--------
 ;+12.L555
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L555 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL555_a GE 2) then begin
      OPLOT,inL5551,ddsL555_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL5551,ddsL555_a-ddsL555_s,ddsL555_a+ddsL555_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L555_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L555_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L555_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L555_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L555_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL555_a,format='(I4)')
      if(nL555_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL555_a LT 6) then begin
    endif $ ;if(nL555_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-12.L555
;--------
 ;+13.L620
    xr=(yr=[-0.25,2.5])
    PLOT,xr,yr,/NODATA,Title='L620 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL620_a GE 2) then begin
      OPLOT,inL6201,ddsL620_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL6201,ddsL620_a-ddsL620_s,ddsL620_a+ddsL620_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L620_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L620_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L620_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L620_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L620_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL620_a,format='(I4)')
      if(nL620_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL620_a LT 6) then begin
    endif $ ;if(nL620_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-13.L620
;--------
 ;+14.L670
    xr=(yr=[-0.05,1])
    PLOT,xr,yr,/NODATA,Title='L670 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL670_a GE 2) then begin
      OPLOT,inL6701,ddsL670_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL6701,ddsL670_a-ddsL670_s,ddsL670_a+ddsL670_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L670_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L670_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L670_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L670_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L670_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL670_a,format='(I4)')
      if(nL670_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL670_a LT 6) then begin
    endif $ ;if(nL670_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
    XYOUTS,.5,1.25,ALIGNMENT=.5,'______________________________________________________________'+$
    '_________________________________________________________________________________________'
 ;-14.L670
;--------
 ;+15.L681
    xr=(yr=[-0.05,1])
    PLOT,xr,yr,/NODATA,Title='L681 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL681_a GE 2) then begin
      OPLOT,inL6811,ddsL681_a,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL6811,ddsL681_a-ddsL681_s,ddsL681_a+ddsL681_s
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L681_a(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L681_a(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L681_a,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L681_a,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L681_a(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL681_a,format='(I4)')
      if(nL681_a LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL681_a LT 6) then begin
    endif $ ;if(nL681_a GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-15.L681



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PLOTS-2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;--------
 ;+1.CHL1
    xr=(yr=[0.01,100])
    PLOT,xr,yr,/NODATA,Title='CHL1 [mg/m!u3!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nCHL1_a2 GE 2) then begin
      OPLOT,inChl1,ddsCHL1_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inChl1,ddsCHL1_a2-ddsCHL1_s2,ddsCHL1_a2+ddsCHL1_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_CHL1_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_CHL1_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_CHL1_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_CHL1_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_CHL1_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nCHL1_a2,format='(I4)')
      if(nCHL1_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nCHL1_a2 LT 6) then begin
    endif $ ;if(nCHL1_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-1.CHL1
;--------
 ;+2.CHL2
    xr=(yr=[0.01,100])
    PLOT,xr,yr,/NODATA,Title='CHL2 [mg/m!u3!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nCHL2_a2 GE 2) then begin
      OPLOT,inChl22,ddsCHL2_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inChl22,ddsCHL2_a2-ddsCHL2_s2,ddsCHL2_a2+ddsCHL2_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_CHL2_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_CHL2_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_CHL2_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_CHL2_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_CHL2_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nCHL2_a2,format='(I4)')
      if(nCHL2_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nCHL2_a2 LT 6) then begin
    endif $ ;if(nCHL2_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-2.CHL2
;--------
 ;+3.KD490
    xr=(yr=[0.001,1])
    PLOT,xr,yr,/NODATA,Title='Kd490 [m!u-1!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nK490_a2 GE 2) then begin
      OPLOT,inK4902,ddsK490_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inK4902,ddsK490_a2-ddsK490_s2,ddsK490_a2+ddsK490_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_K490_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_K490_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_K490_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_K490_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_K490_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nK490_a2,format='(I4)')
      if(nK490_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nK490_a2 LT 6) then begin
    endif $ ;if(nK490_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-3.KD490
;--------
 ;+4.CDM
    xr=(yr=[0.0001,2])
    PLOT,xr,yr,/NODATA,Title='CDM [m!u-1!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nCDM_a2 GE 2) then begin
      OPLOT,inaCDM2,ddsaCDM_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inaCDM2,ddsaCDM_a2-ddsaCDM_s2,ddsaCDM_a2+ddsaCDM_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_CDM_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_CDM_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_CDM_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_CDM_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_CDM_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nCDM_a2,format='(I4)')
      if(nCDM_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nCDM_a2 LT 6) then begin
    endif $ ;if(nCDM_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-4.CDM
;--------
 ;+5.BBP
    xr=(yr=[0.0001,.1])
    PLOT,xr,yr,/NODATA,Title='BBP [m!u-1!n]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO, /XLOG, /YLOG

    if(nBBP_a2 GE 2) then begin
      OPLOT,inBBP2,ddsBBP_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inBBP2,ddsBBP_a2-ddsBBP_s2,ddsBBP_a2+ddsBBP_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_BBP_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_BBP_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(relbias_BBP_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(relrms_BBP_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_BBP_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nBBP_a2,format='(I4)')
      if(nBBP_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nBBP_a2 LT 6) then begin
    endif $ ;if(nBBP_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-5.BBP
;--------
 ;+6.T865
    xr=(yr=[-0.1,1])
    PLOT,xr,yr,/NODATA,Title='T865 []',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nT865_a2 GE 2) then begin
      OPLOT,inT8652,ddsT865_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inT8652,ddsT865_a2-ddsT865_s2,ddsT865_a2+ddsT865_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_T865_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_T865_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_T865_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_T865_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_T865_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nT865_a2,format='(I4)')
      if(nT865_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nT865_a2 LT 6) then begin
    endif $ ;if(nT865_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-6.T865
;--------
 ;+7.L412
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L412 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL412_a2 GE 2) then begin
      OPLOT,inL4122,ddsL412_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL4122,ddsL412_a2-ddsL412_s2,ddsL412_a2+ddsL412_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L412_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L412_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L412_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L412_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L412_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL412_a2,format='(I4)')
      if(nL412_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL412_a2 LT 6) then begin
    endif $ ;if(nL412_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-7.L412
;--------
 ;+8.L443
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L443 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL443_a2 GE 2) then begin
      OPLOT,inL4432,ddsL443_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL4432,ddsL443_a2-ddsL443_s2,ddsL443_a2+ddsL443_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L443_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L443_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L443_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L443_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L443_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL443_a2,format='(I4)')
      if(nL443_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL443_a2 LT 6) then begin
    endif $ ;if(nL443_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-8.L443
;--------
 ;+9.L490
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L490 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL490_a2 GE 2) then begin
      OPLOT,inL4902,ddsL490_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL4902,ddsL490_a2-ddsL490_s2,ddsL490_a2+ddsL490_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L490_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L490_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L490_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L490_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L490_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL490_a2,format='(I4)')
      if(nL490_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL490_a2 LT 6) then begin
    endif $ ;if(nL490_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-9.L490
;--------
 ;+108.L510
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L510 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL510_a2 GE 2) then begin
      OPLOT,inL5102,ddsL510_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL5102,ddsL510_a2-ddsL510_s2,ddsL510_a2+ddsL510_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L510_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L510_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L510_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L510_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L510_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL510_a2,format='(I4)')
      if(nL510_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL510_a2 LT 6) then begin
    endif $ ;if(nL510_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-10.L510
;--------
 ;+11.L531
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L531 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL531_a2 GE 2) then begin
      OPLOT,inL5312,ddsL531_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL5312,ddsL531_a2-ddsL531_s2,ddsL531_a2+ddsL531_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L531_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L531_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L531_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L531_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L531_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL531_a2,format='(I4)')
      if(nL531_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL531_a2 LT 6) then begin
    endif $ ;if(nL531_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-11.L531
;--------
 ;+12.L555
    xr=(yr=[-0.5,5])
    PLOT,xr,yr,/NODATA,Title='L555 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL555_a2 GE 2) then begin
      OPLOT,inL5552,ddsL555_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL5552,ddsL555_a2-ddsL555_s2,ddsL555_a2+ddsL555_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L555_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L555_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L555_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L555_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L555_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL555_a2,format='(I4)')
      if(nL555_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL555_a2 LT 6) then begin
    endif $ ;if(nL555_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-12.L555
;--------
 ;+13.L620
    xr=(yr=[-0.25,2.5])
    PLOT,xr,yr,/NODATA,Title='L620 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL620_a2 GE 2) then begin
      OPLOT,inL6202,ddsL620_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL6202,ddsL620_a2-ddsL620_s2,ddsL620_a2+ddsL620_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L620_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L620_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L620_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L620_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L620_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL620_a2,format='(I4)')
      if(nL620_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL620_a2 LT 6) then begin
    endif $ ;if(nL620_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-13.L620
;--------
 ;+14.L670
    xr=(yr=[-0.1,1])
    PLOT,xr,yr,/NODATA,Title='L670 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL670_a2 GE 2) then begin
      OPLOT,inL6702,ddsL670_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL6702,ddsL670_a2-ddsL670_s2,ddsL670_a2+ddsL670_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L670_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L670_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L670_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L670_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L670_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL670_a2,format='(I4)')
      if(nL670_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL670_a2 LT 6) then begin
    endif $ ;if(nL670_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-14.L670
;--------
 ;+15.L681
    xr=(yr=[-0.1,1])
    PLOT,xr,yr,/NODATA,Title='L681 [mW/cm!u2!n/!7l!5m/sr]',XTitle='in-situ',YTitle=sen_name,CHARSIZE=1.8, $
    XRange=xr,YRange=yr, XST=1, YST=1, /ISO;, /XLOG, /YLOG

    if(nL681_a2 GE 2) then begin
      OPLOT,inL6812,ddsL681_a2,psym=SYMCAT(16),SYMSIZE=.6,COLOR=4
      ERRPLOT,inL6812,ddsL681_a2-ddsL681_s2,ddsL681_a2+ddsL681_s2
      OPLOT,xr,yr

      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.03,.07,CHARSIZE=0.8,CHARTHICK=2, 'OFFSET'+string(fit_L681_a2(0),format='(f6.2)')
      XYOUTS,.03,.14,CHARSIZE=0.8,CHARTHICK=2, 'SLOPE'+string(fit_L681_a2(1),format='(f6.2)')
      XYOUTS,.03,.21,CHARSIZE=0.8,CHARTHICK=2, 'BIAS'+string(bias_L681_a2,format='(f6.2)')
      XYOUTS,.03,.28,CHARSIZE=0.8,CHARTHICK=2, 'RMS'+string(rms_L681_a2,format='(f5.2)')
      XYOUTS,.03,.35,CHARSIZE=0.8,CHARTHICK=2, 'r!u2!n'+string(fit_L681_a2(2),format='(f5.2)')
      XYOUTS,.03,.42,CHARSIZE=0.8,CHARTHICK=2, 'N'+string(nL681_a2,format='(I4)')
      if(nL681_a2 LT 6) then begin
        XYOUTS,.97,.9,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'Stat Warning!'
        XYOUTS,.97,.97,ALIGNMENT=1,CHARSIZE=.7,COLOR=2,CHARTHICK=2,'INSUFFICIENT DATA'
      endif ;if(nL681_a2 LT 6) then begin
    endif $ ;if(nL681_a2 GE 2) then begin
    else begin
      AXIS, YAXIS=1, YRANGE=[1,0], YLOG=0, YST=4, /SAVE
      AXIS, XAXIS=1, XRANGE=[0,1], XLOG=0, XST=4, /SAVE
      XYOUTS,.5,.5,CHARSIZE=1.5,CHARTHICK=3,ALIGNMENT=.5,COLOR=2,'NO DATA'
    endelse
 ;-15.L681




;-------------------------------------------------
    DEVICE, /CLOSE
    SET_PLOT, 'win'
    !P.MULTI = 0
 if(KEYWORD_SET(show)) then begin
    spawn,'gsview32 '+NEWDIR+separator+psFileName
 endif  ;if(KEYWORD_SET(show)) then begin
;-Plot Stat
;-------------------------------------------------
 PRINT,'FINISH.'
 endif  ;if(cnt GT 1) then begin

close,/all
;stop
END