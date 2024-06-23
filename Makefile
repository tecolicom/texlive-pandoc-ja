BUILD = docker build --platform=linux/amd64
TARGET = tecolicom/texlive-pandoc-ja
CACHE = $(if $(NOCACHE),--no-cache)

all:
	$(BUILD) $(CACHE) -t $(TARGET) .
