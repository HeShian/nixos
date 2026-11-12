function fwatch --description '定时刷新壁纸和系统信息'
    while true
        clear
        f $argv; or return $status
        sleep 5; or return $status
    end
end
