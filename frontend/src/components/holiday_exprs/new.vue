<template lang="pug">
  .row
    .col-sm-12.pt-3
      h4 New Holiday Expression
      div.alert.alert-warning(role="alert")
        | You are creating new holiday expression for existing holiday. This will override holiday source to "manual"

      holiday-form(:holiday="holiday" @form-submitted="sendForm")
</template>

<script>
import { POST_HOLIDAY_EXPR } from '@/constants';
import { mapActions } from 'vuex';

export default {

  data: () => ({
    status: '',
    errors: [] ,
  }),

  components: {
    holidayForm: () => import('./components/form'),
  },

  props: {
    existing: {
      default: false
    },
  },

  methods: {
    ...mapActions('Holidays', [POST_HOLIDAY_EXPR]),

    sendForm(payload) {
      this[POST_HOLIDAY_EXPR](payload)
        .then(()=> {

        });
    },
  },

  computed: {
    holiday() {
      return this.$route.params.holiday;
    }
  },
}
</script>
