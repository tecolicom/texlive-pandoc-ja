BUILD = docker build --platform=linux/amd64
TARGET = tecolicom/texlive-pandoc-ja:dev
CACHE = $(if $(NOCACHE),--no-cache)
WORK = /app

all:
	$(BUILD) $(CACHE) -t $(TARGET) .

run:
	@top=`git rev-parse --show-toplevel` cwd=`pwd` path=$${cwd#$$top} ; \
	command="docker run -it --rm -v $$top:$(WORK) -w $(WORK)$${path} $(TARGET) bash" ; \
	echo $$command ; \
	$$command
