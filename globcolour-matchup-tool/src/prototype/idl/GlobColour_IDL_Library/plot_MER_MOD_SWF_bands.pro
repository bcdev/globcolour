PRO plot_MER_MOD_SWF_bands

	device,decomposed=0
	colors=fsc_color(['Blue Violet','Blue','Turquoise','Sea Green','Lime Green','Green','Yellow','Orange Red','Red','Dark Red','Gray'])
;nominal central wavelength and bandwidth (nm)
	meris_cw = [412.5, 442.5, 490.0, 510.0, 560.0, 620.0, 665.0, 681.0, 709.0]
	meris_bw = [10.00, 10.00, 10.00, 10.00, 10.00, 10.00, 10.00, 07.00, 09.00 ]
	meris_color=colors([0,1,2,3,5,6,7,8,9])
	print,meris_color

	modis_cw = [412.5, 442.5, 488.0, 531.0, 551.0, 667.0];, 678.0]
	modis_bw = [15.00, 10.00, 10.00, 10.00, 10.00, 10.00];, 10.00]
	modis_color=colors([0,1,2,4,5,7]);,7])

	swifs_cw = [412.0, 443.0, 490.0, 510.0, 555.0, 670.0]
	swifs_bw = [20.00, 20.00, 20.00, 20.00, 20.00, 20.00]
	swifs_color=colors([0,1,2,3,5,7])

	globcolour_cw = [412.0, 443.0, 490.0, 510.0, 555.0, 670.0]



	set_plot, 'PS'
  	psFileName='Test.eps'
   	device, /color,/encapsul,xSize=32.,ySize=10,BITS_PER_PIXEL=8,FILENAME=psFileName
   	!P.CHARSIZE=1.5
   	!p.charthick=2

   	;tek_color

		plot,[380,780],[0,2.9],/nodata, xst=1, yst=5, xtitle='wavelength [nm]', xmargin=[2,2]
		for i=0,n_elements(globcolour_cw)-1 do begin
			oplot,([[globcolour_cw],[globcolour_cw]])(i,*),[0,3],thick=20,color=colors(10)
		endfor

		for i=0,n_elements(meris_cw)-1 do begin
			oplot,([[meris_cw-meris_bw],[meris_cw-meris_bw],[meris_cw+meris_bw],[meris_cw+meris_bw],[meris_cw-meris_bw]])(i,*),[0.2,.9,.9,.2,.2],thick=5,color=meris_color(i)
			xyouts, meris_cw(i),0.5,string(meris_cw(i),format='(f5.1)'),alignment=0.5,orientation=45, charsize=1.2
		endfor

		for i=0,n_elements(modis_cw)-1 do begin
			oplot,([[modis_cw-modis_bw],[modis_cw-modis_bw],[modis_cw+modis_bw],[modis_cw+modis_bw],[modis_cw-modis_bw]])(i,*),[1.1,1.8,1.8,1.1,1.1],thick=5,color=modis_color(i)
			xyouts, modis_cw(i),1.4,string(modis_cw(i),format='(f5.1)'),alignment=0.5,orientation=45, charsize=1.2
		endfor

		for i=0,n_elements(swifs_cw)-1 do begin
			oplot,([[swifs_cw-swifs_bw],[swifs_cw-swifs_bw],[swifs_cw+swifs_bw],[swifs_cw+swifs_bw],[swifs_cw-swifs_bw]])(i,*),[2.,2.7,2.7,2.,2.],thick=5,color=swifs_color(i)
			xyouts, swifs_cw(i),2.3,string(swifs_cw(i),format='(f5.1)'),alignment=0.5,orientation=45, charsize=1.2
		endfor
		xyouts,[780.,780.,780.],[0.5,1.4,2.3],['MERIS  ','MODIS/A  ','SeaWiFS  '],alignment=1
		oplot,[380,380,!values.f_nan,780,780],[0,3,!values.f_nan,0,3]



	device, /close
  set_plot, 'win'

	spawn,'gsview32 Test.eps'




END