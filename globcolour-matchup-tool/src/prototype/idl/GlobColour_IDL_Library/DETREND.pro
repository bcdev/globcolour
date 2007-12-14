FUNCTION detrend, Y, X, RANGE=range, REMOVE_MEAN=rmean, STANDARDISE=standardise, DIAG=diag

;+
;NAME:
; detrend

;PURPOSE:
;	Remove the "linear trend" from a time-series data and standardise the detrend data

;SYNTAX:
;	result = DETREND( Y [,X] [,range=[min,max]] [,REMOVE_MEAN=variable] [,/STANDARDISE] [,/DIAG])

;INPUTS:
;	A 1D time-series aray of any type except string, Y
;	Corresponding time data, X (optional)

;OUTPUTS:
;	Detrend time-series array of same length as Y

;KEYWORDS:
;	range: Y data within range will be considered for detrending, out-of-bound data will be ignored.
;	remove_mean: a named variable to contain the Original data - mean(Original data)
;	standardise: if present the detrend series mean will be subtracted from the detrend series and then divided by the stddev of detrend series
;							 standardised data will have 0 mean unit variance.
; diag: plots actual and detrend series for diagnosis

;CATEGORY:
;	Statistics, Time-series analysis

;EXAMPLE:
;	IDL> Y = randomn(seed,50)+findgen(50)+1
;	IDL> result = detrend(Y ,/stand ,/diag)
; IDL> print, mean(result,/NaN), stddev(result,NaN)
;			-3.98221e-009      1.00000

;	$Id: detrend.pro,v 1.0 29/01/2007 19:25:13 yaswant Exp $
; detrend.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;-


;parse arguments
	if ( n_params() lt 1 ) then stop,'syntax : '+string(10b)+'result = detrend( Y [,X] [,range=[min,max]] [,/remove_mean] [,STANDARDISED=variable] [,/DIAG])'

;diagnose
	d=0b
	if ( keyword_set(diag) ) then begin
		d=1b
		!p.multi=[0,2,2]
	endif


;intialise the output array with NaNs
  result =( rmean = make_array( n_elements(Y), value=!values.f_nan ) )


;generate serial index if x is not provided
  if ( n_params() lt 2 ) then X = dindgen( n_elements(Y) )+1


;consider data within the prescribed range, if given
  if ( keyword_set(range) ) then begin
    p = where( (Y le range[0]) or (Y ge range[1]), np )
    if (np gt 0) then Y(p) = !values.f_nan
  endif


;check for sufficient number of finite values in the data
  wh = where( finite(Y), nwh, complement=undefine, ncomplement=nundefine )
  if ( nwh gt 1 ) then vy = Y(wh) else stop,'Insufficient number of finite elements in the series'

;remove mean from the original data
	rmean(wh) = vy - mean(vy)



;step.1 estimate the linear fit and subtract from the actual series
  fit = linfit(X(wh), vy, yfit=vyfit, /double )
  result(wh) = vy - vyfit
;plot origina, original-mean and detrend data data
	if (d) then begin
		plot,X(wh),vy,title='Original data (restrictions applied)'
		oplot,X(wh),vyfit
		plot,X(wh),rmean(wh),title='Original - Mean'
		plot,X(wh),result(wh),title='Original - Trend'
	endif



;step.2 Standardise the detrend data (0 mean unit variance)
  if ( keyword_set(standardise) ) then begin
  	result(wh) = ( result(wh) - mean( result(wh)) ) / stddev( result(wh) )
;plot standardise detrend data
		if (d) then $
			plot,X(wh),result(wh),title='Standardised Detrend'
	endif


  return, result

END