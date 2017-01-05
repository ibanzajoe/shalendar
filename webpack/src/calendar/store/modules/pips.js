const Vue = require('vue'),
  request = require('superagent')

module.exports = {
  state: {
    pips: [],
    my_pips: []
  },
  mutations: {
    setMyPips (state, {pips}) {
      state.my_pips = pips
    },
    setPips (state, {pips}){
      state.pips = pips
    },
    addPip (state, {pip}) {
      state.pips.push(pip)
    },
    addPips (state, {pips}) {
      state.pips = state.pips.concat(pips)
    },
    updatePip (state, {pip}) {
      const index = state.pips.findIndex( p => p.id == pip.id)

      Vue.set(state.pips, index, pip)
    }
  },
  actions: {
    getUserPips ( {commit}, user_id) {
      request.get(`/api/employee/${user_id}/pips`)
        .then( res => commit('setPips', {pips: res.body} ) )
    },
    getMyPips ( {commit}, {filter_type}) {
      request.get('/api/my/pips', {filter_type})
        .then( res => {
        commit('setMyPips', {pips: res.body})
      })
    },
    updatePip ( {commit}, {pip} ) {
      commit('updatePip', {pip})
    },
    startPip ( {commit}, {pip} ) {
      request
        .post('/api/pip/start')
        .send({pip_id: pip.id})
        .then( res => {
          pip.status = 'started'
          commit('updatePip', {pip})
        })
    },
    approvalRequest ( {commit}, {pip, handle_close} ) {
      return request
        .post('/api/pip/' + pip.id + '/approvers/notify')
        .then( res => {
          pip.status = 'awaiting approval'
          commit('updatePip', {pip: res.body.pip})
          commit('openModal', {
            name: 'approval_request',
            set: {pip, handle_close}
          })
          return res.body.pip
        })
    },
    denyPip ({commit}, {pip}) {
      return request
        .post(`/api/pip/${pip.id}/deny`)
        .then( res => {
          console.log(res.body)
          commit('updatePip', {pip: res.body.pip})

          return res.body.pip
        })
    },
    approvePip ({commit}, {pip}) {
      return request
        .post(`/api/pip/${pip.id}/approve`)
        .then( res => {
          commit('updatePip', {pip: res.body.pip})

          return res.body.pip
        })
    },
    sendEmployeeNotification ( {commit}, {pip}) {
      request
        .post(`/api/pip/${pip.id}/employee/notify`)
        .then( res => {
          commit('updatePip', {pip: res.body.pip})
        })
    },
    signPip ({commit}, {pip, user}) {
      let role = user.role == 'admin' ? 'manager' : user.role

      return request
        .post(`/api/pip/${pip.id}/sign/${role}`)
        .send(pip)
        .then( res => {
          commit('updatePip', {pip: res.body.pip})
          return res.body.pip
        })
    },

    finishDraftPip ({commit}, {pip}) {
      return request
        .post(`/api/pip/${pip.id}/finish-draft`)
        .send(pip)
        .then( res => {
          commit('updatePip', {pip: res.body.pip})
          return res.body.pip
        })
    },

    updateFollowups({commit}, {payload}){

      return request
        .post("/api/pip/"+payload.pip_id+"/followup/update")
        .send(payload)
        .then( res => {
          commit('updatePip', {pip: res.body.pip})

          return res.body.pip
        })

    }
  }
}
