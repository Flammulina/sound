clear;
exec Window_s.sci;
exec FFT_s.sci;

// 対象音声ファイル名
fname='sounds/aiueo2.wav';
// 分析窓長（点）
winlen = 512;
// リフタの次数
liflen = 16;
// 5母音のおよその中心位置
vowel_sec = [0.90 1.90 3.00 4.00 5.00];
vowel_name = ["a" "i" "u" "e" "o"] 

// 以降、処理開始
[s,fs,bits]=wavread(fname);  // 音声ファイルの読み込み
vowel_pos = vowel_sec*fs-winlen/2; // 各母音の読み込み開始点を計算（分析窓の1/2手前から）
w=HanningWindow_s(winlen); // ハニング窓
lif=zeros(1,winlen); // リフタを作成
lif(1:liflen+1)=1;
lif(winlen-liflen+1:winlen)=1;
tm=([1:winlen]-1)/fs;  // 時間軸（窓内）
quef=tm(1:winlen/2+1); // ケフレンシー軸
fr=zeros(1,winlen/2+1);  // 周波数軸の作成
for k=1:winlen/2+1,
    fr(k)=(k-1)*fs/winlen;
end

// 図を各母音に対して縦に6つ並べて順に描く
clf;
for v=1:5,
    x=s(vowel_pos(v):vowel_pos(v)+winlen-1); // 切り出し
    xx=x.*w;                // 窓掛け
    X=FFT_s(xx);            // DFT
    A=abs(X);               //スペクトルの絶対値
    S=20*log10(A);     // 対数化
    C=IFFT_s(S);            // IDFT
    CC=C.*lif;              // リフタリング
    SS=FFT_s(CC);           // DFT

    // 波形の描画
    subplot(6,5,v);
    plot(tm,x);
    a=gca();
    //a.data_bounds=[tm(1),-1.0; tm($),1.0];
    a.grid=[1 1]*color('gray');
    xlabel(gettext("時間 (s)"));
    //ylabel(gettext("振幅"));
    //title(vowel_name(v));

    // スペクトルの描画
    subplot(6,5,5+v);
    plot(fr,A(1:winlen/2+1),'green');
    a=gca();
    //a.data_bounds=[fr(1),0; fr($),30];
    a.grid=[1 1]*color('gray');
    xlabel(gettext("周波数 (Hz)"));
    //ylabel(gettext("Spectrum"));

    subplot(6,5,10+v);
    plot(fr,S(1:winlen/2+1),'green');
    a=gca();
    a.data_bounds=[fr(1),-50; fr($),40];
    a.grid=[1 1]*color('gray');
    xlabel(gettext("周波数 (Hz)"));
    //ylabel(gettext("Spectrum (dB)"));
    
    // ケプストラム
    subplot(6,5,15+v);
    plot(quef,C(1:winlen/2+1));
    a=gca();
    a.grid=[1 1]*color('gray');
    xlabel(gettext("ケフレンシー (s)"));
    
    // リフタリング処理後のケプストラム
    subplot(6,5,20+v);
    plot(quef,CC(1:winlen/2+1));
    a=gca();
    a.grid=[1 1]*color('gray');
    xlabel(gettext("ケフレンシー (s)"));
    
    // それをDFTしたもの（スペクトル包絡）
    subplot(6,5,25+v);
    plot(fr,S(1:winlen/2+1),'green',fr,SS(1:winlen/2+1),'red');
    a=gca();
    a.data_bounds=[fr(1),-50; fr($),40];
    a.grid=[1 1]*color('gray');
    xlabel(gettext("周波数 (Hz)"));
    //ylabel(gettext("Spectrum (dB)"));
end
