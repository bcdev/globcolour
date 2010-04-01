PRO QC_BOUSSOLE, COMBINE_CHL=combine_chl, NORMALISE=normalise, CLIP_WL=clip_wl, $
          INTERACTIVE=interactive, JUN06=jun06, FEB07=feb07

;KEYWORDS:
;COMBINE_CHL -> to combine CTD(HPLC) Chlorophyll data (weighted mean) from Boussole-Chl-for-GlobColour.xls to the SPMR data
;NORMALISE -> apply f/Q correction to BOUSSOLE nLw (Gordon & Clark) (combine_chl KEYWORD is preferred)
;CLIP_WL -> with NORMALISE keyword, forces the in-situ wavelengths to match morel_foq LUT wavelengths
;INTERACTIVE -> Interatively scan in-situ records otherwise accepts all in-situ records
;JUN06 -> for boussole-spmr-for-GlobCOLOUR.csv
;FEB07 -> for boussole.spmr.for.GlobCOLOUR.fev2007.csv
;
;Author: Yaswant Pradhan, Dec 06
;

close,/all
file=DIALOG_PICKFILE(FILTER="*.csv",/READ,Title='Select BOUSSOLE SPMR File',GET_PATH=curr_dir)
cd,curr_dir

;---------------------------------------------------------------
if(KEYWORD_SET(combine_chl)) then begin
chl_template={$
 VERSION : 1.0,$
 DATASTART : 1,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 13,$
 FIELDTYPES : [3,3,3,3,3,4,4,4,3,4,4,4,4],$
 FIELDNAMES : ['NN','CruiseNo','dd','mm','yyyy','UTC','lat','lon','CTDNo','Depth','dv_Chla','mv_Chla','Chla'],$
 FIELDLOCATIONS : [0,2,4,7,9,14,20,27,33,35,37,44,51],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12]}
;The above template is valid for actual Chl observations as on Feb 2007.
;Use the following template for 5-column reconstructed surface Chl data from BOUSSOLE

surf_chl_template={$
 VERSION : 1.0,$
 DATASTART : 23,$
 DELIMITER : 32b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 5,$
 FIELDTYPES : [3,3,3,4,3],$
 FIELDNAMES : ['yyyy','mm','dd','Chla','Flag'],$
 FIELDLOCATIONS : [0,5,8,11,17],$
 FIELDGROUPS : [0,1,2,3,4]}

 chl_data=READ_ASCII(DIALOG_PICKFILE(/READ,FILTER='*.csv',Title='Select BOUSSOLE Chl File'),COUNT=nChl,TEMPLATE=chl_template)
 chlYear=(chlDate=INTARR(nChl))
 Chla=(chlTime=(chlDepth=(chlLat=(chlLon=(FLTARR(nChl))))))

 for i=0,nChl-1 do begin
    chlYear(i)=chl_data.yyyy(i)
    chlDate(i)=sdy(chl_data.dd(i),chl_data.mm(i),chl_data.yyyy(i))
    Chla(i)=chl_data.Chla(i)
    chlTime(i)=chl_data.UTC(i)
    chlDepth(i)=chl_data.Depth(i)
    chlLat(i)=chl_data.lat(i)
    chlLon(i)=chl_data.lon(i)
 endfor

 surf_chl_data=READ_ASCII(DIALOG_PICKFILE(/READ,FILTER='*.txt',Title='Select BOUSSOLE Surface Chl File'),COUNT=nsChl,TEMPLATE=surf_chl_template)
 surfchlYear=(surfchlDate=(surfChlaFlag=LONARR(nsChl)))
 surfChla=FLTARR(nsChl)
 for i=0,nsChl-1 do begin
    surfchlYear(i)=surf_chl_data.yyyy(i)
    surfchlDate(i)=sdy(surf_chl_data.dd(i),surf_chl_data.mm(i),surf_chl_data.yyyy(i))
    surfChla(i)=surf_chl_data.Chla(i)
    surfChlaFlag(i)=surf_chl_data.Flag(i)
 endfor
endif

