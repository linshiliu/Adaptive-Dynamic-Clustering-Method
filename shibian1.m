%% IEEE 33-Bus - Quarter Circle Radar Charts (2x2 Layout)
% 与聚类拓扑图数据一致

clear all; close all; clc;

%% ========================================================================
%% Part 1: Data Definition (与聚类拓扑图一致)
%% ========================================================================

% Scenario names (与拓扑图一致)
scenarios = {'S1: Initial (06:00)', 'S2: PV Ramp (09:00)', ...
             'S3: Load Surge (14:00)', 'S4: Reconfig (18:00)'};
scenarios_short = {'S1', 'S2', 'S3', 'S4'};

% Performance metrics (与拓扑图数据一致)
% Silhouette Coefficient
sc_dynamic = [0.72, 0.81, 0.78, 0.83];
sc_static  = [0.62, 0.58, 0.60, 0.51];

% VDI (Voltage Deviation Index, p.u.)
vdi_dynamic = [0.038, 0.042, 0.035, 0.032];
vdi_static  = [0.045, 0.052, 0.048, 0.050];

% VDI Improvement (%)
vdi_improvement = (vdi_static - vdi_dynamic) ./ vdi_static * 100;

% Net Load Change (%)
net_load_scenario = [-8, -25, 35, 48];

% TAPL (Total Active Power Loss, MW) - 基于场景推算
tapl_dynamic = [0.185, 0.172, 0.168, 0.165];
tapl_static  = [0.202, 0.198, 0.215, 0.220];
tapl_improvement = (tapl_static - tapl_dynamic) ./ tapl_static * 100;

% Modularity (基于聚类变化程度)
modularity_dynamic = [0.68, 0.82, 0.85, 0.88];
modularity_static  = [0.68, 0.68, 0.68, 0.68];

% Adaptability Score (综合自适应能力)
adaptability_dyn = [0.70, 0.85, 0.88, 0.92];
adaptability_sta = [0.70, 0.58, 0.52, 0.45];

% Colors for scenarios
colors_scenarios = [
    0.216 0.494 0.722;   % S1 - Blue
    0.894 0.102 0.110;   % S2 - Red  
    0.302 0.686 0.290;   % S3 - Green
    0.596 0.306 0.639;   % S4 - Purple
];

%% ========================================================================
%% Part 2: Quarter Circle Radar Charts (2x2 Layout)
%% ========================================================================

fig1 = figure('Position', [50 50 1200 1000], 'Color', 'white', 'Renderer', 'painters');

% Radar metrics (5 metrics)
radar_labels = {'VDI Impr.(%)', 'TAPL Impr.(%)', 'Silhouette', 'Modularity', 'Adaptability'};
num_metrics = 5;

% Normalize all data to 0-100 scale for radar display
radar_data_dyn = zeros(4, num_metrics);
radar_data_sta = zeros(4, num_metrics);

for s = 1:4
    radar_data_dyn(s, :) = [vdi_improvement(s), tapl_improvement(s), ...
                            sc_dynamic(s)*100, modularity_dynamic(s)*100, adaptability_dyn(s)*100];
    radar_data_sta(s, :) = [0, 0, sc_static(s)*100, modularity_static(s)*100, adaptability_sta(s)*100];
end

% Quarter circle angles (0 to 90 degrees)
angles = linspace(0, pi/2, num_metrics);
max_val = 100;
grid_levels = [20, 40, 60, 80, 100];

