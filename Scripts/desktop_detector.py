import time
import subprocess
import ctypes
import os

# --- CONFIGURATION ---
# The process to monitor
APP_NAME = "steam.exe"
# Path to the recovery script (using raw strings to handle backslashes)
SCRIPT_PATH = r"C:\Scripts\shell_desktop.bat"
# ---------------------

def is_process_running(process_name):
    """
    Checks if the specified process is running using 'tasklist'.
    Configured to run silently without spawning a command window.
    """
    try:
        # Prevent the tasklist command window from popping up
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        
        # Execute tasklist with a filter on the image name
        output = subprocess.check_output(
            f'tasklist /FI "IMAGENAME eq {process_name}"', 
            startupinfo=startupinfo,
            universal_newlines=True
        )
        # Check if the process name exists in the output string
        if process_name.lower() in output.lower():
            return True
    except Exception:
        pass
    return False

def run_script_as_admin_hidden(bat_path):
    """
    Launches the .bat script with Administrative privileges (runas)
    and in a completely hidden window state (SW_HIDE).
    """
    # ShellExecuteW Parameters:
    # None: No parent window
    # "runas": Requests elevated Administrative privileges
    # "cmd.exe": The command interpreter
    # f'/c "{bat_path}"': Command argument to execute the script and terminate
    # None: Default working directory
    # 0: SW_HIDE (Runs the batch file invisibly)
    
    cmd_params = f'/c "{bat_path}"'
    ctypes.windll.shell32.ShellExecuteW(None, "runas", "cmd.exe", cmd_params, None, 0)

# --- MAIN MONITORING LOOP ---

# 1. Idle wait while Steam is active
# The script stays in this loop as long as the process is detected
while is_process_running(APP_NAME):
    time.sleep(3) # 3-second polling interval

# 2. Trigger Recovery
# Once the loop exits (Steam closed), launch the recovery script silently
run_script_as_admin_hidden(SCRIPT_PATH)