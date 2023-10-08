clear
clc

% Cell-wide Settings
% The cell-wide parameters are grouped into a single structure enb. A
% number of the functions used in this example require a subset of the
% parameters specified below. In this example we use the configuration
% according to the RMC R.14 FDD specified in TS 36.101 Annex A.3.4 which
% uses 50 RB, 4 port, 'SpatialMux' transmission scheme, '16QAM' symbol
% modulation, 2 codewords and a code rate of 1/2.
enb.NDLRB = 50;                 % Number of resource blocks
enb.CellRefP = 4;               % Cell-specific reference signal ports
enb.NCellID = 0;                % Cell ID
enb.CyclicPrefix = 'Normal';    % Normal cyclic prefix
enb.CFI = 2;                    % Length of control region
enb.DuplexMode = 'FDD';         % FDD duplex mode
enb.TDDConfig = 1;              % Uplink/Downlink configuration (TDD only)
enb.SSC = 4;                    % Special subframe configuration (TDD only)
enb.NSubframe = 0;              % Subframe number

% Transport/Physical channel settings for ease of use the DL-SCH and PDSCH
% channel specific settings are specified in a parameter structure pdsch.
% For the R.14 FDD RMC, there are two codewords, so the modulation scheme
% is specified as a cell array containing the modulation schemes of both
% codewords. If configuring for one codeword, the modulation scheme can be
% a character vector or a cell array with character vectors.
% It is also important to configure the TrBlkSizes parameter to have the
% correct number of elements as the intended number of codewords. The
% number of soft bits for the rate matching stage is decided by the UE
% category as specified in TS 36.306 Table 4.1-1. In this example, the
% transport block size is looked up from tables in TS 36.101 Annex A.3.4.
% This can also be done by using the lteRMCDL function for R.14 RMC.

% DL-SCH Settings
blkSize = 11448;
TrBlkSizes = [blkSize; blkSize];    % 2 elements for 2 codeword transmission
pdsch.RV = [0 0];               % RV for the 2 codewords
pdsch.NSoftbits = 1237248;      % No of soft channel bits for UE category 2
% PDSCH Settings
pdsch.TxScheme = 'SpatialMux';  % Transmission scheme used
pdsch.Modulation = {'16QAM','16QAM'}; % Symbol modulation for 2 codewords
pdsch.NLayers = 2;              % Two spatial transmission layers
pdsch.NTxAnts = 2;              % Number of transmit antennas
pdsch.RNTI = 1;                 % The RNTI value
pdsch.PRBSet = (0:enb.NDLRB-1)';% The PRBs for full allocation
pdsch.PMISet = 0;               % Precoding matrix index
pdsch.W = 1;                    % No UE-specific beamforming
% Only required for 'Port5', 'Port7-8', 'Port8' and 'Port7-14' schemes
if any(strcmpi(pdsch.TxScheme,{'Port5','Port7-8','Port8', 'Port7-14'}))
    pdsch.W = transpose(lteCSICodebook(pdsch.NLayers,pdsch.NTxAnts,[0 0]));
end

% Random number initialization for creating random transport block(s)
rng('default');

% Convert the modulation scheme char array or cell array to string array
% for uniform processing
 pdsch.Modulation = string(pdsch.Modulation);

% Get the number of codewords from the number of transport blocks
nCodewords = numel(TrBlkSizes);

% Generate the transport block(s)
% Initialize the codeword(s)
trBlk = cell(1,nCodewords);

for n=1:nCodewords
    trBlk{n} = randi([0 1],TrBlkSizes(n),1);
end

% Unmodified Downlink
%[cw, chs] = Downlink(enb, pdsch, trBlk, nCodewords);

%{
p = 1;
msg_len = 1300;
msg = randi([0 1], 1, msg_len);
offset = 5764;
offsets = {offset, offset*2};
%seed = [1 1 1 1 0 0 0 0];
%taps = [7, 4, 1];

[pdschsymbols, chs, cws] = ModifiedDownlink(enb, pdsch, trBlk, nCodewords, p, msg, offsets, @EmbedSkipChunk);

% Uplink
[rxTrBlk, crcError] = Uplink(enb, pdsch, chs, pdschsymbols, nCodewords, TrBlkSizes);

% Informed Uplink
decoded_msg = InformedUplink(enb, pdsch, pdschsymbols, nCodewords, msg_len, p, offsets, @GetMsgChunkSkip);
%}

%{
% N Bit Skip
DisplayStatistics.GetStatisticsNBit(8, 2000, 50, 1, enb, pdsch, trBlk, nCodewords, TrBlkSizes)

% "Random" Injection via LSFR
% Period of 8191
seed1 = [0 1 0 1 0 1 0 1 0 1 0 1 0];
tap1 = [0 2 3 12];

% Period of 4095
seed2 = [0 1 0 1 0 1 0 1 0 1 0 1];
tap2 = [0 3 5 11];

% Period of 511
seed3 = [1 0 1 0 1 0 1 0 1];
tap3 = [1 3 7 8];

DisplayStatistics.GetStatisticsLSFR(seed1, tap1, 2000, 50, enb, pdsch, trBlk, nCodewords, TrBlkSizes)
DisplayStatistics.GetStatisticsLSFR(seed2, tap2, 2000, 50, enb, pdsch, trBlk, nCodewords, TrBlkSizes)
DisplayStatistics.GetStatisticsLSFR(seed3, tap3, 2000, 50, enb, pdsch, trBlk, nCodewords, TrBlkSizes)

%}
% Skip Systematic Bits
%DisplayStatistics.GetStatisticsNBit(5, 5000, 50, 5764, enb, pdsch, trBlk, nCodewords, TrBlkSizes)

% Skipping Large Offset
%DisplayStatistics.GetStatisticsNBit(5, 5000, 50, 1000, enb, pdsch, trBlk, nCodewords, TrBlkSizes)

% Skip Chunks
%DisplayStatistics.GetStatisticsChunk(8, 2500, 50, {1, 5764}, enb, pdsch, trBlk, nCodewords, TrBlkSizes)
DisplayStatistics.GetStatisticsChunk(8, 3500, 50, {5764, 5764*2}, enb, pdsch, trBlk, nCodewords, TrBlkSizes)
%DisplayStatistics.GetStatisticsChunk(8, 2500, 50, {5764*2, 5764*3}, enb, pdsch, trBlk, nCodewords, TrBlkSizes)