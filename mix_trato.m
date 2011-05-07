function mix_trato

M=22
N=512;
Fs=22050;

caminho='/home/joao/20101/anacristina/percepcao/'
%filename = dir([caminho '*.wav']);
filename = dir([caminho '*.wav']);

A = [];
for I = 1: length(filename)
    [A_buf,yin] = extract_lpc_sample([caminho filename(I).name], M);
    yout = inverte(A_buf,[caminho filename(I).name]);
    %[H,F] = FREQZ(1,A_buf,N,Fs);
    %    plot(F,10*log10(abs(H)))
    data{I}.A = A_buf;
    data{I}.glottal = yout;
    data{I}.name = filename(I).name;
end

for I = 1:length(filename)
    for J = 1:length(filename)
        y_temp = filter(1, data{J}.A, data{I}.glottal(:,1));
        %        alpha = 0.95; 
        %yin = filter([1 -alpha],[1 0],y_temp);
        yin = y_temp;
        %        data_mix{I,J}.yout = yin;
        %data_mix{I,J}.arquivo_fonte = filename(I).name(1:end-4);
        %data_mix{I,J}.arquivo_filtro = filename(J).name(1:end-4);
        wavwrite(0.99*yin/max(abs(yin)),Fs, ...
                 ['./out/' filename(I).name(1:end-4) '_' ...
                  filename(J).name(1:end-4) '.wav']);  
    end
end




function y = inverte(A,filename)

[x,fs] = wavread(filename);
y = filter(A,1,x(:,1));



function [A,y] = extract_lpc_sample(filename, M)




[y,fs] = wavread(filename);

alpha = 0.95; 
yin = filter([1 -alpha],[1 0],y);


%[A,ALPHA, GRC] = lpccovar(y,M);
%A = lpc(y,M);

%A = lpc(yin(1:end),M);
A = arcov(yin(fix(0.1*end):end),M);
