FUNCTION get_gclist1_template


;+
;NAME:
;   get_gclist1_template
;PURPOSE:
;   RETURNS GLOBCOLOUR MATCH-UP LIST1 FILE TEMPLATE THAT CAN BE USED IN READING
;   THE LIST1 FILES USING READ_ASCII
;INPUTS:
;   NONE
;OUTPUT:
;   GLOBCOLOUR LIST1 TEMPLATE ANONYMOUS STRUCTURE
;SYNTAX:
;   template=get_gclist1_template()
;
;Note: The idl function create_struct() can also be used instead of {} to create anonymous structure like
;   list1_tenplate = CREATE_STRUCT('VERSION',1.0, 'DATASTART',1, and so on)
;Author: Yaswant Pradhan, Jul 07
;-

  gclist1_template={$
 		VERSION : 1.0,$
 		DATASTART : 1,$
 		DELIMITER : 44b,$
 		MISSINGVALUE : !values.f_NaN,$
 		COMMENTSYMBOL : '',$
 		FIELDCOUNT : 12,$
 		FIELDTYPES : [7,7,7,4,4,4,4,4,4,4,4,7],$
 		FIELDNAMES : ['inID','inTime','satTime','Lon','Lat','inValue','satValue','NPix','PixStd','Ratio','pDiff','Filename'],$
 		FIELDLOCATIONS : [0,11,28,45,56,67,78,89,100,111,122,133],$
		FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11]}


  return,gclist1_template


END