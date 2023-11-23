% Copyright (c) 2022 Jakub Skoda
% Released under the MIT License.

% Change the current folder to the folder of this m-file.
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end

run('Common.m');
filpath = 'Partial1000/';
mkdir(filpath)


% Computation parameters
coher_type = 'part';
windTime_size = 2;
windScale_size = 2;
n_sur = 1000; % must be used for credible significance levels
%n_sur = 1; %  innacurate results use for testing
p = 1;
q = 1; 


% Plotting parameters
pictEnh = 5; %Picture enhancer    
    
perc5 = 5/100;  % Percentil 5
perc10 = 10/100;  % Percentil 10
    
xlim = [t(1) t(end)+dt];
xticks = 1970:5:2020.25;
    
yticksLab = [1.5 4 8 20];
yticks = log2(yticksLab);

% Generates permutations for all various combinations of three elements
% 4 variables result in 24 different permutations
Comb = [];
K = 1 : Xsize;
for k = 1 : Xsize   
 Comb = cat(1,Comb, perms(K(~ismember(K,k))));
end

CombSize = size(Comb,1);

WPCO = cell(2,CombSize);
periods = cell(2,CombSize);
coi = cell(2,CombSize);
pvP = cell(2,CombSize);
PWGain = cell(2,CombSize);

% ----- Computation of partial wavelet coherency --------

%for l = 1:CombSize % to compute all possible combinations
for l = [1, 3, 19, 12, 18] % compute only those used in the thesis
Y = X(:,Comb(l,:));
  for k = [2, 3]
  index_partial = k;

%[~,WPCO,~,~,~,pvP,PWGain] = ...
 [~,WPCO{k-1,l},periods{k-1,l},coi{k-1,l},~,pvP{k-1,l},PWGain{k-1,l}] = ...
            MPAWCOG(Y,dt,dj,low_period,up_period,pad,mother,beta,gamma,...
            coher_type,index_partial,windTime_size,...
            windScale_size,n_sur,p,q);
            fprintf("Computatation finished for l=%i, k=%i.\n",l,k);
  end
end

save(strcat(filpath,'Workspace-n_sur_',num2str(n_sur),'-',num2str(now)))

  
% ----- Plot of partial wavelet coherency --------  

fig_count =  1;  

%for l = 1:CombSize % to plot all possible combinations
for l = [1, 3, 19, 12, 18] % plot only those used in the thesis
c1 = Comb(l,1);
c2 = Comb(l,2);
c3 = Comb(l,3);  
   for k = [2, 3]
  Description = strcat(names{c1},'-',names{c2},'-',names{c3},'\_partial',num2str(k));
  filname = strcat(names{c1},'-',names{c2},'-',names{c3},'_partial',num2str(k));       
            
  fig = figure(fig_count);
   set(fig, 'PaperPositionMode', 'manual')
   set(fig, 'PaperUnits', 'centimeters')
   set(fig, 'PaperPosition', [0 0 10 10])         
            
   plotPCInf = subplot(1,1,1);

    ylim = log2([min(periods{k-1,l}),max(periods{k-1,l})]);
        
    imagesc(t,log2(periods{k-1,l}),abs(WPCO{k-1,l}).^pictEnh);
    grid on;
    set(plotPCInf,'XLim',xlim,'XTick',xticks);
    set(plotPCInf,'YLim',ylim, 'YTick',yticks,'YTickLabel',yticksLab, ...
        'YDir','reverse','FontSize',7)
    %title(Description,'FontSize',10,'FontName','arial');
    ylabel('Period (years)','FontSize',8);
    hold on
    colormap jet
    caxis('manual')
    % Plot COI
    plot(t,log2(coi{k-1,l}),'k');
    % Plot levels of significance  
        contour(t,log2(periods{k-1,l}),pvP{k-1,l},[perc5 perc5],'k-','LineWidth',1.5);
     % 'Edgecolor',[.5 .5 .5], is not recognized by Octave   
     if (is_octave)
     contour(t,log2(periods{k-1,l}),pvP{k-1,l},[perc10 perc10],'LineWidth',1.5);
     else
     contour(t,log2(periods{k-1,l}),pvP{k-1,l},[perc10 perc10],'Edgecolor',[.5 .5 .5],'LineWidth',1.5);
     end
    hold off
    
   %fig_count = fig_count + 1; % each plot in separate window
   print(strcat(filpath,filname),filform)
 end
end
