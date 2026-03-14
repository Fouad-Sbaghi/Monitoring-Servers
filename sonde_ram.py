#!/usr/bin/env python3

import psutil
import time
mem = psutil.virtual_memory()
print(f"TIMESTAMP:{int(time.time())}|RAM:{mem.percent}%")