FUNCTION average, array, dim, _extra=_extra
;+
; Calculates the average value of an array in a sepcified dimention
; (see all arguments as in 'total')
;
; Arguments:
;   array ->    array to be averaged, any type except string
;   dim   ->    dimension over which to average (see 'total' documentation)
;
; Keywords:
;   _extra      all keywords passed to 'total'
;
; Usage:
;   result=average(array,dim,[/DOUBLE], [/NaN])
;-

    IF n_elements(dim) EQ 0 THEN dim = 0
    RETURN, total(array, dim, _extra=_extra) / (total(finite(array), dim)>1)

END


