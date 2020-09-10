import { GET_HOLIDAYS, POST_HOLIDAY_EXPR, PATCH_HOLIDAY_EXPR, GET_HOLIDAY, GET_HOLIDAY_EXPR, DESTROY_HOLIDAY } from '../constants';
import axios from '../axios';

const resource = '/holidays';

const state = {
  holidays: [],
};

const mutations = {
  [GET_HOLIDAYS]: (state, holidays) => {
    state.holidays = holidays;
  },
  [PATCH_HOLIDAY_EXPR]: (state, holiday) => {
    console.log(holiday);
  },
  [DESTROY_HOLIDAY]: (state, id) => {
    const idx = state.holidays.map(item => item.id).indexOf(id);
    state.holidays.splice(idx, 1);
  },
};

const actions = {
  [GET_HOLIDAYS]: ({ commit }, filters) => {
    return new Promise((resolve, reject) => {
      axios.get(resource, { params: filters })
        .then((resp) => {
          commit(GET_HOLIDAYS, resp.data);
          resolve(resp);
        })
        .catch((err) => {
          reject(err);
        });
    });
  },
  [POST_HOLIDAY_EXPR]: ({ commit }, params) => {
    return new Promise((resolve, reject) => {
      axios.post(resource, params)
        .then((resp) => {
          resolve(resp);
        })
        .catch((err) => {
          reject(err);
        });
    });
  },

  [PATCH_HOLIDAY_EXPR]: ({ commit }, params) => {
    return new Promise((resolve, reject) => {
      axios.patch(resource + `/${params.id}`, params)
        .then((resp) => {
          commit(PATCH_HOLIDAY_EXPR, resp.data);
          resolve(resp);
        })
        .catch((err) => {
          reject(err);
        });
    });
  },

  [GET_HOLIDAY_EXPR]: ({ commit }, id) => {
    return new Promise((resolve, reject) => {
      axios.get(`/holiday_exprs/${id}`)
        .then((resp) => {
          resolve(resp);
        })
        .catch((err) => {
          reject(err);
        });
    });
  },

  [GET_HOLIDAY]: ({ commit }, id) => {
    console.log('GET')
    return new Promise((resolve, reject) => {
      axios.get(`/holidays/${id}`)
        .then((resp) => {
          resolve(resp);
        })
        .catch((err) => {
          reject(err);
        });
    });
  },

  [DESTROY_HOLIDAY]: ({ commit }, id) => {
    return new Promise((resolve, reject) => {
      if (confirm('Are you sure?')) {
        axios.delete(`/holidays/${id}`)
          .then((resp) => {
            commit(DESTROY_HOLIDAY, id);
            resolve(resp);
          })
          .catch((err) => {
            reject(err);
          });
      }
    });
  },
};

export default {
  namespaced: true,
  state,
  mutations,
  actions,
};
