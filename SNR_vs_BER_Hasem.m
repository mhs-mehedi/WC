clc; 
clear; 
close all; 

M = 8; % 8-PSK Modulation 
bps = log2(M); 

% Input text 
text = 'Information and Communication Engineering'; 
symbols = double(text); 

% Convert text to binary representation 
symbolToBitMapping = de2bi(symbols, 8, 'left-msb'); 
totNoBits = numel(symbolToBitMapping); 
inputReshapedBits = reshape(symbolToBitMapping, 1, totNoBits); 

% Padding to make data length a multiple of bps 
remainder = mod(totNoBits, bps); 
if remainder == 0 
    userPaddedData = inputReshapedBits; 
else 
    paddingBits = zeros(1, bps - remainder); 
    userPaddedData = [inputReshapedBits paddingBits]; 
end 

% Modulation 
reshapedUserPaddedData = reshape(userPaddedData, [], bps); 
bitToSymbolMapping = bi2de(reshapedUserPaddedData, 'left-msb'); 
modulated_symbol = pskmod(bitToSymbolMapping, M, 0); % Removed 'gray' for MATLAB 2014 

% SNR vs BER Analysis 
SNR_range = 0:15; 
BER = zeros(size(SNR_range)); 

for idx = 1:length(SNR_range) 
    snr = SNR_range(idx); 
    % Add noise 
    noisySymbols = awgn(modulated_symbol, snr); 
    % Demodulation 
    demodulatedSymbol = pskdemod(noisySymbols, M, 0); 
    % Convert symbols back to bits 
    demodulatedSymbolToBitMapping = de2bi(demodulatedSymbol, bps, 'left-msb'); 
    reshapedDemodulatedBits = reshape(demodulatedSymbolToBitMapping.', 1, []); 
    % Remove padding 
    demodulatedBitsWithoutPadding = reshapedDemodulatedBits(1:totNoBits); 
    % Calculate BER 
    [~, ber] = biterr(inputReshapedBits, demodulatedBitsWithoutPadding); 
    BER(idx) = ber; 
    % Convert bits back to text 
    if mod(length(demodulatedBitsWithoutPadding), 8) == 0 
        txtBits = reshape(demodulatedBitsWithoutPadding, [], 8); 
        txtBitsDecimal = bi2de(txtBits, 'left-msb'); 
        msg = char(txtBitsDecimal)'; 
    else 
        msg = 'Error in text conversion'; 
    end 
end 

% Plot BER vs SNR 
figure; 
semilogy(SNR_range, BER, 'b-o', 'LineWidth', 2); 
xlabel('SNR (dB)'); 
ylabel('BER'); 
title('SNR vs BER for 8-PSK over AWGN'); 
grid on;