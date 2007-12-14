FUNCTION FLTSCL, Array, HIGH=high, LOW=low
;+
; NAME
;     FLTSCL
; VERSION
;     1.0
; PURPOSE
;     The FLTSCL function scales all values of Array that lie in the range (Min <= x <= Max) into the range (low <= x <= High).
; Syntax
;     Result = FLTSCL( Array [, High=high] [, LOW=low] )

; KEYWORDS:
;     HIGH - Set this keyword to the maximum value of the output scaled Array, default is 1
;     LOW - Set this keyword to the maximum value of the output scaled Array, default is 0
; CATEGORY:
;       Data scaling
; Written by:
; Yaswant Pradhan
; University of Plymouth
; Yaswant.Pradhan@plymouth.ac.uk
; Last Modification: 07-03-07 (YP: Original)

; LICENSE
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;-

if(n_params() LT 1) then begin
    PRINT,'FLTSCL() Error! Insufficient Arguments'
    PRINT,'FLTSCL() Usage: result = FLTSCL( Array, [, High=high] [, LOW=low] )'
    RETALL
endif
if(~KEYWORD_SET(low)) then low=0.
if(~KEYWORD_SET(high)) then high=1.


    range = max(Array,/nan) - min(Array,/nan) ;input data range
    x = (Array - min(Array,/nan)) / range ;scale input data between 0. and 1.
    range2 = high - low          ;user defined range, default is 1.-0.
    x2 = x*range2             ;multiply the user defined range to the 0.-1. scaled data

  RETURN, x2 + low       ;add the user low

END