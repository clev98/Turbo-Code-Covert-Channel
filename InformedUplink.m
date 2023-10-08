% Modified Downlink Using N Bit Skip

function msg=InformedUplink(enb, pdsch, pdschsymbols, nCodewords, msg_len, p, start, ExtractMethod)
% p/seed
% start/taps
% Deprecoding (pseudo-inverse based) returns (Number of symbols)-by-NLayers matrix
if (any(strcmpi(pdsch.TxScheme,{'Port5' 'Port7-8' 'Port8' 'Port7-14'})))
    rxdeprecoded=pdschsymbols*pinv(pdsch.W);
else
    rxdeprecoded = lteDLDeprecode(enb,pdsch,pdschsymbols);
end

% Layer demapping returns a cell array containing one or two codewords. The
% number of codewords is deduced from the number of modulation scheme
% character vectors
layerdemapped = lteLayerDemap(pdsch,rxdeprecoded);

% Initialize the recovered codewords
cws = cell(1,nCodewords);
for n=1:nCodewords
    % Soft demodulation of received symbols
    demodulated = lteSymbolDemodulate(layerdemapped{n},pdsch.Modulation{n},'Soft');
    % Scrambling sequence generation for descrambling
    scramseq = ltePDSCHPRBS(enb,pdsch.RNTI,n-1,length(demodulated),'signed');
    % Descrambling of received bits
    cws{n} = demodulated.*scramseq;
end

% Get msg
%msg = GetMsgNBitSkip(cws, msg_len, p, start);
%msg = GetMsgLSFR(cws, msg_len, seed, taps);
msg = ExtractMethod(cws, msg_len, p, start);