import { UPLOAD_REQUEST, UPLOAD_SUCCESS, UPLOAD_ERROR, GET_FILES } from '../constants';
import axios from '../axios'

const resource = '/uploads';

const state = {
  file: null,
  files: [],
  status: ''
}

const mutations = {
  [UPLOAD_REQUEST]: (state) => {
    state.status = 'uploading'
  },
  [UPLOAD_SUCCESS]: (state, token) => {
    state.status = 'success'
    state.token = token
  },
  [UPLOAD_ERROR]: (state) => {
    state.status = 'error'
  },
  [GET_FILES]: (state, files) => {
    state.files = files
  }
}

const actions = {
  [UPLOAD_REQUEST]: ({commit, dispatch}, file) => {
    return new Promise((resolve, reject) => {
      commit(UPLOAD_REQUEST)
      axios({url: resource, data: file, method: 'POST', headers: { 'Content-Type': 'multipart/form-data' } })
        .then(resp => {
          commit(UPLOAD_SUCCESS, resp)
          // dispatch(USER_REQUEST)
          resolve(resp)
        })
        .catch(err => {
          commit(UPLOAD_ERROR, err)
          reject(err)
        })
    })
  },
  [GET_FILES]: ({commit}) => {
    return new Promise((resolve, reject) => {
      axios.get(resource)
        .then(resp => {
          commit(GET_FILES, resp.data)
          // dispatch(USER_REQUEST)
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
