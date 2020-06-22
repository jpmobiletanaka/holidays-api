<template lang="pug">
  .row
    .col-sm-12.upload-page
      table.table
        tr
          th Name
          th Status
          th Last update
        tr(v-for="file in files" :id="file.id")
          td
            a(:href="file.file_info.url") {{ file.file_info.name }}
          td {{ file.status }}
          td {{ moment(file.created_at).format('MMMM Do YYYY, h:mm:ss a') }}
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
import { UPLOAD_REQUEST, GET_FILES } from '../store/constants';

export default {
  name: 'Upload',
  data() {
    return {
      file: null,
    };
  },

  mounted() {
    this.getFiles();
  },

  methods: {
    getFiles() {
      this.$store.dispatch('Uploads/' + GET_FILES);
    },
    uploadFile() {
      const formData = new FormData();
      formData.append('file', this.file);
      this.$store.dispatch('Uploads/' + UPLOAD_REQUEST, formData).then((r) => {
        console.log(r);
      });
    },
  },
  computed: {
    files() {
      return this.$store.state.Uploads.files;
    },
  },
};
</script>

<style lang="sass">
  .upload-page
    padding-top: 10px
</style>

