import Vue from 'vue';
import Router from 'vue-router';
import store from '../store'; // your vuex store
import Upload from '@/components/Upload';
import Login from '@/components/Login';

const ifNotAuthenticated = (to, from, next) => {
  if (!store.getters['Auth/isAuthenticated']) {
    next()
    return
  }
  next('/')
}

const ifAuthenticated = (to, from, next) => {
  if (store.getters['Auth/isAuthenticated']) {
    next()
    return
  }
  next('/login')
}

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: Login,
      beforeEnter: ifNotAuthenticated,
    },
    {
      path: '/upload',
      name: 'Upload form',
      component: Upload,
      beforeEnter: ifAuthenticated,
    },
  ],
});
