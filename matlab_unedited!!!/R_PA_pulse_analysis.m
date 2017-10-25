%% Generate Plots for Pulmonary Arteries 1D and 3D
% Adapted from Casey's R_Aorta_Pulse_New.m script
% Melody Dong 9/26/17

clear
clc
close all

orig_direc = '/home/melody/PH/CHD_model/Analysis_1D3D/';

%%%%%%%%%%%%%%%% USER INPUT: Directory for Results Files %%%%%%%%%%%%%%%%%%
% Names of Results for Comparison (with prefix for 1D results)
% For linear solver comparison
% direc_1D = {'/home/melody/OneDSolver_Project/sparse_MT/test/skyline/', ...
%     '/home/melody/OneDSolver_Project/sparse_MT/test/sparse_noMT/', ...
%     '/home/melody/OneDSolver_Project/sparse_MT/test/sparse_MT/'};
% direc_3D = {};
% prefix_name = 'PA_106bif_20FE';
% res_names = {'Skyline Matrix','Sparse Matrix Single Proc','Sparse Matrix Multithreading'};

% For 1D/3D comparison of 1:1
% direc_1D = {};
% direc_3D = {'/home/melody/PH/CHD_model/VSD_QP/R_BC/rigid/pulsatile/72-procs_case/VSD_QP_oldgui-allresults/', ...
%     '/home/melody/PH/CHD_model/VSD_QP/R_BC/deform/puls', ...
%     '/home/melody/PH/CHD_model/VSD_QP/RCR_BC/rigid/puls', ...
%     };
% prefix_name = {};
% res_names = {'1:1 3D Rigid R','1:1 3D Def Uni R E311 h0.17', ...
%     '1:1 3D Rigid RCR', };

% For 1D/3D comparison of VSD 2:1
% direc_1D = {};
% direc_3D = {'/home/melody/PH/CHD_model/VSD_Q8R200/R_BC/rigid/pulsatile/72-procs_case/VSD_Q8R200_oldguid-allresults/', ...
%     '/home/melody/PH/CHD_model/VSD_Q8R200/R_BC/deform/puls/',...
%     '/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/rigid/puls/', ...
%     '/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/deform/uniwall/puls/',...
%     '/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/deform/varwall/E290/',...
%     '/home/melody/PH/CHD_model/VSD_Q8R200/RCR_BC/deform/varwall/E311/'};
% prefix_name = {};
% res_names = {'2:1 3D R Rigid','2:1 3D R Def Uni E311 h0.17', ...
%     '2:1 3D RCR Rigid','2:1 3D RCR Def Uni E311 h0.17',...
%     '2:1 3D RCR Def E290 Var','2:1 3D RCR Def E311 Var'};

% For 1D/3D comparison of VSD 3:1
direc_1D = {};
direc_3D = {'/home/melody/PH/CHD_model/VSD_Q12R200/R_BC/rigid/pulsatile/72-procs_case/VSD_Q12R200_oldgui-allresults/', ...
    '/home/melody/PH/CHD_model/VSD_Q12R200/R_BC/deform/puls/',...
    '/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/rigid/puls/', ...
    '/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/deform/uniwall/puls/', ...
    '/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/deform/varwall/96-procs_case_E311/', ...
    '/home/melody/PH/CHD_model/VSD_Q12R200/RCR_BC/deform/varwall/96-procs_case_E351/'};
prefix_name = 'PA_106bif_LINEAR_Q12_deform_RCR_puls';
res_names = {'3:1 3D R Rigid','3:1 3D R Def Uni E311 h0.17', ...
    '3:1 3D RCR Rigid','3:1 3D RCR Def Uni E311 h0.17',...
    '3:1 3D RCR Def E311 Var','3:1 3D RCR Def E351 Var'};

area3D = load('/home/melody/PH/CHD_model/Analysis_1D3D/SU0201_2009_outletArea.txt');

