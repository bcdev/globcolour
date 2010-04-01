PRO NOMAD_DDS_match

file=DIALOG_PICKFILE(FILTER='*',/READ,GET_PATH=path,/MULTIPLE_FILES)
CD,path
s=size(file)
n_files=s[1]

print,'Please wait while Scanning through files...'
wait,1
t1=systime(/seconds)
;-----------------------------------------------
;DEFINE GlobCOLOURDDS BOXES [wlon,elon,slat,nlat]

dds01=[-157.7,-156.7,20.3,21.3] ;-157.2, 20.8 (MOBY)
dds02=[6.6,7.6,42.8,43.8]       ;7.1, 43.3 (BOUSSOLE)
dds03=[12.0,13.0,44.5,45.5]     ;12.5, 45.0 (Venice Tower)
dds04=[-65.0,-64.0,31.5,32.5]   ;-64.5, 32 (BATS)
dds05=[-65.5,-64.5,10.5,11.5]   ;-65.0, 11.0 (CARIACO)
dds06=[-125.5,-124.5,34.5,35.5] ;-125.0, 35.0 (CALCOFI)
dds07=[-70.4,-69.4,42.5,43.5]   ;-69.9, 43.0 (Gulf of Maine)
dds08=[-74.5,-73.5,38.5,39.5 ]  ;-74.0, 39.0 (LEO-15)
dds09=[16.9,17.9,-33.0,-32.0]       ;17.4, -32.5 (Benguela)
dds10=[7.0,8.0,53.5,54.5]       ;7.5, 54 (Helgoland)
dds11=[-3.5,-2.5,49.5,50.5]     ;-3.0, 50.0 (Channel)
dds12=[18.5,19.5,54.7,55.7]     ;19.0, 55.2 (Sopot)
dds13=[-65.5,-64.5,-65.5,-64.5] ;-65.0, -65.0 (Palmer)
dds14=[-118.5,-117.5,-23.5,-22.5];-118.0, -23.0 (Rapa Nui)
dds15=[-73.5,-72.5,-37.0,-36.0] ;-73.0, -36.5 (Concepcion)
dds16=[117.5,118.5,22.0,23.0]   ;118, 22.5 (Taiwan-Str)
dds17=[121.5,122.5,34.5,35.5]   ;122.0, 35.0 (Yellow Sea)
;-----------------------------------------------

;-----------------------------------------------

;-----------------------------------------------
;FIRST LOOP SCAN THROUGH EVERY FILE

field_array=strarr(n_files)
for f=0L,n_files-1 do begin
    templ=ASCII_TEMPLATE(file(f))
    dats=READ_ASCII(file(f),TEMPLATE=templ,DATA_START=1,HEADER=header)
    field_name=strsplit(header,',',/extract)


    NAMES = TAG_NAMES(dats)
;    if n_tags(dats) gt 99 then zzz=dats.field001
 ;   if (n_tags(dats) gt 9 and n_tags(dats) lt 100) then zzz=dats.field01
  ;  if n_tags(dats) lt 10 then zzz=dats.field1

;Loop for each field.
    FOR I = 0, N_TAGS(dats) - 1 DO BEGIN
;Define variable A of same type and structure as the i-th field.
        x = dats.(I)
    ENDFOR
    lat=float(x(6,*)) & lon=float(x(7,*))
    dds=strarr(n_elements(lat))
    dds=reform(dds,1,n_elements(lat))
    data=[dds,x]



;====


;--------------
    openw,10,'NOMAD_DDS.csv'
    printf,10,string("DDS,")+header
       pos=where(lon ge dds01(0) and lon le dds01(1) and lat ge dds01(2) and lat le dds01(3),count)
       print,'DDS01, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS01'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds02(0) and lon le dds02(1) and lat ge dds02(2) and lat le dds02(3), count)
       print,'DDS02, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS02'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds03(0) and lon le dds03(1) and lat ge dds03(2) and lat le dds03(3), count)
       print,'DDS03, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS03'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds04(0) and lon le dds04(1) and lat ge dds04(2) and lat le dds04(3), count)
       print,'DDS04, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS04'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds05(0) and lon le dds05(1) and lat ge dds05(2) and lat le dds05(3), count)
       print,'DDS05, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS05'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds06(0) and lon le dds06(1) and lat ge dds06(2) and lat le dds06(3), count)
       print,'DDS06, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS06'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds07(0) and lon le dds07(1) and lat ge dds07(2) and lat le dds07(3), count)
       print,'DDS07, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS07'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds08(0) and lon le dds08(1) and lat ge dds08(2) and lat le dds08(3), count)
       print,'DDS08, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS08'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds09(0) and lon le dds09(1) and lat ge dds09(2) and lat le dds09(3), count)
       print,'DDS09, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS09'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds10(0) and lon le dds10(1) and lat ge dds10(2) and lat le dds10(3), count)
       print,'DDS10, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS10'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds11(0) and lon le dds11(1) and lat ge dds11(2) and lat le dds11(3), count)
       print,'DDS11, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS11'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds12(0) and lon le dds12(1) and lat ge dds12(2) and lat le dds12(3), count)
       print,'DDS12, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS12'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds13(0) and lon le dds13(1) and lat ge dds13(2) and lat le dds13(3), count)
       print,'DDS13, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS13'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds14(0) and lon le dds14(1) and lat ge dds14(2) and lat le dds14(3), count)
       print,'DDS14, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS14'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds15(0) and lon le dds15(1) and lat ge dds15(2) and lat le dds15(3), count)
       print,'DDS15, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS15'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds16(0) and lon le dds16(1) and lat ge dds16(2) and lat le dds16(3), count)
       print,'DDS16, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS16'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

       pos=where(lon ge dds17(0) and lon le dds17(1) and lat ge dds17(2) and lat le dds17(3), count)
       print,'DDS17, N : ', count
       if count ne 0 then begin
        data(0,pos)='DDS17'
        printf,10,data(*,pos),format='(158(A,","))'
       endif

print,'Compilation File: "NOMAD_DDS.csv" was Successful.'
endfor

close,10

t2=systime(/seconds)
print,string(10b),'========================='
print,string(10b),'Files searched: ',n_files
print,'Elapsed Time (in seconds): ',t2-t1

;-----------------------------------------------
END