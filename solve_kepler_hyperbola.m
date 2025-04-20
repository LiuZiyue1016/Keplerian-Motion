function F = solve_kepler_hyperbola(M, e, tol)
    % 使用牛顿迭代法求解双曲线轨道的偏近点角 F
    % 初始猜测
    F0 = M;
    F = F0;
    err = 1;
    
    while err > tol
        % 计算函数值和导数
        f = e * sinh(F) - F - M;
        f_prime = e * cosh(F) - 1;
        
        % 更新 F
        F1 = F - f / f_prime;
        err = abs(F1 - F);
        F = F1;
    end
end