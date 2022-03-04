### pushing a new image (must be done manually)

1. `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 874575230586.dkr.ecr.us-east-1.amazonaws.com`
2. `docker build -t tdbot .`
3. `docker tag tdbot:latest 874575230586.dkr.ecr.us-east-1.amazonaws.com/tdbot:latest`
4. `docker push 874575230586.dkr.ecr.us-east-1.amazonaws.com/tdbot:latest`


This is currently working but theres an absolute fuck ton of manual shit in here. Id like to change that.