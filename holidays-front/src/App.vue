<template lang="pug">
  div#app.container
    nav.navbar.navbar-light.bg-light
      a.navbar-brand Holidays API
      a.navbar {{ userEmail }}
    router-view
</template>

<script>
export default {
  name: 'App',
  computed: {
    userEmail() {
      return this.$store.state.Auth.userData.email
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
