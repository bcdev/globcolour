FUNCTION LatLon2gcDDSID, LAT, LON, $
       NAME=name
;+
;Returns GlobCOLOUR DDS ID (or DDS name) for a Given Lat, Lon
;INPUTS:
;   LATITUDE (scalar or vector), LONGITUDE (scalar or vector)
;Yaswant Pradhan, 2 March 2007
;
;KEYWORD: NAME will return the GlobCOLOUR DDS name; default is DDS Number
;-


if(N_PARAMS() LT 2) then begin
    PRINT,'Usage: result = LatLon2gcDDSID(LATITUDE, LONGITUDE)'
    retall
endif

if(N_ELEMENTS(LAT) NE (N_ELEMENTS(lon))) then begin
    PRINT,'ERROR! Unequal number of elements in Latitude and Longitude vectors.'
    retall
endif

;-----------------------------------------------
;GlobCOLOURDDS BOXES [wlon,elon,slat,nlat]
rng=0.5 ;range [degrees] in lon and lat direction from the location
dds_lon=[-157.2, 7.9, 12.5083, -64.5, -65., -125., -69., -74., 17.4, 7.5, -3., 19., -65., -118., -73., 118.,$
       122., 53.145833, 17.46683, 24.92636, -70.55, -75.71]
dds_lat=[20.8, 43.3666, 45.3139, 32, 11., 35., 43., 39., -32.5, 54., 50., 55.2, -65., -23., -36.5, 22.5, $
       35., 25.495, 58.59417, 59.94897, 41.3, 36.9]
dds_name=['MOBY','BOUSSOLE','VeniceTower','BATS','CARIACO','CALCOFI','GulfOfMaine','LEO15','Benguela',$
       'Helgoland','Channel','Sopot','Palmer','RapaNui','Concepcion','TaiwanStr','YellowSea',$
       'AbuAlBukhoos','GustavDalenTower','HelsinkiLighthouse','MVCO','COVE']
;-----------------------------------------------

id_no=intarr(n_elements(lat))
ddsname=strarr(n_elements(lat))
for i=0,n_elements(lat)-1 do begin
dds=0
  for k=0,n_elements(dds_name)-1 do begin
    if(lat(i) GT dds_lat[k]-rng and lat(i) LT dds_lat[k]+rng and lon(i) GT dds_lon[k]-rng and lon(i) LT dds_lon[k]+rng) then begin
        id=k+1
        dds=1
        dname=dds_name(k)
    endif
  endfor
    if(~dds) then begin
        id=0
        dname='XDDS'
    endif
    id_no[i]=id
    ddsname[i]=dname
endfor
    if(keyword_set(name)) then return,ddsname else return,string(id_no,format='(I2.2)')
END