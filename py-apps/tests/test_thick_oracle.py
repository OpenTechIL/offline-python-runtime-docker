import oracledb
import sys
import os

#/opt/oracle/instantclient_19_29
oracle_instantclient_path = os.environ["ORACLE_INSTANTCLIENT_PATH"]

def test_env_var_is_set():
    assert oracle_instantclient_path

def test_verify_packages():
    try:
        oracledb.init_oracle_client(lib_dir=oracle_instantclient_path) 
    except Exception as e:
        print(f"\n ❌ Error init oracle client - check the instantclient path \n\n ERR:\n{e}")
        sys.exit(1) # Exit with error to stop Docker build/run
    
if __name__ == "__main__":
    test_verify_packages()