PORT=8080
EXTS=md
FOLDER=./content/
BUILD=./build/

deploy:
	vercel --prod
build:
	bash ./build.sh
dev:
	python -m http.server $(PORT) --directory $(BUILD) &
	nodemon --watch $(FOLDER) --exec "bash" ./build.sh -e $(EXTS)
