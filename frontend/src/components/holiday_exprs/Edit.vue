<template lang="pug">
  .row
    .col-sm-12.pt-3
      h4 Edit Holiday Expression
      edit-form(:holiday="holiday" :edit="true", @form-submitted="sendForm")
</template>

<script>
import { PATCH_HOLIDAY_EXPR } from "../../store/constants";

export default {
  components: {
    'edit-form': () => import('./Form.vue')
  },
  data() {
    return {
      holiday_expr: null
    }
  },
  methods: {
    sendForm(payload) {
      this.$store.dispatch('Holidays/' + PATCH_HOLIDAY_EXPR, Object.assign({}, payload, { id: this.holiday.id }))
    }
  },
  computed: {
    holiday() {
      return this.$route.params.holiday
    }
  },
}
</script>
