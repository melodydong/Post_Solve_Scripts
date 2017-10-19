%% Generate Plots for Pulmonary Arteries with Pulsatile inlet flow and R BC
% Adapted from Casey's R_Aorta_Pulse_New.m script
% Melody Dong 9/26/17

clear
clc
close all

direc = '/home/melody/PH/CHD_model/VSD_1DSolver/Q4R200/RCR_BC/Q4RCR_puls/';
cd(direc);
dat_list = dir('*.dat');
dat_names = {dat_list.name};
clearvars dat_list
prefix_name = 'PA_106bif_LINEAR_Q4_deform_RCR_puls';
path_nameQ4 = '/home/melody/PH/CHD_model/VSD_1DSolver/Q4R200/RCR_BC/Q4RCR_puls/PA_106bif_LINEAR_Q4_deform_RCR_puls';
path_nameQ12 = '/home/melody/PH/CHD_model/VSD_1DSolver/Q12R200/deform/puls/LPARPAall_mod3_LINEAR_Q12_deform';
% path_nameQ500 = '/home/melody/OneDSolver_Project/test_prof/onedsolver/test/Pulmonary_1D_Model/PA_10bif/PA_10bif_500FE/LPARPAtrunc';

% Branch Labels
branches = {'inflow', 'LPA1', 'LPA1_1', 'LPA1_1_1', 'LPA1_1_2', 'LPA1_1_2_1', 'LPA1_1_2_2', 'LPA1_1_3', ...
    'LPA1_2', 'LPA1_3', 'LPA1_3_1', 'LPA1_3_2', 'LPA1_4', 'LPA1_4_1', 'LPA2', 'LPA2_3', ...
    'LPA3', 'LPA3_1', 'LPA3_1_1', 'LPA3_2', 'LPA3_2_1', 'LPA3_3', 'LPA3_4', 'LPA4', ...
    'LPA5', 'LPA5_1', 'LPA6', 'LPA6_1', 'LPA7', 'LPA7_1', 'LPA8', 'LPA9', ...
    'LPA9_1', 'LPA9_2', 'LPA10', 'LPA10_1', 'LPA10_1_1', 'LPA10_1_2', 'LPA10_2', 'LPA10_3', ...
    'LPA_1', 'LPA_1_1', 'LPA_1_1_1', 'LPA_1_2', 'LPA_1_2_1', 'LPA_1_3', 'LPA_1_4', 'LPA_1_5', ...
    'LPA_1_6', 'LPA_1_7', 'LPA', 'RPA', 'RPA1', 'RPA1_1', 'RPA1_1_1', 'RPA1_1_2_2', 'RPA1_1_3', ...
    'RPA1_1_4', 'RPA1_2', 'RPA1_2_1', 'RPA1_2_2', 'RPA1_3', 'RPA1_4', 'RPA1_4_1', 'RPA1_4_1_1', ...
    'RPA1_4_1_1_1', 'RPA1_4_1_2', 'RPA1_4_1_2_1', 'RPA1_4_2', ...
    'RPA1_4_2_1', 'RPA1_4_3', 'RPA3', 'RPA3_1', 'RPA3_2', 'RPA3_3', 'RPA3_4', 'RPA3_5', ...
    'RPA4', 'RPA4_1', 'RPA4_2', 'RPA4_2_1', 'RPA4_3', 'RPA5', 'RPA5_1', 'RPA5_1_1', ...
    'RPA6', 'RPA6_1', 'RPA6_1_1', 'RPA6_1_2', 'RPA6_2', 'RPA7', 'RPA7_1', 'RPA8', ...
    'RPA9', 'RPA10', 'RPA10_1', 'RPA11', 'RPA12', 'RPA12_1', 'RPA12_2', 'RPA12_3', ...
    'RPA13', 'RPA14', 'RPA15', 'RPA_1', 'RPA_1_1', 'RPA_1_1_1'}; 


% Find outlet segments
outlet_segname = {};
ind_out = 1;
for ind_branch = 2:size(branches,2)
    %define temporary branch name
    temp_branch = strcat(branches{ind_branch},'_');
    %find all files with temp_branch name
    temp_matchind = ~cellfun('isempty',strfind(dat_names,temp_branch));
    temp_files = dat_names(temp_matchind);
    %narrow search to just files with _Re.dat
    temp_matchind = ~cellfun('isempty',strfind(temp_files,'_Re.dat'));
    temp_files = temp_files(temp_matchind);
    
    maxsegnum = 0;
    branch_found = false;
    
    for ind_file = 1:size(temp_files,2)
        temp = char(temp_files(ind_file));
        temp_seg = temp(size(prefix_name,2)+1:(end-size('_Re.dat',2)));
        segnum =  str2num(temp_seg(size(temp_branch,2)+1:end));
        
        if ~isempty(segnum)
            %find outlet segment number (=max segment number)
            if segnum>maxsegnum
                maxsegnum = segnum;
            end
            branch_found = true;
        end  
        
    end
    
    if branch_found
        ind_out = ind_out + 1;
        outlet_segname{ind_out} = strcat(temp_branch,num2str(maxsegnum));
    end
    
end

