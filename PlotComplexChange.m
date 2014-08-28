function PlotComplexChange (name, before, after)
	CascadeFigure(figure('name', name));
	
	zoom on
	s1 = subplot(2,1,1);
	
	hold on
	
	plot(real(before), 'b.-')
	plot(real(after), 'c.-')

	legend('real(before)', 'real(after)')
	
	grid on
	
	s2 = subplot(2,1,2);
	
	hold on

	plot(imag(before), 'r.-')
	plot(imag(after), 'm.-')

	legend('imag(before)', 'imag(after)')

	grid on
	
	linkaxes ([s1 s2],'x');
end

