%Dual rotor, single stator, axial flux, PM generator
%3-phase, delta connected (may change to series config but for now delta
%config lowers line voltage so thats why we're using it)

clear
clc
close all

%generator parameters
num_poles = 8;
num_coils = 12; %SHOULD OPTIMIZE, could also be 9 i think
M = 4; %halbach segments per wavelength
num_phases = 3;
num_turns = 100; %SHOULD OPTIMIZE # turns per coil, guess for now but can optimize later
kw = 0.85; %winding factor, assumed 0.85 because that seems to be typical for 12 coils 8 poles

%rotor geometry
od = 0.120; %m, active outer diameter
id = 0.069; %m, active inner diameter

%magnets
Br = 1.4800; %Teslas, max, from spec sheet (N52)
Bh = 52; %MGOe, max, from spec sheet
mag_length = 1*0.0254; %m magnet length
mag_width = 0.5*0.0254; %m, magnet width
thickness = 0.25*0.0254; %m, magnet thickness

%stator geometry
g = 0.003; %m
coil_thickness = 0.25*0.0254; %1/4" thick stator coils
k_loss = 0.9; %a loss term, seems to be standard to account for based on other examples but we can change/update after testing

%wire
d_wire = 0.000812; %m, 20 AWG
coil_width = 0.014; %m, average in middle of coil
rho_cu = 1.72*10^-8; %resistivity of CU at room temp
T_op = 50; %C, operating temperature, idk exactly what value this should be but I assumed a bit higher than air temp for now
L_ph = 0.001; %H, phase inductance, this is based on a paper I found but it is probably different for our generator

%load
R_load = 10; %ohms, load per each phase, just assumed for now because idk what the final load is

%rpm, 0 to 3000 (probably won't get to 3000 but just to be safe)
rpm = 0:1:3000;

%Halbach field per array using mean radius
% B_pk(y) = Br*(1-exp(-k*lm))*sinc_M*exp(-k*y),   
% k = 2*pi/lambda,  lambda = 4*pi*r_mean/p
sincM = sin(pi/M)/(pi/M); %4 segments
r_mean = (od/2 +id/2)/2;
lambda = 4*pi*r_mean/num_poles; %wavelength at mean radius
k = 2*pi/lambda; %how fast field decays with distance
coef = Br * (1-exp(-k*thickness)) * sincM; %accounts for increasing field strength with magnet thickness

avgExp = (exp(-k*g) - exp(-k*(g+coil_thickness)))/(k*coil_thickness); %decay across the air gap, averaged across distance from rotor from g to g+stator thickness
Bmean = 2*coef*avgExp*k_loss; %x2 because of 2 rotor arrays

%flux per pole = avg of sinusoid over poles * pole area
A_pole = pi*((od/2)^2 - (id/2)^2)/num_poles; %area of each pole on rotor
Phi = (2/pi)*Bmean*A_pole; %Wb, 2/pi because field varis sinusoidally across pole

%winding resistance (wire resistance w temp corrections)
N_ph = (num_coils/num_phases) * num_turns;
L_turn = 2*((od/2 - id/2) + coil_width);
A_wire = 1*pi*(d_wire/2)^2; %1 because strands are parallel
R_ph = rho_cu*(1+0.00393*(T_op-20))*N_ph*L_turn/A_wire; %copper losses

%electrical calcs
n = rpm/60;
f = num_poles/2*n; %frequency for faradays law
w_e = 2*pi*f; %frequency in radians
E_ph = 4.44*f*N_ph*Phi*kw; %rms, using faradays law, 4.44 is for converting to rms, per phase which is the same as the line voltage bc of delta config
Z_tot = sqrt((R_ph + R_load)^2 + (w_e*L_ph).^2); %impedance, account for load and copper resistance
I_ph = E_ph./Z_tot; %phase current
I_line = sqrt(3)*I_ph; %line current, increased bc delta config
V_term = I_ph * R_load; %voltage
P_out = num_phases*I_ph.^2*R_load;
P_cu = num_phases*I_ph.^2*R_ph;
eff = P_out./(P_out+P_cu);
eff(isnan(eff)) = 0;

%print outputs
fprintf('Mean coil flux density = %.3f T | Flux/pole = %.3e Wb | N_ph = %d | R_ph = %.3f ohm\n', ...
        Bmean, Phi, N_ph, R_ph);
fprintf('At %d rpm: Voc = %.1f V, V_load = %.1f V, P = %.1f W\n', ...
        rpm(end), E_ph(end), V_term(end), P_out(end));

%% 
%graphs
%not using all these graphs for presentation, open circuti and power are
%importanr for rn but made the rest to look at later
%rpm vs voltage
figure('Position',[100 100 1000 700]);
subplot(2,2,1); plot(rpm,E_ph,'LineWidth',1.5); grid on;
xlabel('Speed (rpm)'); ylabel('V_{oc} line (V rms)'); title('Open-circuit voltage');
subplot(2,2,2); plot(rpm,V_term,'LineWidth',1.5); grid on;
xlabel('Speed (rpm)'); ylabel('V_{line} (V rms)'); title('Loaded terminal voltage');
subplot(2,2,3); plot(rpm,P_out,'LineWidth',1.5); grid on;
xlabel('Speed (rpm)'); ylabel('Power (W)'); title('Output power');
subplot(2,2,4); plot(rpm,I_line,'LineWidth',1.5); grid on;
xlabel('Speed (rpm)'); ylabel('I_{line} (A rms)'); title('Line current');
 