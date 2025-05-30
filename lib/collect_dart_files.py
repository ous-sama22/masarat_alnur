import os

def collect_dart_files(output_file):
    # Get the current working directory
    root_dir = os.getcwd()
    
    # Open the output file in write mode
    with open(output_file, 'w', encoding='utf-8') as outfile:
        # Walk through all directories and subdirectories
        for dirpath, dirnames, filenames in os.walk(root_dir):
            # Filter for .dart files
            dart_files = [f for f in filenames if f.endswith('.dart')]
            
            # Process each dart file
            for dart_file in dart_files:
                full_path = os.path.join(dirpath, dart_file)
                # Create relative path for cleaner output
                relative_path = os.path.relpath(full_path, root_dir)
                
                try:
                    # Read the content of the dart file
                    with open(full_path, 'r', encoding='utf-8') as file:
                        content = file.read()
                    
                    # Write to output file in specified format
                    outfile.write(f"{relative_path}:\n")
                    outfile.write(f"\"{content}\"\n")
                    outfile.write("\n--------------------\n")
                except Exception as e:
                    print(f"Error processing {full_path}: {str(e)}")

if __name__ == "__main__":
    output_file = "dart_files_content.txt"
    collect_dart_files(output_file)
    print(f"Processing complete. Results saved to {output_file}")