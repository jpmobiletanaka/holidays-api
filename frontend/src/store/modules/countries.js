import {GET_COUNTRIES} from '../constants';
import axios from '../axios'

const resource = '/countries';

const state = {
  countries: [],
}

const mutations = {
  [GET_COUNTRIES]: (state, countries) => {
    state.countries = countries
  }
}

const actions = {
  [GET_COUNTRIES]: ({state, commit}) => {
    return new Promise((resolve, reject) => {
      if (state.countries.length > 0) {
        resolve({})
        return
      }
      axios.get(resource)
        .then(resp => {
          commit(GET_COUNTRIES, resp.data)
          resolve(resp)
        })
        .catch(err => {
          reject(err)
        })
    })
  }
}

export default {
  namespaced: true,
  state: state,
  mutations: mutations,
  actions: actions
}
