
# Install Dependencies
.PHONY: install
install: install.sh
	./install.sh

.PHONY: install-personal
install-personal: install.sh
	./install.sh --full

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make                  - Run the default install target"
	@echo "  make install          - Install dependencies"
	@echo "  make install-personal - Install dependencies for personal projects"
	@echo "  make help             - Display this help message"
	@echo "  make devcontainer     - Build and run the dev container"

# Target for running in a dev container
.PHONY: devcontainer
devcontainer: .devcontainer/Dockerfile .devcontainer/devcontainer.json
	@echo "Building and running the dev container..."
	docker build -t devcontainer -f .devcontainer/Dockerfile .
	docker run -it --rm --name devcontainer \
		-v ${HOME}/.ssh:/home/devuser/.ssh \
		-v ${HOME}/.gitconfig:/home/devuser/.gitconfig \
		devcontainer
