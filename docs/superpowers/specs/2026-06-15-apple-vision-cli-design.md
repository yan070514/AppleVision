# Apple Vision CLI + Claude Code Skill 设计文档

> 日期：2026-06-15 | 状态：设计阶段

## 概述

将 Apple Vision 框架的 15 项计算机视觉能力封装为一个 Swift CLI 二进制 `apple-vision`，配合 Claude Code Skill 文件提供领域知识层，让 Claude 能通过 Bash tool 调用原生 Vision API 分析图像。

**方案**：CLI + Skill（B+C），无需常驻 MCP 进程。

---

## 架构

```
┌──────────────────────┐
│  Claude Code         │
│  ┌────────────────┐  │
│  │ apple-vision   │  │   ← Skill：领域知识 + 使用指南
│  │ skill          │  │
│  └───────┬────────┘  │
│          │ Bash tool  │
│          ▼            │
│  ┌────────────────┐  │
│  │ apple-vision   │  │   ← CLI：Swift 二进制，15 个子命令
│  │ CLI binary     │  │
│  └───────┬────────┘  │
└──────────┼───────────┘
           │
           ▼
    ┌──────────────┐
    │ Vision 框架   │
    │ (VNRequest)  │
    └──────────────┘
```

---

## 项目结构

```
AppleVision/
├── Package.swift
├── Sources/
│   └── AppleVisionCLI/
│       ├── main.swift
│       ├── Commands/
│       │   ├── DetectFaces.swift
│       │   ├── DetectFaceLandmarks.swift
│       │   ├── RecognizeText.swift
│       │   ├── DetectBarcodes.swift
│       │   ├── DetectHumanBodyPose.swift
│       │   ├── DetectHumanHandPose.swift
│       │   ├── ClassifyImage.swift
│       │   ├── GenerateFeaturePrint.swift
│       │   ├── CompareFeaturePrint.swift
│       │   ├── DetectHumanRectangles.swift
│       │   ├── DetectContours.swift
│       │   ├── DetectAnimalBodyPose.swift
│       │   ├── GenerateSaliency.swift
│       │   ├── GenerateOpticalFlow.swift
│       │   └── DetectTrajectories.swift
│       ├── Core/
│       │   ├── ImageLoader.swift
│       │   ├── JSONOutput.swift
│       │   └── VisionHandler.swift
│       └── Models/
│           └── OutputTypes.swift
├── Skills/
│   └── apple-vision.md
├── Tests/
│   ├── AppleVisionCLITests/
│   └── fixtures/
│       ├── face.jpg
│       ├── text_chinese.png
│       ├── qrcode.png
│       └── pose.jpg
└── README.md
```

---

## 15 个子命令

| # | 子命令 | Vision 请求类 | 输入 | 主要选项 |
|---|--------|-------------|------|---------|
| 1 | `detect-faces` | `VNDetectFaceRectanglesRequest` | 单图 | `--confidence <0-1>` |
| 2 | `detect-landmarks` | `VNDetectFaceLandmarksRequest` | 单图 | `--confidence <0-1>` |
| 3 | `recognize-text` | `VNRecognizeTextRequest` | 单图 | `--lang <code>`, `--level fast\|accurate` |
| 4 | `detect-barcodes` | `VNDetectBarcodesRequest` | 单图 | `--formats <list>` |
| 5 | `detect-pose` | `VNDetectHumanBodyPoseRequest` | 单图 | `--joints all\|upper\|lower` |
| 6 | `detect-hand` | `VNDetectHumanHandPoseRequest` | 单图 | `--max-hands <n>` |
| 7 | `classify` | `VNClassifyImageRequest` | 单图 | `--max-results <n>` |
| 8 | `featureprint generate` | `VNGenerateImageFeaturePrintRequest` | 单图 | `--output <path>` |
| 9 | `featureprint compare` | 两次 `VNGenerateImageFeaturePrintRequest` | 两张图 | `--image1 <p> --image2 <p>` |
| 10 | `detect-humans` | `VNDetectHumanRectanglesRequest` | 单图 | `--confidence <0-1>` |
| 11 | `detect-contours` | `VNDetectContoursRequest` | 单图 | `--threshold <0-1>` |
| 12 | `detect-animals` | `VNDetectAnimalBodyPoseRequest` | 单图 | — |
| 13 | `saliency` | `VNGenerateAttentionBasedSaliencyImageRequest` / `VNGenerateObjectnessBasedSaliencyImageRequest` | 单图 | `--type attention\|objectness` |
| 14 | `optical-flow` | `VNGenerateOpticalFlowRequest` | 两张图 | `--from <p> --to <p>` |
| 15 | `detect-trajectories` | `VNDetectTrajectoriesRequest` | 视频帧目录 | `--frames <dir>` |

---

## 统一输出格式

所有命令输出 JSON 到 stdout，按像素绝对值表示坐标：

