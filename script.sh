#!/bin/bash

# Печатаем заголовок таблицы
printf "%-10s %-5s %-5s %-5s %-8s %s\n" "PID" "TTY" "STAT" "TIME" "CMD"

# Проходим по всем каталогам в /proc, которые имеют числовые имена (это идентификаторы процессов)
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    # Проверяем, существуют ли необходимые файлы
    if [ -f /proc/$pid/stat ] && [ -f /proc/$pid/status ] && [ -f /proc/$pid/cmdline ]; then
        # Получаем командную строку процесса
        cmd=$(cat /proc/$pid/cmdline | tr '\0' ' ')
        # Если командная строка пуста, используем имя команды
        if [ -z "$cmd" ]; then
            cmd="[$(cat /proc/$pid/comm)]"
        fi

        # Получаем статус процесса из файла stat
        stat=$(cat /proc/$pid/stat)
        status=$(echo "$stat" | awk '{print $3}')

        # Определяем терминал (TTY), к которому привязан процесс
        tty_nr=$(echo "$stat" | awk '{print $7}')
        tty=$(ls -l /proc/$pid/fd | grep " $tty_nr$" | awk '{print $11}')
        # Если терминал не определён, присваиваем значение "?   "
        if [ -z "$tty" ]; then
            tty="?   "
        elif [ "$tty" == "/dev/null" ]; then
            tty="?   "
        else
            tty=$(basename "$tty")
        fi

        # Вычисляем общее время работы процесса
        utime=$(echo "$stat" | awk '{print $14}')
        stime=$(echo "$stat" | awk '{print $15}')
        total_time=$((utime + stime))
        seconds=$((total_time / 100))
        minutes=$((seconds / 60))
        seconds=$((seconds % 60))
        time=$(printf "%02d:%02d" $minutes $seconds)

        # Печатаем информацию о процессе в табличном формате
        printf "%-10s %-5s %-5s %-5s %-8s %s\n" "$pid" "$tty" "$status" "$time" "$cmd"
    fi
done
