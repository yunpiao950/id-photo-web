<template>
  <div class="app">
    <header class="header">
      <h1>📸 证件照制作工具</h1>
      <p>AI 智能抠图 · 一键换背景 · 多种规格</p>
    </header>

    <main class="main">
      <!-- 左侧：上传和处理 -->
      <div class="left-panel">
        <!-- 场景选择 -->
        <section class="section">
          <h2>1️⃣ 选择用途</h2>
          <div class="scene-grid">
            <button
              v-for="(preset, key) in presets"
              :key="key"
              :class="['scene-btn', { active: selectedScene === key }]"
              @click="selectScene(key)"
            >
              <span class="scene-icon">{{ preset.icon }}</span>
              <span class="scene-name">{{ preset.name }}</span>
            </button>
          </div>
        </section>

        <!-- 图片上传 -->
        <section class="section">
          <h2>2️⃣ 上传照片</h2>
          <div
            class="uploader"
            :class="{ dragging: isDragging }"
            @drop="onDrop"
            @dragover.prevent="isDragging = true"
            @dragleave="isDragging = false"
            @click="$refs.fileInput.click()"
          >
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              @change="onFileSelect"
              style="display: none"
            />
            <div v-if="!originalImage" class="uploader-placeholder">
              <span class="upload-icon">📁</span>
              <p>点击或拖拽上传照片</p>
              <p class="hint">支持 JPG、PNG 格式</p>
            </div>
            <img v-else :src="originalImage" class="uploaded-preview" />
          </div>
        </section>

        <!-- 背景色选择 -->
        <section class="section" v-if="processedImage || originalImage">
          <h2>3️⃣ 选择背景色</h2>
          <div class="color-grid">
            <button
              v-for="color in backgroundColors"
              :key="color.value"
              :class="['color-btn', { active: selectedBgColor === color.value }]"
              :style="{ backgroundColor: color.value }"
              @click="selectedBgColor = color.value"
            >
              <span v-if="selectedBgColor === color.value" class="check">✓</span>
            </button>
          </div>
        </section>

        <!-- 操作按钮 -->
        <section class="section" v-if="originalImage && !isProcessing">
          <button class="process-btn" @click="processImage">
            🚀 {{ processedImage ? '重新制作' : '开始制作' }}
          </button>
        </section>

        <!-- 处理状态 -->
        <section class="section" v-if="isProcessing">
          <div class="processing">
            <div class="spinner"></div>
            <p>{{ processingText }}</p>
            <p class="hint">首次使用需下载 AI 模型（约 20MB），请耐心等待</p>
          </div>
        </section>
      </div>

      <!-- 右侧：预览 -->
      <div class="right-panel">
        <section class="preview-section">
          <h2>📋 预览效果</h2>
          <div class="preview-container">
            <canvas ref="previewCanvas"></canvas>
          </div>
          <div class="preview-info" v-if="selectedScene">
            <p><strong>规格：</strong>{{ presets[selectedScene].name }}</p>
            <p><strong>尺寸：</strong>{{ currentDimensions.width }} × {{ currentDimensions.height }} px</p>
            <p><strong>背景：</strong>{{ currentBgColorName }}</p>
          </div>
        </section>

        <!-- 下载按钮 -->
        <section class="section" v-if="processedImage">
          <button class="download-btn" @click="downloadImage">
            💾 下载证件照
          </button>
        </section>
      </div>
    </main>

    <footer class="footer">
      <p>纯前端实现 · 图片不会上传到服务器 · 隐私安全</p>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { removeBackground } from '@imgly/background-removal'

// 场景预设
const presets = {
  'id-card': { name: '身份证', icon: '🆔', width: 358, height: 441, bg: '#ffffff' },
  'passport': { name: '护照', icon: '🛂', width: 354, height: 472, bg: '#ffffff' },
  'visa': { name: '签证', icon: '📝', width: 354, height: 472, bg: '#ffffff' },
  'resume': { name: '简历', icon: '📄', width: 295, height: 413, bg: '#ffffff' },
  'graduation': { name: '毕业证', icon: '🎓', width: 413, height: 579, bg: '#0066cc' },
  'marriage': { name: '结婚证', icon: '💒', width: 626, height: 413, bg: '#ff0000' },
  'exam': { name: '资格考试', icon: '📚', width: 295, height: 413, bg: '#ffffff' },
  'driver': { name: '驾驶证', icon: '🚗', width: 378, height: 520, bg: '#ffffff' }
}

// 背景色选项
const backgroundColors = [
  { name: '白色', value: '#ffffff' },
  { name: '红色', value: '#ff0000' },
  { name: '蓝色', value: '#0066cc' },
  { name: '浅蓝', value: '#4da6ff' },
  { name: '灰色', value: '#e0e0e0' }
]

// 状态
const selectedScene = ref('id-card')
const selectedBgColor = ref('#ffffff')
const originalImage = ref(null)
const processedImage = ref(null)
const isDragging = ref(false)
const isProcessing = ref(false)
const processingText = ref('')

// Canvas
const previewCanvas = ref(null)
let canvas = null
let ctx = null

// 计算属性
const currentDimensions = computed(() => {
  if (!selectedScene.value) return { width: 295, height: 413 }
  const preset = presets[selectedScene.value]
  return { width: preset.width, height: preset.height }
})

const currentBgColorName = computed(() => {
  const color = backgroundColors.find(c => c.value === selectedBgColor.value)
  return color ? color.name : '自定义'
})

// 初始化 Canvas
onMounted(() => {
  if (previewCanvas.value) {
    canvas = previewCanvas.value
    ctx = canvas.getContext('2d')
    canvas.width = currentDimensions.value.width
    canvas.height = currentDimensions.value.height
    renderPreview()
  }
})

