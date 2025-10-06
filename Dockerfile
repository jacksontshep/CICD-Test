# Dockerfile for Vue SSR Application with NSolid

FROM nodesource/nsolid:latest

ARG NSOLID_SAAS
ENV NSOLID_SAAS=${NSOLID_SAAS}

WORKDIR /app

# Copy package files and install ALL dependencies (including dev)
COPY package*.json ./
RUN npm install

# Install tsx globally
RUN npm install -g tsx@latest

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Remove dev dependencies to reduce image size
RUN npm prune --production

# Set NODE_ENV to production for runtime
ENV NODE_ENV=production

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nsolid -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["tsx", "server/index.ts"]