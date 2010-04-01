pro build_ascii_template

;+
;Name:  build_ascii_template
;Purpose:  Build an ASCII template for a data file which can be used alongside READ_ASCII
;Input: none
;Out:   template printed to IDL prompt
;Usage: build_ascii_template
;Author: Yaswant Pradhan, University of Plymouth, Feb 06
;-

 t=ascii_template()

 	tags=tag_names(t)
 	n=n_tags(t)
 	print,'template={$'
 	for i=0,n-1 do begin
  	if size(t.(i),/type) eq 7 then s="'"+t.(i)+"'" $
  	else if size(t.(i),/type) eq 1 then s=string(fix(byte(t.(i))))+"b" $
  	else s=strtrim(t.(i),2)
  	;print,size(t.(i),/type)
  	;print,t.(i), s
  	s=strjoin(s,',')
  	if n_elements(t.(i)) gt 1 then s='['+s+']'
  	print,' ',tags[i],' : ',s,(i lt n-1)?',$':'}'
 	endfor

end