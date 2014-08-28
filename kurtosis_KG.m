function y = kurtosis_KG(x)
%------------------------------------------------------------------------------
x_ = x-mean(x);
if x_ == 0
    y = 1;
else
    y = ( mean(x_.^4) ) / ( mean(x_.^2)^2 ) / 3;
end
return
%------------------------------------------------------------------------------
% TEST
clear all,  clf reset
x = randn(1,1e6);  y = kurtosis_KG(x)
