PORT=8080
EXTS=md
FOLDER=./content/
BUILD=./build/

deploy:
	vercel --prod
dev:
	liveserver --port=$(PORT) $(BUILD) &
	nodemon --watch $(FOLDER) --exec "bash" ./build.sh -e $(EXTS)
clean:
	rm -rf ./build/*/**
