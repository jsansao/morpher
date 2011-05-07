function mix_trato_normaliza

M=22
N=512;
Fs=22050;
f0_norm = 120;

caminho='./percepcao/'
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
    [f0_temp,f0_deviation] = call_f0([caminho filename(I).name]);
    data{I}.f0 =f0_temp; 
    data{I}.name = f0_deviation;
    N_yout =length(yout);
    if f0_temp>10
        N_new = fix(N_yout*f0_temp/f0_norm);
        y_interp = interp1((0:(N_yout-1))/N_yout,yout,(0:(N_new-1))/N_new);    
        data{I}.glottal_norm = y_interp;
    else
        data{I}.glottal_norm = yout;
    end
end


for I = 1:length(filename)
    for J = 1:length(filename)
        y_temp = filter(1, data{J}.A, data{I}.glottal_norm);
        %        alpha = 0.95; 
        %yin = filter([1 -alpha],[1 0],y_temp);
        yin = y_temp(2*M:end);
        %        data_mix{I,J}.yout = yin;
        %data_mix{I,J}.arquivo_fonte = filename(I).name(1:end-4);
        %data_mix{I,J}.arquivo_filtro = filename(J).name(1:end-4);
        ArquivoEscrita= ['./norm/' filename(I).name(1:end-4) '_' ...
                 filename(J).name(1:end-4) '_norm.wav'];
        wavwrite(0.99*yin/max(abs(yin)),Fs, ArquivoEscrita);  
        %        [f0,deviation] = call_f0(ArquivoEscrita);
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



function [snr_mes,deviation] = call_f0(arquivo);


ArquivoTemp = num2hex(rand);
ArquivoTemp2 = [ArquivoTemp '2'];
ArquivoTemp3 = [ArquivoTemp '3'];



command = [ 'acoustic -i ' arquivo ' -o ' ArquivoTemp2 ' -c ' ...
                            ArquivoTemp3 ' -n 1 | grep F0 > ' ...
                            ArquivoTemp ] ;
                    
eval(command); 

fid = fopen(ArquivoTemp);
file = textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
fclose(fid);
lines = file{1};
Linha = lines{1, :};
[a b snr_mes deviation] = strread(Linha, '%s %s %f %f', 'delimiter',' ');
         
command = ['!rm ' ArquivoTemp ' ' ArquivoTemp2 ...
                               '.stt ' ArquivoTemp3];
eval(command);