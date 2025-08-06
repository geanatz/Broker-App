#!/usr/bin/env python3
"""
Script pentru eliminarea diacriticelor din toate fisierele din @lib/
Inlocuieste: ă/â -> a, ț -> t, ș -> s, î -> i
"""

import os
import re
from pathlib import Path

def remove_diacritics(text):
    """Inlocuieste diacriticele cu echivalentele fara diacritice"""
    replacements = {
        'ă': 'a', 'Ă': 'A',
        'â': 'a', 'Â': 'A', 
        'ț': 't', 'Ț': 'T',
        'ș': 's', 'Ș': 'S',
        'î': 'i', 'Î': 'I'
    }
    
    for diacritic, replacement in replacements.items():
        text = text.replace(diacritic, replacement)
    
    return text

def process_file(file_path):
    """Proceseaza un singur fisier"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        content = remove_diacritics(content)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Eroare la procesarea {file_path}: {e}")
        return False

def main():
    """Functia principala"""
    lib_dir = Path("lib")
    
    if not lib_dir.exists():
        print("Directorul lib/ nu exista!")
        return
    
    # Extensii de fisiere de procesat
    extensions = {'.dart', '.yaml', '.yml', '.json', '.md', '.txt'}
    
    files_processed = 0
    files_modified = 0
    
    print("Scanez fisierele din lib/ pentru diacritice...")
    
    for file_path in lib_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix in extensions:
            files_processed += 1
            if process_file(file_path):
                files_modified += 1
                print(f"Modificat: {file_path}")
    
    print(f"\nRezultat:")
    print(f"- Fisiere procesate: {files_processed}")
    print(f"- Fisiere modificate: {files_modified}")
    
    if files_modified > 0:
        print("Diacriticele au fost eliminate cu succes!")
    else:
        print("Nu s-au gasit diacritice in fisierele procesate.")

if __name__ == "__main__":
    main() 