const request = require('superagent')

module.exports = {
  state: {
    confirm: {
      show: false,
      title: 'Are you sure?',
      message: 'Are you sure?',
      resolve: function(){},
      reject: function(){}
    },
    pipPreview: {
      show: false,
      pip: {},
      handle_update: function(){}
    },
    demo: {
      show: false
    },
    addEmployee: {
      show: false
    },
    bam: {
      show: false,
      title: false,
      text: false,
      image_src: false,
      button_text: false,
      button_click: function () {
      }
    },
    approval_request: {
      show: false,
      pip: {},
      close_handler: function(){}
    }
  },
  mutations: {
    closeAllModals (state) {
      _.forOwn(state, m => {
        m.show = false
      })
    },
    closeModal (state, payload) {
      state[payload.name].show = false
    },
    openModal (state, payload) {
      state[payload.name] = {
        show: true,
        ...payload.set
      }
    },
    showConfirmModal (state, payload) {
      state.confirm = {
        show: true,
        message: payload.message,
        title: payload.title,
        image_src: payload.image_src,
        resolve_text: payload.resolve_text,
        resolve: payload.resolve,
        reject_text: payload.reject_text,
        reject: payload.reject
      }
    },
    closeConfirmModal (state) {
      state.confirm = {
        show: false,
        message: 'Are you sure?',
        resolve: function(){},
        reject: function(){}
      }
    },
    showModalPip (state, {pip, handle_update}) {
      state.pipPreview = {
        pip,
        handle_update,
        show: true
      }
    },
    showFollowupDateModal (state, payload) {
      state.modals.followupDate = {
        show: true
      }
    },
    showBam (state, opts) {
      state.bam = {
        show: true,
        title: opts.title || false,
        text: opts.text || false,
        image_src: opts.image_src || false,
        button_text: opts.button_text || 'Continue',
        button_click: opts.button_click
      }
    },
    hideBam (state) {
      state.bam = {
        show: false,
        title: false,
        text: false,
        image_src: false,
        button_text: 'Continue',
        button_click: function () {}
      }
    },
    updatePip (state, {pip}) {
      state.pipPreview.pip = pip
    }
  },
  actions: {
    bam: function({commit}, opts){
      return new Promise( resolve => {
        opts.button_click = function(){
          resolve()
          commit('hideBam')
        }.bind(this)

        commit('showBam', opts)
      })
    },
    modalConfirm({commit}, options) {
      return new Promise( (resolve, reject) => {
        options.resolve = resolve
        options.reject = reject

        commit('showConfirmModal', options)
      }).then( yes => true, no => false )
        .then( res => {
          commit('closeConfirmModal')
          return res
        })
    },
    showModalPip ({commit}, {pip_id, handle_update}){
      request.get('/api/pip/' + pip_id)
        .then( res => {
          commit('showModalPip', {handle_update, pip: res.body})
        })
    }
  }

}