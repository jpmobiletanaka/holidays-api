<template lang="pug">
  .row
    .col-sm-12
      .row
        .col-sm-12
          filters(@countries-loaded="getHolidays")
      .row
        .col-sm-12.holidays-page
          table.table
            tr
              th
              th Name (en)
              th Name (ja)
              th.dates Dates
              th Day off
              th Updated
              th
            tr(v-for="holiday in holidays" :id="holiday.id")
              td
                div
                  span.ml-1.badge.badge-primary {{ holiday.country_code }}
                  span.ml-1.badge.badge-primary(v-if="holiday.observed") observed
                  span.ml-1.badge.badge-primary {{ holiday.current_source_type }}
                  span.ml-1.badge.badge-primary(v-if="holiday.recurring") recurring

              td {{ holiday.en_name }}
              td {{ holiday.ja_name }}
              td.dates(v-html="holiday.dates.join('<br>')")
              td {{ holiday.day_off }}
              td {{ moment(holiday.updated_at).format('MMMM Do YYYY, h:mm:ss a') }}
              td
                router-link(v-if="isManual(holiday)" :to="{ name: 'Edit Holiday Expr', params: { holiday: holiday }}")
                  a
                    b-icon(icon="pencil")
                router-link(v-else :to="{ name: 'New Holiday Expr', params: { holiday: holiday, existing: true }}")
                  a
                    b-icon(icon="pencil")

</template>

<script>
import { GET_HOLIDAYS } from "../../store/constants";

export default {
  components: {
    'filters' : () => import('./Filters')
  },

  methods: {
    getHolidays(evt) {
      this.$store.dispatch('Holidays/' + GET_HOLIDAYS, evt)
    },
    isManual(holiday) {
      return holiday.current_source_type === 'manual'
    }
  },
  computed: {
    holidays() {
      return this.$store.state.Holidays.holidays
    },
    countries() {
      return this.$store.state.Countries.countries
    }
  }
};
</script>

<style lang="sass">
  th.dates, td.dates
    min-width: 200px
</style>
