PRO combine_SeaBASS_DDS
;+
; PURPOSE:
;   1.Search all SeaBASS formatted data files
;   2.Filter files covering GlobCOLOUR DDS sites
;   3.Combine files with unique fields;
;-

print,'Please be patience while Scanning through files...'
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
;DEFINE FILE SEARCH PATTERN

;str='*.*'
;search_file=FILE_SEARCH(str,/FULLY_QUALIFY_PATH)
;Recursively search sub-directories
;depth=0
;while not(n_elements(search_file) gt 2) do begin
;    depth=depth+1
;    str='*/'+str
;    search_file=FILE_SEARCH(str,/FULLY_QUALIFY_PATH)
;endwhile

;print,search_file

close,/all
FILE_DELETE,'FileList.csv',/QUIET
SPAWN, 'dir /b/s/aa',count=n_files, search_file ;,/HIDE

CD,CURRENT=curr_dir
root_len=strlen(curr_dir)

;openw,10,'FileList.csv'
;printf,10,'DDS_No,StartYear,StartMonth,StartDay,StartHour(GMT),StartMinute(GMT),C_Longitude,C_Latitude,Data_Type,File,Investigators,Fields'
;-----------------------------------------------
match=intarr(17)
dds='NO_MATCH'
;-----------------------------------------------
;FIRST LOOP SCAN THROUGH EVERY FILE

field_array=strarr(n_files)
for f=0L,n_files-1 do begin
    s=size(search_file(f),/dim)
        max_lines=n_lines(search_file(f)) ;useful function n_lines counts no of lines in a file
        header=strarr(max_lines)
        openr,1,search_file(f)
        ;print,'Scanning through file: ',f+1
        readf,1,header
        close,1

;FIELDS
    i=0
    while not(strcmp(strmid(header(i),1,6),'fields')) do i=i+1
    fields=strmid(header(i),8,5000)
    field_array(f)=fields
endfor

;help,n_files,field_array
uniq_field=field_array[UNIQ(field_array,SORT(field_array))]
n_uf=size(uniq_field,/n_elements)

;====


;SECOND LOOP SCAN THROUGH EVERY FILE AND MATCH ACCORDING TO THE NUMBER OF FIELDS
for uf=0L,n_uf-1 do begin

    com_file_name='ComboFile'+strcompress(string(uf+1,format='(i3.3)'),/remove_all)+'.dds'
    print,com_file_name
    openw,90,com_file_name
    printf,90,'ID,DDS,Experiment,Filename,West,East,South,North,StYear,StMonth,StDay,StHour,StMinute,MDepth,',uniq_field(uf),format='(10000A)'

    file_num=0
    for f=0L,n_files-1 do begin
        s=size(search_file(f),/dim)
        max_lines=n_lines(search_file(f)) ;useful function n_lines counts no of lines in a file
        header=strarr(max_lines)
        openr,1,search_file(f)
        ;print,'Scanning through file: ',f+1
        readf,1,header
        close,1
        file_name=strmid(search_file(f),root_len+1,200)

;FIELDS
    i=0
    while not(strcmp(strmid(header(i),1,6),'fields')) do i=i+1
    fields=strmid(header(i),8,5000)

;ADD BY FIELD TYPES
    if (strcmp(fields,uniq_field(uf))) then begin


;EXPERIMENT
        i=0
        while not(strcmp(strmid(header(i),1,10),'experiment')) do i=i+1
        experiment=strmid(header(i),12,50)


;POSITION
        position=fltarr(4)
;NORTH
        i=0
        while not(strcmp(strmid(header(i),1,14),'north_latitude')) do i=i+1
        position(3)=float(strmid(header(i),16,7))


;SOUTH
        i=0
        while not(strcmp(strmid(header(i),1,14),'south_latitude')) do i=i+1
        position(2)=float(strmid(header(i),16,7))


;WEST
        i=0
        while not(strcmp(strmid(header(i),1,14),'west_longitude')) do i=i+1
        position(0)=float(strmid(header(i),16,7))


;EAST
        i=0
        while not(strcmp(strmid(header(i),1,14),'east_longitude')) do i=i+1
        position(1)=float(strmid(header(i),16,7))


;CENTRAL POSITION
        cposition=fltarr(2)
        cposition(0)=(position(0)+position(1))/2.    ;Central Longitude
        cposition(1)=(position(2)+position(3))/2.    ;Central Latitude

;START DATE
        date=intarr(3)
        i=0
        while not(strcmp(strmid(header(i),1,10),'start_date')) do i=i+1
        year=strmid(header(i),12,4)
        month=strmid(header(i),16,2)
        day=strmid(header(i),18,2)
        date=[year,month,day]

