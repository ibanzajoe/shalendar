require('./index.scss')

const Vue = require('vue'),
  modal = require('./components/modal.html'),
  signPip = require('./components/sign-pip.html'),
  slide = require('./components/slide.html'),
  slidePipPreview = require('./components/slide-pip-preview.html'),
  profile = require('./components/profile.html'),
  mainNav = require('./components/main-nav.html'),
  maya = require('./components/maya.html'),
  fileUpload = require('./components/file-upload.html'),
  addEmployeeModal = require('./components/add-employee-modal.html'),
  userList = require('./components/user-list.html')

Vue.filter('break_email', function (str) {
  if (!str) return false

  return str.replace('@', ' @')
})

Vue.filter('capitalize', function (str) {
  if(str) return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()})

})

Vue.filter('snake_to_human', function (str) {
  if(str) return str.replace(/_/g, ' ')

})

Vue.filter('moment', function(date){
  //if(date) return moment(date).format('YYYY-MM-DD')
  if(date) return moment(date).local().format('MM-DD-YYYY h:mm:ss a')
})

Vue.filter('date', function(date){
  //if(date) return moment(date).format('YYYY-MM-DD')
  if(date) return moment(date).local().format('MM-DD-YYYY')
})

Vue.transition('fade', {
  css: false,
  enter: function (el, done) {
    // element is already inserted into the DOM
    // call done when animation finishes.
    $(el)
      .css('opacity', 0)
      .animate({ opacity: 1 }, 1000, done)
  },
  enterCancelled: function (el) {
    $(el).stop()
  },
  leave: function (el, done) {
    // same as enter
    $(el).animate({ opacity: 0 }, 1000, done)
  },
  leaveCancelled: function (el) {
    $(el).stop()
  }
})

Vue.component('modal', {
  template: modal,
  props: {
    show: {
      type: Boolean,
      required: true,
      twoWay: true
    }
  }
})

Vue.component('signature', {
  template: signPip,
  props: {
    signature_text: {
      type: String,
      required: true,
      twoWay: true
    },
    handle_submit: {
      type: Function,
      required: true
    },
  },
  methods: {
    is_confirmed: function(is_confirmed){
      if(is_confirmed){
        return "is-primary"
      }else{

      }
    }
  }
})

Vue.component('slide', {
  template: slide,
  props: {
    active: {
      required: true
    },
    name: {
      required: true
    }
  },
  methods: {
    active_class: function(){
      return this.active == this.name ? 'active' : ''
    }
  }
})

Vue.component('slide-pip-preview', {
  template: slidePipPreview,
  props: ['pip','company']
})

Vue.component('profile', {
  template: profile,
  props: {
    user: {
      required: true
    },
    hidechart: {
      type: Boolean
    },
    showemail: {
      type: Boolean
    }
  }
})

Vue.component('main-nav', {
  template: mainNav,
  ready: function(){
    var hash = window.location.hash
    if (!hash) return false

    var el = $(hash)
    console.log(el)
    if (el){
      setTimeout(function(){
        $(hash).focus()
      })
    }

  },
  props: {
    user: {

    }
  },
  methods: {
    mobile_expand: function(){

    }
  }
})

Vue.component('maya', {
  template: maya,
  props: ['pos', 'content']
})

Vue.component('file-upload', {
  template: fileUpload,
  props: {
    handle_upload:{
      required: true
    }
  },
  ready: function(){
    console.log(this.files)
  },
  methods: {
    handle_click: function(){
      console.log('handle clcick file upload')
      filepicker.pickMultiple(
        {
          services: ['CLOUDDRIVE','COMPUTER','DROPBOX','GOOGLE_DRIVE','EVERNOTE','GMAIL','FTP','CLOUDAPP'],
          customCss: '//bambeecom.docker/assets/filestack.css'
        },
        function(Blobs){
          this.handle_upload(Blobs)
        }.bind(this),
        function(err){
          console.log('upload error', err)
        }
      );
    }
  }
})

Vue.component('add-employee-modal', {
  template: addEmployeeModal,
  props: {
    show: {
      type: Boolean,
      required: true,
      twoWay: true
    },
    redirect: {
      type: String,
      required: false,
      twoWay: false,
      default: false
    }
  },
  data: function(){
    return {
      modal: {
        csv: false,
        adp: false
      }
    }
  },
  methods: {
    handle_modal: function(name){
      console.log(name)
      this.modal[name] = true
    },
    handle_connect_adp: function(){
      alert('coming soon')
    }
  }
})

Vue.component('user-list', {
  template: userList,
  ready: function(){

  },
  props: {
    users: {
      type: Array,
      required: true

    },

    selected: {
      twoWay: true
    },

    single: {
      type: Boolean
    },

    click: {
      type: Function
    },

    filter: {
      type: String
    },

    show_status: {
      type: Boolean
    }
  },
  methods: {
    is_selected: function(user){
      if (this.single) return user == this.selected

      if (!this.selected) return false

      return this.selected.indexOf(user) !== -1
    },
    select_user: function(user){
      var selected = false

      if (this.single) {
        selected = this.selected == user

        if (selected) {
          this.selected = false
        }else{
          this.selected = user
        }

      }else{
        selected = this.selected.indexOf(user)

        if (selected == -1){
          this.selected.push(user)
        }else{
          this.selected.splice(selected, 1)
        }
      }


    }
  }
})

window.Vue = Vue;