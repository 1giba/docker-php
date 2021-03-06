server {
    listen 80;
    listen [::]:80;
    server_name ${NGINX_SERVER_NAME};

    root    ${NGINX_DOCUMENT_ROOT};
    charset UTF-8;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    location / {
        try_files ${ESCAPE}uri ${ESCAPE}uri/ /index.php?${ESCAPE}query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php${ESCAPE} {
        fastcgi_pass ${PHP_FPM_FAST_CGI};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME ${ESCAPE}document_root${ESCAPE}fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param DOCUMENT_ROOT ${ESCAPE}document_root;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;
}
