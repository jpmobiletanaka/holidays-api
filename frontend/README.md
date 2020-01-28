# holidays-front

> Holidays API frontend client

## Build Setup

``` bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build

# build for production and view the bundle analyzer report
npm run build --report

# run unit tests
npm run unit

# run e2e tests
npm run e2e

# run all tests
npm test
```

For a detailed explanation on how things work, check out the [guide](http://vuejs-templates.github.io/webpack/) and [docs for vue-loader](http://vuejs.github.io/vue-loader).

## Deploy
Prerequisites: 
* AWS CLI Installed
* AWS Access Keys for IAM account (either in env vars or in ~/.aws/credentials). This account has to be included in 

### Using deploy script

Run `APP_ENV=your_env deploy/deploy.sh`

It will build, push, migrate (if needed) and update a cluster service.

Also you can run separate scripts:
```
sh deploy/build.sh
sh deploy/push.sh
sh APP_ENV=your_env deploy/update_service.sh
```
