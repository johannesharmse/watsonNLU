# Contributing

Persons contributing to this project agree to the [code of conduct](https://github.com/johannesharmse/watsonNLU/blob/master/CONDUCT.md) and agree to the potential redistribution of their code under our license.

## Contribution Overview

The adopted contribution process requires that the collaborators fork the original repository and create pull requests for the changes to be approved by a team member. Here are some useful commands:

1. After forking the original repository, clone this forked version (as instructed by [CristinaSolana](https://gist.github.com/CristinaSolana/1885435)):

```git
git clone git@github.com:YOUR-USERNAME/YOUR-FORKED-REPO.git
```
2. Add remote from original repository in your forked repository:

```git
cd into/cloned/fork-repo
git remote add upstream git://github.com/ORIGINAL-DEV-USERNAME/REPO-YOU-FORKED-FROM.git
git fetch upstream
```

3. Updating your fork from original repo to keep up with their changes:
    1. Fetch the branches and their commits from the upstream repository.
      ```git
      git fetch upstream
      ```
    2. Got to your fork's local master branch:
      ```
      git checkout master
      ```
    3. Merge the changes from upstream/master into the local master branch:
      ```
      git merge upstream/master
      ```

3. After completing some tasks:

    1. Add *all* files that have been worked on
        ```
        git add .
        ```
   2. Add commit message
       ```
       git commit -m '[COMMIT MESSAGE]'
       ```
   4. Push anytime after that
       ```
       git push
       ```
   5. Navigate to  [Compare changes](https://github.com/johannesharmse/watsonNLU/compare) and create pull request for the branch of interest.

   6. Wait for a member of the team to merge [pull request](https://github.com/johannesharmse/watsonNLU/pulls).


## Contributor Agreement:

### Tasks:

- Refer to [Issues](https://github.com/johannesharmse/watsonNLU/issues) and [Project Board](https://github.com/johannesharmse/watsonNLU/projects).

### Communication:
Each group member is responsible to be:

- Responsive on Slack, especially during Friday and Saturday.
- 10-minute stand-up meeting on Monday during lunch break, to talk about weekly plan.

### Contribute to the project
- For small changes, create Branch is ok. Please follow the tips about commit message below (In **How to contribute** part.)
- For big changes, please use Fork. Please follow the tips about commit message below (In **How to contribute** part.).
- Commit frequently with clear and concise commit message.
- Write tests for function changes.
- Once your changes are done, submit a Pull Request.
- Wait for comments from team member. Then make changes from your Branch/Folk repo.
- Only merge after reaching whole team agreement.

## Where to Contribute (Workflow)

#### Using GitHub
1.  We can use GitHub flow (branch) to manage changes:
   - Clone this repo. Create a new branch in your desktop copy of this repository for each significant change.
   - Commit the change in that branch ([about branch](https://help.github.com/articles/about-branches/)).
   - Submit a pull request from that branch to the master repository.
   - If you receive feedback, make changes on your desktop and push to your branch on GitHub: the pull request will update automatically.
   - **If a major change is made by any person, tag atleast two other contributors. If this change is approved by all → accept pull request.

2.   We also use GitHub flow (fork) to manage changes:
   - Fork [(How to fork)](https://help.github.com/articles/working-with-forks/), then clone this repo.
   - Push that branch to your fork of this repository on GitHub.
   - Submit a pull request
   - If you receive feedback, make changes on your desktop and push to your branch on GitHub: the pull request will update automatically.
   - **If a major change is made by any person, tag atleast two other contributors. If this change is approved by all → accept pull request.

## How to Contribute

#### Code comment
- Functions need to be documented clearly.

#### Commit message
- Big changes:

```
 git commit -m "A brief summary of the commit

 A paragraph describing what changed and its impact."
```

-  Small changes:
   - 1-line detailed message including what change you made.

```
git commit -m "Concise summary of what you did here"
```

- Frequent commit everytime you make changes.


#### Testing conventions
- We will be using `testthat` to test our functions.
- `codecov` will be used to test the coverage of all the tests written using `testthat`.
- The following checks have to be implemented before submitting any major pull request to a stable version of the package:

   - `devtools::check()`
   - `devtools::test()`
   - `covr::report()`
   - `goodpractice::gp()`
   - `devtools::spell_check()`

#### Coding convention

- R:

      - Avoid using `=` when assign objects. Instead, use `->`
      - Use `%>%` (including in **dplyr** package)
      - All code should be in `.R` file rather than `.Rmd` or R notebook.


## Attribution
This document was adapted from [here](https://github.com/swcarpentry/r-novice-inflammation/blob/gh-pages/CONTRIBUTING.md).
