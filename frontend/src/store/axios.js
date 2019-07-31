import axios from 'axios/index'

const baseHost = process.env.API_URL || 'http://localhost:3000';
const basePath = process.env.API_PATH || '/api'
const apiVersion = process.env.API_VER || 1

const token = localStorage.getItem('user-token')
if (token) {
  axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
}

export default axios.create({
  baseURL: baseHost + basePath + '/v' + `${apiVersion}`,
})
