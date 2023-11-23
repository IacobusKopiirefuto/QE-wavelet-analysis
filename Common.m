% Copyright (c) 2022 Jakub Skoda
% Released under the MIT License.

% This code is run at start of every other script

clear; % clearing variables
clc; % clearing screen

% Path for loading the wavelet functions (has to be changed)
% use `if ispc else` to add file path for Windows, but Octave/Matlab should handle this themselves
% https://www.mathworks.com/help/matlab/ref/ispc.html  https://www.mathworks.com/matlabcentral/answers/117110-dealing-with-and-windows-vs-unix-for-path-definition
addpath('ASToolbox2018/Functions/WaveletTransforms');
addpath('ASToolbox2018/Functions/Auxiliary');

% Loading data
d = dlmread ('data.csv', "," ,1,1);
fx      = d(:,1);
reserve = d(:,2);
GDP     = d(:,3);
CPI     = d(:,4);

t =  transpose(1970:0.25:2020.25);

% sorting data in a nice matrix
% could have been done directly from dlmread()
% but this I find easier to read
X = [fx GDP CPI reserve];

Xsize = size(X,2);

% parameters for easy naming and saving of the output
names = cell(1,Xsize);
names{1} =      'fx';  
names{2} =      'GDP'; 
names{3} =      'CPI'; 
names{4} =      'reserve';

% format for saving output
% use '-dsvg' for svg, '-dpng' for png
filform = '-dpng';

% ******** Common wavelet transforms parameters *********************
dt = 1/4;
dj = 1/30; 
low_period = 1;
up_period = 23;

% -------------------- Choice of boundary conditions -----------
% To try other b.c.'s, make pad = 1 or pad = 2
pad = 0;     % Zero b.c.'s

% ---------------------- Choice of wavelet ---------------------
mother = 'Morlet'; % Morlet wavelet
beta = []; % 6.0; % omega parameter for the Morlet
gamma = [];  % Not important


% subfunction that checks if we are in octave
 function r = is_octave ()
   persistent x;
   if (isempty (x))
     x = exist ('OCTAVE_VERSION', 'builtin');
   end
   r = x;
 end
% https://web.archive.org/web/20190926055627/https://wiki.octave.org/Compatibility
