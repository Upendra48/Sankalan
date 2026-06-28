# Build stage: compile Flutter web with a Flutter SDK compatible with the frontend project
FROM ubuntu:24.04 AS builder

ARG FLUTTER_VERSION=3.10.7
ARG API_BASE_URL=https://sankalan.onrender.com/api/
ENV FLUTTER_ROOT=/usr/local/flutter
ENV PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"

WORKDIR /app

# Install required build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Download and install Flutter SDK
RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    | tar -xJ -C /usr/local

# Disable analytics and warm up the web tooling
RUN flutter --version && flutter config --no-analytics && flutter precache --web

# Copy pubspec files and resolve packages first for caching
COPY pubspec.* ./
RUN flutter pub get

# Copy source and build web assets
COPY . .
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

# Serve stage: host the generated web app with nginx
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
