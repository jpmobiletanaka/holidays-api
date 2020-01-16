<template lang="pug">
  .row
    .col-sm-12.pt-3
      h4 New Holiday Expression
      div.alert.alert-warning(role="alert" v-if="isExisting")
        | You are creating new holiday expression for existing holiday. This will override holiday source to "manual"

      new-form(:holiday="holiday" :isExisting="isExisting" @form-submitted="sendForm")
</template>

<script>
import { POST_HOLIDAY_EXPR } from "../../store/constants";

export default {
  components: {
    'new-form': () => import('./Form.vue')
  },
  props: {
    existing: {
      default: false
    }
  },
  methods: {
    sendForm(payload) {
      this.$store.dispatch('Holidays/' + POST_HOLIDAY_EXPR, payload)
    }
  },
  computed: {
    holiday() {
      return this.$route.params.holiday
    },
    isExisting() {
      return this.$route.params.existing
    }
  },
}
</script>
