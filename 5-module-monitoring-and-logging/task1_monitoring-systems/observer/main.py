import json
import time
import os
from datetime import date

LOG_DIR = "/home/a/_git/learnanddowhatyoulearn/2026/learn-and-do-what-you-learn/5-module-monitoring-and-logging/task1_monitoring-systems/observer/logs"

def get_cpu_times():
    with open('/proc/stat', 'r') as f:
        first_line = f.readline()
    # Разбиваем строку и берем только числовые значения (первые 7 полей)
    fields = [float(x) for x in first_line.split()[1:8]]
    
    idle_time = fields[3] + fields[4] # idle + iowait
    total_time = sum(fields)
    return idle_time, total_time

def get_cpu_usage():
  # Замер 1
  idle1, total1 = get_cpu_times()
  time.sleep(1)
  # Замер 2
  idle2, total2 = get_cpu_times()

  # Считаем разницу
  delta_idle = idle2 - idle1
  delta_total = total2 - total1

  return {"cpu_usage_percent": f"{(1.0 - (delta_idle / delta_total)) * 100:.2f} %"}

def get_mem_usage():
  mem_info = {}
  with open('/proc/meminfo', 'r') as f:
    for line in f:
      parts = line.split()
      if (len(parts)) < 2:
        return
      key = parts[0].strip(":")
      mem_info[key] = float(parts[1])

  total_kb = mem_info.get("MemTotal", 0)
  free_kb = mem_info.get("MemFree", 0)
  buffers_kb = mem_info.get("Buffers", 0)
  cached_kb = mem_info.get("Cached", 0)
  available_kb = free_kb + buffers_kb + cached_kb
  used_kb = total_kb - available_kb
  percent = (used_kb / total_kb) * 100 if total_kb > 0 else 0

  return {"mem_usage_percent": f"{percent:.2f} %"}

def get_disks_usage(path = '/'):
  st = os.statvfs(path)
  total = st.f_blocks

  return {"disk_usage_percent": f"{((st.f_blocks - st.f_bavail) / total) * 100 if total > 0 else 0 :.2f} %"}

def get_net_stat():
  res = {}
  with open("/proc/net/dev") as f:
    lines = f.readlines()
    for i in range(2, len(lines)):
      parts = lines[i].split()
      if parts[0].strip(":").find('wlp') == -1:
        continue
      res["received_mb"]        = f"{(float(parts[1])/1024):.2f} MB"
      res["received_errors"]    = parts[3]
      res["transmitted_mb"]     = f'{float(parts[9]) / 1024:.2f} MB'
      res["transmitted_errors"] = parts[11]
  return res

def collect_metrics():
  return {"time": time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),
          "hostname": 'a-pc',
        **get_cpu_usage() |
        get_mem_usage() |
        get_disks_usage() |
        get_net_stat() }

def write_stat():
  os.makedirs(LOG_DIR, exist_ok=True)
  fname = f"{LOG_DIR}/{date.today().isoformat()}-aynurs-awesome.log"
  with open(fname, 'a', encoding="utf-8") as f:
    metrics = collect_metrics()
    f.write(json.dumps(metrics) + '\n')

if __name__ == '__main__':
  write_stat()
