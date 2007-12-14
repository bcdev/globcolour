FUNCTION NORMALISE, data, $
				 BOXCOX=BoxCox,$
				 MANLY=Manly, $
				 JOHNDRAPER=JohnDraper, $
				 YEOJOHNSON=YeoJohnson, $
				 TEST=test, DIAG=diag, $
				 GET_LAMBDA=opt_lambda


;+
;NAME:
; NORMALISE (use of 's' in normalise is intentional);
;		Note: This is different to David Fanning's NORMALIZE function which is used to calculate the scaling vector
; 	 required to position a graphics primitive of specified range
;    at a specific position in an arbitray coordinate system.

;PURPOSE:
; Normalise a skewed data series using four different power transformation methods:
;	1. Box and Cox (1964) (defaul method)
;	2. Manly (1971)
;	3. John and Draper (1980) and
; 4. Yeo and Johnson (2000)

;SYNTAX:
; Result = NORMALISE (Data | /TEST [,/BOXCOX | ,/MANLY | ,/JOHNDRAPER | ,/YEOJOHNSON] [,/DIAG] [,GET_LAMBDA=variable] )

;INPUTS:
; data: 1D array of any type except string

;OUTPUTS:
; Normalised data series

;KEYWORDS:
;	test:	demonstarte the model using test dataset within this routine
;	BoxCox: Applies calssical BoxCox (1964) power transformation (default method)
;	Manly: Applies transformation approach by Manly (1971)
; JohnDraper: Applies transformation approach by John and Draper (1980)
; YeoJohnson: Applies transformation approach by Yeo and Johnson (2000)
; diag: Diagnose the data using plots
;	get_lambda: a named variable to store optimised lambda

;EXTERNAL FUNCTIONS:
;	PPOINTS()


;EXAMPLE:
;IDL> print, normalise(/test)
;			"Box-Cox" OPT_LAMBDA and R^2 :     -0.080000000      0.85758678
;			3.9301628       3.9658661       4.0420698       4.0265000 ...
;			...
;			... 4.9065189       4.8473132       4.7442314       4.8074325

;REFERENCE:
;	As above

;	$Id: NORMALISE.pro,v 1.0 15/05/2007 19:25:13 yaswant Exp $
; NORMALISE.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;	Yaswant.Pradhan@plymouth.ac.uk
;-


	if( n_params() lt 1 and ~keyword_set(test) ) then $
	stop,'Syntax: result = NORMALISE(Data | /TEST [,/BOXCOX | ,/MANLY | ,/JOHNDRAPER | ,/YEOJOHNSON] [,/DIAG] [,GET_LAMBDA=variable] )'


;----------------------------
;Global parameters/constants
	default_method='Box-Cox'
	offset = 0.01
	n_lambda = 601	;max number of lambda iteration
	n_half = floor(n_lambda/2); lambda = (0:n_lambda - n_half) / 100
;----------------------------


;----------------------------------------
;test dataset
	if keyword_set(test) then begin
		data = [112, 118, 132, 129, 121, 135, 148, 148, 136, 119, 104, 118, $
						115, 126, 141, 135, 125, 149, 170, 170, 158, 133, 114, 140, $
						145, 150, 178, 163, 172, 178, 199, 199, 184, 162, 146, 166, $
						171, 180, 193, 181, 183, 218, 230, 242, 209, 191, 172, 194, $
						196, 196, 236, 235, 229, 243, 264, 272, 237, 211, 180, 201, $
						204, 188, 235, 227, 234, 264, 302, 293, 259, 229, 203, 229, $
						242, 233, 267, 269, 270, 315, 364, 347, 312, 274, 237, 278, $
						284, 277, 317, 313, 318, 374, 413, 405, 355, 306, 271, 306, $
						315, 301, 356, 348, 355, 422, 465, 467, 404, 347, 305, 336, $
						340, 318, 362, 348, 363, 435, 491, 505, 404, 359, 310, 337, $
						360, 342, 406, 396, 420, 472, 548, 559, 463, 407, 362, 405, $
						417, 391, 419, 461, 472, 535, 622, 606, 508, 461, 390, 432]

		lines = n_elements(data)
	endif	;if keyword_set(test) then begin
;----------------------------------------

	lines=n_elements(data)

	lambda =( corr = dblarr(n_lambda) )

	points = ppoints(lines)	;probability points between 0. and 1., exclusive
	qnorm = dblarr(lines)
	for p=0,lines-1 do qnorm(p) = gauss_cvf(points(p))	;generate normally distributed data, 0 mean 1 variance (use normal quantile function)


