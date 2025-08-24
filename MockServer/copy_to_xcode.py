#!/usr/bin/env python3
"""
Script to copy generated mock data to Xcode project
"""
import os
import shutil
import json
import argparse
from pathlib import Path

def copy_mock_data_to_xcode(source_dir, target_dir, file_pattern="*.json"):
    """
    Copy mock data files to Xcode project directory
    """
    source_path = Path(source_dir)
    target_path = Path(target_dir)
    
    if not source_path.exists():
        print(f"❌ Source directory does not exist: {source_path}")
        return []
    
    # Create target directory if it doesn't exist
    target_path.mkdir(parents=True, exist_ok=True)
    
    copied_files = []
    
    # Find all JSON files in source directory
    for file_path in source_path.glob(file_pattern):
        if file_path.is_file():
            target_file = target_path / file_path.name
            
            # Copy the file
            shutil.copy2(file_path, target_file)
            print(f"📁 Copied {file_path.name} to {target_path}")
            copied_files.append(target_file)
    
    return copied_files

def print_xcode_instructions(files_copied):
    """
    Print instructions for adding files to Xcode
    """
    if not files_copied:
        return
    
    print("\n" + "="*60)
    print("📱 XCODE INTEGRATION INSTRUCTIONS")
    print("="*60)
    print("To add these files to your Xcode project:")
    print()
    print("1. Open your Xcode project")
    print("2. Right-click on the 'Resources/MockData' folder in the navigator")
    print("3. Select 'Add Files to F1Vision'")
    print("4. Navigate to and select the copied files:")
    
    for file_path in files_copied:
        print(f"   • {file_path.name}")
    
    print()
    print("5. Make sure 'Add to target: F1Vision' is checked")
    print("6. Click 'Add'")
    print()
    print("The files will now appear in your Xcode project navigator!")
    print("="*60)

def main():
    parser = argparse.ArgumentParser(description='Copy mock data to Xcode project')
    parser.add_argument('--source', default='./raceData', help='Source directory (default: ./raceData)')
    parser.add_argument('--target', default='../F1Vision/Resources/MockData/Race', help='Target directory in Xcode project')
    parser.add_argument('--pattern', default='*.json', help='File pattern to copy (default: *.json)')
    parser.add_argument('--type', choices=['race', 'track', 'all'], default='race', help='Type of data to copy')
    
    args = parser.parse_args()
    
    # Determine source and target based on type
    if args.type == 'race':
        source_dir = './raceData'
        target_dir = '../F1Vision/Resources/MockData/Race'
    elif args.type == 'track':
        source_dir = './trackData'
        target_dir = '../F1Vision/Resources/MockData/Track'
    elif args.type == 'all':
        # Copy both race and track data
        print("🔄 Copying all mock data...")
        
        # Copy race data
        race_files = copy_mock_data_to_xcode('./raceData', '../F1Vision/Resources/MockData/Race', '*.json')
        
        # Copy track data
        track_files = copy_mock_data_to_xcode('./trackData', '../F1Vision/Resources/MockData/Track', '*.json')
        
        all_files = race_files + track_files
        
        # Print instructions
        print_xcode_instructions(all_files)
        return
    
    # Copy files
    print(f"📁 Copying {args.type} data from {source_dir} to {target_dir}...")
    copied_files = copy_mock_data_to_xcode(source_dir, target_dir, args.pattern)
    
    if copied_files:
        print(f"✅ Successfully copied {len(copied_files)} files")
        print_xcode_instructions(copied_files)
    else:
        print("ℹ️  No files were copied")

if __name__ == "__main__":
    main()
