<template lang="pug">
  .row
    .col-sm-12.filters.pt-1
      .ml-2.mt-1
        h6 Filters
      .p-2
        label
          | Country
          b-form-select(v-model="filters.country_code", :options="country_code_options")
        label.ml-2
          | From
          div
            datepicker(v-model="filters.from")
        label.ml-2
          | To
          div
            datepicker(v-model="filters.to")
        .float-right
          router-link(:to="{name: 'New Holiday Expr'}")
            button.btn.btn-primary New holiday
</template>

<script>
import { GET_COUNTRIES } from "@/constants";
import 'vue2-datepicker/index.css';

export default {
  components: {
    'datepicker': () => import('vue2-datepicker')
  },
  data() {
    return {
      filters: {
        country_code: null,
        from: null,
        to: null
      }
    }
  },
  mounted() {
    this.getCountries()
  },
  methods: {
    getCountries() {
      this.$store.dispatch('Countries/' + GET_COUNTRIES).then(res => {
        this.$emit('countries-loaded', this.filters)
      })
    }
  },
  computed: {
    country_code_options() {
      let opts = this.$store.state.Countries.countries.map(e => {
        return { value: e.country_code, text: `${e.en_name} (${e.country_code})` }
      })
      opts.unshift({ value: null, text: 'All' })
      return opts
    },
    current_source_type_options() {
      return ['google', 'file', 'manual']
    }
  },
  watch: {
    filters: {
      handler() {
        this.$emit('countries-loaded', this.filters)
      },
      deep: true
    }
  }
};
</script>
