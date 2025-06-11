#!/bin/bash

echo "🔥 Запуск стресс-теста для проверки алертов..."
echo "==============================================="

# Функция для генерации CPU нагрузки
cpu_stress() {
    echo "💻 Генерируем CPU нагрузку..."
    timeout 60s yes > /dev/null &
    timeout 60s yes > /dev/null &
    timeout 60s yes > /dev/null &
    timeout 60s yes > /dev/null &
    echo "CPU нагрузка будет активна 60 секунд"
}

# Функция для генерации нагрузки на память
memory_stress() {
    echo "🧠 Генерируем нагрузку на память..."
    timeout 60s stress --vm 1 --vm-bytes 1G --vm-keep > /dev/null 2>&1 &
    echo "Нагрузка на память будет активна 60 секунд"
}

# Функция для генерации нагрузки на диск
disk_stress() {
    echo "💾 Генерируем нагрузку на диск..."
    timeout 60s dd if=/dev/zero of=/tmp/stresstest bs=1M count=1000 > /dev/null 2>&1 &
    echo "Нагрузка на диск будет активна 60 секунд"
}

case $1 in
    cpu)
        cpu_stress
        ;;
    memory)
        memory_stress
        ;;
    disk)
        disk_stress
        ;;
    all)
        cpu_stress
        sleep 5
        memory_stress
        sleep 5
        disk_stress
        ;;
    *)
        echo "Использование: $0 {cpu|memory|disk|all}"
        echo "  cpu    - нагрузка на CPU"
        echo "  memory - нагрузка на память" 
        echo "  disk   - нагрузка на диск"
        echo "  all    - все виды нагрузки"
        exit 1
        ;;
esac

echo "==============================================="
echo "🎯 Проверьте Grafana дашборды и алерты!"
echo "📊 Grafana: http://$(ip route get 8.8.8.8 | grep -oP 'src \K\S+' 2>/dev/null || echo localhost):9101"
echo "📈 Prometheus: http://$(ip route get 8.8.8.8 | grep -oP 'src \K\S+' 2>/dev/null || echo localhost):9100"
