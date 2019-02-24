% Project:        2.14 TAing
% Title:          2.14 Magnetic Levitation Demo
% Author:         Tyler Hamer
% Creation Date:  Friday, February 1st, 2019

%% (0A) DESCRIPTION

% Designing a controller for the 2.14 magnetic levitation demo. 

%% (0B) REVISION LOG

%  Number   Editor          Description
%  00       Tyler Hamer     Created document 

%% (0C) Setup: Clears & Setups MatLAB

clear
clc
close all

% Default Values
FontSize    = 12;                % Default Line Size
LineWdith   = 1.5;               % Default Line Width
MarkerSize  = 16;                % Default Line Width

% General plotting settings
set(0,'defaultAxesFontSize',FontSize);
set(0,'defaultTextFontSize',FontSize);
set(0,'defaultTextInterpreter','latex');
set(0,'defaultLegendInterpreter','latex')
set(0,'defaultAxesTickLabelInterpreter','latex');  
set(0,'defaultLineLinewidth',LineWdith);
set(0,'defaultLineMarkerSize',MarkerSize);
set(0,'defaultFigureWindowStyle','docked')

% Bode Plot Settings
opts                       = bodeoptions;
opts.FreqUnits             = 'Hz';
opts.FreqScale             = 'log';
opts.MagUnits              = 'abs';
opts.MagScale              = 'log';
opts.PhaseUnits            = 'deg';
opts.Title.FontSize        = FontSize;
opts.Title.Interpreter     = 'latex';
opts.XLabel.FontSize       = FontSize;
opts.XLabel.Interpreter    = 'latex';
opts.YLabel.FontSize       = FontSize;
opts.YLabel.Interpreter    = 'latex';
opts.TickLabel.FontSize    = FontSize;
% set(findall(gcf,'type','line'),'linewidth',LineWdith)
% Bode plot line width cannot be set an input. Run above after plotting


% Debugging Mode - Only run to run code without plotting grpahs

%set(0,'DefaultFigureVisible','off');  % Disable Plots
set(0,'DefaultFigureVisible','on');   % Enable Plots

%% (2) Parameters

% Variable   Value                Unit      Description

% Constants
R           = 6.94e6;            % [ohm]    plant resistance
C           = 4.60e-9;           % [F]      plant capacitance
Fs          = 2e3;               % [Hz]     1kHz sample rate
tau_Fs      = 1/Fs;              % [sec]    time delay for 2kHz sample rate

% Transfer Functions
s           = tf('s');           %          define Laplace Variable 's'
z           = tf('z', tau_Fs);   %          define unit delay

%% (3) Plant

% Plant for RC Circuit
tau_RC      = R*C;               %          plant time constant
P.tf        = 1/(tau_RC*s + 1);  %          plant TF
P.zoh       = c2d(P.tf, tau_Fs); %          zero order hold of plant TF
P.approx    = P.tf*exp(-tau_Fs*s/2); %      approx zero order hold with tau_Fs/2 time delay

% Data for RC Circuit - Frequency [Hz], Magnitude [abs], Phase [deg]
P.meas_data = xlsread('Template_Code_2_14_Data.xlsx', 'A4:C105');

% Data for ZoH Model of RC Circuit
[temp1, temp2] =  bode( P.zoh, (2*pi*P.meas_data(:,1)) );         

