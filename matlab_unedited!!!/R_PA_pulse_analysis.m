%% Generate Plots for Pulmonary Arteries 1D and 3D
% Adapted from Casey's R_Aorta_Pulse_New.m script
% Melody Dong 9/26/17

clear
clc
close all

orig_direc = '/home/melody/PH/CHD_model/Analysis_1D3D/';

%%%%%%%%%%%%%%%% USER INPUT: Directory for Results Files %%%%%%%%%%%%%%%%%%
% Names of Results for Comparison (with prefix for 1D results)
direc_1D = {'/home/melody/PH/CHD_model/VSD_1DSolver/Q4R200/RCR_BC/Q4RCR_puls/'};
direc_3D = {'/home/melody/PH/CHD_model/VSD_QP/RCR_BC/rigid/puls/', ...
    '/home/melody/PH/CHD_model/VSD_QP/RCR_BC/deform/uniwall/puls/E256/',...
    '/home/melody/PH/CHD_model/VSD_QP/RCR_BC/deform/uniwall/puls/', ...
    '/home/melody/PH/CHD_model/VSD_QP/RCR_BC/deform/varwall/'};

prefix_name = 'PA_106bif_LINEAR_Q4_deform_RCR_puls';

res_names = {'1:1 1D','1:1 3D Rigid','1:1 3D Deform Uniform E=2.56e6',...
    '1:1 3D Deform Uniform E=3.11e6','1:1 3D Deform Variable E=3.11e6'};

area3D = load('/home/melody/PH/CHD_model/Analysis_1D3D/SU0201_2009_outletArea.txt');

viscosity = 0.04;

% P/Q Conversion
pConv = 7.500615050434136e-04; % Pressure cgs --> mmHg
qConv = 0.06; % Flow cgs --> L/min

%%%%% Notes about Comparison %%%%%
% Comparing 1D and 3D simulations for Normal 1:1. Adjusting deformable wall
% simulations to test if GMRES and deformable wall is working
    

%%%%%%%%%%%%%%%%% Load .dat files to parse through %%%%%%%%%%%%%%%%%%%%%%%%
direc = '/home/melody/PH/CHD_model/VSD_1DSolver/Q4R200/RCR_BC/Q4RCR_puls/';
cd(direc);
dat_list = dir('*.dat');
dat_names = {dat_list.name};
clearvars dat_list

cd(orig_direc);


%%%%%%%%%%%%%%%%%% Find outlet segment Names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Branch Labels
branches = {'inflow', 'LPA', 'LPA1', 'LPA1_1', 'LPA1_1_1', 'LPA1_1_2', ...
    'LPA1_1_2_1', 'LPA1_1_2_2', 'LPA1_1_3', 'LPA1_2', 'LPA1_3', ...
    'LPA1_3_1', 'LPA1_3_2', 'LPA1_4', 'LPA1_4_1', 'LPA2', 'LPA2_3', ...
    'LPA3', 'LPA3_1', 'LPA3_1_1', 'LPA3_2', 'LPA3_2_1', 'LPA3_3', ...
    'LPA3_4', 'LPA4', 'LPA5', 'LPA5_1', 'LPA6', 'LPA6_1', 'LPA7', ...
    'LPA7_1', 'LPA8', 'LPA9', 'LPA9_1', 'LPA9_2', 'LPA10', 'LPA10_1', ...
    'LPA10_1_1', 'LPA10_1_2', 'LPA10_2', 'LPA10_3', 'LPA_1', 'LPA_1_1', ...
    'LPA_1_1_1', 'LPA_1_2', 'LPA_1_2_1', 'LPA_1_3', 'LPA_1_4', ...
    'LPA_1_5', 'LPA_1_6', 'LPA_1_7', 'RPA', 'RPA1', 'RPA1_1', ...
    'RPA1_1_1', 'RPA1_1_2_2', 'RPA1_1_3', 'RPA1_1_4', 'RPA1_2', ...
    'RPA1_2_1', 'RPA1_2_2', 'RPA1_3', 'RPA1_4', 'RPA1_4_1', 'RPA1_4_1_1', ...
    'RPA1_4_1_1_1', 'RPA1_4_1_2', 'RPA1_4_1_2_1', 'RPA1_4_2', ...
    'RPA1_4_2_1', 'RPA1_4_3', 'RPA3', 'RPA3_1', 'RPA3_2', 'RPA3_3', ...
    'RPA3_4', 'RPA3_5', 'RPA4', 'RPA4_1', 'RPA4_2', 'RPA4_2_1', 'RPA4_3', ...
    'RPA5', 'RPA5_1', 'RPA5_1_1', 'RPA6', 'RPA6_1', 'RPA6_1_1', ...
    'RPA6_1_2', 'RPA6_2', 'RPA7', 'RPA7_1', 'RPA8', 'RPA9', 'RPA10', ...
    'RPA10_1', 'RPA11', 'RPA12', 'RPA12_1', 'RPA12_2', 'RPA12_3', ...
    'RPA13', 'RPA14', 'RPA15', 'RPA_1', 'RPA_1_1', 'RPA_1_1_1'}; 

outlet_segname = cell(size(branches));
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

clear dat_names ind* direc branch_found temp* *num

%%%%%%%%%%%%%%%%%%%%%%%% 3D Simulation P/Q %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Pressure, Flow Results Files from 3D Directories
flow3D = cell(size(direc_3D));
press3D = cell(size(direc_3D));
wss3D = cell(size(direc_3D));

