% Copyright (c) 2022 Jakub Skoda
% Released under the MIT License.

% Change the current folder to the folder of this m-file.
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end
run('Common.m');

filpath = 'Multiple5000/';
mkdir(filpath)

% pkg load control                  
                  
% Parameters for computing levels of significance
n_sur = 1; % Levels of sig. will be very inaccurate with this small
           % number of surrogates; use it just to test!
n_sur = 5000; % What must be used for credible significance levels! 
%               WARNING: TAKES VERY LONG!
                  
             
% Window sizes for smoothing (for coherency and gain)
windTime_size = 2;
windScale_size = 2;
p = 1; 
q = 1; % Surrogates based on an ARMA(1,1) model

% PLOTS  
fig = figure(1);
set(fig, 'PaperPositionMode', 'manual')
set(fig, 'PaperUnits', 'centimeters')
set(fig, 'PaperPosition', [0 0 10 10])

xlim = [t(1) t(end)+dt];
xticks = 1970:5:2020.25;

yticksLab = [1.5 4 8 20];
yticks = log2(yticksLab);

ylimPhase = [-pi-0.5 pi+0.5];
yticksPhase = -pi: pi/2 : pi;
yticksPhaseLab = {'-pi','-pi/2','0','pi/2','pi'};

perc5 = 5/100;  % Percentil 5
perc10 = 10/100;  % Percentil 10


% generates special combination-permutations of elements
% matters on the order of the first element
% the other two are just combinations where order does not matter
% 4 variables result in 12 different 'combinations'
%Comb = [];
%K = 1 : Xsize;
%for k = 1 : Xsize   
% Comb = cat(1,Comb,cat(2, ones(size(Ck,1),1)*k, nchoosek(K(~ismember(K,k)),2)));
 % nchoose seek generates combination of two for all numbers from 1 to Xsize, beside number k
 % vetrical vector with all numbers of value k is added as the frist columns
 % this is added to matrix of previous 'combinations'.
%end

% Generates permutations for all various combinations of three elements
% 4 variables result in 24 different permutations
Comb = [];
K = 1 : Xsize;
for k = 1 : Xsize   
 Comb = cat(1,Comb, perms(K(~ismember(K,k))));
end

%-----------------------------------------------------------
% MAIN COMPUTATIONS
% Computation of multiple wavelet coherency

% and of complex partial wavelet coherency and complex partial gain 
%coher_type = 'both';
%index_partial = 1;
%[WMCO,WPCO{1},periods,coi,pvM,pvP{1},PWGain{1}] = ...
%   MPAWCOG(X,dt,dj,low_period,up_period,pad,mother,beta,gamma,...
%           coher_type,index_partial,windTime_size,...
%           windScale_size,n_sur,p,q); 


CombSize = size(Comb,1);

WMCO = cell(1,CombSize);
pvM = cell(1,CombSize);

periods = cell(1,CombSize);
coi = cell(1,CombSize);

%for l = 1:CombSize % to compute all possible combinations
for l = [1,19] % only these two are used in the thesis
  Y = X(:,Comb(l,:));
  Ysize = size(Y,2);

  c1 = Comb(l,1);
  c2 = Comb(l,2);
  c3 = Comb(l,3);
           
  coher_type = 'mult';
  index_partial = [];
  [WMCO{l},~,periods{l},coi{l},pvM{l}] = ...
     MPAWCOG(Y,dt,dj,low_period,up_period,pad,mother,beta,gamma,...
             coher_type,index_partial,windTime_size,...
             windScale_size,n_sur,p,q); 
  fprintf("Computatation finished for l=%i.\n",l);
end

% saves results of the computation into a loadable file
save(strcat(filpath,'Workspace-n_sur_',num2str(n_sur),'-',num2str(now)))
% to convert now to date use datestr(now,'yyyy-mmmm-dd_HH:MM')

% -------------- Plot of multiple wavelet coherency ------------------

