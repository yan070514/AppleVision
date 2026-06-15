---
name: apple-vision
description: Apple Vision 图像分析——通过 CLI 调用 macOS Vision 框架的 15 个计算机视觉工具
---

# Apple Vision CLI Skill

## 什么时候用这个 Skill

当用户给你一张图片并要求你做以下事情时：

- 提取图片中的文字
- 检测人脸、五官
- 扫描/解码二维码或条码
- 分析人体姿态、手势
- 识别动物姿态
- 分类图片内容
- 比较两张图片的相似度
- 检测物体轮廓
- 生成显著性区域
- 分析视频帧之间的运动（光流/轨迹）

## 15 个命令速查

### 文字
| 命令 | 用途 | 示例 |
|------|------|------|
| `recognize-text` | OCR 文字识别 | `apple-vision recognize-text --image screenshot.png --lang zh-Hans` |

### 人脸
| 命令 | 用途 | 示例 |
|------|------|------|
| `detect-faces` | 检测人脸位置 | `apple-vision detect-faces --image photo.jpg` |
| `detect-landmarks` | 检测五官关键点 | `apple-vision detect-landmarks --image face.jpg` |

### 条码
| 命令 | 用途 | 示例 |
|------|------|------|
| `detect-barcodes` | 扫码/解码 | `apple-vision detect-barcodes --image qrcode.png` |

### 人体 & 动物
| 命令 | 用途 | 示例 |
|------|------|------|
| `detect-pose` | 人体姿态 19 关节 | `apple-vision detect-pose --image yoga.jpg --joints all` |
| `detect-hand` | 手部 21 关键点 | `apple-vision detect-hand --image gesture.jpg` |
| `detect-humans` | 人体边框（快） | `apple-vision detect-humans --image crowd.jpg` |
| `detect-animals` | 猫狗姿态 | `apple-vision detect-animals --image pet.jpg` |

### 图像分析
| 命令 | 用途 | 示例 |
|------|------|------|
| `classify` | 图像分类 | `apple-vision classify --image scene.jpg` |
| `featureprint generate` | 生成图像指纹 | `apple-vision featureprint generate --image a.jpg --output a.fp` |
| `featureprint compare` | 比较两张图 | `apple-vision featureprint compare --image1 a.jpg --image2 b.jpg` |
| `detect-contours` | 检测物体轮廓 | `apple-vision detect-contours --image object.jpg` |
| `saliency` | 显著性区域 | `apple-vision saliency --image design.jpg --type attention` |

### 视频/帧序列
| 命令 | 用途 | 示例 |
|------|------|------|
| `optical-flow` | 两帧之间运动 | `apple-vision optical-flow --from frame1.jpg --to frame2.jpg` |
| `detect-trajectories` | 多帧物体轨迹 | `apple-vision detect-trajectories --frames ./frame_dir/` |

## 调用规范

**全部通过 Bash tool 调用：**

```bash
apple-vision <子命令> --image <图片路径> [选项...]
```

**输出格式**：所有命令输出统一 JSON 到 stdout：

```json
{
  "command": "<子命令名>",
  "input": "<输入路径>",
  "duration_ms": 42.3,
  "results": [...],
  "error": null
}
```

## 关键约束

1. **必须指定 `--image`（或等效参数）**，不支持 stdin 管道输入
2. **坐标全部是像素绝对值**，原点在左上角
3. **`recognize-text` 默认 `.accurate` 模式**（精确但慢），大量文本可切 `--level fast`
4. **`featureprint compare` 直接比较两张图**，无需先生成指纹文件
5. **`optical-flow` 和 `detect-trajectories` 需要多帧**，单张图片无法分析运动
6. **`detect-trajectories --frames` 需要目录**，帧按文件名排序，需预先从视频拆帧
7. **`similarity` 值 0~1**，1.0 = 完全相同；`distance` 是 L2 欧氏距离，越小越相似

## 常见组合模式

### 场景 1：分析截图中的报错
1. `apple-vision recognize-text --image error_screenshot.png`
2. 从返回的 TextResult 中提取错误信息文本

### 场景 2：分析瑜伽体式是否标准
1. `apple-vision detect-pose --image user_pose.jpg`
2. `apple-vision detect-pose --image reference_pose.jpg`
3. 对比两组 JointPoint 的坐标

### 场景 3：检查两张 UI 截图是否一致（视觉回归）
1. `apple-vision featureprint compare --image1 ui_before.png --image2 ui_after.png`
2. similarity < 0.95 表示变化显著

### 场景 4：扫描产品条码并分类
1. `apple-vision detect-barcodes --image product.jpg`
2. `apple-vision classify --image product.jpg`
3. 交叉验证条码和视觉分类是否一致

### 场景 5：分析视频中物体的运动
1. 用 ffmpeg 预先拆帧：`ffmpeg -i video.mp4 -vf fps=30 frames/%04d.jpg`
2. `apple-vision optical-flow --from frames/0001.jpg --to frames/0002.jpg`
3. 对多帧重复，得出运动模式

## 错误处理

| 退出码 | 含义 | Claude 应该怎么处理 |
|--------|------|-------------------|
| 0 | 成功 | 解析 results JSON |
| 1 | 图片不存在 | 检查路径是否正确 |
| 2 | 不是有效图片 | 确认文件格式（支持 JPG/PNG/HEIC） |
| 3 | 格式不支持 | 转换图片格式 |
| 4 | Vision 框架内部错误 | 重试一次，仍失败则告知用户图片可能损坏 |
| 5 | 缺少参数 | 补充必需参数 |

## 系统要求

- macOS 14+（Vision 框架完整 API 覆盖）
- 编译后的二进制位于 `/usr/local/bin/apple-vision`（或通过 PATH 访问）
