function E = solve_kepler(M, e, tol)
    % 设置E的初始估计值
    if M < pi
        E = M+e/2;
    else
        E = M-e/2;
    end
    delta = 1;
    % 牛顿迭代,直到确定E在所要求的范围内
    while abs(delta) > tol
        delta = (E - e*sin(E) - M) / (1 - e*cos(E));
        E = E - delta;
    end
end