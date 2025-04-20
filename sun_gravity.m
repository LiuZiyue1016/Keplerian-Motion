function dydt = sun_gravity(t, x)
    mu_sun = 1.32712440017987e11; % 太阳引力常数 (km³/s²)
    % 定义引力作用下的运动方程
    r = x(1:3);
    v = x(4:6);
    
    R = sqrt(x(1)^2+x(2)^2+x(3)^2);
    dr = v;
    dv = -mu_sun * r / (R^3);
    
    dydt = [dr;dv];
end