;START TIME(GMT)
        time=intarr(3)
        i=0
        while not(strcmp(strmid(header(i),1,10),'start_time')) do i=i+1
        hour=strmid(header(i),12,2)
        minute=strmid(header(i),15,2)
        second=strmid(header(i),18,2)
        time=[hour,minute,second]

;MEASUREMENT DEPTH
        i=0
        while not(strcmp(strmid(header(i),1,17),'measurement_depth')) do begin
            i=i+1
            if (i eq max_lines) then begin
                meas_dep='NA'
            break
            endif
            meas_dep=strmid(header(i),19,6)
        endwhile

;DATA TYPE
        i=0
        while not(strcmp(strmid(header(i),1,9),'data_type')) do i=i+1
        data_type=strmid(header(i),11,100)

;INVESTIGATORS
        i=0
        while not(strcmp(strmid(header(i),1,13),'investigators')) do i=i+1
        investigators=strmid(header(i),15,100)

;END HEADER
        i=0
        while not(strcmp(strmid(header(i),1,10),'end_header')) do i=i+1
        start_data=i+1

;DATA
        if (max_lines gt start_data) then data=header[start_data:max_lines-1] $
        else print,'Error! 0 Record',search_file(f)


dds='NO_MATCH'
;--------------
        if (((position(0) ge dds01(0) and position(0) le dds01(1)) or $
            (position(1) ge dds01(0) and position(1) le dds01(1))) and $
            ((position(2) ge dds01(2) and position(2) le dds01(3)) or $
            (position(3) ge dds01(2) and position(3) le dds01(3)))) then begin
            dds='DDS01'
            print,'DDS1: ',position
        ;printf,10,'DDS1,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(0)=match(0)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds02(0) and position(0) le dds02(1)) or $
            (position(1) ge dds02(0) and position(1) le dds02(1))) and $
            ((position(2) ge dds02(2) and position(2) le dds02(3)) or $
            (position(3) ge dds02(2) and position(3) le dds02(3)))) then begin
            dds='DDS02'
            print,'DDS2: ',position
       ;printf,10,'DDS2,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(1)=match(1)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds03(0) and position(0) le dds03(1)) or $
            (position(1) ge dds03(0) and position(1) le dds03(1))) and $
            ((position(2) ge dds03(2) and position(2) le dds03(3)) or $
            (position(3) ge dds03(2) and position(3) le dds03(3)))) then begin
            dds='DDS03'
            print,'DDS3: ',position
       ;printf,10,'DDS3,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(2)=match(2)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds04(0) and position(0) le dds04(1)) or $
            (position(1) ge dds04(0) and position(1) le dds04(1))) and $
            ((position(2) ge dds04(2) and position(2) le dds04(3)) or $
            (position(3) ge dds04(2) and position(3) le dds04(3)))) then begin
            dds='DDS04'
            print,'DDS4: ',position
       ;printf,10,'DDS4,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(3)=match(3)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds05(0) and position(0) le dds05(1)) or $
            (position(1) ge dds05(0) and position(1) le dds05(1))) and $
            ((position(2) ge dds05(2) and position(2) le dds05(3)) or $
            (position(3) ge dds05(2) and position(3) le dds05(3)))) then begin
            dds='DDS05'
            print,'DDS5: ',position
       ;printf,10,'DDS5,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(4)=match(4)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds06(0) and position(0) le dds06(1)) or $
            (position(1) ge dds06(0) and position(1) le dds06(1))) and $
            ((position(2) ge dds06(2) and position(2) le dds06(3)) or $
            (position(3) ge dds06(2) and position(3) le dds06(3)))) then begin
            dds='DDS06'
            print,'DDS6: ',position
       ;printf,10,'DDS6,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(5)=match(5)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds07(0) and position(0) le dds07(1)) or $
            (position(1) ge dds07(0) and position(1) le dds07(1))) and $
            ((position(2) ge dds07(2) and position(2) le dds07(3)) or $
            (position(3) ge dds07(2) and position(3) le dds07(3)))) then begin
            dds='DDS07'
            print,'DDS7: ',position
       ;printf,10,'DDS7,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(6)=match(6)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds08(0) and position(0) le dds08(1)) or $
            (position(1) ge dds08(0) and position(1) le dds08(1))) and $
            ((position(2) ge dds08(2) and position(2) le dds08(3)) or $
            (position(3) ge dds08(2) and position(3) le dds08(3)))) then begin
            dds='DDS08'
            print,'DDS8: ',position
       ;printf,10,'DDS8,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(7)=match(7)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds09(0) and position(0) le dds09(1)) or $
            (position(1) ge dds09(0) and position(1) le dds09(1))) and $
            ((position(2) ge dds09(2) and position(2) le dds09(3)) or $
            (position(3) ge dds09(2) and position(3) le dds09(3)))) then begin
            dds='DDS09'
            print,'DDS9: ',position
       ;printf,10,'DDS9,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(8)=match(8)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds10(0) and position(0) le dds10(1)) or $
            (position(1) ge dds10(0) and position(1) le dds10(1))) and $
            ((position(2) ge dds10(2) and position(2) le dds10(3)) or $
            (position(3) ge dds10(2) and position(3) le dds10(3)))) then begin
            dds='DDS10'
            print,'DDS10: ',position
       ;printf,10,'DDS10,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(9)=match(9)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds11(0) and position(0) le dds11(1)) or $
            (position(1) ge dds11(0) and position(1) le dds11(1))) and $
            ((position(2) ge dds11(2) and position(2) le dds11(3)) or $
            (position(3) ge dds11(2) and position(3) le dds11(3)))) then begin
            dds='DDS11'
            print,'DDS11: ',position
       ;printf,10,'DDS11,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(10)=match(10)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds12(0) and position(0) le dds12(1)) or $
            (position(1) ge dds12(0) and position(1) le dds12(1))) and $
            ((position(2) ge dds12(2) and position(2) le dds12(3)) or $
            (position(3) ge dds12(2) and position(3) le dds12(3)))) then begin
            dds='DDS12'
            print,'DDS12: ',position
       ;printf,10,'DDS12,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(11)=match(11)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds13(0) and position(0) le dds13(1)) or $
            (position(1) ge dds13(0) and position(1) le dds13(1))) and $
            ((position(2) ge dds13(2) and position(2) le dds13(3)) or $
            (position(3) ge dds13(2) and position(3) le dds13(3)))) then begin
            dds='DDS13'
            print,'DDS13: ',position
       ;printf,10,'DDS13,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(12)=match(12)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds14(0) and position(0) le dds14(1)) or $
            (position(1) ge dds14(0) and position(1) le dds14(1))) and $
            ((position(2) ge dds14(2) and position(2) le dds14(3)) or $
            (position(3) ge dds14(2) and position(3) le dds14(3)))) then begin
            dds='DDS14'
            print,'DDS14: ',position
       ;printf,10,'DDS14,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(13)=match(13)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds15(0) and position(0) le dds15(1)) or $
            (position(1) ge dds15(0) and position(1) le dds15(1))) and $
            ((position(2) ge dds15(2) and position(2) le dds15(3)) or $
            (position(3) ge dds15(2) and position(3) le dds15(3)))) then begin
            dds='DDS15'
            print,'DDS15: ',position
       ;printf,10,'DDS15,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(14)=match(14)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds16(0) and position(0) le dds16(1)) or $
            (position(1) ge dds16(0) and position(1) le dds16(1))) and $
            ((position(2) ge dds16(2) and position(2) le dds16(3)) or $
            (position(3) ge dds16(2) and position(3) le dds16(3)))) then begin
            dds='DDS16'
            print,'DDS16: ',position
       ;printf,10,'DDS16,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(15)=match(15)+1
            file_num=file_num+1
        endif

        if (((position(0) ge dds17(0) and position(0) le dds17(1)) or $
            (position(1) ge dds17(0) and position(1) le dds17(1))) and $
            ((position(2) ge dds17(2) and position(2) le dds17(3)) or $
            (position(3) ge dds17(2) and position(3) le dds17(3)))) then begin
            dds='DDS17'
            print,'DDS17: ',position
       ;printf,10,'DDS17,',date(0),',',date(1),',',date(2),',',time(0),',',time(1),',',cposition(0),',',cposition(1),',',data_type,',',search_file(f),',',investigators,',',fields,FORMAT='(850A)'
            match(16)=match(16)+1
            file_num=file_num+1
        endif

        if not (strcmp(dds,'NO_MATCH')) then begin
            for x=0,(max_lines-start_data)-1 do printf,90,f+1,dds,experiment,file_name,position(0),position(1),position(2),position(3),date,time(0),time(1),meas_dep,data(x),$
            FORMAT='((I,x),3(A,x),4(F,x),3(I,x),2(I,x),(A,x),10000A)';FORMAT='(3050A)'
        endif
    endif

;PARAMETERS
    ;i=0
    ;while not(strcmp(strmid(header(i),1,10),'parameters')) do i=i+1
    ;params=strmid(header(i),12,100)
    ;print,params

;START_DATE
    ;i=0
    ;while not(strcmp(strmid(header(i),1,10),'parameters')) do i=i+1
    ;print,strmid(header(i),12,100)
    ;endif
    endfor
    close,90
print,'Compilation File: ', uf+1, '  of',n_uf,'  Successful.'
endfor
;free_lun, lun


close,10

t2=systime(/seconds)
print,string(10b),'========================='
print,string(10b),'Files searched: ',n_files
print,'Files matched: ',fix(total(match))
print,string(10b),'DDS Match Summary: ',match
print,'Elapsed Time (in seconds): ',t2-t1

;-----------------------------------------------
END