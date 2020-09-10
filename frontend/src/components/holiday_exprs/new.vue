<template lang="pug">
  .row
    .col-sm-12.pt-3
      h4 New Holiday Expression

      holiday-form(:holiday="holiday")
</template>

<script>

export default {
  components: {
    holidayForm: () => import('./components/form'),
  },

  computed: {
    holiday() {
      return this.$route.params.holiday
    }
  },
}
</script>
