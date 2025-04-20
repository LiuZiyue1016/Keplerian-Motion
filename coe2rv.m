function [r, v] = coe2rv(a, e, i, Omega, omega, theta, mu)
    % 将轨道根数转换为位置和速度向量（支持椭圆和双曲线轨道）
    % 输入：
    %   a: 半长轴
    %   e: 偏心率
    %   i: 倾角（弧度）
    %   Omega: 升交点赤经（弧度）
    %   omega: 近地点角距（弧度）
    %   theta: 真近点角（弧度）
    %   mu: 引力参数
    % 输出：
    %   r: 位置向量
    %   v: 速度向量

    % 检查轨道类型
    if a > 0
        if e >= 1
            error('对于椭圆轨道，偏心率 e 必须小于 1');
        end
        % 椭圆轨道逻辑
        p = a * (1 - e^2);  % 半参数
        r_mag = p / (1 + e * cos(theta));  % 径向距离
        v_mag = sqrt(mu / p);  % 速度大小
        
        % 位置向量（极坐标到笛卡尔坐标）
        r_perifocal = [r_mag * cos(theta);
                       r_mag * sin(theta);
                       0];
        
        % 速度向量
        if e == 0
            v_perifocal = [-sin(theta);
                           cos(theta);
                           0] * v_mag;
        else
            v_perifocal = [-v_mag * sin(theta);
                           v_mag * (e + cos(theta));
                           0];
        end
    elseif a < 0
        if e <= 1
            error('对于双曲线轨道，偏心率 e 必须大于 1');
        end
        % 双曲线轨道逻辑
        p = a * (1 - e^2);  % 半参数
        
        % 确保分母不为零或负值
        denominator = 1 + e * cos(theta);
        if denominator <= 0
            error('分母 1 + e*cos(theta) 为零或负值，无法计算径向距离 r');
        end
        
        % 径向距离
        r_mag = p / denominator;
        
        % 位置向量（极坐标到笛卡尔坐标）
        r_perifocal = [r_mag * cos(theta);
                       r_mag * sin(theta);
                       0];
        
        % 速度向量
        v_mag = sqrt(mu / p);
        v_perifocal = v_mag * [-sin(theta);
                               e + cos(theta);
                               0];
    else
        error('半长轴 a 不能为零');
    end
    
    % 构造旋转矩阵，将轨道平面坐标转换为惯性坐标
    R3_Omega = [cos(Omega), -sin(Omega), 0;
                sin(Omega), cos(Omega), 0;
                0, 0, 1];
    
    R1_i = [1, 0, 0;
            0, cos(i), -sin(i);
            0, sin(i), cos(i)];
    
    R3_omega = [cos(omega), -sin(omega), 0;
                sin(omega), cos(omega), 0;
                0, 0, 1];
    
    % 总旋转矩阵
    R = R3_Omega * R1_i * R3_omega;
    
    % 转换位置和速度到惯性坐标
    r = R * r_perifocal;
    v = R * v_perifocal;
end