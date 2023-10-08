% Embed via LSFR

function tc=EmbedLSFR(tc, msg, seed, taps)

covert_len = length(msg);
ctr = 1;
sr = seed;

% INJECT
k = 1;

for n=1:length(tc)
    while ctr <= covert_len && k <= length(tc)
        for b=1:length(tc{k})
            [next, sr] = GetNextLSFRState(sr, taps);

            if next == 1
                tc{k}(b) = msg(ctr);
                ctr = ctr + 1;
            end
    
            if ctr > covert_len
                break
            end
        end
    
        k = k + 1;
    end
end
