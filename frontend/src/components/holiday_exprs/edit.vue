<template lang="pug">
  .row
    .col-sm-12.pt-3
      h4 Edit Holiday Expression
      div.alert.alert-warning(v-if="!isManual" role="alert")
        | You are creating new holiday expression for existing holiday. This will override holiday source to "manual"

      holiday-form(:holiday="holiday" :edit="true")
</template>

<script>
  import { GET_HOLIDAY } from '@/constants';
  import { mapActions } from 'vuex';

  export default {
    data(){
      return {
        holiday: this.$route.params.holiday,
      }
    },

    components: {
      holidayForm: () => import('./components/form')
    },

    computed: {
      isManual() {
        return this.holiday && this.holiday.current_source_type === 'manual';
      },
    },

    mounted() {
      if (!this.holiday) {
        this.loadHoliday();
      }
    },

    methods: {
      ...mapActions('Holidays', [GET_HOLIDAY]),

      loadHoliday() {
        console.log('Load')
        this[GET_HOLIDAY](this.$route.params.id).then((res) => {
          this.holiday = res.data
        })
      }
    }
  }
</script>
