FROM node:20-alpine3.20

# 1. 更换工作目录为 /app
WORKDIR /app

# 2. 先复制依赖清单（利用 Docker 缓存层）
# 如果本地有 package-lock.json，请一并复制
COPY package.json package-lock.json* ./

# 3. 如果需要编译原生模块，请取消下面这行的注释
RUN apk add --no-cache python3 make g++

# 4. 安装依赖 (推荐使用 npm ci，如果报 workspaces 错误则用 npm install)
# 如果不需要 devDependencies，可以加上 --omit=dev
RUN npm install

# 5. 复制应用代码
COPY index.js ./

# 6. 安装必要的系统工具（建议确认是否真的需要 bash 和 curl）
RUN apk update && apk add --no-cache openssl curl

# 7. 暴露端口
EXPOSE 3000

# 8. 使用非 root 用户运行（提高安全性）
USER node

# 9. 启动命令
CMD ["node", "index.js"]
