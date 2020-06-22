PORT=8080
EXTS=md
STATIC=./static/*/**
FOLDER=./content/
BUILD=./build/

deploy:
	make clean
	bash ./build.sh --prod
	vercel --prod
dev:
	live-server --port=$(PORT) $(BUILD) &
	nodemon --watch $(FOLDER) $(STATIC) --exec "bash ./build.sh --dev" -e $(EXTS)
clean:
	rm -rf ./build/*/**
