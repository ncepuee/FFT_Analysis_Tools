% Spectrum Analyse code for Common mode voltage
%% 取一个参考周期
clc
clear all

%% 示波器波形
DataMeas=load('G:\EMTProgram\simulinkprogram\PhD_Learning\MyStudyHobby\FFT_Analysis\withHPF.csv');%载入csv文件
% DataMeas=load('F:\每周汇报文件存储\2022年04月04日-04月10日\ILZSVM8_VSFPWM_1e-8(0.1s).mat');

f=50; %设定频率分辨率
T=1/f; %基波周期
% dt=1e-8;
dt=4e-8; %设定示波器的采样周期dt
N=T/dt;%一个频率分辨率内的采样点数
CMVqzsi=CMV_Data(1:N,1); %取出一个频率分辨率周期的点
CMVqzsi=CMVqzsi.';%将IL的列向量变成行向量
IFFTCMVqzsi=fft(CMVqzsi);%进行快速傅里叶变换
CMVqzsi0=IFFTCMVqzsi(1)/N;%直流分量幅值
t=0:dt:(N-1)*dt;
%% 绘制频谱图
X_mags = abs(fft(CMVqzsi)); %求傅里叶变换后的模值
bin_vals = [0:N-1]; 
fax_Hz = bin_vals*f; %将横坐标按频率分辨率设定好
N_2 = ceil(N/2); %只看前半部分，因为关于N/2对称
figure(1)
% hold on
% plot(fax_Hz(1), X_mags(1)/(N)); %经过傅里叶变换后直流分量幅值扩大N倍
% plot(fax_Hz(2:N/2), X_mags(2:N/2)/(N/2)); %经过傅里叶变换后基波和谐波幅值扩大N/2倍
%通过semilogx函数，横坐标是以10为底在对数刻度，在y周使用线性刻度。
% semilogx(fax_Hz(1), 20*log10(X_mags(1))/(N)); %经过傅里叶变换后直流分量幅值扩大N倍
% 由于在log(1)的值是负无穷所以，直流分量在频谱上无法表示
semilogx(fax_Hz(21:N/2), 20*log10(X_mags(21:N/2)/(N/2)),'b'); %经过傅里叶变换后基波和谐波幅值扩大N/2倍
% xlabel('Frequency [Hz]')
% ylabel('Voltage [dB]');
% title({'Single-sided Power spectrum' ...
%     ' (Frequency is shown on a log scale)' ...
%     'Frequency resolution:50Hz'});
axis tight
% %% 准Z源直流侧的电流处理
% CMVqzsi1=CMVqzsi0;
% for k=1:1:150
%     CMVqzsi1abs=abs(IFFTCMVqzsi(1+k))*2/N;
%     CMVqzsi1angle=angle(IFFTCMVqzsi(1+k));
%     CMVqzsi1=CMVqzsi1+CMVqzsi1abs*cos(2*pi*k*50*t+CMVqzsi1angle);
% end
% CMVqzsinoise=0;
% % for k=1800:1:N/2-1
% %     Iqzsinoiseabs=abs(IFFTIqzsi(1+k))*2/N;
% %     Iqzsinoiseangle=angle(IFFTIqzsi(1+k));
% %     Iqzsinoise=Iqzsinoise+Iqzsinoiseabs*cos(2*pi*k*50*t+Iqzsinoiseangle);
% % end
% %% 绘制准z源的电流Iqzsi
% figure(2)
% plot(t,CMVqzsi-CMVqzsi1-CMVqzsinoise,'b','LineWidth',1)
% xlabel('Time[s]');ylabel('ILripple(DSP)[A]'); %坐标轴
% title({'Current Ripple' ...
%     'ZSVM8 Modulation'});
% axis tight
% %% 绘制准Z源的电流及其基波
% figure(3)
% xlabel('Time[s]');ylabel('ILripple(DSP)[A]'); %坐标轴
% plot(t,CMVqzsi-CMVqzsinoise,'y')
% hold on
% plot(t,CMVqzsi1,'r','LineWidth',1)
% hold on
% plot(t,CMVqzsi-CMVqzsi1-CMVqzsinoise,'b','LineWidth',1)
% axis tight