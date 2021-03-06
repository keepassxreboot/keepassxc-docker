all: build

.PHONY: build
build:
	docker build --build-arg QT5_MINOR=11 --build-arg QT5_MICRO=0 . -t keepassxc/keepassxc-ci:bionic-qt5.11
	docker build --build-arg QT5_MINOR=15 --build-arg QT5_MICRO=2 . -t keepassxc/keepassxc-ci:bionic-qt5.15

.PHONY: push
push:
	docker push keepassxc/keepassxc-ci:bionic-qt5.11
	docker push keepassxc/keepassxc-ci:bionic-qt5.15
