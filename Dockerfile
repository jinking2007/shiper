FROM node:20-alpine

# 改用标准应用目录
WORKDIR /app

# 复制必要文件（如果有 package-lock.json 也一并拷入）
COPY package*.json index.js index.html* ./

# 暴露端口
EXPOSE 3000

# 安装 Alpine 运行环境依赖
RUN apk update && apk upgrade && \
    apk add --no-cache openssl curl gcompat iproute2 coreutils bash && \
    chmod +x index.js && \
    npm install --production

# 启动服务
CMD ["node", "index.js"]
