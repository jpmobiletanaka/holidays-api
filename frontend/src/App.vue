<template lang="pug">
  div#app.container
    nav.navbar.navbar-expand-lg.navbar-light.bg-light
      router-link(class="navbar-brand" to="/") Holidays API
      .collapse.navbar-collapse
        ul.navbar-nav.mr-auto
          li.nav-item
            router-link(to="/upload" class="nav-link") Uploads
          li.nav-item
            router-link(to="/holidays" class="nav-link") Holidays
        a.nav-link(v-if="isAuthenticated") {{ userEmail }}
    router-view
</template>

<script>
export default {
  name: 'App',
  computed: {
    userEmail() {
      return this.$store.state.Auth.userData.email
    },
    isAuthenticated(){
      return this.$store.getters['Auth/isAuthenticated']
    }
  }
};
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}
</style>
