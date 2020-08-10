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
              b-form-select(
                v-model="filters.country_codes",
                :options="country_code_options",
                multiple :select-size="4",
                @change="changeFilters"
              )
          .col-sm-5
            label.ml-2
              | From
              div
                datepicker(v-model="filters.from", @change="changeFilters")
            label.ml-2
              | To
              div
                datepicker(v-model="filters.to", @change="changeFilters")
          .col-sm-3
            .float-right
              router-link(:to="{name: 'New Holiday Expr'}")
                button.btn.btn-primary New holiday
</template>

<script>
import { GET_COUNTRIES, GET_HOLIDAYS } from '@/constants';
import { mapActions, mapState } from 'vuex';
import 'vue2-datepicker/index.css';

export default {
  components: {
    datepicker: () => import('vue2-datepicker'),
  },
  data() {
    return {
      filters: {
        country_codes: [],
        from: null,
        to: null,
      },
    };
  },

  mounted() {
    this[GET_COUNTRIES]().then(() => this[GET_HOLIDAYS](this.filters));
  },

  methods: {
    ...mapActions('Holidays', [GET_HOLIDAYS]),
    ...mapActions('Countries', [GET_COUNTRIES]),

    changeFilters() {
      this[GET_HOLIDAYS](this.formattedFilters());
    },

    formattedFilters() {
      const filters = { country_codes: this.filters.country_codes };
      if (this.filters.from) {
        filters.from = this.moment(this.filters.from).format('YYYY-MM-DD');
      }
      if (this.filters.to) {
        filters.to = this.moment(this.filters.to).format('YYYY-MM-DD');
      }
      return filters;
    },
  },

  computed: {
    ...mapState('Countries', ['countries']),

    country_code_options() {
      return this.countries.map((e) => {
        const result = {};
        result.value = e.country_code;
        result.text = `${e.en_name} (${e.country_code})`;
        return result;
      });
    },
  } };
</script>
