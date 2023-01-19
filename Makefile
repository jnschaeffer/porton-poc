PRIVKEY_FILE=identity-manager-sts/privkey.pem

PHONY: down

privkey: $(PRIVKEY_FILE)

up: privkey
	docker-compose up -d

down:
	docker-compose down

$(PRIVKEY_FILE):
	openssl genpkey -out $(PRIVKEY_FILE) -algorithm RSA -pkeyopt rsa_keygen_bits:4096
	chmod 644 $(PRIVKEY_FILE)
