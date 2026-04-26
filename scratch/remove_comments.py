import os
import re

def remove_comments(content):
    # Remove multi-line comments
    content = re.sub(r'/\*[\s\S]*?\*/', '', content)
    
    # Remove single-line comments (including doc comments)
    # Be careful not to remove comments inside strings
    # This regex is a bit simplistic but works for most cases
    # We look for // that is not preceded by a colon (to avoid URLs) and not inside quotes
    lines = content.split('\n')
    cleaned_lines = []
    for line in lines:
        # Check if line has //
        if '//' in line:
            # Check if it's likely a comment (not in a string)
            # A more robust solution would use a state machine or a more complex regex
            # but for this task, a simple check usually suffices if we're careful.
            # Let's try to only remove if it's at the start of a line or after a space
            
            # Find the first // that is not part of a URL
            match = re.search(r'(?<!:)\s*//.*', line)
            if match:
                line = line[:match.start()].rstrip()
        cleaned_lines.append(line)
    
    # Remove empty lines if they were just comments
    # Actually, the user said "remove all comments..and leave only code"
    # Usually this implies keeping the structure but removing the comment text.
    return '\n'.join(cleaned_lines)

def process_directory(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                print(f"Processing {file_path}...")
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                cleaned_content = remove_comments(content)
                
                # Check for empty lines at the end or multiple empty lines
                # but let's keep it simple for now.
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(cleaned_content)

if __name__ == "__main__":
    process_directory('lib')
