function plot_mars_orbit(r_rel, orbit_plane, distance, energy, angular_momentum)
    % 参数设置
    % 真实比例参数
    mars_radius = 3389.2;       % 火星实际平均半径 (km)
    rate = 25;
    %% 绘制轨道平面
    figure;
    plot(orbit_plane(1, :), orbit_plane(2, :));
    xlabel('X (km)', 'FontSize', 12);
    ylabel('Y (km)', 'FontSize', 12);
    legend("探测器轨道");
    grid on;
    %% 绘制轨道参数变化
    % 绘制距离随时间变化
    figure;
    subplot(3, 1, 1);
    plot(distance, 'b');
    title('探测器与火星的距离');
    xlabel('时间步');
    ylabel('距离 (km)');
    % 绘制能量随时间变化
    subplot(3, 1, 2);
    plot(energy, 'r');
    title('探测器的能量');
    ylim([-400, -300]);
    xlabel('时间步');
    ylabel('能量 (km^{2}/s)');
    % 绘制角动量随时间变化
    subplot(3, 1, 3);
    plot(angular_momentum, 'g');
    title('探测器的角动量');
    xlabel('时间步');
    ylabel('角动量 (km²/s)');
    %% 绘制局部放大图
    figure;
    
    % 绘制探测器轨道
    plot3(r_rel(1, :), r_rel(2, :), r_rel(3, :), 'b-', 'LineWidth', 1.5, 'DisplayName', '探测器轨道');
    hold on;
    
    % 绘制火星球体
    [X, Y, Z] = sphere(50); % 球面网格精度
    X = X * mars_radius * rate; 
    Y = Y * mars_radius * rate;
    Z = Z * mars_radius * rate;
    
    % 渲染火星表面
    surf(X, Y, Z, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'DisplayName', '火星');
    
    % 图幅优化
    axis equal;
    xlabel('X (km)', 'FontSize', 12);
    ylabel('Y (km)', 'FontSize', 12);
    zlabel('Z (km)', 'FontSize', 12);
    legend(["探测器轨道", "火星（放大25倍）"], "Position", [0.6708 0.7565 0.2429, 0.0774]);
    grid on;
    rotate3d on; % 启用三维旋转查看
    %% 绘制局部放大图
    figure;
    
    % 计算距离并筛选接近火星的点
    distance = vecnorm(r_rel, 2, 1);
    near_indices = find(distance < 1.5e4);
    x = r_rel(1, near_indices);
    y = r_rel(2, near_indices);
    z = r_rel(3, near_indices);
    
    % 绘制探测器轨道
    plot3(x, y, z, 'b-', 'LineWidth', 1.5, 'DisplayName', '探测器轨道');
    hold on;
    
    % 绘制火星球体
    [X, Y, Z] = sphere(50); % 球面网格精度
    X = X * mars_radius; 
    Y = Y * mars_radius;
    Z = Z * mars_radius;
    
    % 渲染火星表面
    surf(X, Y, Z, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'DisplayName', '火星');
    
    % 图幅优化
    axis equal;
    xlabel('X (km)', 'FontSize', 12);
    ylabel('Y (km)', 'FontSize', 12);
    zlabel('Z (km)', 'FontSize', 12);
    legend(["探测器轨道", "火星"], "Position", [0.6708 0.7565 0.2429, 0.0774]);
    grid on;
    rotate3d on; % 启用三维旋转查看
end