viscosity = 0.04;

% P/Q Conversion
pConv = 7.500615050434136e-04; % Pressure cgs --> mmHg
qConv = 0.06; % Flow cgs --> L/min

%%%%% Notes about Comparison %%%%%
% Comparing 1D and 3D simulations for Normal 1:1. Adjusting deformable wall
% simulations to test if GMRES and deformable wall is working
    

%%%%%%%%%%%%%%%%% Load .dat files to parse through %%%%%%%%%%%%%%%%%%%%%%%%
if size(direc_1D,2) >= 1
    direc = direc_1D{1};
    cd(direc);
    dat_list = dir('*.dat');
    dat_names = {dat_list.name};
    clearvars dat_list
end

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

if size(direc_1D,2) >= 1
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
        temp_seg = temp(size(prefix_name{1},2)+1:(end-size('_Re.dat',2)));
        segnum = str2num(temp_seg(size(temp_branch,2)+1:end));
        
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
    for ind_outlet = 1:size(branches,2)
        temp_Q = flow3D{i};
        temp_wss(ind_outlet,:) = 4*viscosity*temp_Q(:,ind_outlet+1)./(pi*sqrt(area3D(ind_outlet)/pi)^3);
    end
    wss3D{i} = temp_wss;
    
    
    clear temp*
    
end


%%%%%%%%%%%%%%%%%%%%%%% 1D Simulation P/Q/WSS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flow1D = cell([1, size(direc_1D,1)]);
press1D = cell([1, size(direc_1D,1)]);
wss1D = cell([1, size(direc_1D,1)]);
area1D = cell([1, size(direc_1D,1)]);



% Parse through all 1D Results Directories
for i = 1:size(direc_1D,2)
    % Read Inflow for 1D
    temp_Qin = load(strcat(direc_1D{i}, prefix_name{i}, branches{2}, '_0', '_flow.dat')); % inflow branch name
    temp_flow(1,:) = temp_Qin(1,:);
    
    % Read Inlet Pressure for 1D
    temp_Pin = load(strcat(direc_1D{i}, prefix_name{i}, branches{2},'_0','_pressure.dat')); % inlet pressure branch name
    temp_press(1,:) = temp_Pin(1,:);
    
    % Read Inlet WSS for 1D
    temp_WSSin = load(strcat(direc_1D{i}, prefix_name{i}, branches{2},'_0','_wss.dat')); % inlet pressure branch name
    temp_wss(1,:) = temp_WSSin(1,:);
    
    % Read Outlet P/Q for 1D
    for ind_outlet = 2:size(outlet_segname,2)
        % Outlet Flow
        temp_Qout = load(strcat(direc_1D{i}, prefix_name{i}, outlet_segname{ind_outlet},'_flow.dat'));
        [rows, ~] = size(temp_Qout);
        temp_flow(ind_outlet,:) = temp_Qout(rows,:); %only saves last element in segment (outlet)
        
        % Outlet Pressure
        temp_Pout = load(strcat(direc_1D{i}, prefix_name{i}, outlet_segname{ind_outlet},'_pressure.dat'));
        [rows, ~] = size(temp_Pout);
        temp_press(ind_outlet,:) = temp_Pout(rows,:);
        
        % Outlet WSS
        temp_WSSout = load(strcat(direc_1D{i}, prefix_name{i}, outlet_segname{ind_outlet},'_wss.dat'));
        [rows, ~] = size(temp_WSSout);
        temp_wss(ind_outlet,:) = temp_WSSout(rows,:);
        
        temp_Aout = load(strcat(direc_1D{i}, prefix_name{i}, outlet_segname{ind_outlet},'_area.dat'));
        [rows, ~] = size(temp_Aout);
        temp_area(ind_outlet,:) = temp_Aout(rows,:);
