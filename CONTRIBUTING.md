#Pull Request Guidelines

* All pull requests should be a single commit, so that the changes can be observed
and evaluated together. Here's the best way to make that happen:
    * Pull from this repo's 'master' branch to your local repo. All pull requests
      *must* be against the 'master' branch.
    * Create a local branch for making your changes:
        - git checkout master
        - git checkout -b mychangebranch
    * Do all your testing, fixing, etc., in that branch. Make as many commits
      as you need as you work.
    * When you've completed your changes, and and made sure that everything's working great, merge it back into working
      using the '--squash' option so that it appears as a single commit.
        - git checkout master
        - git merge --squash mychangebranch
        - git commit -am "Added super powers"
        - git push origin master
    * Now you have your changes in a single commit against your 'master'
      branch on GitHub, and can create the pull request.
