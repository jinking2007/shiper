# ==========================================
# 构建阶段 (Builder)
# ==========================================
FROM node:24.21.0-alpine AS builder

# 安装必要的系统依赖
RUN apk add --no-cache libc6-compat

WORKDIR /app/

# 从你的远程构建源复制代码
COPY --from=src . .

WORKDIR /app/

# 可选：更新全局 npm（如果不需要可以删掉以节省构建时间）
RUN ["npm","install","-g","npm"]

# 安装项目依赖
RUN ["npm","ci"]

# 🚀 关键：这里彻底删除了 RUN ["npm","run","build"]，千万不要保留！

# ==========================================
# 运行阶段 (Runner)
# ==========================================
FROM node:24.21.0-alpine AS runner

WORKDIR /app

# 创建非 root 用户
RUN ["addgroup","--system","--gid","1001","app"]
RUN ["adduser","--system","--uid","1001","app"]

# 🚀 关键：不要复制不存在的 dist 目录
# 直接复制应用源码和依赖
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/index.js ./index.js

# 如果有其他的源码文件或文件夹（比如 src/、config/ 等），按需取消注释并复制
# COPY --from=builder /app/src ./src

# 确保非 root 用户有权限访问
RUN chown -R app:app /app

# 切换用户
USER app

EXPOSE 3000

# 启动命令
CMD ["node", "index.js"]
