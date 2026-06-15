# Apple Vision CLI

15 个计算机视觉 CLI 工具，封装 Apple Vision 框架。配合 Claude Code 使用，让 AI 能"看懂"图片。

## 安装

```bash
cd AppleVision
swift build -c release
sudo ln -sf "$(pwd)/.build/release/AppleVisionCLI" /usr/local/bin/apple-vision
```

或者添加 PATH（无需 sudo）：

```bash
export PATH="$PATH:/path/to/AppleVision/.build/release"
alias apple-vision=AppleVisionCLI
```

## 依赖

- macOS 14+
- Swift 5.9+
- Xcode 15+

## 使用

```bash
apple-vision recognize-text --image photo.jpg
apple-vision detect-faces --image selfie.png
apple-vision detect-barcodes --image qrcode.png
apple-vision detect-pose --image yoga.jpg
apple-vision classify --image scene.jpg
apple-vision featureprint compare --image1 a.jpg --image2 b.jpg
```

## 全部命令

| 命令 | 功能 |
|------|------|
| `recognize-text` | OCR 文字识别 |
| `detect-faces` | 人脸检测 |
| `detect-landmarks` | 五官关键点 |
| `detect-barcodes` | 条码/二维码 |
| `detect-pose` | 人体姿态 |
| `detect-hand` | 手部姿态 |
| `detect-humans` | 人体检测 |
| `detect-animals` | 动物姿态 |
| `classify` | 图像分类 |
| `featureprint generate` | 图像指纹 |
| `featureprint compare` | 相似度比较 |
| `detect-contours` | 轮廓检测 |
| `saliency` | 显著性区域 |
| `optical-flow` | 光流 |
| `detect-trajectories` | 轨迹检测 |

## 输出格式

所有命令输出 JSON 到 stdout，坐标均为像素绝对值：

```json
{
  "command": "recognize-text",
  "input": "/path/to/image.jpg",
  "duration_ms": 42.3,
  "results": [...],
  "error": null
}
```
