FUNCTION get_gcDDStimeseries_template


;+
;NAME:
;   get_gcDDStimeseries_template
;PURPOSE:
;   RETURNS GLOBCOLOUR DDS TIMESERIES FILE TEMPLATE
;INPUTS:
;   NONE
;OUTPUT:
;   GLOBCOLOUR DDS TIMESERIES TEMPLATE ANONYMOUS STRUCTURE
;SYNTAX:
;   template=get_gcDDStimeseries_template()
;
;Note: The idl function create_struct() can also be used instead of {} to create anonymous structure like
;   list1_tenplate = CREATE_STRUCT('VERSION',1.0, 'DATASTART',1, and so on)
;Author: Yaswant Pradhan, Jul 07
;-

  gcDDStimeseries_template={$
 		VERSION : 1.0,$
 		DATASTART : 1,$
 		DELIMITER : 44b,$
 		MISSINGVALUE : !values.f_NaN,$
 		COMMENTSYMBOL : '',$
 		FIELDCOUNT : 37,$
 		FIELDTYPES : [7,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,7,7],$
		FIELDNAMES : ['TIME','CHL1_MEAN','CHL2_MEAN','KD490_MEAN','TSM_MEAN','CDM_MEAN','BBP_MEAN','T865_MEAN','L412_MEAN','L443_MEAN','L490_MEAN','L510_MEAN','L531_MEAN','L555_MEAN','L620_MEAN','L670_MEAN','L681_MEAN','L709_MEAN',+$
												 'CHL1_SDEV','CHL2_SDEV','KD490_SDEV','TSM_SDEV','CDM_SDEV','BBP_SDEV','T865_SDEV','L412_SDEV','L443_SDEV','L490_SDEV','L510_SDEV','L531_SDEV','L555_SDEV','L620_SDEV','L670_SDEV','L681_SDEV','L709_SDEV','DDS_NAME','FileName'],$
 		FIELDLOCATIONS : [0,17,33,49,65,81,97,113,129,145,161,177,193,209,225,241,257,273,289,305,321,337,353,369,385,401,417,433,449,465,481,497,513,529,545,561,571],$
 		FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36]}


  return,gcDDStimeseries_template


END