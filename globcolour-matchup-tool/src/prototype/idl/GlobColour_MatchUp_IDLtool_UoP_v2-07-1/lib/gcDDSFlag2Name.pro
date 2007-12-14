FUNCTION gcDDSFlag2Name,input,flag, $
         DEPTH=dep, CLOUD=clf, TURBID=tbd,$
         VALID=val, ALLOW_REPLICA=allow_replica, ALLOW_LAND=allow_land

;+
;NAME:
;     gcDDSFlag2Name
;PURPOSE:
;     Converts GlobCOLOUR DDS 16-bit Flags to Names, store Depth/Cloud info if necessary
;INPUTS:
;     A 16-bit 2-byte integer value, e.g. 6753
;OUTPUT:
;     A string Array containg the Flag Names
;KEYWORDS:
;      DEPTH -> a named variable to store the depth information
;      0 - undefined
;      1 - >1000m
;      2 - >=200m and <1000m
;      3 - >=30m and <200m
;      4 - <30m

;      CLOUD -> a named variable to store the cloud fraction
;      0 - undefined
;      1 - <5%
;      2 - >=5% and <25%
;      3 - >=25% and <50%
;      4 - >50%

;      TURBID -> a named variable to store the turbid flag
;      0 - Not turbid
;      1 - Turbid

;      VALID -> a named variable to store the validity of the pixel
;      1 - Valid
;      0 - Invalid (if there is LAND or NO_MEAS or REPLICA or INVALID flag raised)
;       -- if /allow_replica keyword is set, then REPLICA flag will be realxed and will be considered as valid
;       -- if /allow_land keyword is set, then LAND flag will be ignored and will be considered as valid
;

;Syntax: result=gcDDSFlag2Name(6753 [,DEPTH=variable] [,CLOUD=variable] [,TURBID=variable] [,VALID=variable] $
;                [,/ALLOW_REPLICA] [,/ALLOW_LAND])
;
;Original: Yaswant Pradhan (June 06)
;Verson: 1.3
;Last modified: Mar 07 (YP) Depth, Cloud Keyword added
;        Apr 07 (YP) bugfix keyword variable intialisations, thanks to Julien Demaria.
;        allow_land keyword added
;-


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Initialise keyword variables
 dep=0  ;do not change
 clf=0  ;do not change
 tbd=0  ;do not change
 val=1  ;do not change
 if (KEYWORD_SET(allow_replica)) then replica=1b else replica=0b; set replica=1b to force allow replica (to override keyword parameter)
 if (KEYWORD_SET(allow_land)) then land=1b else land=1b; set land=1b to force allow land (to override keyword parameter)
 verb=0b    ;verb=1b sets verbose switch on
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;GlobColour FLAGS
 flag="NO_MEAS,INVALID,REPLICA,LAND,CLOUD1,CLOUD2,DEPTH1,DEPTH2,TURBID," + $
    "spare,spare,spare,spare,SWF,MOD,MER"
 flag=STRSPLIT(flag,',',/extract)
 nbits=N_ELEMENTS(flag) ;nbits=16


;GlobColour Flags are SHORT INTEGERS
 input=UINT(input)
 x=ROUND(input,/L64)
 hi=ROUND(2D^nbits,/L64)
 IF (x ge hi) OR (x lt -hi) THEN BEGIN
    print,'[gcDDSFlag2Name] WARNING! Fail converting flags: ',x, nbits
    out=MAKE_ARRAY(nbits,/FLOAT, value=-1) ;error indicator
    RETURN,out
 ENDIF
 out=MAKE_ARRAY(nbits,/FLOAT, value=0)

 FOR i=nbits-1,0,-1 DO BEGIN
    test=ROUND(2D^i,/L64)
    IF (x ge test) THEN BEGIN
       out[i]=1
       x=x-test
    ENDIF
 ENDFOR

 pos=WHERE(out EQ 1, cnt)
 if (cnt GT 0) then  begin

;HANDLE DEPTH
    if( TOTAL(STRMATCH(flag(pos),'DEPTH1'))+TOTAL(STRMATCH(flag(pos),'DEPTH2')) EQ 0 ) then dep=4 ;<30m
    if( (TOTAL(STRMATCH(flag(pos),'DEPTH1')) EQ 1) and (TOTAL(STRMATCH(flag(pos),'DEPTH2')) EQ 0) ) then dep=3 ;>=30m, <200m
    if( (TOTAL(STRMATCH(flag(pos),'DEPTH1')) EQ 0) and (TOTAL(STRMATCH(flag(pos),'DEPTH2')) EQ 1) ) then dep=2 ;>=200m, <1000m
    if( TOTAL(STRMATCH(flag(pos),'DEPTH1'))+TOTAL(STRMATCH(flag(pos),'DEPTH2') ) EQ 2) then dep=1 ;>1000m

;HANDLE CLOUD
    if( TOTAL(STRMATCH(flag(pos),'CLOUD1'))+TOTAL(STRMATCH(flag(pos),'CLOUD2')) EQ 0 ) then clf=1 ;<5%
    if( (TOTAL(STRMATCH(flag(pos),'CLOUD1')) EQ 1) and (TOTAL(STRMATCH(flag(pos),'CLOUD2')) EQ 0) ) then clf=2 ;>=5%, <25%
    if( (TOTAL(STRMATCH(flag(pos),'CLOUD1')) EQ 0) and (TOTAL(STRMATCH(flag(pos),'CLOUD2')) EQ 1) ) then clf=3 ;>=25%, <50%
    if( TOTAL(STRMATCH(flag(pos),'CLOUD1'))+TOTAL(STRMATCH(flag(pos),'CLOUD2')) EQ 2 ) then clf=4 ;>50%

;TURBID FLAG
    if(TOTAL(STRMATCH(flag(pos),'TURBID')) EQ 1) then tbd=1

;HANDLE LAND
    if(land) then begin
      if(verb) then print,'LAND flags are considered VALID'
      LAND_FLAG=0
    endif else LAND_FLAG=TOTAL( STRMATCH(flag(pos),'LAND') )

;HANDLE REPLICA FOR VALIDITY
    if(replica) then begin
      if(verb) then print,'REPLICA flags are considered VALID'
      if( (TOTAL(STRMATCH(flag(pos),'NO_MEAS')) EQ 1) or $
         (TOTAL(STRMATCH(flag(pos),'INVALID')) EQ 1) or $
         (LAND_FLAG EQ 1) ) then val=0 ;VALID FLAG
    endif else if( (TOTAL(STRMATCH(flag(pos),'NO_MEAS')) EQ 1) or $
         (TOTAL(STRMATCH(flag(pos),'INVALID')) EQ 1) or $
         (TOTAL(STRMATCH(flag(pos),'REPLICA')) EQ 1) or $
         (LAND_FLAG EQ 1) ) then val=0 ;VALID FLAG

    RETURN,flag(pos)
 endif else RETURN,''

END