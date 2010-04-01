FUNCTION YP_SIGTEST, r, N

;+
; NAME:
;       YP_SIGTEST
; VERSION
;       1.0
; PURPOSE:
;    Significance Test of correlation for a sample size = N
;    N:    Number of observations
;    r:    Correlation coefficient
;    Pr:   Probaility that random noise could produce the result (correlation) with N samples
;       Pr=ERFC(r*sqrt(N/2))
;    ERFC: Complementary Error Function
;    rsig: At which we have 100*(1-limit) chance that random data would produce this result (r)
;       rsig=INVERF(limit)*sqrt(2/N)
;
; Interpretation:
;       Any "r" value greater than "rsig" are significant at "limit*100" level
;
; INPUT:
;       r
;       N
;
; OUTPUT:
;       2-element array [significance level, probability]
;
; Example:
;   IDL> result = YP_SIGTEST(0.67, 23)
;   IDL> print, result
;     99.000000    0.0013126156
;
; CATEGORY:
;       Statistical Analysis
;
;
;
; Written by:
; Yaswant Pradhan
; University of Plymouth
; Yaswant.Pradhan@plymouth.ac.uk
; Last Modification: 28-02-06 (YP: Original)

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


if ( n_params() LT 2 ) then RETURN,[0.,0.]
r = DOUBLE(r)
N = DOUBLE(N)
Pr = 0D
rsig = 0D
i = 0.99

if (r gt 1.0 or r lt -1.0) then begin
    err = widget_message('r value should be between -1.0 and 1.0. Input r, N again!',/Error)
endif

r = abs(r)
Pr = ERFC( r*sqrt(N/2.) )

while ( inverf(i)*sqrt(2./N) gt r ) do begin
    i = i - 0.01
    rsig = inverf(i)*sqrt(2./N)
endwhile

print,'Correlation Significance Test Result:'
print,'====================================='
print,'Correlation coefficient: ',r
print,'Number of samples: ',N
print,'Confidence Limit: '+string(9b)+string(i*100,format='(i2.2)')+'%'
print,'Probability (Pr): ',Pr
print,'====================================='

RETURN,[i*100.,Pr]
END