for i = 1:size(direc_3D,2)
    temp_direc = direc_3D{i};
    
    % Save flows
    tempF = importdata(strcat(temp_direc,'all_results-flows.txt'),'\t',1);
    flow3D{i} = tempF.data;
    
    % Save pressures
    tempP = importdata(strcat(temp_direc,'all_results-pressures.txt'),'\t',1);
    press3D{i} = tempP.data.*pConv;
    
    % Save WSS for all outlets and inlet
    for ind_outlet = 1:size(outlet_segname,2)
        temp_Q = flow3D{i};
        temp_wss(ind_outlet,:) = 4*viscosity*temp_Q(:,ind_outlet+1)./(pi*sqrt(area3D(ind_outlet)/pi)^3);
    end
    wss3D{i} = temp_wss;
    
end

clear temp*

%%%%%%%%%%%%%%%%%%%%%%% 1D Simulation P/Q/WSS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flow1D = cell([1, size(direc_1D,1)]);
press1D = cell([1, size(direc_1D,1)]);
wss1D = cell([1, size(direc_1D,1)]);
area1D = zeros(size(area3D));



% Parse through all 1D Results Directories
for i = 1:size(direc_1D,2)
    % Read Inflow for 1D
    temp_Qin = load(strcat(direc_1D{i}, prefix_name, branches{2}, '_0', '_flow.dat')); % inflow branch name
    temp_flow(1,:) = temp_Qin(1,:);
    
    % Read Inlet Pressure for 1D
    temp_Pin = load(strcat(direc_1D{i}, prefix_name, branches{2},'_0','_pressure.dat')); % inlet pressure branch name
    temp_press(1,:) = temp_Pin(1,:);
    
    % Read Inlet WSS for 1D
    temp_WSSin = load(strcat(direc_1D{i}, prefix_name, branches{2},'_0','_wss.dat')); % inlet pressure branch name
    temp_wss(1,:) = temp_WSSin(1,:);
    
    % Read Outlet P/Q for 1D
    for ind_outlet = 2:size(outlet_segname,2)
        % Outlet Flow
        temp_Qout = load(strcat(direc_1D{i}, prefix_name, outlet_segname{ind_outlet},'_flow.dat'));
        [rows, ~] = size(temp_Qout);
        temp_flow(ind_outlet,:) = temp_Qout(rows,:); %only saves last element in segment (outlet)
        
        % Outlet Pressure
        temp_Pout = load(strcat(direc_1D{i}, prefix_name, outlet_segname{ind_outlet},'_pressure.dat'));
        [rows, ~] = size(temp_Pout);
        temp_press(ind_outlet,:) = temp_Pout(rows,:);
        
        % Outlet WSS
        temp_WSSout = load(strcat(direc_1D{i}, prefix_name, outlet_segname{ind_outlet},'_wss.dat'));
        [rows, ~] = size(temp_WSSout);
        temp_wss(ind_outlet,:) = temp_WSSout(rows,:);

        area1D(ind_outlet) = pi*((4*viscosity*mean(temp_flow(ind_outlet,2:end)))./(pi*mean(temp_wss(ind_outlet,2:end)))).^(2/3);
    end
    
    % Convert P/Q
%     temp_flow = temp_flow*qConv;
    temp_press = temp_press.*pConv;
    
    % Add temp flows and pressures to cell array of all 1D results
    flow1D{i} = temp_flow;
    press1D{i} = temp_press;
    wss1D{i} = temp_wss;
    
end


clear temp* rows

%%%%%%%%%%%% SET UP TIME ARRAYS %%%%%%%%%%%%%
% Get info for 1D data
[~, numSteps] = size(flow1D{1});
% how many save steps in one cardiac cycle (i.e. 1 second)
cycle = 44;
dt = 0.02;
% convert times to seconds
t = 0:dt:(cycle-1)*dt;
% % only plot the last cardiac cycle
% startcycle=129;
% tt = startcycle:startcycle+cycle;
tt = (numSteps-cycle):numSteps-1;
% extended time
t1Dall = 0:dt:(numSteps-1)*dt;

% Do the same for 3D data
cycle3D = 21;
dt3D = 0.04285;
[numSteps3D,~] = size(flow3D{1});
% convert time to seconds
t3D = 0:dt3D:(cycle3D-1)*dt3D;
% only plot last cardiac cycle
tt3D = numSteps3D-cycle3D:numSteps3D-1;
% extended time
t3Dall = 0:dt3D:(numSteps3D-1)*dt3D;

clear numSteps* cycle dt*

figureNum = 1;


%% Flow plots

%%%%%%%%%%%% GENERATE PLOTS %%%%%%%%%%%%%
% Plot all flows

% Make colors for 3 of the same color plotted in a row
co = [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840;
    0         0         1
    1         0         0
    1         0         1];
set(groot,'defaultAxesColorOrder',co);
hold on

% Plot Flow Waveform at inlet
figure(figureNum)
figureNum = figureNum + 1;
figure(figureNum)
figureNume = figureNum + 1;

