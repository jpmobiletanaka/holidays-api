import {GET_SOURCES} from '../constants';
import axios from '../axios'

const resource = '/sources';

const state = {
  file: null,
  files: [],
  status: ''
}

const mutations = {
  [GET_SOURCES]: (state, sources) => {
    state.sources = sources
  }
}

const actions = {
  [GET_SOURCES]: ({commit}) => {
    return new Promise((resolve, reject) => {
      axios.get(resource)
        .then(resp => {
          commit(GET_SOURCES, resp.data)
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
