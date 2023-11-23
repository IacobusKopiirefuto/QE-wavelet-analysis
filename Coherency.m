% Copyright (c) 2022 Jakub Skoda
% Released under the MIT License.

% Change the current folder to the folder of this m-file.
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end
run('Common.m');

% parameters for easy saving of the output
filpath = 'CoherencyP/';
mkdir(filpath)

cohname = '-Coherency';
linname = '-PhaseDif_Gains';

% creating list of various combinations
Comb = nchoosek(1:Xsize,2)
CombSize = size(Comb,1)

% *******************  COHERENCY ************************************

% - Choice of size of windows for smoothing in coherency computation -
wt_size = 2; % Actual size used varies with scale s and
%              is given by:  wt_size*s/dt (with a minimum value of 5)
ws_size = 2; % Actual size used depends on dj and is 
%              given by: ws_size/(2*dj) (with a minimum value of 5)


% levels of significance are not computed
% no need to specify these parameters

% creating cells for saving the results
WCO = cell(1,CombSize);
periods = cell(1,CombSize);
coi = cell(1,CombSize);
WGain = cell(1,CombSize);

for k = 1 : CombSize
% Index numbers of current varialbes
c1 = Comb(k,1)
c2 = Comb(k,2)
   
% Computation of Coherency 
% [WCO,WCross,periods,coi,pv_WCO,WGain]
[WCO{k},~,periods{k},coi{k},~,WGain{k}] = ...
      AWCOG(X(:,c1),X(:,c2),dt,dj,low_period,up_period,pad,mother,beta,gamma,...
            wt_size,ws_size);
end

% saves results of the computation into a loadable file
save(strcat(filpath,'Workspace-Coherency-',num2str(now)))
% to convert now to date use datestr(now,'yyyy-mmmm-dd_HH:MM')

% ---------------- Plot of coherency ---------------------------

pict_enh = 5; % Picture enhancer
yticks_lab = [1.5 4 8 15 20];
yticks = log2(yticks_lab);

for k = 1 : CombSize
  c1 = Comb(k,1);
  c2 = Comb(k,2);
 
  logcoi = log2(coi{k});
  logperiods = log2(periods{k});

  %xlim = [t(1)-1 t(end)];
  %xticks = 0:40:200;
  ylim = [min(logperiods), max(logperiods)];

  % figure(1+2*(k-1)); % use to plot each in a separte window
  figure(1);
  plotCOHER = subplot(1,1,1);
  imagesc(t,log2(periods{k}), abs(WCO{k}).^pict_enh);
    colormap(jet)   
    grid on
    
   % x-axis labels 
   % most likely not needed, years get labeled just fine without it
   % set(plotCOHER,'XLim',xlim,'XTick',xticks);
    
   % y-axis labels 
   % when removed it labels axis as 0, to 4.5
   % this is same value as ylim, but is not dependant on it
   % adding number to yticks_lab yeild unexpected result as well
   % for explanation see https://www.mathworks.com/help/matlab/graphics-object-properties.html
   % especially https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html
     set(plotCOHER,'YLim',ylim,'YDir','reverse',...
        'YTick',yticks,'YTickLabel',yticks_lab);
   %     set(plotCOHER,'YDir','reverse');
        
    set(plotCOHER,'FontName','arial','FontSize',20); 
    %title(strcat(names{c1},'-',names{c2}),'FontSize',9);       
    ylabel('Period (years)','FontSize',20);
    
    % Plot the Cone Of Influence
    hold on
    plot(t,logcoi,'k');
    hold off
    
    % Saves output
    print(strcat(filpath,names{c1},'-',names{c2},cohname),filform)
end

%********************  PHASE-DIFFERENCES & GAINS *********************

% ----------  Choice of  bands for phase-differences -----------
lpf1 = 7.5;
upf1 = 8.5;

lpf2 = 10; 
upf2 = 12;

% creating cells for saving the results
phaseDif = cell(2,CombSize);
gain = cell(2,CombSize);

