clc; 
clear all;     
close all; 

number_bits = 30;  
BINSEQ = abs(round(rand(1,number_bits)*2-1)); 

t = 0:1/100:1; 
Eb = 1; 
Tb = 1; 
nc = 4; %number of carrier cycle in a bit
fc = nc/Tb;  

% Carrier Signal 
Ac = 1.0; 
xc = Ac * cos(2*pi*fc*t); 

figure(1) 
plot(t, Ac*xc); 
title('Carrier Signal') 
xlabel(' time s '); 
ylabel( ' amplitude ' ); 

% PSK Modulation 
TX=[];
for m=1:1:number_bits 
    if(BINSEQ(m)==1) 
        TX = [TX sqrt(2*Eb/Tb)*cos(2*pi*fc*t)]; 
    else 
        TX = [TX -1*sqrt(2*Eb/Tb)*cos(2*pi*fc*t)]; 
    end 
end 

 
snr_db = -80; % Example SNR  
signal_power = mean(TX.^2);  
noise_power = signal_power / (10^(snr_db/10))  
noise = sqrt(noise_power/2) * randn(size(TX));  
RX_AWGN = TX + noise; 

figure(2) 
subplot(2,1,1) 
plot(1:length(TX),TX) 
title('PSK signal') 
subplot(2,1,2) 
plot(1:length(RX_AWGN),RX_AWGN) 
title('PSK with noise ') 

%Coherent Detection 
LO = sqrt(2/Tb) * cos(2*pi*fc*t); % Local oscillator
BINSEQDET = []; % Detected binary sequence
CS = []; % Correlation results

for n = 1:number_bits
    start_idx = (n-1)*length(t) + 1;
    end_idx = n*length(t);
    temp = RX_AWGN(start_idx:end_idx);
    
    % Correlate with LO
    S = sum(temp .* LO);
    CS = [CS S]; % Store correlation result
    
    % Decision: If S > 0, bit = 1; else, bit = 0
    if S > 0
        BINSEQDET = [BINSEQDET 1];
    else
        BINSEQDET = [BINSEQDET 0];
    end
end
figure(3) 
subplot(2,2,1) 
stem(CS) 
title('Output of the correlation receiver') 

subplot(2,2,2) 
scatter(CS,zeros(1,number_bits)) 
title('Signal-space diagram for the PSK signal'); 

subplot(2,2,3) 
stem(BINSEQ) 
title('Transmitted binary sequence') 

subplot(2,2,4) 
stem(BINSEQDET) 
title('Detected binary sequence') 

Bit_error = sum(abs(BINSEQDET - BINSEQ))
fprintf('Number of error bits: %d\n',Bit_error);