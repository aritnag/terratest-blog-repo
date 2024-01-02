#!/bin/bash
find . -type f -name "*.tf" -exec terraform fmt {} \;
