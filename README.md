# QE-wavelet-analysis

Octave/Matlab code from my diploma thesis [Wavelet analysis of quantitative easing in Japan](https://opac.crzp.sk/?fn=detailBiblioForm&sid=FE42652C724A629CC7654024874B).

Octave code in this repo relies on propriatory [ASToolbox2018](https://sites.google.com/site/aguiarconraria/joanasoares-wavelets) to be used.
To run ASToolbox2018 in Octave you have to omit `’Edgecolor’,[.7 .7 .7]` option from the `contour()` function. If you want to use `xlsread()` function, you need to load io package by writing `pkg load io` in your script.
In case it is not already installed, type `pkg install -forge io` in the command window.
Beside that, ASToolbox2018 works just fine in Octave and produces output virtually identical to that of Matlab.