;------------------------------------------------------------
if(KEYWORD_SET(jun06)) then begin
;June 2006 SPMR data
template={ $
   VERSION:         1.0, $
   DATASTART:       1, $
   DELIMITER:       44b, $
   MISSINGVALUE:    !values.f_NaN, $
   COMMENTSYMBOL:   '', $
   FIELDCOUNT:      44, $
   FIELDTYPES:      [3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4], $
   FIELDNAMES:      ['dd','mm','yyyy','UTC','CumulTime','lon','lat','SZA','nLw412','nLw442','nLw490','nLw510','nLw560','nLw620','nLw665','nLw681','nLw708','Es412','Es442','Es490','Es510','Es560','Es620','Es665','Es681','Es708', $
              'EsRat412','EsRat442','EsRat490','EsRat510','EsRat560','EsRat620','EsRat665','EsRat681','EsRat708','Kd412','Kd442','Kd490','Kd510','Kd560','Kd620','Kd665','Kd681','Kd708'], $
   FIELDLOCATIONS:  [0,3,5,10,17,25,31,38,45,56,67,78,89,100,111,122,133,144,156,168,180,193,205,217,229,241,253,264,275,286,297,308,319,330,341,352,363,374,385,396,407,418,429,440], $
   FIELDGROUPS:     [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43] }
  n_rows=n_lines(file)-1
endif else begin
;Feb 2007 SPMR data
template={ $
   VERSION:         1.0, $
   DATASTART:       2, $
   DELIMITER:       44b, $
   MISSINGVALUE:    !values.f_NaN, $
   COMMENTSYMBOL:   '', $
   FIELDCOUNT:      56, $
   FIELDTYPES:      [3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4], $
   FIELDNAMES:      ['dd','mm','yyyy','UTC','CumulTime','lon','lat','SZA',$
                'nLw380','nLw412','nLw442','nLw455','nLw490','nLw510','nLw530','nLw560','nLw620','nLw665','nLw681','nLw708',$
                'Es380','Es412','Es442','Es455','Es490','Es510','Es530','Es560','Es620','Es665','Es681','Es708', $
                'EsRat380','EsRat412','EsRat442','EsRat455','EsRat490','EsRat510','EsRat530','EsRat560','EsRat620','EsRat665','EsRat681','EsRat708',$
                'Kd380','Kd412','Kd442','Kd455','Kd490','Kd510','Kd530','Kd560','Kd620','Kd665','Kd681','Kd708'], $
   FIELDLOCATIONS:  [0,3,5,10,18,27,34,42,50,59,67,75,83,91,99,107,115,123,131,139,147,156,165,174,183,192,202,211,220,229,238,247,256,265,273,281,289,297,305,313,321,329,337,345,353,362,370,378,386,394,402,410,418,426,434,442],$
   FIELDGROUPS:     [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55]}
  n_rows=n_lines(file)-2
endelse
;------------------------------------------------------------
data=READ_ASCII(file,TEMPLATE=template)


;++OUTPUT FILES
openw,20,'Boussole-spmr-for-GlobCOLOUR_QC.csv'
if(KEYWORD_SET(jun06)) then begin
  printf,10,'dd,mm,yyyy,hour,minute,lon,lat,SZA,nLw412,nLw442,nLw490,nLw510,nLw560,nLw620,nLw665,nLw681,nLw708,'+$
         'Es412,Es442,Es490,Es510,Es560,Es620,Es665,Es681,Es708,'+ $
         'EsRat412,EsRat442,EsRat490,EsRat510,EsRat560,EsRat620,EsRat665,EsRat681,EsRat708,'+$
         'Kd412,Kd442,Kd490,Kd510,Kd560,Kd620,Kd665,Kd681,Kd708,Chl,Chl_Lat,Chl_Lon,Chl_Time'
wl=[412.,442.,490.,510.,560.,620.,665.,681.,708.]
nLw=[[data.nLw412],[data.nLw442],[data.nLw490],[data.nLw510],[data.nLw560],[data.nLw620],[data.nLw665],[data.nLw681],[data.nLw708]]
Es=[[data.Es412],[data.Es442],[data.Es490],[data.Es510],[data.Es560],[data.Es620],[data.Es665],[data.Es681],[data.Es708]]
EsRat=[[data.EsRat412],[data.EsRat442],[data.EsRat490],[data.EsRat510],[data.EsRat560],[data.EsRat620],[data.EsRat665],[data.EsRat681],[data.EsRat708]]
Kd=[[data.Kd412],[data.Kd442],[data.Kd490],[data.Kd510],[data.Kd560],[data.Kd620],[data.Kd665],[data.Kd681],[data.Kd708]]

