% Get Covert Message LSFR

function msg=GetMsgLSFR(tc, msg_len, seed, taps)

sr = seed;
msg = zeros(1, msg_len);
ctr = 1;

for n=1:length(tc)
    % Get Message
    k = 1;

    while ctr <= msg_len && k <= length(tc)
        for b=1:length(tc{k})
            [next, sr] = GetNextLSFRState(sr, taps);

            if next == 1
                if tc{k}(b) <= 0
                    msg(ctr) = 0;
                else
                    msg(ctr) = 1;
                end
    
                ctr = ctr + 1;
            end

            if ctr > msg_len
                break
            end
        end

        k = k + 1;
    end
end