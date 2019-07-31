import Vue from 'vue'
import Vuex from "vuex"
import Auth from './modules/auth'
import Uploads from './modules/uploads'

Vue.use(Vuex)

const store = new Vuex.Store({
  strict: true,
  state: {
    locale: document.querySelector('html').getAttribute('lang')
  },
  actions: {},
  mutations: {},
  getters: {},
  modules: { Auth, Uploads }
})

export default store
