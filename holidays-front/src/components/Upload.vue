<template lang="pug">
  .row
    .col-sm-12.upload-page
      b-form#upload(inline method="POST")
        label.sr-only(for="upload-file")
        b-form-file.form-control#upload-file.mb-2.mr-sm-2.mb-sm-0(
          v-model="file",
          :state="Boolean(file)",
          placeholder="Choose a file...",
          drop-placeholder="Drop file here...")
        button.form-control.btn.btn-primary(type="submit", @click.prevent="uploadFile") Upload

</template>
<script>
  import { UPLOAD_REQUEST } from "../store/constants";

  export default {
    name: 'Upload',
    data() {
      return {
        file: null
      }
    },
    methods: {
      uploadFile() {
        let formData = new FormData();
        formData.append('file', this.file);
        this.$store.dispatch('Uploads/' + UPLOAD_REQUEST, formData).then((r) => {
          console.log(r)
        })
      }
    }
  };
</script>

<style lang="sass">
  .upload-page
    padding-top: 10px
</style>

