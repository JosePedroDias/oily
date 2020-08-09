.PHONY: run-src symbolics clean dist run-dist test

os := $(shell uname)

codehash := $(shell git rev-parse --verify --short HEAD)
codedate := $(shell git show -s --format="%cI" HEAD)
codedate := $(shell git show -s --format="%cI" HEAD)
gameversion := $(shell cat src/core/consts.lua|pcregrep -o1 -i 'M.version = "([^"]+)"')

butler = butler

ifeq ($(os),Darwin)
	love = /Applications/love.app/Contents/MacOS/love
else ifeq ($(os),Linux)
	love = love
else
	love = "C:\\Program Files\\LOVE\\lovec"
endif

args=`arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`
rootd = `pwd`
srcd = "$(rootd)/src"
gamenamenoext = oily
gamename = oily.love

run-src:
	@$(love) $(srcd) $(call args)

symbolics:
	@mkdir src/assets
	@ln -s $(rootd)/assets/font $(rootd)/assets/gfx $(rootd)/assets/sfx src/assets

clean:
	@rm -rf build dist src/assets

getRidOfDsStores:
	@echo 'removing .DS_Stores...'
	@find . -name '.DS_Store' -type f -delete

dist:	getRidOfDsStores
	@rm -rf dist build
	@mkdir dist
	@mkdir build
	@cp -R src/* build
	@rm -rf ext/luaunit.lua build/test
	@find ./build -type f -exec sed -iE 's/src.//g' {} \;
	@rm -rf ./build/*.luaE
	@rm -rf ./build/*.svg
	@rm -rf ./build/*.svg
	@echo "code hash: $(codehash), date: $(codedate)"
	@sed -i -e 's/__GITHASH__/$(codehash)/g' build/core/consts.lua
	@sed -i -e 's/__GITDATE__/$(codedate)/g' build/core/consts.lua
	@cd build && zip -9 -q -r ../dist/$(gamename) . && cd ..
	@cd assets && zip -9 -q -r ../dist/$(gamename) . && cd ..
	@rm -rf build

# https://love2d.org/wiki/Game_Distribution
# https://github.com/MisterDA/love-release
binaries:	dist
	@rm -rf binaries
	@mkdir -p binaries/win32 binaries/win64 binaries/mac64
# windows
	@cp -R love-binaries/win32 binaries
	@cp -R love-binaries/win64 binaries
	@rm binaries/win32/love.exe
	@rm binaries/win64/love.exe
	@cat love-binaries/win32/love.exe dist/$(gamename) > binaries/win32/$(gamenamenoext).exe
	@cat love-binaries/win64/love.exe dist/$(gamename) > binaries/win64/$(gamenamenoext).exe
	@zip -9 -q -r binaries/$(gamenamenoext)_win32_$(gameversion).zip binaries/win32
	@zip -9 -q -r binaries/$(gamenamenoext)_win64_$(gameversion).zip binaries/win64
# mac
	@cp -R love-binaries/mac64/love.app binaries/mac64/${gamenamenoext}.app
	@cp dist/$(gamename) binaries/mac64/${gamenamenoext}.app/Contents/Resources
# mac - replaces CFBundleIdentifier
	@sed -i -e 's/<string>org.love2d.love<\/string>/<string>com.josepedrodias.oily<\/string>/g' binaries/mac64/${gamenamenoext}.app/Contents/Info.plist
# mac - replaces CFBundleName
	@sed -i -e 's/<string>LÖVE<\/string>/<string>oily<\/string>/g' binaries/mac64/${gamenamenoext}.app/Contents/Info.plist
# mac - removes UTExportedTypeDeclarations
	@sed -i.bak -e '104,132d' binaries/mac64/${gamenamenoext}.app/Contents/Info.plist
	@zip -9 -q -r binaries/$(gamenamenoext)_mac64_$(gameversion).zip binaries/mac64
# any
	@cp dist/$(gamename) binaries
	@mv binaries/$(gamename) binaries/$(gamenamenoext)_$(gameversion).love
# remove folders
	@rm -rf binaries/win32 binaries/win64 binaries/mac64

publish:	binaries
	#@butler push --if-changed --userversion=$(gameversion) binaries/$(gamenamenoext)_win32_$(gameversion).zip josepedrodias/oily:windows-32
	@$(butler) push --userversion=$(gameversion) binaries/$(gamenamenoext)_win64_$(gameversion).zip josepedrodias/oily:windows-64
	@$(butler) push --userversion=$(gameversion) binaries/$(gamenamenoext)_mac64_$(gameversion).zip josepedrodias/oily:mac-64
	@$(butler) push --userversion=$(gameversion) binaries/$(gamenamenoext)_$(gameversion).love josepedrodias/oily:linux

run-dist:	dist
	@$(love) dist/$(gamename)

test:
	@$(love) $(srcd) test
