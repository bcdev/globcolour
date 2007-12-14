PRO diagFlags

close,/all
template={$
 VERSION : 1.0,$
 DATASTART : 0,$
 DELIMITER : 32b,$
 MISSINGVALUE : !Values.F_NaN,$
 COMMENTSYMBOL : '',$
 FIELDCOUNT : 1,$
 FIELDTYPES : 3,$
 FIELDNAMES : 'Flag',$
 FIELDLOCATIONS : 0,$
 FIELDGROUPS : 0}

file=DIALOG_PICKFILE(Title='Select FlagFile',Filter='*.csv',/Read)
data=READ_ASCII(file, Template=template)

for i=0,FILE_LINES(file)-1 do print,gcDDSFlag2Name(data.Flag(i))



END