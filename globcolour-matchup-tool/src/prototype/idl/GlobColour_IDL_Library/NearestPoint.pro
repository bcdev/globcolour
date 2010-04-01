FUNCTION NearestPoint, LonSearch, LatSearch, LonProto, LatProto, $
       MaxDist=MaximumDistance, SR=SearchRadius, nP=nPoints, SPH=sph, $
       VERB=verb
;+
;NAME:
;	NearestPoint

;PURPOSE:
;	Returns the nearest point of a given loacation (Lon,Lat) from a set of
; points and retruns the position [col, row] of Nearest pixel
; Calculation based on Cartesian system minimum distance formula

;SYNTAX:
;	Result = NearestPoint( LonArray, LatArray, LonPoint, LatPoint $
; 				[,MAXDIST=value] [,SR=value] [,nP=value] [,/SPH] [,/VERB] )

;INPUTS:
;	LonSearch:Longitude Vector/Array (max 2D) from which Search to be performed
; LatSearch:Latgitude Vector/Array (max 2D) from which Search to be performed
; LonProto: Longitude value (scalar) to be searched
; LatProto: Latgitude value (scalar) to be searched
;
;KEYWORDS:
;	MaxDist: Maximum distance from the Searched Point
; SR:   (For Vector inputs) Search Radius in Lat/Lon units [default is 0.5 degrees]
; nP:   nPoints -> Number of Pixels surrounding the Nearest Point [optional; default is 0]
;       nPoints should be between 1 [=3x3 pixels] and 50 [=101x101 pixels];
; SPH: Correction for spherical coordinate;
;     do not use this keyword, if there is a large latitudinal difference in the input data
;     verb: Verbose

;###IMPORTANT NOTE: nPoints have different properties for different input type
;     i) While use nP keyword with 2D Lon/Lat arrays, nP means the number of pixels on each side of the nearest search pixel.
;     ii)While use nP keyword with Vector Lon/Lat arrays, nP means number of pixels close to the searched point are to be extracted.

;OUTPUT:
; The nearest Pixel position from the Search window
;		 	2-element array, if nPoints=1 [col,row]
; 		4-element array, if nPoints>1 [lft_col, rgt_col, bot_row, top_row]

;CATEGORY:
;	Image/Map/Earth Coordinate

;	$Id: NearestPoint.pro,v 1.0 15/05/2006 19:25:13 yaswant Exp $
; NearestPoint.pro	Yaswant Pradhan	University of Plymouth
;	Last modification: Mar 07(yp) modified definition of nP.
;-


	s=size(LonSearch)

;++Parse Error
	if ( n_params() lt 4 ) then begin
  	print,'ERROR 0.: [Arguments] Insufficient number of arguments.'
    print,'USAGE: result=NearestPoint(LonArray, LatArray, LonPoint, LatPoint, [MaxDist=value], [nP=integer], [SR=value], [/SPH])'
    return,-900
	endif

	if ( (s[0] le 0) or (s[0] gt 2) ) then begin
    print,'ERROR 1.: [Dimension] 0 - Lat/LonSearch should be Arrays'
    return,-901
	endif

	if (n_elements(LonSearch) ne n_elements(LatSearch)) then begin
    print, 'ERROR 2.: [Dimension] Unequal - Dimensions of LatSearch and LonSearch should be equal'
    return,-902
	endif
;--Parse Error


;++Default Settings
	if not (keyword_set(nPoints)) then nPoints = 0
	if not (keyword_set(MaximumDistance)) then MaximumDistance = 0.1
	if not (keyword_set(SearchRadius)) then SearchRadius = 0.05
	if (keyword_set(verb)) then v=1b else v = 0b
	f = 1.
	if(v) then help,nPoints
;--Default Settings


;++Handle input data
	if (s[0] EQ 1) then begin
    NCols = n_elements(LonSearch)
    LonS = reform(LonSearch, NCols)
    LatS = reform(LatSearch, NCols)
	endif

	if (s[0] eq 2) then begin
    Ncols = s[1]
    Nrows = s[2]
    Npix = s[4]
    LonS = reform(LonSearch, Npix)
    LatS = reform(LatSearch, NPix)
	endif
;--Handle input data


;++Apply correction for Earth sphere
	if ( keyword_set(sph) ) then begin
    print,'Sphere Correction Applied.'
    f = sin( abs(median(LatSearch))*!DTOR )
	endif
;++Apply correction for Earth sphere


	xDiff = f*(LonProto - LonS)
	yDiff = (LatProto - LatS)


	res = (xDiff^2) + (yDiff^2)   ;Square of Distance between 2 points in Cartesian Coord
	distance = sqrt(res)          ;Calculate the distance
	sort_pos = sort(distance)     ;sort the result to extract nP points from Vector inputs

	pos = where( distance eq min(distance) )  ;Position of Minimum Distance
	min_dis = min(distance)      ;Minimum distance between Search and Proto Points
	if (v) then print,'Minimum distance : ',min_dis
	if ( min_dis gt MaximumDistance ) then begin  ;If no points found within 0.5 degrees of the Proto Point
    print,'ERROR 3.: [MaximumDistance] No Points Found within ',float(MaximumDistance)
    return,-903
	endif


	if( s[0] eq 2 ) then begin
;1. FOR 2D LON/LAT data
    ret=fltarr(2)
    ret(0)=(pos[0] mod Ncols)  ;Col Position if there are more than 1 nearest points, then use the 1st one pos[0]
    ret(1)=long(pos[0]/Ncols)   ;Row Position

    if (nPoints ge 1) then begin
    	if (nPoints gt 50) then begin
      	if(v) then PRINT,'WARNING 1.: [nPoints] Exceed - nPoints should be less than 51. Default set to 1.'
        	return,long(ret)
        endif

        np = nPoints
        lc = ( 0 > (ret(0)-nP) )            ;subLeft Column
        rc = ( (Ncols-1) < (ret(0)+nP) )    ;subRight Column
        br = ( 0 > (ret(1)-nP) )            ;subBottom Row
        tr = ( (Nrows-1) < (ret(1)+nP) )    ;subRight Column
    		;print,lc,rc,br,tr,min_dis
        return,long([lc,rc,br,tr])
    	endif else return, long(ret)

		endif else if (s[0] eq 1) then begin



;2. FOR VECTOR LON/LAT data
    pos2 = where( distance le SearchRadius, cnt )
    ;if(v) then print,'pos2 : ',distance(pos2),pos2

    ;If the number of pixels within Search radius are less than desired points
    ;Then get the N closest desired points
    if( cnt lt nPoints ) then begin
    	if(v) then print,(LonSearch(sort_pos))[0:nPoints-1],(LatSearch(sort_pos))[0:nPoints-1]
      if(v) then print,'Distance : ',(distance(sort_pos))[0:nPoints-1]
      return,sort_pos[0:nPoints-1]
    endif else begin
      if(v) then print,LonSearch(pos2), LatSearch(pos2)
      if(v) then print,'Distance : ', distance(pos2)
      return,pos2
    endelse
	endif


END