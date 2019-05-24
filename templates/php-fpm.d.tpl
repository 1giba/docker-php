[global]
daemonize = no

[www]
user = ${USER_NAME}
group = ${GROUP_NAME}

clear_env = no

; Ensure worker stdout and stderr are sent to the main error log.
catch_workers_output = yes

listen = ${PHP_FPM_FAST_CGI}
listen.owner = ${USER_NAME}
listen.group = ${GROUP_NAME}
listen.mode = 0666

pm.status_path = /status