```json
{
  "command": "<子命令名>",
  "input": "<输入文件路径>",
  "duration_ms": 42.3,
  "results": [ /* 各命令结构不同，见下 */ ],
  "error": null
}
```

### 各命令 results 结构

**detect-faces / detect-humans**
```json
{ "bbox": { "x": 120, "y": 80, "width": 400, "height": 500 }, "confidence": 0.95 }
```

**detect-landmarks**（额外包含 76 个关键点坐标）
```json
{ "bbox": { ... }, "confidence": 0.95, "landmarks": { "left_eye": { "x": 300, "y": 200 }, ... } }
```

**recognize-text**
```json
{ "text": "Hello World", "confidence": 0.98, "bbox": { "x": 50, "y": 30, "width": 200, "height": 30 } }
```

**detect-barcodes**
```json
{ "payload": "https://example.com", "format": "QR", "bbox": { ... } }
```

**detect-pose / detect-hand / detect-animals**
```json
{ "joints": { "left_shoulder": { "x": 400, "y": 300, "confidence": 0.99 }, ... } }
```

**classify**
```json
{ "label": "cat", "confidence": 0.97 }
```

**featureprint generate**
```json
{ "fingerprint_file": "/path/to/output.fp" }
```

**featureprint compare**
```json
{ "similarity": 0.923, "distance": 0.077 }
```

**detect-contours**
```json
{ "contour_index": 0, "points": [{ "x": 10, "y": 20 }, ...], "area": 1500.5 }
```

**saliency**
```json
{ "heatmap_bounds": { "x": 100, "y": 50, "width": 300, "height": 200 }, "confidence": 0.85 }
```

**optical-flow**
```json
{ "pixel_offset": { "dx": 5.2, "dy": -3.1 }, "magnitude": 6.07 }
```

**detect-trajectories**
```json
{ "trajectory_id": 0, "points": [{ "x": 100, "y": 200, "time": 0.0 }, { "x": 150, "y": 180, "time": 0.033 }, ...] }
```

---

## Skill 文件设计

Skill 文件 `Skills/apple-vision.md` 包含：

1. **触发条件**：用户给了一张图片并需要分析其视觉内容
2. **能力速查表**：15 个子命令的适用场景一句话描述
3. **调用规范**：统一通过 `apple-vision <子命令> --image <路径> [选项]`
4. **关键约束**：
   - 必须指定 `--image`，不支持管道输入
   - 坐标均为像素绝对值
   - `recognize-text` 默认 accurate 模式
   - `featureprint compare` 前需先生成指纹
   - `optical-flow` 和 `detect-trajectories` 需要多帧输入
5. **常见模式**：组合调用范例（如先 classify 再 recognize-text）

---

## 错误处理

| 错误类型 | 含义 | 退出码 |
|---------|------|--------|
| `FileNotFound` | 图片路径不存在 | 1 |
| `InvalidImage` | 文件不是有效图片 | 2 |
| `UnsupportedFormat` | Vision 不支持的格式 | 3 |
| `VisionError` | Vision 框架内部错误 | 4 |
| `MissingArgument` | 缺少必需参数 | 5 |
| `NoResults` | 正常执行但未检测到目标（不算错误） | 0，results 为 [] |

---

## 依赖

- **Swift 5.9+**（Vision 框架 macOS 13+ / iOS 16+ 最佳 API 覆盖）
- **swift-argument-parser**（Apple 官方 CLI 框架）
- **macOS 14+**（推荐，Venature 对动物识别、光流等新 API 支持更好）

---

## 测试策略

| 层级 | 测什么 | 怎么测 |
|------|--------|--------|
| 单元测试 | 每个 Command 的 JSON 输出结构 | XCTest + `Tests/fixtures/` 固定测试图 |
| 快照测试 | 同一张图两次调用输出一致 | XCTest |
| 集成测试 | 完整 CLI 调用链路 | Shell 脚本，验证退出码和 JSON 结构 |
| 边界测试 | 空图片、超尺寸图、无权限路径 | XCTest |

---

## 数据约定

- **坐标**：所有坐标均为像素绝对值，原点在图片左上角，x 轴向右、y 轴向下
- **featureprint compare 的 similarity**：范围 0~1，1.0 表示两张图高度相似；distance 为 L2 欧氏距离，无上界
- **optical-flow**：返回全帧的平均位移向量（summary），不返回逐像素光流场（数据量过大）
- **detect-trajectories**：需要预先将视频拆帧放入目录，帧文件按时间命名排序

---

## 不做的事

- 不支持图片管道输入（`cat img.jpg | apple-vision ...`）
- 不支持视频文件直接输入（需预先拆帧）
- 不支持 GPU/ANE 加速的手动控制（Vision 框架自动选择）
- 不支持非 Apple 平台的 OpenCV 回退方案
