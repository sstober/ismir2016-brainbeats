function [ mat_errorRate ] = compute_bpmErrorRate( mat_beatError, mat_tresh )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: audio_to_noveltyCurve
% Date of Revision: 
% Programmer: Thomas Praetzlich
% 
% Description:
%       Compute BPM error rates from absolute BPM errors.
%
% Input:
%       mat_beatError: matrix containing beat errors
%       mat_tresh: vector containing threshold
%           
%
% Output:
%       mat_errorRate: BPM error rates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mat_errorRate = zeros(size( mat_tresh ));
for t = 1:length(mat_tresh)
    tau = mat_tresh(t);
%     fprintf('(<=%d beats): ',tau)
    mat_errorRate(t) = 1-sum( mat_beatError(:) <= tau ) / numel(  mat_beatError );
%     fprintf('%4.1f%%\n',100*mat_errorRate(t));
end

end

