#!/bin/bash
minikube pause -A
echo "System will shut down in 15 seconds. Press Ctrl + C to cancel"
sleep 15
shutdown -h now
