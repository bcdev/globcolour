FUNCTION read_MorelfQ_LUT, filename

;+
;NAME:
;   read_MorelfQ_LUT
;
;PURPOSE:
;   Reads f/Q Look-up table (Morel et al) and returns the data as a 5-D array
;
;SYNTAX:
;   data = read_MorelfQ_LUT( 'morel_fq.dat' )
;   or data = read_MorelfQ_LUT()
;
;Author:
;   Yaswant Pradhan, Feb 2007
;
;-

if(n_params() LT 1) then $
    filename = DIALOG_PICKFILE(/READ,FILTER='*_fq.dat',Title='Select "morel_fq.dat" file',GET_PATH=cwd)

foqtab = dblarr(7,6,6,17,13)
data = dblarr(55692)

  openr,lun,filename, /get_lun
  print,"Loading Morel f/Q table from: ",file_dirname(filename)
  readf,lun,data ;reading data to a temporary array
  FREE_LUN,lun
      xx=0L
    for ii=0,7-1 do for jj=0,6-1 do for kk=0,6-1 do for ll=0,17-1 do for mm=0,13-1 do begin
      foqtab[ii,jj,kk,ll,mm]=data[xx]
      xx=xx+1L
    endfor

RETURN, foqtab

END