<template>
  <transition name="modal">
    <div class="modal-mask" @click="$emit('close')">
      <div class="modal-wrapper" style="height: 100%;">
        <div class="modal-container" @click.stop>
          <div class="modal-body">

            <form @submit.prevent="save_calendar">
              <p>Calendar: <input type="text" v-model="calendar.name"></p>
              <p>Color: <input type="text" v-model="calendar.color" @click="show_colorpicker = true"></p>
              <colorpicker v-if="show_colorpicker" v-model="colors" @change-color="handle_color"></colorpicker>

              <button>Save</button>
            </form>

          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>

const { Compact } = require('vue-color')

// calendar modal
module.exports = {
  props: ['calendar'],
  components: {
    'colorpicker': Compact
  },
  data: function(){
    return {
      show_colorpicker: false,
      colors: {
        hex: '#194d33',
        hsl: {
          h: 150,
          s: 0.5,
          l: 0.2,
          a: 1
        },
        hsv: {
          h: 150,
          s: 0.66,
          v: 0.30,
          a: 1
        },
        rgba: {
          r: 25,
          g: 77,
          b: 51,
          a: 1
        },
        a: 1
      }
    }
  },
  methods: {
    handle_color: function(val) {
      this.calendar.color = val.hex
      this.show_colorpicker = false
    },
    save_calendar: function(){
      var _this = this
      console.log('post to calendar', this.calendar)
      $.post("/api/calendar", this.calendar, function(res){
        console.log(res)
        _this.$emit("close")
        alert('wtf')
      })
    }
  },
  mounted: function(){

  }
}
</script>
