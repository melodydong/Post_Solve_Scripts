%% Generate Plots for Aorta-Iliac Arteries with Pulse inlet flow and R BC


%% Flow plots
% Read flow data
flow1D = [];
vasculatureFlow = [];
temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_0_flow.dat');
[rows, ~] = size(temp);
flow1D(1,:) = temp(rows,:);
vasculatureFlow(1,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_7_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(2,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_17_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_22_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_29_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_36_flow.dat');
[rows, ~] = size(temp);
flow1D(2,:) = temp(rows,:);
vasculatureFlow(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rceliac_branch_3_flow.dat');
[rows, ~] = size(temp);
flow1D(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rceliac_trunk_8_flow.dat');
[rows, ~] = size(temp);
flow1D(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rleft_internal_iliac_16_flow.dat');
[rows, ~] = size(temp);
flow1D(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rrenal_left_7_flow.dat');
[rows, ~] = size(temp);
flow1D(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rrenal_right_7_flow.dat');
[rows, ~] = size(temp);
flow1D(7,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rright_iliac_16_flow.dat');
[rows, ~] = size(temp);
flow1D(8,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rright_internal_iliac_11_flow.dat');
[rows, ~] = size(temp);
flow1D(9,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rsuperior_mesentaric_12_flow.dat');
[rows, ~] = size(temp);
flow1D(10,:) = temp(rows,:);

inflow = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/Flow-Files/pulsatile.flow');
F = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-converted-results/all_results-flows.txt','\t',1);
flow3D = F.data;
flow3D(:,2) = -1.*flow3D(:,2);

FF = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-Deformable-converted-results/all_results-flows.txt','\t',1);
flow3DFSI = FF.data;
flow3DFSI(:,2) = -1.*flow3DFSI(:,2);

%%%%%%%%%%%% SET UP TIME ARRAYS %%%%%%%%%%%%%

% Get info for 1D data
[~, numSteps] = size(flow1D);
% how many save steps in one cardiac cycle (i.e. 1 second)
cycle = 40;
dt = 0.02;
% convert times to seconds
t = 0:dt:cycle*dt;
% only plot the last cardiac cycle
tt = numSteps-cycle:numSteps;

% Do the same for 3D data
cycle3D = 40;
dt3D = 0.02;
[numSteps3D,~] = size(flow3D);
% convert time to seconds
t3D = 0:dt3D:cycle3D*dt3D;
% only plot last cardiac cycle
tt3D = numSteps3D-cycle3D:numSteps3D;


%%%%%%%%%%%% GENERATE PLOTS %%%%%%%%%%%%%

% Branch Labels
branches = {'Aorta Inlet', 'Left Iliac', 'Celiac Branch', 'Celiac Trunk', ... 
    'Left Internal Iliac', 'Left Renal', 'Right Renal', 'Right Iliac', ...
    'Right Internal Iliac', 'Superior Mesentaric', 'Input Flow'}; 

% Plot all flows
figureNum = 1;
figure(figureNum)
figureNum = figureNum + 1;

% Make colors for 3 of the same color plotted in a row
co = [0    0.4470    0.7410;
    0    0.4470    0.7410;
    0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.8500    0.3250    0.0980;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.9290    0.6940    0.1250;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4940    0.1840    0.5560;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.4660    0.6740    0.1880;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.3010    0.7450    0.9330;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840;
    0.6350    0.0780    0.1840;
    0.6350    0.0780    0.1840
    0         0         1
    0         0         1
    0         0         1
    1         0         0
    1         0         0
    1         0         0
    1         0         1
    1         0         1
    1         0         1];
set(groot,'defaultAxesColorOrder',co);
hold on

for i = 2:size(flow1D)
    name = sprintf('%s 1D',branches{i});
    plot(t,flow1D(i,tt),'DisplayName',name,'LineWidth',2);
    name = sprintf('%s 3D',branches{i});
    plot(t3D,flow3D(tt3D,i+1),':','DisplayName',name,'LineWidth',2);
    name = sprintf('%s 3D FSI',branches{i});
    plot(t3D,flow3DFSI(tt3D,i+1),'--','DisplayName',name,'LineWidth',2);
end
%name = sprintf('%s',branches{11});
%plot(inflow(:,1),inflow(:,2),'--k','DisplayName',name,'LineWidth',2);

% show legend
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 16;
legend('boxOff')
xlim([0 cycle*dt])
xlabel('time (s)','FontSize',18)
ylabel('flow (cm/s)','FontSize',18)
set(gca,'FontSize',16)
% title('Flow at outlet of branches in Aorta-Iliac model (Pulsatile flow, R BC)')
title('Flow at outlet of branches in Aorta-Iliac model')


% Plot flows at each outlet individually
for i = 1:size(flow1D)
    figure(figureNum)
    figureNum = figureNum + 1;
    
    % Reset colors
    co = [0    0.4470    0.7410;
        0.4660    0.6740    0.1880;
        0.6350    0.0780    0.1840;
        0.8500    0.3250    0.0980;
        0.9290    0.6940    0.1250;
        0.4940    0.1840    0.5560;
        0.3010    0.7450    0.9330;
        0         0         1
        1         0         0
        1         0         0];
    set(groot,'defaultAxesColorOrder',co);
    hold on
    
    plot(t,flow1D(i,tt),'DisplayName','1D','LineWidth',2);
    plot(t3D,flow3D(tt3D,i+1),'-.','DisplayName','3D Rigid','LineWidth',2);
    plot(t3D,flow3DFSI(tt3D,i+1),'-.','DisplayName','3D FSI','LineWidth',2);

    % show legend
    lgd = legend('show','Location','northeast');
    lgd.FontSize = 16;
    xlim([0 cycle*dt])
    xlabel('time (s)','FontSize',18)
    ylabel('flow (cm/s)','FontSize',18)
    set(gca,'FontSize',16)
%     name = sprintf('Flow at %s outlet in Aorta-Iliac model (Pulsatile flow, R BC)',branches{i});
    name = sprintf('Flow at %s outlet in Aorta-Iliac model',branches{i});
    title(name,'FontSize',18)
end


% Plot flows along geometry
figure(figureNum)
figureNum = figureNum + 1;
hold on

% Add labels
Labels = {'Aorta Inlet (segment 0)','Segment 7','Iliac Bifurcation (segment 17)','Segment 22','Segment 29','Aorta Outlet (segment 36)'};

[m,~] = size(vasculatureFlow);
for i = 1:m
    name = sprintf('%s',Labels{i});
    plot(t,vasculatureFlow(i,tt),'DisplayName',name);
end

% show legend
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 16;
legend('boxOff')
xlim([0 cycle*dt])
xlabel('time (s)','FontSize',18)
ylabel('flow (cm/s)','FontSize',18)
set(gca,'FontSize',16)
% title('Flow along aorta in Aorta-Iliac model (Pulsatile flow, R BC)')
title('Flow along aorta in Aorta-Iliac model','FontSize',18)


%% Pressure Plots

% Read pressure data
pressure1D = [];
vasculaturePressure = [];
temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_0_pressure.dat');
[rows, ~] = size(temp);
pressure1D(1,:) = temp(rows,:);
vasculaturePressure(1,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_7_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(2,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_17_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_22_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_29_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Raorta_36_pressure.dat');
[rows, ~] = size(temp);
pressure1D(2,:) = temp(rows,:);
vasculaturePressure(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rceliac_branch_3_pressure.dat');
[rows, ~] = size(temp);
pressure1D(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rceliac_trunk_8_pressure.dat');
[rows, ~] = size(temp);
pressure1D(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rleft_internal_iliac_16_pressure.dat');
[rows, ~] = size(temp);
pressure1D(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rrenal_left_7_pressure.dat');
[rows, ~] = size(temp);
pressure1D(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rrenal_right_7_pressure.dat');
[rows, ~] = size(temp);
pressure1D(7,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rright_iliac_16_pressure.dat');
[rows, ~] = size(temp);
pressure1D(8,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rright_internal_iliac_11_pressure.dat');
[rows, ~] = size(temp);
pressure1D(9,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-1D/TXT/OSMSC0006_Pulse_Rsuperior_mesentaric_12_pressure.dat');
[rows, ~] = size(temp);
pressure1D(10,:) = temp(rows,:);
% Convert from Barye to mmHg
pressure1D = 0.0007500616827.*pressure1D;
vasculaturePressure = 0.0007500616827.*vasculaturePressure; 

P = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-converted-results/all_results-pressures.txt','\t',1);
pressure3D = P.data;
% Convert from Barye to mmHg
pressure3D = 0.0007500616827.*pressure3D;

PP = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Pulse-Deformable-converted-results/all_results-pressures.txt','\t',1);
pressure3DFSI = PP.data;
% Convert from Barye to mmHg
pressure3DFSI = 0.0007500616827.*pressure3DFSI;

%%%%%%%%%%%% GENERATE PLOTS %%%%%%%%%%%%%

% Plot all pressures
figure(figureNum)
figureNum = figureNum + 1;

% Make colors for 3 of the same color plotted in a row
co = [0    0.4470    0.7410;
    0    0.4470    0.7410;
    0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.8500    0.3250    0.0980;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.9290    0.6940    0.1250;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4940    0.1840    0.5560;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.4660    0.6740    0.1880;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.3010    0.7450    0.9330;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840;
    0.6350    0.0780    0.1840;
    0.6350    0.0780    0.1840
    0         0         1
    0         0         1
    0         0         1
    1         0         0
    1         0         0
    1         0         0
    1         0         1
    1         0         1
    1         0         1];
set(groot,'defaultAxesColorOrder',co);
hold on

for i = 1:size(pressure1D)
    name = sprintf('%s 1D',branches{i});
    plot(t,pressure1D(i,tt),'DisplayName',name,'LineWidth',2);
    name = sprintf('%s 3D',branches{i});
    plot(t3D,pressure3D(tt3D,i+1),':','DisplayName',name,'LineWidth',2);
    name = sprintf('%s 3D FSI',branches{i});
    plot(t3D,pressure3DFSI(tt3D,i+1),'-.','DisplayName',name,'LineWidth',2);
end

% show legend
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 16;
legend('boxOff')
xlim([0 cycle*dt])
xlabel('time (s)','FontSize',18)
ylabel('pressure (mmHg)','FontSize',18)
set(gca,'FontSIze',18)
% title('Pressure at outlet of branches in Aorta-Iliac model (Pulsatile flow, R BC)')
title('Pressure at outlet of branches in Aorta-Iliac model','FontSize',18)


% Plot pressures at each outlet individually
for i = 1:size(pressure1D)
    figure(figureNum)
    figureNum = figureNum + 1;
    
    % Reset colors
    co = [0    0.4470    0.7410;
        0.4660    0.6740    0.1880;
        0.6350    0.0780    0.1840;
        0.8500    0.3250    0.0980;
        0.9290    0.6940    0.1250;
        0.4940    0.1840    0.5560;
        0.3010    0.7450    0.9330;
        0         0         1
        1         0         0
        1         0         0];
    set(groot,'defaultAxesColorOrder',co);
    hold on
    
    plot(t,pressure1D(i,tt),'DisplayName','1D','LineWidth',2);
    plot(t3D,pressure3D(tt3D,i+1),':','DisplayName','3D Rigid','LineWidth',2);
    plot(t3D,pressure3DFSI(tt3D,i+1),'-.','DisplayName','3D FSI','LineWidth',2);
    
    % show legend
    lgd = legend('show','Location','northeast');
    lgd.FontSize = 16;
    xlim([0 cycle*dt])
    xlabel('time (s)','FontSize',18)
    ylabel('pressure (mmHg)','FontSize',18)
    set(gca,'FontSize',16)
%     name = sprintf('Pressure at %s outlet in Aorta-Iliac model (Pulsatile flow, R BC)',branches{i});
    name = sprintf('Pressure at %s outlet in Aorta-Iliac model',branches{i});
    title(name,'FontSize',18)
end


% Plot pressure along geometry
figure(figureNum)
figureNum = figureNum + 1;
hold on

% Add labels
Labels = {'Aorta Inlet (segment 0)','Segment 7','Iliac Bifurcation (segment 17)','Segment 22','Segment 29','Aorta Outlet (segment 36)'};

[m,~] = size(vasculaturePressure);
for i = 1:m
    name = sprintf('%s',Labels{i});
    plot(t,vasculaturePressure(i,tt),'DisplayName',name);
end

% show legend
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 16;
legend('boxOff')
xlim([0 cycle*dt])
xlabel('time (s)','FontSize',18)
ylabel('pressure (mmHg)','FontSize',18)
set(gca,'FontSize',16)
% title('Pressure along aorta in Aorta-Iliac model (Pulsatile flow, R BC)')
title('Pressure along aorta in Aorta-Iliac model','FontSize',18)

