clc; 
clear; 
close all; 

M = 8; 
bps = log2(M); 

% Generate a random binary data sequence 
numBits = 10000; 
randomBits = randi([0 1], 1, numBits); 

% Padding to ensure data length is a multiple of bps 
remainder = mod(numBits, bps); 
if remainder ~= 0 
    paddingBits = zeros(1, bps - remainder); % Add zero padding 
    randomBits = [randomBits paddingBits]; 
end 

% Convert bits to symbols 
reshapedBits = reshape(randomBits, [], bps); 
bitToSymbolMapping = bi2de(reshapedBits, 'left-msb'); 

% 8-PSK Modulation 
modulatedSymbols = pskmod(bitToSymbolMapping, M, 0); 

% SNR vs BER Analysis 
SNR_range = 0:15; 
BER = zeros(size(SNR_range)); 

for idx = 1:length(SNR_range) 
    snr = SNR_range(idx); 

    % Add AWGN noise 
    noisySymbols = awgn(modulatedSymbols, snr); 

    % Demodulation 
    demodulatedSymbols = pskdemod(noisySymbols, M, 0); 

    % Convert symbols back to bits 
    demodulatedBitsMatrix = de2bi(demodulatedSymbols, bps, 'leftmsb'); 
    receivedBits = reshape(demodulatedBitsMatrix.', 1, []); % Convert back to 1D array 

    % Remove padding 
    receivedBits = receivedBits(1:numBits); 

    % Compute BER 
    [~, ber] = biterr(randomBits(1:numBits), receivedBits); 
    BER(idx) = ber; 
end 

% Plot BER vs SNR 
figure; 
semilogy(SNR_range, BER, 'b-o', 'LineWidth', 2); 
xlabel('SNR (dB)'); 
ylabel('BER'); 
title('SNR vs BER for 8-PSK over AWGN with Random Data'); 
grid on;