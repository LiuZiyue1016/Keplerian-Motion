function measure_deflection(r_rel, v_rel, mars_pos, mars_vel)
    % 偏转效果评估指标
    x = mars_pos/norm(mars_pos);
    v_in = v_rel(:,1);
    v_out = v_rel(:,end);
    v_in_sun = v_in + mars_vel;
    v_out_sun = v_out + mars_vel;
    
    v_in_norm = norm(v_in);
    v_out_norm = norm(v_out);
    if abs(v_in_norm - v_out_norm) > 1e-3
        warning('相对速度模差异较大：v_in=%.3f, v_out=%.3f', v_in_norm, v_out_norm);
    end

    fprintf('\n探测器飞入火星影响球时轨道状态为（通过双曲线kepler轨道递推）:\n');
    fprintf('位置: [%f %f %f] km\n', r_rel(1, 1), r_rel(2, 1), r_rel(3, 1));
    fprintf('半径: %f km\n', norm(r_rel(:, 1)));
    fprintf('速度矢量: [%f %f %f] km/s\n', v_in(1), v_in(2), v_in(3))
    fprintf('速度: %f km/s\n', v_in_norm)

    
    fprintf('\n探测器飞出火星影响球时轨道状态为（通过双曲线kepler轨道递推）:\n');
    fprintf('位置: [%f %f %f] km\n', r_rel(1, end), r_rel(2, end), r_rel(3, end));
    fprintf('半径: %f km\n', norm(r_rel(:, end)));
    fprintf('速度矢量: [%f %f %f] km/s\n', v_out(1), v_out(2), v_out(3))
    fprintf('速度: %f km/s\n', v_out_norm)

    v_inf = v_in_norm; % 直接使用进入速度模
    
    % 近心点计算
    [~, idx] = min(vecnorm(r_rel,2,1));
    mars_radius = 3389.2;
    r_p = r_rel(:,idx);
    
    delta_v = norm(v_out_sun - v_in_sun);
    deflection_angle = 2 * asind(delta_v/(2*v_inf)); % 修正后的偏转角
    psi = acosd(dot(r_p, x)/(norm(r_p)));
    
    % 角动量与能量变化
    h_in = cross(r_rel(:,1) + mars_pos, v_in_sun);
    h_out = cross(r_rel(:,end) + mars_pos, v_out_sun);
    delta_h = norm(h_out - h_in);
    delta_E = -2 * v_inf * norm(mars_vel) * sind(deflection_angle/2) * sind(psi);
    
    % 输出评估结果
    fprintf('\n火星引力偏转效果:\n');
    fprintf(['近地点半径: %f km\n借力飞行高度: %f km\n角动量变化: %f km^2/s\n速度增量: %f km/s\n' ...
        '偏转角: %f°\n轨道能量变化: %f km²/s²\n'],...
            norm(r_p), norm(r_p) - mars_radius, delta_h, delta_v, deflection_angle, delta_E);
    %% 绘制双曲线（标准方程：x^2/a^2 - y^2/b^2 = 1）
    a = 3;      % 双曲线实半轴长度（自定义）
    b = 4;      % 双曲线虚半轴长度（自定义）
    c = sqrt(a^2 + b^2); % 焦点距离原点距离（自动计算）
    y = linspace(-10, 10, 1000); % y轴范围可调整
    x_right = a * sqrt(1 + y.^2 / b^2); % 右分支
    
    figure;
    hold on;
    plot(x_right, y, 'b', 'LineWidth', 1.5); % 绘制右分支
    
    % 绘制渐近线（y = ±(b/a)x）
    x_asym = linspace(0, 10, 100);
    y_asym_upper = (b/a) * x_asym;
    y_asym_lower = -(b/a) * x_asym;
    plot(x_asym, y_asym_upper, '--k', 'LineWidth', 1);
    plot(x_asym, y_asym_lower, '--k', 'LineWidth', 1);
    
    % 标注火星
    scatter(c, 0, 'ro', 'filled'); % 焦点位置
    text(c+0.2, 0.2, '火星', 'FontSize', 12); 

    % 标注近地点
    scatter3(a, 0,200,'pentagram',...
    'MarkerFaceColor','y','MarkerEdgeColor','k');
    
    % 近地点半径计算（顶点到焦点的距离）
    quiver(c, 0, -4, 0, 0.5, 'r', 'LineWidth', 1.2, 'MaxHeadSize', 1.2);
    text(c-a+2.4, a+0.18, sprintf('r_{p}=%.2f km', norm(r_p)), 'FontSize', 12);
    
    % 绘制速度矢量（以右分支为例）
    % 选取两个点作为速度矢量起点（用户可调整位置）
    t1 = 1.8; % 参数化方程中的参数（
    x1_points = a * cosh(t1); 
    y1_points = b * sinh(t1);
    
    % 计算速度方向导数（dx/dt, dy/dt）
    dx1 = a * sinh(t1); % 参数方程导数dx/dt
    dy1 = b * cosh(t1); % 参数方程导数dy/dt
    
    % 绘制箭头
    quiver(x1_points, y1_points, -dx1, -dy1, 0.3, 'r', 'LineWidth', 1.2, 'MaxHeadSize', 1.2);
    text(x1_points+1.2, y1_points, sprintf('v_{\\infty}^{-}=%.3f km/s', v_in_norm), 'FontSize', 12);
    
    t2 = -1.5; % 参数化方程中的参数（
    x2_points = a * cosh(t2); 
    y2_points = b * sinh(t2);
    
    % 计算速度方向导数（dx/dt, dy/dt）
    dx2 = a * sinh(t2); % 参数方程导数dx/dt
    dy2 = b * cosh(t2); % 参数方程导数dy/dt
    
    % 绘制箭头（缩放速度矢量长度）
    quiver(x2_points, y2_points, -dx2, -dy2, 0.3, 'r', 'LineWidth', 1.2, 'MaxHeadSize', 1.2);
    text(x2_points+1, y2_points+2, sprintf('v_{\\infty}^{+}=%.3f km/s', v_out_norm), 'FontSize', 12);

    % 找到双曲线右分支的最远端点（x最大的点）
    [~, idx] = max(x_right);
    farthest_point = [x_right(idx), y(idx)];
    
    % 计算SOI圆的半径（最远端点到焦点的距离）
    soi_radius = norm(farthest_point - [c, 0]);
    
    % 绘制SOI圆（以焦点为圆心，最远端点到焦点的距离为半径）
    theta = linspace(0, 2*pi, 100);
    soi_x = c + soi_radius * cos(theta);
    soi_y = 0 + soi_radius * sin(theta);
    plot(soi_x, soi_y, 'g--', 'LineWidth', 1.2);
    
    % 标注SOI
    text(c + soi_radius/2, soi_radius/2, 'SOI', 'FontSize', 12, 'Color', 'g');
    axis off;
end