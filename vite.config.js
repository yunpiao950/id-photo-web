import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: '/id-photo-web/',
  server: {
    host: '0.0.0.0',
    port: 3000,
    strictPort: true
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  }
})
