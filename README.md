# Apple Vision CLI

15 个计算机视觉 CLI 工具，封装 Apple Vision 框架。配合 Claude Code 使用，让 AI 能"看懂"图片中的文字、人脸、姿态、条码、物体等。

## 前提条件

- **macOS 14+**
- **Xcode 15+**（或 Command Line Tools：`xcode-select --install`）

## 安装

### 方式一：源码编译（推荐）

```bash
git clone https://github.com/你的用户名/AppleVision.git
cd AppleVision
swift build -c release
sudo ln -sf "$(pwd)/.build/release/AppleVisionCLI" /usr/local/bin/apple-vision
```

### 方式二：无需 sudo

```bash
git clone https://github.com/你的用户名/AppleVision.git
cd AppleVision
swift build -c release
echo 'export PATH="$PATH:'"$(pwd)"'/.build/release"' >> ~/.zshrc
echo 'alias apple-vision=AppleVisionCLI' >> ~/.zshrc
source ~/.zshrc
```

### 方式三：预编译二进制（给同事分发）

```bash
# 从 GitHub Releases 下载 apple-vision.zip
unzip apple-vision.zip
sudo ln -sf "$(pwd)/AppleVisionCLI" /usr/local/bin/apple-vision
```

---

## 注册 Claude Code Skill

让 Claude 更精准地理解何时调用哪个命令：

```bash
cp Skills/apple-vision.md ~/.claude/skills/
```

重启 Claude Code 即可生效。

---

## 使用

```bash
apple-vision recognize-text --image photo.jpg --lang zh-Hans
apple-vision detect-faces --image selfie.png
apple-vision detect-barcodes --image qrcode.png
apple-vision detect-pose --image yoga.jpg
apple-vision classify --image scene.jpg
apple-vision featureprint compare --image1 a.jpg --image2 b.jpg
```

## 全部命令

| 命令 | 功能 | 示例 |
|------|------|------|
| `recognize-text` | OCR 文字识别 | `--lang zh-Hans --level fast` |
| `detect-faces` | 人脸检测 | `--confidence 0.5` |
| `detect-landmarks` | 五官关键点（76个） | `--confidence 0.5` |
| `detect-barcodes` | 条码/二维码解码 | — |
| `detect-pose` | 人体 19 关节 | `--joints all/upper/lower` |
| `detect-hand` | 手部 21 关键点 | `--max-hands 2` |
| `detect-humans` | 人体边框（快速） | `--confidence 0.5` |
| `detect-animals` | 猫/狗 骨骼姿态 | — |
| `classify` | 图像分类 | `--max-results 5` |
| `featureprint generate` | 生成图像指纹 | `--output file.fp` |
| `featureprint compare` | 两张图相似度 | `--image1 a.jpg --image2 b.jpg` |
| `detect-contours` | 物体轮廓 | `--threshold 0.5` |
| `saliency` | 视觉显著性热区 | `--type attention/objectness` |
| `optical-flow` | 两帧间光流 | `--from f1.jpg --to f2.jpg` |
| `detect-trajectories` | 多帧物体轨迹 | `--frames ./frames_dir/` |

## 输出格式

所有命令输出统一 JSON 到 stdout，坐标均为像素绝对值（左上角原点）：

```json
{
  "command": "recognize-text",
  "input": "/path/to/image.jpg",
  "duration_ms": 42.3,
  "results": [
    {
      "text": "Hello World",
      "confidence": 0.98,
      "bbox": { "x": 120, "y": 80, "width": 400, "height": 30 }
    }
  ],
  "error": null
}
```

## 给同事分发（预编译）

```bash
# 在你的机器上打包
cd AppleVision
swift build -c release
zip -j apple-vision.zip .build/release/AppleVisionCLI Skills/apple-vision.md

# 上传到 GitHub Releases，同事下载后：
unzip apple-vision.zip
sudo ln -sf "$(pwd)/AppleVisionCLI" /usr/local/bin/apple-vision
cp apple-vision.md ~/.claude/skills/
```

> ⚠️ 预编译二进制要求同事的 Mac 芯片架构（Apple Silicon / Intel）和 macOS 版本与你一致。