;;;;+DIAG;;;;
	show_plot = 0b
	if keyword_set(diag) then begin
		show_plot = 1b
		device,decomposed=0
		!p.background='ffffff'x
		!p.color='000000'x
		!p.multi=[0,3,2]
		!p.charsize=2.
		window,1,xs=750,ys=450, title='Normalise',xpos=0,ypos=0

		plot, data, psym=4, title='Original data', xtitle='Sequence',ytitle='Value'
		hist_data=histogram(data,min=min(data),max=max(data),nbins=12, location=x)
		plot,x,hist_data,psym=10, title='Histogram of Original data', xtitle='X',ytitle='frequency'
	endif
;;;;-DIAG;;;;




;[1];;;+BOX-COX (Default);;;; Box and Cox (1964)
	if ~( keyword_set(BoxCox) or keyword_set(Manly) or keyword_set(JohnDraper) or keyword_set(YeoJohnson) ) then begin
	method='Box-Cox'
;if -ve values are present in the data
		if(min(data) lt 0.) then begin
			print,'WARNING! -ve values found in the data, an offset of (min + offset) will be added to the data'
			data = data + min(data) + offset
		endif


;find lambda corresponding to the max-correlation iteratively
		max_corr =( opt_lambda = 0.0 )
		for i=0,n_lambda-1 do begin
			lambda(i) = (i-n_half)/100.0D
			if( lambda(i) ne 0. ) then trans_data = (data^lambda(i) - 1.)/lambda(i) $
			else trans_data = alog(data)
			corr(i) = correlate(qnorm, trans_data)^2.
			if( corr(i) gt max_corr) then begin
				max_corr = corr(i)
				opt_lambda = lambda(i)
			endif	;if( corr gt max_corr) then begin
		endfor	;for i=0,n_lambda-1 do begin


;calculate transformed data for optimal lambda
		print, '"Box-Cox" OPT_LAMBDA and R^2 : ', opt_lambda, max_corr
		if ( opt_lambda ne 0. ) then opt_trans_data = (data^opt_lambda - 1.)/opt_lambda $
		else opt_trans_data = alog(data)

	endif	;if ~( keyword_set(BoxCox) or keyword_set(Manly) or keyword_set(JohnDraper) or keyword_set(YeoJohnson) ) then begin
;;;;-BOX-COX (Default);;;




;[2];;;+MANLY;;;; Manly (1971)
	if ( keyword_set(Manly) or strcmp(default_method,'Manly',/fold_case) ) then begin
	method='Manly'
;find lambda corresponding to the max-correlation iteratively
		max_corr =( opt_lambda = 0.0 )
		for i=0,n_lambda-1 do begin
			lambda(i) = (i-n_half)/100.0D
			if( lambda(i) ne 0. ) then trans_data = ( exp( data*lambda(i) ) - 1. ) / lambda(i) $
			else trans_data = data
			corr(i) = correlate(qnorm, trans_data)^2.
			if( corr(i) gt max_corr) then begin
				max_corr = corr(i)
				opt_lambda = lambda(i)
			endif	;if( corr gt max_corr) then begin
		endfor	;for i=0,n_lambda-1 do begin


;calculate transformed data for optimal lambda
		print, '"Manly" OPT_LAMBDA and R^2 : ', opt_lambda, max_corr
		if ( opt_lambda ne 0. ) then opt_trans_data = ( exp( data*opt_lambda ) - 1. ) / opt_lambda $
		else opt_trans_data = data

	endif	;if keyword_set(Manly) then begin
;;;;-MANLY;;;




;[3];;;+JOHNDRAPER;;;; John and Draper (1980)
	if ( keyword_set(JohnDraper) or strcmp(default_method,'John-Draper',/fold_case) ) then begin
	method='John-Draper'
;find lambda corresponding to the max-correlation iteratively
		max_corr =( opt_lambda = 0.0 )
		sign = dblarr(lines)
		neg = where(data lt 0., n_neg, complement=pos, ncomplement=n_pos)
		if(n_neg gt 0) then sign(neg) = (-1)
		if(n_pos gt 0) then sign(pos) = 1
		;sign=make_array(lines,value=-1)
		for i=0,n_lambda-1 do begin
			lambda(i) = (i-n_half)/100.0D
			if( lambda(i) ne 0. ) then trans_data = sign * ( ((abs(data)+1)^lambda(i)) - 1. ) / lambda(i) $
			else trans_data = sign * alog(abs(data)+1)
			corr(i) = correlate(qnorm, trans_data)^2.
			if( corr(i) gt max_corr) then begin
				max_corr = corr(i)
				opt_lambda = lambda(i)
			endif	;if( corr gt max_corr) then begin
		endfor	;for i=0,n_lambda-1 do begin


