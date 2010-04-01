FUNCTION KM2DEG, KM, Longitude, Latitude, DEG
;+
; NAME
;     KM2DEG, DEG2KM
; VERSION
;     1.0
; PURPOSE
;     returns the equivalent of 1 (km/degree) in degrees/kilometers
; SYNTAX:
;     result=KM2DEG(Kilometers, Longitude, Latitude)
;     result=DEG2KM(Degrees, Longitude, Latitude)

; Example:
;   IDL> result = KM2DEG(100,25,35)
;   IDL> print, result
;       1.0966405      0.89831528
;     i.e., 100 km at 25E,35N is 1.0966° along Longitude and 0.8983° along Latitude
; KEYWORDS:
;     None
; INPUTS:
;     Kilometers|Degrees, Longitude, Latitude
; OUTPUT:
;     A 2-element array
; WARNING:
;     Do NOT use these functions with vector data. You will not get correct results
; CATEGORY:
;       Data handling, Empirical estimation
; Written by:
; Yaswant Pradhan
; University of Plymouth
; Yaswant.Pradhan@plymouth.ac.uk
; Last Modification: 18-01-07 (YP: Original)

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


Re=6378.137D    ;Earth's radius at the Equator
if(N_PARAMS() LT 3) then begin
    PRINT,'KM2DEG() Error! Insufficient arguments'
    PRINT,'KM2DEG() Usage: result=KM2DEG(Kilometer, Longitude, Latitude)'
    RETALL
endif

    DEG=dblarr(2)
;DEG[0] = Meridional distance (Equivalent of 1KM) in degrees at given Lon, Lat and
;DEG[1] = Zonal distance (Equivalent of 1KM) in degrees at given Lon, Lat
    DEG[0] = (180.0D/!DPI) / (Re * COS(Latitude*!DTOR))
    DEG[1] = (180.0D/!DPI) / Re

return,DEG*KM
END
;---------------------------------------------------------

FUNCTION DEG2KM, DEG, Longitude, Latitude, KM

Re=6378.137D
if(N_PARAMS() LT 3) then begin
    PRINT,'DEG2KM() Error! Insufficient arguments'
    PRINT,'DEG2KM() Usage: result=DEG2KM(Degrees, Longitude, Latitude)'
    RETALL
endif

    KM=dblarr(2)
;KM[0] = Meridional distance (Equivalent of 1° )in Kiometers at given Lon, Lat and
;KM[1] = Zonal distance (Equivalent of 1°) in kilometers at given Lon, Lat
    KM[0] = (Re / (180.0D/!DPI))* COS(Latitude*!DTOR)
    KM[1] =  Re / (180.0D/!DPI)

return,DEG*KM
END
;---------------------------------------------------------