#!/bin/bash

echo "🚀 部署到 GitHub Pages..."

# 检查 git 是否配置
if ! git config user.name > /dev/null 2>&1; then
    echo "请配置 git 用户名和邮箱："
    echo "  git config --global user.name \"你的名字\""
    echo "  git config --global user.email \"你的邮箱\""
    exit 1
fi

# 初始化 git（如果还没初始化）
if [ ! -d ".git" ]; then
    git init
fi

# 添加所有文件
git add .
git commit -m "Deploy to GitHub Pages"

# 设置主分支
git branch -M main

# 提示用户添加远程仓库
echo ""
echo "✅ 本地提交完成！"
echo ""
echo "接下来请执行："
echo "1. 在 GitHub 创建新仓库（不要初始化）"
echo "2. 运行以下命令（替换为你的仓库地址）："
echo ""
echo "   git remote add origin https://github.com/你的用户名/id-photo-web.git"
echo "   git push -u origin main"
echo ""
echo "3. 在 GitHub 仓库 Settings → Pages 中启用 GitHub Actions 部署"
echo ""
