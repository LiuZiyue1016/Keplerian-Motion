function plot_solar_system(r_data, r0, mars_position, mars_orbit, earth_pos, earth_orbit)
    %% 天体参数设定
    R_sun = 696300; % 太阳半径(公里)[5](@ref)
    scale_factor = 35; % 太阳显示尺寸缩放因子
    %% 可视化设置
    figure();
    hold on;
    axis equal;
    grid on;
    xlabel('X (km)');
    ylabel('Y (km)');
    zlabel('Z (km)');
    view(3);
    
    %% 绘制太阳
    [X,Y,Z] = sphere(20);
    surf(X*R_sun*scale_factor, Y*R_sun*scale_factor, Z*R_sun*scale_factor, ...
        'FaceAlpha', 0.5, 'DisplayName', '太阳(放大35倍)');
    
    %% 绘制行星轨道
    % 地球轨道(蓝色)[3](@ref)
    plot3(earth_orbit(1, :), earth_orbit(2, :), earth_orbit(3, :),...
        'Color', [0 0.5 1], 'LineWidth', 1.5, 'DisplayName', '地球轨道');
    
    % 火星轨道(红色)[2,5](@ref)
    plot3(mars_orbit(1, :), mars_orbit(2, :), mars_orbit(3, :),...
        'Color', [1 0.2 0], 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', '火星轨道');
    
    %% 绘制探测器轨迹
    % 探测器轨道(紫色)
    plot3(r_data(1, :), r_data(2, :), r_data(3, :),...
        'Color', [0.5 0 1], 'LineWidth', 2, 'DisplayName', '探测器轨道');
    
    % 探测器起点(星形标记)
    scatter3(r0(1), r0(2), r0(3), 100, 'pentagram',...
        'MarkerEdgeColor','k', 'MarkerFaceColor',[0.7 0 1], 'DisplayName','探测器起点');
    
    %% 添加当前时刻天体位置
    % 地球当前位置(蓝色圆点)
    scatter3(earth_pos(1), earth_pos(2), earth_pos(3), 40, 'filled',...
        'MarkerFaceColor', [0 0.5 1], 'DisplayName','地球位置');
    
    % 火星当前位置(红色圆点)[5](@ref)
    mars_pos = mars_position;
    scatter3(mars_pos(1), mars_pos(2), mars_pos(3), 40, 'filled',...
        'MarkerFaceColor', [1 0.2 0], 'DisplayName','火星位置');
    
    %% 辅助设置
    legend('Location', 'best');
    % set(gca, 'Color', [0.1 0.1 0.1]); % 深色背景
    set(gcf, 'Position', [100 100 1200 800]);
    hold off;
end