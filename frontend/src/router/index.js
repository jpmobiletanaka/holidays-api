import Vue from 'vue';
import Router from 'vue-router';
import store from '../store'; // your vuex store
import Upload from '@/components/Upload';
import Login from '@/components/Login';
import Holidays from '@/components/holidays';
import EditHolidayExpr from '@/components/holiday_exprs/edit'
import NewHolidayExpr from '@/components/holiday_exprs/new'

const ifNotAuthenticated = (to, from, next) => {
  if (!store.getters['Auth/isAuthenticated']) {
    next();
    return
  }
  next('/')
};

const ifAuthenticated = (to, from, next) => {
  if (store.getters['Auth/isAuthenticated']) {
    next();
    return
  }
  next('/login')
};

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
    {
      path: '/holidays',
      name: 'Holidays',
      component: Holidays,
      beforeEnter: ifAuthenticated,
    },
    {
      path: '/holiday_exprs/:id/edit',
      name: 'Edit Holiday Expr',
      component: EditHolidayExpr,
      beforeEnter: ifAuthenticated,
    },
    {
      path: '/holiday_exprs/new',
      name: 'New Holiday Expr',
      component: NewHolidayExpr,
      beforeEnter: ifAuthenticated,
    }
  ],
  linkExactActiveClass: 'active',
});
