.DEFAULT_GOAL := test

ifeq ($(shell uname), Darwin)                                        # Apple
    CXX          := g++
    INCLUDE      := /usr/local/include
    CXXFLAGS     := -pedantic -std=c++11 -I$(INCLUDE) -Wall -Weffc++
    LIB          := /usr/local/lib
    LDFLAGS      := -lgtest_main
    CLANG-CHECK  := clang-check
    GCOV         := gcov
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format
else ifeq ($(CI), true)                                              # Travis CI
    CXX          := g++-5
    INCLUDE      := /usr/include
    CXXFLAGS     := -pedantic -std=c++11 -Wall -Weffc++
    LIB          := /usr/lib
    LDFLAGS      := -lgtest -lgtest_main -pthread
    CLANG-CHECK  := clang-check
    GCOV         := gcov-5
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format
else ifeq ($(shell uname -p), unknown)                               # Docker
    CXX          := g++
    INCLUDE      := /usr/include
    CXXFLAGS     := -pedantic -std=c++11 -Wall -Weffc++
    LIB          := /usr/lib
    LDFLAGS      := -lgtest -lgtest_main -pthread
    CLANG-CHECK  := clang-check
    GCOV         := gcov
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format
else                                                                 # UTCS
    CXX          := g++-4.8
    INCLUDE      := /usr/include
    CXXFLAGS     := -pedantic -std=c++11 -Wall -Weffc++
    LIB          := /usr/lib
    LDFLAGS      := -lgtest -lgtest_main -pthread
    CLANG-CHECK  := clang-check-3.8
    GCOV         := gcov-4.8
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format-3.8
endif

clean:
	cd examples; make clean
	@echo
	cd exercises; make clean
	@echo
	cd patterns; make clean

config:
	git config -l

docker-build:
	docker build -t gpdowning/gcc .

docker-pull:
	docker pull gpdowning/gcc

docker-push:
	docker push gpdowning/gcc

docker-run:
	docker run -it -v $(PWD):/usr/oopl-sarc -w /usr/oopl-sarc gpdowning/gcc

init:
	touch README
	git init
	git add README
	git commit -m 'first commit'
	git remote add origin git@github.com:gpdowning/oopl-sarc.git
	git push -u origin master

pull:
	make clean
	@echo
	git pull
	git status

push:
	make clean
	@echo
	git add .gitignore
	git add .travis.yml
	git add Dockerfile
	git add examples
	git add exercises
	git add makefile
	git add patterns
	git commit -m "another commit"
	git push
	git status

status:
	make clean
	@echo
	git branch
	git remote -v
	git status

sync:
	@rsync -r -t -u -v --delete              \
    --include "Docker.sh"                    \
    --include "InitializerList.c++"          \
    --include "Auto.c++"                     \
    --include "Initializations.c++"          \
    --include "SharedPtr.c++"                \
    --include "Functions.c++"                \
    --exclude "*"                            \
    ../../examples/c++/ examples
	@rsync -r -t -u -v --delete              \
    --include "Count.c++"                    \
    --include "Count.h"                      \
    --exclude "*"                            \
    ../../exercises/c++/ exercises
	@rsync -r -t -u -v --delete              \
    --include "StrategyPattern.c++"          \
    --include "StrategyPattern.h"            \
    --include "StrategyPattern1.c++"         \
    --include "StrategyPattern1.h"           \
    --exclude "*"                            \
    ../../patterns/c++/ patterns

test:
	make clean
	@echo
	cd examples; make test
	@echo
	cd exercises; make test
	@echo
	cd patterns; make test

versions:
	which make
	make --version
	@echo
	which git
	git --version
	@echo
	which $(CXX)
	$(CXX) --version
	@echo
	ls -ald $(INCLUDE)/boost
	@echo
	ls -ald $(INCLUDE)/gtest
	@echo
	ls -al $(LIB)/*gtest*
ifneq ($(shell uname -p), unknown) # Docker
	@echo
	which $(CLANG-CHECK)
	$(CLANG-CHECK) --version
endif
	@echo
	which $(GCOV)
	$(GCOV) --version
	@echo
	which $(VALGRIND)
	$(VALGRIND) --version
	@echo
	which $(DOXYGEN)
	$(DOXYGEN) --version
ifneq ($(shell uname -p), unknown) # Docker
	@echo
	which $(CLANG-FORMAT)
	$(CLANG-FORMAT) --version
endif
