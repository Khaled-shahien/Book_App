# Branch Protection Setup

After merging this PR, manually apply these settings on GitHub.

## For `main` branch
Settings -> Branches -> Add rule -> Branch name: main

- [x] Require a pull request before merging
- [x] Require approvals: 1
- [x] Require status checks to pass before merging
  - Required checks: "Analyze & Test"
- [x] Require branches to be up to date before merging
- [x] Do not allow bypassing the above settings

## For `develop` branch
Use the same settings, but approvals can be 0 for solo development.