% 3D Flow RCR BC
%   Q4 (VSD 1-1)
%   Deform
inflowQ4 = load('/home/melody/PH/CHD_model/VSD_QP/RCR_BC/deform/puls/pulsQ4.flow');
F = importdata('/home/melody/PH/CHD_model/VSD_QP/RCR_BC/deform/puls/all_results-flows.txt','\t',1);
flow3DQ4 = F.data;
flow3DQ4(:,2) = -1.*flow3DQ4(:,2);
%   Rigid
F = importdata('/home/melody/PH/CHD_model/VSD_QP/RCR_BC/rigid/puls/all_results-flows.txt','\t',1);
flow3DQ4rig = F.data;
flow3DQ4rig(:,2) = -1.*flow3DQ4rig(:,2);
%  Q8 (VSD 2-1)
%  deformable
inflowQ8 = load('/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/deform/puls/pulsQ8.flow');
F = importdata('/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/deform/puls/all_results-flows.txt','\t',1);
flow3DQ8def = F.data;
flow3DQ8def(:,2) = -1.*flow3DQ8def(:,2);
%   Rigid
F = importdata('/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/rigid/puls/all_results-flows.txt','\t',1);
flow3DQ8rig = F.data;
flow3DQ8rig(:,2) = -1.*flow3DQ8rig(:,2);
%   Q12 (VSD 3-1)
%   Deform
inflowQ12 = load('/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/deform/puls/pulsQ12.flow');
F = importdata('/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/deform/puls/all_results-flows.txt','\t',1);
flow3DQ12def = F.data;
flow3DQ12def(:,2) = -1.*flow3DQ12def(:,2);
%   Rigid
F = importdata('/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/rigid/puls/all_results-flows.txt','\t',1);
flow3DQ12rig = F.data;
flow3DQ12rig(:,2) = -1.*flow3DQ12rig(:,2);


% 3D Pressure RCR BC
% Normal 1:1
%   Deform
P = importdata('/home/melody/PH/CHD_model/VSD_QP/RCR_BC/deform/puls/all_results-pressures.txt','\t',1);
pressure3D_Q4def = P.data;
%   Rigid
P = importdata('/home/melody/PH/CHD_model/VSD_QP/RCR_BC/rigid/puls/all_results-pressures.txt','\t',1);
pressure3D_Q4rig = P.data;
% VSD 2:1
%   Deform
P = importdata('/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/deform/puls/all_results-pressures.txt','\t',1);
pressure3D_Q8def = P.data;
%   Rigid
P = importdata('/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/rigid/puls/all_results-pressures.txt','\t',1);
pressure3D_Q8rig = P.data;
% VSD 3:1
%   Deform
P = importdata('/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/deform/puls/all_results-pressures.txt','\t',1);
pressure3D_Q12def = P.data;
%   Rigid
P = importdata('/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/rigid/puls/all_results-pressures.txt','\t',1);
pressure3D_Q12rig = P.data;

%% Flow plots
% Read flow data
flow1D_Q4 = [];
flow1D_Q8 = [];
flow1D_Q12 = [];


% inflow
% %   Q4 (VSD 1-1)
% temp = load(strcat(prefix_name,'LPA_0_flow.dat')); %branches{51},'_0','_flow.dat'));
% [rows, ~] = size(temp);
% flow1D_Q4(1,:) = temp(1,:);
%   Q8 (VSD 2-1)
temp = load(strcat(path_nameQ4,'LPA_0_flow.dat')); %branches{51},'_0','_flow.dat'));
[rows, ~] = size(temp);
flow1D_Q8(1,:) = temp(1,:);
%   Q12 (VSD 2-1)
temp = load(strcat(path_nameQ12,'LPA_0_flow.dat')); %branches{51},'_0','_flow.dat'));
[rows, ~] = size(temp);
flow1D_Q12(1,:) = temp(1,:);

% all other outlet flows
for ind_outlet = 2:size(outlet_segname,2)
%     % Q4 (VSD 1-1)
%     temp = load(strcat(prefix_name,outlet_segname{ind_outlet},'_flow.dat'));
%     [rows, ~] = size(temp);
%     flow1D_Q4(ind_outlet,:) = temp(rows,:); %only saves last element in segment (outlet)
    % Q8 (VSD 2-1)
    temp = load(strcat(path_nameQ4,outlet_segname{ind_outlet},'_flow.dat'));
    [rows, ~] = size(temp);
    flow1D_Q8(ind_outlet,:) = temp(rows,:); %only saves last element in segment (outlet)
    % Q12 (VSD 3-1)
    temp = load(strcat(path_nameQ12,outlet_segname{ind_outlet},'_flow.dat'));
    [rows, ~] = size(temp);
    flow1D_Q12(ind_outlet,:) = temp(rows,:); %only saves last element in segment (outlet)
end



%%%%%%%%%%%% SET UP TIME ARRAYS %%%%%%%%%%%%%

% Get info for 1D data
[~, numSteps] = size(flow1D_Q8);
% how many save steps in one cardiac cycle (i.e. 1 second)
cycle = 43;
dt = 0.02;
% convert times to seconds
t = 0:dt:cycle*dt;
% only plot the last cardiac cycle
startcycle=129;
tt = startcycle:startcycle+cycle;
% extended time
t1Dall = 0:dt:(numSteps-1)*dt;

% Do the same for 3D data Deform
cycle3D = 20;
dt3D = 0.04285;
[numSteps3D,~] = size(flow3DQ8def);
% convert time to seconds
t3D = 0:dt3D:cycle3D*dt3D;
% only plot last cardiac cycle
tt3D = numSteps3D-cycle3D:numSteps3D;
% extended time
t3Dall = 0:dt3D:(numSteps3D-1)*dt3D;

