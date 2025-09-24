FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with optimizations
RUN npm ci --silent --only=production && npm cache clean --force

# Copy source and build
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

# Install security updates
RUN apk update && apk upgrade && apk add --no-cache wget

# Create non-root user
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001

# Copy built app
COPY --from=builder /app/build /usr/share/nginx/html

# Copy optimized nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chown -R appuser:appuser /usr/share/nginx/html && \
    chown -R appuser:appuser /var/cache/nginx && \
    chown -R appuser:appuser /var/log/nginx && \
    chown -R appuser:appuser /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appuser /var/run/nginx.pid

USER appuser

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]