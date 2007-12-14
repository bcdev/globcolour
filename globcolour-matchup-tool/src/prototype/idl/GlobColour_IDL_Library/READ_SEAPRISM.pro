FUNCTION READ_SEAPRISM, file, data_struct, $
        VERB=verb, INTERPOL_GC=interpol_gc, SHOW=show, PLOT1=plot1

;+
; Pre-defined Function to Read SeaPRISM data (reorganised csv file) from AERONET site
; Yaswant Pradhan
;-

if(n_params() LT 1) then begin
    file=DIALOG_PICKFILE(/READ,FILTER='*.csv',Title='Select SeaPRISM File.',GET_PATH=cwd)
    cd,cwd
endif

location=file_basename(file,'.csv')
print,'You have selected a file from AERONATE Location : ',location

if(strcmp(location,'SEAPRISM_exLwn_Abu_Al_Bukhoosh')) then begin
SPR_Template={$
 VERSION : 1.0,$
 DATASTART : 10,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 16,$
 FIELDTYPES : [7,7,4,3,4,4,4,4,4,4,4,4,4,4,4,7],$
 FIELDNAMES : ['Date','Time','FSDY','Instrument','Lwn412','Lwn440','Lwn490','Lwn500','Lwn555','Lwn675','Pressure','Windspeed','Chla','SSRfl','Ozone','Processing_Date'],$
 FIELDLOCATIONS : [0,11,20,31,34,43,52,55,64,73,82,94,96,105,114,125],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]}
 wl=[412,440,490,500,555,675]
endif else if (strcmp(location,'SEAPRISM_exLwn_COVE')) then begin
SPR_Template={$
 VERSION : 1.0,$
 DATASTART : 10,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 15,$
 FIELDTYPES : [7,7,4,3,4,4,4,4,4,4,4,4,4,4,7],$
 FIELDNAMES : ['Date','Time','FSDY','Instrument','Lwn413','Lwn441','Lwn489','Lwn551','Lwn668','Pressure','Windspeed','Chla','SSRfl','Ozone','Processing_Date'],$
 FIELDLOCATIONS : [0,11,20,31,34,43,51,60,69,78,90,92,101,110,121],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]}
 wl=[413,441,489,551,668]
endif else if (strcmp(location,'SEAPRISM_exLwn_Gustav_Dalen_Tower')) then begin
SPR_Template={$
 VERSION : 1.0,$
 DATASTART : 10,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 18,$
 FIELDTYPES : [7,7,4,3,4,4,4,4,4,4,4,4,4,4,4,4,4,7],$
 FIELDNAMES : ['Date','Time','FSDY','Instrument','Lwn412','Lwn439','Lwn441','Lwn491','Lwn500','Lwn554','Lwn668','Lwn675','Pressure','Windspeed','Chla','SSRfl','Ozone','Processing_Date'],$
 FIELDLOCATIONS : [0,11,20,31,35,44,53,56,59,68,77,80,88,100,104,113,122,133],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}
 wl=[412,439,441,491,500,554,668,675]
endif else if (strcmp(location,'SEAPRISM_exLwn_Helsinki_Lighthouse')) then begin
SPR_Template={$
 VERSION : 1.0,$
 DATASTART : 10,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 15,$
 FIELDTYPES : [7,7,4,3,4,4,4,4,4,4,4,4,4,4,7],$
 FIELDNAMES : ['Date','Time','FSDY','Instrument','Lwn413','Lwn441','Lwn491','Lwn555','Lwn668','Pressure','Windspeed','Chla','SSRfl','Ozone','Processing_Date'],$
 FIELDLOCATIONS : [0,11,20,31,35,43,51,60,69,78,90,92,101,110,121],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]}
 wl=[413,441,491,555,668]
endif else if (strcmp(location,'SEAPRISM_exLwn_MVCO')) then begin
SPR_Template={$
 VERSION : 1.0,$
 DATASTART : 10,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 18,$
 FIELDTYPES : [7,7,4,3,4,4,4,4,4,4,4,4,4,4,4,4,4,7],$
 FIELDNAMES : ['Date','Time','FSDY','Instrument','Lwn412','Lwn439','Lwn442','Lwn490','Lwn500','Lwn555','Lwn668','Lwn674','Pressure','Windspeed','Chla','SSRfl','Ozone','Processing_Date'],$
 FIELDLOCATIONS : [0,11,20,29,33,42,51,54,57,66,75,78,86,93,97,106,115,126],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]}
 wl=[412,442,490,500,555,668,674]
 endif else if (strcmp(location,'SEAPRISM_exLwn_Venice')) then begin
