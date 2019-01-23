%Digital Communications, EEEN40060
%Assignmnets 2 - Simulation of Hamming-coded BPSK System
%Student - Paul Doherty #10387129

clc
clear all

Eb = 1;                   %bit energy
EbN0 = [1:2:11];          %varying Eb/n0 
M = length(EbN0);         %Noise varied 6 times
n0 = Eb./EbN0;            %calculating noise


number_of_bit_errors = zeros(1,M);
Ns = 500000;              %number of samples       
N = 7;
Generator = [1 1 0 1 0 0 0; 0 1 1 0 1 0 0; 1 1 1 0 0 1 0; 1 0 1 0 0 0 1]; %Generator Matrix
trans_sig = zeros(1,N);
e = zeros(1,N);
Info = 0.5 > rand(1,(Ns*4)+4); %Code word to encoded

for m = [1:M]
for j = [1:4:Ns]
c = mod(Info(j:j+3)*Generator,2);    %Transmitted codeword

%BPSK Modulator
for k = [1:N]
    
    if  c(k) == 0
        trans_sig(k) = -1;
    else
        trans_sig(k) = 1;
    end
end
e =  randn(1,N);        %Noise in Channel
Dev = sqrt(n0(m)/2)*e;  %Calculating deviation

recieved_sig = trans_sig + Dev;     %transmitted signal + AWGN

%BPSK Demodulator
for k = [1:N]
    
    if recieved_sig(k) > 0
         c_recieved(k) = 1;
    else
         c_recieved(k) = 0;
    end
end

%Generating parity-check Matrix
P_transpose = transpose(Generator(:,1:3)); %Transpose of P
I = eye(3);
H = [I P_transpose];

Syndrome = mod(c_recieved*H',2);    %Finding syndrome
c_rec_check = c_recieved;

%Hamming Decoder
for k = [1:N]
   
    if Syndrome' == H(:,k)
       c_rec_check(k) = mod(c_rec_check(k)+1,2);
    end
    
end
    
bit_errors = mod(c_rec_check+c_recieved,2);
number_of_bit_errors(m) = number_of_bit_errors(m)+ sum(bit_errors);
simulation_BER(m) = number_of_bit_errors(m)/(Ns*4);
end
end

Pe= qfunc(sqrt(2.*EbN0)); %theoretical Symbol Error Prob
EbN0dB = 10*log10(EbN0);  %converting to dB for graphing
semilogy(EbN0dB,Pe,'b--o')
legend('Theoretical BER')
hold on
% figure (2)
title('Bit Error Probablility Curve')
semilogy(EbN0dB,simulation_BER,'r-o')
xlabel('EbN0 (dB)') 
ylabel('Bit Error Rate')
legend('Sim - BER')
hold off




% end