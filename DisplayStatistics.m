% Statistic Gen

classdef DisplayStatistics
    methods(Static)
        function [overtError, covertError, BER]=ConductChannel(p, l, offset, enb, pdsch, trBlk, nCodewords, TrBlkSizes, DownlinkMethod, UplinkMethod)
            msg = randi([0 1], 1, l);
            overtError = 0;
            
            % Modified Downlink
            [pdschsymbols, chs, BER] = ModifiedDownlink(enb, pdsch, trBlk, nCodewords, p, msg, offset, DownlinkMethod);
            % Channel Estimation
            
            % Uninformed Uplink
            [rxTrBlk, ~] = Uplink(enb, pdsch, chs, pdschsymbols, nCodewords, TrBlkSizes);
            % Informed Uplink
            decoded_msg = InformedUplink(enb, pdsch, pdschsymbols, nCodewords, l, p, offset, UplinkMethod);

            for n=1:nCodewords
                overtError = overtError + sum(trBlk{n} ~= rxTrBlk{n});
            end

            covertError = sum(msg ~= decoded_msg);
        end

        function GetStatisticsNBit(max_p, max_len, len_step, offset, enb, pdsch, trBlk, nCodewords, TrBlkSizes)
            % (p, l, overtError, covertError, BER)
            s = [];
            
            for p=1:max_p
                for l=100:len_step:max_len
                    [overtError, covertError, BER]=DisplayStatistics.ConductChannel(p, l, offset, enb, pdsch, trBlk, nCodewords, TrBlkSizes, @EmbedNBitSkip, @GetMsgNBitSkip);

                    s = [s; p l overtError, covertError, BER];
                end
            end

            % Max l by p value while keeping decoded overt error zero
            figure
            
            for p=1:max_p
                a = s(s(:,1) == p, :);
                a = a(a(:,3) == 0, :);
                [val, ~] = max(a(:, 2));


                plot(p, val, '*', 'linewidth', 2);
                hold on
            end

            title("Max Covert Message Length vs Skip Value")
            xlabel("Skip Value")
            ylabel("Max Covert Message Length")
            hold off

            % Growth of p and l vs growth in decoded overt error
            figure

            for p=1:max_p
                pnts = s(s(:,1) == p, :);

                for k=1:length(pnts)
                    plot3(pnts(k, 1), pnts(k, 2), pnts(k, 3), "o")
                    hold on
                end
            end

            title("Skip Value vs Message Length vs Overt Errors");
            xlabel("Skip Value");
            ylabel("Covert Message Length");
            zlabel("Overt Errors")
            hold off

            % Growth of p and l vs BER
            figure

            for p=1:max_p
                pnts = s(s(:,1) == p, :);

                for k=1:length(pnts)
                    plot(pnts(k, 2), pnts(k, 5), "o")
                    hold on
                end
            end

            title("Message Length vs BER");
            xlabel("Covert Message Length");
            ylabel("Bit Error Rate (BER)")
            hold off
        end

        function maxLen=GetStatisticsLSFR(seed, tap, max_len, len_step, enb, pdsch, trBlk, nCodewords, TrBlkSizes)
            % (l, overtError, covertError, BER)
            s = [];

            for l=100:len_step:max_len
                [overtError, covertError, BER]=DisplayStatistics.ConductChannel(seed, l, tap, enb, pdsch, trBlk, nCodewords, TrBlkSizes, @EmbedLSFR, @GetMsgLSFR);

                s = [s; l overtError, covertError, BER];
            end

            % Growth of l vs growth in decoded overt error
            figure

            for row=1:height(s)
                plot(s(row, 1), s(row, 2), "o")
                hold on
            end

            title("Covert Message Length vs Overt Error");
            xlabel("Covert Message Length");
            ylabel("Overt Error");
            hold off

            % Growth of p and l vs BER
            figure

            for row=1:height(s)
                plot(s(row, 1), s(row, 4), "o")
                hold on
            end

            title("Covert Message Length vs BER");
            xlabel("Covert Message Length");
            ylabel("Bit Error Rate (BER)")
            hold off

            a = s(s(:,2) == 0, :);
            [maxLen, ~] = max(a(:, 1));
        end

        function GetStatisticsChunk(max_p, max_len, len_step, offset, enb, pdsch, trBlk, nCodewords, TrBlkSizes)
            % (p, l, overtError, covertError, BER)
            s = [];
            
            for p=1:max_p
                for l=100:len_step:max_len
                    [overtError, covertError, BER]=DisplayStatistics.ConductChannel(p, l, offset, enb, pdsch, trBlk, nCodewords, TrBlkSizes, @EmbedSkipChunk, @GetMsgChunkSkip);

                    s = [s; p l overtError, covertError, BER];
                end
            end

            % Max l by p value while keeping decoded overt error zero
            figure
            
            for p=1:max_p
                a = s(s(:,1) == p, :);
                a = a(a(:,3) == 0, :);
                [val, ~] = max(a(:, 2));


                plot(p, val, '*', 'linewidth', 2);
                hold on
            end

            title("Max Covert Message Length vs Skip Value")
            xlabel("Skip Value")
            ylabel("Max Covert Message Length")
            hold off

            % Growth of p and l vs growth in decoded overt error
            figure

            for p=1:max_p
                pnts = s(s(:,1) == p, :);

                for k=1:length(pnts)
                    plot3(pnts(k, 1), pnts(k, 2), pnts(k, 3), "o")
                    hold on
                end
            end

            title("Skip Value vs Message Length vs Overt Errors");
            xlabel("Skip Value");
            ylabel("Covert Message Length");
            zlabel("Overt Errors")
            hold off

            % Growth of p and l vs BER
            figure

            for p=1:max_p
                pnts = s(s(:,1) == p, :);

                for k=1:length(pnts)
                    plot(pnts(k, 2), pnts(k, 5), "o")
                    hold on
                end
            end

            title("Message Length vs BER");
            xlabel("Covert Message Length");
            ylabel("Bit Error Rate (BER)")
            hold off
        end
    end
end