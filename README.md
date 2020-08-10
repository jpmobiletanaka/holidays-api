## Deploy backend
APP_NAME=holidays-api APP_ENV=production backend/deploy/deploy.sh
## Deploy frontend
APP_NAME=holidays-api APP_ENV=production frontend/deploy/deploy.sh
## Connect to server
  ./send_ssh_key.sh holidays-api-production-backend