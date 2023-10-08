% Poor Man's LFSR

function [next, sr]=GetNextLSFRState(sr, taps)

% Get LSFR Output
xor = 0;

for t=1:length(taps)
    xor = xor + sr(taps(t) + 1);
end

if mod(xor, 2) == 0
    xor = 0;
else
    xor = 1;
end

next = xor;
sr = [xor sr(1:end - 1)];