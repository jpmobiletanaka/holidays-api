<template lang="pug">
  .row
    .col-sm-12.filters.pt-1
      .ml-2.mt-1
        h6 Filters
      .p-2
        .row
          .col-sm-4
            label
              | Country
              b-form-select(v-model="filters.country_codes", :options="country_code_options", multiple :select-size="4")
          .col-sm-5
            label.ml-2
              | From
              div
                datepicker(v-model="filters.from")
            label.ml-2
              | To
              div
                datepicker(v-model="filters.to")
          .col-sm-3
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
        country_codes: [],
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
      });
      return opts;
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
