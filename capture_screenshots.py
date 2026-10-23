# capture_screenshots.py
# Captures high-resolution, genuine screenshots from the running LoanWiser Shiny dashboard
# using Chrome DevTools Protocol (CDP).

import os
import time
import json
import base64
import subprocess
import urllib.request
import websocket

SCREENSHOTS_DIR = os.path.abspath("screenshots")
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

CHROME_PATH = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
PORT = 9222
APP_URL = "http://127.0.0.1:7890"

# 1. Start Chrome with remote debugging
chrome_cmd = [
    CHROME_PATH,
    "--headless=new",
    "--disable-gpu",
    f"--remote-debugging-port={PORT}",
    "--remote-allow-origins=*",
    "--window-size=1600,1050",
    "--hide-scrollbars",
    APP_URL
]

print("Starting headless Chrome...")
proc = subprocess.Popen(chrome_cmd)
time.sleep(3)

try:
    # 2. Get webSocketDebuggerUrl
    targets_url = f"http://127.0.0.1:{PORT}/json"
    with urllib.request.urlopen(targets_url) as resp:
        targets = json.loads(resp.read().decode())
    
    ws_url = None
    for t in targets:
        if t.get("type") == "page":
            ws_url = t["webSocketDebuggerUrl"]
            break
            
    if not ws_url:
        ws_url = targets[0]["webSocketDebuggerUrl"]
        
    print(f"Connecting to CDP: {ws_url}")
    ws = websocket.create_connection(ws_url, timeout=15)
    
    msg_id = 0
    def send_cdp(method, params=None):
        global msg_id
        msg_id += 1
        payload = {"id": msg_id, "method": method, "params": params or {}}
        ws.send(json.dumps(payload))
        while True:
            res = json.loads(ws.recv())
            if res.get("id") == msg_id:
                return res.get("result", {})

    # Wait for Shiny to fully initialize
    print("Waiting for Shiny app reactive rendering...")
    time.sleep(4)
    
    tabs = [
        ("01_executive_dashboard", "tab_dashboard", "Executive Dashboard"),
        ("02_applicant_profile", "tab_profile", "Applicant Profiling"),
        ("03_loan_analysis", "tab_loan_analysis", "Loan Analysis & Debt Solvency"),
        ("04_risk_assessment", "tab_risk", "Risk Classification Engine"),
        ("05_ml_prediction", "tab_ml", "Machine Learning Prediction"),
        ("06_whatif_simulation", "tab_whatif", "Interactive What-If Simulation"),
        ("07_eda_analysis", "tab_eda", "Exploratory Data Analysis"),
        ("08_amortization_schedule", "tab_amortization", "Amortization Ledger"),
        ("09_model_performance", "tab_performance", "Model Performance & Benchmarks"),
        ("10_about_project", "tab_about", "Academic Specification & Architecture")
    ]
    
    for filename, tab_id, label in tabs:
        print(f"Navigating to tab: {label} ({tab_id})...")
        # Click the tab using jQuery/JavaScript
        js_click = f"""
        (function() {{
            var link = document.querySelector('a[data-value="{tab_id}"]');
            if (link) {{
                link.click();
                return true;
            }}
            return false;
        }})()
        """
        eval_res = send_cdp("Runtime.evaluate", {"expression": js_click})
        time.sleep(2.0) # Allow reactive charts/Plotly/DT to settle
        
        # Capture screenshot
        shot = send_cdp("Page.captureScreenshot", {"format": "png"})
        img_data = base64.b64decode(shot["data"])
        out_path = os.path.join(SCREENSHOTS_DIR, f"{filename}.png")
        with open(out_path, "wb") as f:
            f.write(img_data)
        print(f" -> Saved {out_path} ({len(img_data):,} bytes)")

    print("\nAll 10 dashboard tab screenshots successfully captured!")

finally:
    try:
        ws.close()
    except Exception:
        pass
    proc.terminate()
    print("Headless Chrome terminated.")
