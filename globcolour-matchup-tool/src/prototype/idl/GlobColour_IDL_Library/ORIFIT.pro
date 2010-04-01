FUNCTION ORIFIT,XARR,YARR, $
    YFIT = yfit, VERBOSE=verbose

;+
;NAME:
; ORIFIT

;PURPOSE:
; Returns linear regression results through origin.

;SYNTAX:
; Result = ORIFIT (X, Y [,YFIT=variable][/VERB] )

;INPUTS:
; XARR:	Array of independent variable [1D]
;	YARR:	Array of dependent variable [1D]

;OUTPUTS:
; 4-element array containing the fit result [intercept, slope, r2, rms]
;	Set YFIT to a named variable to store the fit data

;KEYWORDS:
; YFIT: A named variable to store the fit data
; VERB: Verbose


;	$Id: ORIFIT.pro,v 1.0 13/10/2006 19:25:13 yaswant Exp $
; ORIFIT.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;-

 if (n_params() ne 2) then $
        MESSAGE,"!ERROR-0: incorrect number of arguments"+string(10b)+" USAGE: result = YP_ORIFIT(X,Y)"
 if (n_elements(XARR) ne n_elements(YARR)) then $
        MESSAGE,'!ERROR-1 > X and Y must be vectors of equal length.'
 if (n_elements(XARR) LT 2.) then $
        MESSAGE,'!ERROR-2 > X and Y must be arrays of at least 2 elements'

 nPts = n_elements(XARR)
 intercept=0.
 slope = total(YARR * XARR)/total(XARR * XARR)
 est = slope*XARR + intercept           ;Predicted Y
 SStot = total((YARR-mean(YARR))^2.)    ;Sum square
 SSreg = total((YARR-est)^2.)           ;Regression Sum square
 rsq = (SStot-SSreg)/SStot              ;Coefficient of determination
 rms = sqrt(total((YARR-est)^2.)/nPts)  ;RMS of estimation

 yfit=est

 if(KEYWORD_SET(verbose)) then begin
  print,"N : ",nPts
  print,"Slope : ",slope
  print,"Intercept : ",intercept
  print,"r-squared : ",rsq
  print,"RMSE : ",rms
 endif
return,[intercept,slope,rsq,rms]
END