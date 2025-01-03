if (( $+commands[myapictl] )); then
  # If the completion file does not exist, generate it and then source it
  # Otherwise, source it and regenerate in the background
  if [[ ! -f "$ZSH_CACHE_DIR/completions/_myapictl" ]]; then
    myapictl completion zsh | tee "$ZSH_CACHE_DIR/completions/_myapictl" >/dev/null
    source "$ZSH_CACHE_DIR/completions/_myapictl"
  else
    source "$ZSH_CACHE_DIR/completions/_myapictl"
    myapictl completion zsh | tee "$ZSH_CACHE_DIR/completions/_myapictl" >/dev/null &|
  fi
fi