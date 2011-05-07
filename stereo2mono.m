function stereo2mono 

caminho='/home/joao/20101/anacristina/percepcao/'
caminho_out='/home/joao/20111/morpher/percepcao/'
D = dir('/home/joao/20101/anacristina/percepcao/*.wav');

Temp = size(D);
Dtotal = Temp(1);


for J = 1 : Dtotal  
    ArquivoBase = [ caminho D(J).name  ]
    [y,fs] = wavread(ArquivoBase);
    ArquivoBaseSaida = [ caminho_out D(J).name  ]
    wavwrite(y(:,1), fs, ArquivoBaseSaida);
end
