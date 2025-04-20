function compare_kep_integral(r_kep, r_integral, v_kep, v_integral)
    pos_diff = r_kep(:, end) - r_integral(:, end);  % 位置差异矩阵
    vel_diff = v_kep(:, end) - v_integral(:, end);  % 速度差异矩阵
    
    fprintf('\n两种方法计算的到达火星影响球时日心轨道状态偏差为:\n');
    fprintf('位置偏差: [%f %f %f] km\n', pos_diff(1), pos_diff(2), pos_diff(3));
    fprintf('速度偏差 [%f %f %f] km/s\n', vel_diff(1), vel_diff(2), vel_diff(3))
end