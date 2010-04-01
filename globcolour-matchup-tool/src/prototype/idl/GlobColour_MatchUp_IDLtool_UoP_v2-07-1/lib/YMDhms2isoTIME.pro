FUNCTION YMDhms2isoTIME, Year, Month, Day, Hour, Minute, Second, $
       DOY=doy, VERB=verb
;+
;Returns ISO19115 compliant Time in YYYYMMDDThhmmssZ format
;INPUTS:
;   Year, Month, Day, Hour, Minute, Second (All data as scalar or vector)
;Yaswant Pradhan, 2 March 2007
;
;KEYWORD: DOY (day-of-year) will return the Time as YYYDDDThhmmssZ
;-


L=n_elements(Year)
isoTime=strarr(L)

if(N_PARAMS() EQ 0) then begin
    PRINT,'YMDhms2isoTIME() Warning! Parameter aruments were not provided. Returning Current System Time
    PRINT,'YMDhms2isoTIME() Usage: result = YMDhms2isoTIME(Year,Month,Day,Hour,Minute,Second,[/DOY])'
    CALDAT,systime(/Julian),Month, Day, Year, Hour, Minute, Second
endif else if(N_PARAMS() LT 3) then begin
    PRINT,'YMDhms2isoTIME() Usage: result = YMDhms2isoTIME(Year,Month,Day,Hour,Minute,Second,[/DOY])'
    retall
endif else if(N_PARAMS() EQ 3) then begin
    if(keyword_set(verb)) then PRINT,'YMDhms2isoTIME() Warning! Hour,Minute,Second are set to 0.
    Hour=(Minute=(Second=intarr(L)))
endif else if(N_PARAMS() EQ 4) then begin
    if(keyword_set(verb)) then PRINT,'YMDhms2isoTIME() Warning! Minute, Second are set to 0.
    Minute=(Second=intarr(L))
endif else if(N_PARAMS() EQ 5) then begin
    if(keyword_set(verb)) then PRINT,'YMDhms2isoTIME() Warning! Second set to 0.
    Second=intarr(L)
endif

for i=0,L-1 do begin
    if(KEYWORD_SET(doy)) then $
    isoTime(i)=string(Year(i),format='(I4.4)')+string(SDY(Day(i),Month(i),Year(i)),format='(I3.3)')+ $
         'T'+string(Hour(i),format='(I2.2)')+string(Minute(i),format='(I2.2)')+$
         string(Second(i),format='(I2.2)')+'Z' else $
    isoTime(i)=string(Year(i),format='(I4.4)')+string(Month(i),format='(I2.2)')+ $
         string(Day(i),format='(I2.2)')+'T'+string(Hour(i),format='(I2.2)')+string(Minute(i),format='(I2.2)')+$
         string(Second(i),format='(I2.2)')+'Z'
endfor
RETURN,isoTime
END