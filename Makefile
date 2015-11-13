IMAGE = imega/cart
CONTAINERS = cart
PORT = -p 80:80

build:
	docker build -f nginx.docker -t $(IMAGE) .

start:
	@docker run -d --name cart -v $(CURDIR)/sites-enabled:/etc/nginx/sites-enabled -v $(CURDIR)/app:/app $(PORT) $(IMAGE)

stop:
	-docker stop $(CONTAINERS)

clean: stop
	-docker rm -fv $(CONTAINERS)

destroy: clean
	@docker rmi -f $(IMAGE)

.PHONY: build start stop clean destroy
