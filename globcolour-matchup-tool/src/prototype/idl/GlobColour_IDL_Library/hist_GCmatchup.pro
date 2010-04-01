PRO hist_GCmatchup


	nb=20
	swf_file=dialog_pickfile(/read,title='Please Select SeaWiFS Average File',get_path=cwd)
	cd,cwd
	mod_file=dialog_pickfile(/read,title='Please Select MODISA Average File')
	mer_file=dialog_pickfile(/read,title='Please Select MERIS Average File')

	swf_data=read_ascii(swf_file,template=get_avg_template())
	mod_data=read_ascii(mod_file,template=get_avg_template())
	mer_data=read_ascii(mer_file,template=get_avg_template())


;---------------------------------------------
;+Set device as postscript for plotting [3col, 5rows]
    SET_PLOT, 'PS'
    psFileName='Histogram.eps'
    DEVICE, /COLOR,/ENCAPSUL,xSize=24.,ySize=20,BITS_PER_PIXEL=8,FILENAME=psFileName
    !P.MULTI = [0, 3, 3]
;-Set device as postscript for plotting [3col, 5rows]
;---------------------------------------------

	;[chlin,chlsat, kdin,kdsat, t865in,t865sat, l412inm,l412sat, l443in,l443sat, l490in,l490sat, l510in,l510sat, l555in,l555sat, l670in,l670sat]
	cols=[7,24, 9,26, 13,30, 14,31, 15,32, 16,33, 17,34, 19,36, 21,38]
	xtit=['log!d10!n(Chl-a)','log!d10!n(Kd490)','log!d10!n(T865)', 'log!d10!n(L412)','log!d10!n(L443)','log!d10!n(L490)','log!d10!n(L510)','log!d10!n(L555)','log!d10!n(L670)']

	!p.thick=3
	!p.charthick=2
	tek_color
	for k=0,17,2 do begin

		;wh_in=where(,nin)
		wh_sw=where((swf_data.(cols[k]) GT 0.) and (swf_data.(cols[k+1]) GT 0.), nsw)
		wh_mo=where((mod_data.(cols[k]) GT 0.) and (mod_data.(cols[k+1]) GT 0.), nmo)
		wh_me=where((mer_data.(cols[k]) GT 0.) and (mer_data.(cols[k+1]) GT 0.), nme)


		if (nsw GT 0) then begin
			swin_id=swf_data.(0)[wh_sw]
			swin_data=alog10(swf_data.(cols[k])[wh_sw])
			sw_data=alog10(swf_data.(cols[k+1])[wh_sw])
			hist_swin_data=histogram(swin_data,min=min(swin_data),max=max(swin_data),nbins=nb, location=swin_x)
			hist_sw_data=histogram(sw_data,min=min(swin_data),max=max(swin_data),nbins=nb, location=sw_x)
		endif
		if (nmo GT 0) then begin
			moin_id=mod_data.(0)[wh_mo]
			moin_data=alog10(mod_data.(cols[k])[wh_mo])
			mo_data=alog10(mod_data.(cols[k+1])[wh_mo])
			hist_moin_data=histogram(moin_data,min=min(swin_data),max=max(swin_data),nbins=nb, location=moin_x)
			hist_mo_data=histogram(mo_data,min=min(swin_data),max=max(swin_data),nbins=nb, location=mo_x)
		endif
		if (nme GT 0) then begin
			mein_id=mer_data.(0)[wh_me]
			mein_data=alog10(mer_data.(cols[k])[wh_me])
			me_data=alog10(mer_data.(cols[k+1])[wh_me])
			hist_mein_data=histogram(mein_data,min=min(swin_data),max=max(swin_data),nbins=nb, location=mein_x)
			hist_me_data=histogram(me_data,min=min(swin_data),max=max(swin_data),nbins=nb, location=me_x)
		endif

		ymax=max([hist_swin_data,hist_sw_data,hist_mo_data,hist_me_data])

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		nmer=n_elements(mein_id)
		moidx=(swidx=-1)
		for c=0,nmer-1 do begin
			mome=where(strcmp(moin_id,mein_id(c)),nc)
			if(nc GT 0) then moidx=[moidx,mome]
			swme=where(strcmp(swin_id,mein_id(c)),nc)
			if(nc GT 0) then swidx=[swidx,swme]
		endfor

		cmome=moin_id(moidx[1:*])
		cswme=swin_id(swidx[1:*])
		nmome=n_elements(cmome)
		swmomeidx=-1
		for c=0,nmome-1 do begin
			swmome=where(strcmp(cswme,cmome(c)),nc)
			if(nc GT 0) then swmomeidx=[swmomeidx,swmome]
		endfor
		cid=cswme(swmomeidx[1:*])
		cid=cid[uniq(cid,sort(cid))]

		stop
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;Plot In-situ/SeaWiFS data
			plot,swin_x,hist_swin_data,psym=10,xtitle=xtit(k/2),ytitle='Frequency',$
					yrange=[0,ymax],charsize=2,xmargin=[8,3],linestyle=1,$
					xticks=4,xtick_get=xtg
			;oplot,swin_x,hist_swin_data,psym=10;,xtickname=string(10.^xtg,format='(F4.2)');, xtitle=xtit(k/2),ytitle='Frequency',$
					;yrange=[0,ymax],charsize=2,xmargin=[8,2],linestyle=1;,$
					;xtickname=string(10.^swin_x,format='(F4.2)')
			oplot,sw_x,hist_sw_data,psym=10

;Plot In-situ/MODIS data
			if (nmo GT 0) then begin
				oplot,moin_x,hist_moin_data,psym=10,linestyle=1,color=2
				oplot,mo_x,hist_mo_data,psym=10,color=2
			endif

;Plot In-situ/MERIS data
			if (nme GT 0) then begin
				oplot,mein_x,hist_mein_data,psym=10,linestyle=1,color=4
				oplot,me_x,hist_me_data,psym=10,color=4
			endif

;Linear X-Axis Values
			axis,xaxis=1,charsize=1.5,xticks=n_elements(xtg)-1,xtickname=string(10.^xtg,format='(F7.3)'),/save

;Legends
			axis,yaxis=1, yrange=[0,1],CHARSIZE=1.5, ystyle=4,/save
			axis,xaxis=1, xrange=[0,1],CHARSIZE=1.5, xstyle=4,/save
			xyouts,[.98,.98,.98],[.9,.8,.7],['SWF','MOD','MER'],color=[0,2,4],alignment=1

	endfor


;-------------------------------------------------
    DEVICE, /CLOSE
    SET_PLOT, 'win'
    !P.MULTI = 0
 if(KEYWORD_SET(show)) then begin
    spawn,'gsview32 '+NEWDIR+separator+psFileName
 endif  ;if(KEYWORD_SET(show)) then begin
;-Plot Stat
;-------------------------------------------------
 PRINT,'FINISH.'
stop
END