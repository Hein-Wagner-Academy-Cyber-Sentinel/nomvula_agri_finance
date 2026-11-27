"""
This python script is to test the json structure 
determen if it is loaded propperly into RAM
"""

import json

try:
    with open("developer_config.json", "r", encoding="utf-8") as f:
        data = json.load(f)
        print(f"{data} loaded successfulley!")
except json.JSONDecodeError as err:
    print(f"Syntax Error in JSON: {err.msg} at line {err.lineno}, column {err.colno}")
