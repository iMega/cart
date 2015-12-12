IMAGE = imega/cart
CONTAINERS = imega_cart imega_cart_db
PORT = -p 80:80

build:
	@docker build -f nginx.docker -t $(IMAGE) .

prestart:
	@docker run -d --name imega_cart_db leanlabs/redis

start: prestart
	@while [ "`docker inspect -f {{.State.Running}} imega_cart_db`" != "true" ]; do \
		@echo "wait db"; sleep 0.3; \
	done
	$(eval IP_DB = $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' imega_cart_db))
	@cp $(CURDIR)/sites-enabled/cart.dist $(CURDIR)/sites-enabled/cart.conf
	@sed -i '' -e "s/set \$$redis_ip 127.0.0.1;/set \$$redis_ip $(IP_DB);/g" $(CURDIR)/sites-enabled/cart.conf

	@docker run -d --name imega_cart \
		-v $(CURDIR)/sites-enabled:/etc/nginx/sites-enabled \
		-v $(CURDIR)/app:/app \
		-v $(CURDIR)/vendor:/vendor \
		-v $(CURDIR)/nginx.conf:/etc/nginx/nginx.conf \
		$(PORT) \
		$(IMAGE)

stop:
	-docker stop -fv $(CONTAINERS)

clean: stop
	-docker rm -fv $(CONTAINERS)

destroy: clean
	@docker rmi -f $(IMAGE)

.PHONY: build start prestart stop clean destroy
