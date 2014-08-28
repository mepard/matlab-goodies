function y = kurtosis_dBG(x)
%------------------------------------------------------------------------------
y =10*log10 (kurtosis_KG(x));
return
%------------------------------------------------------------------------------
% TEST
clear all,  clf reset
x = randn(1,1e6);  y = kurtosis_dBG(x)
