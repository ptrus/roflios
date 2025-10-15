FROM ubuntu:24.04

# Install required dependencies
RUN apt-get update && \
    apt-get install -y curl ca-certificates nginx supervisor && \
    rm -rf /var/lib/apt/lists/*

# Download and install Helios binary
RUN ARCH="$(uname -m)" && \
    if [ "$ARCH" = "x86_64" ]; then \
        HELIOS_URL="https://github.com/a16z/helios/releases/latest/download/helios_linux_amd64.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        HELIOS_URL="https://github.com/a16z/helios/releases/latest/download/helios_linux_arm64.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -fsSL "$HELIOS_URL" -o helios.tar.gz && \
    tar -xzf helios.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/helios && \
    rm helios.tar.gz

# Copy website files
COPY website /usr/share/nginx/html

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create startup script that will use environment variables
RUN echo '#!/bin/bash\n\
if [ -z "$INFURA_API_KEY" ]; then\n\
  echo "Error: INFURA_API_KEY environment variable is not set"\n\
  exit 1\n\
fi\n\
\n\
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF\n\
[supervisord]\n\
nodaemon=true\n\
user=root\n\
\n\
[program:helios]\n\
command=/usr/local/bin/helios ethereum --network mainnet --rpc-bind-ip 127.0.0.1 --rpc-port 8545 --execution-rpc https://mainnet.infura.io/v3/$INFURA_API_KEY\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
autorestart=true\n\
\n\
[program:nginx]\n\
command=/usr/sbin/nginx -g "daemon off;"\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
autorestart=true\n\
EOF\n\
\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf\n\
' > /usr/local/bin/start.sh && chmod +x /usr/local/bin/start.sh

# Expose the combined port
EXPOSE 1337

# Run startup script
CMD ["/usr/local/bin/start.sh"]
