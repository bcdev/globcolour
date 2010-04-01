FUNCTION FILTERED_AVERAGE, Array, SD=stdev, CV=coeff_var, NAN=nan, VERB=verb
;+
;NAME:
;	FILTERED_AVERAGE

;PURPOSE:
;	Estimates the average value of an array with specific Sigma and coefficient of variation threshold limits

;SYNTAX:
; Result= FILTERED_AVERAGE(Array [,SD=value][,CV=value][,/NAN][,/VERB])

;Inputs:
; Array: Vector/Array (max 2D) from which Search to be performed


;OUTPUTS:
; A 4-element vecotr containing [Mean, Median, Stdev, N] of the filtered array

;KEYWORDS:
; SD: The cutoff threshold standard deviation, e.g., +/-2sigma [default is 1.5]
; CV: accepted percent of variation [default is 0.15 or 15%]; Note: CV is computeds as (stdev/median) not (stdev/mean)
; NAN: ignore NaNs
; VERB: Verbose

;EXAMPLE:
; IDL> x=findgen(11)
; IDL> print,FILTERED_AVERAGE(x)
; 		Fail to meet CV criterion
;      NaN          NaN          NaN          NaN

; IDL> print,FILTERED_AVERAGE(x, CV=0.6)
;      5.00000      5.00000      2.73861      9.00000

;CATEGORY:
;	Statistical analysis

;	$Id: FILTERED_AVERAGE.pro,v 1.0 01/05/2006 19:25:13 yaswant Exp $
; FILTERED_AVERAGE.pro	Yaswant Pradhan	University of Plymouth
;	Last modification: Mar 07 (yp)
;-


;++Parse Error
  if(n_params() LT 1) then begin
    print,'ERROR! (comp_OBPG_avg) Insufficient number of arguments'
    print,'SYNTAX: result = comp_OBPG_avg ( Array [SD=value] [,CV=value] )'
    RETALL
  endif

;++Intialise Parameters
  if(~KEYWORD_SET(stdev)) then stdev=1.5
  if(~KEYWORD_SET(coeff_var)) then coeff_var=0.15
  if(KEYWORD_SET(verb)) then verb=1b else verb=0b
  if(KEYWORD_SET(nan)) then Array=Array(where(finite(Array)))


  ArrayAvg=mean(Array)
  ArrayMedian=median(Array)
  ;ArrayRMS=sqrt(mean(Array^2.))
  ArrayVAR=stddev(Array)


  threshold=[ArrayMedian - stdev*ArrayVAR, ArrayMedian + stdev*ArrayVAR]


  pos=where(Array GE threshold[0] AND Array LE threshold[1], cnt)


  if(verb) then begin
    print,'INPUT DATA ARRAY: ',  Array
    print,'INPUT DATA MEAN : ',  ArrayAvg
    print,'INPUT DATA MEDIAN : ',ArrayMedian
    print,'INPUT DATA STDEV : ', ArrayVAR
    print,'FILTER THRESHOLD : ', threshold
    print,'FILTERED POSITION: ', pos
  endif


  if(cnt GT 1) then begin

    med_cv = stddev(Array(pos)) / median(Array(pos),/EVEN)
    if(verb) then print,'FILTERED DATA CV: ', med_cv

    if(med_cv LE coeff_var) $
        then RETURN, [mean(Array(pos)), median(Array(pos)), stddev(Array(pos)), cnt] $
        else begin
            if(verb) then print,'[FILTERED_AVERAGE] Fail to meet CV criterion'
            RETURN, MAKE_ARRAY(4,Value=!Values.F_NaN)
        endelse

  endif else begin
    print,'[FILTERED_AVERAGE] Fail to meet > 2 point criterion'
    RETURN, MAKE_ARRAY(4,Value=!Values.F_NaN)
  endelse

END