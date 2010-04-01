FUNCTION PPOINTS, N

;+
;NAME:
; PPOINTS

;PURPOSE:
; Returns an array of N probability points between 0 and 1, exclusive

;SYNTAX:
; Result = PPOINTS (N)

;INPUTS:
; N: number of desired points, must be > 1

;OUTPUTS:
; An array of N probability points

;KEYWORDS:
; None

;EXAMPLE:
;IDL> print, ppoints(5)
;			0.10000000      0.30000000      0.49999999      0.69999998      0.89999998


;CATEGORY:
;	Statistics & Probability

;	$Id: PPOINTS.pro,v 1.0 29/05/2007 19:25:13 yaswant Exp $
; PPOINTS.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;-

;parse error
	if (n_params() ne 1) then begin
		print,'Syntax: result = ppoints(N)'
		retall
	endif
	if (N lt 2) then begin
		print,'Error! N must be greater than 1'
		retall
	endif


;set a [0,1] exclusive bound
	bound = double([0.5/N, 1.-(0.5/N)])

;linear increment
	inc = (bound[1]-bound[0])/(N-1)


	result = dblarr(N)
	result[0] = bound[0]
	for i=1,N-1 do result[i] = result[i-1]+inc

	return,result

END