<template lang="pug">
  .row
    .col-sm-12.login-page
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
import { AUTH_REQUEST, AUTH_LOGOUT } from '@/constants';

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
    login() {
      this.$store.dispatch('Auth/' + AUTH_REQUEST, this.user)
        .then(() => {
          this.$router.push('/')
        })
    },
    logout() {
      this.$store.dispatch(AUTH_LOGOUT)
        .then(() => {
          this.$router.push('/login')
        })
    },
  },
  computed: {
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
