#!/bin/bash
#
# Bootstrap script for AnythingLLM in docker-ai-stack
# Reads the LiteLLM API key from the shared volume and starts AnythingLLM
#
# This file is part of Docker AI Stack:
# https://github.com/hwdsl2/docker-ai-stack

# Read LiteLLM API key from shared volume (if available)
if [ -f /var/lib/litellm-shared/.api_key ]; then
  export GENERIC_OPEN_AI_API_KEY=$(cat /var/lib/litellm-shared/.api_key)
fi

# Start AnythingLLM using the original entrypoint
exec /usr/local/bin/docker-entrypoint.sh