%for l = 1:CombSize % to plot all possible combinations
for l = [19, 1] % only these two are used in the thesis
  c1 = Comb(l,1);
  c2 = Comb(l,2);
  c3 = Comb(l,3);  
  
  ylim = log2([min(periods{l}),max(periods{l})]);
  plotMC =  subplot(1,1,1);
  %fig = figure(l);
  fig = figure(1);
  % subplot(50,3,[1 40]);
    pictEnh = 20; % Picture enhancer    
    imagesc(t,log2(periods{l}), abs(WMCO{l}).^pictEnh);
    ylabel('Period (years)');
    grid on
    set(plotMC,'XLim',xlim,'XTick',xticks);
    set(plotMC,'YLim',ylim, 'YTick',yticks,'YTickLabel',yticksLab, ... 
        'YDir','reverse','FontSize',20);
    %title(strcat('Multiple Coherency:',names{c1},', ',names{c2},', ',names{c3}),'FontSize',8,'FontName','arial');
    colormap jet
    caxis('manual')
    hold on
    % Plot COI
    plot(t,log2(coi{l}),'k');
    % Plot levels of significance
        contour(t,log2(periods{l}),pvM{l},[perc5 perc5],'k-','LineWidth',1.5);
        
     % 'Edgecolor',[.5 .5 .5], is not recognized by Octave   
     if (is_octave)
     contour(t,log2(periods{l}),pvM{l},[perc10 perc10],'LineWidth',1.5);
     else
     contour(t,log2(periods{l}),pvM{l},[perc10 perc10],'Edgecolor',[.5 .5 .5],'LineWidth',1.5);
     end
    hold off 

    print(strcat(filpath,names{c1},'_',names{c2},'_',names{c3}),'-dpng')
end

% All its periods are EQUAL
% isequal(periods{1,1},periods{1,2},periods{1,3},periods{1,4},periods{1,5},periods{1,6},periods{1,7},periods{1,8},periods{1,9},periods{1,10},periods{1,11},periods{1,12})
% ans = 1

% All its coi are EQUAL
% isequal(coi{1,1},coi{1,2},coi{1,3},coi{1,4},coi{1,5},coi{1,6},coi{1,7},coi{1,8},coi{1,9},coi{1,10},coi{1,11},coi{1,12})ans = 1
% ans = 1


% Permutation of same elements have different values 
% in WMCO sometimes even up to 0.73
% max(max(abs(WMCO{1,6} - WMCO{1,9})))
% average error is up to 0.067
% (sum(sum(abs(WMCO{1,9} - WMCO{1,12}))) )/(size(WMCO{1,6},1)*size(WMCO{1,6},2))


% This is however not dissimilar to permutations of elements with at least one different variable
%for k = 1:11
%(sum(sum(abs(WMCO{1,k} - WMCO{1,12}))) )/(size(WMCO{1,6},1)*size(WMCO{1,6},2))
%end
%ans = 0.1062
%ans = 0.1086
%ans = 0.1001
%ans = 0.092026
%ans = 0.070090
%ans = 0.063108
%ans = 0.093361
%ans = 0.085241
%ans = 0.067200
%ans = 0.061029
%ans = 0.074357

%for k = 1:11
%max(max(abs(WMCO{1,k} - WMCO{1,12})))
%end
%ans = 0.9078
%ans = 0.6739
%ans = 0.8050
%ans = 0.7108
%ans = 0.5899
%ans = 0.6010
%ans = 0.7787
%ans = 0.8612
%ans = 0.7317
%ans = 0.7176
%ans = 0.6839


% there is also difference in pvM
% pvM only attains values 0 or 1
% Difference between permutations is up to 0.32
% (sum(sum(abs(pvM{1,9} - pvM{1,12}))) )/(size(pvM{1,6},1)*size(pvM{1,6},2))

% Difference between different permutation of variables is comperable
%for k = 4:11
%(sum(sum(abs(pvM{1,k} - pvM{1,12}))) )/(size(pvM{1,6},1)*size(pvM{1,6},2))
%end
%ans = 0.3260
%ans = 0.3051
%ans = 0.2294
%ans = 0.3062
%ans = 0.2571
%ans = 0.3184
%ans = 0.3037
%ans = 0.2310
