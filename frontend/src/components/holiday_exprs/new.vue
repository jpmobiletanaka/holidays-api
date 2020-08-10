<template lang="pug">
  .row
    .col-sm-12.pt-3
      h4 New Holiday Expression
      div.alert.alert-warning(role="alert")
        | You are creating new holiday expression for existing holiday. This will override holiday source to "manual"

      holiday-form
</template>

<script>

export default {
  components: {
    holidayForm: () => import('./components/form'),
  },
}
</script>
