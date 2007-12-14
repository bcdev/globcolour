PRO read_HDF, filename, data, attributes, sdsNames, status

;+
; NAME:
;   read_HDF.pro
;
; PURPOSE:
;   Read HDF file into structure variable
;
; CATEGORY:
;   All levels of processing
;
; CALLING SEQUENCE:
;   read_HDF, filename, data, attributes, sdsNames, status
;
; INPUTS:
;   filename = filename for existing HDF file
;
; OUTPUTS:
;   data = structure variable for data read from HDF file
;   attributes = array of strings of the attributes from the HDF file
;		sdsNames = Names of SDs in the HDF
;   status = result status: 0 = OK_STATUS, -1 = BAD_PARAMS, -2 = BAD_FILE,
;      -3 = BAD_FILE_DATA, -4 = FILE_ALREADY_OPENED
;
; COMMON BLOCKS:
;   None
;
;
; MODIFICATION HISTORY:
;   13/06/2007     Yaswant Pradhan   Original release of code, Version 1.00
;
; $Log: read_hdf.pro,v $
;
;
;idver='$Id: read_hdf.pro,v 1.0 2007/06/13 12:43:06 yaswant Exp $'
;
;+

	OK_STATUS = 0
	BAD_PARAMS = -1
	BAD_FILE = -2
	BAD_FILE_DATA = -3
	FILE_ALREADY_OPENED = -4

	status = BAD_PARAMS

	if (n_params(0) lt 1) then begin
    print, 'USAGE: read_HDF, filename, data, attributes, status'
    return
	endif
	if (n_params(0) lt 2) then begin
    filename = ''
    read, 'Enter filename for the existing HDF file : ', filename
    if (strlen(filename) lt 1) then return
	endif
	if ~(hdf_ishdf(filename)) then begin
		print,string(10b)+'Invalid HDF File >> '+filename
		return
	endif

	status = OK_STATUS


	hdfFileID = HDF_SD_start(filename,/read)
	HDF_SD_fileinfo, hdfFileID, n_datasets, n_attributes
  numPalettes = hdf_dfp_npals(filename)


	global_attributes = strarr(n_attributes)
	for i=0,n_attributes-1 do begin
		HDF_SD_attrinfo, hdfFileID, i, NAME=att_name
		HDF_SD_attrinfo, hdfFileID, i, DATA=att_value
		global_attributes(i)=att_name+'='+strtrim(string(att_value),2)
	endfor


;Retrieve SDs attributes
	sdsNames = strarr(n_datasets)
	for j=0,n_datasets-1 do begin
		sdsID = HDF_SD_select(hdfFileID,j)
		HDF_SD_getinfo, sdsID, NAME=sdsName, NATTS=n_sdsAttributes
		sdsNames(j)=sdsName
		sds_attributes = strarr(n_sdsAttributes)

		for k=0,n_sdsAttributes-1 do begin
			HDF_SD_attrinfo, sdsID, k, NAME=sds_att_name
			HDF_SD_attrinfo, sdsID, k, DATA=sds_att_value
			;sds_attributes(k) =sdsNames(j)+'_'+sds_att_name+'='+strtrim(string(sds_att_value),2)
			sds_attributes(k) = sds_att_name+'='+strtrim(string(sds_att_value),2)
		endfor;for k=0,n_sdsAttributes-1 do begin
	endfor;for j=0,n_datasets-1 do begin

	attributes = [global_attributes,sds_attributes]
	;attributes = attributes[sort(attributes)]


;Retrieve Main dataset
	for i=0,n_datasets-1 do begin
		print,'SDS Name: ',sdsNames(i)
		index = HDF_SD_nametoindex(hdfFileID, sdsNames[i])
		sdsDataID = HDF_SD_select(hdfFileID, index)
		HDF_SD_getdata, sdsDataID, data
	endfor

	HDF_SD_end, hdfFileID

END

