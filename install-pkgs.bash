#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run with sudo or as root." >&2
  exit 1
fi
