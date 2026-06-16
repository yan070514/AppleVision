# Apple Vision CLI

让你的 Mac 终端拥有「视力」。基于 Apple Vision 框架，提供 15 个图像分析命令。

## 能干什么

| 你想... | 命令 |
|---------|------|
| 提取图片中的文字 | `apple-vision recognize-text --image 截图.png` |
| 找到照片里的人脸 | `apple-vision detect-faces --image 合影.jpg` |
| 扫描二维码 | `apple-vision detect-barcodes --image 码.png` |
| 分析人体动作 | `apple-vision detect-pose --image 瑜伽.jpg` |
| 判断图片内容 | `apple-vision classify --image 场景.jpg` |
| 比较两张图是否相似 | `apple-vision featureprint compare --image1 a.jpg --image2 b.jpg` |

## 安装

### 一键安装

```bash
# 1. 克隆
git clone https://github.com/yan070514/AppleVision.git && cd AppleVision

# 2. 编译
swift build -c release

# 3. 安装到系统（需要密码）
sudo ln -sf "$(pwd)/.build/release/AppleVisionCLI" /usr/local/bin/apple-vision
```

不想输密码？跳过第 3 步，改为：

```bash
echo 'alias apple-vision="'"$(pwd)"'/.build/release/AppleVisionCLI"' >> ~/.zshrc
source ~/.zshrc
```

### 前提

- macOS 14 或更新版本
- Xcode Command Line Tools（没有的话运行 `xcode-select --install`）

---

## 快速上手

```bash
# 识别截图里的中文
apple-vision recognize-text --image ~/Desktop/截图.png

# 照片里有几张脸
apple-vision detect-faces --image ~/Photos/合影.jpg

# 这是什么
apple-vision classify --image ~/Downloads/未知图片.jpg

# 扫个码
apple-vision detect-barcodes --image qrcode.png
```

---

## 搭配 Claude Code 使用

安装 Skill 后，Claude 会自动判断该调用哪个命令：

```bash
cp Skills/apple-vision.md ~/.claude/skills/
```

重启 Claude Code，然后直接对它说「帮我看看这张图里有什么文字」。

---

## 全部命令

| 命令 | 做什么 | 常用参数 |
|------|--------|---------|
| `recognize-text` | 识别文字 | `--lang zh-Hans`, `--level fast` |
| `detect-faces` | 找人脸位置 | `--confidence 0.5` |
| `detect-landmarks` | 五官定位（76个点） | `--confidence 0.5` |
| `detect-barcodes` | 扫二维码/条码 | — |
| `detect-pose` | 人体骨骼（19个关节） | `--joints all` |
| `detect-hand` | 手部骨骼（21个点） | `--max-hands 2` |
| `detect-humans` | 快速找人 | `--confidence 0.5` |
| `detect-animals` | 猫/狗骨骼 | — |
| `classify` | 图片分类标签 | `--max-results 5` |
| `featureprint generate` | 生成图片指纹 | `--output a.fp` |
| `featureprint compare` | 两张图相似度 | `--image1 a.jpg --image2 b.jpg` |
| `detect-contours` | 找物体轮廓 | — |
| `saliency` | 视觉焦点区域 | `--type attention` |
| `optical-flow` | 两帧间运动 | `--from f1.jpg --to f2.jpg` |
| `detect-trajectories` | 物体运动轨迹 | `--frames ./dir/` |

所有命令输出 JSON 格式，坐标均为像素绝对值。加 `--help` 查看详细参数。

---

## 技术

基于 [Apple Vision](https://developer.apple.com/documentation/vision) 框架，Swift 编写，本地运行不上传任何数据。
