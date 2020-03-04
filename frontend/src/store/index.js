import Vue from 'vue'
import Vuex from "vuex"
import Auth from './modules/auth'
import Uploads from './modules/uploads'
import Holidays from './modules/holidays'
import Countries from './modules/countries'

Vue.use(Vuex)

const store = new Vuex.Store({
  strict: true,
  state: {
    locale: document.querySelector('html').getAttribute('lang')
  },
  actions: {},
  mutations: {},
  getters: {},
  modules: { Auth, Uploads, Holidays, Countries }
})

export default store
