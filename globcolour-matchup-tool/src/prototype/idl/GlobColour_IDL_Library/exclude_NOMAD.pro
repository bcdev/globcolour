PRO exclude_NOMAD

;removes NOMAD duplicates from SeaBASS
CD,'Y:\GlobCOLOUR\in-situ\SeaBASS-archive\0_dds_valid'
sb_temp=ascii_template('Combo__LwEdEsKd490chl_surf__Mar-2006.csv')
S=READ_ASCII('Combo__LwEdEsKd490chl_surf__Mar-2006.csv',template=sb_temp)
n_temp=ascii_template('nomad_seabass_v13.csv')
N=READ_ASCII('nomad_seabass_v13.csv',template=n_temp)

sID=S.FIELD133
sDate=S.FIELD022
sLat=S.FIELD025
sLon=S.FIELD026
sHour=S.FIELD019
sMin=S.FIELD020

nDate=N.FIELD007
nLat=N.FIELD009
nLon=N.FIELD010
nHour=N.FIELD004
nMin=N.FIELD005

help,sDate,nDate
openw,1,'excludeNOMAD.csv'
c=0
for i=0,n_elements(sDate)-1 do begin
    for j=0,n_elements(nDate)-1 do begin
        if ((sDate(i) EQ nDate(j)) AND (sHour(i) EQ nHour(j)) AND (sMin(i) EQ nMin(j)) AND (sLat(i) EQ nLat(j)) AND (sLon(i) EQ nLon(j))) then begin
            print, sDate(i),nDate(j),sLat(i),nLat(j),sLon(i),nLon(j),sHour(i),nHour(j)
            printf,1,sID(i)
            c=c+1
        endif
    endfor
endfor
print,c
close,1
END