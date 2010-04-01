FUNCTION MOREL_CHL_KD_CASE1, CHL=chl, KD490=kd490

;+
; NAME:
;       MOREL_CHL_KD_CASE1
; VERSION
;       1.0
; PURPOSE:
;       FUNCTION TO CALCULATE KD490 FROM CHLOROPHYLL-A AND VICE-VERSA IN CASE-I WATERS FOLLOWING
;       MOREL CONVENTION; Kd490=Kw490 + Chi490*Chl^e490
; Usage:
;       result=MOREL_CHL_KD_CASE1([chl=value] | [kd490=value])
; Keywords:
;  chl = Chlorophyll concentration in Case-1 water
;  kd490 = Diffuse attenuation coefficeint in Case-1 water
;
; INPUT:
;       chl: a scalar or vector or array returns a scalar or vector or array of kd490
;     kd490: a scalar or vector or array returns a scalar or vector or array of chl
; OUTPUT:
;       depending on keywords:1. if set date then returns outputs=intarr(2) where outputs[0]=SDY, outputs[1]=YEAR
;                  2. if set sday then returns outputs=intarr(3) where outputs[0]=DAY, outputs[2]=MONTH, outputs[2]=YEAR
; Example:
;   IDL> chl=MOREL_CHL_KD_CASE1(k = [0.09,0.23])
;   IDL> print,chl
;     0.91806026       4.4847025
;   IDL> kd490=MOREL_CHL_KD_CASE1(c = [0.918,4.485])
;   IDL> print,kd490
;      0.089996761      0.23000953

; CATEGORY:
;       Ovean colour, Empirical estimation


; Written by:
; Yaswant Pradhan
; University of Plymouth
; Yaswant.Pradhan@plymouth.ac.uk
; Last Modification: 28-02-07 (YP: Original)

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if ~(keyword_set (chl) or keyword_set (kd490)) then $
print,"USAGE:"+string(10b)+"result=MOREL_CHL_KD_CASE1([chl=value] | [kd490=value])"

;CONSTANTS, [New X490 and exp490 after merging NOMAD, see André's email on 28-02-2007]
kw490=0.0166D
X490=0.077746D  ;0.08349D=OLD VALUE BEFORE FEB 2007
exp490=0.672846D ;0.63303D=OLD VALUE BEFORE FEB 2007


if(keyword_set(chl)) then begin

    return,(kw490 + X490*chl^(exp490))

endif else if(keyword_set(kd490)) then begin

    return,((kd490-kw490)/X490)^(1./exp490) ;return,DOUBLE(exp(alog((kd490-kw490)/X490)/exp490))

endif

END