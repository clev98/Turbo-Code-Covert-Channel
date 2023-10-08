% Retrieve N Bit Skip

function msg=GetMsgNBitSkip(tc, msg_len, p, start)

msg = zeros(1, msg_len);
ctr = 1;

for n=1:length(tc)
    % Get Message
    k = 1;

    while ctr <= msg_len && k <= length(tc)
        for b=start:p:length(tc{k})
            if tc{k}(b) <= 0
                msg(ctr) = 0;
            else
                msg(ctr) = 1;
            end

            ctr = ctr + 1;

            if ctr > msg_len
                break
            end
        end

        k = k + 1;
    end
end