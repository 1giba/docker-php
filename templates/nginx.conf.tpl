user  ${USER_NAME};
worker_processes  ${NGINX_WORKER_PROCESSES};

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  ${NGINX_WORKER_CONNECTIONS};
    multi_accept on;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format gzip '${ESCAPE}remote_addr - ${ESCAPE}remote_user [${ESCAPE}time_local] "${ESCAPE}request" '
                    '${ESCAPE}status ${ESCAPE}body_bytes_sent "${ESCAPE}http_referer" '
                    '"${ESCAPE}http_user_agent" "${ESCAPE}http_x_forwarded_for"';

    access_log off;
    error_log  off;

    sendfile    on;
    tcp_nopush  on;
    tcp_nodelay on;

    keepalive_timeout ${NGINX_KEEPALIVE_TIMEOUT};
    types_hash_max_size 2048;
    server_tokens ${NGINX_EXPOSE_VERSION};
    client_body_buffer_size ${NGINX_CLIENT_BODY_BUFFER_SIZE};
    client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};
    large_client_header_buffers ${NGINX_LARGE_CLIENT_HEADER_BUFFERS};

    gzip  on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    include /etc/nginx/conf.d/*.conf;
}