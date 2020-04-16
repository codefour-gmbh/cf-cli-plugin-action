# CF CLI Plugin Action
Deploy and manage Cloud Foundry services (including plugins e.g. for zero-downtime deployment)

## Example Workflow
```
name: Deploy to Cloud Foundry with Zero-Downtime-Plugin "Puppeteer"

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-18.04
    
    steps:
    - uses: codefour-gmbh/cf-cli-plugin-action@master
      with:
        cf_api: https://api.some-cf-domain.internet
        cf_username: ${{ secrets.CF_USER }}
        cf_password: ${{ secrets.CF_PASSWORD }}
        cf_org: MyOrg
        cf_space: MySpace
        cf_plugin: cf-puppeteer
        cf_app: MyApp
        cf_routes: my.app-domain.internet
        command: zero-downtime-push
        arguments: MyApp -f my-manifest.yml
```
