help:
	@echo "build   generate all bin file"

build:
	@mkdir -p ./bin
	@mix deps.get 
	@mix escript.build
	@mv meshblu_performance_tools ./bin

# clean:
# 	@python setup.py clean

# run:
# 	@for f in mysql/*.yaml postgres/*.yaml kong/*.yaml ; do echo "$f" ; done

#     Contact GitHub API Training Shop Blog About 

