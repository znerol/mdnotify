VERSION := $(shell git describe --tags --always)

all: build

.build/apple/Products/Release/mdnotify:
	swift build -c release --arch arm64 --arch x86_64

clean:
	rm -rf .build build dist

build: .build/apple/Products/Release/mdnotify
	mkdir -p build/mdnotify-${VERSION}
	cp COPYING.txt .build/apple/Products/Release/mdnotify build/mdnotify-${VERSION}

dist: build
	mkdir -p dist
	tar --uid 0 --gid 0 --numeric-owner -czf dist/mdnotify-${VERSION}.tar.gz -C build mdnotify-${VERSION}
	(cd dist && shasum -a 256 mdnotify-* > sha256sums.txt)

.PHONY: test
test:
	swift test --parallel
