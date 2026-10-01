# 1. 使用 Node 20 Alpine 基础镜像（安全、体积小）
FROM node:20-alpine3.20

# 2. 设置工作目录（建议用 /app，不要用 /tmp）
WORKDIR /app

# 3. 安装必要的系统级依赖（根据你的实际需求保留或删除）
# 如果无需编译原生模块（如 bcrypt, sqlite3），可以不装 python3/make/g++
RUN apk update && apk add --no-cache bash openssl curl

# 4. 复制根目录的依赖清单（利用 Docker 缓存层）
COPY package.json package-lock.json ./

# ==========================================
# 5. 重点修复：复制所有 Workspace 子包的 package.json
# ⚠️ 请根据你实际的 Monorepo 目录结构修改下面两行！
# 假设你的子包在 packages/ 和 apps/ 目录下
# ==========================================
COPY packages/*/package.json ./packages/
COPY apps/*/package.json ./apps/

# 6. 执行安装（使用 --workspaces --include-workspace-root 修复报错）
# 提示：如果 npm ci 仍然报错，可以替换为 npm install --workspaces --include-workspace-root
RUN npm ci --workspaces --include-workspace-root

# 7. 复制项目所有源代码（前提是配置了 .dockerignore 排除 node_modules）
COPY . .

# 8. 执行构建（如果你有 npm run build 脚本）
RUN npm run build

# 9. 暴露端口
EXPOSE 3000

# 10. 切换到非 root 用户运行（提高安全性）
USER node

# 11. 启动命令（根据你的入口文件调整）
CMD ["node", "index.js"]
