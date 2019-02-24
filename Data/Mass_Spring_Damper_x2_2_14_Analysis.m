% Project:        2.14 Demos
% Title:          2x Mass-Spring-Damper Demo
% Author:         Tyler Hamer
% Creation Date:  Friday, February 22nd, 2019

%% (0A) DESCRIPTION

% Designing a controller for the 2.14 2 x Mass-Spring-Damper Demo

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

% Mechanical Plant Parameters
m1          = 0.85;              % [kg]     mass of body 1
m2          = 0.3;               % [kg]     mass of body 2
b1          = 15;                % [N*s/m]  damping coefficient for damper 1
b2          = 0.4;               % [N*s/m]  damping coefficient for damper 2
k1          = 1400;              % [N/m]    stiffness for spring 1
k2          = 975;               % [N/m]    stiffness for spring 2

% Electical Plant Parameters
R           = 0.85;              % [ohm]    resistance of voice coil
L           = 5e-3;              % [H]      inductance of voice coil
Kf          = 7.1;               % [N/A]    voice coil - force constant

% Other Parameters
Kpower      = 2;                 % [V/V]    power amplifier gain
Ksense      = 94;                % [V/m]    LVDT sensor gain

% Sampling
Fs          = 2e3;               % [Hz]     1kHz sample rate
tau_Fs      = 1/Fs;              % [sec]    time delay for 2kHz sample rate

% Transfer Functions
s           = tf('s');           %          define Laplace Variable 's'
z           = tf('z', tau_Fs);   %          define unit delay

%% (3) Plant

% Mechanical + Electicl Model System Matrix
P.A = [     0           0         1          0       0   ; ...
            0           0         0          1       0   ; ...
       -(k1+k2)/m1    k2/m1  -(b1+b2)/m1   b2/m1   Kf/m1 ; ...
          k2/m2      -k2/m2     b2/m2     -b2/m2     0   ; ...
         -Kf/L          0         0          0     -R/L  ] ;
   
P.B = [0 0 0 0 Kpower/L]';

P.C = [Ksense 0 0 0 0] ;

P.D = 0;

% Mechanical + Electrical System Model
P.tf = ss(P.A,P.B,P.C,P.D);

P.zoh       = c2d(P.tf, tau_Fs); %          zero order hold of plant TF
P.approx    = P.tf*exp(-tau_Fs*s/2); %      approx zero order hold with tau_Fs/2 time delay

% Measured Data for Plant - Frequency [Hz], Magnitude [abs], Phase [deg]
P.meas_data = xlsread('Mass_Spring_Damper_x2_2_14_Analysis.xlsx', 'A4:C361');

% Data for ZoH Model of Plant
[temp1, temp2] =  bode( P.zoh, (2*pi*P.meas_data(:,1)) );         

