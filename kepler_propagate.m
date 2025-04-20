function [r, v] = kepler_propagate(r0, v0, t1, mu, dt)
    % 初始化状态向量
    x = [r0(:); v0(:)];
    
    % 生成时间向量，确保包含t1
    t = 0:dt:t1;
    if t(end) < t1
        t = [t, t1];  % 强制包含t1
    end
    n_time = length(t);
    
    % 初始化解矩阵
    X = zeros(6, n_time);
    X(:, 1) = x;
    
    for j = 1:n_time-1
        % 当前状态
        r = X(1:3, j);
        v = X(4:6, j);
        
        % 计算轨道根数
        [a, e, i, Omega, omega, theta0] = rv2coe(r, v, mu);
        
        % 检查轨道类型
        if e >= 1
            error('仅支持椭圆轨道，e必须小于1');
        end
        
        % 计算平均角速度
        n = sqrt(mu / a^3);
        
        % 计算平近点角
        E0 = 2 * atan(sqrt((1 - e)/(1 + e)) * tan(theta0 / 2));
        M0 = E0 - e * sin(E0);
        
        % 计算下一个时间点的平近点角
        if j == n_time - 1
            % 最后一个时间点，使用剩余时间增量
            dt_step = t(j+1) - t(j);
        else
            dt_step = dt;
        end
        
        M = M0 + n * dt_step;
        
        % 牛顿迭代求解偏近点角E
        E = solve_kepler(M, e, 1e-10);
        
        % 计算真近点角
        theta = 2 * atan(sqrt((1 + e)/(1 - e)) * tan(E / 2));
        
        % 轨道根数到位置速度转换
        [r_new, v_new] = coe2rv(a, e, i, Omega, omega, theta, mu);
        
        % 更新状态
        X(:, j+1) = [r_new; v_new];
    end
    
    % 提取最终位置和速度
    r = X(1:3, :);
    v = X(4:6, :);
end