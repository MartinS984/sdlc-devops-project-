# Makefile

.PHONY: up down

# "make up" starts the environment
up:
	@chmod +x scripts/startup.sh
	@./scripts/startup.sh

# "make down" is a placeholder if you ever want to add a stop script later
down:
	@echo "Stopping environment..."
	# commands to stop minikube or kill ports could go here