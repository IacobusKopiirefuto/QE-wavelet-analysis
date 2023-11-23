% Copyright (c) 2022 Jakub Skoda
% Released under the MIT License.

% Change the current folder to the folder of this m-file.
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end

run('Common.m');
load('Partial/Workspace-n_sur_1-738401.7879');

filpath = 'Partial-PhaseDiff/';
mkdir(filpath)


% Computation of mean partial phase differences (with 95% CIs)
 %  and mean gains (in three different frequency bands) 

% Short-cycles
    lpF0 = 1.5;
    upF0 = 4;
% Business-cycles
    lpF1 = 4;
    upF1 = 8;
% Long-cycles
    lpF2 = 8;
    upF2 = 20;
%
alfa = 0.05; % To compute 95% CI

phaseDif0 = cell(2,CombSize);
low_phaseDif0 = cell(2,CombSize);
up_phaseDif0 = cell(2,CombSize);

phaseDif1 = cell(2,CombSize);
low_phaseDif1 = cell(2,CombSize);
up_phaseDif1 = cell(2,CombSize);

phaseDif2 = cell(2,CombSize);
low_phaseDif2 = cell(2,CombSize);
up_phaseDif2 = cell(2,CombSize);

gain0 = cell(2,CombSize);
gain1 = cell(2,CombSize);
gain2 = cell(2,CombSize);

for l = 1 % :CombSize
  for k = [2, 3]
   % Computation of partial phase-differences
   % Message 'Cannot use Zar formula at point' is sometimes dysplayed
   % see line 176 of MeanPHASE.m form ASToolbox2018 for more information
  [phaseDif0{k-1,l},low_phaseDif0{k-1,l},up_phaseDif0{k-1,l}] = MeanPHASE(WPCO{k-1,l},periods{k-1,l},lpF0,upF0,alfa);
  [phaseDif1{k-1,l},low_phaseDif1{k-1,l},up_phaseDif1{k-1,l}] = MeanPHASE(WPCO{k-1,l},periods{k-1,l},lpF1,upF1,alfa);
  [phaseDif2{k-1,l},low_phaseDif2{k-1,l},up_phaseDif2{k-1,l}] = MeanPHASE(WPCO{k-1,l},periods{k-1,l},lpF2,upF2,alfa);
  
  % Computation of Gains 
  gain0{k-1,l} = MeanGAIN(PWGain{k-1,l},periods{k-1,l},lpF0,upF0);
  gain1{k-1,l} = MeanGAIN(PWGain{k-1,l},periods{k-1,l},lpF1,upF1);
  gain2{k-1,l} = MeanGAIN(PWGain{k-1,l},periods{k-1,l},lpF2,upF2);
  end
end

save(strcat(filpath,'Workspace-n_sur_',num2str(n_sur),'-lp',num2str(lpF0),'_up',num2str(upF0),'-lp',num2str(lpF1),'_up',num2str(upF1),'-lp',num2str(lpF2),'_up',num2str(upF2),'-',num2str(now)))

% Phase-difference withOUT Partial coherency
% There seems to be still few bugs

ylimPhase = [-pi-0.5 pi+0.5];
yticksPhase = -pi: pi/2 : pi;
yticksPhaseLab = {'-pi','-pi/2','0','pi/2','pi'};

pause('on')
pause(2)

