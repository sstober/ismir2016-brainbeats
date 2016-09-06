function [ mat_peakVal, mat_peakIdx ] = pickPeaks( x, N, tau )
%pickPeaks pick N max peaks 
%   x   : input data
%   N   : number of peaks to pick
%   tau : indices to exclude around a detected peak before detecting the
%         next one

% exclude tau values left and right after each detected peak
if nargin < 3
    tau = 5;
end
if nargin < 2
    N = 1; 
end

mat_peakVal = zeros(1,N);
mat_peakIdx = zeros(1,N);

for i = 1:N
    % detect max peak
    [ mat_peakVal(i), mat_peakIdx(i) ] = max( x );

    % exclude neighborhood around max peak
    x( max(1,(mat_peakIdx(i)-tau)) : min( mat_peakIdx(i)+tau, length(x) ) ) = 0;
end

