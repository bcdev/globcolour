PRO PLOT_DDS
;Plots GlobColour DDS locations for predefined DDS + Aeronet DDS sites
;Reads globcolour_dds.csv

close,/all

data=READ_GCDDS(/verb)

 tek_color
   ;++PS UTILITY
   SET_PLOT, 'PS'
   psFileName=DIALOG_PICKFILE(FILTER=['*.ps','*.eps'],/WRITE,Title='Please Enter EPS File Name.')
   DEVICE, /COLOR,/ENCAPSUL,xSize=23,ySize=12,BITS_PER_PIXEL=8,FILENAME=psFileName

Lat_Names=['60N','30N','EQ','30S','60S']
n_Lats=[60,30,0,-30,-60]
Lon_Names=['150W','120W','90W','60W','30W','0','30E','60E','90E','120E','150E']
n_Lons=[-150,-120,-90,-60,-30,0,30,60,90,120,150]

MAP_SET,0.,0.,LIMIT=[-90.,-180.,90.,180.],/ISO,$
       XMargin=[0,0],YMargin=[2,2],/NOBORDER,/CLIP

MAP_GRID,/BOX_AXES,COLOR=0,LATDEL=30., LONDEL=30., $
       /NO_GRID,LATNAMES=Lat_Names, LATS=n_Lats, $ ;,GLINESTYLE=1,CHARSIZE=1
       LONNAMES=Lon_Names, LONS=n_Lons,CHARTHICK=2.
MAP_CONTINENTS,/COAST, FILL_CONTINENTS=1,COLOR=15


wh=where(data.SiteID LE 23,cnt,complement=aot,ncomplement=n_aot)

if (cnt GT 0) then begin
	all_ID =	data.SiteID(wh)
	all_LonC =	data.LonC(wh)
	all_LatC =	data.LatC(wh)
	n_all =		n_elements(all_ID)

	plots,all_LonC,all_LatC,psym=symcat(15),color=2

endif

if (n_aot GT 0) then begin
	aot_ID =	data.SiteID(aot)
	aot_LonC=	data.LonC(aot)
	aot_LatC=	data.LatC(aot)
	n_aot =		n_elements(aot_ID)

	plots,aot_LonC,aot_LatC,psym=symcat(15),color=4

endif


plots,-170,-59,psym=symcat(15),COLOR=2
plots,-170,-69,psym=symcat(15),COLOR=4

XYOUTS,[-165,-165],[-61,-71],$
       ['ALL PRODUCTS [N:'+string(cnt,format='(I3)')+']','T865 (AERONET) [N:'+string(n_aot,format='(I3)')+']'],charthick=1.5

XYOUTS,0,84,"GlobColour Diagnostic Data Sites",ALIGNMENT=0.5,CHARSIZE=1.0,charthick=1.5
XYOUTS,180,-89,"GlobColour, UoP.",ALIGNMENT=1.,CHARSIZE=0.8,charthick=2
DEVICE, /CLOSE
SET_PLOT, 'win'

END