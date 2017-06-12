help:
	@echo "build   generate all bin file"
	@echo "clean   clean packages anf remove all bin file"
build:
	# @mkdir -p ./bin
	@mix deps.get 
	@mix escript.build
	# @mv meshblu_performance_tools ./bin

clean:
	@rm -rf meshblu_performance_tools
	@mix deps.clean
  s

