;+
; FUNCTION
;    alogbase
; USAGE:
;     result=alogbase(base,varaible)
; EXAMPLE:
;     y=alogbase(2,10) calculates log2(10)

; yaswant.pradhan@plymouth.ac.uk 2004.

function alogbase, base, x
    if (n_params() ne 2) then begin
        err_msg=" ERROR: incorrect number of arguments"+string(10b)+" USAGE: result = alogbase(base, variable)"
        RETURN,err_msg
    endif
        return, double(alog(x)/alog(base))
end

