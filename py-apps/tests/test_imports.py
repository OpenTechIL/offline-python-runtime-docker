# check_imports.py
import importlib
import sys

# List the packages you want to verify
packages = ["oracledb", "pytest"]

def test_verify_packages():
    missing = []
    for pkg in packages:
        try:
            importlib.import_module(pkg)
            print(f"✅ {pkg} loaded successfully.")
            
        except ImportError:
            print(f"❌ {pkg} failed to load.")
            missing.append(pkg)
    
    if missing:
        print(f"\nTotal missing/broken: {len(missing)}")
        sys.exit(1) # Exit with error to stop Docker build/run
    else:
        print("\nAll packages are healthy!")

if __name__ == "__main__":
    test_verify_packages()