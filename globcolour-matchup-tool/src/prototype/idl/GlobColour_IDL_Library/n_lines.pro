FUNCTION n_lines,file


on_ioerror,ioerr
openr,unit,file,/get_lun,error=err
if err ne 0 then begin
    ioerr:
    message,'Error reading file '+file,/inform
    return,-1
endif


nlines=0l & line=''
while not eof(unit) do begin
    readf,unit,line
    nlines=nlines+1
endwhile
free_lun,unit


return,nlines
END

