# Tython SFDX Project Template

## Dev, Build and Test

Todo.

1. Run `npm install` to bring in all development dependencies.

2. Use SFDX to create new LWC; Note files will auto-lint on git commit.

## Resources

https://github.com/trailheadapps/lwc-recipes
https://github.com/trailheadapps/ebikes-lwc
https://github.com/dreamhouseapp/dreamhouse-lwc

## Description of Files and Directories

`force-app/` is the main src directory. Note `tests/` here is for global testing utils/mocks. Individual component unit test files live in the same folder as said component.

`scripts/` directory contains shell scripts for orchestrating project flows

`.circleci` directory houses continuous integration configs

## Issues

-Should we add automatic `__tests__` folder/file creation when creating new LWC?
-Should unit test scripts be run on pre-commit?
-Install stylelint for css, can be added to lint-staged
