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

## Deploy manually
Prerequisites: 
* AWS CLI Installed
* AWS Access Keys for `revenue_setup` account (either in env vars or in ~/.aws/credentials)

Build the new backend image if changed:
```
docker build -f docker/frontend/Dockerfile -t holidays-api_frontend .
```

Tag it with AWS ECR Repo:
```
docker tag holidays-api_frontend 611630892743.dkr.ecr.ap-northeast-1.amazonaws.com/holidays-api-frontend
```

Login to ECR
```
aws ecr get-login --no-include-email | bash
```

Push the images:
```
docker push 611630892743.dkr.ecr.ap-northeast-1.amazonaws.com/holidays-api-frontend
```

Update service:
```
aws ecs update-service --service holidays-api-staging-frontend --force-new-deployment --cluster holidays-api-staging
```
