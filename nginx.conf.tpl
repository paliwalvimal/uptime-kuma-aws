worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /tmp/nginx/nginx.pid;

events {
    worker_connections  1024;
}

http {
    proxy_temp_path        /tmp/nginx/proxy_temp;
    client_body_temp_path  /tmp/nginx/client_temp;
    fastcgi_temp_path      /tmp/nginx/fastcgi_temp;
    uwsgi_temp_path        /tmp/nginx/uwsgi_temp;
    scgi_temp_path         /tmp/nginx/scgi_temp;

    server_tokens  off;

    log_format  json_logger  escape=json '{'
        '"remote_addr": "$remote_addr",'
        '"remote_user": "$remote_user",'
        '"time_local": "$time_local",'
        '"request": "$request",'
        '"request_time": "$request_time",'
        '"request_length": "$request_length",'
        '"status": "$status",'
        '"body_bytes_sent": "$body_bytes_sent",'
        '"http_referer": "$http_referer",'
        '"http_origin": "$http_origin",'
        '"http_user_agent": "$http_user_agent",'
        '"http_x_forwarded_for": "$http_x_forwarded_for",'
        '"upstream_addr": "$upstream_addr"'
    '}';

    access_log  /var/log/nginx/access.log  json_logger;

    sendfile  on;

    keepalive_timeout  65;

    gzip  on;

    server {
        listen ${NGINX_PORT};

        location /ping {
            access_log    off;
            default_type  "text/html";
            return 200    "pong\n";
        }

        location / {
            proxy_pass http://localhost:${UPTIME_KUMA_PORT};

            proxy_http_version 1.1;

            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host ${UPTIME_KUMA_HOSTNAME};
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