;calculate transformed data for optimal lambda
		print, '"John-Draper" OPT_LAMBDA and R^2 : ', opt_lambda, max_corr
		if ( opt_lambda ne 0. ) then opt_trans_data = sign * ( ((abs(data) + 1)^opt_lambda) - 1.0 ) / opt_lambda $
		else opt_trans_data = sign * alog(abs(data)+1)

	endif	;if keyword_set(JohnDraper) then begin
;;;;-JOHNDRAPER;;;



;[4];;;+YEOJOHNSON;;;; Yeo and Johnson (2000)
	if ( keyword_set(YeoJohnson) or strcmp(default_method,'Yeo-Johnson',/fold_case) ) then begin
	method='Yeo-Johnson'
;find lambda corresponding to the max-correlation iteratively
		max_corr =( opt_lambda = 0.0 )
		trans_data =( opt_trans_data= dblarr(lines) )

		for i=0,n_lambda-1 do begin
			lambda(i) = (i-n_half)/100.0D
			for k=0,lines-1 do begin
				if( (lambda(i) ne 0.) and (data(k) ge 0.) ) then trans_data(k) = ( ((data(k)+1.)^lambda(i)) - 1.0 ) / lambda(i) $
				else if( (lambda(i) eq 0.) and (data(k) ge 0.) ) then trans_data(k) = alog( data(k)+1. ) $
				else if( (lambda(i) ne 2.) and (data(k) lt 0.) ) then trans_data(k) = ( ((1.- data(k))^(2.-lambda(i))) - 1.0 ) / (lambda(i) - 2.) $
				else if( (lambda(i) eq 2.) and (data(k) lt 0.) ) then trans_data(k) = -( alog(1. - data(k)) ) $
				else trans_data(k) = data(k)
			endfor	;k=0,lines-1 do begin

			corr(i) = correlate(qnorm, trans_data)^2.
			if( corr(i) gt max_corr) then begin
				max_corr = corr(i)
				opt_lambda = lambda(i)
			endif	;if( corr gt max_corr) then begin
		endfor	;for i=0,n_lambda-1 do begin

;calculate transformed data for optimal lambda
		print, '"Yeo-Johnson" OPT_LAMBDA and R^2 : ', opt_lambda, max_corr
		for k=0,lines-1 do begin
				if( (opt_lambda ne 0.) and (data(k) ge 0.) ) then opt_trans_data(k) = ( ((data(k)+1.)^opt_lambda) - 1.0 ) / opt_lambda $
				else if( (opt_lambda eq 0.) and (data(k) ge 0.) ) then opt_trans_data(k) = alog( data(k)+1. ) $
				else if( (opt_lambda ne 2.) and (data(k) lt 0.) ) then opt_trans_data(k) = ( ((1.- data(k))^(2. - opt_lambda)) - 1.0 ) / (opt_lambda - 2.) $
				else if( (opt_lambda eq 2.) and (data(k) lt 0.) ) then opt_trans_data(k) = -( alog(1. - data(k)) ) $
				else opt_trans_data(k) = data(k)
			endfor

	endif	;if keyword_set(YeoJohnson) then begin
;;;;-YEOJOHNSON;;;



;;;;+DIAG;;;;
	if(show_plot) then begin
		plot, lambda, corr, psym=1, symsize=0.6, yst=1, title=method+'Normality plot', xtitle='lambda',ytitle='r!u2'
		oplot, [opt_lambda,opt_lambda],[0,1]

		hist_trans_data=histogram(opt_trans_data, nbins=12, location=trans_x)
		plot,trans_x,hist_trans_data,psym=10, title='Histogram of Transformed data', xtitle='t(X, lambda)',ytitle='frequency'

		plot,reverse(qnorm),data[sort(data)],psym=4, symsize=.5, yst=1, title='Normal Q-Q Plot', xtitle='Standard Normal Quantiles',ytitle='Ordered Original data'
		fit = linfit(reverse(qnorm),data[sort(data)],yfit=fit_data)
		oplot,reverse(qnorm),fit_data

		plot,reverse(qnorm),opt_trans_data[sort(opt_trans_data)],psym=4, symsize=.5, yst=1, title='Normal Q-Q Plot', xtitle='Standard Normal Quantiles',ytitle='Ordered Transformed data'
		fit = linfit(reverse(qnorm),opt_trans_data[sort(opt_trans_data)],yfit=fit_data)
		oplot,reverse(qnorm),fit_data

		!p.multi=0

	endif
;;;;-DIAG;;;;



	return,opt_trans_data

END