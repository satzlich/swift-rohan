import os

def process_swift_files(directory):
    copyright_line = "// Copyright 2024-2025 Lie Yan"
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".swift"):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r+', encoding='utf-8') as f:
                        lines = f.readlines()
                        
                        # Check if first two lines match our pattern
                        if len(lines) >= 2 and lines[0].strip() == copyright_line and lines[1].strip() == "":
                            # Remove first two lines
                            new_content = ''.join(lines[2:])
                            f.seek(0)
                            f.write(new_content)
                            f.truncate()
                            print(f"Removed copyright from: {file_path}")
                except Exception as e:
                    print(f"Error processing {file_path}: {str(e)}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python script.py <directory>")
        sys.exit(1)
    
    directory = sys.argv[1]
    if not os.path.isdir(directory):
        print(f"Error: {directory} is not a valid directory")
        sys.exit(1)
    
    process_swift_files(directory)
    print("Processing complete.")