endif else begin
  printf,20,'dd,mm,yyyy,hour,minute,lon,lat,SZA,nLw380,nLw412,nLw442,nLw455,nLw490,nLw510,nLw530,nLw560,nLw620,nLw665,nLw681,nLw708,'+$
         'Es380,Es412,Es442,Es455,Es490,Es510,Es530,Es560,Es620,Es665,Es681,Es708,'+ $
         'EsRat380,EsRat412,EsRat442,EsRat455,EsRat490,EsRat510,EsRat530,EsRat560,EsRat620,EsRat665,EsRat681,EsRat708,'+$
         'Kd380,Kd412,Kd442,Kd455,Kd490,Kd510,Kd530,Kd560,Kd620,Kd665,Kd681,Kd708,Chl,Chl_Lat,Chl_Lon,Chl_Time'

wl=[380.,412.,442.,455.,490.,510.,530.,560.,620.,665.,681.,708.]

if(KEYWORD_SET(normalise)) then begin
    wl=wl
    if(KEYWORD_SET(clip_wl)) then wl=[380.,412.5,442.5,455.,490.,510.,530.,560.,620.,660.,681.,708.]
endif

nLw=[[data.nLw380],[data.nLw412],[data.nLw442],[data.nLw455],[data.nLw490],[data.nLw510],[data.nLw530],[data.nLw560],[data.nLw620],[data.nLw665],[data.nLw681],[data.nLw708]]>0.
Es=[[data.Es380],[data.Es412],[data.Es442],[data.Es455],[data.Es490],[data.Es510],[data.Es530],[data.Es560],[data.Es620],[data.Es665],[data.Es681],[data.Es708]]>0.
EsRat=[[data.EsRat380],[data.EsRat412],[data.EsRat442],[data.EsRat455],[data.EsRat490],[data.EsRat510],[data.EsRat530],[data.EsRat560],[data.EsRat620],[data.EsRat665],[data.EsRat681],[data.EsRat708]]>0.
Kd=[[data.Kd380],[data.Kd412],[data.Kd442],[data.Kd455],[data.Kd490],[data.Kd510],[data.Kd530],[data.Kd560],[data.Kd620],[data.Kd665],[data.Kd681],[data.Kd708]]>0.
endelse

if(KEYWORD_SET(normalise)) then begin
fqtab=read_MorelfQ_LUT()
  openw,11,'Boussole-exnLw-for-GlobCOLOUR_QC.csv'
  printf,11,'dd,mm,yyyy,hour,minute,lon,lat,SZA,'+$
            'exnLw380,exnLw412,exnLw442,exnLw455,exnLw490,exnLw510,exnLw530,exnLw560,exnLw620,exnLw665,exnLw681,exnLw708,Chla,Kd490,Chl_Flag'
endif

;--OUTPUT FILES



device,decomposed=0
!p.background='ffffff'x
!p.color='000000'x
tek_color

pos = [0.2, 0.2, 0.75, 0.9]
window,1,XSIZE=600,YSIZE=400,XPOS=10,YPOS=10,TITLE='QC_BOUSSOLE'
accept=''


