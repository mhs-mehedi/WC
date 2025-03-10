clc;
clear;
close all;

% Input binary sequence
binary_seq = [1 0 1 1 0 0 1 0 0 1];

% Parameters
SNR_dB = .5; % Signal-to-Noise Ratio in dB
N = length(binary_seq); % Length of the binary sequence
fc = 1000; % Carrier frequency
Fs = 10000; % Sampling frequency
t = 0:1/Fs:(N-1)/Fs; % Time vector

% BPSK Modulation
binary_seq_polar = 2 * binary_seq - 1; % Convert to polar NRZ
bpsk_signal = binary_seq_polar .* cos(2 * pi * fc * t);

% AWGN Channel
signal_power = mean(abs(bpsk_signal).^2);
noise_power = signal_power / (10^(SNR_dB/10));
noise = sqrt(noise_power/2) * randn(1, length(bpsk_signal));
received_signal = bpsk_signal + noise;

% Coherent Correlation Demodulation
demod_signal = received_signal .* cos(2 * pi * fc * t);
demod_signal_integrated = reshape(demod_signal, [], N);
demod_signal_integrated = sum(demod_signal_integrated, 1);

% Decision making
detected_binary_seq = demod_signal_integrated > 0;

% Error calculation
num_errors = sum(binary_seq ~= detected_binary_seq);

% Plotting
figure;

% (a) Polar NRZ input binary sequence and modulated BPSK signal
subplot(311)
stairs([0 binary_seq], 'LineWidth',2)
title('Original Binary Sequence');
xlabel('Bit Index');
ylabel('Amplitude');
xlim([1 N+1]);
ylim([-1.5 1.5]);
grid on;

subplot(3, 1, 2);
stairs([0 binary_seq_polar], 'LineWidth', 2);
title('Polar NRZ Input Binary Sequence');
xlabel('Bit Index');
ylabel('Amplitude');
xlim([1 N+1]);
ylim([-1.5 1.5]);
grid on;

subplot(3, 1, 3);
plot(t, bpsk_signal);
title('Modulated BPSK Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;


% (b) Received BPSK signal in AWGN channel and output of the coherent correlation receiver
figure;
subplot(2, 1, 1);
plot(t, received_signal);
title('Received BPSK Signal in AWGN Channel');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;


subplot(2, 1, 2);
plot(t, demod_signal);
title('Output of Coherent Correlation Receiver');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% (c) Transmitted and detected binary sequence
figure;
stairs([0 binary_seq], 'LineWidth', 2);
hold on;
stairs([0 detected_binary_seq], 'LineWidth', 2);
title('Transmitted and Detected Binary Sequence');
xlabel('Bit Index');
ylabel('Amplitude');
xlim([1 N+1]);
ylim([-0.5 1.5]);
legend('Transmitted', 'Detected');
grid on;

% Display the number of erroneous bits
fprintf('Number of erroneous bits received: %d\n', num_errors);