PRO get_matchupFilenames, avg_file, TYPE2=type2


  if ( n_params() LT 1 ) then $
  avg_file = dialog_pickfile( /READ, title='Please select desired _DDS_Match_average.csv File', filter='*_average.csv', get_path=cwd)
  cd,cwd

  tem=get_avg_template()
  data=read_ascii( avg_file, template=tem )

  if ( keyword_set(type2)) $
   then fields=tem.fieldnames(92:108) $
   else fields=tem.fieldnames(24:40)

  print,'FIELD FIELDNUMBER'
  for i=0,15 do print, fields(i), i
  read,'Input a field-number to get the match-up-file list : ', field
  param_name=(strsplit( fields(field), '_', /extract))[0]

  if( strcmp(param_name,'ddsChl1',/fold_case) or strcmp(param_name,'ddsChl2',/fold_case) ) $
  then in_name='inChl' $
  else in_name='in'+strmid(param_name,3)
  avg_name=param_name+'_avg'
  std_name=param_name+'_std'
  n_name=param_name+'_N'


  for i=0, n_tags(data)-1 do begin
    if strcmp( (tag_names(data))[i], in_name, /fold_case ) then in=data.(i)
    if strcmp( (tag_names(data))[i], avg_name, /fold_case ) then avg=data.(i)
    if strcmp( (tag_names(data))[i], std_name, /fold_case ) then std=data.(i)
    if strcmp( (tag_names(data))[i], n_name, /fold_case ) then n=data.(i)
    if strcmp( (tag_names(data))[i], 'ddsFilename', /fold_case ) then filename=data.(i)
  endfor

  pos=where( (in GT 0.) and (avg GT 0.) and ((std/avg) LT 0.2), cnt )
  if (cnt GT 0) then begin
    outfile=param_name+'_matchup_list.txt'
    openw,1,outfile
    print,'Match-up file names for '+param_name+' are stored in > '+outfile
    for i=0,cnt-1 do printf,1,filename(i)
    close,1
  endif else print,'No matchup files for ',param_name

END