coCount = 0;
for i = 1:size(res_names,2)
    coCount = coCount + 1;
    
    temp_flow = [];
    temp_press = [];
    temp_wss = [];
    
    if i <= size(direc_1D,2)
        temp_flow = flow1D{i};
        temp_press = press1D{i};
        temp_wss = wss1D{i};
        
        figure(1)
        plot(t, temp_flow(1,tt), 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;
        
        figure(2)
        plot(t, temp_press(1,tt)+10, 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;
        
        figure(3)
        plot(area1D(2:end), mean(temp_wss(2:end,tt),2), 'o', 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;        
    
    elseif i > size(direc_1D, 2) && i <= size(direc_3D,2)+size(direc_1D,2)
        temp_flow = flow3D{i-size(direc_1D,2)};
        temp_press = press3D{i-size(direc_1D,2)};
        temp_wss = wss3D{i-size(direc_1D,2)};
        
        figure(1)
        plot(t3D, -temp_flow(tt3D, 2), 'Color', co(coCount,:), 'DisplayName', res_names{i}, 'LineWidth',2);
        hold on;
        
        figure(2)
        plot(t3D, temp_press(tt3D, 2), 'Color', co(coCount,:), 'DisplayName', res_names{i}, 'LineWidth',2);
        hold on;

        figure(3)
        plot(area1D(2:end), mean(temp_wss(2:end,tt),2), 'o', 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;
    
    else
        display('Error: index not in range of available results');
        break;
    end
    
end

figure(1)
ylim([0 250]);
set(0, 'defaultTextFontSize',16);
xlabel('Time (s)');
ylabel('Flow (ml/s)');
title({'Flow Comparison between', '1D and 3D Inlet: Normal'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 12;
set(lgd, 'Interpreter','none');
legend('boxOff')

figure(2)
ylim([0 50]);
set(0, 'defaultTextFontSize',16);
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
title({'Pressure Comparison between', '1D and 3D Inlet: Normal'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 12;
set(lgd, 'Interpreter','none');
legend('boxOff')

figure(3)
ylim([0 100]);
set(0, 'defaultTextFontSize',16);
xlabel('Time (s)');
ylabel('WSS (dyn/cm^2)');
title({'WSS Comparison between', '1D and 3D: Normal'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 12;
set(lgd, 'Interpreter','none');
legend('boxOff')

% % Parse through 1D and 3D flow for each branch
% for i = 2:20:size(flow3DQ4_defuni,1)
%     figure(figureNum)
%     figureNum = figureNum + 1;
%     % VSD 1:1
%     name = sprintf('%s 3D 1:1 Deform Uniform Wall',branches{i});
%     plot(t3D,flow3DQ4_defuni(i,tt3D),'DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D 1:1 Rigid',branches{i});
%     plot(t3D,flow3DQ4_rig(tt3Drig,i+1),':','DisplayName',name,'LineWidth',2);
%     hold on
%     
% %     % VSD 2:1
% %     name = sprintf('%s 3D 2:1 Deform',branches{i});
% %     plot(t3D,flow3Q8d(i,tt3D),'r','DisplayName',name,'LineWidth',2);
% %     hold on
% %     name = sprintf('%s 3D 2:1 Rigid',branches{i});
% %     plot(t3D,flow3DQ8def(tt3Drig,i+1),'r:','DisplayName',name,'LineWidth',2);
% %     hold on
% %     
% %     % VSD 3:1
% %     name = sprintf('%s 3D 3:1 Deform',branches{i});
% %     plot(t3D,flow3DQ12(i,tt3D),'g','DisplayName',name,'LineWidth',2);
% %     hold on
% %     name = sprintf('%s 3D 3:1 Rigid',branches{i});
% %     plot(t3D,flow3DQ12def(tt3Drig,i+1),'g:','DisplayName',name,'LineWidth',2);
% %     hold on
%     
%     % show legend
%     lgd = legend('show','Location','eastoutside');
%     lgd.FontSize = 8;
%     set(lgd, 'Interpreter','none');
%     legend('boxOff')
%     xlim([0 cycle*dt])
%     xlabel('time (s)')
%     ylabel('flow (cm^3/s)')
%     title({'Flow at Branch in', 'PA model for VSD Conditions'})
% end
% 
% 
% 
% % Plot Inflow Waveforms
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % % VSD 1:1
% % name = 'Inflow 1D Normal';
% % plot(t, flow1D_Q4(1,tt)*60/1000, 'DisplayName',name,'LineWidth',2);
% % hold on;
% % name = 'Inflow 3D Normal';
% % plot(t3D, flow3DQ4(tt3D, 2)*60/1000,':', 'DisplayName',name,'LineWidth',2);
% % hold on;
% % VSD 2:1
% name = 'Inflow 1D VSD 2:1';
% plot(t, flow1D_Q8(1,tt)*60/1000,'r', 'DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inflow 3D VSD 2:1';
% plot(t3D, flow3DQ8def(tt3D, 2)*60/1000, 'r:', 'DisplayName',name,'LineWidth',2);
% hold on;
% % VSD 3:1
% name = 'Inflow 1D VSD 3:1';
% plot(t, flow1D_Q12(1,tt)*60/1000,'g', 'DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inflow 3D VSD 3:1';
% plot(t3D, flow3DQ12def(tt3D, 2)*60/1000, 'g:', 'DisplayName',name,'LineWidth',2);
% hold on;
% 
% xlabel('Time (s)');
% ylabel('Flow (L/min)');
% title({'Inflow Waveform Comparison', 'between 1D and 3D'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 8;
% set(lgd, 'Interpreter','none');
% 
% 
% % Average flow error at each outlet and inlet
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % avg_flow1D_Q4 = mean(flow1D_Q4(:,tt),2);
% % avg_flow3D_Q4 = mean(flow3DQ4(tt3D,2:end,1))';
% avg_flow1D_Q8 = mean(flow1D_Q8(:,tt),2);
% avg_flow3D_Q8 = mean(flow3DQ8def(tt3D,2:end,1))';
% avg_flow1D_Q12 = mean(flow1D_Q12(:,tt),2);
% avg_flow3D_Q12 = mean(flow3DQ12def(tt3D,2:end,1))';
% 
% % name = 'Normal Flow error';
% % plot(100*(avg_flow1D_Q4-avg_flow3D_Q4)./avg_flow3D_Q4,'bo');
% % hold on;
% name = 'VSD 2:1 Flow error';
% plot(100*(avg_flow1D_Q8-avg_flow3D_Q8)./avg_flow3D_Q8,'ro','DisplayName',name);
% hold on
% name = 'VSD 3:1 Flow error';
% plot(100*(avg_flow1D_Q12-avg_flow3D_Q12)./avg_flow3D_Q12,'go','DisplayName',name);
% 
% xlabel('PA model outlets');
% ylabel({'% Error difference between', '1D and 3D (normalized to 3D)'});
% title({'Flow error at outlets in', 'PA model for VSD Conditions'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 8;
% set(lgd, 'Interpreter','none');
% 
% colors = [0    0.4470    0.7410;
%       0.8500    0.3250    0.0980;
%       0.9290    0.6940    0.1250];
% b(1).FaceColor = colors(1,:);
% b(2).FaceColor = colors(2,:);
% 
% % Flow over entire cardiac cycle
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % % VSD 1:1
% % name = '1D Normal';
% % plot(t1Dall, flow1D_Q4(12,:)*60/1000, 'DisplayName',name,'LineWidth',2);
% % hold on;
% % name = '3D Normal';
% % plot(t3Dall, flow3DQ4(:, 13)*60/1000,':', 'DisplayName',name,'LineWidth',2);
% % hold on;
% % VSD 2:1
% name = '1D VSD 2:1';
% plot(t1Dall, flow1D_Q8(12,:)*60/1000,'r', 'DisplayName',name,'LineWidth',2);
% hold on;
% name = '3D VSD 2:1';
% plot(t3Dall, flow3DQ8def(:, 13)*60/1000, 'r:', 'DisplayName',name,'LineWidth',2);
% hold on;
% % VSD 3:1
% name = '1D VSD 3:1';
% plot(t1Dall, flow1D_Q12(12,:)*60/1000,'g', 'DisplayName',name,'LineWidth',2);
% hold on;
% name = '3D VSD 3:1';
% plot(t3Dall, flow3DQ12def(:, 13)*60/1000, 'g:', 'DisplayName',name,'LineWidth',2);
% hold on;
% 
% xlabel('Time (s)');
% ylabel('Flow (L/min)');
% title({'Flow Convergence', 'in 1D and 3D'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 8;
% set(lgd, 'Interpreter','none');


% %% Pressure Plots
% 
% % Read pressure data
% % %   Normal VSD 1:1
% % pressure1D_Q4 = [];
% % vasculaturePressure = [];
% % temp = load(strcat(prefix_name,branches{2},'_0','_pressure.dat'));
% % [rows, ~] = size(temp);
% % pressure1D_Q4(1,:) = temp(1,:);
% %   VSD 2:1
% pressure1D_Q8 = [];
% vasculaturePressure = [];
% temp = load(strcat(path_nameQ8,branches{2},'_0','_pressure.dat'));
% [rows, ~] = size(temp);
% pressure1D_Q8(1,:) = temp(1,:);
% %   VSD 3:1
% pressure1D_Q12 = [];
% vasculaturePressure = [];
% temp = load(strcat(path_nameQ12,branches{2},'_0','_pressure.dat'));
% [rows, ~] = size(temp);
% pressure1D_Q12(1,:) = temp(1,:);
% 
% 
% % all other outlet pressures
% for ind_outlet = 2:size(outlet_segname,2)
% %     % Normal VSD 1:1
% %     temp = load(strcat(prefix_name,outlet_segname{ind_outlet},'_pressure.dat'));
% %     [rows, ~] = size(temp);
% %     pressure1D_Q4(ind_outlet,:) = temp(rows,:);
%     % VSD 2:1
%     temp = load(strcat(path_nameQ8,outlet_segname{ind_outlet},'_pressure.dat'));
%     [rows, ~] = size(temp);
%     pressure1D_Q8(ind_outlet,:) = temp(rows,:);
%     % VSD 3:1
%     temp = load(strcat(path_nameQ12,outlet_segname{ind_outlet},'_pressure.dat'));
%     [rows, ~] = size(temp);
%     pressure1D_Q12(ind_outlet,:) = temp(rows,:);
% end
% % Convert from Barye to mmHg
% % pressure1D_Q4 = 0.0007500616827.*pressure1D_Q4;
% pressure1D_Q8 = 0.0007500616827.*pressure1D_Q8;
% pressure1D_Q12 = 0.0007500616827.*pressure1D_Q12;
% 
% 
% 
% % Convert from Barye to mmHg
% pressure3D_Q4defuni = 0.0007500616827.*pressure3D_Q4defuni;
% pressure3D_Q8def = 0.0007500616827.*pressure3D_Q8def;
% pressure3D_Q12def = 0.0007500616827.*pressure3D_Q12def;
% pressure3D_Q4rig = 0.0007500616827.*pressure3D_Q4rig;
% pressure3D_Q8rig = 0.0007500616827.*pressure3D_Q8rig;
% pressure3D_Q12rig = 0.0007500616827.*pressure3D_Q12rig;
% 
% %%%%%%%%%%%% GENERATE PLOTS %%%%%%%%%%%%%
% 
% % Plot all pressures
% % figure(figureNum)
% % figureNum = figureNum + 1;
% 
% % Make colors for 3 of the same color plotted in a row
% co = [0    0.4470    0.7410;
%     0    0.4470    0.7410;
%     0    0.4470    0.7410;
%     0.8500    0.3250    0.0980;
%     0.8500    0.3250    0.0980;
%     0.8500    0.3250    0.0980;
%     0.9290    0.6940    0.1250;
%     0.9290    0.6940    0.1250;
%     0.9290    0.6940    0.1250;
%     0.4940    0.1840    0.5560;
%     0.4940    0.1840    0.5560;
%     0.4940    0.1840    0.5560;
%     0.4660    0.6740    0.1880;
%     0.4660    0.6740    0.1880;
%     0.4660    0.6740    0.1880;
%     0.3010    0.7450    0.9330;
%     0.3010    0.7450    0.9330;
%     0.3010    0.7450    0.9330;
%     0.6350    0.0780    0.1840;
%     0.6350    0.0780    0.1840;
%     0.6350    0.0780    0.1840
%     0         0         1
%     0         0         1
%     0         0         1
%     1         0         0
%     1         0         0
%     1         0         0
%     1         0         1
%     1         0         1
%     1         0         1];
% set(groot,'defaultAxesColorOrder',co);
% hold on
% 
% for i = 2:20:size(pressure1D_Q8,1)
%     figure(figureNum)
%     figureNum = figureNum + 1;
%     
% %     % Normal Q4 1:1
% %     name = sprintf('%s 1D Normal',branches{i});
% %     plot(t,pressure1D_Q4(i,tt),'DisplayName',name,'LineWidth',2);
% %     hold on
% %     name = sprintf('%s 3D Normal',branches{i});
% %     plot(t3D,pressure3D_Q4(tt3D,i+1),':','DisplayName',name,'LineWidth',2);
% %     hold on
%     % VSD 2:1
%     name = sprintf('%s 1D VSD 2:1',branches{i});
%     plot(t,pressure1D_Q8(i,tt),'r','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 2:1',branches{i});
%     plot(t3D,pressure3D_Q8def(tt3D,i+1),'r:','DisplayName',name,'LineWidth',2);
%     hold on
%     % VSD 3:1
%     name = sprintf('%s 1D VSD 3:1',branches{i});
%     plot(t,pressure1D_Q12(i,tt),'g','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 3:1',branches{i});
%     plot(t3D,pressure3D_Q12def(tt3D,i+1),'g:','DisplayName',name,'LineWidth',2);
%     hold on
%     
%     lgd = legend('show','Location','eastoutside');
%     lgd.FontSize = 8;
%     set(lgd, 'Interpreter','none');
%     legend('boxOff')
%     xlim([0 cycle*dt])
%     xlabel('time (s)')
%     ylabel('pressure (mmHg)')
%     title({'Pressure at Branch in','PA model for VSD Conditions'})
% end
% 
% 
% % Plot Pressure Waveform at inlet
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on;
% 
% % % Normal 1:1
% % name = 'Inlet P 1D Normal';
% % plot(t, pressure1D_Q4(1,tt),'DisplayName',name,'LineWidth',2);
% % hold on;
% % name = 'Inlet P 3D Normal';
% % plot(t3D, pressure3D_Q4(tt3D,2),':','DisplayName',name,'LineWidth',2);
% % hold on
% % VSD 2:1
% name = 'Inlet P 1D VSD 2:1';
% plot(t, pressure1D_Q8(1,tt),'r','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D VSD 2:1';
% plot(t3D, pressure3D_Q8def(tt3D,2),'r:','DisplayName',name,'LineWidth',2);
% % VSD 3:1
% name = 'Inlet P 1D VSD 3:1';
% plot(t, pressure1D_Q12(1,tt),'g','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D VSD 3:1';
% plot(t3D, pressure3D_Q12def(tt3D,2),'g:','DisplayName',name,'LineWidth',2);
% 
% xlabel('Time (s)');
% ylabel('Pressure (mmHg)');
% title({'Pressure Comparison between', '1D and 3D Inlet'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 8;
% set(lgd, 'Interpreter','none');
% legend('boxOff')
% 
% 
% % Average pressure at each outlet and inlet
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % avg_pressure1D_Q4 = mean(pressure1D_Q4(:,tt),2);
% % avg_pressure3D_Q4 = mean(pressure3D_Q4(tt3D,2:end),1)';
% avg_pressure1D_Q8 = mean(pressure1D_Q8(:,tt),2);
% avg_pressure3D_Q8 = mean(pressure3D_Q8def(tt3D,2:end),1)';
% avg_pressure1D_Q12 = mean(pressure1D_Q12(:,tt),2);
% avg_pressure3D_Q12 = mean(pressure3D_Q12def(tt3D,2:end),1)';
% 
% % name = 'Normal Pressure error';
% % plot(100*(avg_pressure1D_Q4-avg_pressure3D_Q4)./avg_pressure3D_Q4,'bo','DisplayName',name)
% % hold on
% name = 'VSD 2:1 Pressure error';
% plot(100*(avg_pressure1D_Q8-avg_pressure3D_Q8)./avg_pressure3D_Q8,'ro','DisplayName',name)
% hold on
% name = 'VSD 3:1 Pressure error';
% plot(100*(avg_pressure1D_Q12-avg_pressure3D_Q12)./avg_pressure3D_Q12,'go','DisplayName',name)
% 
% xlabel('PA model outlets');
% ylabel({'% Error difference between','1D and 3D (normalized to 3D)'});
% title({'Pressure error at outlets', 'in PA model for VSD Conditions'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 8;
% set(lgd, 'Interpreter','none');
% 
% colors = [0    0.4470    0.7410;
%       0.8500    0.3250    0.0980;
%       0.9290    0.6940    0.1250];
% b(1).FaceColor = colors(1,:);
% b(2).FaceColor = colors(2,:);
% 
% 
% % Plot Pressure Waveform at inlet
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on;
% 
% % % Normal 1:1
% % name = 'P 1D Normal';
% % plot(t1Dall, pressure1D_Q4(12,:),'DisplayName',name,'LineWidth',2);
% % hold on;
% % name = 'P 3D Normal';
% % plot(t3Dall, pressure3D_Q4(:,13),':','DisplayName',name,'LineWidth',2);
% % hold on
% % VSD 2:1
% name = 'P 1D VSD 2:1';
% plot(t1Dall, pressure1D_Q8(12,:),'r','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'P 3D VSD 2:1';
% plot(t3Dall, pressure3D_Q8def(:,13),'r:','DisplayName',name,'LineWidth',2);
% % VSD 3:1
% name = 'P 1D VSD 3:1';
% plot(t1Dall, pressure1D_Q12(12,:),'g','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'P 3D VSD 3:1';
% plot(t3Dall, pressure3D_Q12def(:,13),'g:','DisplayName',name,'LineWidth',2);
% 
% xlabel('Time (s)');
% ylabel('Pressure (mmHg)');
% title({'Pressure Convergence in', '1D and 3D Branch'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 8;
% set(lgd, 'Interpreter','none');
% legend('boxOff')
% 
% 
% %% WSS Plots
% 
% viscosity = 0.04;
% 
% % Area outlet differences
% %   3D area
% area3D = load('/home/melody/PH/CHD_model/VSD_QP/SU0201_2009_outletArea.txt');
% 
% 
% % Read WSS data
% % %   Normal 1:1
% % wss1D_Q4 = [];
% % vasculaturewss = [];
% % temp = load(strcat(prefix_name,branches{2},'_0','_wss.dat'));
% % [rows, ~] = size(temp);
% % wss1D_Q4(1,:) = temp(rows,:);
% %   VSD 2:1
% wss1D_Q8 = [];
% vasculaturewss = [];
% temp = load(strcat(path_nameQ8,branches{2},'_0','_wss.dat'));
% [rows, ~] = size(temp);
% wss1D_Q8(1,:) = temp(rows,:);
% %   VSD 3:1
% wss1D_Q12 = [];
% vasculaturewss = [];
% temp = load(strcat(path_nameQ12,branches{2},'_0','_wss.dat'));
% [rows, ~] = size(temp);
% wss1D_Q12(1,:) = temp(rows,:);
% 
% 
% % 3D outlet areas
% % wss3D_Q4 = [];
% wss3D_Q8def = [];
% wss3D_Q12def = [];
% wss3D_Q8rig = [];
% wss3D_Q12rig = [];
% 
% % all other outlet WSS
% for ind_outlet = 2:size(outlet_segname,2)
% %     % Normal 1:1
% %     temp = load(strcat(prefix_name,outlet_segname{ind_outlet},'_wss.dat'));
% %     [rows, ~] = size(temp);
% %     wss1D_Q4(ind_outlet,:) = temp(rows,:);
% %     wss3D_Q4(ind_outlet-1,:) = 4*viscosity*flow3DQ4(tt3D, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
%     % VSD 2:1
%     temp = load(strcat(path_nameQ8,outlet_segname{ind_outlet},'_wss.dat'));
%     [rows, ~] = size(temp);
%     wss1D_Q8(ind_outlet,:) = temp(rows,:);
%     wss3D_Q8def(ind_outlet-1,:) = 4*viscosity*flow3DQ8def(tt3D, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
%     wss3D_Q8rig(ind_outlet-1,:) = 4*viscosity*flow3DQ8rig(tt3Drig, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
%     
%     % VSD 3:1
%     temp = load(strcat(path_nameQ12,outlet_segname{ind_outlet},'_wss.dat'));
%     [rows, ~] = size(temp);
%     wss1D_Q12(ind_outlet,:) = temp(rows,:);
%     wss3D_Q12def(ind_outlet-1,:) = 4*viscosity*flow3DQ12def(tt3D, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
%     wss3D_Q12rig(ind_outlet-1,:) = 4*viscosity*flow3DQ12rig(tt3Drig, ind_outlet+1)./(pi*sqrt(area3D(ind_outlet-1)/pi)^3);
% 
% end
% 
% %   1D area
% % area1D_Q4 = pi*((4*viscosity*mean(flow1D_Q4(:,tt),2))./(pi*mean(wss1D_Q4(:,tt),2))).^(2/3);
% area1D_Q8 = pi*((4*viscosity*mean(flow1D_Q8(:,tt),2))./(pi*mean(wss1D_Q8(:,tt),2))).^(2/3);
% area1D_Q12 = pi*((4*viscosity*mean(flow1D_Q12(:,tt),2))./(pi*mean(wss1D_Q12(:,tt),2))).^(2/3);
% 
% % Plot average WSS at outlets
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % avg_wss1D_Q4 = mean(wss1D_Q4(2:end,tt),2);
% % avg_wss3D_Q4 = mean(wss3D_Q4(:,:),2);
% avg_wss1D_Q8 = mean(wss1D_Q8(2:end,tt),2);
% avg_wss3D_Q8def = mean(wss3D_Q8def(:,:),2);
% avg_wss3D_Q8rig = mean(wss3D_Q8rig(:,:),2);
% avg_wss1D_Q12 = mean(wss1D_Q12(2:end,tt),2);
% avg_wss3D_Q12def = mean(wss3D_Q12def(:,:),2);
% avg_wss3D_Q12rig = mean(wss3D_Q12rig(:,:),2);
% 
% % % Normal 1:1
% % name = '1D WSS Normal';
% % plot(avg_wss1D_Q4,'b*','DisplayName',name);
% % hold on;
% % name = '3D WSS Normal';
% % plot(avg_wss3D_Q4,'bo','DisplayName',name);
% % hold on
% % VSD 2:1
% name = '1D WSS VSD 2:1';
% plot(avg_wss1D_Q8,'r*','DisplayName',name);
% hold on;
% name = '3D WSS VSD 2:1';
% plot(avg_wss3D_Q8def,'ro','DisplayName',name);
% hold on
% % VSD 3:1
% name = '1D WSS VSD 3:1'
% plot(avg_wss1D_Q12,'g*','DisplayName',name);
% hold on;
% name = '3D WSS VSD 3:1'
% plot(avg_wss3D_Q12def,'go','DisplayName',name);
% hold on
% 
% xlabel('PA Model Outlets');
% ylabel('WSS (dyn/cm2)');
% title('WSS comparison between 1D and 3D')
% lgd = legend('show', 'Location','eastoutside');
% lgd.FontSize = 8;
% set(lgd, 'Interpreter','none');
% 
% 
% 
% % Plot outlet areas
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on;
% 
% plot(area1D_Q8(2:end),'bo');
% hold on;
% plot(area3D,'ro')
% title('Area of 1D and 3D outlets');
% legend('1D area','3D area')
% 
% 
% % Average WSS error at each outlet
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % plot(100*(avg_wss1D_Q4-avg_wss3D_Q4)./avg_wss3D_Q4,'bo');
% plot(100*(avg_wss1D_Q8-avg_wss3D_Q8def)./avg_wss3D_Q8def,'ro');
% plot(100*(avg_wss1D_Q12-avg_wss3D_Q12def)./avg_wss3D_Q12def,'go');
% 
% xlabel('PA model outlets');
% ylabel('Error difference between 1D and 3D (normalized to 3D)');
% title('WSS error at outlets in PA model');
% legend('WSS Error VSD 2:1','WSS Error VSD 3:1');
% 
% 
% % Average WSS vs. area at each outlet
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % % Normal
% % name = '1D WSS Normal';
% % plot(area1D_Q4(2:end),avg_wss1D_Q4,'b*','DisplayName',name);
% % hold on;
% % name = '3D WSS Normal';
% % plot(area3D, avg_wss3D_Q4, 'bo','DisplayName',name);
% % hold on;
% % VSD 2:1
% name = '1D WSS VSD 2:1';
% plot(area1D_Q8(2:end),avg_wss1D_Q8,'r*','DisplayName',name);
% hold on;
% name = '3D WSS VSD 2:1';
% plot(area3D, avg_wss3D_Q8def, 'ro','DisplayName',name);
% hold on;
% % VSD 3:1
% name = '1D WSS VSD 3:1';
% plot(area1D_Q8(2:end),avg_wss1D_Q12,'g*','DisplayName',name);
% hold on;
% name = '3D WSS VSD 3:1';
% plot(area3D, avg_wss3D_Q12def, 'go','DisplayName',name);
% hold on;
% 
% 
% legend('show','Location','eastoutside');
% xlabel('Area (cm^2)');
% ylabel('WSS (dyn/cm2)');
% title('WSS comparison between 1D and 3D')
% 
% 
% %% Plots inidividual
% 
% set(0, 'defaultTextFontSize',16);
% 
% 
% 
% % VSD 2:1
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on;
% name = 'Inlet P 1D VSD 2:1';
% plot(t, pressure1D_Q8(1,tt),'r','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D VSD 2:1 Deform';
% plot(t3D, pressure3D_Q8def(tt3D,2),'r:','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D VSD 2:1 Rigid';
% plot(t3Drig, pressure3D_Q8rig(tt3Drig,2),'r-.','DisplayName',name,'LineWidth',2);
% ylim([0 250]);
% set(0, 'defaultTextFontSize',16);
% xlabel('Time (s)');
% ylabel('Pressure (mmHg)');
% title({'Pressure Comparison between', '1D and 3D Inlet: VSD 2:1'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 12;
% set(lgd, 'Interpreter','none');
% legend('boxOff')
% 
% % VSD 3:1
% figure(figureNum)
% figureNum = figureNum + 1;
% name = 'Inlet P 1D VSD 3:1';
% plot(t, pressure1D_Q12(1,tt),'g','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D VSD 3:1 Deform';
% plot(t3D, pressure3D_Q12def(tt3D,2),'g:','DisplayName',name,'LineWidth',2);
% hold on;
% name = 'Inlet P 3D VSD 3:1 Rigid';
% plot(t3Drig, pressure3D_Q12rig(tt3Drig,2),'g-.','DisplayName',name,'LineWidth',2);
% ylim([0 250]);
% set(0, 'defaultTextFontSize',16);
% xlabel('Time (s)');
% ylabel('Pressure (mmHg)');
% title({'Pressure Comparison between', '1D and 3D Inlet: VSD 3:1'});
% lgd = legend('show','Location','eastoutside');
% lgd.FontSize = 12;
% set(lgd, 'Interpreter','none');
% legend('boxOff')
% 
% 
% % Plot Pressure at LPA 3_1 & RPA 3_3
% for i = [22, 62] %22:size(pressure1D_Q4,1)
% %     figure(figureNum)
% %     figureNum = figureNum + 1;
% %     % Normal Q4 1:1
% %     name = sprintf('%s 1D Normal',branches{i});
% %     plot(t,pressure1D_Q4(i,tt),'b','DisplayName',name,'LineWidth',2);
% %     hold on
% %     name = sprintf('%s 3D Normal',branches{i});
% %     plot(t3D,pressure3D_Q4(tt3D,i+1),'b:','DisplayName',name,'LineWidth',2);
% %     hold on
% %     if i == 22
% %         ylim([0 120]);
% %     else
% %         ylim([0 70]);
% %     end
% %     set(0, 'defaultTextFontSize',16);
% %     lgd = legend('show','Location','eastoutside');
% %     lgd.FontSize = 12;
% %     set(lgd, 'Interpreter','none');
% %     legend('boxOff')
% %     xlim([0 cycle*dt])
% %     xlabel('time (s)')
% %     ylabel('pressure (mmHg)')
% %     title({'Pressure at Branch in','PA model for Normal Conditions'})
%     
%     figure(figureNum)
%     figureNum = figureNum + 1;
%     % VSD 2:1
%     name = sprintf('%s 1D VSD 2:1',branches{i});
%     plot(t,pressure1D_Q8(i,tt),'r','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 2:1 Deform',branches{i});
%     plot(t3D,pressure3D_Q8def(tt3D,i+1),'r:','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 2:1 Rigid',branches{i});
%     plot(t3Drig,pressure3D_Q8rig(tt3Drig,i+1),'r-.','DisplayName',name,'LineWidth',2);
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
%     title({'Pressure at Branch in','PA model for VSD 2:1'})
%     
%     figure(figureNum)
%     figureNum = figureNum + 1;
%     % VSD 3:1
%     name = sprintf('%s 1D VSD 3:1',branches{i});
%     plot(t,pressure1D_Q12(i,tt),'g','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 3:1 Deform',branches{i});
%     plot(t3D,pressure3D_Q12def(tt3D,i+1),'g:','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 3:1 Rigid',branches{i});
%     plot(t3Drig,pressure3D_Q12rig(tt3Drig,i+1),'g-.','DisplayName',name,'LineWidth',2);
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
%     title({'Pressure at Branch in','PA model for VSD 3:1'})
% end
% 
% 
% 
% 
% % Plot Flow at LPA3_3 and RPA1_3
% for i = [22, 62]; %2:20:size(flow1D_Q4,1)
% %     figure(figureNum)
% %     figureNum = figureNum + 1;
% %     % VSD 1:1
% %     name = sprintf('%s 1D Normal',branches{i});
% %     plot(t,flow1D_Q4(i,tt),'b','DisplayName',name,'LineWidth',2);
% %     hold on
% %     name = sprintf('%s 3D Normal',branches{i});
% %     plot(t3D,flow3DQ4(tt3D,i+1),'b:','DisplayName',name,'LineWidth',2);
% %     hold on
% %     % show legend
% %     if i == 22
% %         ylim([0 12]);
% %     else
% %         ylim([0 3.5]);
% %     end
% %     set(0, 'defaultTextFontSize',16);
% %     lgd = legend('show','Location','eastoutside');
% %     lgd.FontSize = 12;
% %     set(lgd, 'Interpreter','none');
% %     legend('boxOff')
% %     xlim([0 cycle*dt])
% %     xlabel('time (s)')
% %     ylabel('flow (cm^3/s)')
% %     title({'Flow at Branch in', 'PA model for Normal Conditions'})
%     
%     figure(figureNum)
%     figureNum = figureNum + 1;
%     % VSD 2:1
%     name = sprintf('%s 1D VSD 2:1',branches{i});
%     plot(t,flow1D_Q8(i,tt),'r','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 2:1 Deform',branches{i});
%     plot(t3D,flow3DQ8def(tt3D,i+1),'r:','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 2:1 Rigid',branches{i});
%     plot(t3Drig,flow3DQ8rig(tt3Drig,i+1),'r-.','DisplayName',name,'LineWidth',2);
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
%     title({'Flow at Branch in', 'PA model for VSD 2:1'})
%     
%     figure(figureNum)
%     figureNum = figureNum + 1;    
%     % VSD 3:1
%     name = sprintf('%s 1D VSD 3:1',branches{i});
%     plot(t,flow1D_Q12(i,tt),'g','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 3:1 Deform',branches{i});
%     plot(t3D,flow3DQ12def(tt3D,i+1),'g:','DisplayName',name,'LineWidth',2);
%     hold on
%     name = sprintf('%s 3D VSD 3:1 Rigid',branches{i});
%     plot(t3Drig,flow3DQ12rig(tt3Drig,i+1),'g-.','DisplayName',name,'LineWidth',2);
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
%     title({'Flow at Branch in', 'PA model for VSD 3:1'})
% end
% 
% 
% % Average WSS vs. area at each outlet
% figure(figureNum)
% figureNum = figureNum + 1;
% hold on
% 
% % % Normal
% % plot(2*sqrt(area1D_Q4(2:end)./pi),avg_wss1D_Q4,'b*');
% % hold on;
% % plot(2*sqrt(area3D./pi), avg_wss3D_Q4, 'bo');
% % hold on;
% % VSD 2:1
% plot(2*sqrt(area1D_Q8(2:end)./pi),avg_wss1D_Q8,'r*');
% hold on;
% plot(2*sqrt(area3D./pi), avg_wss3D_Q8def, 'ro');
% hold on;
% plot(2*sqrt(area3D./pi), avg_wss3D_Q8rig, 'r+');
% hold on;
% % VSD 3:1
% plot(2*sqrt(area1D_Q8(2:end)./pi),avg_wss1D_Q12,'g*');
% hold on;
% plot(2*sqrt(area3D./pi), avg_wss3D_Q12def, 'go');
% hold on;
% plot(2*sqrt(area3D./pi), avg_wss3D_Q12rig, 'g+');
% hold on;
% 
% set(0, 'defaultTextFontSize',16);
% lgd = legend('1D WSS Normal', '3D WSS Normal', '1D WSS VSD 2:1','3D WSS VSD 2:1 Defom','3D WSS VSD 2:1 Rigid',...
%     '1D WSS VSD 3:1','3D WSS VSD 3:1 Deform','3D WSS VSD 3:1 Rigid');
% lgd.FontSize = 12;
% set(lgd, 'Interpreter','none');
% legend('boxOff')
% xlabel('Diameter of Vessel (cm)');
% ylabel('WSS (dyn/cm2)');
% title({'WSS comparison between 1D and 3D','for VSD Conditions'})