for i=0,n_rows-1 do begin
;for i=0,2 do begin
get_chl=!Values.F_NaN
get_chl_lat_lon_time=MAKE_ARRAY(3,Value=!Values.F_NaN)
    if(KEYWORD_SET(combine_chl)) then begin
      Chl_flag=1
      spmrDate=sdy(data.dd(i),data.mm(i),data.yyyy(i))
      spmrYear=data.yyyy(i)
      spmrTime=data.UTC(i)
      tDiff=ABS(spmrTime - chlTime)
      px=where(spmrYear EQ chlYear and spmrDate EQ chlDate and chlDepth LT 20. and tDiff LE 0.3,d)
      if(d LT 1) then px=where(spmrYear EQ chlYear and spmrDate EQ chlDate and chlDepth LE 20. and tDiff LE 1.0,d)
      if(d EQ 1) then begin
        get_chl=Chla(px(0))
        get_chl_lat_lon_time=[chlLat(px(0)),chlLon(px(0)),chlTime(px(0))]
      endif else if(d GE 2) then begin  ;do a weighted average if data at more than 1 depth are available
        id=sort(chlDepth(px))
        wt=reverse(findgen(d)+1)    ;define weights max for surface most depth and 1 for bottom most depth
        get_chl=total(wt*Chla(px(id)))/total(wt)
        get_chl_lat_lon_time=[chlLat(px(0)),chlLon(px(0)),chlTime(px(0))]
      endif else if(d LT 1) then begin  ;read the chl value from reconstructed surface Chl file
        px=where(spmrYear EQ surfchlYear and spmrDate EQ surfchlDate,s)
        if(s GT 0) then begin
            get_chl=surfChla(px(0))
            if(surfChlaFlag(px(0)) EQ 0) then Chl_flag=0
        endif
      endif
    endif


    p=where(nLw(i,*) EQ 0,c)
    if(c GT 0) then nLw(i,p)=!Values.F_NaN
    if(TOTAL(nLw(i,*),/NaN) EQ 0.) then nLw(i,*)=0.
    PLOT,wl,nLw(i,*), YST=8, XRANGE=[350.,750.],XST=1,PSYM=-SYMCAT(16),POSITION=pos,YTITLE='nLw',XTITLE='Wavelength (nm)',THICK=2, $
        TITLE="SZA: "+string(data.SZA(i),format='(F6.2)')+" Date: "+string(data.yyyy(i),format='(I4.4)')+$
        string(data.mm(i),format='(I2.2)')+string(data.dd(i),format='(I2.2)')+" UTC: "+string(data.UTC(i),format='(F5.2)')+$
        " Chla: "+string(get_chl,format='(F6.3)')

    p=where(Es(i,*) EQ 0,c)
    if(c GT 0) then Es(i,p)=!Values.F_NaN
    if(TOTAL(Es(i,*),/NaN) EQ 0.) then Es(i,*)=0.
    AXIS, 0.1, 0.2, /NORM, /SAVE, YAXIS=0, YRANGE=[min(Es(i,*),/NaN),max(Es(i,*),/NaN)], COLOR=2, YTITLE = 'Es'
    OPLOT,wl,Es(i,*),PSYM=-SYMCAT(16),COLOR=2,THICK=2

    p=where(Kd(i,*) EQ 0,c)
    if(c GT 0) then Kd(i,p)=!Values.F_NaN
    if(TOTAL(Kd(i,*),/NaN) EQ 0.) then Kd(i,*)=0.
    AXIS, 0.75, 0.2, /NORM, /SAVE, YAXIS=1, YRANGE=[min(Kd(i,*),/NaN),max(Kd(i,*),/NaN)], COLOR=4, YTITLE = 'Kd'
    OPLOT,wl,Kd(i,*),PSYM=-SYMCAT(16),COLOR=4,THICK=2

    p=where(EsRat(i,*) EQ 0,c)
    if(c GT 0) then EsRat(i,p)=!Values.F_NaN
    if(TOTAL(EsRat(i,*),/NaN) EQ 0.) then EsRat(i,*)=0.
    AXIS, 0.85, 0.2, /NORM, /SAVE, YAXIS=1, YRANGE=[min(EsRat(i,*),/NaN),max(EsRat(i,*),/NaN)], COLOR=15,YTITLE = 'EsRatio'
    OPLOT,wl,EsRat(i,*), COLOR=15,THICK=2

    if(KEYWORD_SET(interactive)) then read,accept

    if ~(strcmp(accept,'n')) then begin
      print,i+1,' ACCEPT'
      time=strcompress(string(data.UTC(i),format='(f5.2)'),/remove_all)
      temp=strsplit(time,'.',/extract)
      hour=temp[0]
      minute=temp[1]
        if(KEYWORD_SET(jun06)) then begin
          printf,20,data.dd(i),data.mm(i),data.yyyy(i),hour,minute,data.lon(i),data.lat(i),data.SZA(i),$
          nLw(i,*),Es(i,*),EsRat(i,*),Kd(i,*),get_chl,get_chl_lat_lon_time, format='(5(I,","),43(F,","))'
        endif else printf,20,data.dd(i),data.mm(i),data.yyyy(i),hour,minute,data.lon(i),data.lat(i),data.SZA(i),$
          nLw(i,*),Es(i,*),EsRat(i,*),Kd(i,*),get_chl,get_chl_lat_lon_time, format='(5(I,","),55(F,","))'

        if(KEYWORD_SET(normalise)) then begin
         inChl=get_chl
         if(~FINITE(inChl)) then begin
            inChl=MOREL_CHL_KD_CASE1(kd490=Kd(i,4))
            Chl_flag=-9
         endif
         n_wl=n_elements(wl)
         solz=data.SZA(i)
         get_morel_fQ,fqtab, wl, n_wl, solz, 0.D, 0.D, inChl, f_Q
         printf,11,data.dd(i),data.mm(i),data.yyyy(i),hour,minute,data.lon(i),data.lat(i),data.SZA(i),$
              nLw(i,*)*f_Q,inChl,Kd(i,4),Chl_flag,FORMAT='(5(I,","),17(F,","),I)'
       endif


    endif else print,'REJECT'

endfor
close,/all
print,'>>>>DONE<<<<'
END