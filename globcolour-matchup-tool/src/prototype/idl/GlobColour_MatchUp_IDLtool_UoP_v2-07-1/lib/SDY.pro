FUNCTION SDY,dd,mm,yyyy
;+
;Name:  sdy
;Task:  Calculate Serial Day of Year from date, month, year
;Input: 3 (scalar integers)
;Out:   Integer
;Usage: Result=SDY(dd,mm,yyyy)
;Caution: Program can not handle incorrect input of day, eg Feb 31 or Apr 31
;Author: Yaswant Pradhan, University of Plymouth, May 06
;-

;++Parse Error
if (n_params() LT 3) then begin
    print,'SDY() ERROR 1. Insufficient number of arguments'
    print,'SYNTAX: result = SDY(dd,mm,yyyy)'
    retall
endif

if ((dd LT 1) OR (mm LT 1) OR (yyyy LT 0) OR (dd GT 31) OR (mm GT 12)) then begin
    print,'SDY() ERROR 2. Invalid (day, month, year)'
    print,'SYNTAX: result = SDY(dd,mm,yyyy)'
    retall
endif
;--Parse Error

days=[31,28,31,30,31,30,31,31,30,31,30,31]
mm2=mm-2
leap=0
out=0

if (((yyyy MOD 4) EQ 0) AND (((yyyy MOD 100) NE 0) OR (yyyy MOD 400) EQ 0)) then leap=1
for i=0,mm2 do begin
    out=out+days(i)
    if ((i EQ 1) AND (leap EQ 1)) then out=out+1
endfor
    out=out+dd
    return,out
END