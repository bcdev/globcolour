PRO mapGlobColourInsitu, PARAM=param
;Plots Insitu locations of GlobColour in-situ data

; Syntax:
;		mapGlobColourInsitu, PARAM=[Chla | Chla_hplc | Chla_fluor | Kd490 | ...]
;Params
 ;12->Chla_hplc  ;13->Chla_fluor ;14->Kd490 ;15->TSM ;16->acdm443 ;17->bbp443 ;18->T865 ;19->exLwn412
 ;20->exLwn443 ;21->exLwn490 ;22->exLwn510 ;23->exLwn531 ;24->exLwn555 ;25->exLwn620 ;26->exLwn670
 ;27->exLwn681 ;28->exLwn709



	close,/all

	data=read_gcINSITU31(/verb,DB_NAME=db)

	case param of
		'Chla_hplc': begin
			variable = 'Chlorophyll-a (HPLC)'
			wh = where(data.Chla_hplc GT 0.,cnt)
		end

		'Chla_fluor': begin
			variable = 'Chlorophyll-a (FLUOR)'
			wh = where(data.Chla_fluor GT 0.,cnt)
		end

		'Chla': begin
			variable = 'Chlorophyll-a (HPLC+FLUOR)'
			wh = where((data.Chla_hplc GT 0.) or (data.Chla_fluor GT 0.),cnt)
		end

		'Kd490': begin
			variable = 'Kd-490'
			wh = where(data.Kd490 GT 0.,cnt)
		end

		'TSM': begin
			variable = 'TSM'
			wh = where(data.TSM GT 0.,cnt)
		end

		'acdm443': begin
			variable = 'aCDM443'
			wh = where(data.acdm443 GT 0.,cnt)
		end

		'bbp443': begin
			variable = 'bbp443'
			wh = where(data.bbp443 GT 0.,cnt)
		end

		'T865': begin
			variable = 'T865'
			wh = where(data.T865 GT 0.,cnt)
		end

		'exLwn412': begin
			variable = 'Lw412'
			wh = where(data.exLwn412 GT 0.,cnt)
		end

		'exLwn443': begin
			variable = 'Lw443'
			wh = where(data.exLwn443 GT 0.,cnt)
		end

		'exLwn490': begin
			variable = 'Lw490'
			wh = where(data.exLwn490 GT 0.,cnt)
		end

		'exLwn510': begin
			variable = 'Lw510'
			wh = where(data.exLwn510 GT 0.,cnt)
		end

		'exLwn531': begin
			variable = 'Lw531'
			wh = where(data.exLwn531 GT 0.,cnt)
		end

		'exLwn555': begin
			variable = 'Lw555'
			wh = where(data.exLwn555 GT 0.,cnt)
		end

		'exLwn620': begin
			variable = 'Lw620'
			wh = where(data.exLwn620 GT 0.,cnt)
		end

		'exLwn670': begin
			variable = 'Lw670'
			wh = where(data.exLwn670 GT 0.,cnt)
		end

		'exLwn681': begin
			variable = 'Lw681'
			wh = where(data.exLwn681 GT 0.,cnt)
		end

		'exLwn709': begin
			variable = 'Lw709'
			wh = where(data.exLwn709 GT 0.,cnt)
		end
		else : begin
			print,'Can not understandd PARAM'
			retall
		endelse
	endcase

 	tek_color
   ;++PS UTILITY
   SET_PLOT, 'PS'
   psFileName=DIALOG_PICKFILE(FILTER=['*.ps','*.eps'],/WRITE,Title='Please Enter EPS File Name.')
   DEVICE, /COLOR,/ENCAPSUL,xSize=23,ySize=12,BITS_PER_PIXEL=8,FILENAME=psFileName

	Lat_Names=['60N','30N','EQ','30S','60S']
	n_Lats=[60,30,0,-30,-60]
	Lon_Names=['150W','120W','90W','60W','30W','0','30E','60E','90E','120E','150E']
	n_Lons=[-150,-120,-90,-60,-30,0,30,60,90,120,150]

	MAP_SET,0.,0.,LIMIT=[-90.,-180.,90.,180.],/ISO, XMargin=[0,0],YMargin=[2,2],/NOBORDER,/CLIP
	MAP_GRID,/BOX_AXES,COLOR=0,LATDEL=30.,LONDEL=30.,/NO_GRID,LATNAMES=Lat_Names,LATS=n_Lats,LONNAMES=Lon_Names,LONS=n_Lons,CHARTHICK=2.;,GLINESTYLE=1,CHARSIZE=1
	MAP_CONTINENTS,/COAST, FILL_CONTINENTS=1,COLOR=15


	if(cnt GT 0) then begin
		plots,data.LONGITUDE(wh),data.LATITUDE(wh),psym=symcat(16),color=2,symsize=.4
	endif


	;XYOUTS,[-165,-165],[-61,-71],$
  ;     ['ALL PRODUCTS [N:'+string(cnt,format='(I3)')+']','T865 (AERONET) [N:'+string(n_aot,format='(I3)')+']'],charthick=1.5
	XYOUTS,0,84,db+' : '+variable,ALIGNMENT=0.5,CHARSIZE=1.0,charthick=1.5
	XYOUTS,180,84,'N='+string(cnt,format='(I5)'),ALIGNMENT=1.,CHARSIZE=1.0,charthick=1.5,color=2
	XYOUTS,180,-89,'GlobColour, UoP.',ALIGNMENT=1.,CHARSIZE=0.8,charthick=2

	DEVICE, /CLOSE
	SET_PLOT, 'win'
	!p.font=1

END