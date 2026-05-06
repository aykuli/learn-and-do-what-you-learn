#!/bin/bash
echo "--- 1. Running docker containers"
docker compose up -d

while [ "$(docker inspect -f '{{.State.Health.Status}}' ubuntu centos7 fedora | grep -c "healthy")" -ne 3 ]; do
    echo "...waiting for all containers to be healthy"
    sleep 2
done


echo
echo "--- 2. See docker container's list"
docker compose ps

echo
echo "--- 3. Run playbook"
cd playbook
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass

echo
echo "--- 4. Stop docker containers"
cd ../
docker compose down

echo
echo "--- 2. See docker container's list"
docker compose ps
