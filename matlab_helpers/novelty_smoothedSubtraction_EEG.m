function [noveltySub,local_average] = novelty_smoothedSubtraction_EEG(noveltyCurve,parameter)
if nargin < 2
    parameter = [];
end
if ~isfield( parameter, 'fs')
    parameter.fs = 512;
end
if ~isfield( parameter, 'smooth_len')
    parameter.smooth_len = 1; % in seconds
end

myhann = @(n)  0.5-0.5*cos(2*pi*((0:n-1)'/(n-1)));
smooth_len = parameter.fs * parameter.smooth_len;

smooth_filter = myhann(smooth_len);
smooth_filter = smooth_filter(:)';
local_average = filter2(smooth_filter./sum(smooth_filter),noveltyCurve);

noveltySub = (noveltyCurve-local_average);
% noveltySub = (noveltySub>0).*noveltySub;
end