SPR_Template={$
 VERSION : 1.0,$
 DATASTART : 10,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 20,$
 FIELDTYPES : [7,7,4,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,7],$
 FIELDNAMES : ['Date','Time','FSDY','Instrument','Lwn413','Lwn440','Lwn442','Lwn490','Lwn501','Lwn550','Lwn555','Lwn667','Lwn670','Lwn674','Pressure','Windspeed','Chla','SSRfl','Ozone','Processing_Date'],$
 FIELDLOCATIONS : [0,11,20,31,35,44,53,56,59,68,71,80,83,86,95,102,106,115,124,135],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]}
 wl=[413,440,442,490,501,550,555,667,670,674]
endif

if(keyword_set(verb)) then begin
 print,'RECORDS :',SPR_Template.FIELDCOUNT
 print,'FIELDNAMES:',SPR_Template.FIELDNAMES;,format='((A))'
 print,'MISSING :',SPR_Template.MISSINGVALUE
endif
 data=READ_ASCII(file,TEMPLATE=SPR_Template)



if(keyword_set(interpol_gc)) then begin
 wl_gc=[412,443,490,510,531,555,620,670]
 if(strcmp(location,'SEAPRISM_exLwn_Abu_Al_Bukhoosh')) then begin
    wl=[412,440,490,500,555,675]
    Lwn_gc=fltarr(n_elements(wl_gc),n_elements(data.DATE))
    for i=0,n_elements(data.DATE)-1 do begin
      Lwn=[data.Lwn412[i],data.Lwn440[i],data.Lwn490[i],data.Lwn500[i],data.Lwn555[i],data.Lwn675[i]]
      pos=where(finite(Lwn),cnt)
      if(cnt GT 0) then Lwn_gc(*,i)=interpol(Lwn(pos),wl(pos),wl_gc)
    endfor
 endif else if(strcmp(location,'SEAPRISM_exLwn_COVE')) then begin
    wl=[413,441,489,551,668]
    Lwn_gc=fltarr(n_elements(wl_gc),n_elements(data.DATE))
    for i=0,n_elements(data.DATE)-1 do begin
      Lwn=[data.Lwn413[i],data.Lwn441[i],data.Lwn489[i],data.Lwn551[i],data.Lwn668[i]]
      pos=where(finite(Lwn),cnt)
      if(cnt GT 0) then Lwn_gc(*,i)=interpol(Lwn(pos),wl(pos),wl_gc)
    endfor
 endif else if(strcmp(location,'SEAPRISM_exLwn_Gustav_Dalen_Tower')) then begin
    wl=[412,439,441,491,500,554,668,675]
    Lwn_gc=fltarr(n_elements(wl_gc),n_elements(data.DATE))
    for i=0,n_elements(data.DATE)-1 do begin
      Lwn=[data.Lwn412[i],data.Lwn439[i],data.Lwn441[i],data.Lwn491[i],data.Lwn500[i],$
         data.Lwn554[i],data.Lwn668[i],data.Lwn675[i]]
      pos=where(finite(Lwn),cnt)
      if(cnt GT 0) then Lwn_gc(*,i)=interpol(Lwn(pos),wl(pos),wl_gc)
    endfor
 endif else if(strcmp(location,'SEAPRISM_exLwn_Helsinki_Lighthouse')) then begin
    wl=[413,441,491,555,668]
    Lwn_gc=fltarr(n_elements(wl_gc),n_elements(data.DATE))
    for i=0,n_elements(data.DATE)-1 do begin
      Lwn=[data.Lwn413[i],data.Lwn441[i],data.Lwn491[i],data.Lwn555[i],data.Lwn668[i]]
      pos=where(finite(Lwn),cnt)
      if(cnt GT 0) then Lwn_gc(*,i)=interpol(Lwn(pos),wl(pos),wl_gc)
    endfor
 endif else if(strcmp(location,'SEAPRISM_exLwn_MVCO')) then begin
    wl=[412,442,490,500,555,668,674]
    Lwn_gc=fltarr(n_elements(wl_gc),n_elements(data.DATE))
    for i=0,n_elements(data.DATE)-1 do begin
      Lwn=[data.Lwn412[i],data.Lwn442[i],data.Lwn490[i],data.Lwn500[i],data.Lwn555[i],data.Lwn668[i],data.Lwn674[i]]
      pos=where(finite(Lwn),cnt)
      if(cnt GT 0) then Lwn_gc(*,i)=interpol(Lwn(pos),wl(pos),wl_gc)
    endfor
 endif else if(strcmp(location,'SEAPRISM_exLwn_Venice')) then begin
    Lwn_gc=fltarr(n_elements(wl_gc),n_elements(data.DATE))
    for i=0,n_elements(data.DATE)-1 do begin
      Lwn=[data.Lwn413[i],data.Lwn440[i],data.Lwn442[i],data.Lwn490[i],data.Lwn501[i],$
         data.Lwn550[i],data.Lwn555[i],data.Lwn667[i],data.Lwn670[i],data.Lwn674[i]]
      pos=where(finite(Lwn),cnt)
      if(cnt GT 0) then Lwn_gc(*,i)=interpol(Lwn(pos),wl(pos),wl_gc)
    endfor
 endif
