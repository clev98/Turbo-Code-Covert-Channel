% Uplink

function [rxTrBlk, crcError]=Uplink(enb, pdsch, chs, pdschsymbols, nCodewords, TrBlkSizes)

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

% Initialize the received transport block and CRC
rxTrBlk = cell(1,nCodewords);
crcError = zeros(1,nCodewords);

for n=1:nCodewords
    % Rate recovery stage also allows combining with soft information for
    % the HARQ process, using the input cbsbuffers. For the first
    % transmission of the transport block, the soft buffers are initialized
    % as empty. For retransmissions, the parameter cbsbuffers should be the
    % soft information from the previous transmission
    cbsbuffers = [];  % Initial transmission of the HARQ process
    % Rate recovery returns a cell array of turbo encoded code blocks
    raterecovered = lteRateRecoverTurbo(cws{n},TrBlkSizes,pdsch.RV(n),chs(n),cbsbuffers);
    NTurboDecIts = 5; % Number of turbo decoding iteration cycles
    % Turbo decoding returns a cell array of decoded code blocks
    turbodecoded = lteTurboDecode(raterecovered,NTurboDecIts);
    % Code block desegmentation concatenates the input code block segments
    % into a single output data block, after removing any filler and
    % type-24B CRC bits that may be present
    [blkdesegmented,segErr] = lteCodeBlockDesegment(turbodecoded,(TrBlkSizes+24));
    % CRC decoding returns the transport block after checking for CRC error
    [rxTrBlk{n},crcError(n)] = lteCRCDecode(blkdesegmented,'24A');
end