#!/bin/bash

SCREENSHOTS_DIR="docs/screenshots"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

echo "📷 Создание скриншотов для DevOps портфолио..."
echo "==============================================="

# Создаем директорию для скриншотов
mkdir -p $SCREENSHOTS_DIR

echo "📊 Для создания качественных скриншотов:"
echo ""
echo "1. 🚀 Главный дашборд DevOps Portfolio:"
echo "   http://192.168.1.67:9101/d/devops-portfolio-main"
echo ""
echo "2. 📈 Prometheus Targets:"
echo "   http://192.168.1.67:9100/targets"
echo ""
echo "3. 🔥 Prometheus Alerts:"
echo "   http://192.168.1.67:9100/alerts"
echo ""
echo "4. 💻 System Overview Dashboard:"
echo "   http://192.168.1.67:9101/d/system-overview"
echo ""
echo "5. 🐳 Docker Monitoring:"
echo "   http://192.168.1.67:9101/d/docker-monitoring"
echo ""

# Создаем README для скриншотов
cat > $SCREENSHOTS_DIR/README.md << 'EOF'
# DevOps Portfolio Screenshots

## 🚀 Monitoring Stack Overview

This folder contains screenshots demonstrating the monitoring infrastructure setup.

### 📊 Dashboards
- **Main Dashboard**: DevOps Portfolio overview with key metrics
- **System Monitoring**: Detailed system resource monitoring  
- **Docker Monitoring**: Container and network monitoring
- **Prometheus Targets**: Service health monitoring

### 🔥 Alerting
- **CPU Usage Alerts**: Triggers when CPU > 90%
- **Memory Usage Alerts**: Triggers when Memory > 95%
- **Disk Usage Alerts**: Triggers when Disk > 90%
- **Service Down Alerts**: Triggers when services are unavailable

### 🛠️ Technology Stack
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Node Exporter**: System metrics export
- **Docker**: Containerized deployment

### 📈 Key Features
- Real-time monitoring
- Custom alerting rules
- Professional dashboards
- Auto-provisioning configuration
- Stress testing capabilities
EOF

echo "==============================================="
echo "✅ Директория создана: $SCREENSHOTS_DIR"
echo "✅ README создан: $SCREENSHOTS_DIR/README.md"
echo ""
echo "📝 Рекомендуемые скриншоты для портфолио:"
echo "   1. main-dashboard-overview.png"
echo "   2. cpu-alert-triggered.png"
echo "   3. prometheus-targets-healthy.png"
echo "   4. system-metrics-detailed.png"
echo "   5. grafana-datasource-config.png"
echo ""
echo "🎯 Совет: Запустите стресс-тест перед скриншотами:"
echo "   ./scripts/stress-test.sh all"
