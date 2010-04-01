FUNCTION YMDhms2isoTIME, Year, Month, Day, Hour, Minute, Second, $
       DOY=doy, VERB=verb
;+
;NAME:
;	YMDhms2isoTIME

;VERSION
; 1.0

;PURPOSE:
;	Returns ISO19115 compliant Date Time in YYYYMMDDThhmmssZ (see ISO 8601 date time) format

;SYNTAX:
;	Result = YMDHMS2ISOTIME( [Year] [,Month] [,Day] [,Hour] [,Minute] [,Second] [,/DOY] [,/VERB])

;INPUTS:
;	[Year], [Month], [Day], [Hour], [Minute], [Second] All variables can be passed as as scalars or vectors
;	If nothing is passed, the current system date time will be used as input

;OUTPUT:
; String output ISO 19115 compliant date and time

;KEYWORDS:
;	DOY: (day-of-year) will return the Time as YYYDDDThhmmssZ in stead of YYYYMMDDThhmmssZ
;	VERB: Verbose

;EXAMPLE:
;   IDL> print, YMDhms2isoTIME(1992, 12, 10, 0, 0, 0 ,/DOY )
;   			1992345T000000Z
;   IDL> print, YMDhms2isoTIME(1992, 12, 10, 0, 0, 0 )
;					19921210T000000Z
;   IDL> print, YMDhms2isoTIME()
;					20070530T183936Z
;   IDL> print, YMDhms2isoTIME(2000)
;					YMDhms2isoTIME() Usage: Result = YMDhms2isoTIME(Year,Month,Day,Hour,Minute,Second,[/DOY])
;		IDL> print,YMDHMS2ISOTIME(2000,10,10)
;				20001010T000000Z


;EXTERNAL ROUTINES/FUNCTIONS:
;	SDY()

;CATEGORY:
; Date and Time

;	$Id: YMDhms2isoTIME.pro,v 1.0 2/03/2007 16:05:10 yaswant Exp $
; YMDhms2isoTIME.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;-


	if(N_PARAMS() EQ 0) then begin
    PRINT,'YMDhms2isoTIME() Warning! Parameter aruments were not provided. Returning Current System Time
    PRINT,'YMDhms2isoTIME() Usage: result = YMDhms2isoTIME(Year,Month,Day,Hour,Minute,Second,[/DOY])'
    CALDAT,systime(/Julian),Month, Day, Year, Hour, Minute, Second
    L=n_elements(Year)
	endif else if(N_PARAMS() LT 3) then begin
    PRINT,'YMDhms2isoTIME() Usage: Result = YMDhms2isoTIME(Year,Month,Day,Hour,Minute,Second,[/DOY])'
    retall
	endif else if(N_PARAMS() EQ 3) then begin
		L=n_elements(Year)
    if(keyword_set(verb)) then PRINT,'YMDhms2isoTIME() Warning! Hour,Minute,Second are set to 0.
    Hour=(Minute=(Second=intarr(L)))
	endif else if(N_PARAMS() EQ 4) then begin
		L=n_elements(Year)
    if(keyword_set(verb)) then PRINT,'YMDhms2isoTIME() Warning! Minute, Second are set to 0.
    Minute=(Second=intarr(L))
	endif else if(N_PARAMS() EQ 5) then begin
		L=n_elements(Year)
    if(keyword_set(verb)) then PRINT,'YMDhms2isoTIME() Warning! Second set to 0.
    Second=intarr(L)
	endif else L=n_elements(Year)


	isoTime=strarr(L)

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