for s = 1:4
    subplot(2, 2, s);
    hold on; box off;
    
    % Draw quarter circle grid
    for gl = grid_levels
        theta_arc = linspace(0, pi/2, 50);
        x_arc = gl * cos(theta_arc);
        y_arc = gl * sin(theta_arc);
        plot(x_arc, y_arc, ':', 'Color', [0.75 0.75 0.75], 'LineWidth', 0.8);
        % Grid level labels
        text(gl + 2, 0, sprintf('%d', gl), 'FontSize', 8, 'Color', [0.5 0.5 0.5], ...
             'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
    end
    
    % Draw axes from origin to each metric direction
    for a = 1:num_metrics
        plot([0, max_val*cos(angles(a))], [0, max_val*sin(angles(a))], '-', ...
             'Color', [0.6 0.6 0.6], 'LineWidth', 1);
        
        % Metric labels at the end of each axis
        label_x = (max_val + 15) * cos(angles(a));
        label_y = (max_val + 15) * sin(angles(a));
        
        % Adjust alignment based on angle
        if angles(a) < pi/6
            h_align = 'left';
            v_align = 'middle';
        elseif angles(a) > pi/3
            h_align = 'center';
            v_align = 'bottom';
        else
            h_align = 'left';
            v_align = 'bottom';
        end
        
        text(label_x, label_y, radar_labels{a}, 'FontSize', 10, 'FontWeight', 'bold', ...
             'HorizontalAlignment', h_align, 'VerticalAlignment', v_align, 'FontName', 'Arial');
    end
    
    % Draw X and Y axes
    plot([0, max_val+5], [0, 0], 'k-', 'LineWidth', 1.2);
    plot([0, 0], [0, max_val+5], 'k-', 'LineWidth', 1.2);
    
    % Plot Dynamic Clustering data
    data_dyn = radar_data_dyn(s, :);
    x_dyn = data_dyn .* cos(angles);
    y_dyn = data_dyn .* sin(angles);
    
    % Fill area for dynamic
    fill([0, x_dyn, 0], [0, y_dyn, 0], colors_scenarios(s, :), ...
         'FaceAlpha', 0.3, 'EdgeColor', colors_scenarios(s, :), 'LineWidth', 2);
    
    % Plot points and connecting line for dynamic
    plot([x_dyn, x_dyn(1)], [y_dyn, y_dyn(1)], '-', ...
         'Color', colors_scenarios(s, :), 'LineWidth', 2);
    plot(x_dyn, y_dyn, 'o', 'MarkerSize', 10, ...
         'MarkerFaceColor', colors_scenarios(s, :), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    
    % Plot Static Clustering data
    data_sta = radar_data_sta(s, :);
    x_sta = data_sta .* cos(angles);
    y_sta = data_sta .* sin(angles);
    
    % Fill area for static
    fill([0, x_sta, 0], [0, y_sta, 0], [0.7 0.7 0.7], ...
         'FaceAlpha', 0.2, 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.5, 'LineStyle', '--');
    
    % Plot points for static
    plot(x_sta, y_sta, 's', 'MarkerSize', 8, ...
         'MarkerFaceColor', [0.7 0.7 0.7], 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    
    % Add value labels for dynamic clustering
    for m = 1:num_metrics
        offset_x = 8 * cos(angles(m) + 0.15);
        offset_y = 8 * sin(angles(m) + 0.15);
        text(x_dyn(m) + offset_x, y_dyn(m) + offset_y, sprintf('%.1f', data_dyn(m)), ...
             'FontSize', 9, 'FontWeight', 'bold', 'Color', colors_scenarios(s, :), ...
             'FontName', 'Arial');
    end
    
    % Title with scenario info
    title(sprintf('%s', scenarios{s}), ...
          'FontSize', 13, 'FontWeight', 'bold', 'FontName', 'Arial', ...
          'Color', colors_scenarios(s, :));
    
    % Add key metrics annotation box
    info_str = sprintf('SC_{dyn}=%.2f  VDI_{dyn}=%.3f\n\\DeltaP_{net}=%+d%%', ...
                       sc_dynamic(s), vdi_dynamic(s), net_load_scenario(s));
    text(65, 25, info_str, 'FontSize', 9, 'FontName', 'Arial', ...
         'BackgroundColor', [1 1 1 0.9], 'EdgeColor', colors_scenarios(s,:), ...
         'LineWidth', 1.2, 'Margin', 3);
    
    axis equal;
    axis([-5 135 -5 135]);
    axis off;
    
    % Add legend for first subplot only
    if s == 1
        legend_h1 = plot(nan, nan, 'o-', 'Color', colors_scenarios(s, :), ...
                         'MarkerFaceColor', colors_scenarios(s, :), 'LineWidth', 2, 'MarkerSize', 8);
        legend_h2 = plot(nan, nan, 's--', 'Color', [0.5 0.5 0.5], ...
                         'MarkerFaceColor', [0.7 0.7 0.7], 'LineWidth', 1.5, 'MarkerSize', 8);
        legend([legend_h1, legend_h2], {'Dynamic', 'Static'}, ...
               'Location', 'southeast', 'FontSize', 10, 'FontName', 'Arial');
    end
    
    hold off;
end

sgtitle('Quarter-Circle Radar: Dynamic vs Static Clustering Performance', ...
        'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');

%% ========================================================================
%% Part 3: Save Figure
%% ========================================================================

output_folder = 'Output_Figures';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

saveas(fig1, fullfile(output_folder, 'Radar_QuarterCircle_2x2.png'));
saveas(fig1, fullfile(output_folder, 'Radar_QuarterCircle_2x2.eps'), 'epsc');

fprintf('Generated: Radar_QuarterCircle_2x2\n');
fprintf('Output folder: %s\n', output_folder);

%% ========================================================================
%% Part 4: Print Summary Table
%% ========================================================================

fprintf('\n========== Performance Summary ==========\n');
fprintf('%-20s %8s %8s %8s %8s\n', 'Metric', 'S1', 'S2', 'S3', 'S4');
fprintf('------------------------------------------------------------\n');
fprintf('%-20s %8.2f %8.2f %8.2f %8.2f\n', 'SC (Dynamic)', sc_dynamic);
fprintf('%-20s %8.2f %8.2f %8.2f %8.2f\n', 'SC (Static)', sc_static);
fprintf('%-20s %8.3f %8.3f %8.3f %8.3f\n', 'VDI (Dynamic)', vdi_dynamic);
fprintf('%-20s %8.3f %8.3f %8.3f %8.3f\n', 'VDI (Static)', vdi_static);
fprintf('%-20s %8.1f %8.1f %8.1f %8.1f\n', 'VDI Impr. (%)', vdi_improvement);
fprintf('%-20s %8.1f %8.1f %8.1f %8.1f\n', 'TAPL Impr. (%)', tapl_improvement);
fprintf('%-20s %8d %8d %8d %8d\n', 'Net Load (%)', net_load_scenario);
fprintf('============================================================\n');
