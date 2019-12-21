.SUFFIXES: .js .css .html
NODE=node
RM=rm -f
GENERATED_SOURCES=src/cli/initConfig/config.json.template.js \
	src/cli/initConfig/config.js.template.js \
	src/report/csv/csv.template.js \
	src/report/dot/moduleLevel/dot.template.js \
	src/report/dot/folderLevel/ddot.template.js \
	src/report/html/html.template.js \
	src/report/err-html/err-html.template.js \
	src/schema/configuration.schema.json \
	src/schema/cruise-result.schema.json \

.PHONY: help dev-build clean

help:
	@echo
	@echo " -------------------------------------------------------- "
	@echo "| More information and other targets: open the Makefile  |"
	@echo " -------------------------------------------------------- "
	@echo
	@echo "Useful targets:"
	@echo
	@echo "dev-build. If necessary this ..."
	@echo "- ... recompiles the handlebar templates"
	@echo
	@echo "clean. Removes all generated sources."
	@echo
	@echo "uses to infer whether re-compilation is necessary."
	@echo

# production rules
src/%.template.js: src/%.template.hbs
	npx handlebars --commonjs handlebars/runtime -f $@ $<

src/%.schema.json: utl/%.schema.js
	$(NODE) ./utl/generate-schemas.utl.js
	npx prettier --write ./src/schema/*.json
	node bin/dependency-cruise.js --validate --output-type dot utl/schema | dot -Grankdir=TD -Gsplines=ortho -T svg > utl/overview.svg
	node bin/dependency-cruise.js --validate --output-type dot utl/schema | dot -Gdpi=192 -Grankdir=TD -Gsplines=ortho -T png | pngquant - > utl/overview.png

# "phony" targets
dev-build: $(GENERATED_SOURCES)

profile:
	$(NODE) --prof src/cli.js -f - test
	@echo "output will be in a file called 'isolate-xxxx-v8.log'"
	@echo "- translate to readable output with:"
	@echo "    node --prof-process isolate-xxxx-v8.log | more"

clean:
	$(RM) $(GENERATED_SOURCES)
