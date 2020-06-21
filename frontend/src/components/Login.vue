<template lang="pug">
  .row
    .col-sm-12.login-page
      .alert.alert-danger(v-if="isUnauthorized", role="alert")
        Invalid Email Or Password
      b-form(inline)
        b-form-group(
          class="mb-2 mr-sm-2 mb-sm-0"
          id="email-group"
          :state="emailState"
        )
          b-input#email(type="email", v-model="email")
        b-form-group(
          class="mb-2 mr-sm-2 mb-sm-0"
          id="password-group"
          :state="passwordState"
        )
          b-input#password(type="password", v-model="password")
        b-form-group(
          class="mb-2 mr-sm-2 mb-sm-0"
          id="submit"
        )
          button.btn.btn-primary(type="submit", @click.prevent="login") Login

</template>
<script>
import { AUTH_REQUEST } from "../store/constants";
import { mapState, mapActions } from 'vuex';

export default {
  name: 'Login',
  data() {
    return {
      emailState: null,
      passwordState: null,
      email: null,
      password: null,
    }
  },
  methods: {
    ...mapActions('Auth', [AUTH_REQUEST]),

    login() {
      this[AUTH_REQUEST](this.user)
        .then(() => {
          this.$router.push('/')
        })
    },
  },
  computed: {
    ...mapState('Auth', ['status']),
    isUnauthorized() {
      return this.status.status === 401;
    },

    user() {
      return { email: this.email, password: this.password }
    }
  }
};
</script>

<style lang="sass">
  .login-page
    padding-top: 20px
</style>
