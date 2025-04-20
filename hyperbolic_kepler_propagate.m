function [r, v, orbit_plane, distance, energy, ...
    angular_momentum] = hyperbolic_kepler_propagate(r0, v0, t1, mu_mars, mu_sun, dt, mars_pos, mars_vel)
    % 初始化状态向量 [位置; 速度]
    x = [r0(:); v0(:)];  % 确保为列向量
    
    % 创建时间向量
    t = 0:dt:t1;
    if t(end) < t1
        t = [t, t1];  % 强制包含t1
    end
    n_time = length(t);  % 时间点数量
    
    % 初始化解矩阵
    X = zeros(6, n_time);  % 6个状态变量（3位置 + 3速度）
    X(:, 1) = x;
    
    % 初始化轨道平面坐标矩阵
    orbit_plane = zeros(2, n_time);  % 2个变量（x_orbit, y_orbit）
    
    % 初始化额外的存储矩阵
    distance = zeros(1, n_time);  % 距离火星的距离
    energy = zeros(1, n_time);    % 能量
    angular_momentum = zeros(1, n_time);  % 角动量
    
    % 计算初始位置与火星的距离
    distance(1) = norm(r0);
    
    % 计算初始角动量
    angular_momentum(1) = norm(cross(r0 + mars_pos, v0 + mars_vel));
    
    for j = 1:n_time-1
        % 当前状态
        r = X(1:3, j);
        v = X(4:6, j);
        
        % 计算轨道根数
        [a, e, i, Omega, omega, theta0] = rv2coe(r, v, mu_mars);
            
        % 检查是否为双曲线轨道
        if a > 0
            error('该轨道不是双曲线轨道');
        end
        
        % 计算平均角速度（双曲线轨道使用双曲函数）
        n = sqrt(mu_mars / (-a)^3);  % 平均角速度
        
        % 计算偏近点角 F0
        F0 = 2 * atanh(sqrt((e - 1) / (e + 1)) * tan(theta0 / 2));  % 从θ₀计算F₀
        
        % 计算平近点角 M
        M0 = e * sinh(F0) - F0;  % 双曲线轨道的平近点角

        % 计算下一个时间点的平近点角
        if j == n_time - 1
            % 最后一个时间点，使用剩余时间增量
            dt_step = t(j+1) - t(j);
        else
            dt_step = dt;
        end

        M = M0 + n * dt_step;  % 下一个时间点的平近点角
        
        % 牛顿迭代方程
        F = solve_kepler_hyperbola(M, e, 1e-10);
        
        % 计算真近点角
        theta = 2 * atan(sqrt((e + 1) / (e - 1)) * tanh(F / 2));
        
        % 轨道根数到位置速度转换
        [r_new, v_new] = coe2rv(a, e, i, Omega, omega, theta, mu_mars);

        % 计算轨道平面坐标
        if j == n_time-1
            x_orbit = a * (e - cosh(F));
            y_orbit = a * sqrt(e^2 - 1) * sinh(F);
            orbit_plane(1, j+1) = x_orbit;
            orbit_plane(2, j+1) = y_orbit;
        end

        x_orbit = a * (e - cosh(F0));
        y_orbit = a * sqrt(e^2 - 1) * sinh(F0);
        orbit_plane(1, j) = x_orbit;
        orbit_plane(2, j) = y_orbit;
        
        % 更新状态
        X(:, j+1) = [r_new; v_new];
        
        % 计算探测器与火星的距离
        distance(j+1) = norm(r_new);
        
        % 计算能量
        v_new_norm = norm(v_new + mars_vel);
        r_new_norm = norm(r_new + mars_pos);
        energy(j+1) = (v_new_norm^2)/2 - mu_sun/r_new_norm;
        
        % 计算角动量
        angular_momentum(j+1) = norm(cross(r_new + mars_pos, v_new + mars_vel));
    end
    
    % 提取最终位置和速度
    r = X(1:3, :);
    v = X(4:6, :);
end