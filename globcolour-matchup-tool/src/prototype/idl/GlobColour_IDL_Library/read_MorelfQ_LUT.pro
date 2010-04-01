FUNCTION read_MorelfQ_LUT, filename

;+
;NAME:
;   read_MorelfQ_LUT

;VERSION
; 1.2

;PURPOSE:
; Returns the Morel et al f/Q Look-up table (LUT) as a 5D double array

;SYNTAX:
; Result = read_MorelfQ_LUT( 'morel_fq.dat' )
; or Result = read_MorelfQ_LUT()

;INPUTS:
;	filepath to "morel_fq.dat" or nothing (the program will promt to select morel_fq.dat file)

;OUTPUT:
; A 5-D array of Array[7,6,6,17,13]

;CATEGORY:
; Ocean colour, Radiative transfer, BRDF

;	$Id: read_MorelfQ_LUT.pro,v 1.0 28/02/2006 12:12:43 yaswant Exp $
; read_MorelfQ_LUT.pro	Yaswant Pradhan	University of Plymouth
;	Last modification
;-


	if(n_params() LT 1) then $
    filename = dialog_pickfile(/READ,FILTER='*_fq.dat',Title='Select "morel_fq.dat" file',GET_PATH=cwd)

	foqtab = dblarr(7,6,6,17,13)
	data = dblarr(55692)

  openr,lun,filename, /get_lun
  print,"Loading Morel f/Q table from: ",file_dirname(filename)
  readf,lun,data ;reading data to a temporary array
  free_lun,lun
  	xx = 0L
    for ii=0,7-1 do for jj=0,6-1 do for kk=0,6-1 do for ll=0,17-1 do for mm=0,13-1 do begin
      foqtab[ii,jj,kk,ll,mm] = data[xx]
      xx = xx+1L
    endfor

	return, foqtab

END