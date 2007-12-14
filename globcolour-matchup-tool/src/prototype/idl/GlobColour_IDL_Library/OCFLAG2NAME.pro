FUNCTION OCFlag2Name, value, GET_FLAG_TABLE=gft

;+
;NAME:
; OCFlag2Name

;PURPOSE:
; Converts NASA Oceancolor (http://oceancolor.gsfc.nasa.gov/) 32-bit Flag values to Names

;SYNTAX:
;	Result = OCFlag2Name( Value [,GET_FLAG_TABLE=variable])

;INPUTS:
; A 32-bit 4-byte integer value, e.g. 268472370

;OUTPUT:
; A string Array containg the Oceancolor defined Flag Names

;KEYWORDS:
;      GET_FLAG_TABLE -> a named variable to store the Oceancolor Flag LUT

;EXAMPLE:
;	IDL> print, OCFlag2Name(268472370)
;			LAND HILT HISATZEN HISOLZEN CHLFAIL SSTFAIL


;	$Id: OCFlag2Name.pro,v 1.2 08/05/2006 10:12:43 yaswant Exp $
; OCFlag2Name.pro	Yaswant Pradhan	University of Plymouth
; Feedback: Yaswant.Pradhan@plymouth.ac.uk;
;-




;Oceancolor defined Flags
	flag_names = ['ATMFAIL','LAND','BADANC','HIGLINT','HILT','HISATZEN','COASTZ','NEGLW', $
								'STRAYLIGHT','CLDICE','COCCOLITH','TURBIDW','HISOLZEN','HITAU','LOWLW','CHLFAIL',$
								'NAVWARN','ABSAER','TRICHO','MAXAERITER','MODGLINT','CHLWARN','ATMWARN','DARKPIXEL', $
    		 			  'SEAICE','NAVFAIL','FILTER','SSTWARN','SSTFAIL','HIPOL','spare','OCEAN']

;Number of bits
	nbits = n_elements( flag_names ) ;nbits=32

;GET_FLAG_TABLE
	gft = transpose( [[string(indgen(nbits)+1)], [flag_names]] )

;Possible Min, Max range for signed integer
	x = round(value, /L64)
	hi = round(2D^nbits, /L64)

;Error handing
	if ( (x ge hi) or (x lt -hi) ) then begin
  	print,'Fail: converting flags: ',x, nbits
    out = make_array(nbits, /FLOAT, value=-1) ;error indicator
    return,out
	endif


	out = make_array(nbits,/FLOAT, value=0)
	for i=nbits-1,0,-1 do begin
    test = round(2D^i, /L64)
    if (x ge test) then begin
       out[i] = 1
       x = x-test
    endif
	endfor

	wh = where(out eq 1., cnt)

	if (cnt gt 0) then return,flag_names(wh) else return,''

END