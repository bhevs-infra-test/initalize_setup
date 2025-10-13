#!/bin/bash

TARGET_HOST="controller"
PLAYBOOK_FILE="playbook.yml"

echo "--- START: Ansible Playbook Checks ---"

# 1. PING and Sudo Access Check
echo "--- 1/3: PING/SUDO check..."
ansible ${TARGET_HOST} -m ping --become > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ FAILED: PING/SUDO ACCESS failed."
    exit 1
fi
echo "✅ SUCCESS: PING/SUDO ACCESS verified."

# 2. Playbook Syntax Check
echo "--- 2/3: Syntax check..."
ansible-playbook ${PLAYBOOK_FILE} --syntax-check > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ FAILED: Playbook SYNTAX failed."
    exit 1
fi
echo "✅ SUCCESS: Syntax check passed."

# 3. Dry Run (Check for Changes)
echo "--- 3/3: Dry Run check (Previewing changes)..."
ansible-playbook ${PLAYBOOK_FILE} --check > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ FAILED: Dry Run (Check) failed."
    exit 1
fi
echo "✅ SUCCESS: Dry Run completed."

echo "--- FINISH: All checks passed. Ready for execution. ---"
