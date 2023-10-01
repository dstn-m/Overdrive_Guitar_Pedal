% ***********************************
% Project     : SD-1 Circuit Simulation
% Author      : Dustin Matthews
% Date        : 10/10/2023
% Description : Numberically simulate transfer functions that were
%               derived by hand analytically for the SD-1's Tone Control
%               circuitry.
%
% ***********************************

%--------------%
% Tone Control
%--------------%
% circuit parameters
Rf   = 10000; % feedback loop resistor
Cf   = 10e-9; % feedback loop cap
Rg   = 470;   % filter resistor to ground
Cg   = 27e-9; % filter cap to ground
Rpm  = 10000; % potentiometer middle position resistance
Rp   = 20000; % potentiometer at edge resistance
% simulation parameters
min_freq = 20;
max_freq = 20000;
f = linspace(min_freq, max_freq, 10000); % frequency vector
w = 2 * pi * f;                        % convert to radians


%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-
% intermediate impedances
Zp = 1./ (1i * Cg .* w) + Rg; % filter network at middle lug of potentiometer
Zf = (Rf./ (1i * Cf .* w)) ./ (Rf + 1./ (1i * Cf .* w)); % feedback loop impedance
%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-

% simulate with potentiometer in middle position
Hwm = Zf .*(1/Rpm + 1./Zf - ((2*Zp) ./(Rpm^2 + 2*Rpm.*Zp)));

mag_Hwm = abs(Hwm);%20* log10(Hwm);
mag_Hwm = 20 .* log10(mag_Hwm);
figure(1)

semilogx(w ./ (2*pi), mag_Hwm);
hold on;
xlim([min(f) max(f)]);
set(gca, "fontsize", 20);
xlabel('Hz'); ylabel('dB');
title('SD-1 Op-amp Filter Section');

%-%-%-%-%-%
% derive filter properties
[maxY, maxYindex] = max(mag_Hwm);
wo_mid = f(maxYindex);                        % center freq
mid_peak = maxY;                              % gain at center freq
fprintf('f_o = %gHz, gain at f_o = %g dB\n', wo_mid, mid_peak);

g3dB = mid_peak - 3;
f3 = find(((mag_Hwm>(g3dB-.005)) & (mag_Hwm<(g3dB+.005))), 2);
f3dB_lwr = f(f3(1));
f3dB_upper = f(f3(2));
fprintf('f_c lower = %gHz, f_c upper = %gHz\nBW = %gHz\n\n',...
                     f3dB_lwr, f3dB_upper, f3dB_upper-f3dB_lwr);
%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-
% simulate with potentiometer in far right position (max)
Hw_max = 1 + Zf ./ Zp;

mag_Hw_max = abs(Hw_max);%20* log10(Hwm);
mag_Hw_max = 20 .* log10(mag_Hw_max);

semilogx(w ./ (2*pi), mag_Hw_max);

hold off;
legend('Potentiometer Middle Position', 'Potentiometer Max Position');
%-%-%-%-%-%
% derive filter properties
[maxY, maxYindex] = max(mag_Hw_max);
wo_max = f(maxYindex);
max_peak = maxY;
fprintf('f_o = %g, gain at f_o = %g dB\n', wo_max, max_peak);

g3dB = max_peak - 3;
f3_2 = find(((mag_Hw_max>(g3dB-.005)) & (mag_Hw_max<(g3dB+.005))), 2);
f3dB_lwr = f(f3_2(1));
f3dB_upper = f(f3_2(2));
fprintf('f_c lower = %gHz, f_c upper = %gHz\nBW = %gHz\n\n',...
                     f3dB_lwr, f3dB_upper, f3dB_upper-f3dB_lwr);

%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-
% plot individual freq responses
figure(2)
semilogx(w ./ (2*pi), mag_Hwm);
xlim([min(f) max(f)]);
set(gca, "fontsize", 20);
xlabel('Hz'); ylabel('dB');
title('Op-Amp Filter, Potentiometer Middle Position');

figure(3)
semilogx(w ./ (2*pi), mag_Hw_max);
xlim([min(f) max(f)]);
set(gca, "fontsize", 20);
xlabel('Hz'); ylabel('dB');
title('Op-Amp Filter, Potentiometer Maximum Position');
