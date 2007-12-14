FUNCTION read_gcDDS, filename, data, $
         VERB=verb, SHOW_ERROR=show_error, $
         GET_FILENAME=fname

;+
; NAME
;     read_gcDDS
; VERSION
;     1.0
; PURPOSE
;     READS GLOBCOLOUR_DDS DEFINITION CSV FILE
; USAGE:
;   IDL> result = read_gcDDS('filename',[/verb],[/show_error],[GET_FILENAME=variable])
;   IDL> help, result
;       RESULT  STRUCT    = -> <Anonymous> Array[1]
; KEYWORDS:
;     verb - prints the Field Names in the returned structure
;     show_error - print expected illegal floating point errors
;     GET_FILENAME - save input file name to a named variable
;     DB_NAME - save database name (extracted from the 1st line of the GlobCOLOUR insitu file)
;               to a named variable
; INPUTS
;     GLOBCOLOUR DDS CSV FILENAME; IF NOT PROVIDED A DIALOG PROMPT WILL APPEAR
; OUTPUT
;     ANONYMOUS STRUCTURE RETURNED
; CATEGORY:
;       Data handling
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


 if(N_PARAMS() LT 1) then begin
    filename=DIALOG_PICKFILE(/READ,FILTER="*.csv",TITLE='SELECT GlobCOLOUR DDS CSV FILE')
    if(STRCMP(filename,'')) then begin
        print,'Error! Insitu file was not selected.'
        retall
    endif
 endif
 CD,FILE_DIRNAME(filename)

 gcdds_template={$
 VERSION : 1.0,$
 DATASTART : 1,$
 DELIMITER : 59b,$
 MISSINGVALUE : !values.f_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 9,$
 FIELDTYPES : [3,7,7,4,4,4,4,4,4],$
 FIELDNAMES : ['SiteID','SiteName','Location','LatC','LatA','LatB','LonC','LonA','LonB'],$
 FIELDLOCATIONS : [0,2,7,14,19,20,21,28,29],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8]}


 data=READ_ASCII(filename,TEMPLATE=gcdds_template)
 if(KEYWORD_SET(verb)) then begin
    for i=0,n_elements(gcdds_template.FIELDNAMES)-1 do print,i+1,gcdds_template.FIELDNAMES[i],format='(I3.2,"->",A)'
    print,'INPUT FILE : ',filename
 endif
 if(KEYWORD_SET(show_error)) then !EXCEPT=1 else !EXCEPT=0

 fname=FILE_BASENAME(filename)

 return,data

END