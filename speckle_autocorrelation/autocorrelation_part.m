% 读取散斑图像
img = imread('1500.bmp');
img = double(img); % 转换为 double 类型
img = img / max(img(:)); % 归一化图像（强度范围 [0, 1]）

% 计算图像的均值和标准差
mean_img = mean(img(:));
std_img = std(img(:));

% 归一化图像
normalized_img = (img - mean_img) / std_img;

% 设置位移范围
Delta_max = 10; % 最大位移量（以像素为单位）
r_corr = zeros(2*Delta_max+1, 2*Delta_max+1); % 存储相关系数

% 计算归一化相关系数
for dx = -Delta_max:Delta_max
    for dy = -Delta_max:Delta_max
        % 计算位移后的相关系数
        shifted_img = circshift(normalized_img, [dx, dy]);
        
        % 计算相关系数（使用内积）
        corr_value = sum(sum(normalized_img .* shifted_img)); % 内积
        r_corr(dx + Delta_max + 1, dy + Delta_max + 1) = corr_value;
    end
end

% 对相关系数进行归一化
r_corr_normalized = (r_corr - min(r_corr(:))) / (max(r_corr(:)) - min(r_corr(:)));

% 绘制归一化相关系数图像
figure;
subplot(1,2,1);
imagesc(r_corr_normalized);
colorbar off;
% title('归一化相关系数');
% xlabel('X/pixel', 'FontSize', 20);
% ylabel('Y/pixel', 'FontSize', 20);
set(gca,'FontSize', 20);
colormap jet;

% 提取中心位置剖面
center_x = Delta_max + 1; % 中心位置的 x 坐标

% 中心行剖面（沿 x 方向）
profile_x = r_corr_normalized(:, center_x);

% 绘制中心行剖面
subplot(1,2,2);
plot(-Delta_max:Delta_max, profile_x, 'b', 'LineWidth', 2);
% title('中心行剖面');
% xlabel('X/pixel', 'FontSize', 20);
% ylabel('归一化相关系数', 'FontSize', 20);
set(gca,'FontSize', 20);
ylim([0,1.1]);


% --- 计算自相关的峰背比 PBR ---

% 主峰值（中心点）
peak_value = r_corr_normalized(Delta_max + 1, Delta_max + 1);

% 创建 mask 排除主峰周围的区域（避免干扰背景统计）
mask = true(size(r_corr_normalized));
exclude_radius = 10; % 可调：5:排除中心 11x11 区域 ；10:排除中心中心21x21区域
mask(Delta_max+1-exclude_radius:Delta_max+1+exclude_radius, ...
     Delta_max+1-exclude_radius:Delta_max+1+exclude_radius) = false;

% 背景区域数据
background_values = r_corr_normalized(mask);

% 背景标准差
sigma_background = std(background_values(:));

% 自相关 SNR
snr_autocorr = peak_value / sigma_background;

% 打印 SNR 结果
fprintf('图像自相关的峰背比 PBR= %.2f\n', snr_autocorr);
