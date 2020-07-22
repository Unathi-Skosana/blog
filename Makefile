PORT=8080
EXTS=md,css
STATIC=./static/*/**
FOLDER=./content/
BUILD=./build/

deploy:
	make clean
	bash ./build.sh --prod
	vercel --prod
dev:
	nodemon --watch $(FOLDER) $(STATIC) --exec "bash ./build.sh --dev" -e $(EXTS) &
	live-server --port=$(PORT) $(BUILD)
clean:
	rm -rf ./build/*/**
