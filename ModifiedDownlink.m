% Modified Downlink Every Nth Bit, Optional LSFR

function [pdschsymbols, chs, BER]=ModifiedDownlink(enb, pdsch, trBlk, nCodewords, p, msg, start, EmbedMethod)

% Get the physical channel bit capacity required for rate matching from
% ltePDSCHIndices info output
[~,pdschInfo] = ltePDSCHIndices(enb,pdsch,pdsch.PRBSet);

% Define a structure array with parameters for lteRateMatchTurbo
chs = pdsch;
chs(nCodewords) = pdsch; % For 2 codewords, the array has two elements
% Initialize the codeword(s)
cw = cell(1,nCodewords);

for n=1:nCodewords
    % CRC addition for the transport block
    crccoded = lteCRCEncode(trBlk{n},'24A');
    % Code block segmentation returns a cell array of code block segments
    % with filler bits and type-24B CRC appended as required
    blksegmented = lteCodeBlockSegment(crccoded);
    % Channel coding returns the turbo coded segments in a cell array
    chencoded = lteTurboEncode(blksegmented);
    
    % Bundle the parameters in structure chs for rate matching as the
    % function requires both cell-wide and channel specific parameters
    chs(n).Modulation = pdsch.Modulation{n};
    chs(n).DuplexMode = enb.DuplexMode;
    chs(n).TDDConfig = enb.TDDConfig;
    
    % Calculate number of layers for the codeword
    if n==1
        chs(n).NLayers = floor(pdsch.NLayers/nCodewords);
    else
        chs(n).NLayers = ceil(pdsch.NLayers/nCodewords);
    end
    % Rate matching returns a codeword after sub-block interleaving, bit
    % collection and bit selection and pruning defined for turbo encoded
    % data and merging the cell array of code block segments
    cw{n} = lteRateMatchTurbo(chencoded,pdschInfo.G(n),pdsch.RV(n),chs(n));
end

% INJECT
%cw = EmbedNBitSkip(cw, msg, p, start);
cws = cw;
cw = EmbedMethod(cw, msg, p, start);
numBitErr = 0;
totalBits = 0;

% Initialize the modulated symbols
modulated = cell(1,nCodewords);

for n=1:nCodewords
   % Calculate BER
   numBitErr = numBitErr + sum(cw{n} ~= cws{n});
   totalBits = totalBits + length(cws{n});

   % Generate the scrambling sequence
   scramseq = ltePDSCHPRBS(enb,pdsch.RNTI,n-1,length(cw{n}));
   % Scramble the codewords
   scrambled = xor(scramseq,cw{n});
   % Symbol modulate the scrambled codewords
   modulated{n} = lteSymbolModulate(scrambled,pdsch.Modulation{n});
end

% Layer mapping results in a (symbols per layer)-by-NLayers matrix
layermapped = lteLayerMap(pdsch,modulated);
% Precoding results in a (symbols per antenna)-by-NTxAnts matrix
precoded = lteDLPrecode(enb, pdsch, layermapped);
% Apply beamforming optionally (W should be 1 or identity if no beamforming)
pdschsymbols = precoded*pdsch.W;

BER = numBitErr/totalBits;