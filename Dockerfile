# ==========================================
# 构建阶段 (Builder)
# ==========================================
FROM node:24.21.0-alpine AS builder

# 安装必要的系统依赖
RUN apk add --no-cache libc6-compat

WORKDIR /app/

# 从你的构建上下文复制代码（假设你之前是通过 COPY --from=src . . 或直接 COPY . .）
COPY . .

# 安装依赖（如果不需要全局更新 npm，建议删除这行，基础镜像自带的通常够用）
# RUN ["npm","install","-g","npm"]

# 使用 npm ci 安装依赖
RUN ["npm","ci"]

# 🚀 关键修改：删除下面这一行，因为你的项目不需要构建！
# RUN ["npm","run","build"]

# ==========================================
# 运行阶段 (Runner)
# ==========================================
FROM node:24.21.0-alpine AS runner

WORKDIR /app

# 创建非 root 用户
RUN addgroup --system --gid 1001 app && \
    adduser --system --uid 1001 app

# 🚀 关键修改：因为没有了 build，直接复制源码和依赖
# 不要复制 dist 目录（因为不存在）
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/index.js ./index.js

# 如果有其他源码文件或文件夹（如 src/），也需要一并复制
# COPY --from=builder /app/src ./src

# 切换到非 root 用户
USER app

EXPOSE 3000

# 启动命令（根据你第一次发来的 Dockerfile，入口是 index.js）
CMD ["node", "index.js"]