for k = 1 : CombSize
% Index numbers of current variables
c1 = Comb(k,1)
c2 = Comb(k,2)
              
% -------- Computation of (mean) phase-differences -------------

phaseDif{1,k}=MeanPHASE(WCO{k},periods{k},lpf1,upf1);
phaseDif{2,k}=MeanPHASE(WCO{k},periods{k},lpf2,upf2);

%  Computation of (mean) gains
gain{1,k} = MeanGAIN(WGain{k},periods{k},lpf1,upf1); 
gain{2,k} = MeanGAIN(WGain{k},periods{k},lpf2,upf2);
end

% ---------------- Plots of phases and gains -------------------
ylim_phase = [-pi-0.1 pi+0.1];
yticks_phase = -pi:pi/2:pi;
yticks_phase_lab = {'-pi','-pi/2','0','pi/2','pi'};

for k = 1 : CombSize
  
c1 = Comb(k,1);
c2 = Comb(k,2);
 
logcoi = log2(coi{k});
logperiods = log2(periods{k});

%xlim = [t(1)-1 t(end)];
%xticks = 0:40:200;
ylim = [min(logperiods), max(logperiods)];

 % --------------------- Plots of phases -------------------------
figure(2*k);
%figure(2);
 plotPHASE1 = subplot(3,2,1); % 2.5~3.5 freq. band
 	plot(t,phaseDif{1,k},'LineWidth',1,'Color','k');
    ylabel('7.5~8.5 freq. band');
    set(plotPHASE1,'XLim',xlim,'XTick',xticks)
    set(plotPHASE1,'YLim',ylim_phase,'YTick',yticks_phase,'YTickLabel',...
        yticks_phase_lab,'YGrid','on')
    set(plotPHASE1,'FontName','arial','FontSize',9)
    title(strcat('Phase-Difference of ',names{c1},'-',names{c2}),'FontSize',9)
   
plotPHASE2 = subplot(3,2,3); % 7.5~8.5 freq. band
    plot(t,phaseDif{2,k},'LineWidth',1,'Color','k'); 
    ylabel('10~12 freq. band');
    set(plotPHASE2,'XLim',xlim,'XTick',xticks)
    set(plotPHASE2,'YLim',ylim_phase,'YTick',yticks_phase,'YTickLabel',...
        yticks_phase_lab,'YGrid','on')
    set(plotPHASE2,'FontName','arial','FontSize',9)
 
% --------------------- Plots of  gains ------------------------
%ylimGain = [0 4];
%yticksGain = 0:4;

ylimGain1 = [min(gain{1,k}),max(gain{1,k})];
ylimGain2 = [min(gain{2,k}),max(gain{2,k})];

plotGAIN1 = subplot(3,2,2); % 2.5~3.5 freq. band
    plot(t,gain{1,k},'k-','LineWidth',1,'Color','k');
    ylabel('7.5~8.5 freq. band');
    set(plotGAIN1,'XLim',xlim,'XTick',xticks)
    set(plotGAIN1,'YLim',ylimGain1,'YGrid','on')
    % ,'YTick',yticksGain
    set(plotGAIN1,'FontName','arial','FontSize',9);    
    title({' Y=\alpha+\beta X'},...
           'FontSize',7)
    legend('|\beta|','Location','Best')
 
plotGAIN2 = subplot(3,2,4);% 7.5~8.5 freq. band
    plot(t,gain{2,k},'k-','LineWidth',1,'Color','k');
    ylabel('10~12 freq. band');   
   set(plotGAIN2,'XLim',xlim,'XTick',xticks)
   set(plotGAIN2,'YLim',ylimGain2,'YGrid','on')
   % 'YTick',yticksGain;
   set(plotGAIN2,'FontName','arial','FontSize',9); 
   legend('|\beta|','Location','Best')
   
   %print(strcat(filpath,names{c1},'-',names{c2},linname),filform)
end
