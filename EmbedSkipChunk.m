% Skip Parity

function tc=EmbedSkipChunk(tc, covert_msg, p, skip)

% Covert vars
covert_len = length(covert_msg);
ctr = 1;

% INJECT
k = 1;

for n=1:length(tc)
    while ctr <= covert_len && k <= length(tc)
        for b=1:p:length(tc{k})
            if b >= skip{1} && b <= skip{2}
                continue
            end

            tc{k}(b) = covert_msg(ctr);
            ctr = ctr + 1;
    
            if ctr > covert_len
                break
            end
        end
    
        k = k + 1;
    end
end