endif


if(keyword_set(show)) then begin
 device,decomposed=0
 tek_color
 !P.BACKGROUND='ffffff'x
 !P.COLOR='000000'x
 !P.THICK=2
 !P.FONT=-1
 if(~keyword_set(plot1)) then !P.MULTI=[0,2,2]

 ;window,Title=location
 SET_PLOT, 'PS'
 psFileName=DIALOG_PICKFILE(FILTER=['*.ps','*.eps'],/WRITE,Title='Please Type EPS File Name.')
 DEVICE, /COLOR,/ENCAPSUL,xSize=20.,ySize=15.,BITS_PER_PIXEL=8,FILENAME=psFileName

 if(keyword_set(plot1)) then begin
  plot,wl(pos),Lwn(pos),/NODATA,color=15,xmar=[8,4],CHARSIZE=1.6,$
    LINESTYLE=-1,xgridstyle=1,xticklen=1,ygridstyle=1,yticklen=1;,xtickname=[''],ytickname=['']

  plot,wl(pos),Lwn(pos),psym=symcat(33), $
    xtitle='!17wavelength (nm)!5',ytitle='L!S!Uex!R!Dwn!n (!7l!17W/cm!u2!n/nm/sr)', xmar=[8,4], $
    SYMSIZE=1.6,CHARSIZE=1.6,Title=location,/noerase
    ;LINESTYLE=-1,xgridstyle=1,xticklen=1,ygridstyle=1,yticklen=1
  oplot,wl_gc,interpol(Lwn(pos),wl(pos),wl_gc,/quadratic),psym=-symcat(1),COLOR=2,SYMSIZE=1.6,THICK=3
  oplot,wl_gc,interpol(Lwn(pos),wl(pos),wl_gc,/spline),psym=-symcat(1),COLOR=3,SYMSIZE=1.6,THICK=3
  oplot,wl_gc,interpol(Lwn(pos),wl(pos),wl_gc),psym=-symcat(1),COLOR=4,SYMSIZE=1.6,THICK=3
  xyouts,/normal,[0.8,0.8,0.8,.8],[.9,.85,.8,.75],['!5Original','Linear','Spline','Quadratic'],COLOR=[0,4,3,2]
 endif else begin
  plot,wl(pos),Lwn(pos),psym=1,Title='!17Original Data',COLOR=0,ytit='!NL!S!Uex!R!Dwn'

  plot,wl(pos),Lwn(pos),Title='Quadratic',psym=-1
  oplot,wl_gc,interpol(Lwn(pos),wl(pos),wl_gc,/quadratic),psym=-symcat(7),COLOR=2

  plot,wl(pos),Lwn(pos),Title='Spline',psym=-1,ytit='!NL!S!Uex!R!Dwn',xtit='wavelength [nm]'
  oplot,wl_gc,interpol(Lwn(pos),wl(pos),wl_gc,/spline),psym=-symcat(7),COLOR=2

  plot,wl(pos),Lwn(pos),Title='Linear',psym=-1,xtit='wavelength [nm]'
  oplot,wl_gc,interpol(Lwn(pos),wl(pos),wl_gc),psym=-symcat(7),COLOR=2
 endelse

 DEVICE, /CLOSE
 SET_PLOT, 'win'
 SPAWN,'gsview32 '+psFileName
endif


if(keyword_set(interpol_gc)) then return,Lwn_gc else return,data
END