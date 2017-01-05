const request = require('superagent'),
  Vue = require('vue')

const users = {
  state: {
    manager_id: null,
    users: [],
    selected: []
  },
  mutations: {
    setUsers (state, {users, manager_id}){
      state.manager_id = manager_id
      state.users = users
    },
    addUser (state, {user}) {
      state.users.push(user)
    },
    addUsers (state, {users}) {
      state.users = state.users.concat(users)
    },
    setSelected (state, {users}) {
      state.selected = users
    },
    selectUser(state, user) {
      let selected = state.selected.indexOf(user)

      if (selected != -1) return state.selected.splice(selected,1)

      state.selected.push(user)
    },
    updateUser(state, user){
      const index = state.users.findIndex(u => u.id = user.id)
      Vue.set(state.users, index, user)
    }
  },
  actions: {
    getAssignableEmployees( {commit}, manager_id ) {
      $.get("/api/manager/" + manager_id + '/assignable-employees', users => commit('setUsers', {users, manager_id} ))
    },
    selectUser( {commit, state}, user ) {
      commit( 'selectUser', user )
    },
    createUsers( {commit}, users ) {
      return request.post('/api/employee/create', users)
        .then( res => {
          commit('addUsers', {users: res.body.users})

          res.body.users.forEach( u => {
            if (u.approver) commit('setApproversOn')
          })

          return res.body.users
        })
    },
    setAsApprover ({commit}, user){
      request
        .post(`/api/employee/${user.id}/set-as-approver`)
        .then( res => {
          commit('setApproversOn')
          commit('updateUser', res.body.user)
        })
    },
    unsetAsApprover ({commit}, user) {
      request
        .post(`/api/employee/${user.id}/unset-as-approver`)
        .then( res => {
          commit('updateUser', res.body.user)
          console.log('wtf')
          if (!res.body.approvers) {
            console.log('setting off')
            commit('setApproversOff')
          }
      })
    }
  }
}

module.exports = users