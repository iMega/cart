IMAGE = imega/cart
CONTAINERS = dns cart cart_db
PORT = -p 80:80

build:
	docker build -f nginx.docker -t $(IMAGE) .

prestart:
	@docker run -d --name cart_db -p 6379:6379 leanlabs/redis
	@docker run -d --name dns --cap-add=NET_ADMIN \
		--link cart_db:cart_db \
		andyshinn/dnsmasq

start: prestart
ifeq ($(shell until [ "`docker inspect -f {{.State.Running}} dns`" == "true" ]; do sleep 0.1; done; echo true;),true)
	$(eval RESOLVER = $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' dns))
endif

	cp $(CURDIR)/nginx.dist $(CURDIR)/nginx.conf
	sed -i '' -e 's/resolver 127.0.0.1;/resolver $(RESOLVER);/g' $(CURDIR)/nginx.conf

	@docker run -d --name cart \
		--link cart_db:cart_db \
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
