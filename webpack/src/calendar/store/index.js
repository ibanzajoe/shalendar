const Vue = require('vue'),
  Vuex = require('vuex'),
  request = require('superagent'),
  modules = require('./modules')

Vue.use(Vuex)

const store = new Vuex.Store({
  modules,
  state: {
    current_user: window._store.current_user,
    redirect: false,
    show_left_nav: true
  },
  mutations: {
    setApproversOn (state) {
      state.current_user.company.approvers = true
    },
    setApproversOff (state) {
      state.current_user.company.approvers = false
    },
    setRedirect (state, url) {
      state.redirect = url
    },

    hideLeftNav (state) {
      state.show_left_nav = false
    },
    showLeftNav (state) {
      state.show_left_nav = true
    },
    updateCurrentUser (state, user) {
      state.current_user = user
    }
  },
  actions: {
    updateCurrentUser ({commit}, user) {
      delete user.company
      return $.post('/api/user/save', user)
        .then( res => commit('updateCurrentUser', res.user) )
    }
  }
})

if (module.hot) {
  module.hot.accept([
    './modules'
  ], () => {
    store.hotUpdate({
      modules: require('./modules')
    })
  })
}

module.exports = store