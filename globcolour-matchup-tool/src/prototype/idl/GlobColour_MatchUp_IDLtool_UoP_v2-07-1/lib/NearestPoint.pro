FUNCTION NearestPoint, LonSearch, LatSearch, LonProto, LatProto, $
       MaxDist=MaximumDistance, SR=SearchRadius, nP=nPoints, SPH=sph, $
       VERB=verb
;+
;Name: NearestPoint
;Syntax:
;     result = NearestPoint( LonArray, LatArray, LonPoint, LatPoint $
;         [,MaxDist=value] [,SR=value] [,nP=value] [,/SPH] [,/verb] )
;
;Purpose: Estimates the nearest point of a given loacation from a set of
;      points and retruns the position [col, row] of Nearest pixel
;     Calculation based on Cartesian system minimum distance formula
;
;Inputs:
;     LonSearch:Longitude Vector/Array (max 2D) from which Search to be performed
;     LatSearch:Latgitude Vector/Array (max 2D) from which Search to be performed
;     LonProto: Longitude value (scalar) to be searched
;     LatProto: Latgitude value (scalar) to be searched
;
;Keywords:
;     MaxDist: Maximum distance from the Searched Point
;     SR:   (For Vector inputs) Search Radius in Lat/Lon units [default is 0.5 degrees]
;     nP:   nPoints -> Number of Pixels surrounding the Nearest Point [optional; default is 0]
;               nPoints should be between 1 [=3x3 pixels] and 50 [=101x101 pixels];
;     SPH: Correction for spherical coordinate;
;      do not use this keyword, if there is a large latitudinal difference in the input data
;     verb: Verbose

;###IMPORTANT NOTE: nPoints have different properties for different input type
;     i) While use nP keyword with 2D Lon/Lat arrays, nP means the number of pixels on each side of the nearest search pixel.
;     ii)While use nP keyword with Vector Lon/Lat arrays, nP means number of pixels close to the searched point are to be extracted.

;Output:
;     The nearest Pixel position from the Search window
;     2-element array, if nPoints=1 [col,row]
;     4-element array, if nPoints>1 [lft_col, rgt_col, bot_row, top_row]
;Author: Yaswant Pradhan, University of Plymouth
;Version: 1.0, May 06
;Last Change: Mar 07
;-


s=SIZE(LonSearch)
;++Parse Error
if (n_params() LT 4) then begin
    PRINT,'ERROR 0.: [Arguments] Insufficient number of arguments.'
    PRINT,'USAGE: result=NearestPoint(LonArray, LatArray, LonPoint, LatPoint, [MaxDist=value], [nP=integer], [SR=value], [/SPH])'
    return,-900
endif
if (s[0] LE 0 OR s[0] GT 2) then begin
    PRINT,'ERROR 1.: [Dimension] 0 - Lat/LonSearch should be Arrays'
    return,-901
endif
if (n_elements(LonSearch) NE n_elements(LatSearch)) then begin
    PRINT,'ERROR 2.: [Dimension] Unequal - Dimensions of LatSearch and LonSearch should be equal'
    return,-902
endif
;Default Settings
if NOT (keyword_set(nPoints)) then nPoints=0
if NOT (keyword_set(MaximumDistance)) then MaximumDistance=0.1
if NOT (keyword_set(SearchRadius)) then SearchRadius=0.05
if (keyword_set(verb)) then v=1b else v=0b
help,nPoints
;--Parse Error


if (s[0] EQ 1) then begin
    NCols=n_elements(LonSearch)
    LonS=REFORM(LonSearch, NCols)
    LatS=REFORM(LatSearch, NCols)
endif
if (s[0] EQ 2) then begin
    Ncols=s[1]
    Nrows=s[2]
    Npix=s[4]
    LonS=REFORM(LonSearch, Npix)
    LatS=REFORM(LatSearch, NPix)
endif

f=1.
if (KEYWORD_SET(sph)) then begin
    PRINT,'Sphere Correction Applied.'
    f=sin(abs(median(LatSearch))*!DTOR)
endif


xDiff=f*(LonProto - LonS)
yDiff=(LatProto - LatS)


res=(xDiff^2) + (yDiff^2)   ;Square of Distance between 2 points in Cartesian Coord
distance=sqrt(res)          ;Calculate the distance
sort_pos=sort(distance)     ;sort the result to extract nP points from Vector inputs

pos=where(distance EQ min(distance))  ;Position of Minimum Distance
min_dis=min(distance)      ;Minimum distance between Search and Proto Points
if(v) then print,'Minimum distance : ',min_dis
if (min_dis GT MaximumDistance) then begin  ;If no points found within 0.5 degrees of the Proto Point
    PRINT,'ERROR 3.: [MaximumDistance] No Points Found within ',float(MaximumDistance)
    RETURN,-903
endif


if(s[0] EQ 2) then begin
;1. FOR 2D LON/LAT data
    ret=fltarr(2)
    ret(0)=(pos[0] MOD Ncols)  ;Col Position if there are more than 1 nearest points, then use the 1st one pos[0]
    ret(1)=long(pos[0]/Ncols)   ;Row Position

    if (nPoints GE 1) then begin
        if (nPoints GT 50) then begin
            if(v) then PRINT,'WARNING 1.: [nPoints] Exceed - nPoints should be less than 51. Default set to 1.'
            RETURN,long(ret)
        endif
        np=nPoints
        lc=(0 > (ret(0)-nP))            ;subLeft Column
        rc=((Ncols-1) < (ret(0)+nP))    ;subRight Column
        br=(0 > (ret(1)-nP))            ;subBottom Row
        tr=((Nrows-1) < (ret(1)+nP))    ;subRight Column
    ;print,lc,rc,br,tr,min_dis
        RETURN,long([lc,rc,br,tr])
    endif else RETURN, long(ret)


endif else if (s[0] EQ 1) then begin
;2. FOR VECTOR LON/LAT data
    pos2=where(distance LE SearchRadius, cnt)
    ;if(v) then print,'pos2 : ',distance(pos2),pos2

    ;If the number of pixels within Search radius are less than desired points
    ;Then get the N closest desired points
    if(cnt LT nPoints) then begin
       if(v) then print,(LonSearch(sort_pos))[0:nPoints-1],(LatSearch(sort_pos))[0:nPoints-1]
       if(v) then print,'Distance : ',(distance(sort_pos))[0:nPoints-1]
       RETURN,sort_pos[0:nPoints-1]

    endif else begin
       if(v) then print,LonSearch(pos2), LatSearch(pos2)
       if(v) then print,'Distance : ', distance(pos2)
       RETURN,pos2

    endelse
endif

END