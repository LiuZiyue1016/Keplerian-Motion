clear; clc;
%% 初始化参数
mu_sun = 1.32712440017987e11; % 太阳引力常数 (km³/s²)
mu_mars = 4.28283762065e4;     % 火星引力常数 (km³/s²)
r0 = 1e8 * [-0.370264003660595; 
            1.315142470848916; 
            0.608322679422336]; % 初始位置 (km)
v0 = [-31.806213625480979; 
      -6.234823833392683; 
      -0.078190790328369];    % 初始速度 (km/s)
mars_pos = 1e8 * [0.598177297152914; 
                -1.853298132110158; 
                -0.866200961703781]; % 火星位置 (km)
mars_vel = [24.165448742900686; 
          8.313187618593524; 
          3.161448109961551];   % 火星速度 (km/s)
earth_pos = 1e8 * [0.110937729685236; 
                    1.346867468212425; 
                    0.583831802330196];
earth_vel = [-30.200703848645549; 
            1.956654058695767; 
            0.847099469360955];
% 时间参数
t1 = 279.1317802839208 * 86400;  % 到火星影响球时间 (秒)
t2 = 3.83447851834784 * 86400;   % 火星影响球内飞行时间 (秒)
t3 = 500 * 86400;                % 后续500天飞行时间 (秒)
T_mars = 686.98*84600;
T_earth = 365.256*86400;
dt = 100;
%% 任务1：Kepler方法递推从起点到火星引力影响球的探测器轨道
[r_kep, v_kep] = kepler_propagate(r0, v0, t1, mu_sun, dt);
fprintf('Kepler方法计算探测器到达火星影响球时日心轨道状态为:\n');
fprintf('日心位置: [%f %f %f] km\n', r_kep(1, end), r_kep(2, end), r_kep(3, end));
fprintf('日心速度: [%f %f %f] km/s\n', v_kep(1, end), v_kep(2, end), v_kep(3, end));
%% 任务2：数值积分递推从起点到火星引力影响球的探测器轨道
tspan1 = [0, t1];
y0 = [r0; v0];
options = odeset('RelTol', 1e-12, 'AbsTol', 1e-12);
[t_integral, y_integral] = ode45(@sun_gravity, tspan1, y0, options);
r_integral = y_integral(:, 1:3)';
v_integral = y_integral(:, 4:6)';
fprintf('\n数值积分方法计算探测器到达火星影响球时日心轨道状态为:\n');
fprintf('日心位置: [%f %f %f] km\n', r_integral(1, end), r_integral(2, end), r_integral(3, end));
fprintf('日心速度: [%f %f %f] km/s\n', v_integral(1, end), v_integral(2, end), v_integral(3, end));
% 比较前两种任务的递推效果，以数值积分为基准
compare_kep_integral(r_kep, r_integral, v_kep, v_integral);
%% 任务3：在火星影响球内的探测器轨道（双曲线kepler轨道递推）
r_in = r_kep(:, end) - mars_pos;  % 转换为火心坐标系
v_in = v_kep(:, end) - mars_vel;
tspan2 = [0, t2];
y0_mars = [r_in; v_in];
% [t_rel, y_rel] = ode45(@mars_gravity, tspan2, y0_mars, options);
[r_rel, v_rel, orbit_plane, distance, energy, ...
    angular_momentum] = hyperbolic_kepler_propagate(r_in, v_in, t2, mu_mars, mu_sun, dt, mars_pos, mars_vel);
% 绘制火心飞行轨道
plot_mars_orbit(r_rel, orbit_plane, distance, energy, angular_momentum)
% 衡量借力飞行偏转效果
measure_deflection(r_rel, v_rel, mars_pos, mars_vel)
%% 任务4：Kepler递推500天生成从火星引力影响球飞出后的探测器轨道
r_rel_sun = r_rel + mars_pos;  % 转回日心坐标系
v_rel_sun = v_rel + mars_vel;
r_out = r_rel_sun(:, end);
v_out = v_rel_sun(:, end);
[r_final, v_final] = kepler_propagate(r_out, v_out, t3, mu_sun, dt);
fprintf('\nkepler方法计算探测器飞出火星引力影响球500天后的日心轨道状态\n')
fprintf('日心位置: [%f %f %f] km\n', r_final(1, end), r_final(2, end), r_final(3, end));
fprintf('日心速度: [%f %f %f] km/s\n', v_final(1, end), v_final(2, end), v_final(3, end))
%% 生成火星轨道
mars_tapan = [0, T_mars];
mars0 = [mars_pos; mars_vel]; 
[t_mars, y_mars] = ode45(@sun_gravity, mars_tapan, mars0, options);
r_mars = y_mars(:, 1:3)'; % 火星轨道

earth_tspan = [0, T_earth];
earth0 = [earth_pos; earth_vel]; 
[t_earth, y_earth] = ode45(@sun_gravity, earth_tspan, earth0, options);
r_earth = y_earth(:, 1:3)'; % 地球轨道

% 绘制日心飞行轨道
r = [r_kep, r_rel_sun, r_final];
plot_solar_system(r, r0, mars_pos, r_mars, earth_pos, r_earth);