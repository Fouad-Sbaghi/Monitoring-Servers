#!/usr/bin/env python3
import psutil
import time

cpu_usage = psutil.cpu_percent(interval=1)
print(f"TIMESTAMP:{int(time.time())}|CPU:{cpu_usage}%")
