% 读取并归一化散斑图像
img = imread('ke.bmp');
img = double(img);
img = img / max(img(:)); % 归一化到 [0,1]

% 计算均值和标准差
mean_img = mean(img(:));
std_img = std(img(:));

% 归一化图像（零均值、单位标准差）
normalized_img = (img - mean_img) / std_img;

% 计算整个图像的自相关函数（归一化互相关）
r_corr = xcorr2(normalized_img); % 计算2D自相关函数

% 归一化自相关矩阵（缩放到 [0,1]）
r_corr_normalized = (r_corr - min(r_corr(:))) / (max(r_corr(:)) - min(r_corr(:)));

% 提取中心行剖面
[rows, cols] = size(r_corr_normalized);
center_x = floor(cols / 2) + 1; % 中心 x 位置
center_y = floor(rows / 2) + 1; % 中心 y 位置

profile_x = r_corr_normalized(center_y, :); % 提取中心行
x_range = -floor(cols / 2):floor(cols / 2); % x 轴范围（位移量）




% 显示自相关结果
figure;
subplot(1,2,1);
imagesc(r_corr_normalized);
% colorbar;
% title('整幅图像的自相关函数');
xlabel('X (pixel)','FontSize',24);
ylabel('Y (pixel)','FontSize',24);
set(gca,'FontSize',20);
colormap jet;

% 绘制中心行剖面
subplot(1,2,2);
plot(x_range, profile_x, 'b', 'LineWidth', 1.5);
% title('自相关中心行剖面');
xlabel('X (pixel)','FontSize',24);
xlim([-800,800]);
ylim([0,1.1]);
set(gca,'FontSize',20)
grid on;

% 计算 PBR（峰背比）
signal = profile_x(center_x); % 主峰值（中心）
noise_region = [1:center_x-10, center_x+10]; % 去除主峰±20像素的噪声区域
noise_std = std(profile_x(noise_region)); % 噪声标准差
SNR = signal / noise_std;

% 显示 SNR
fprintf('图像自相关的峰背比 PBR = %.2f\n', SNR);


