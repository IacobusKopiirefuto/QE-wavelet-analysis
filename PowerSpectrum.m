% Copyright (c) 2022 Jakub Skoda
% Released under the MIT License.

% Change the current folder to the folder of this m-file.
if(~isdeployed)
  cd(fileparts(which(mfilename)));
end

run('Common.m');

filpath = 'PowerSpectrumP/';
mkdir(filpath)

powername = 'PowerSpectrum-';

sig_type = 'AR0';

pictEnh = 2/5;  % Picture enhnacer
perc5 = 5/100;  % Percentil 5
perc10 = 10/100;% Percentil 10

%---------------- Computation ----------------------------------

% creating cells for saving the results
wave = cell(1,Xsize);
periods = cell(1,Xsize);
coi = cell(1,Xsize);
power = cell(1,Xsize);
pv_power = cell(1,Xsize);
maxPower = cell(1,Xsize);

for k = 1 : Xsize
      [wave{k},periods{k},coi{k},power{k},pv_power{k}] =...
        AWT(X(:,k),dt,dj,low_period,up_period,pad,mother,beta,gamma,sig_type);

      % Computation of Maxima (ridges)
      maxPower{k} = MatrixMax(power{k},3,.14);
end     

% saves results of the computation into a loadable file
save(strcat(filpath,'Workspace-PowerSpectrum-',num2str(now)))
% to convert now to date use datestr(now,'yyyy-mmmm-dd_HH:MM')

%---------------- Plots ----------------------------------------

for k = 1 : Xsize   
  %figure(k);
  figure(1);
     
    plotPOWER = subplot(1,1,1);

    ylim = log2([min(periods{k}),max(periods{k})]);
    yticks = [1.5 4 8 20]; 
    imagesc(t,log2(periods{k}),(power{k}).^pictEnh); 
    ylabel('Period (years)');
    grid on;
    set(plotPOWER,'XLim',xlim,'XTick',xticks);
    set(plotPOWER,'YLim',ylim,'YTick',log2(yticks), ...
        'YTickLabel',yticks,'YDir','reverse');
    set(plotPOWER,'FontSize',20);
    %title(names{k},'Fontsize',10);
    colormap jet; % To obtain the colors of the paper;
    caxis('manual'); % To hold colors (when we superimpose the 
                     % contours)
    hold on
    % Plot ridges
        contour(t,log2(periods{k}),maxPower{k},[1,1],'w-','LineWidth',1.5);
    % Pot COI
        plot(t,log2(coi{k}),'-k','LineWidth',1.25);
    % Plot levels of significance
        contour(t,log2(periods{k}),pv_power{k},[perc5,perc5],'k-','LineWidth',1.5);
        
     % 'Edgecolor',[.7 .7 .7], is not recognized by Octave   
     if (is_octave)
     contour(t,log2(periods{k}),pv_power{k},[perc10 perc10],'LineWidth',1.5);
     else
     contour(t,log2(periods{k}),pv_power{k},[perc10 perc10],'Edgecolor',[.7 .7 .7],'LineWidth',1.5);
     end
    hold off
    print(strcat(filpath,powername,names{k}),filform) % saves output
 end