%         area1D(ind_outlet) = pi*((4*viscosity*mean(temp_flow(ind_outlet,2:end)))./(pi*mean(temp_wss(ind_outlet,2:end)))).^(2/3);
    end
    
    % Convert P/Q
%     temp_flow = temp_flow*qConv;
    temp_press = temp_press.*pConv;
    
    % Add temp flows and pressures to cell array of all 1D results
    flow1D{i} = temp_flow;
    press1D{i} = temp_press;
    wss1D{i} = temp_wss;
    area1D{i} = temp_area;
    
    clear temp*
    
end


clear rows

%%%%%%%%%%%% SET UP TIME ARRAYS %%%%%%%%%%%%%
if size(direc_1D,1)>0
    % Get info for 1D data
    [~, numSteps] = size(flow1D{1});
    % how many save steps in one cardiac cycle (i.e. 1 second)
    cycle = 44;
    dt = 0.02;
    % convert times to seconds
    t = 0:dt:(cycle-1)*dt;
    % % only plot the last cardiac cycle
    startcycle=86;
    tt = startcycle:startcycle+cycle-1;
%     tt = (numSteps-cycle):numSteps-1;
    % extended time
    t1Dall = 0:dt:(numSteps-1)*dt;
end

% Do the same for 3D data
if size(direc_3D,1)>0
    cycle3D = 21;
    dt3D = 0.04285;
    [numSteps3D,~] = size(flow3D{1});
    % convert time to seconds
    t3D = 0:dt3D:(cycle3D-1)*dt3D;
    % only plot last cardiac cycle
    tt3D = numSteps3D-(3*cycle3D):(numSteps3D-2*cycle3D)-1;
    % extended time
    t3Dall = 0:dt3D:(numSteps3D-1)*dt3D;