// 选择场景
function selectScene(key) {
  selectedScene.value = key
  selectedBgColor.value = presets[key].bg
  if (canvas) {
    canvas.width = presets[key].width
    canvas.height = presets[key].height
    renderPreview()
  }
}

// 文件上传
function onFileSelect(event) {
  const file = event.target.files[0]
  if (file) loadImage(file)
}

function onDrop(event) {
  event.preventDefault()
  isDragging.value = false
  const file = event.dataTransfer.files[0]
  if (file && file.type.startsWith('image/')) loadImage(file)
}

function loadImage(file) {
  const reader = new FileReader()
  reader.onload = (e) => {
    originalImage.value = e.target.result
    processedImage.value = null
    renderPreview()
  }
  reader.readAsDataURL(file)
}

// 处理图片
async function processImage() {
  if (!originalImage.value) return
  
  isProcessing.value = true
  processingText.value = '正在加载 AI 模型...'
  
  try {
    // 将 base64 转为 blob
    const response = await fetch(originalImage.value)
    const blob = await response.blob()
    
    processingText.value = '正在 AI 抠图...'
    const removedBg = await removeBackground(blob, {
      progress: (key, current, total) => {
        processingText.value = `正在处理：${Math.round((current / total) * 100)}%`
      }
    })
    
    processedImage.value = URL.createObjectURL(removedBg)
    renderPreview()
  } catch (error) {
    console.error('处理失败:', error)
    alert('处理失败，请重试')
  } finally {
    isProcessing.value = false
  }
}

// 渲染预览
function renderPreview() {
  if (!ctx || !canvas) return
  
  // 清空画布
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  
  // 填充背景色
  ctx.fillStyle = selectedBgColor.value
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  
  // 如果有抠图，显示抠图结果
  if (processedImage.value) {
    const img = new Image()
    img.onload = () => {
      // 计算缩放比例，居中显示
      const scale = Math.min(
        canvas.width / img.width,
        canvas.height / img.height
      ) * 0.9
      const newWidth = img.width * scale
      const newHeight = img.height * scale
      const x = (canvas.width - newWidth) / 2
      const y = (canvas.height - newHeight) / 2
      ctx.drawImage(img, x, y, newWidth, newHeight)
    }
    img.src = processedImage.value
  } else if (originalImage.value) {
    // 显示原图预览（半透明）
    const img = new Image()
    img.onload = () => {
      const scale = Math.min(
        canvas.width / img.width,
        canvas.height / img.height
      ) * 0.8
      const newWidth = img.width * scale
      const newHeight = img.height * scale
      const x = (canvas.width - newWidth) / 2
      const y = (canvas.height - newHeight) / 2
      ctx.globalAlpha = 0.5
      ctx.drawImage(img, x, y, newWidth, newHeight)
      ctx.globalAlpha = 1.0
    }
    img.src = originalImage.value
  }
}

// 监听背景色变化
watch(selectedBgColor, () => {
  renderPreview()
})

// 下载图片
function downloadImage() {
  if (!canvas) return
  
  const link = document.createElement('a')
  link.download = `证件照-${presets[selectedScene.value].name}-${Date.now()}.png`
  link.href = canvas.toDataURL('image/png')
  link.click()
}
</script>

<style scoped>
.app {
  min-height: 100vh;
  padding: 20px;
}

.header {
  text-align: center;
  color: white;
  margin-bottom: 30px;
}

.header h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

.header p {
  font-size: 1.1rem;
  opacity: 0.9;
}

.main {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
  max-width: 1400px;
  margin: 0 auto;
}

@media (max-width: 900px) {
  .main {
    grid-template-columns: 1fr;
  }
}

.left-panel, .right-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.section h2 {
  font-size: 1.2rem;
  margin-bottom: 15px;
  color: #333;
}

/* 场景选择 */
.scene-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
}

.scene-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px 10px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  transition: all 0.2s;
}

.scene-btn:hover {
  border-color: #667eea;
  transform: translateY(-2px);
}

.scene-btn.active {
  border-color: #667eea;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.scene-icon {
  font-size: 1.5rem;
  margin-bottom: 5px;
}

.scene-name {
  font-size: 0.9rem;
}

/* 上传区域 */
.uploader {
  border: 2px dashed #ccc;
  border-radius: 8px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.uploader:hover, .uploader.dragging {
  border-color: #667eea;
  background: rgba(102, 126, 234, 0.05);
}

.upload-icon {
  font-size: 3rem;
  display: block;
  margin-bottom: 10px;
}

.hint {
  font-size: 0.85rem;
  color: #999;
  margin-top: 5px;
}

.uploaded-preview {
  max-width: 100%;
  max-height: 200px;
  border-radius: 8px;
}

/* 颜色选择 */
.color-grid {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.color-btn {
  width: 50px;
  height: 50px;
  border: 3px solid transparent;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  transition: all 0.2s;
}

.color-btn:hover {
  transform: scale(1.1);
}

.color-btn.active {
  border-color: #333;
}

.check {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 1.5rem;
  text-shadow: 0 0 3px black;
}

/* 处理按钮 */
.process-btn, .download-btn {
  width: 100%;
  padding: 15px;
  font-size: 1.1rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.process-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.process-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.download-btn {
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
  color: white;
}

.download-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(17, 153, 142, 0.4);
}

/* 处理状态 */
.processing {
  text-align: center;
  padding: 20px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* 预览区域 */
.preview-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.preview-container {
  background: #f0f0f0;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

canvas {
  max-width: 100%;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

.preview-info {
  margin-top: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.preview-info p {
  margin: 5px 0;
  font-size: 0.95rem;
}

/* 页脚 */
.footer {
  text-align: center;
  color: white;
  margin-top: 40px;
  padding: 20px;
  opacity: 0.8;
}
</style>
