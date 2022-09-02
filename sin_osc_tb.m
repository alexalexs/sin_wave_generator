clc
clear all
clf
%% init---------------------------------------
period=20e-12;  % period
N_bit=8;        % Bit resolution (can't be changed)
M_len=16;       % Array length of pi/4 sin
N=M_len*20;     % n-points only for testbench plot
%% -------------------------------------------
% Original sin plot
t_max=M_len*period; % 
f=1/t_max/4; % freq
t=linspace(0,t_max,N);
y=sin(2*pi*f*t); % sin original
% Plot
subplot(2,2,1)
plot(t,y)
hold on
title(['pi/4 part of sin width:' num2str(N_bit) 'bit'])
xlabel('t, [s]')
%% Discretization, truncate bit (optional)
edges=0:1/(2^N_bit-1):1; % discretization
y_discr=discretize(y,edges);
[Y,E]=discretize(t,0:t_max/(M_len):t_max+(t_max/M_len)*1);
t_discr=E(Y);
y_discr_norm=edges(y_discr);
y_discr_norm_bin=dec2base(round(y_discr_norm.*127*2),2,N_bit+1); % amplitude of signed int8=127*2
y_bit_trunc=y_discr_norm_bin(:,1:N_bit);
y_bit_trunc(1:N/M_len:end,:)
str_="b"""+join(string(y_bit_trunc(1:N/M_len:end,:))','",b"') % for VHDL array type 
str_write=join(string(y_bit_trunc(1:N/M_len:end,:))','\n') % for .mif(*) file
y_discr_norm2=base2dec(y_bit_trunc,2)';
y_discr_norm2=y_discr_norm2./max(y_discr_norm2);
%% Write to file .mif
file=fopen('sin_rom.mif','w');
fprintf(file,str_write,'%d');
fclose(file);
%% Replication of pi/4 interval 
y_arr=[y_discr_norm2 y_discr_norm2(end:-1:1)]; % pi/2
y_src=[y y(end:-1:1)]; % pi/2
y_arr=[y_arr -1.*y_arr]; % pi
y_src=[y_src y_src.*(-1)]; % pi
t_discr_arr=[t_discr t_discr+max(t_discr)];
t_discr_arr=[t_discr_arr t_discr_arr+max(t_discr_arr)];
x_src=[t t+max(t)];
x_src=[x_src x_src+max(x_src)];
for i=1:3 % 4 periods
    y_arr=[y_arr y_arr]; % 2*pi
    y_src=[y_src y_src]; % 2*pi
    t_discr_arr=[t_discr_arr t_discr_arr+max(t_discr_arr)];
    x_src=[x_src x_src+max(x_src)];
end
% Plot
subplot(2,2,1)
plot(t_discr,y_discr_norm2)
legend({'Continuous','discrete (zero-order hold)'})
subplot(2,2,3)
plot(t_discr_arr,y_arr);
hold on
plot(x_src,y_src);
title('Continuous and discrete signal')
xlabel('t, [s]')
%% FFT
y_in=y_arr(1:(N/M_len):end);
y_src_decim=y_src(1:(N/M_len):end);
[n_f,y_discr_fft_norm]=fft_fun(t_discr_arr(1:(N/M_len):end),y_in);
[n_src_f,y_src_fft_norm]=fft_fun(x_src(1:(N/M_len):end),y_src_decim);
% Plot
subplot(2,2,4)
plot(n_f,10.*log10(y_discr_fft_norm))
hold on
plot(n_src_f,10.*log10(y_src_fft_norm))
axis([0 max(n_f)/2 -50 0])
title('FFT continuous signal and discrete signal')
xlabel('f, [Hz]')
%% Read file from ModelSim
file=fopen('output.txt','r');
A=split(fscanf(file,'%c'));
A(end)=[];
fclose(file);
%% Converting binary signed to int8->double
y_out_dec=typecast(uint8(bin2dec(A)), 'int8'); % converting to signed data
y_out_dec_norm=double(y_out_dec)./double(max(max(abs(y_out_dec)))); % convert to double
x_out=(1:length(y_out_dec)).*period-period*1; % offset on one sample period for modelsim data
% Plot
subplot(2,2,3)
plot(x_out,y_out_dec_norm)
hold on
legend({'in (zero-order hold)','out','modelsim'})
%% Plot
subplot(2,2,2)
% plot(x_out,y_in-y_out_dec_norm');
title('Phase error')
%% FFT
[n_f,y_modelsim_fft_norm]=fft_fun(x_out,y_out_dec_norm);
% Plot
subplot(2,2,4)
plot(n_f,10.*log10(y_modelsim_fft_norm))
hold on
axis([0 max(n_f)/2 -70 0])
legend({'in (zero-order hold)','out','modelsim'})
%% FFT function
function [n_f,y_fft_norm_half]=fft_fun(x,y)
Fs=1/(x(2)-x(1)); % sample freq
N_fft=1024*4;
y_fft=abs(fft(y,N_fft));
y_fft_norm=y_fft./max(y_fft);
y_fft_norm_half=y_fft_norm(1:N_fft/2).^2;
n_f=Fs.*(0:N_fft/2-1)./N_fft;
end