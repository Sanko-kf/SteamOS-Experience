import subprocess

def run_batch_script_silently():
    """
    Executes a Windows Batch (.bat) script in the background without 
    triggering a visible console window.

    This function utilizes the Windows-specific 'CREATE_NO_WINDOW' flag
    to ensure the process runs completely silently, preventing the 
    command prompt from popping up and stealing focus.
    """
    
    # Absolute path to the target batch script
    # Using a raw string (r"...") to handle Windows backslashes correctly
    bat_path = r"C:\Scripts\start_BigPicture.bat"

    # Construct the command arguments list
    # cmd.exe : The Windows Command Processor
    # /c      : Carries out the command specified by string and then terminates
    command = ["cmd.exe", "/c", bat_path]

    # flag: CREATE_NO_WINDOW
    # Value 0x08000000 allows the process to run without creating a console window
    # This is specific to the Windows OS
    CREATE_NO_WINDOW = 0x08000000

    try:
        # Popen is used here instead of run() or call() to allow asynchronous execution
        # creationflags applies the specific Windows flag to hide the UI
        subprocess.Popen(command, creationflags=CREATE_NO_WINDOW)
        
    except FileNotFoundError:
        print(f"Error: The file at {bat_path} was not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    run_batch_script_silently()