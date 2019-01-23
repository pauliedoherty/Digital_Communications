clear all
clc
total_x_received = [];
M=16;
Ns=5000; %determine the amount of symbols
L=50;     %size of loop (amount of changes for noise value)
symbol_error = zeros(1,L);
simSER = zeros(1,L);
possible_transmittions = [(-3+3i) (-1+3i) (1+3i) (3+3i) (-3+1i) (-1+1i) (1+1i) (3+1i) (-3-1i) (-1-1i) (1-1i) (3-1i) (-3-3i) (-1-3i) (1-3i) (3-3i)];
Eb= 1;
x_received = zeros(1,Ns*4);
EbN0 = [25:-0.5:0.5] %varying Eb/n0 L times
n0 = Eb./EbN0;       %calculating noise
EsN0 = EbN0*log2(M);    %mulitplying EbN0 by 4 to get EsN0
EsN0dB = 10*log10(EsN0);    %converting to dB for graphing
EbN0dB = 10*log10(EbN0);

 Pe= 4 * (1-(1/sqrt(M))) * qfunc(sqrt(3.*EsN0/((M-1)))); %theoretical Symbol Error Prob
x = 0.5 > rand(1,Ns*4); %randomely generated signal of 1 and 0s
for l = [1:L]
for k=[1:4:Ns*4]
    
%Bit to Symbol Mapping using grey coding to decide the columns and rows of
%Tx
    
    if      [x(k) x(k+1)] == [0 0]
    tx_col = -3;
   
    elseif [x(k) x(k+1)] == [0 1]
    tx_col = -1;
        
    elseif [x(k) x(k+1)] == [1 1]
    tx_col = 1;
     
    elseif [x(k) x(k+1)] == [1 0]
    tx_col = 3;
    end
    
    if      [x(k+2) x(k+3)] == [0 0]
    tx_row = 3;
   
    elseif [x(k+2) x(k+3)] == [0 1]
    tx_row = 1;
        
    elseif [x(k+2) x(k+3)] == [1 1]
    tx_row = -1;
     
    elseif [x(k+2) x(k+3)] == [1 0]
    tx_row = -3;
    end
    
    
    %AWGN

   Dev = sqrt(n0(l)/2)*randn; %calculating a deviation for both rows and columns
   Devi = sqrt(n0(l)/2)*randn;
   Tx_withnoise = tx_col+(tx_row)*i + Dev + Devi*i; %adding deviation due to noise
    
   %Demodulator -
   %finding the euclidean distance between the transmitted symbols and all
   %possible symbol transmissions
   
    euclidean(1)=abs(Tx_withnoise - possible_transmittions(1));
    euclidean(2)=abs(Tx_withnoise - possible_transmittions(2));
    euclidean(3)=abs(Tx_withnoise - possible_transmittions(3));
    euclidean(4)=abs(Tx_withnoise - possible_transmittions(4));
    euclidean(5)=abs(Tx_withnoise - possible_transmittions(5));
    euclidean(6)=abs(Tx_withnoise - possible_transmittions(6));
    euclidean(7)=abs(Tx_withnoise - possible_transmittions(7));
    euclidean(8)=abs(Tx_withnoise - possible_transmittions(8));
    euclidean(9)=abs(Tx_withnoise - possible_transmittions(9));
    euclidean(10)=abs(Tx_withnoise - possible_transmittions(10));
    euclidean(11)=abs(Tx_withnoise - possible_transmittions(11));
    euclidean(12)=abs(Tx_withnoise - possible_transmittions(12));
    euclidean(13)=abs(Tx_withnoise - possible_transmittions(13));
    euclidean(14)=abs(Tx_withnoise - possible_transmittions(14));
    euclidean(15)=abs(Tx_withnoise - possible_transmittions(15));
    euclidean(16)=abs(Tx_withnoise - possible_transmittions(16));
    
    %the minimum distance found between tx symbol and possible transmission
    %is used to determine which symbol combination has been sent
    [C,I] = min(euclidean);
    
    %comparing the real part of tx_withnoise for columns
    %and imaginary part of tx_withnoise for rows
    if real(possible_transmittions(I)) ~= tx_col || imag(possible_transmittions(I)) ~= tx_row
        symbol_error(l) = symbol_error(l) + 1; %adding errors each time one is seen
        %this is not the most efficient way to calculate errors but is
        %sufficient here
        simSER(l) =  symbol_error(l)/Ns;  %simulated symbol error rate
        
    end
    
    %Symbol to Bit Mapping
    
    if real(possible_transmittions(I)) == -3
    x_received(k) = 0;
    x_received(k + 1) = 0;
    
    elseif real(possible_transmittions(I)) == -1
    x_received(k) = 0;
    x_received(k + 1) = 1;
    
    elseif real(possible_transmittions(I)) == 1
    x_received(k) = 1;
    x_received(k + 1) = 1;
    
    elseif real(possible_transmittions(I)) == 3
    x_received(k) = 1;
    x_received(k + 1) = 0;
    end
    
    if imag(possible_transmittions(I)) == -3
    x_received(k + 2) = 1;
    x_received(k + 3) = 0;
    
    elseif imag(possible_transmittions(I)) == -1
    x_received(k + 2) = 1;
    x_received(k + 3) = 1;
    
    elseif imag(possible_transmittions(I)) == 1
    x_received(k + 2) = 0;
    x_received(k + 3) = 1;
    
    elseif imag(possible_transmittions(I)) == 3
    x_received(k + 2) = 0;
    x_received(k + 3) = 0;
    end

end
bit_errors = mod(x_received+x,2); %determining when there was an error
number_of_bit_errors(l) = sum(bit_errors); %summing all errors
simBER(l) = number_of_bit_errors(l)/(Ns*4);  %simulated Bit Error Rate
end


figure (1)
title('Symbol Error Probablility Curve')
semilogy(EsN0dB,simSER,'r.-')
xlabel('EsN0 (dB)')
ylabel('Symbol Error Rate')


hold on

semilogy(EsN0dB,Pe,'b--o')
hold off

figure (2)
title('Bit Error Probablility Curve')
semilogy(EbN0dB,simBER,'m:')
xlabel('EbN0 (dB)')
ylabel('Bit Error Rate')




