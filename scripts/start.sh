#!/bin/bash

echo "🚀 Запуск мониторинг стека..."
echo "==============================================="

# Проверяем, что мы в правильной директории
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Файл docker-compose.yml не найден!"
    echo "Убедитесь, что вы находитесь в директории проекта"
    exit 1
fi

# Проверяем доступность портов
echo "🔍 Проверяем доступность портов..."
for port in 9100 9101 9102; do
    if netstat -tuln | grep -q ":$port "; then
        echo "⚠️  Порт $port уже используется!"
        echo "Завершите процесс или измените порт в docker-compose.yml"
        exit 1
    fi
done

echo "✅ Все порты доступны"

# Запускаем стек
echo "🐳 Запускаем Docker Compose..."
docker-compose up -d

# Проверяем статус
echo ""
echo "📊 Статус контейнеров:"
docker-compose ps

# Получаем IP адрес
SERVER_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+' 2>/dev/null || echo "localhost")

echo ""
echo "🎉 Мониторинг стек запущен!"
echo "==============================================="
echo "📈 Prometheus:    http://$SERVER_IP:9100"
echo "📊 Grafana:       http://$SERVER_IP:9101"
echo "🖥️  Node Exporter: http://$SERVER_IP:9102"
echo ""
echo "👤 Grafana логин: admin"
echo "🔑 Grafana пароль: DevOps2024!"
echo "==============================================="
