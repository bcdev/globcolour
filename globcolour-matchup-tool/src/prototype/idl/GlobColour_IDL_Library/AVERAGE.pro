FUNCTION average, array, dim, _extra=_extra
;+
;NAME:
;	average

;PURPOSE:
;	Returns the average value of an array in a sepcified dimention
; (see all arguments as in 'total')

;SYNTAX:
;   result = average(array [,dim][,/DOUBLE][,/NaN])

;INPUTS:
;   array ->    array to be averaged, any type except string
;   dim   ->    dimension over which the average is to be performed; average=mean when dim=0 (see 'total' documentation)
;
;KEYWORDS:
;   _extra      all keywords passed to 'total'
;

;	$Id: average.pro,v 1.0 29/05/2005 19:25:13 yaswant Exp $
; average.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;-

	if (n_params() lt 1) then begin
		print,'Syntax Error: result = average(array [,dim][,/DOUBLE][,/NaN])'
		retall
	endif

  if ( n_elements(dim) eq 0 ) then dim = 0

  return, total(array, dim, _extra=_extra) / (total(finite(array), dim)>1)

END

