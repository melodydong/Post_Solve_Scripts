%% Generate Plots for Aorta-Iliac Arteries with Steady inlet flow and R BC


%% Flow plots
% Read flow data
flow1D = [];
vasculatureFlow = [];
temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_0_flow.dat');
[rows, ~] = size(temp);
flow1D(1,:) = temp(rows,:);
vasculatureFlow(1,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_7_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(2,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_17_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_22_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_29_flow.dat');
[rows, ~] = size(temp);
vasculatureFlow(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_36_flow.dat');
[rows, ~] = size(temp);
flow1D(2,:) = temp(rows,:);
vasculatureFlow(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rceliac_branch_3_flow.dat');
[rows, ~] = size(temp);
flow1D(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rceliac_trunk_8_flow.dat');
[rows, ~] = size(temp);
flow1D(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rleft_internal_iliac_16_flow.dat');
[rows, ~] = size(temp);
flow1D(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rrenal_left_7_flow.dat');
[rows, ~] = size(temp);
flow1D(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rrenal_right_7_flow.dat');
[rows, ~] = size(temp);
flow1D(7,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rright_iliac_16_flow.dat');
[rows, ~] = size(temp);
flow1D(8,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rright_internal_iliac_11_flow.dat');
[rows, ~] = size(temp);
flow1D(9,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rsuperior_mesentaric_12_flow.dat');
[rows, ~] = size(temp);
flow1D(10,:) = temp(rows,:);

inflow = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/Flow-Files/steady.flow');
F = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-converted-results/all_results-flows.txt','\t',1);
flow3D = F.data;
flow3D(:,2) = -1.*flow3D(:,2);

FF = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-Deformable-converted-results/all_results-flows.txt','\t',1);
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
cycle3D = 29;
dt3D = 0.02;
[numSteps3D,~] = size(flow3D);
% convert time to seconds
t3D = 0:dt3D:cycle3D*dt3D;
% only plot last cardiac cycle
tt3D = numSteps3D-cycle3D:numSteps3D;

% Do the same for 3D data
cycle3DF = 40;
dt3DF = 0.02;
[numSteps3DF,~] = size(flow3DFSI);
% convert time to seconds
t3DF = 0:dt3DF:cycle3DF*dt3DF;
% only plot last cardiac cycle
tt3DF = numSteps3DF-cycle3DF:numSteps3DF;

%%%%%%%%%%%% GENERATE PLOTS %%%%%%%%%%%%%

% Branch Labels
branches = {'Aorta Inlet', 'Aorta Outlet', 'Celiac Branch', 'Celiac Trunk', ... 
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
    plot(t3DF,flow3DFSI(tt3DF,i+1),'--','DisplayName',name,'LineWidth',2);
end
%name = sprintf('%s',branches{11});
%plot(inflow(:,1),inflow(:,2),'--k','DisplayName',name,'LineWidth',2);

% show legend
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
legend('boxOff')
xlim([0 cycle*dt])
xlabel('time (s)')
ylabel('flow (cm/s)')
title('Flow at outlet of branches in Aorta-Iliac model (Steady flow, R BC)')


% Plot flows at each outlet individually
figure(figureNum)
figureNum = figureNum + 1;
hold on

b = bar([flow1D(:,end),flow3D(end,2:end)',flow3DFSI(end,2:end)'],0.3);
colors = [0    0.4470    0.7410;
      0.8500    0.3250    0.0980;
      0.9290    0.6940    0.1250];
b(1).FaceColor = colors(1,:);
b(2).FaceColor = colors(2,:);
b(3).FaceColor = colors(3,:);

% Show legend
legend('1D','3D Rigid','3D FSI');

% Set axis labels and title
set(gca, 'XTick', 1:size(flow1D), 'XTickLabel', branches);
ax = gca;
ax.XTickLabelRotation = 45;
ylabel('flow (cm/s)')
name = sprintf('Flow at outlets in Aorta-Iliac model (Steady flow, R BC)');
title(name)

% Plot flows along aorta geometry
figure(figureNum)
figureNum = figureNum + 1;

xloc = 2:2:12;
b = bar(xloc,vasculatureFlow(:,end),0.4);
b.FaceColor = colors(1,:);

% Add labels
Labels = {'Aorta Inlet (segment 0)','Segment 7','Iliac Bifurcation (segment 17)','Segment 22','Segment 29','Aorta Outlet (segment 36)'};

% Set axis labels and title
set(gca, 'XTick', xloc, 'XTickLabel', Labels);
ax = gca;
ax.XTickLabelRotation = 45; 
ylabel('flow (cm/s)')
title('Flow along aorta in Aorta-Iliac model (Steady flow, R BC)')



%% Pressure Plots

% Read pressure data
pressure1D = [];
vasculaturePressure = [];
temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_0_pressure.dat');
[rows, ~] = size(temp);
pressure1D(1,:) = temp(rows,:);
vasculaturePressure(1,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_7_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(2,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_17_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_22_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_29_pressure.dat');
[rows, ~] = size(temp);
vasculaturePressure(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Raorta_36_pressure.dat');
[rows, ~] = size(temp);
pressure1D(2,:) = temp(rows,:);
vasculaturePressure(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rceliac_branch_3_pressure.dat');
[rows, ~] = size(temp);
pressure1D(3,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rceliac_trunk_8_pressure.dat');
[rows, ~] = size(temp);
pressure1D(4,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rleft_internal_iliac_16_pressure.dat');
[rows, ~] = size(temp);
pressure1D(5,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rrenal_left_7_pressure.dat');
[rows, ~] = size(temp);
pressure1D(6,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rrenal_right_7_pressure.dat');
[rows, ~] = size(temp);
pressure1D(7,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rright_iliac_16_pressure.dat');
[rows, ~] = size(temp);
pressure1D(8,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rright_internal_iliac_11_pressure.dat');
[rows, ~] = size(temp);
pressure1D(9,:) = temp(rows,:);

temp = load('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-1D/TXT/OSMSC0006_Steady_Rsuperior_mesentaric_12_pressure.dat');
[rows, ~] = size(temp);
pressure1D(10,:) = temp(rows,:);
% Convert from Barye to mmHg
pressure1D = 0.0007500616827.*pressure1D;
vasculaturePressure = 0.0007500616827.*vasculaturePressure; 

P = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-converted-results/all_results-pressures.txt','\t',1);
pressure3D = P.data;
% Convert from Barye to mmHg
pressure3D = 0.0007500616827.*pressure3D;

PP = importdata('/Users/caseyfleeter/Documents/MarsdenResults/1DSolverComparison/OSMSC0006-NewSV/Simulations/R-Steady-Deformable-converted-results/all_results-pressures.txt','\t',1);
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
    plot(t3DF,pressure3DFSI(tt3DF,i+1),'-.','DisplayName',name,'LineWidth',2);
end

% show legend
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
legend('boxOff')
xlim([0 cycle*dt])
xlabel('time (s)')
ylabel('pressure (mmHg)')
title('Pressure at outlet of branches in Aorta-Iliac model (Steady flow, R BC)')


% Plot pressures at each outlet individually
figure(figureNum)
figureNum = figureNum + 1;
hold on

b = bar([pressure1D(:,end),pressure3D(end,2:end)',pressure3DFSI(end,2:end)'],0.3);
colors = [0    0.4470    0.7410;
      0.8500    0.3250    0.0980;
      0.9290    0.6940    0.1250];
b(1).FaceColor = colors(1,:);
b(2).FaceColor = colors(2,:);
b(3).FaceColor = colors(3,:);

% Show legend
legend('1D','3D Rigid','3D FSI');   

% Set axis labels and title
set(gca, 'XTick', 1:size(pressure1D), 'XTickLabel', branches);
ax = gca;
ax.XTickLabelRotation = 45;
ylabel('Pressure (mmHg)')
name = sprintf('Pressure at outlet in Aorta-Iliac model (Steady flow, R BC)');
title(name)


% Plot pressure along geometry
figure(figureNum)
figureNum = figureNum + 1;

xloc = 2:2:12;
b = bar(xloc,vasculaturePressure(:,end),0.4);
b.FaceColor = colors(1,:);

% Add labels
label1 = sprintf('Aorta Inlet (segment 0)');
label2 = sprintf('Iliac Bifurcation (segment 17)');
label3 = sprintf('Aorta Outlet (segment 36)');
Labels = {label1,'Segment 7',label2,'Segment 22','Segment 29',label3};

% Set axis labels and title
set(gca, 'XTick', xloc, 'XTickLabel', Labels);
ax = gca;
ax.XTickLabelRotation=45;
ylabel('Pressure (mmHg)')
title('Pressure along aorta in Aorta-Iliac model (Steady flow, R BC)')
