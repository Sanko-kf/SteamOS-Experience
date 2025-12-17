import time
import win32api
import subprocess
import os

# --- PATH CONFIGURATION ---
# The 'r' prefix denotes a raw string, handling Windows backslashes correctly.
SCRIPTS_FOLDER = r"C:\Scripts"

# Construct absolute paths using os.path.join for reliability
BAT_FILE_INACTIVE = os.path.join(SCRIPTS_FOLDER, 'sleep_mode.bat')
BAT_FILE_ACTIVE = os.path.join(SCRIPTS_FOLDER, 'stop_sleep.bat')

# --- SETTINGS ---
# Inactivity threshold in seconds before triggering sleep mode
INACTIVITY_THRESHOLD = 300  # 5 minutes

def get_idle_time():
    """
    Calculates the time elapsed since the last user input (keyboard/mouse).
    
    Returns:
        float: Idle time in seconds.
    """
    # GetTickCount returns milliseconds since system startup.
    # GetLastInputInfo returns milliseconds since the last input event.
    return (win32api.GetTickCount() - win32api.GetLastInputInfo()) / 1000

def execute_bat(file_path):
    """
    Executes a Windows Batch (.bat) file silently in the background.
    
    Args:
        file_path (str): The absolute path to the batch file.
    """
    if os.path.exists(file_path):
        try:
            # creationflags=0x08000000 maps to CREATE_NO_WINDOW.
            # This is critical: it prevents a black command prompt window from 
            # flashing over the application (e.g., Steam) when the script runs.
            subprocess.Popen(file_path, creationflags=0x08000000, shell=True)
            print(f"Successfully executed: {file_path}")
        except Exception as e:
            print(f"Error executing {file_path}: {e}")
    else:
        print(f"File not found: {file_path}")

def main():
    """
    Main monitoring loop.
    Checks user activity state every second and triggers batch scripts on state change.
    """
    # State flag to prevent repetitive execution of the same script
    is_inactive = False
    print("Monitoring system idle time...")

    while True:
        try:
            idle_time = get_idle_time()

            # TRANSITION: Active -> Inactive
            if idle_time >= INACTIVITY_THRESHOLD and not is_inactive:
                print(f"Idle threshold reached ({idle_time}s). Engaging sleep mode.")
                execute_bat(BAT_FILE_INACTIVE)
                is_inactive = True
            
            # TRANSITION: Inactive -> Active
            elif idle_time < INACTIVITY_THRESHOLD and is_inactive:
                print("User activity detected. Disengaging sleep mode.")
                execute_bat(BAT_FILE_ACTIVE)
                is_inactive = False

            # Check frequency: 1 second
            time.sleep(1)
            
        except Exception as e:
            print(f"Error in monitoring loop: {e}")
            # Wait longer on error to prevent log spamming
            time.sleep(5)

if __name__ == "__main__":
    main()