FUNCTION get_gcCntOffset, Filename, Latitude, $
        LAT_STEP=LatStep, NR=nRows

;+
;Name:      get_gcCntOffset
;
;Task:      Returns the offset and count for a GlobColour netCDF (Isin Grid) hyperslab
;
;Inputs:
;     A GlobColour netCDF file in Isin projection
;     Latitude of interest in decimal degrees
;
;Output:    A 2-element array [Offset, Count], i.e., from where and how many pixels
;
;Keywords:
;      LAT_STEP -> Latitude Step in the Isin grid (default method is get info from Global attribute)
;      NR -> Number of Rows on either sides of the row corresponding to in-situ Latitude (default is 2 -> 5 rows)
;
;Syntax: result=getgcCntOffset(Filename, Latitude [,LAT_STEP=value] [,NR=value])
;
;Original: Yaswant Pradhan (Apr 07)
;Verson: 1.0
;Last modified: Apr 07 (YP) NR Keyword added
;-

;COMPILE_OPT IDL2


  if ( n_params() LT 2 ) then begin
    stop,'SYNTAX: Result = get_gcCntOset(Filename, Latitude)'
  endif


;+  Read netCDF row
  id = NCDF_OPEN(Filename)      ;Open netCDF input file
  NCDF_VARGET, id, 'row', row    ;Read variable 'data'
  NCDF_ATTGET, id, /GLOBAL, 'lat_step', LS
  NCDF_CLOSE, id
;-  Read netCDF


  if ~( keyword_set(LatStep) ) then LatStep=LS
  if ~( keyword_set(nRows) ) then nRows=2   ;2 rows from either sides of the row corresponding to the in-situ lat



  getRow = FIX( (Latitude + 90.)/LatStep )
  subRows = [getRow-nRows, getRow+nRows]

  oset = VALUE_LOCATE(row, subRows[0]-1)+1
  limit = VALUE_LOCATE(row, subRows[1])
;print,getRow,nRows,oset,limit,subRows
;help,row
  if ( (oset GT 0) and (limit GT 0) and (oset LT n_elements(row)) ) then begin
    ;if ( (row[oset]-subRows[0] EQ 0) or (row[limit]-subRows[1] EQ 0) ) then begin
      cnt = ( limit - oset )
      return,[oset, cnt]
    ;endif
  endif else return,[-1,-1]

END