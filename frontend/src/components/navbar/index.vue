<template lang="pug">
  b-navbar(toggleable="lg" type="light" variant="light")
    b-navbar-brand(to="/") Holidays API

    b-navbar-toggle(target="nav-collapse")

    b-collapse(id="nav-collapse" is-nav='')
      b-navbar-nav
        b-nav-item(to="/holidays") Holidays
        b-nav-item(to="/uploads") Uploads

      <!-- Right aligned nav items -->
      b-navbar-nav(v-if="isAuthenticated" class="ml-auto")
        b-nav-item-dropdown(:text="userData.email", right='')
          b-dropdown-item(href="#", @click.prevent="logout") Logout
      b-navbar-nav(v-else class="ml-auto")
        b-nav-item(to="/login") Login
</template>
<script>
import { AUTH_LOGOUT } from "../../store/constants";
import { mapState, mapGetters, mapActions } from 'vuex';

export default {
name: 'Navbar',
computed: {
  ...mapState('Auth', ['userData']),
  ...mapGetters('Auth', ['isAuthenticated']),
},
methods: {
  ...mapActions('Auth', [AUTH_LOGOUT]),

  logout() {
    this[AUTH_LOGOUT]().then(() => { this.$router.push('/login') })
  },
}
};
</script>
