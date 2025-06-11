#### 1. 🚀 Главный дашборд
**URL**: `http://localhost:9101/d/`
**Описание**: Дашборд мониторинга с статусом сервисов
- Таблица статуса сервисов
- Шкалы использования CPU, памяти, диска
- Индикатор загрузки системы
![image](https://github.com/user-attachments/assets/98170146-f85b-4728-ab9c-596605a2cbba)

#### 2. 🔥 Система алертов в действии
**URL**: `http://localhost:9100/alerts`
**Описание**: Алерты Prometheus во время стресс-теста
- Алерт HighCPUUsage (красный статус)
- Детали алерта и пороговые значения
- Активные правила мониторинга
![image](https://github.com/user-attachments/assets/dbdcc46c-fd4f-4ee0-95af-5389533cca8e)
![image](https://github.com/user-attachments/assets/5384d915-286b-475e-9631-f84ee0f1b51a)

#### 3. 📊 Дашборд Grafana под нагрузкой
**URL**: `http://localhost:9101/d/system-overview`
**Описание**: Метрики в реальном времени во время CPU стресс-теста:
- Шкала CPU показывает >90% (красный порог)
- Графики временных рядов с пиками
- Память и диск стабильные (зелёные)
![image](https://github.com/user-attachments/assets/d22cb4f5-af20-49d4-8253-ad84b57bde1c)

#### 4. 🎯 Здоровье целей Prometheus
**URL**: `http://localhost:9100/targets`
**Описание**: Все цели мониторинга здоровы
- prometheus (1/1 up)
- node-exporter (1/1 up)
- Все эндпоинты зелёного статуса
![image](https://github.com/user-attachments/assets/6d55bcc3-8554-43d7-840b-2793dbbbfa4a)
