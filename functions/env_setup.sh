DIR='./envs/slowing_bar_hpc1'
reqs='./envs/requirements.txt'
temp='./envs/temp.txt'

check_condition() {
    # If env is set up properly, returns true
    pip freeze > "$temp"
    if diff "$reqs" "$temp" > /dev/null; then
        echo "Enviroment set."
        return 0 # true
    else
        echo "Enviroment not set."
        return 1 # false
    fi
}

# Sets all other nodes except 0 to wait
if [ "$SLURM_ARRAY_TASK_ID" -ne 0 ]; then
    sleep 20
fi

# If env does not exist, it is created
if [ ! -d "$DIR" ] && [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then
    echo "Env does not exist creating dir"
    python3 -m venv "$DIR"
fi

# Activates env
source "$DIR/bin/activate"

# Check if the environment is set up correctly
if ! check_condition; then
    if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then
        echo "Setting up environment..."
        pip install -r "$reqs" > /dev/null 2>&1
    else
        while true; do
            if check_condition; then
                echo "ENV Installed"
                break
            else 
                echo "ENV Installing"
            fi
            echo "sleep 30"
            sleep 30
        done
    fi
fi

echo "Environment Setup Complete"
