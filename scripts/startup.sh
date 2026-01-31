#!/bin/bash

# --- 1. Colors for pretty output ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting DevOps Environment...${NC}"

# --- 2. Start Minikube (if not running) ---
if ! minikube status | grep -q "Running"; then
    echo -e "${BLUE}📦 Starting Minikube...${NC}"
    minikube start
else
    echo -e "${GREEN}✅ Minikube is already running.${NC}"
fi

# --- 3. Start Jenkins (Docker) ---
echo -e "${BLUE}🐳 Starting Jenkins Container...${NC}"
docker start jenkins > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Jenkins started.${NC}"
else
    echo -e "⚠️  Jenkins container not found or error starting."
fi

# --- 4. Port Forwarding (The Magic Part) ---
echo -e "${BLUE}🔌 Establishing Port Forwarding Tunnels...${NC}"

# ArgoCD Tunnel (Port 8081)
kubectl port-forward svc/argocd-server -n argocd 8081:443 > /dev/null 2>&1 &
PID_ARGO=$!

# Grafana Tunnel (Port 3000)
kubectl port-forward svc/my-monitoring-grafana -n monitoring 3000:80 > /dev/null 2>&1 &
PID_GRAF=$!

# Prometheus Tunnel (Port 9090) <--- NEW!
kubectl port-forward svc/my-monitoring-kube-prometh-prometheus -n monitoring 9090:9090 > /dev/null 2>&1 &

# Node App Tunnel (Port 3001)
kubectl port-forward svc/node-app-service 3001:80 > /dev/null 2>&1 &
PID_APP=$!

# Wait a few seconds for tunnels to establish
sleep 5

# --- 5. Display Dashboard ---
echo -e "\n${GREEN}🎉 ENVIRONMENT READY! 🎉${NC}"
echo "---------------------------------------------------"
echo -e "🔧 Jenkins:     http://localhost:8080"
echo -e "🐙 ArgoCD:      https://localhost:8081"
echo -e "📊 Grafana:     http://localhost:3000"
echo -e "🔥 Prometheus:  http://localhost:9090"
echo -e "🌍 Node App:    http://localhost:3001"
echo "---------------------------------------------------"
echo -e "${BLUE}Press [CTRL+C] to stop the tunnels and exit.${NC}"

# --- 6. Cleanup Function (Runs when you hit Ctrl+C) ---
cleanup() {
    echo -e "\n${BLUE}🛑 Shutting down tunnels...${NC}"
    kill $PID_ARGO
    kill $PID_GRAF
    kill $PID_PROM
    kill $PID_APP
    echo -e "${GREEN}✅ Tunnels closed. Bye!${NC}"
    exit
}

# Trap the "Ctrl+C" signal and run cleanup
trap cleanup SIGINT

# Keep script running to maintain tunnels
wait