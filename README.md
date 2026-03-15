# 证件照制作工具 - 纯前端版

AI 智能证件照生成工具，完全在浏览器运行，无需后端服务器。

## 功能特点

- ✅ AI 智能抠图（使用 @imgly/background-removal）
- ✅ 多种证件照规格（身份证、护照、简历等）
- ✅ 一键换背景色（白/红/蓝等）
- ✅ 服装模板叠加（可选）
- ✅ 纯前端实现，图片不上传服务器
- ✅ 免费部署到 Vercel/Netlify

## 快速开始

### 安装依赖

```bash
cd id-photo-web
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000

### 构建生产版本

```bash
npm run build
```

### 部署到 Vercel

```bash
npm install -g vercel
vercel deploy
```

## 支持的证件照规格

| 类型 | 尺寸 (px) | 默认背景 |
|------|----------|---------|
| 身份证 | 358 × 441 | 白色 |
| 护照 | 354 × 472 | 白色 |
| 签证 | 354 × 472 | 白色 |
| 简历 | 295 × 413 | 白色 |
| 毕业证 | 413 × 579 | 蓝色 |
| 结婚证 | 626 × 413 | 红色 |
| 资格考试 | 295 × 413 | 白色 |
| 驾驶证 | 378 × 520 | 白色 |

## 技术栈

- Vue 3 + Vite
- @imgly/background-removal (WebAssembly AI 抠图)
- Fabric.js (画布处理)

## 注意事项

- 首次使用需下载 AI 模型（约 20MB），请耐心等待
- 图片处理在本地完成，不会上传到任何服务器
- 建议使用 Chrome/Edge 等现代浏览器

## License

MIT
