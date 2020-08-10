<template lang="pug">
  .row
    .col-sm-12
      .row
        .col-sm-12
          filters
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
                router-link(
                  v-if="isManual(holiday)"
                  :to="{ name: 'Edit Holiday Expr', params: { id: holiday.id, holiday: holiday }}"
                )
                  a
                    b-icon(icon="pencil")

                router-link(
                  v-else
                  :to="{ name: 'New Holiday Expr' }"
                )
                  a
                    b-icon(icon="pencil")

                a(href="js:;" @click="deleteHoliday(holiday)")
                  b-icon(icon="x")

</template>

<script>
import { DESTROY_HOLIDAY } from '@/constants';
import { mapState, mapActions } from 'vuex';

export default {
  components: {
    filters: () => import('./components/filters'),
  },

  methods: {
    ...mapActions('Holidays', [DESTROY_HOLIDAY]),

    isManual(holiday) {
      return holiday.current_source_type === 'manual';
    },
    deleteHoliday(holiday) {
      this[DESTROY_HOLIDAY](holiday.id);
    },
  },
  computed: {
    ...mapState('Holidays', ['holidays']),
  }
};
</script>

<style lang="sass">
  th.dates, td.dates
    min-width: 200px
</style>
