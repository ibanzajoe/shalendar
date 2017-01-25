<template>


  <transition name="modal">
    <div class="modal-mask" @click="$emit('close')">
      <div class="modal-wrapper" style="height: 100%;">
        <form @submit.prevent="handle_save_calendar">
          <div class="modal-container" @click.stop>
            <div class="modal-body">
              <h3 class="title">Update Calendar</h3>


              <label class="label">Label</label>
              <p class="control">
                <input class="input is-success" type="text" v-model="calendar.name">
              </p>
              <label class="label">Color</label>
              <p class="control">
                <div style="cursor: pointer; width: 40px; height: 40px;" :style="{backgroundColor: calendar.color}" @click="show_colorpicker = true" v-model="calendar.color"></div>
              </p>

              <colorpicker v-if="show_colorpicker" v-model="colors" @change-color="handle_color"></colorpicker>

              <br><br>
              <a class="is-pulled-left link is-warning is-outlined modal-default-button" style="color: red;" @click="handle_delete_calendar">delete</a>

              <button class="button is-pulled-right is-success">Save</button>


            </div>
          </div>


        </form>

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
       handle_delete_calendar: function(){
         alert('delete it')
       },
       handle_save_calendar: function(){
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
