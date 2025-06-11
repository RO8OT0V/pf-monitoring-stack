pipeline {
    agent any
    
    environment {
        // Переменные для мониторинг стека
        PROJECT_NAME = 'pf-monitoring-stack'
        STACK_PREFIX = 'pf-monitoring'
        
        // Порты сервисов (ваши текущие)
        PROMETHEUS_PORT = '9100'
        GRAFANA_PORT = '9101'
        NODE_EXPORTER_PORT = '9102'
        
        // Jenkins работает на порту 8100
        JENKINS_PORT = '8100'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 20, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('🔍 Environment Check') {
            steps {
                script {
                    echo "🚀 Starting Monitoring Stack CI/CD Pipeline"
                    echo "📅 Build Date: ${new Date()}"
                    echo "🏗️ Build Number: ${BUILD_NUMBER}"
                    echo "👤 User: RO8OT0V"
                    echo "🖥️ Server: Arch Linux (192.168.1.67)"
                }
                
                sh '''
                    echo "🔧 System Information:"
                    echo "🐳 Docker Version:"
                    docker --version
                    docker-compose --version
                    
                    echo "📊 System Resources:"
                    echo "💾 Disk Space:"
                    df -h | head -5
                    echo "🧠 Memory:"
                    free -h
                    echo "💻 CPU Cores:"
                    nproc
                    
                    echo "🌐 Network Connectivity:"
                    ping -c 2 8.8.8.8 || echo "⚠️ No internet connectivity"
                '''
            }
        }
        
        stage('🛑 Cleanup Previous') {
            steps {
                script {
                    echo "🧹 Cleaning up previous deployment..."
                    
                    sh '''
                        # Проверяем текущие контейнеры
                        echo "📋 Current containers:"
                        docker ps -a --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
                        
                        # Останавливаем мониторинг стек если запущен
                        if docker-compose ps -q 2>/dev/null | grep -q .; then
                            echo "🛑 Stopping existing monitoring stack..."
                            docker-compose down --remove-orphans || true
                        else
                            echo "✅ No existing stack found"
                        fi
                        
                        # Очищаем неиспользуемые ресурсы
                        echo "🗑️ Pruning unused Docker resources..."
                        docker system prune -f
                    '''
                }
            }
        }
        
        stage('📋 Configuration Validation') {
            parallel {
                stage('🔧 Docker Compose') {
                    steps {
                        sh '''
                            echo "🔍 Validating docker-compose.yml..."
                            if [ -f "docker-compose.yml" ]; then
                                docker-compose config -q
                                echo "✅ Docker Compose configuration is valid"
                            else
                                echo "❌ docker-compose.yml not found!"
                                exit 1
                            fi
                        '''
                    }
                }
                
                stage('📊 Prometheus Config') {
                    steps {
                        sh '''
                            echo "🔍 Validating Prometheus configuration..."
                            if [ -f "prometheus/prometheus.yml" ]; then
                                # Используем promtool для валидации
                                docker run --rm -v ${PWD}/prometheus:/etc/prometheus \\
                                    prom/prometheus:latest \\
                                    promtool check config /etc/prometheus/prometheus.yml
                                echo "✅ Prometheus configuration is valid"
                            else
                                echo "❌ prometheus/prometheus.yml not found!"
                                exit 1
                            fi
                        '''
                    }
                }
                
                stage('📈 Grafana Dashboards') {
                    steps {
                        sh '''
                            echo "🔍 Validating Grafana dashboards..."
                            dashboard_count=0
                            
                            if [ -d "grafana/dashboards" ]; then
                                for dashboard in grafana/dashboards/*.json; do
                                    if [ -f "$dashboard" ]; then
                                        echo "Validating: $(basename $dashboard)"
                                        python3 -m json.tool "$dashboard" > /dev/null
                                        dashboard_count=$((dashboard_count + 1))
                                    fi
                                done
                                echo "✅ Found and validated $dashboard_count dashboards"
                            else
                                echo "⚠️ No grafana/dashboards directory found"
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('🚀 Deploy Stack') {
            steps {
                script {
                    echo "🚀 Deploying monitoring stack..."
                    
                    sh '''
                        # Создаем необходимые директории и права
                        echo "📁 Creating directories and setting permissions..."
                        mkdir -p prometheus/data grafana/data
                        
                        # Устанавливаем права для Grafana и Prometheus
                        sudo chown -R 472:472 grafana/data 2>/dev/null || echo "⚠️ Could not set Grafana permissions"
                        sudo chown -R 65534:65534 prometheus/data 2>/dev/null || echo "⚠️ Could not set Prometheus permissions"
                        
                        # Запускаем стек
                        echo "🐳 Starting Docker Compose stack..."
                        docker-compose up -d --build
                        
                        echo "⏳ Waiting for services to initialize..."
                        sleep 45
                        
                        echo "📋 Container status:"
                        docker-compose ps
                    '''
                }
            }
        }
        
        stage('🩺 Health Checks') {
            parallel {
                stage('📊 Prometheus Health') {
                    steps {
                        script {
                            retry(3) {
                                sh '''
                                    echo "🔍 Checking Prometheus health..."
                                    
                                    # Проверяем готовность
                                    if curl -f -s http://localhost:${PROMETHEUS_PORT}/-/ready; then
                                        echo "✅ Prometheus is ready"
                                    else
                                        echo "❌ Prometheus not ready"
                                        exit 1
                                    fi
                                    
                                    # Проверяем targets
                                    targets=$(curl -s http://localhost:${PROMETHEUS_PORT}/api/v1/targets | jq '.data.activeTargets | length')
                                    echo "📈 Active targets: $targets"
                                    
                                    if [ "$targets" -ge 2 ]; then
                                        echo "✅ Prometheus has sufficient active targets"
                                    else
                                        echo "⚠️ Low number of active targets"
                                    fi
                                '''
                            }
                        }
                    }
                }
                
                stage('📈 Grafana Health') {
                    steps {
                        script {
                            retry(3) {
                                sh '''
                                    echo "🔍 Checking Grafana health..."
                                    
                                    # Проверяем API health
                                    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${GRAFANA_PORT}/api/health)
                                    
                                    if [ "$response" = "200" ]; then
                                        echo "✅ Grafana API is healthy"
                                    else
                                        echo "❌ Grafana health check failed: HTTP $response"
                                        exit 1
                                    fi
                                    
                                    # Проверяем datasources
                                    sleep 10
                                    datasources=$(curl -s -u admin:admin http://localhost:${GRAFANA_PORT}/api/datasources | jq '. | length' 2>/dev/null || echo "0")
                                    echo "🔗 Configured datasources: $datasources"
                                '''
                            }
                        }
                    }
                }
                
                stage('🖥️ Node Exporter Health') {
                    steps {
                        script {
                            retry(3) {
                                sh '''
                                    echo "🔍 Checking Node Exporter health..."
                                    
                                    # Проверяем метрики
                                    if curl -s http://localhost:${NODE_EXPORTER_PORT}/metrics | head -10 | grep -q "node_"; then
                                        echo "✅ Node Exporter is providing metrics"
                                    else
                                        echo "❌ Node Exporter metrics not available"
                                        exit 1
                                    fi
                                    
                                    metrics_count=$(curl -s http://localhost:${NODE_EXPORTER_PORT}/metrics | wc -l)
                                    echo "📊 Available metrics: $metrics_count"
                                '''
                            }
                        }
                    }
                }
            }
        }
        
        stage('🧪 Integration Tests') {
            steps {
                script {
                    echo "🧪 Running integration tests..."
                    
                    sh '''
                        echo "🔬 Integration Test Suite"
                        
                        # Test 1: Метрики собираются
                        echo "Test 1: Metrics Collection"
                        up_metrics=$(curl -s "http://localhost:${PROMETHEUS_PORT}/api/v1/query?query=up" | jq '.data.result | length')
                        if [ "$up_metrics" -gt 0 ]; then
                            echo "✅ UP metrics found: $up_metrics"
                        else
                            echo "❌ No UP metrics found"
                            exit 1
                        fi
                        
                        # Test 2: CPU метрики доступны
                        echo "Test 2: CPU Metrics"
                        cpu_metrics=$(curl -s "http://localhost:${PROMETHEUS_PORT}/api/v1/query?query=node_cpu_seconds_total" | jq '.data.result | length')
                        if [ "$cpu_metrics" -gt 0 ]; then
                            echo "✅ CPU metrics available: $cpu_metrics"
                        else
                            echo "❌ No CPU metrics found"
                        fi
                        
                        # Test 3: Дашборды загружены
                        echo "Test 3: Dashboard Check"
                        sleep 5
                        dashboards=$(curl -s -u admin:admin "http://localhost:${GRAFANA_PORT}/api/search" 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
                        echo "📊 Dashboards found: $dashboards"
                        
                        # Test 4: Алерты настроены
                        echo "Test 4: Alert Rules"
                        alert_rules=$(curl -s "http://localhost:${PROMETHEUS_PORT}/api/v1/rules" | jq '.data.groups | length')
                        if [ "$alert_rules" -gt 0 ]; then
                            echo "✅ Alert rules configured: $alert_rules groups"
                        else
                            echo "⚠️ No alert rules found"
                        fi
                        
                        echo "🎉 Integration tests completed!"
                    '''
                }
            }
        }
        
        stage('📊 Generate Report') {
            steps {
                sh '''
                    echo "📊 Generating deployment report..."
                    
                    # Создаем отчет (исправлены экранирования)
                    cat > deployment_report.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Monitoring Stack Deployment Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
        .info { color: blue; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>🚀 Monitoring Stack Deployment Report</h1>
EOF
                    
                    # Добавляем динамический контент
                    echo "    <p><strong>Deployment Date:</strong> $(date)</p>" >> deployment_report.html
                    echo "    <p><strong>Build Number:</strong> ${BUILD_NUMBER}</p>" >> deployment_report.html
                    echo "    <p><strong>User:</strong> RO8OT0V</p>" >> deployment_report.html
                    echo "    <p><strong>Server:</strong> Arch Linux (192.168.1.67)</p>" >> deployment_report.html
                    
                    # Добавляем таблицу сервисов
                    cat >> deployment_report.html << 'EOF'
    
    <h2>📋 Service Status</h2>
    <table>
        <tr><th>Service</th><th>Port</th><th>Status</th><th>URL</th></tr>
EOF
                    
                    echo "        <tr><td>Prometheus</td><td>${PROMETHEUS_PORT}</td><td class=\"success\">✅ Running</td><td><a href=\"http://192.168.1.67:${PROMETHEUS_PORT}\">http://192.168.1.67:${PROMETHEUS_PORT}</a></td></tr>" >> deployment_report.html
                    echo "        <tr><td>Grafana</td><td>${GRAFANA_PORT}</td><td class=\"success\">✅ Running</td><td><a href=\"http://192.168.1.67:${GRAFANA_PORT}\">http://192.168.1.67:${GRAFANA_PORT}</a></td></tr>" >> deployment_report.html
                    echo "        <tr><td>Node Exporter</td><td>${NODE_EXPORTER_PORT}</td><td class=\"success\">✅ Running</td><td><a href=\"http://192.168.1.67:${NODE_EXPORTER_PORT}\">http://192.168.1.67:${NODE_EXPORTER_PORT}</a></td></tr>" >> deployment_report.html
                    echo "        <tr><td>Jenkins</td><td>${JENKINS_PORT}</td><td class=\"info\">ℹ️ External</td><td><a href=\"http://192.168.1.67:${JENKINS_PORT}\">http://192.168.1.67:${JENKINS_PORT}</a></td></tr>" >> deployment_report.html
                    
                    # Завершаем HTML
                    cat >> deployment_report.html << 'EOF'
    </table>
    
    <h2>📊 System Metrics</h2>
    <p>All services deployed successfully and passing health checks.</p>
    
    <h2>🎯 Next Steps</h2>
    <ul>
        <li>Access Grafana dashboards</li>
        <li>Monitor system metrics</li>
        <li>Test alert notifications</li>
        <li>Take screenshots for portfolio</li>
    </ul>
</body>
</html>
EOF

                    echo "✅ Report generated: deployment_report.html"
                '''
                
                // Архивируем отчет
                archiveArtifacts artifacts: 'deployment_report.html', fingerprint: true
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '.',
                    reportFiles: 'deployment_report.html',
                    reportName: 'Deployment Report'
                ])
            }
        }
    }
    
    post {
        always {
            script {
                def currentDate = new Date().format("yyyy-MM-dd HH:mm:ss")
                echo "🏁 Pipeline completed at ${currentDate}"
                
                // Собираем логи
                sh '''
                    echo "📋 Collecting container logs..."
                    mkdir -p build_logs
                    docker-compose logs --tail=100 prometheus > build_logs/prometheus.log 2>&1 || true
                    docker-compose logs --tail=100 grafana > build_logs/grafana.log 2>&1 || true
                    docker-compose logs --tail=100 node-exporter > build_logs/node-exporter.log 2>&1 || true
                '''
                
                archiveArtifacts artifacts: 'build_logs/*.log', fingerprint: true, allowEmptyArchive: true
            }
        }
        
        success {
            echo '''
🎉 DEPLOYMENT SUCCESSFUL! 🎉

🌍 Your monitoring stack is now available:
📊 Prometheus: http://192.168.1.67:9100
📈 Grafana: http://192.168.1.67:9101 (admin/admin)
🖥️ Node Exporter: http://192.168.1.67:9102
🏗️ Jenkins: http://192.168.1.67:8100

🚀 DevOps Portfolio project successfully automated with Jenkins!
            '''
        }
        
        failure {
            echo '''
❌ DEPLOYMENT FAILED!

Check the build logs for details.
The monitoring stack may need manual intervention.
            '''
        }
    }
}
