function results = protocol_aware_uc(params, seed)
%PROTOCOL_AWARE_UC Manuscript-facing wrapper for the proposed protocol.
%
% The protocol was first developed under the working filename
% protocol_aert_uc.m. The research manuscript uses the clearer name
% AWARE-UC: Availability and Weighted-energy Adaptive Routing with Uneven
% Clustering. This wrapper keeps naming consistent without breaking older
% scripts.

results = protocol_aert_uc(params, seed);
results.protocol = 'AWARE_UC';
end
