IMAGE = imega/cart
CONTAINERS = imega_cart imega_cart_db
PORT = -p 80:80
REDIS_PORT = 6379

build:
	@docker build -t $(IMAGE) .

prestart:
	@docker run -d --name imega_cart_db leanlabs/redis

start: prestart
	@while [ "`docker inspect -f {{.State.Running}} imega_cart_db`" != "true" ]; do \
		@echo "wait db"; sleep 0.3; \
	done
	$(eval REDIS_IP = $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' imega_cart_db))

	@docker run -d --name imega_cart \
		--env REDIS_IP=$(REDIS_IP) \
		--env REDIS_PORT=$(REDIS_PORT) \
		$(PORT) \
		$(IMAGE)

stop:
	@-docker stop $(CONTAINERS)

clean: stop
	@-docker rm -fv $(CONTAINERS)

destroy: clean
	@docker rmi -f $(IMAGE)
