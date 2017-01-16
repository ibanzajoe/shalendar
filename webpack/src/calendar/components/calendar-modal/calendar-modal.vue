<template>
    <transition name="modal">
        <div class="modal-mask" @click="$emit('close')">
            <div class="modal-wrapper" style="height: 100%;">
                <div class="modal-container" @click.stop>
                    <div class="modal-body">

                        <form @submit.prevent="save_calendar">
                            <p>Label: <input type="text" v-model="calendar.name"></p>
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
  props: ['calendar', 'cal'],
  components: {
    'colorpicker': Compact
  },
  data: function(){
    return {
      show_colorpicker: false,
      colors: {
        hex: this.calendar.color
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
        _this.cal.fullCalendar("refetchEvents")
      })
    }
  },
  mounted: function(){
    this.calendar.colors
  }
}
   </script>
