import {GET_HOLIDAYS, POST_HOLIDAY_EXPR, PATCH_HOLIDAY_EXPR, GET_HOLIDAY_EXPR} from '../constants';
import axios from '../axios'

const resource = '/holidays';

const state = {
  holidays: [],
}

const mutations = {
  [GET_HOLIDAYS]: (state, holidays) => {
    state.holidays = holidays
  },
  [PATCH_HOLIDAY_EXPR]: (state, holiday) => {
    console.log(holiday)
  }
}

const actions = {
  [GET_HOLIDAYS]: ({commit}, filters) => {
    return new Promise((resolve, reject) => {
      axios.get(resource, { params: filters })
        .then(resp => {
          commit(GET_HOLIDAYS, resp.data)
          resolve(resp)
        })
        .catch(err => {
          reject(err)
        })
    })
  },
  [POST_HOLIDAY_EXPR]: ({commit}, params) => {
    return new Promise((resolve, reject) => {
      axios.post(resource, params)
        .then(resp => {
          resolve(resp)
        })
        .catch(err => {
          reject(err)
        })
    })
  },
  [PATCH_HOLIDAY_EXPR]: ({commit}, params) => {
    return new Promise((resolve, reject) => {
      axios.patch(resource + `/${params.id}`, params)
        .then(resp => {
          commit(PATCH_HOLIDAY_EXPR, resp.data)
          resolve(resp)
        })
        .catch(err => {
          reject(err)
        })
    })
  },
  [GET_HOLIDAY_EXPR]: ({commit}, id) => {
    return new Promise((resolve, reject) => {
      axios.get(`/holiday_exprs/${id}`)
        .then(resp => {
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
