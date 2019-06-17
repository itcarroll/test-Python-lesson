SHELL := /bin/bash
BASEURL ?= /
OWNER := SESYNC-ci
export GEM_HOME = $(HOME)/.gem

.DEFAULT_GOAL := preview

.PHONY: release archive preview course slides upstream

# do not run rules in parallel
## because bin/build_rmd.R (bin/build_ipynb.py) runs over all .Rmd (.ipynb) slides
.NOTPARALLEL:

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

# look up all files whose modification should trigger rebuild of Jekyll site (erring conservatively)
SITE := $(shell find docs/ ! -path "docs/_site*")

# # Merge with (upstream) lesson-style Repository

# target to merge changes
upstream: | .git/refs/remotes/upstream
	git pull
	git fetch upstream master:upstream
	git merge --no-edit upstream
	git push
# target to create upstream branch
.git/refs/remotes/upstream:
	git remote add -f upstream "git@github.com:$(OWNER)/lesson-style.git"
	git branch -t upstream upstream/master

# target to identify slide files
slides: $(SLIDES)

# targets to trigger the order-only prerequisite just once
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
docs/_site: $(SITE) | docs/Gemfile.lock
	pushd docs && bundle exec jekyll build --baseurl=$(BASEURL)$(RSTUDIO_PROXY) && popd
	touch docs/_site
docs/Gemfile.lock:
	pushd docs && bundle install && popd

# # Copy Handouts and Data for a Course
#
# make target "course" is called within the handouts Makefile,
# assumed to be at ../../Makefile
#
# files matching "worksheet*" will be renumbered by lesson numbers

# target to update style and identify course handout files
course: upstream $(addprefix ../../handouts/,$(HANDOUTS:worksheet%=worksheet-$(LESSON)%))

# target to copy worksheets to the ../../handouts/
# directory while adding lesson numbers
../../handouts/worksheet-$(LESSON)%: worksheet%
	cp $< $@

# target to copy remaining handouts to ../../handouts/
../../handouts/%: %
	mkdir -p $(dir $@)
	cp -r $< $@

# # Archive
# 
# call the archive target with a command line parameter for DATE

# target to archive a lesson
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