% Do the same for 3D data Rigid
cycle3Drig = 20;
dt3Drig = 0.04285;
[numSteps3Drig,~] = size(flow3DQ8rig);
% convert time to seconds
t3Drig = 0:dt3Drig:cycle3Drig*dt3Drig;
% only plot last cardiac cycle
tt3Drig = numSteps3Drig-cycle3Drig:numSteps3Drig;
% extended time
t3Dallrig = 0:dt3Drig:(numSteps3Drig-1)*dt3Drig;


%%%%%%%%%%%% GENERATE PLOTS %%%%%%%%%%%%%
% Plot all flows
figureNum = 1;
% figure(figureNum)
% figureNum = figureNum + 1;

% Make colors for 3 of the same color plotted in a row
co = [0    0.4470    0.7410;
    0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840;
    0.6350    0.0780    0.1840
    0         0         1
    0         0         1
    1         0         0
    1         0         0
    1         0         1
    1         0         1];
set(groot,'defaultAxesColorOrder',co);
hold on

% Parse through 1D and 3D flow for each branch
for i = 2:20:size(flow3DQ4,1)
    figure(figureNum)
    figureNum = figureNum + 1;
    % VSD 1:1
    name = sprintf('%s 3D 1:1 Deform',branches{i});
    plot(t3D,flow3DQ4(i,tt3D),'DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D 1:1 Rigid',branches{i});
    plot(t3D,flow3DQ4rig(tt3Drig,i+1),':','DisplayName',name,'LineWidth',2);
    hold on
    % VSD 2:1
    name = sprintf('%s 3D 2:1 Deform',branches{i});
    plot(t3D,flow3Q8d(i,tt3D),'r','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D 2:1 Rigid',branches{i});
    plot(t3D,flow3DQ8def(tt3Drig,i+1),'r:','DisplayName',name,'LineWidth',2);
    hold on
    % VSD 3:1
    name = sprintf('%s 3D 3:1 Deform',branches{i});
    plot(t3D,flow3DQ12(i,tt3D),'g','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D 3:1 Rigid',branches{i});
    plot(t3D,flow3DQ12def(tt3Drig,i+1),'g:','DisplayName',name,'LineWidth',2);
    hold on
    
    % show legend
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 8;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
    xlim([0 cycle*dt])
    xlabel('time (s)')
    ylabel('flow (cm^3/s)')
    title({'Flow at Branch in', 'PA model for VSD Conditions'})
end



% Plot Inflow Waveforms
figure(figureNum)
figureNum = figureNum + 1;
hold on

