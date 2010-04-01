FUNCTION read_gcINSITU31, filename, data, $
         VERB=verb, SHOW_ERROR=show_error, $
         GET_FILENAME=fname, DB_NAME=dname

;+
; NAME
;     read_gcINSITU31
; VERSION
;     1.0
; PURPOSE
;     READS THE STANDARD 31-COLUMN GLOBCOLOUR IN-SITU CSV FILE
; USAGE:
;   IDL> result = read_gcINSITU31('filename',[/verb],[/show_error],[GET_FILENAME=variable],[DB_NAME=variable])
;   IDL> help, result
;       RESULT  STRUCT    = -> <Anonymous> Array[1]
; KEYWORDS:
;     verb - prints the Field Names in the returned structure
;     show_error - print expected illegal floating point errors
;     GET_FILENAME - save input file name to a named variable
;     DB_NAME - save database name (extracted from the 1st line of the GlobCOLOUR insitu file)
;               to a named variable
; INPUTS
;     GLOBCOLOUR IN-SITU CSV FILENAME; IF NOT PROVIDED A DIALOG PROMPT WILL APPEAR
; OUTPUT
;     ANONYMOUS STRUCTURE RETURNED
; CATEGORY:
;       Data handling, Empirical estimation
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
    filename=DIALOG_PICKFILE(/READ,FILTER="*.csv",TITLE='SELECT GlobCOLOUR 31-column INSITU CSV FILE')
    if(STRCMP(filename,'')) then begin
        print,'Error! Insitu file was not selected.'
        retall
    endif
 endif
 CD,FILE_DIRNAME(filename)

 gcinsitu_template={$
 VERSION : 1.0,$
 DATASTART : 10,$
 DELIMITER : 44b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 31,$
 FIELDTYPES : [7,2,7,3,3,3,3,3,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3,7,7],$
 FIELDNAMES : ['ID','DDS_ID','DDS_Name','Year','Month','Date','Hour','Minute','Longitude','Latitude', $
          'Depth','Chla_hplc','Chla_fluor','Kd490','TSM','acdm443','bbp443','T865', $
          'exLwn412','exLwn443','exLwn490','exLwn510','exLwn531','exLwn555','exLwn620','exLwn670','exLwn681','exLwn709', $
          'Flag','Campaign','Comments'],$
 FIELDLOCATIONS : [0,5,8,11,16,18,20,23,26,38,49,51,55,66,70,74,78,82,86,90,94,98,102,106,110,114,118,122,126,129,138],$
 FIELDGROUPS : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]}


 data=READ_ASCII(filename,TEMPLATE=gcinsitu_template)
 if(KEYWORD_SET(verb)) then begin
    for i=0,n_elements(gcinsitu_template.FIELDNAMES)-1 do print,i+1,gcinsitu_template.FIELDNAMES[i],format='(I3.2,"->",A)'
    print,'INPUT FILE : ',filename
 endif
 if(KEYWORD_SET(show_error)) then !EXCEPT=1 else !EXCEPT=0

 fname=FILE_BASENAME(filename)

 openr,1,filename
 firstline=strarr(1)
 readf,1,firstline
 close,1
 dname=(strsplit(firstline,',',/extract))[1]
 dname=strcompress(dname,/remove_all)

 return,data
END