% N Bit Skip

function tc=EmbedNBitSkip(tc, covert_msg, p, start)

% Covert vars
covert_len = length(covert_msg);
ctr = 1;

% INJECT
k = 1;

for n=1:length(tc)
    while ctr <= covert_len && k <= length(tc)
        for b=start:p:length(tc{k})
            tc{k}(b) = covert_msg(ctr);
            ctr = ctr + 1;
    
            if ctr > covert_len
                break
            end
        end
    
        k = k + 1;
    end
end