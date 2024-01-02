#!/bin/bash

# Find and stop all running Terraform processes
echo "Stopping all Terraform processes..."

# Use pkill to find and terminate Terraform processes
pkill -f "terraform"

echo "All Terraform processes have been terminated."
