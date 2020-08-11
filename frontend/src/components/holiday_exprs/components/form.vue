<template lang="pug">
  .row
    .col-sm-12
      .alert.alert-danger(v-if="error", role="alert")
        | {{error}}
      b-form(@submit="onSubmit" @reset="onReset" v-if="show")
        b-form-group(
          label="Name (en)"
          label-for="en_name"
        )
          b-form-input(
            v-model="holiday_expr.en_name"
            required
          )
        b-form-group(
          label="Name (ja)"
          label-for="ja_name"
        )
          b-form-input(
            v-model="holiday_expr.ja_name"
            required
          )
        b-form-group(
          label="Country"
          label-for="country"
        )
          b-form-select(
            id="country"
            :disabled="edit"
            :options="countries"
            v-model="holiday_expr.country_code"
            required
          )
        b-form-group(
          v-if="isNew"
          label="Calendar type"
          label-for="calendar-type"
        )
          b-form-select(id="calendar-type" v-model="holiday_expr.calendar_type", :options="calendar_types")
        .form-group.row
          .col-sm-1
            label
              | Day off
              b-form-checkbox(id="day-off" v-model="holiday_expr.day_off")
          .col-sm-1
            label
              | Observed
              b-form-checkbox(id="observed" v-model="holiday_expr.observed")
          .col-sm-1
            label
              | Recurring
              b-form-checkbox(id="recurring" v-model="recurring")
          .col-sm-3
            label
              | Start date
              datepicker(id="start-date" :format="datepickerFormat" v-model="start_date" valueType="format")
          .col-sm-2
            label
              | End date
              datepicker(id="end-date" :format="datepickerFormat" v-model="end_date" valueType="format")

        b-button(type="submit" variant="primary") Save
</template>

<script>
import 'vue2-datepicker/index.css';
import { mergeWith, compact, pick } from 'lodash';
import { GET_COUNTRIES, PATCH_HOLIDAY_EXPR, POST_HOLIDAY_EXPR } from '@/constants';
import { mapActions } from 'vuex';


const HOLIDAY_FIELDS = ['en_name', 'ja_name', 'country_code', 'holiday_type', 'expression']

export default {
  components: {
    'datepicker': () => import('vue2-datepicker'),
  },
  props: {
    'holiday': {
      default: null
    },
    'edit': {
      default: false
    }
  },
  data(){
    return {
      holiday_expr: {
        en_name: null,
        ja_name: null,
        country_code: null,
        holiday_type: null,
        calendar_type: 0,
        observed: false,
        day_off: true,
        expression: null
      },
      recurring: false,
      start_date: null,
      end_date: null,
      show: true,
      calendar_types: [{ text: 'gregorian', value: 0 }, { text: 'julian', value: 1 }],
      error: null,
    }
  },

  mounted(){
    this[GET_COUNTRIES]().then(() => {
      if(this.holiday) {
        this.fillFields()
      }
    })
  },
  methods: {
    ...mapActions('Holidays', [PATCH_HOLIDAY_EXPR, POST_HOLIDAY_EXPR]),
    ...mapActions('Countries', [GET_COUNTRIES]),

    fillFields() {
      this.holiday_expr = Object.assign({}, this.holiday_expr, this.holidayFields)
      this.recurring = this.holiday.recurring
      this.fillDates()
    },

    fillDates() {
      if (this.holiday) {
        this.start_date = this.formatDate(this.holiday.dates[0])
        this.end_date = this.formatDate(this.holiday.dates[this.holiday.dates.length - 1])
      }
    },

    formatDate(dateStr){
      return this.recurring ? this.moment(dateStr).format('DD-MM') : dateStr
    },

    processForm(){
      let res = this.moment(this.start_date).toObject()
      mergeWith(res, this.moment(this.end_date).toObject(), (dst, src, k) =>{
        if (k === 'months') {
          return [...new Set([dst+1, src+1])]
        } else {
          return [dst, src]
        }
      })
      if (this.recurring) {
        this.holiday_expr.expression = this.createExpression(res.months, res.date)
      } else {
        this.holiday_expr.expression = this.createExpression(res.months, res.date, res.years)
      }
    },

    createExpression(months, dates, years = []){
      if (months.length > 1) {
        return `(${compact([years[0], months[0], dates[0]]).join('.')})-(${compact([years[1], months[1], dates[1]]).join('.')})`
      } else if(dates[0] === dates[1]) {
        return compact([years[0] , months[0], dates[0]]).join('.')
      } else {
        return compact([years[0], months[0], `${dates[0]}-${dates[1]}`]).join('.')
      }
    },

    onSubmit(evt) {
      evt.preventDefault();
      this.processForm();


      this.submitForm().then(() => {
          this.$router.push('/holidays')
        }).catch((err) => {
          this.error  = err.response.data
      });
    },

    submitForm() {
      if (this.edit) {
        return this[PATCH_HOLIDAY_EXPR](Object.assign({}, this.holiday_expr, { id: this.holiday.id }))
      } else {
        return this[POST_HOLIDAY_EXPR](Object.assign({}, this.holiday_expr))
      };
    },

    onReset(evt) {
      evt.preventDefault()
      this.holiday_expr.en_name = null;
      this.holiday_expr.ja_name = null;
      this.holiday_expr.country_code = null;
      this.holiday_expr.expression = null;
    }
  },

  computed: {
    holidayFields() {
      return pick(this.holiday, HOLIDAY_FIELDS)
    },
    countries() {
      return this.$store.state.Countries.countries.map(e => {
        return { value: e.country_code, text: `${e.en_name} (${e.country_code})` }
      })
    },
    isNew() {
      return !this.edit
    },
    datepickerFormat() {
      if(this.recurring) {
        return 'MM-DD'
      } else {
        return 'YYYY-MM-DD'
      }
    }
  },
  watch: {
    recurring() {
      this.fillDates()
    }
  }
}
</script>
