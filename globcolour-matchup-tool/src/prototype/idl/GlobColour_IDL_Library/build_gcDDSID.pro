PRO build_gcDDSID, SERIAL_ID=serial_id
;+
;Creates sample ID, DDS_ID number and Name for a given dataset
;Functions used : read_gcinsitu31()
;Yaswant Pradhan, 23 Feb 2007
;
;KEYWORD: serial_id will add serial numbers in stead of yyyymmddThhmm
;CALLING FUNCTIONS: read_gcinsitu31
;-


tag="AE" ; Database tag, AE=AERONET, AS=Aeronet SeaPRISM, OB=OBPG, NO=NOMAD, BB=BOUSSOLE BUOY, BS=BOUSSOLE SPMR, SB=SEABASS, NI=NILU, CX=CASIX, FB=FerryBox
if(keyword_set(serial_id)) then seq=1 else seq=0
;-----------------------------------------------
;GlobCOLOURDDS BOXES [wlon,elon,slat,nlat]
;rng=0.5 ;range [degrees] in lon and lat direction from the location
dds_lon=[-157.2, 7.9, 12.51, -64.5, -65., -125., -69., -74., 17.4, 7.5, -3., 19., -65., -118., -73., 118.,$
       122., 53.15, 17.47, 24.93, -70.55, -75.71, 10.5, -28.63, -22.94, -14.42, -59.50, -149.61, 166.92, 127.77, $
       -177.38, 116.72, 73.81, 77.57]
dds_lat=[20.8, 43.37, 45.31, 32, 11., 35., 43., 39., -32.5, 54., 50., 55.2, -65., -23., -36.5, 22.5, $
       35., 25.50, 58.59, 59.95, 41.3, 36.9, 58.5, 38.53, 16.73, -7.98, 13.17, -17.57, -0.52, 26.35,$
       28.21, 20.71, 15.45, -37.81]
dds_name=['MOBY','BOUSSOLE','VeniceTower','BATS','CARIACO','CALCOFI','GulfOfMaine','LEO15','Benguela',$
       'Helgoland','Channel','Sopot','Palmer','RapaNui','Concepcion','TaiwanStr','YellowSea',$
       'AbuAlBukhoos','GustavDalenTower','HelsinkiLighthouse','MVCO','COVE','FerryBox','Azores','CapeVerde',$
       'AscensionIsland','Barbados','Tahiti','Nauru','Okinawa','MidwayIsland','DongshaIsland','Goa','AmsterdamIsland']
n_dds=n_elements(dds_name)
rng=fltarr(n_dds,2)
for i=0,n_dds-1 do rng(i,*)=KM2DEG(50.5,dds_lon(i),dds_lat(i))


;dds_01=[dds_lon[0]-rng,dds_lon[0]+rng,dds_lat[0]-rng,dds_lat[0]+rng]
;-----------------------------------------------

data=read_gcinsitu31(/verb)

lat=data.Latitude
lon=data.Longitude
close,/all
openw,1,'id_info.csv'
for i=0,n_elements(lat)-1 do begin
dds=0
  for k=0,n_elements(dds_name)-1 do begin
    if(lat(i) GT dds_lat[k]-rng[k,1] and lat(i) LT dds_lat[k]+rng[k,1] and lon(i) GT dds_lon[k]-rng[k,0] and lon(i) LT dds_lon[k]+rng[k,0]) then begin
        if(seq) then gc_id=tag+string(k+1,format='(I2.2)')+"-"+string(i+1,format='(I5.5)') $
        else gc_id=tag+string(k+1,format='(I2.2)')+"-"+string(data.Year[i],format='(I4.4)')+string(data.Month[i],format='(I2.2)')+ $
            string(data.Date[i],format='(I2.2)')+"T"+string(data.Hour[i],format='(I2.2)')+string(data.Minute[i],format='(I2.2)')+strtrim('00')
        printf,1,gc_id,k+1,dds_name[k],format='(A,",",I2.2,",",A)'
        dds=1
    endif
  endfor
    if(~dds) then begin
        if(seq) then gc_id=tag+string(dds,format='(I2.2)')+"-"+string(i+1,format='(I5.5)') $
        else gc_id=tag+string(dds,format='(I2.2)')+"-"+string(data.Year[i],format='(I4.4)')+string(data.Month[i],format='(I2.2)')+ $
            string(data.Date[i],format='(I2.2)')+"T"+string(data.Hour[i],format='(I2.2)')+string(data.Minute[i],format='(I2.2)')+strtrim('00')
        printf,1,gc_id,0,'XDDS',format='(A,",",I2.2,",",A)'
    endif
endfor

close,1

END