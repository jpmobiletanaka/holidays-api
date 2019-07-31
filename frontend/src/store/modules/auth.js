import { AUTH_REQUEST, AUTH_SUCCESS, AUTH_ERROR, AUTH_LOGOUT, AUTH_DECODE } from '../constants';
import axios from '../axios'

const resource = '/auth';

const state = {
  token: localStorage.getItem('user-token') || '',
  status: '',
  userData: JSON.parse(localStorage.getItem('user-data') || '{}')
}

const getters = {
  isAuthenticated(state) {
    if (!state.token || !state.userData.exp) return false
    if ((Math.floor(Date.now() / 1000) > state.userData.exp)) return false
    return true
  },
  authStatus: state => state.status,
}

const mutations = {
  [AUTH_REQUEST]: (state) => {
    state.status = 'loading'
  },
  [AUTH_SUCCESS]: (state, token) => {
    state.status = 'success'
    state.token = token
  },
  [AUTH_ERROR]: (state) => {
    state.status = 'error'
  },
  [AUTH_DECODE]: (state, payload) => {
    localStorage.setItem('user-data', JSON.stringify(payload))
    state.userData = payload
  }
}

const actions = {
  [AUTH_REQUEST]: ({commit, dispatch}, user) => {
    return new Promise((resolve, reject) => {
      commit(AUTH_REQUEST)
      axios({url: resource, data: user, method: 'POST', headers: { 'Content-Type': 'application/json' } })
        .then(resp => {
          const token = resp.data.token
          localStorage.setItem('user-token', token)
          // Add the following line:
          axios.defaults.headers.common['Authorization'] = token
          commit(AUTH_SUCCESS, resp)
          dispatch(AUTH_DECODE, token)
          // dispatch(USER_REQUEST)
          resolve(resp)
        })
        .catch(err => {
          commit(AUTH_ERROR, err)
          localStorage.removeItem('user-token')
          reject(err)
        })
    })
  },
  [AUTH_LOGOUT]: ({commit, dispatch}) => {
    return new Promise((resolve, reject) => {
      commit(AUTH_LOGOUT)
      localStorage.removeItem('user-token')
      // remove the axios default header
      delete axios.defaults.headers.common['Authorization']
      resolve()
    })
  },
  [AUTH_DECODE]: ({commit}, token) => {
    let base64Url = token.split('.')[1];
    let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    let jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));

    commit(AUTH_DECODE, JSON.parse(jsonPayload));
  }

}

export default {
  namespaced: true,
  state: state,
  getters: getters,
  mutations: mutations,
  actions: actions
}
