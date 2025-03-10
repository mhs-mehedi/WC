clc;
clear;
close all;

% Parameters
M_values = [2, 4, 8]; % Modulation orders (BPSK, QPSK, 8-PSK)
numBits = 1e6; % Number of bits to transmit
SNR_dB = 0:2:20; % SNR values in dB
SNR = 10.^(SNR_dB/10); % Convert SNR to linear scale

% Initialize BER results
BER = zeros(length(M_values), length(SNR_dB));

% Loop over different modulation orders
for m_idx = 1:length(M_values)
    M = M_values(m_idx);
    k = log2(M); % Bits per symbol
    
    % Generate random binary data
    data = randi([0 1], numBits, 1);
    
    % Reshape data into symbols
    data_symbols = bi2de(reshape(data, k, []).';
    
    % PSK Modulation
    modulated_signal = pskmod(data_symbols, M, pi/M);
    
    % Loop over different SNR values
    for snr_idx = 1:length(SNR_dB)
        % Add AWGN noise
        noisy_signal = awgn(modulated_signal, SNR_dB(snr_idx), 'measured');
        
        % PSK Demodulation
        demodulated_symbols = pskdemod(noisy_signal, M, pi/M);
        
        % Convert symbols back to bits
        received_bits = de2bi(demodulated_symbols, k);
        received_bits = received_bits(:);
        
        % Calculate BER
        BER(m_idx, snr_idx) = sum(data ~= received_bits) / numBits;
    end
end

% Plot BER vs SNR
figure;
semilogy(SNR_dB, BER(1,:), 'bo-', 'LineWidth', 2);
hold on;
semilogy(SNR_dB, BER(2,:), 'ro-', 'LineWidth', 2);
semilogy(SNR_dB, BER(3,:), 'go-', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs SNR for Different PSK Modulation Orders');
legend('BPSK (M=2)', 'QPSK (M=4)', '8-PSK (M=8)');