%                      Frquency       Magnitude         Phase
%                        [Hz]           [abs]           [deg]
P.zoh_data     = [P.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

% Data for ZoH Approximated Model of Plant
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
title({'2 Mass-Spring-Damper \& Voice Coil Freq. Response', ...
       '$\omega_{\rm N1}$ = 5.0 Hz, $\omega_{\rm Z}$ = 9.0 Hz, $\omega_{\rm N2}$ = 11.0 Hz, \& $f_{\rm s}$ = 2 kHz'})
legend('Measured', 'ZoH Discrete Model', '$\tau$/2 Delay Cont. Model', 'Location', 'Southwest')
xlabel('$ \rm Frequency~[Hz] $');
ylabel('Magnitude [abs]');
xlim(5*[1e-1, 1e2])
ylim([1e-5, 1e1])
xticks( 5*logspace(-1,2,4) )
yticks( logspace(-5,1,7) )
grid on;

subplot(2,1,2)
semilogx(P.meas_data(:,1),  P.meas_data(:,3),  'b.');
hold on;
semilogx(P.zoh_data(:,1), P.zoh_data(:,3), 'r-');
semilogx(P.approx_data(:,1), P.approx_data(:,3), 'g--');
xlabel('$ \rm Frequency~[Hz] $');
ylabel('Phase [deg]');
xlim(5*[1e-1, 1e2])
ylim( [-540 0] )
xticks( 5*logspace(-1,2,4) )
yticks( -540:90:0 )
grid on;

%% (4) Controller

% Desired properties for the controller
Wc          = 2*pi*40;           % [rad/s]  desired crossover
phi_M       = 20;                % [deg]    phase margin
phi_loss    = 33;                % [deg]    from close lag cntrl & LP filters

% Lead Compensator
Cntrl.N_lead = 2;                % [ ]      number of lead compensators
[~, phi]    = min( abs(2*pi*P.meas_data(:,1) - Wc) );
phi         = (phi_M - 180) - (P.meas_data(phi, 3)-phi_loss); 
phi         = deg2rad(phi/Cntrl.N_lead); 
                                 % [ ]     desired phase to add
alpha       = (1+sin(phi)) ./ (1-sin(phi))
                                 % [ ]      lead alpha
Td          = 1./(Wc*sqrt(alpha))
                                 % [sec]    lead time constant
Cntrl.lead  = (alpha*Td*s+1) / (Td*s+1);
                                 %          lead compensator                                  
% I Controller
Ti          = 1/(0.1*Wc)         % [sec]    lag time constant
Cntrl.Int   = (Ti*s+1) / (Ti*s); %          I controller 

% High Frequency Low Pass Filter
Cntrl.N_lp  = 2;                 % [ ]      number of low pass filters
Tlp         = 1/(5*Wc)           % [sec]    Low pass filter time constant
Cntrl.lp    = 1/(Tlp*s+1);       %          High frequency low pass filter

% Proportional Gain
Cntrl.tf    = (Cntrl.lead)^Cntrl.N_lead * ...
               Cntrl.Int *                ...
              (Cntrl.lp)^Cntrl.N_lp; %      ungained controller
[Kp,~]      = bode(Cntrl.tf*P.approx, Wc);
Kp          = 1/Kp               % [ ]      proportional gain

% Full Controller
Cntrl.tf    = Kp*Cntrl.tf;       %          gained controller

% Data for Controller - Frequency [Hz], Magnitude [abs], Phase [deg]
Cntrl.meas_data = xlsread('Mass_Spring_Damper_x2_2_14_Analysis.xlsx', 'E4:G360');

% Data for Controller Model
[temp1, temp2] =  bode( Cntrl.tf, (2*pi*Cntrl.meas_data(:,1)) );         

%                      Frquency             Magnitude         Phase
%                        [Hz]                 [abs]           [deg]
Cntrl.tf_data = [Cntrl.meas_data(:,1), squeeze(temp1), squeeze(temp2)];

figure()
subplot(2,1,1)
loglog(Cntrl.meas_data(:,1),  Cntrl.meas_data(:,2),  'b.');
hold on;
loglog(Cntrl.tf_data(:,1), Cntrl.tf_data(:,2), 'r-');
titTF1 = '$~C(s) = K_{\rm p} ( \frac{ \tau_{\rm i} s+1 }{ \tau_{\rm i} s } ) ';
titTF2 = ' ( \frac{ \alpha \tau_{\rm d} s+1 }{ \tau_{\rm d} s+1 } )^{2} ';
titTF3 = ' ( \frac{ 1 }{ \tau_{\rm lp} s+1 } )^{2} $';
titval = '$K_{\rm p}=9.3,$ $\tau_{\rm i}=0.04$ sec, $\alpha=6.4,$ $\tau_{\rm d}=0.0016$ sec, \& $\tau_{\rm lp}=0.0008$ sec';
tit = strcat('Controller: ', titTF1, titTF2, titTF3 );
title({tit, titval})
legend('Measured', 'Cont. Model', 'Location', 'Northwest')
xlabel('$ \rm Frequency~[Hz] $');
ylabel('Magnitude [abs]');
xlim(5*[1e-1, 1e2])
ylim([1e1, 1e3])
xticks( 5*logspace(-1,2,4) )
yticks( logspace(1,3,3) )
grid on;

subplot(2,1,2)
semilogx(Cntrl.meas_data(:,1),  Cntrl.meas_data(:,3),  'b.');
hold on;
semilogx(Cntrl.tf_data(:,1), Cntrl.tf_data(:,3), 'r-');
xlabel('$ \rm Frequency~[Hz] $');
ylabel('Phase [deg]');
xlim(5*[1e-1, 1e2])
ylim( [-90 90] )
xticks( 5*logspace(-1,2,4) )
yticks( -90:45:90 )
grid on;

%% (5) Return Ratio

% Return Ratio
RR.tf       = Cntrl.tf*P.approx;  %         return ratio

% Data for Return Ratio - Frequency [Hz], Magnitude [abs], Phase [deg]
RR.meas_data = xlsread('Mass_Spring_Damper_x2_2_14_Analysis.xlsx', 'I4:K360');

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
titTF1 = '$~RR(s) = C(s)P(s)H(s) ~\&~ \omega_{\rm c-desired}=40~ \rm{Hz}, \phi_{\rm M-desired} = 20^{\rm o}$';
tit = strcat('Return Ratio: ', titTF1);
title(tit)
legend('Measured', 'Cont. Model', 'Location', 'Southwest')
xlabel('$ \rm Frequency~[Hz] $');
ylabel('Magnitude [abs]');
xlim(5*[1e-1, 1e2])
ylim([1e-3, 1e2])
xticks( 5*logspace(-1,2,4) )
yticks( logspace(-3,2,6) )
grid on;

subplot(2,1,2)
semilogx(RR.meas_data(:,1),  RR.meas_data(:,3),  'b.');
hold on;
semilogx(RR.tf_data(:,1), RR.tf_data(:,3), 'r-');
xlabel('$ \rm Frequency~[Hz] $');
ylabel('Phase [deg]');
xlim(5*[1e-1, 1e2])
ylim([-540, 0])
xticks( 5*logspace(-1,2,4) )
yticks( -540:90:0 )
grid on;

figure()
bode(RR.tf, opts, 'r')
set(findall(gcf,'type','line'),'linewidth',LineWdith)
titTF1 = '$~RR(s) = C(s)P(s)H(s) ~\&~ \omega_{\rm c-desired}=40~ \rm{Hz}, \phi_{\rm M-desired} = 40^{\rm o}$';
tit = strcat('Return Ratio: ', titTF1);
title(tit)
xlim(5*[1e-1, 1e2])
xticks( 5*logspace(-1,2,4) )
grid on

figure()
nyquist(RR.tf, 'b')
xlim([-20, 10])
ylim([-15, 15])

%% (8) Closed Loop

% Closed Loop
CL.tf       = RR.tf/(1+RR.tf);   %           closed loop

% Data for Closed Loop - Frequency [Hz], Magnitude [abs], Phase [deg]
CL.meas_data = xlsread('Mass_Spring_Damper_x2_2_14_Analysis.xlsx', 'M4:O360');

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
titTF = '$~T(s) = \frac{ Y(s) }{ R(s) } = \frac{ Y(s) }{ n(s) } = \frac{ C(s)P(s) }{ 1+C(s)P(s)H(s) }$';
titval = '$\omega_{\rm N-desired}=40$ Hz, $\omega_{\rm N}=26$ Hz, $\zeta_{\rm desired}=0.2,$ \& $\zeta=0.26$';
tit = strcat('Complementary Sensitivity / Closed Loop: ', titTF);
title({tit, titval})
legend('Measured', 'Model', 'Location', 'Southwest')
ylabel('Magnitude [abs]');
xlabel('$ \rm Frequency~[Hz] $');
xlim(5*[1e-1, 1e2])
ylim([1e-3, 1e1])
xticks( 5*logspace(-1,2,4) )
yticks( logspace(-3,1,5) )
grid on;

subplot(2,1,2)
semilogx(CL.meas_data(:,1),  CL.meas_data(:,3),  'b.');
hold on;
semilogx(CL.tf_data(:,1), CL.tf_data(:,3), 'r-');
xlabel('$ \rm Frequency~[Hz] $');
ylabel('Phase [deg]');
xlim(5*[1e-1, 1e2])
ylim([-540, 0])
xticks( 5*logspace(-1,2,4) )
yticks( -540:90:0 )
grid on;