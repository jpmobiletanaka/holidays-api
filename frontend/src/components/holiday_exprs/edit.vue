<template lang="pug">
  .row
    .col-sm-12.pt-3
      h4 Edit Holiday Expression
      holiday-form(:holiday="holiday" :edit="true")
</template>

<script>
  import { PATCH_HOLIDAY_EXPR } from '@/constants';
  import { mapActions } from 'vuex';

  export default {
    components: {
      holidayForm: () => import('./components/form')
    },
    data() {
      return {
        holiday_expr: null
      }
    },
    methods: {
      ...mapActions('Holidays', [PATCH_HOLIDAY_EXPR]),

      sendForm(payload) {
        this[PATCH_HOLIDAY_EXPR](Object.assign({}, payload, { id: this.holiday.id }))
      }
    },
    computed: {
      holiday() {
        return this.$route.params.holiday
      }
    },
  }
</script>
