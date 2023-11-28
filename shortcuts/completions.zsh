# Define a function to perform the completion
_cluster_jobs() {
  local -a suggestions
  local cur="${LBUFFER##* }"
  
  
  # Get Job numbers and names
  local job_ids_raw=("${(@f)$(squeue --user $USER -o "%A (%j)" --noheader)}")
  
  # Extract only the job ID numbers
  local job_ids=("${(@)job_ids_raw//[^0-9]*/}")
  
  
  # Filter based on what the user has typed
  suggestions=()
  for id in "${job_ids[@]}"; do
    if [[ "$id" == "$cur"* ]]; then
      suggestions+=("$id")
    fi
  done
  

    if [ ${#suggestions[@]} -eq 1 ]; then
    # if there's only one match, respond with only the job number
    compadd "${suggestions[1]}"
    elif [ ${#suggestions[@]} -gt 1 ]; then
    # more than one suggestion resolved,
    # respond with the suggestions intact
    compadd -a suggestions
    fi
    }

# Register the completion function for the scancel command
compdef _cluster_jobs scancel