%                      Frquency       Magnitude         Phase
%                        [Hz]           [abs]           [deg]
P.zoh_data     = [P.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

% Data for ZoH Approximated Model of RC Circuit
[temp1, temp2] =  bode( P.approx, (2*pi*P.meas_data(:,1)) );         

%                      Frquency       Magnitude         Phase
%                        [Hz]           [abs]           [deg]
P.approx_data  = [P.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

figure()
subplot(2,1,1)
loglog(P.meas_data(:,1),  P.meas_data(:,2),  'b.');
hold on;
loglog(P.zoh_data(:,1), P.zoh_data(:,2), 'r-');
loglog(P.approx_data(:,1), P.approx_data(:,2), 'g--');
title('RC Circuit Freq. Response, $ \rm \omega_{b}~=~5 Hz,~f_{s}~=~2kHz $')
legend('Measured', 'ZoH Discrete Model', '$\tau$/2 Delay Cont. Model', 'Location', 'Southwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([1e-3, 1e0])
grid on;
subplot(2,1,2)
semilogx(P.meas_data(:,1),  P.meas_data(:,3),  'b.');
hold on;
semilogx(P.zoh_data(:,1), P.zoh_data(:,3), 'r-');
semilogx(P.approx_data(:,1), P.approx_data(:,3), 'g--');
ylabel('Phase [deg]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([-180, 0])
yticks([-180, -135, -90, -45, 0])
grid on;

%% (4) Delay

% Time Delay Model
delay.tf     = exp(-tau_Fs*s);   %          time delay TF for 1kHz rate
delay.zoh    = 1/z;              %          zero order hold of time delay

% Data for Time Delay - Frequency [Hz], Magnitude [abs], Phase [deg]
delay.meas_data = xlsread('Template_Code_2_14_Data.xlsx', 'E4:G105');

% Data for ZoH Model of Time Delay
[temp1, temp2] =  bode( delay.zoh, (2*pi*P.meas_data(:,1)) );         

%                      Frquency       Magnitude         Phase
%                        [Hz]           [abs]           [deg]
delay.zoh_data = [P.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

% Data for Continuous Model of Time Delay
[temp1, temp2] =  bode( delay.tf, (2*pi*delay.meas_data(:,1)) );         

%                      Frquency       Magnitude         Phase
%                        [Hz]           [abs]           [deg]
delay.tf_data = [P.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

figure()
subplot(2,1,1)
loglog(delay.meas_data(:,1),  delay.meas_data(:,2),  'b.');
hold on;
loglog(delay.zoh_data(:,1), delay.zoh_data(:,2), 'r-');
loglog(delay.tf_data(:,1), delay.tf_data(:,2), 'g--');
title('Time Delay Freq. Response, $ ~f_{s}~=~2kHz $')
legend('Measured', 'ZoH Discrete Model', 'Continuous Model', 'Location', 'Southwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([1e-1, 1e1])
grid on;
subplot(2,1,2)
semilogx(delay.meas_data(:,1),  delay.meas_data(:,3),  'b.');
hold on;
semilogx(delay.zoh_data(:,1), delay.zoh_data(:,3), 'r-');
semilogx(delay.tf_data(:,1), delay.tf_data(:,3), 'g--');
ylabel('Phase [deg]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([-180, 0])
yticks([-180, -135, -90, -45, 0])
grid on;

%% (5) ZoH of Plant with Advance (High Frequency Phase Curl)

% Model 
HF_curl.tf   = z*P.zoh;          %          zero order hold of plant w/ advance

% Data for Time Delay - Frequency [Hz], Magnitude [abs], Phase [deg]
HF_curl.meas_data = xlsread('Template_Code_2_14_Data.xlsx', 'I4:K105');

% Data for ZoH Model of RC Circuit
[temp1, temp2] =  bode( HF_curl.tf, (2*pi*HF_curl.meas_data(:,1)) );         

%                      Frquency       Magnitude         Phase
%                        [Hz]           [abs]           [deg]
HF_curl.tf_data = [P.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

figure()
subplot(2,1,1)
loglog(HF_curl.tf_data(:,1),  HF_curl.tf_data(:,2),  'b.');
hold on;
loglog(HF_curl.meas_data(:,1), HF_curl.meas_data(:,2), 'r-');
title('ZoH of RC Circuit w/ Time Advance Freq. Response, $ ~f_{s}~=~2kHz $')
legend('Measured', 'Discrete Model', 'Location', 'Southwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([1e-2, 1e0])
grid on;
subplot(2,1,2)
semilogx(HF_curl.tf_data(:,1),  HF_curl.tf_data(:,3),  'b.');
hold on;
semilogx(HF_curl.meas_data(:,1), HF_curl.meas_data(:,3), 'r-');
ylabel('Phase [deg]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([-90, 0])
yticks([-90, -60, -30, 0])
grid on;

%% (6) Lead Compensator

% Desired properties for the controller
Wc          = 2*pi*50';         % [rad/s]  desired crossover
                                 
% Lead Compensator
phi         = deg2rad(30);       % [ ]      desired phase to add
alpha       = (1+sin(phi)) ./ (1-sin(phi));
                                 % [ ]      lead alpha
Td          = 1./(Wc*sqrt(alpha));
                                 % [sec]    lead time constant
C_lead.tf   = (alpha*Td*s+1) / (Td*s+1);
                                 %          lead compensator 

% Data for Lead Compensator - Frequency [Hz], Magnitude [abs], Phase [deg]
C_lead.meas_data = xlsread('Template_Code_2_14_Data.xlsx', 'M4:O105');

% Data for Lead Compensator Model
[temp1, temp2] =  bode( C_lead.tf, (2*pi*C_lead.meas_data(:,1)) );         

%                      Frquency             Magnitude         Phase
%                        [Hz]                 [abs]           [deg]
C_lead.tf_data = [C_lead.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

figure()
subplot(2,1,1)
loglog(C_lead.meas_data(:,1),  C_lead.meas_data(:,2),  'b.');
hold on;
loglog(C_lead.tf_data(:,1), C_lead.tf_data(:,2), 'r-');
titTF1 = '$ C_{\rm lead} = \frac{ \alpha \tau_{\rm d} s+1 }{ \tau_{\rm d} s+1 } $';
titTF2 = '$ \alpha = \frac{ 1 + \sin \phi_{M}  }{ 1 - \sin \phi_{M} }$';
titTF3 = '$ \tau_{\rm d} = \frac{ 1 }{ \sqrt{ \alpha } \omega_{\rm c} } $';
tit = ['Lead Compensator: ' titTF1 ', ' titTF2 ' $ \& $ ' titTF3];
title(tit)
legend('Measured', 'Cont. Model', 'Location', 'Northwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([1e0, 1e1])
grid on;
subplot(2,1,2)
semilogx(C_lead.meas_data(:,1),  C_lead.meas_data(:,3),  'b.');
hold on;
semilogx(C_lead.tf_data(:,1), C_lead.tf_data(:,3), 'r-');
ylabel('Phase [deg]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([0, 45])
yticks([0, 15, 30, 45])
grid on;

%% (7) Intergral Controller

% PI Controller
Ti          = 1/Wc;              % [sec]    lag time constant
C_int.tf     = (Ti*s+1) / (Ti*s); %          PI controller

% Data for Intergral Controller - Frequency [Hz], Magnitude [abs], Phase [deg]
C_int.meas_data = xlsread('Template_Code_2_14_Data.xlsx', 'Q4:S105');

% Data for Lead Compensator Model
[temp1, temp2] =  bode( C_int.tf, (2*pi*P.meas_data(:,1)) );         

%                      Frquency             Magnitude         Phase
%                        [Hz]                 [abs]           [deg]
C_int.tf_data = [C_int.meas_data(:,1), squeeze(temp1), squeeze(temp2)];
                                                                  
[temp1, temp2] =  bode( C_int.tf, (2*pi*C_int.meas_data(:,1)) );         
            
C_int.tf_data   = [C_int.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

figure()
subplot(2,1,1)
loglog(C_int.meas_data(:,1),  C_int.meas_data(:,2),  'b.');
hold on;
loglog(C_int.tf_data(:,1), C_int.tf_data(:,2), 'r-');
titTF1 = '$ C_{\rm PI} = \frac{ \tau_{\rm i} s+1 }{ \tau_{\rm i} s } $';
titTF2 = '$ \tau_{\rm i} = \frac{ 1 }{ \omega_{\rm c} } $';
tit = ['PI Controller: ' titTF1 ' $ \& $ ' titTF2];
title(tit)
legend('Measured', 'Cont. Model', 'Location', 'Southwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([0.9, 1.1e2])
grid on;
subplot(2,1,2)
semilogx(C_int.meas_data(:,1),  C_int.meas_data(:,3),  'b.');
hold on;
semilogx(C_int.tf_data(:,1), C_int.tf_data(:,3), 'r-');
ylabel('Phase [deg]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([-90, 0])
yticks([-90, -60, -30, 0])
grid on;

%% (8) Return Ratio

% Proportional Gain
Cntrl.tf    = C_lead.tf*C_int.tf; %         ungained controller
[Kp,~]      = bode(Cntrl.tf*P.approx, Wc);
Kp          = 1/Kp;              % [ ]      proportional gain

% Full Controller & Return Ratio
Cntrl.tf    = Kp*Cntrl.tf;       %          gained controller
RR.tf       = Cntrl.tf*P.approx; %          return ratio

% Data for Return Ratio - Frequency [Hz], Magnitude [abs], Phase [deg]
RR.meas_data = xlsread('Template_Code_2_14_Data.xlsx', 'U4:W105');

% Data for Return Ratio Model
[temp1, temp2] =  bode( RR.tf, (2*pi*RR.meas_data(:,1)) );         

%                 Frquency         Magnitude         Phase
%                   [Hz]             [abs]           [deg]
RR.tf_data = [RR.meas_data(:,1), squeeze(temp1), squeeze(temp2)];
                                                                  
[temp1, temp2] =  bode( RR.tf, (2*pi*RR.meas_data(:,1)) );         
            
RR.tf_data   = [RR.meas_data(:,1), squeeze(temp1), squeeze(temp2)];
                                                                  
[temp1, temp2] =  bode( RR.tf, (2*pi*RR.meas_data(:,1)) );         
            
RR.tf_data   = [RR.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

figure()
subplot(2,1,1)
loglog(RR.meas_data(:,1),  RR.meas_data(:,2),  'b.');
hold on;
loglog(RR.tf_data(:,1), RR.tf_data(:,2), 'r-');
titTF1 = '$RR = K_{\rm p} CP $';
titTF2 = '$ K_{\rm p} = \frac{ 1 }{ || CP || } |_{\omega = \omega_{\rm c} } $';
tit = ['Return Ratios: ' titTF1 ' $ \& $ ' titTF2];
title(tit)
legend('Measured', 'Cont. Model', 'Location', 'Southwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([1e-2, 1e3])
grid on;
subplot(2,1,2)
semilogx(RR.meas_data(:,1),  RR.meas_data(:,3),  'b.');
hold on;
semilogx(RR.tf_data(:,1), RR.tf_data(:,3), 'r-');
ylabel('Phase [deg]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([-180, 0])
yticks([-180, -135, -90, -45, 0])
grid on;

%% (8) Closed Loop

% Closed Loop
CL.tf       = RR.tf/(1+RR.tf);   %           closed loop

% Data for Closed Loop - Frequency [Hz], Magnitude [abs], Phase [deg]
CL.meas_data = xlsread('Template_Code_2_14_Data.xlsx', 'Y4:AA105');

% Data for Lead Compensator Model
[temp1, temp2] =  bode( CL.tf, (2*pi*CL.meas_data(:,1)) );         

%                 Frquency         Magnitude         Phase
%                   [Hz]             [abs]           [deg]
CL.tf_data = [CL.meas_data(:,1), squeeze(temp1), squeeze(temp2)];
                                                                  
[temp1, temp2] =  bode( CL.tf, (2*pi*CL.meas_data(:,1)) );         
            
figure()
subplot(2,1,1)
loglog(CL.meas_data(:,1),  CL.meas_data(:,2),  'b.');
hold on;
loglog(CL.tf_data(:,1), CL.tf_data(:,2), 'r-');
titTF = '$T = \frac{ Y }{ R } = \frac{ Y }{ n } = \frac{ CP }{ 1+CP }$';
tit = ['Complementary Sensitivity / Closed Loop: ' titTF];
title(tit)
legend('Measured', 'Model', 'Location', 'Southwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([1e-2, 1e1])
grid on;
subplot(2,1,2)
semilogx(CL.meas_data(:,1),  CL.meas_data(:,3),  'b.');
hold on;
semilogx(CL.tf_data(:,1), CL.tf_data(:,3), 'r-');
ylabel('Phase [deg]');
xlabel('$ \rm Frequency~[Hz] $');
ylim([-180, 0])
yticks([-180, -135, -90, -45, 0])
grid on;