PRO combo_stat, MODEL2=model2, MERGED=merged, SHOW=show

;Plot regression and histogram of combined list1 matchup data
;/SHOW display plots (gsview32 recommended)
;/MERGED to work with merged matchup combined data
;/MODEL2 compute Model-II (reduced major axis) regression parameters

;Last change: 08 Jul 2007 (YP)

	close,/all

	filDir=DIALOG_PICKFILE(/DIRECTORY,/Read,Title='Select GlobColour _combo File Path',get_path=cwd)
	cd,cwd
  SearchResult=FILE_SEARCH(filDir, '*_combo.csv', count=nFiles)
  if(nFiles GT 0) then comboFiles=SearchResult(sort(SearchResult)) else RETALL


;=======================================
;Configure Parameters
	if( keyword_set(merged) ) then Sensor=['AV','AVW','GSM'] else Sensor=['SeaWiFS','MODIS','MERIS']
	Param=['Chl1','Chl2','K490','CDM','TSM','T865','L412','L443','L490','L510','L531','L555','L620','L670','L681','L709']
	minV= [0.01,   0.01,  0.01, 0.0001, 0., -0.1,  -0.5,  -0.5,  -0.5,  -0.5,  -0.5,  -0.5,  -0.5,  -0.1,  -0.1,  -0.1];Plot min range
	maxV= [100.0,  100.0, 1.0,  1.0,   100., 0.8, 	4.0, 	 4.0, 	5.0,   5.0,   3.0,   5.0,   0.5,   1.0,   0.5,   0.5]	;Plot max range
	thre= [10.5,   10.5,  10.5, 1.0,   10.0, 0.7, 	1.5, 	 1.5,   1.5,   1.5,   1.5,   1.5,   1.5,   1.0,   1.0,   1.0] 	;filter threshold
	inMax= [105.0, 105.0,   10.0, 10.0,  10.0, 10.0, 	10.0,  10.0,  10.0,  10.0,  10.0,  10.0,  10.0,  10.0,  10.0,  10.0] 	;Maximum in-situ cut-off
	;Param=['Chl1','K490','T865','L412','L443','L490','L510','L555','L670']
	;minV=[0.01, 0.01, -0.1, -0.5, -0.5, -0.5, -0.5, -0.5, -.1];Plot min range
	;maxV=[100.0, 1.0, 0.8, 4.0, 4.0, 5.0, 5.0, 5.0, 1.0]	;Plot max range
	;thre=[0.5,   0.5, 0.7, 1.5, 1.5, 1.5, 1.5, 1.5, 1.0] 	;filter threshold
	;thre=[10.5,   10.5, 0.7, 1.5, 1.5, 1.5, 1.5, 1.5, 1.0] 	;filter threshold
	nbin=15	;Histogram bins

;=======================================

	openw,1,'CharacterisationSummary.csv'
	printf,1,'Parameter,Sensor,N,Slope,Intercept,r^2,MeanRatio,MedianRatio,RatioSQR,Mean%Diff,Median%Diff,Bias,RMS,In-situRange,,SatelliteRange,'


	if(nFiles GT 0) then begin

		for p=0,n_elements(Param)-1 do begin

			set_plot, 'PS'
    	psFileName=Param(p)+'.eps'
    	device, /color,/encapsul,xSize=24.,ySize=21,BITS_PER_PIXEL=8,FILENAME=psFileName
    	!P.MULTI = [0, 3, 3, 0, 1]
    	!P.CHARSIZE=2
    	tek_color

			for s=0,n_elements(Sensor)-1 do begin
				wh=(where(STREGEX(comboFiles,Sensor(s)) NE -1 and STREGEX(comboFiles,Param(p)) NE -1, nF))

   			if(nF GT 0) then begin

   				files=comboFiles(wh)
   				print,Sensor(s)
   				print,files

   				data=read_ascii(files(0),template=get_gclist1_template())

   				threshold= abs((data.satValue-data.inValue)/(data.satValue+data.inValue))
   				wh = where(threshold LT thre(p) and data.inValue LE inMax(p), nwh)

   				if (nwh GT 2) then begin
   					insitu	=	(data.inValue)[wh]
   					sat 		=	(data.satValue)[wh]
   					PixStd 	=	(data.PixStd)[wh]

;Compute Stats
						if( strcmp(Param(p),'Chl1',/fold_case) or strcmp(Param(p),'K490',/fold_case) or strcmp(Param(p),'Chl2',/fold_case) ) then begin
							if(keyword_set(model2)) then fit = [RMAFIT(alog10(insitu),alog10(sat)), (CORRELATE(alog10(insitu),alog10(sat),/DOUBLE))^2.] else $
							fit = [LINFIT(alog10(insitu),alog10(sat)), (CORRELATE(alog10(insitu),alog10(sat),/DOUBLE))^2.] ;log-transformed fit for Chl and Kd490

       				rms = sqrt(mean(alog10(sat/insitu)^2.))   ;Relative RMS
       				bias = mean(alog10(sat/insitu))   ;Relative bias
       			endif else begin
       				if(keyword_set(model2)) then fit = [RMAFIT(insitu,sat), (CORRELATE(insitu,sat,/DOUBLE))^2.] else $
       				fit = [LINFIT(insitu,sat), (CORRELATE(insitu,sat,/DOUBLE))^2.]

       				rms = sqrt(mean((sat-insitu)^2.))    ;RMS
       				bias = mean(sat-insitu)          	;BIAS
       			endelse
       			avgratio = mean(sat/insitu)   ;Mean Ratio
       			medratio = median(sat/insitu)    ;Median Ratio
						pd = ((sat-insitu)/insitu)*100.; Percent difference
       			avgpd = mean(abs(pd))   ;Mean absolute % diff
       			medpd = median(abs(pd)) ;Median absolute % diff
       			range_insitu = [min(insitu),max(insitu)]    ;in-situ range
       			range_sat = [min(sat),max(sat)]    ;Satellite range
       			pctlratio = percentiles(sat/insitu)	;percentiles of satellite to in-situ ratio
       			sqr = (pctlratio[3]-pctlratio[1])/2. ;Semi Quartile Ratio

       			printf,1,Param(p),Sensor(s),nwh,fit(1),fit(0),fit(2),avgratio,medratio,sqr,avgpd,medpd,bias,rms,range_insitu,range_sat,$
       						format='(2(A,","),I,",",13(f,","),f)'
