function m = MeanAngles (angles)
	m = angle(sum(exp(1i*angles)) / length(angles));
end
