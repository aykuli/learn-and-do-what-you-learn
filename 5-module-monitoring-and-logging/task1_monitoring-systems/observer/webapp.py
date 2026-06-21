import os
import json
from flask import Flask, render_template_string

app = Flask(__name__)

# Path to your log file
LOG_FILE_PATH = "/home/a/_git/learnanddowhatyoulearn/2026/learn-and-do-what-you-learn/5-module-monitoring-and-logging/task1_monitoring-systems/observer/logs/2026-06-21-aynurs-awesome.log"

# Inline HTML template with Bootstrap for a clean dashboard look
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Monitor Observer Logs</title>
    <link href="https://bootcdn.net" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container my-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="h2 text-dark">🖥️ System Monitor Observer Logs</h1>
            <span class="badge bg-secondary fs-6">Host: {{ hostname }}</span>
        </div>
        
        <div class="card shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table border="1" cellpadding="10" cellspacing="0">
                        <thead class="table-dark">
                            <tr>
                                <th>Timestamp</th>
                                <th>CPU Usage</th>
                                <th>Memory Usage</th>
                                <th>Disk Usage</th>
                                <th>Rx (MB) / Errs</th>
                                <th>Tx (MB) / Errs</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for log in logs %}
                            <tr>
                                <td class="fw-bold text-muted">{{ log.time }}</td>
                                <td><span class="badge bg-primary">{{ log.cpu_usage_percent }}</span></td>
                                <td><span class="badge bg-info text-dark">{{ log.mem_usage_percent }}</span></td>
                                <td>{{ log.disk_usage_percent }}</td>
                                <td>{{ log.received_mb }} <small class="text-danger">({{ log.received_errors }} errs)</small></td>
                                <td>{{ log.transmitted_mb }} <small class="text-danger">({{ log.transmitted_errors }} errs)</small></td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
"""

def read_json_lines_log(filepath):
    logs = []
    if not os.path.exists(filepath):
        return logs
    
    with open(filepath, "r", encoding="utf-8") as file:
        i = 0
        for line in file:
            i = i + 1
            line = line.strip()
            print("---------")
            print(json.loads(line))
            print("----------------------")
            if line:  # Skip empty lines
                try:
                    logs.append(json.loads(line))
                except json.JSONDecodeError:
                    continue  # Skip corrupted lines
    return logs

@app.route("/")
def index():
    logs = read_json_lines_log(LOG_FILE_PATH)
    # Reverse logs to show the newest entries at the top of the webpage
    logs.reverse() 
    print("logs---------")
    print(logs)
    
    # Get hostname from the first available log entry
    hostname = logs[0].get("hostname", "Unknown") if logs else "N/A"
    
    return render_template_string(HTML_TEMPLATE, logs=logs, hostname=hostname)

if __name__ == "__main__":
    # Runs the web app on localhost port 5000
    app.run(host="127.0.0.1", port=5000, debug=True)