% % VSD 1:1
% name = 'Inflow 1D Normal';
% plot(t, flow1D_Q4(1,tt)*60/1000, 'DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inflow 3D Normal';
% plot(t3D, flow3DQ4(tt3D, 2)*60/1000,':', 'DisplayName',name,'LineWidth',2);
% hold on;
% VSD 2:1
name = 'Inflow 1D VSD 2:1';
plot(t, flow1D_Q8(1,tt)*60/1000,'r', 'DisplayName',name,'LineWidth',2);
hold on;
name = 'Inflow 3D VSD 2:1';
plot(t3D, flow3DQ8def(tt3D, 2)*60/1000, 'r:', 'DisplayName',name,'LineWidth',2);
hold on;
% VSD 3:1
name = 'Inflow 1D VSD 3:1';
plot(t, flow1D_Q12(1,tt)*60/1000,'g', 'DisplayName',name,'LineWidth',2);
hold on;
name = 'Inflow 3D VSD 3:1';
plot(t3D, flow3DQ12def(tt3D, 2)*60/1000, 'g:', 'DisplayName',name,'LineWidth',2);
hold on;

xlabel('Time (s)');
ylabel('Flow (L/min)');
title({'Inflow Waveform Comparison', 'between 1D and 3D'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
set(lgd, 'Interpreter','none');


% Average flow error at each outlet and inlet
figure(figureNum)
figureNum = figureNum + 1;
hold on

% avg_flow1D_Q4 = mean(flow1D_Q4(:,tt),2);
% avg_flow3D_Q4 = mean(flow3DQ4(tt3D,2:end,1))';
avg_flow1D_Q8 = mean(flow1D_Q8(:,tt),2);
avg_flow3D_Q8 = mean(flow3DQ8def(tt3D,2:end,1))';
avg_flow1D_Q12 = mean(flow1D_Q12(:,tt),2);
avg_flow3D_Q12 = mean(flow3DQ12def(tt3D,2:end,1))';

% name = 'Normal Flow error';
% plot(100*(avg_flow1D_Q4-avg_flow3D_Q4)./avg_flow3D_Q4,'bo');
% hold on;
name = 'VSD 2:1 Flow error';
plot(100*(avg_flow1D_Q8-avg_flow3D_Q8)./avg_flow3D_Q8,'ro','DisplayName',name);
hold on
name = 'VSD 3:1 Flow error';
plot(100*(avg_flow1D_Q12-avg_flow3D_Q12)./avg_flow3D_Q12,'go','DisplayName',name);

xlabel('PA model outlets');
ylabel({'% Error difference between', '1D and 3D (normalized to 3D)'});
title({'Flow error at outlets in', 'PA model for VSD Conditions'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
set(lgd, 'Interpreter','none');

colors = [0    0.4470    0.7410;
      0.8500    0.3250    0.0980;
      0.9290    0.6940    0.1250];
b(1).FaceColor = colors(1,:);
b(2).FaceColor = colors(2,:);

% Flow over entire cardiac cycle
figure(figureNum)
figureNum = figureNum + 1;
hold on

% % VSD 1:1
% name = '1D Normal';
% plot(t1Dall, flow1D_Q4(12,:)*60/1000, 'DisplayName',name,'LineWidth',2);
% hold on;
% name = '3D Normal';
% plot(t3Dall, flow3DQ4(:, 13)*60/1000,':', 'DisplayName',name,'LineWidth',2);
% hold on;
% VSD 2:1
name = '1D VSD 2:1';
plot(t1Dall, flow1D_Q8(12,:)*60/1000,'r', 'DisplayName',name,'LineWidth',2);
hold on;
name = '3D VSD 2:1';
plot(t3Dall, flow3DQ8def(:, 13)*60/1000, 'r:', 'DisplayName',name,'LineWidth',2);
hold on;
% VSD 3:1
name = '1D VSD 3:1';
plot(t1Dall, flow1D_Q12(12,:)*60/1000,'g', 'DisplayName',name,'LineWidth',2);
hold on;
name = '3D VSD 3:1';
plot(t3Dall, flow3DQ12def(:, 13)*60/1000, 'g:', 'DisplayName',name,'LineWidth',2);
hold on;

xlabel('Time (s)');
ylabel('Flow (L/min)');
title({'Flow Convergence', 'in 1D and 3D'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
set(lgd, 'Interpreter','none');


%% Pressure Plots

% Read pressure data
% %   Normal VSD 1:1
% pressure1D_Q4 = [];
% vasculaturePressure = [];
% temp = load(strcat(prefix_name,branches{2},'_0','_pressure.dat'));
% [rows, ~] = size(temp);
% pressure1D_Q4(1,:) = temp(1,:);
%   VSD 2:1
pressure1D_Q8 = [];
vasculaturePressure = [];
temp = load(strcat(path_nameQ4,branches{2},'_0','_pressure.dat'));
[rows, ~] = size(temp);
pressure1D_Q8(1,:) = temp(1,:);
%   VSD 3:1
pressure1D_Q12 = [];
vasculaturePressure = [];
temp = load(strcat(path_nameQ12,branches{2},'_0','_pressure.dat'));
[rows, ~] = size(temp);
pressure1D_Q12(1,:) = temp(1,:);


% all other outlet pressures
for ind_outlet = 2:size(outlet_segname,2)
%     % Normal VSD 1:1
%     temp = load(strcat(prefix_name,outlet_segname{ind_outlet},'_pressure.dat'));
%     [rows, ~] = size(temp);
%     pressure1D_Q4(ind_outlet,:) = temp(rows,:);
    % VSD 2:1
    temp = load(strcat(path_nameQ4,outlet_segname{ind_outlet},'_pressure.dat'));
    [rows, ~] = size(temp);
    pressure1D_Q8(ind_outlet,:) = temp(rows,:);
    % VSD 3:1
    temp = load(strcat(path_nameQ12,outlet_segname{ind_outlet},'_pressure.dat'));
    [rows, ~] = size(temp);
    pressure1D_Q12(ind_outlet,:) = temp(rows,:);
end
% Convert from Barye to mmHg
% pressure1D_Q4 = 0.0007500616827.*pressure1D_Q4;
pressure1D_Q8 = 0.0007500616827.*pressure1D_Q8;
pressure1D_Q12 = 0.0007500616827.*pressure1D_Q12;



% Convert from Barye to mmHg
pressure3D_Q4def = 0.0007500616827.*pressure3D_Q4def;
pressure3D_Q8def = 0.0007500616827.*pressure3D_Q8def;
pressure3D_Q12def = 0.0007500616827.*pressure3D_Q12def;
pressure3D_Q4rig = 0.0007500616827.*pressure3D_Q4rig;
pressure3D_Q8rig = 0.0007500616827.*pressure3D_Q8rig;
pressure3D_Q12rig = 0.0007500616827.*pressure3D_Q12rig;

%%%%%%%%%%%% GENERATE PLOTS %%%%%%%%%%%%%

% Plot all pressures
% figure(figureNum)
% figureNum = figureNum + 1;

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

for i = 2:20:size(pressure1D_Q8,1)
    figure(figureNum)
    figureNum = figureNum + 1;
    
%     % Normal Q4 1:1
%     name = sprintf('%s 1D Normal',branches{i});
%     plot(t,pressure1D_Q4(i,tt),'DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D Normal',branches{i});
%     plot(t3D,pressure3D_Q4(tt3D,i+1),':','DisplayName',name,'LineWidth',2);
%     hold on
    % VSD 2:1
    name = sprintf('%s 1D VSD 2:1',branches{i});
    plot(t,pressure1D_Q8(i,tt),'r','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 2:1',branches{i});
    plot(t3D,pressure3D_Q8def(tt3D,i+1),'r:','DisplayName',name,'LineWidth',2);
    hold on
    % VSD 3:1
    name = sprintf('%s 1D VSD 3:1',branches{i});
    plot(t,pressure1D_Q12(i,tt),'g','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 3:1',branches{i});
    plot(t3D,pressure3D_Q12def(tt3D,i+1),'g:','DisplayName',name,'LineWidth',2);
    hold on
    
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 8;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
    xlim([0 cycle*dt])
    xlabel('time (s)')
    ylabel('pressure (mmHg)')
    title({'Pressure at Branch in','PA model for VSD Conditions'})
end


% Plot Pressure Waveform at inlet
figure(figureNum)
figureNum = figureNum + 1;
hold on;

% % Normal 1:1
% name = 'Inlet P 1D Normal';
% plot(t, pressure1D_Q4(1,tt),'DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D Normal';
% plot(t3D, pressure3D_Q4(tt3D,2),':','DisplayName',name,'LineWidth',2);
% hold on
% VSD 2:1
name = 'Inlet P 1D VSD 2:1';
plot(t, pressure1D_Q8(1,tt),'r','DisplayName',name,'LineWidth',2);
hold on;
name = 'Inlet P 3D VSD 2:1';
plot(t3D, pressure3D_Q8def(tt3D,2),'r:','DisplayName',name,'LineWidth',2);
% VSD 3:1
name = 'Inlet P 1D VSD 3:1';
plot(t, pressure1D_Q12(1,tt),'g','DisplayName',name,'LineWidth',2);
hold on;
name = 'Inlet P 3D VSD 3:1';
plot(t3D, pressure3D_Q12def(tt3D,2),'g:','DisplayName',name,'LineWidth',2);

xlabel('Time (s)');
ylabel('Pressure (mmHg)');
title({'Pressure Comparison between', '1D and 3D Inlet'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
set(lgd, 'Interpreter','none');
legend('boxOff')


% Average pressure at each outlet and inlet
figure(figureNum)
figureNum = figureNum + 1;
hold on

% avg_pressure1D_Q4 = mean(pressure1D_Q4(:,tt),2);
% avg_pressure3D_Q4 = mean(pressure3D_Q4(tt3D,2:end),1)';
avg_pressure1D_Q8 = mean(pressure1D_Q8(:,tt),2);
avg_pressure3D_Q8 = mean(pressure3D_Q8def(tt3D,2:end),1)';
avg_pressure1D_Q12 = mean(pressure1D_Q12(:,tt),2);
avg_pressure3D_Q12 = mean(pressure3D_Q12def(tt3D,2:end),1)';

% name = 'Normal Pressure error';
% plot(100*(avg_pressure1D_Q4-avg_pressure3D_Q4)./avg_pressure3D_Q4,'bo','DisplayName',name)
% hold on
name = 'VSD 2:1 Pressure error';
plot(100*(avg_pressure1D_Q8-avg_pressure3D_Q8)./avg_pressure3D_Q8,'ro','DisplayName',name)
hold on
name = 'VSD 3:1 Pressure error';
plot(100*(avg_pressure1D_Q12-avg_pressure3D_Q12)./avg_pressure3D_Q12,'go','DisplayName',name)

xlabel('PA model outlets');
ylabel({'% Error difference between','1D and 3D (normalized to 3D)'});
title({'Pressure error at outlets', 'in PA model for VSD Conditions'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
set(lgd, 'Interpreter','none');

colors = [0    0.4470    0.7410;
      0.8500    0.3250    0.0980;
      0.9290    0.6940    0.1250];
b(1).FaceColor = colors(1,:);
b(2).FaceColor = colors(2,:);


% Plot Pressure Waveform at inlet
figure(figureNum)
figureNum = figureNum + 1;
hold on;

% % Normal 1:1
% name = 'P 1D Normal';
% plot(t1Dall, pressure1D_Q4(12,:),'DisplayName',name,'LineWidth',2);
% hold on;
% name = 'P 3D Normal';
% plot(t3Dall, pressure3D_Q4(:,13),':','DisplayName',name,'LineWidth',2);
% hold on
% VSD 2:1
name = 'P 1D VSD 2:1';
plot(t1Dall, pressure1D_Q8(12,:),'r','DisplayName',name,'LineWidth',2);
hold on;
name = 'P 3D VSD 2:1';
plot(t3Dall, pressure3D_Q8def(:,13),'r:','DisplayName',name,'LineWidth',2);
% VSD 3:1
name = 'P 1D VSD 3:1';
plot(t1Dall, pressure1D_Q12(12,:),'g','DisplayName',name,'LineWidth',2);
hold on;
name = 'P 3D VSD 3:1';
plot(t3Dall, pressure3D_Q12def(:,13),'g:','DisplayName',name,'LineWidth',2);

xlabel('Time (s)');
ylabel('Pressure (mmHg)');
title({'Pressure Convergence in', '1D and 3D Branch'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 8;
set(lgd, 'Interpreter','none');
legend('boxOff')


%% WSS Plots

viscosity = 0.04;

% Area outlet differences
%   3D area
area3D = load('/home/melody/PH/CHD_model/VSD_QP/SU0201_2009_outletArea.txt');


% Read WSS data
% %   Normal 1:1
% wss1D_Q4 = [];
% vasculaturewss = [];
% temp = load(strcat(prefix_name,branches{2},'_0','_wss.dat'));
% [rows, ~] = size(temp);
% wss1D_Q4(1,:) = temp(rows,:);
%   VSD 2:1
wss1D_Q8 = [];
vasculaturewss = [];
temp = load(strcat(path_nameQ4,branches{2},'_0','_wss.dat'));
[rows, ~] = size(temp);
wss1D_Q8(1,:) = temp(rows,:);
%   VSD 3:1
wss1D_Q12 = [];
vasculaturewss = [];
temp = load(strcat(path_nameQ12,branches{2},'_0','_wss.dat'));
[rows, ~] = size(temp);
wss1D_Q12(1,:) = temp(rows,:);


% 3D outlet areas
% wss3D_Q4 = [];
wss3D_Q8def = [];
wss3D_Q12def = [];
wss3D_Q8rig = [];
wss3D_Q12rig = [];

% all other outlet WSS
for ind_outlet = 2:size(outlet_segname,2)
%     % Normal 1:1
%     temp = load(strcat(prefix_name,outlet_segname{ind_outlet},'_wss.dat'));
%     [rows, ~] = size(temp);
%     wss1D_Q4(ind_outlet,:) = temp(rows,:);
%     wss3D_Q4(ind_outlet-1,:) = 4*viscosity*flow3DQ4(tt3D, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
    % VSD 2:1
    temp = load(strcat(path_nameQ4,outlet_segname{ind_outlet},'_wss.dat'));
    [rows, ~] = size(temp);
    wss1D_Q8(ind_outlet,:) = temp(rows,:);
    wss3D_Q8def(ind_outlet-1,:) = 4*viscosity*flow3DQ8def(tt3D, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
    wss3D_Q8rig(ind_outlet-1,:) = 4*viscosity*flow3DQ8rig(tt3Drig, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
    
    % VSD 3:1
    temp = load(strcat(path_nameQ12,outlet_segname{ind_outlet},'_wss.dat'));
    [rows, ~] = size(temp);
    wss1D_Q12(ind_outlet,:) = temp(rows,:);
    wss3D_Q12def(ind_outlet-1,:) = 4*viscosity*flow3DQ12def(tt3D, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
    wss3D_Q12rig(ind_outlet-1,:) = 4*viscosity*flow3DQ12rig(tt3Drig, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);

end

%   1D area
% area1D_Q4 = pi*((4*viscosity*mean(flow1D_Q4(:,tt),2))./(pi*mean(wss1D_Q4(:,tt),2))).^(2/3);
area1D_Q8 = pi*((4*viscosity*mean(flow1D_Q8(:,tt),2))./(pi*mean(wss1D_Q8(:,tt),2))).^(2/3);
area1D_Q12 = pi*((4*viscosity*mean(flow1D_Q12(:,tt),2))./(pi*mean(wss1D_Q12(:,tt),2))).^(2/3);

% Plot average WSS at outlets
figure(figureNum)
figureNum = figureNum + 1;
hold on

% avg_wss1D_Q4 = mean(wss1D_Q4(2:end,tt),2);
% avg_wss3D_Q4 = mean(wss3D_Q4(:,:),2);
avg_wss1D_Q8 = mean(wss1D_Q8(2:end,tt),2);
avg_wss3D_Q8def = mean(wss3D_Q8def(:,:),2);
avg_wss3D_Q8rig = mean(wss3D_Q8rig(:,:),2);
avg_wss1D_Q12 = mean(wss1D_Q12(2:end,tt),2);
avg_wss3D_Q12def = mean(wss3D_Q12def(:,:),2);
avg_wss3D_Q12rig = mean(wss3D_Q12rig(:,:),2);

% % Normal 1:1
% name = '1D WSS Normal';
% plot(avg_wss1D_Q4,'b*','DisplayName',name);
% hold on;
% name = '3D WSS Normal';
% plot(avg_wss3D_Q4,'bo','DisplayName',name);
% hold on
% VSD 2:1
name = '1D WSS VSD 2:1';
plot(avg_wss1D_Q8,'r*','DisplayName',name);
hold on;
name = '3D WSS VSD 2:1';
plot(avg_wss3D_Q8def,'ro','DisplayName',name);
hold on
% VSD 3:1
name = '1D WSS VSD 3:1'
plot(avg_wss1D_Q12,'g*','DisplayName',name);
hold on;
name = '3D WSS VSD 3:1'
plot(avg_wss3D_Q12def,'go','DisplayName',name);
hold on

xlabel('PA Model Outlets');
ylabel('WSS (dyn/cm2)');
title('WSS comparison between 1D and 3D')
lgd = legend('show', 'Location','eastoutside');
lgd.FontSize = 8;
set(lgd, 'Interpreter','none');



% Plot outlet areas
figure(figureNum)
figureNum = figureNum + 1;
hold on;

plot(area1D_Q8(2:end),'bo');
hold on;
plot(area3D,'ro')
title('Area of 1D and 3D outlets');
legend('1D area','3D area')


% Average WSS error at each outlet
figure(figureNum)
figureNum = figureNum + 1;
hold on

% plot(100*(avg_wss1D_Q4-avg_wss3D_Q4)./avg_wss3D_Q4,'bo');
plot(100*(avg_wss1D_Q8-avg_wss3D_Q8def)./avg_wss3D_Q8def,'ro');
plot(100*(avg_wss1D_Q12-avg_wss3D_Q12def)./avg_wss3D_Q12def,'go');

xlabel('PA model outlets');
ylabel('Error difference between 1D and 3D (normalized to 3D)');
title('WSS error at outlets in PA model');
legend('WSS Error VSD 2:1','WSS Error VSD 3:1');


% Average WSS vs. area at each outlet
figure(figureNum)
figureNum = figureNum + 1;
hold on

% % Normal
% name = '1D WSS Normal';
% plot(area1D_Q4(2:end),avg_wss1D_Q4,'b*','DisplayName',name);
% hold on;
% name = '3D WSS Normal';
% plot(area3D, avg_wss3D_Q4, 'bo','DisplayName',name);
% hold on;
% VSD 2:1
name = '1D WSS VSD 2:1';
plot(area1D_Q8(2:end),avg_wss1D_Q8,'r*','DisplayName',name);
hold on;
name = '3D WSS VSD 2:1';
plot(area3D, avg_wss3D_Q8def, 'ro','DisplayName',name);
hold on;
% VSD 3:1
name = '1D WSS VSD 3:1';
plot(area1D_Q8(2:end),avg_wss1D_Q12,'g*','DisplayName',name);
hold on;
name = '3D WSS VSD 3:1';
plot(area3D, avg_wss3D_Q12def, 'go','DisplayName',name);
hold on;


legend('show','Location','eastoutside');
xlabel('Area (cm^2)');
ylabel('WSS (dyn/cm2)');
title('WSS comparison between 1D and 3D')


%% Plots inidividual

set(0, 'defaultTextFontSize',16);

% % Plot Pressure Waveform at inlet
% % Normal 1:1
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on;
% name = 'Inlet P 1D Normal';
% plot(t, pressure1D_Q4(1,tt),'b','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D Normal';
% plot(t3D, pressure3D_Q4(tt3D,2),'b:','DisplayName',name,'LineWidth',2);
% hold on
% ylim([0 250]);
% set(0, 'defaultTextFontSize',16);
% xlabel('Time (s)');
% ylabel('Pressure (mmHg)');
% title({'Pressure Comparison between', '1D and 3D Inlet: Normal'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 12;
% set(lgd, 'Interpreter','none');
% legend('boxOff')

% VSD 2:1
figure(figureNum)
figureNum = figureNum + 1;
hold on;
name = 'Inlet P 1D VSD 2:1';
plot(t, pressure1D_Q8(1,tt),'r','DisplayName',name,'LineWidth',2);
hold on;
name = 'Inlet P 3D VSD 2:1 Deform';
plot(t3D, pressure3D_Q8def(tt3D,2),'r:','DisplayName',name,'LineWidth',2);
hold on;
name = 'Inlet P 3D VSD 2:1 Rigid';
plot(t3Drig, pressure3D_Q8rig(tt3Drig,2),'r-.','DisplayName',name,'LineWidth',2);
ylim([0 250]);
set(0, 'defaultTextFontSize',16);
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
title({'Pressure Comparison between', '1D and 3D Inlet: VSD 2:1'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 12;
set(lgd, 'Interpreter','none');
legend('boxOff')

% VSD 3:1
figure(figureNum)
figureNum = figureNum + 1;
name = 'Inlet P 1D VSD 3:1';
plot(t, pressure1D_Q12(1,tt),'g','DisplayName',name,'LineWidth',2);
hold on;
name = 'Inlet P 3D VSD 3:1 Deform';
plot(t3D, pressure3D_Q12def(tt3D,2),'g:','DisplayName',name,'LineWidth',2);
hold on;
name = 'Inlet P 3D VSD 3:1 Rigid';
plot(t3Drig, pressure3D_Q12rig(tt3Drig,2),'g-.','DisplayName',name,'LineWidth',2);
ylim([0 250]);
set(0, 'defaultTextFontSize',16);
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
title({'Pressure Comparison between', '1D and 3D Inlet: VSD 3:1'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 12;
set(lgd, 'Interpreter','none');
legend('boxOff')


% Plot Pressure at LPA 3_1 & RPA 3_3
for i = [22, 62] %22:size(pressure1D_Q4,1)
%     figure(figureNum)
%     figureNum = figureNum + 1;
%     % Normal Q4 1:1
%     name = sprintf('%s 1D Normal',branches{i});
%     plot(t,pressure1D_Q4(i,tt),'b','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D Normal',branches{i});
%     plot(t3D,pressure3D_Q4(tt3D,i+1),'b:','DisplayName',name,'LineWidth',2);
%     hold on
%     if i == 22
%         ylim([0 120]);
%     else
%         ylim([0 70]);
%     end
%     set(0, 'defaultTextFontSize',16);
%     lgd = legend('show','Location','eastoutside');
%     lgd.FontSize = 12;
%     set(lgd, 'Interpreter','none');
%     legend('boxOff')
%     xlim([0 cycle*dt])
%     xlabel('time (s)')
%     ylabel('pressure (mmHg)')
%     title({'Pressure at Branch in','PA model for Normal Conditions'})
    
    figure(figureNum)
    figureNum = figureNum + 1;
    % VSD 2:1
    name = sprintf('%s 1D VSD 2:1',branches{i});
    plot(t,pressure1D_Q8(i,tt),'r','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 2:1 Deform',branches{i});
    plot(t3D,pressure3D_Q8def(tt3D,i+1),'r:','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 2:1 Rigid',branches{i});
    plot(t3Drig,pressure3D_Q8rig(tt3Drig,i+1),'r-.','DisplayName',name,'LineWidth',2);
    hold on
    if i == 22
        ylim([0 120]);
    else
        ylim([0 70]);
    end
    set(0, 'defaultTextFontSize',16);
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 12;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
    xlim([0 cycle*dt])
    xlabel('time (s)')
    ylabel('pressure (mmHg)')
    title({'Pressure at Branch in','PA model for VSD 2:1'})
    
    figure(figureNum)
    figureNum = figureNum + 1;
    % VSD 3:1
    name = sprintf('%s 1D VSD 3:1',branches{i});
    plot(t,pressure1D_Q12(i,tt),'g','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 3:1 Deform',branches{i});
    plot(t3D,pressure3D_Q12def(tt3D,i+1),'g:','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 3:1 Rigid',branches{i});
    plot(t3Drig,pressure3D_Q12rig(tt3Drig,i+1),'g-.','DisplayName',name,'LineWidth',2);
    hold on
    if i == 22
        ylim([0 120]);
    else
        ylim([0 70]);
    end
    set(0, 'defaultTextFontSize',16);
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 12;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
    xlim([0 cycle*dt])
    xlabel('time (s)')
    ylabel('pressure (mmHg)')
    title({'Pressure at Branch in','PA model for VSD 3:1'})
end




% Plot Flow at LPA3_3 and RPA1_3
for i = [22, 62]; %2:20:size(flow1D_Q4,1)
%     figure(figureNum)
%     figureNum = figureNum + 1;
%     % VSD 1:1
%     name = sprintf('%s 1D Normal',branches{i});
%     plot(t,flow1D_Q4(i,tt),'b','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D Normal',branches{i});
%     plot(t3D,flow3DQ4(tt3D,i+1),'b:','DisplayName',name,'LineWidth',2);
%     hold on
%     % show legend
%     if i == 22
%         ylim([0 12]);
%     else
%         ylim([0 3.5]);
%     end
%     set(0, 'defaultTextFontSize',16);
%     lgd = legend('show','Location','eastoutside');
%     lgd.FontSize = 12;
%     set(lgd, 'Interpreter','none');
%     legend('boxOff')
%     xlim([0 cycle*dt])
%     xlabel('time (s)')
%     ylabel('flow (cm^3/s)')
%     title({'Flow at Branch in', 'PA model for Normal Conditions'})
    
    figure(figureNum)
    figureNum = figureNum + 1;
    % VSD 2:1
    name = sprintf('%s 1D VSD 2:1',branches{i});
    plot(t,flow1D_Q8(i,tt),'r','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 2:1 Deform',branches{i});
    plot(t3D,flow3DQ8def(tt3D,i+1),'r:','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 2:1 Rigid',branches{i});
    plot(t3Drig,flow3DQ8rig(tt3Drig,i+1),'r-.','DisplayName',name,'LineWidth',2);
    hold on
    % show legend
    if i == 22
        ylim([0 12]);
    else
        ylim([0 3.5]);
    end
    set(0, 'defaultTextFontSize',16);
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 12;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
    xlim([0 cycle*dt])
    xlabel('time (s)')
    ylabel('flow (cm^3/s)')
    title({'Flow at Branch in', 'PA model for VSD 2:1'})
    
    figure(figureNum)
    figureNum = figureNum + 1;    
    % VSD 3:1
    name = sprintf('%s 1D VSD 3:1',branches{i});
    plot(t,flow1D_Q12(i,tt),'g','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 3:1 Deform',branches{i});
    plot(t3D,flow3DQ12def(tt3D,i+1),'g:','DisplayName',name,'LineWidth',2);
    hold on
    name = sprintf('%s 3D VSD 3:1 Rigid',branches{i});
    plot(t3Drig,flow3DQ12rig(tt3Drig,i+1),'g-.','DisplayName',name,'LineWidth',2);
    hold on
    % show legend
    if i == 22
        ylim([0 12]);
    else
        ylim([0 3.5]);
    end
    set(0, 'defaultTextFontSize',16);
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 12;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
    xlim([0 cycle*dt])
    xlabel('time (s)')
    ylabel('flow (cm^3/s)')
    title({'Flow at Branch in', 'PA model for VSD 3:1'})
end


% Average WSS vs. area at each outlet
figure(figureNum)
figureNum = figureNum + 1;
hold on

% % Normal
% plot(2*sqrt(area1D_Q4(2:end)./pi),avg_wss1D_Q4,'b*');
% hold on;
% plot(2*sqrt(area3D./pi), avg_wss3D_Q4, 'bo');
% hold on;
% VSD 2:1
plot(2*sqrt(area1D_Q8(2:end)./pi),avg_wss1D_Q8,'r*');
hold on;
plot(2*sqrt(area3D./pi), avg_wss3D_Q8def, 'ro');
hold on;
plot(2*sqrt(area3D./pi), avg_wss3D_Q8rig, 'r+');
hold on;
% VSD 3:1
plot(2*sqrt(area1D_Q8(2:end)./pi),avg_wss1D_Q12,'g*');
hold on;
plot(2*sqrt(area3D./pi), avg_wss3D_Q12def, 'go');
hold on;
plot(2*sqrt(area3D./pi), avg_wss3D_Q12rig, 'g+');
hold on;

set(0, 'defaultTextFontSize',16);
lgd = legend('1D WSS Normal', '3D WSS Normal', '1D WSS VSD 2:1','3D WSS VSD 2:1 Defom','3D WSS VSD 2:1 Rigid',...
    '1D WSS VSD 3:1','3D WSS VSD 3:1 Deform','3D WSS VSD 3:1 Rigid');
lgd.FontSize = 12;
set(lgd, 'Interpreter','none');
legend('boxOff')
xlabel('Diameter of Vessel (cm)');
ylabel('WSS (dyn/cm2)');
title({'WSS comparison between 1D and 3D','for VSD Conditions'})