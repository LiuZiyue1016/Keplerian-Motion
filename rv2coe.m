function [a, e, i, Omega, w, phi] = rv2coe(R, V, miu)
    Z = [0; 0; 1];  % 定义惯性坐标系的Z轴
    X = [1; 0; 0];  % 定义惯性坐标系的X轴
    Y = [0; 1; 0];  % 定义惯性坐标系的Y轴

    r = norm(R);
    H = cross(R, V);
    h = norm(H);
    N = cross(Z, H);
    n = norm(N);

    tmp = 2 / r - dot(V, V) / miu;
    if tmp == 0  % 抛物线轨道
        a = Inf;
    else
        a = 1 / tmp;
    end

    E = ((dot(V, V) - miu / r) * R - dot(R, V) * V) / miu;
    e = norm(E);

    i = acos(dot(Z, H) / h);  % 直接计算弧度值

    if e < 1e-7
        w = 0;  % 圆轨道无近地点角距
    else
        w = acosd(dot(N, E) / (n * e));
        if dot(Z, E) < 0
            w = 360 - w;
        end
        w = deg2rad(w);
    end

    Omega = acosd(dot(N, X) / n);
    if dot(N, Y) < 0
        Omega = 360 - Omega;
    end
    Omega = deg2rad(Omega);

    phi = 0;  % 默认值
    if e > 1e-7
        phi = acosd(dot(E, R) / (e * r));
        if dot(R, V) < 0
            phi = 360 - phi;
        end
        phi = deg2rad(phi);
    end
end