import os
import pandas as pd
import re

# 获取所有 m5out_* 目录
base_dir = "./"  # 你的代码路径
output_dirs = [d for d in os.listdir(base_dir) if d.startswith("m5out_m")]

# 定义用于提取数据的正则表达式
cycle_pattern = re.compile(r"system.cpu.numCycles\s+(\d+)")
instruction_pattern = re.compile(r"system.cpu.commit.committedInsts\s+(\d+)")
thread_cycle_pattern = re.compile(r"system.cpu.thread(\d+).numCycles\s+(\d+)")
thread_instruction_pattern = re.compile(r"system.cpu.thread(\d+).commit.committedInsts\s+(\d+)")

# 遍历每个输出目录
for out_dir in output_dirs:
    stats_file = os.path.join(base_dir, out_dir, "stats.txt")

    if not os.path.exists(stats_file):
        print(f"Warning: {stats_file} not found!")
        continue

    # 读取 stats.txt
    with open(stats_file, "r") as file:
        stats_data = file.readlines()

    # 解析数据
    total_cycles = None
    total_instructions = None
    thread_cycles = {}
    thread_instructions = {}

    for line in stats_data:
        cycle_match = cycle_pattern.search(line)
        instruction_match = instruction_pattern.search(line)
        thread_cycle_match = thread_cycle_pattern.search(line)
        thread_instruction_match = thread_instruction_pattern.search(line)

        if cycle_match:
            total_cycles = int(cycle_match.group(1))
        elif instruction_match:
            total_instructions = int(instruction_match.group(1))
        elif thread_cycle_match:
            thread_id = int(thread_cycle_match.group(1))
            thread_cycles[thread_id] = int(thread_cycle_match.group(2))
        elif thread_instruction_match:
            thread_id = int(thread_instruction_match.group(1))
            thread_instructions[thread_id] = int(thread_instruction_match.group(2))

    # 创建 DataFrame
    df = pd.DataFrame(columns=["Thread ID", "Nombre des cycles", "Nombre des instructions"])

    # 添加应用程序的总执行数据
    df = df.append({"Thread ID": "L'application", "Nombre des cycles": total_cycles, "Nombre des instructions": total_instructions}, ignore_index=True)

    # 添加线程数据
    for thread_id in sorted(thread_cycles.keys()):
        df = df.append({
            "Thread ID": f"Thread {thread_id}",
            "Nombre des cycles": thread_cycles.get(thread_id, 0),
            "Nombre des instructions": thread_instructions.get(thread_id, 0)
        }, ignore_index=True)

    # 将表格保存为 CSV
    csv_filename = f"{out_dir}.csv"
    df.to_csv(csv_filename, index=False)
    print(f"Saved table: {csv_filename}")

print("All tables have been generated and saved as CSV files!")
