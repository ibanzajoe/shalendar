require('babel-polyfill')
require('./index.scss')

const Vue = require('vue'),
  VueRouter = require('vue-router'),
  _ = require('lodash')

const components = require('./components/index')

window.Vue = Vue

/* auto register all components */
_.forOwn(components, (value, key) => {
  Vue.component(key, value)
})
