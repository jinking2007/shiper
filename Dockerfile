# ==========================================
# 构建阶段 (Builder)
# ==========================================
FROM node:24.21.0-alpine AS builder

# 安装必要的系统依赖
RUN apk add --no-cache libc6-compat

WORKDIR /app/

# 从你的远程构建源复制代码（保持你日志中的写法）
COPY --from=src . .

WORKDIR /app/

# 安装依赖（如果有必要，可以保留更新 npm，通常没必要）
RUN ["npm","install","-g","npm"]

# 安装项目依赖
RUN ["npm","ci"]

# 🚀 关键修改 1：彻底删除下面这一行！因为你的项目没有 build 脚本
# RUN ["npm","run","build"]

# ==========================================
# 运行阶段 (Runner)
# ==========================================
FROM node:24.21.0-alpine AS runner

WORKDIR /app

# 创建非 root 用户
RUN ["addgroup","--system","--gid","1001","app"]
RUN ["adduser","--system","--uid","1001","app"]

# 🚀 关键修改 2：因为没有了 build，不要再去复制不存在的 dist 目录
# 直接把 builder 里的应用文件和依赖复制过来
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/index.js ./index.js

# 如果有其他源码文件或文件夹（比如 src/ 目录），按需复制
# COPY --from=builder /app/src ./src

# 确保非 root 用户有权限访问这些文件
RUN chown -R app:app /app

# 切换到非 root 用户
USER app

EXPOSE 3000

# 启动命令（根据你最初的 Dockerfile，入口是 index.js）
CMD ["node", "index.js"]
