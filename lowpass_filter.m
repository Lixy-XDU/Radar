function sig_lowpass = lowpass_filter(Fp,Fs,ap,as,fs,sig)
%BUTTER 此处显示有关此函数的摘要
%   此处显示详细说明
    wp = Fp/2/fs;
    ws = Fs/2/fs;
    [N,wc] = buttord(wp,ws,ap,as);
    [b,a] = butter(N,wc,"low");
    sig_lowpass = filter(b,a,sig);
end

