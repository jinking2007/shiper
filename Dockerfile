# ==========================================
# 构建阶段 (Builder)
# ==========================================
FROM node:24.21.0-alpine AS builder

# 安装必要的系统依赖（日志中有使用 libc6-compat）
RUN apk add --no-cache libc6-compat

WORKDIR /app/

# 从你的构建上下文复制代码（如果此前有 COPY --from=src . . 也保留原来的，这里写通用写法）
COPY . .

# 重点修复：去掉全局更新 npm（没必要且容易出错）
# 使用 npm ci，并带上处理 workspaces 的参数
# 如果确实需要强制包含根目录的依赖，加上 --include-workspace-root
RUN npm ci --workspaces --include-workspace-root

# 执行构建
RUN npm run build

# ==========================================
# 运行阶段 (Runner)
# ==========================================
FROM node:24.21.0-alpine AS runner

WORKDIR /app

# 创建非 root 用户 (根据你之前的日志保留)
RUN addgroup --system --gid 1001 app
RUN adduser --system --uid 1001 app

# 从构建阶段复制产物
# ⚠️ 下面的 dist 需要替换为你项目中真实的构建输出目录（如 dist, build, .next 等）
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# 切换到非 root 用户
USER app

EXPOSE 3000

# 启动命令
# ⚠️ 确保路径与你的构建产物入口匹配，例如 dist/index.js 或 dist/main.js
CMD ["node", "dist/index.js"]
