clc; clear; close all;

%% 1. الإعدادات والفرضيات (Desert Harsh Environment)
num_trials = 200;
ptx_dBm = 4; 
gtx_dB = 5; grx_dB = 35; noise_floor = -125;
battery_mAh = 2000; voltage = 3.7; current_tx = 0.120;

% العتبات (Thresholds)
snr_threshold_bpsk = 7; 
snr_threshold_qpsk = 12;

% أزمنة الإرسال
time_bpsk = 4; time_qpsk = 1;  
retry_penalty = 2; % استهلاك الضعف عند الفشل

%% 2. المحاكاة وحساب الـ SNR
distances_km = 600 + 1400.*rand(num_trials, 1);
fspl = 20*log10(distances_km) + 20*log10(2.0) + 92.45;
snr_actual = (ptx_dBm + gtx_dB + grx_dB - fspl) - noise_floor;

% مصفوفات النتائج
energy_fixed_bpsk = zeros(num_trials, 1);
energy_fixed_qpsk = zeros(num_trials, 1);
energy_adaptive = zeros(num_trials, 1);
success_fixed_bpsk = 0; success_fixed_qpsk = 0; success_adaptive = 0;
adaptive_mode = zeros(num_trials, 1); 

e_b = voltage * current_tx * time_bpsk;
e_q = voltage * current_tx * time_qpsk;

%% 3. تشغيل السيناريوهات
for i = 1:num_trials
    % --- Fixed BPSK ---
    if snr_actual(i) >= snr_threshold_bpsk
        energy_fixed_bpsk(i) = e_b; success_fixed_bpsk = success_fixed_bpsk + 1;
    else
        energy_fixed_bpsk(i) = e_b * retry_penalty;
    end
    
    % --- Fixed QPSK ---
    if snr_actual(i) >= snr_threshold_qpsk
        energy_fixed_qpsk(i) = e_q; success_fixed_qpsk = success_fixed_qpsk + 1;
    else
        energy_fixed_qpsk(i) = e_q * retry_penalty;
    end
    
    % --- Adaptive System ---
    if snr_actual(i) >= snr_threshold_qpsk
        energy_adaptive(i) = e_q; success_adaptive = success_adaptive + 1;
        adaptive_mode(i) = 2;
    elseif snr_actual(i) >= snr_threshold_bpsk
        energy_adaptive(i) = e_b; success_adaptive = success_adaptive + 1;
        adaptive_mode(i) = 1;
    else
        energy_adaptive(i) = 0; adaptive_mode(i) = 0; 
    end
end

%% 4. حسابات الموثوقية بالنسبة المئوية (%)
% القانون: (النجاح / الإجمالي) * 100
reliability_qpsk = (success_fixed_qpsk / num_trials) * 100;
reliability_bpsk = (success_fixed_bpsk / num_trials) * 100;
reliability_adaptive = (success_adaptive / num_trials) * 100;

%% 5. حساب البطارية
total_joules = (battery_mAh/1000) * voltage * 3600;
drain_bpsk = total_joules - cumsum(energy_fixed_bpsk);
drain_qpsk = total_joules - cumsum(energy_fixed_qpsk);
drain_adaptive = total_joules - cumsum(energy_adaptive);

%% 6. الرسم الاحترافي (Professional Dashboard)
figure('Color', 'k', 'Position', [100, 50, 900, 950]);

% --- الرسمة 1: مناطق القرار ---
subplot(3,1,1); hold on;
scatter(find(adaptive_mode==2), snr_actual(adaptive_mode==2), 30, [0.4 1 0.4], 'filled');
scatter(find(adaptive_mode==1), snr_actual(adaptive_mode==1), 30, [1 1 0.4], 'filled');
scatter(find(adaptive_mode==0), snr_actual(adaptive_mode==0), 30, [1 0.2 0.2], 'filled');
yline(snr_threshold_qpsk, '--', 'QPSK Limit', 'Color', [0.8 0.4 0.4], 'LineWidth', 1.2, 'LabelHorizontalAlignment', 'right');
yline(snr_threshold_bpsk, '--', 'BPSK Limit', 'Color', [0.8 0.8 0.4], 'LineWidth', 1.2, 'LabelHorizontalAlignment', 'right');
title('Adaptive System Decision Regions', 'Color', 'w');
ylabel('SNR (dB)', 'Color', 'w'); grid on;
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]);
legend({'Chosen QPSK', 'Chosen BPSK', 'Smart Sleep'}, 'TextColor', 'w', 'Color', 'none', 'Location', 'northeast');

% --- الرسمة 2: الموثوقية بالنسبة المئوية (Success Rate %) ---
subplot(3,1,2);
bar_vals = [reliability_qpsk, reliability_bpsk, reliability_adaptive];
b = bar(bar_vals, 0.5, 'FaceColor', [0.3 0.5 0.8]);
set(gca, 'xticklabel', {'Fixed QPSK', 'Fixed BPSK', 'Adaptive (Smart)'}, ...
    'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]);
title('Overall System Reliability (%)', 'Color', 'w');
ylabel('Success Rate (%)', 'Color', 'w');
ylim([0 110]); % تعيين المدى حتى 100% (مع هامش بسيط للجمالية)
grid on;
% إضافة قيمة النسبة فوق كل عمود للتوضيح
text(1:3, bar_vals, string(round(bar_vals,1))+'%', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'w', 'FontWeight', 'bold');

% --- الرسمة 3: مقارنة البطارية ---
subplot(3,1,3);
plot(drain_qpsk, 'r', 'LineWidth', 1.8); hold on;
plot(drain_bpsk, 'b', 'LineWidth', 1.8);
plot(drain_adaptive, 'g', 'LineWidth', 2.5);
title('Battery Life: System Comparison', 'Color', 'w');
ylabel('Energy (Joules)', 'Color', 'w'); xlabel('Transmission Attempt', 'Color', 'w');
legend({'Fixed QPSK', 'Fixed BPSK', 'Adaptive System'}, 'TextColor', 'w', 'Color', 'none');
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]); grid on;
