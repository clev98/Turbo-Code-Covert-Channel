# Turbo-Code-Covert-Channel
4G LTE Based Covert Channel, simulated in MATLAB. 

# Introduction
This is an attempt at a Turbo Code based covert channel, simulated in MATLAB's LTE simulator. As a forward error correcting code, bit errors will be corrected by the receiver of the data, providing a possible vector one way covert communication for third parties intercepting RF communications between a handset and a tower. 

This project generates pseudorandom overt and covert messages. The covert message is then embedded into the output of the Turbo Encoder prior to transmission. An informed uplink will intercept the transmission and extract the message. This will require knowledge of the scrambling sequence. The embedded message will be treated as a series of bit errors and corrected at the uninformed receiver. 

A full writeup can be found at clev dot news.

# File Structure
- LTESim.m - Main file. Run from here.
- Downlink.m - An unmodified handset with a regular Turbo Encoder.
- ModifiedDownlink.m - A handset with a modified Turbo Encoder to provide for injection of data. 
- Uplink.m - An uninformed, unmodified uplink. 
- InformedUplink - A third party receiver capable of intercepting outgoing LTE communications. 
- EmbedLSFR.m - Embed messages pseudorandomly using an LSFR.  
- EmbedNBitSkip.m - Embed messages by embedding a bit every N bits.
- EmbedSkipChunk.m - Embed messages by embedding chunks of bits at regular intervals. Seeks to take advantage of Turbo Code's block structure. 
- GetMsgChunkSkip.m - Extract bits according to the embedding method.
- GetMsgLSFR.m - Extract bits according to the embedding method.
- GetMsgNBitSkip.m - Extract bits according to the embedding method.
- GetNextLSFRState.m - Extract bits according to the embedding method.

# How to Use
This project assumes access to MATLAB and the LTE Toolbox.

Currently this project requires uncommenting of desired methods in the bottom of LTESim.m do run specific scenarios. This will change in the future. 

1. Run LTESim.m in Matlab.
2. A number of graphs will be generated with attempted message lengths, effects of modification of the embedding parameters, and the effect on the bit error rate at the uninformed receiver. 

# References
Credit for the starting code to create one way LTE communication is given to MATLAB. It can be found [here](https://www.mathworks.com/help/lte/ug/lte-dl-sch-and-pdsch-processing-chain.html).