function cdf = PDFtoCDF (sigmas, pdf)
	cdf = cumtrapz(sigmas, pdf);
end
