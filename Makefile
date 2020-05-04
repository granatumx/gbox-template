# VER: Version is set here and included as an environment variable in the build.
# GBOX: Gbox that is built, this is the docker image so self-referencing is possible.
VER = 1.0.0
GBOX = granatumx/gbox-template:$(VER)

main:
	@echo "\e[1;4;31mMakefile: make\e[0m"
	@echo "\e[1;31mPlace your makefile build instructions here that run inside the container.\e[0m"
	@echo "\e[33mThings like python scripts probably do not need a separate build step.\e[0m"

docker:
	docker build --build-arg VER=$(VER) --build-arg GBOX=$(GBOX) -t $(GBOX) .

docker-push:
	docker login
	docker push $(GBOX)
	
shell:
	@echo "\e[1;4;31mMakefile: make shell\e[0m"
	@echo "\e[1;31mYou are entering the image and can poke around.\e[0m"
	@echo "\e[1;31mLink the network and docker of the parent process.\e[0m"
	docker run -v /var/run/docker.sock:/var/run/docker.sock --network=host --rm -it $(GBOX) bash

doc:
	@echo "\e[1;4;31mMakefile: make doc\e[0m"
	@echo "\e[1;31mYou are making the documentation for this gbox.\e[0m"
	./gendoc.sh
	
test:
	@echo "\e[1;4;31mMakefile: make test\e[0m"
	@echo "\e[1;31mPlace your test instructions here that run inside the container.\e[0m"