end

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
figureNum = figureNum + 1;
figure(figureNum)
figureNum = figureNum + 1;

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
        temp_area = area1D{i};
        
        % 1D Inflow
        figure(1)
        plot(t, temp_flow(1,tt), 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;
        
        % 1D Inlet Pressure
        figure(2)
        plot(t, temp_press(1,tt)+10, 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;
        
        % 1D WSS vs. Area
        figure(3)
        plot(mean(temp_area(2:end,tt),2), mean(temp_wss(2:end,tt),2), 'o', 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;
        
        % 1D Outlet Branch Flow and Pressure
        for ind_outlet = 2:20:size(branches,2)
            % Flow
            figure(ind_outlet+figureNum);
            name = sprintf('%s %s',res_names{i},branches{ind_outlet});
            plot(t,temp_flow(ind_outlet,tt),'Color', co(coCount,:),'DisplayName',name,'LineWidth',2);
            hold on
            
            % Pressure
            figure(ind_outlet+figureNum+1);
            name = sprintf('%s %s',res_names{i},branches{ind_outlet});
            plot(t,temp_press(ind_outlet,tt)+10,'Color', co(coCount,:),'DisplayName',name,'LineWidth',2);
            hold on
        end
    
    elseif i > size(direc_1D, 2) && i <= size(direc_3D,2)+size(direc_1D,2)
        temp_flow = flow3D{i-size(direc_1D,2)};
        temp_press = press3D{i-size(direc_1D,2)};
        temp_wss = wss3D{i-size(direc_1D,2)};
        
        % 3D Inflow
        figure(1)
        plot(t3D, -temp_flow(tt3D, 2), 'Color', co(coCount,:), 'DisplayName', res_names{i}, 'LineWidth',2);
        hold on;
        
        % 3D Inlet Pressure
        figure(2)
        plot(t3D, temp_press(tt3D, 2), 'Color', co(coCount,:), 'DisplayName', res_names{i}, 'LineWidth',2);
        hold on;
    
        % 3D WSS vs. Area
        figure(3)
        plot(area3D(2:end), mean(temp_wss(2:end,tt3D),2), 'o', 'Color', co(coCount,:), 'DisplayName',res_names{i},'LineWidth',2);
        hold on;
        
        % 3D Outlet Flow and Pressure
        for ind_outlet = 2:20:size(branches,2)
            % Flow
            figure(ind_outlet+figureNum);
            name = sprintf('%s %s',res_names{i},branches{ind_outlet});
            plot(t3D,temp_flow(tt3D,ind_outlet+1),'Color', co(coCount,:),'DisplayName',name,'LineWidth',2);
            hold on
            
            % Pressure
            figure(ind_outlet+figureNum+1);
            name = sprintf('%s %s',res_names{i},branches{ind_outlet});
            plot(t3D,temp_press(tt3D,ind_outlet+1),'Color', co(coCount,:),'DisplayName',name,'LineWidth',2);
            hold on
        end
    
    else
        display('Error: index not in range of available results');
        break;
    end
    
end

figure(1)
set(0, 'defaultTextFontSize',10);
xlabel('Time (s)');
ylabel('Flow (ml/s)');
title({'Flow Comparison between', '1D and 3D Inlet: Normal'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 10;
set(lgd, 'Interpreter','none');
legend('boxOff')

figure(2)
set(0, 'defaultTextFontSize',10);
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
title({'Pressure Comparison between', '1D and 3D Inlet: Normal'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 10;
set(lgd, 'Interpreter','none');
legend('boxOff')

figure(3)
set(0, 'defaultTextFontSize',10);
xlabel('Vessel Area (cm^2)');
ylabel('WSS (dyn/cm^2)');
title({'WSS Comparison between', '1D and 3D: Normal'});
lgd = legend('show','Location','eastoutside');
lgd.FontSize = 10;
set(lgd, 'Interpreter','none');
legend('boxOff')

for ind_outlet = (2):20:(size(branches,2))
    % Outlet Flow plots
    figure(ind_outlet+figureNum);
    set(0, 'defaultTextFontSize',10);
    xlabel('Time (s)');
    ylabel('Flow (mL/s)');
    name = branches{ind_outlet};
    title({'Flow Comparison between', '1D and 3D Outlet: Normal',name});
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 10;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
    
    % Outlet Pressure plots
    figure(ind_outlet+figureNum+1);
    set(0, 'defaultTextFontSize',10);
    xlabel('Time (s)');
    ylabel('Pressure (mmHg)');
    name = branches{ind_outlet};
    title({'Pressure Comparison between', '1D and 3D Outlet: Normal',name});
    lgd = legend('show','Location','eastoutside');
    lgd.FontSize = 10;
    set(lgd, 'Interpreter','none');
    legend('boxOff')
end



%% Calculations
Avg3D = cell(size(direc_3D));

for i = 1:size(direc_3D,2)
    
    temp_flow = flow3D{i};
    temp_press = press3D{i};
    
    %Calculate Resistance of Pulmonary Artery (P=QR)
    [row col] = size(temp_flow);
    Qavg = [];
    for j = 1:(col-1)
        Qavg(:,j) = mean(temp_flow(:,j+1));
    end
    Qtot = abs(Qavg(:,1));  %-sum(Qavg(:,2:end))) % Calculates total flow

    Pout_avg = mean(mean(temp_press(:,3:end)));
    Pin_avg = mean(temp_press(:,2));
    Pdrop = (Pin_avg - Pout_avg); % Calculates pressure drop from inletto outlet

    RPA = Pdrop/Qtot; % Calculates resistance in Pulmonary artery of 3D model

    ccbegin = 41;
    ccend = 61;
    ccPout_avg = mean(mean(temp_press(tt3D,3:end)));
    ccPin_avg = mean(temp_press(tt3D,2));
    Qin_avg = mean(temp_flow(tt3D,2));
    Qout_avg = mean(mean(temp_flow(tt3D,3:end)));
    
    Avg3D{i} = [RPA; Qin_avg; Qout_avg; ccPin_avg; ccPout_avg];

end

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
