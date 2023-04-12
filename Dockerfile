FROM ghcr.io/hazmi35/node:18-dev-alpine as build-stage

# Installing libvips-dev for sharp Compatibility
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev

# Set environment to prod
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Set working directory
WORKDIR /tmp
ENV PATH /tmp/node_modules/.bin:$PATH

# Copy needed files
COPY ./package*.json ./

# Install deps
RUN npm install --production

# Set working directory to /tmp/app
WORKDIR /tmp/app

# Copy project files
COPY ./ .

# Build project
RUN npm run build

# Get ready for production
FROM ghcr.io/hazmi35/node:18-dev-alpine

# Set working directory
WORKDIR /app

# Install needed deps
RUN apk add --no-cache vips

# Set environment to prod
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Copy from build stage
COPY --from=build-stage /tmp/node_modules ./node_modules
COPY --from=build-stage /tmp/app ./

# Set path
ENV PATH /app/node_modules/.bin:$PATH

# Expose port
EXPOSE 1337

CMD ["npm", "run", "start"]
