.PHONY: crypter
crypter:
	@echo "[*] building crypter ..." && \
	cd crypter; CGO_ENABLED=0 go build \
		-o ../dist/crypter main.go

.PHONY: loader
loader:
	@echo "[*] building loader ..." && \
	cd loader; CGO_ENABLED=1 go build \
		-o ../dist/loader main.go
