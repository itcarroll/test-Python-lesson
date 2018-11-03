SHELL := /bin/bash
PORT ?= 4321
.DEFAULT_GOAL := preview

# look up lesson number and slides in Jekyll _config.yml
LESSON := $(shell ruby -e "require 'yaml';puts YAML.load_file('docs/_data/lesson.yml')['lesson']")
SORTER := $(shell ruby -e "require 'yaml';puts YAML.load_file('docs/_data/lesson.yml')['sorter']")
SLIDES := $(SORTER:%=docs/_slides/%.md)

# list available Markdown, RMarkdown and Jupyter Notebook slides
SLIDES_MD := $(shell find slides/ -name "*.md" -exec basename {} \;)
SLIDES_RMD := $(shell find slides/ -name "*.Rmd" -exec basename {} \;)
SLIDES_IPYNB := $(shell find slides/ -name "*.ipynb" -exec basename {} \;)

# look up files for trainees in Jekyll _config.yml
HANDOUTS := $(shell ruby -e "require 'yaml';puts YAML.load_file('docs/_data/lesson.yml')['handouts']")

# do not run rules in parallel
## because bin/build_rmd.R (bin/build_ipynb.py) runs over all .Rmd (.ipynb) slides
.NOTPARALLEL:
.PHONY: course upstream slides archive preview

# target to synchronize with GitHub
upstream: | .git/refs/remotes/upstream
	git pull
	git fetch upstream master:upstream
	git merge --no-edit upstream
	git push
.git/refs/remotes/upstream:
	git remote add -f upstream "git@github.com:sesync-ci/lesson-style.git"
	git branch -t upstream upstream/master

# target to just update docs/_slides
slides: $(SLIDES)
$(SLIDES): | docs/_slides
docs/_slides:
	mkdir -p docs/_slides
## cannot use a pattern as the next three targets, because
## the targets are only a subset of docs/_slides/%.md and
## they have different recipes
$(addprefix docs/_slides/,$(SLIDES_MD)): docs/_slides/%: slides/%
	cp $< $@
$(addprefix docs/_slides/,$(SLIDES_RMD:.Rmd=.md)): docs/_slides/%.md: bin/build_rmd.R slides/%.Rmd 
	@$<
$(addprefix docs/_slides/,$(SLIDES_PMD:.ipynb=.md)): docs/_slides/%.md: bin/build_ipynb.py /slides/%.ipynb 
	@$<

# target to build local jekyll site for RStudio Server preview
preview: slides | docs/_site
export GEM_HOME=$(HOME)/.gem
SITE = $(shell find docs/ ! -path "docs/_site*")
docs/_site: $(SITE) | docs/Gemfile.lock
	pushd docs && bundle exec jekyll build --baseurl=/p/$(PORT) && popd
	touch docs/_site
docs/Gemfile.lock:
	pushd docs && bundle install && popd

# target that brings this lesson into a course
## make target "course" is called within the handouts Makefile,
## assumed to be at ../../Makefile
course: upstream slides $(addprefix ../../handouts/,$(HANDOUTS:worksheet%=worksheet-$(LESSON)%))
## copy lesson handouts to the ../../handouts/ directory
## while adding lesson numbers to worksheets
../../handouts/worksheet-$(LESSON)%: worksheet%
	cp $< $@
../../handouts/%: %
	mkdir -p $(dir $@)
	cp -r $< $@

# target to archive a lesson
## call the archive target with a command line parameter for DATE
archive: | docs/_archive
	cp docs/_views/course.md docs/_archive/$(DATE)-index.md
	pushd docs && bundle exec jekyll build --config _config.yml,_archive.yml && popd
	echo -e "---\n---\n$$(cat docs/_site/$(subst -,/,$(DATE))/index.html)" > docs/_archive/$(DATE)-index.html
	rm docs/_archive/$(DATE)-index.md
docs/_archive:
	mkdir docs/_archive

# target to create binary for GitHub release
release:
	ln -s . handouts
	if [ -f *.Rproj ]; then ln *.Rproj handouts.Rproj; fi
	zip -FSr handouts handouts/handouts.Rproj $(addprefix handouts/,$(HANDOUTS))
	rm -f handouts handouts.Rproj