;--------------------------------------------------------
						plot_legend=['N','r!u2!n','RMS','BIAS','SLOPE','OFFSET']
						stat=[nwh,fit(2),rms,bias,fit(1),fit(0)]
						fmt=['(I4)','(f5.2)','(f5.2)','(f5.2)','(f5.2)','(f5.2)']

;Prepare data for histogram plot
						hist_insitu	= histogram(alog10(insitu), min=min(alog10([insitu,sat])), max=max(alog10([insitu,sat])), nbins=nbin, location=x_insitu)
						hist_sat	= histogram(alog10(sat), min=min(alog10([insitu,sat])), max=max(alog10([insitu,sat])), nbins=nbin, location=x_sat)
						ymax=max([hist_insitu,hist_sat])

;Prepare data for percent difference histogram plot
						hist_pd	= histogram(pd, min=-100., max=100., nbins=21, location=x_pd)
						pct_hist_pd = (hist_pd/total(hist_pd))*100.

;-------------------------------------------


;Scatter plot
						if( strcmp(Param(p),'Chl1',/fold_case) or strcmp(Param(p),'K490',/fold_case) or strcmp(Param(p),'Chl2',/fold_case) ) then begin
							plot,	insitu,sat,psym=symcat(16),symsize=0.6,/xlog,/ylog,/iso,xrange=[minV(p),maxV(p)],yrange=[minV(p),maxV(p)],xstyle=1,ystyle=1,$
									title=Param(p),xtitle='!8in situ!5',ytitle=Sensor(s),charthick=2
							errplot,insitu,sat-PixStd,sat+PixStd,width=0,color=4
							oplot,[minV(p),maxV(p)],[minV(p),maxV(p)]
   					endif else begin
   						plot,	insitu,sat,psym=symcat(16),symsize=0.7,/iso,xrange=[minV(p),maxV(p)],yrange=[minV(p),maxV(p)],xstyle=1,ystyle=1,$
									title=Param(p),xtitle='!8in situ!5',ytitle=Sensor(s),charthick=2
							errplot,insitu,sat-PixStd,sat+PixStd,width=0,color=4
							oplot,[minV(p),maxV(p)],[minV(p),maxV(p)]
   					endelse
;Legend
						axis, xaxis=1, xrange=[0,1], xlog=0, xst=4, /save
  					axis, yaxis=1, yrange=[1,0], ylog=0, yst=4, /save
  					for x=0,5 do xyouts,0.98,(x+4.5)/10.,plot_legend(x)+string(stat(x),format=fmt(x)),charsize=0.8,alignment=1,charthick=2

;------------------

;Histogram Plot (1)
						plot,x_insitu,hist_insitu,psym=10,xtitle=Param(p),ytitle='Frequency',yrange=[0,ymax],linestyle=3,thick=2.5,xticks=4,$
									xtick_get=xtg,xtickformat='(A1)',charthick=2,xmargin=[10,4]
						oplot,x_sat,hist_sat,psym=10,linestyle=0,thick=2.5
						axis, xaxis=0,xticks=n_elements(xtg)-1,xtickname=string(10.^xtg,format='(f7.3)'),charthick=2,charsize=1.5,/save
;Legend
						axis, xaxis=1, xrange=[0,1], xlog=0, xst=4, /save
  					axis, yaxis=1, yrange=[0,1], ylog=0, yst=4, /save
  					plots,[0.02,0.12],[0.9,0.9],linestyle=3,thick=2.5;in-situ
  					plots,[0.02,0.12],[0.8,0.8],linestyle=0,thick=2.5;satellite
  					xyouts,[0.14,0.14],[.9,.8],['!8in situ!5',Sensor(s)],charsize=0.8,charthick=2


;Histogram Plot (2 Pecent difference)
						plot,x_pd,pct_hist_pd,psym=10,xtitle='% Difference : '+Param(p),ytitle='Frequency (%)',thick=2.5, charthick=2,xmargin=[10,4]
;Legend
						;axis, xaxis=1, xrange=[0,1], xlog=0, xst=4, /save
  					;axis, yaxis=1, yrange=[0,1], ylog=0, yst=4, /save
  					;plots,[0.02,0.12],[0.9,0.9],linestyle=3,thick=2.5;in-situ
  					;plots,[0.02,0.12],[0.8,0.8],linestyle=0,thick=2.5;satellite
  					;xyouts,[0.14,0.14],[.9,.8],['!8in situ!5',Sensor(s)],charsize=0.8,charthick=2

;--------------


   				endif

				endif	;if(nF GT 0) then begin

			endfor	;for s=0,n_elements(Sensor)-1 do begin
			if(KEYWORD_SET(show)) then spawn,'gsview32 '+psFileName
		endfor		;for p=0,n_elements(Param)-1 do begin

		close,1
		device, /close
    set_plot, 'win'
    !P.MULTI = 0




	endif				;if(nFiles GT 0) then begin

	print,string(10b)+'FINISH.';stop

END