for l = 1 %:CombSize
c1 = Comb(l,1);
c2 = Comb(l,2);
c3 = Comb(l,3);  
  for k = 3 % [2, 3]
  Description = strcat(names{c1},'-',names{c2},'-',names{c3},'\_partial',num2str(k));
  filname = strcat(names{c1},'-',names{c2},'-',names{c3},'_partial',num2str(k));         
  fig = figure(1);
  set(fig, 'PaperPositionMode', 'manual')
  set(fig, 'PaperUnits', 'centimeters')
  set(fig, 'PaperPosition', [0 0 10 10])

  % Plots of partial phase-differences
  % 56 65
  plotDif0 = subplot(3,2,1);
  plot(t,phaseDif0{k-1,l},'LineWidth',1,'Color','k');
  % CIS
     hold on
     plot(t,low_phaseDif0{k-1,l},'k-.','LineWidth',0.75);
     plot(t,up_phaseDif0{k-1,l},'k-.','LineWidth',0.75);   
     grid on;
     set(plotDif0,'XLim',xlim,'XTick',xticks)
     set(plotDif0,'YLim',ylimPhase,'YTick',yticksPhase,...
        'YTickLabel',yticksPhaseLab,'FontSize',7);
     title('Partial Phase-difference','FontSize',10,'FontName','arial');
     ylabel('1.5~4 years');
     hold off
     
    plotDif1 = subplot(3,2,3);;
    plot(t,phaseDif1{k},'LineWidth',1,'Color','k');
    hold on
    plot(t,low_phaseDif1{k},'k-.','LineWidth',0.75);
    plot(t,up_phaseDif1{k},'k-.','LineWidth',0.75);
    ylabel('4~8 years');
    grid on;
    set(plotDif1,'XLim',xlim,'XTick',xticks)
    set(plotDif1,'YLim',ylimPhase,'YTick',yticksPhase,...
        'YTickLabel',yticksPhaseLab,'FontSize',7) 
    hold off
    
    plotDif2 =subplot(3,2,5);;
    plot(t,phaseDif2{k-1,l},'LineWidth',1,'Color','k');
    hold on
    plot(t,low_phaseDif2{k-1,l},'k-.','LineWidth',0.75);
    plot(t,up_phaseDif2{k-1,l},'k-.','LineWidth',0.75);  
    ylabel('8~20 years');
    grid on;
    set(plotDif2,'XLim',xlim,'XTick',xticks)
    set(plotDif2,'YLim',ylimPhase,'YTick',yticksPhase,...
        'YTickLabel',yticksPhaseLab,'FontSize',7) 
hold off

     
     % Plots of  Gains
     ylimGain0 = [min(gain0{k-1,l}),max(gain0{k-1,l})];
     ylimGain1 = [min(gain1{k-1,l}),max(gain1{k-1,l})];
     ylimGain2 = [min(gain2{k-1,l}),max(gain2{k-1,l})];
  
  plotGain0 = subplot(3,2,2);;
        plot(t,gain0{k-1,l},'LineWidth',1,'Color','k');
        ylabel('1.5~4 years');
        legend('| \beta |','Location','Best')
        % Octave warning: legend: 'best' not yet implemented for location specifier, using 'northeast' instead
        grid on;
        set(plotGain0,'XLim',xlim,'XTick',xticks)
        set(plotGain0,'YLim',ylimGain0,'FontSize',7);
        % 'YTick',0:.5:3,
        title('FFR = \alpha + \beta \pi + \gamma y','FontSize',10,'FontName','arial')
        
  plotGain1 = subplot(3,2,4);;
        plot(t,gain1{k-1,l},'LineWidth',1,'Color','k');
        ylabel('4~8 years');
        legend('| \beta |','Location','Best')
        grid on;
        set(plotGain1,'XLim',xlim,'XTick',xticks)           
        set(plotGain1,'YLim',ylimGain1,'FontSize',7)
        % 'YTick', 0:.5:3
        
  plotGain2 = subplot(3,2,6);;
        plot(t,gain2{k-1,l},'LineWidth',1,'Color','k');
        ylabel('8~20 years');
        legend('| \beta |','Location','Best')
        grid on;
        set(plotGain2,'XLim',xlim,'XTick',xticks)
        set(plotGain2 ,'YLim',ylimGain2,'FontSize',7)
        % ,'YTick',0:.5:3
   
  axes( 'visible', 'off', 'title', Description); 
  %print(strcat(filpath,filname),filform,'-r7086')
  % '-r7086; ,'-r0'
  end
end

