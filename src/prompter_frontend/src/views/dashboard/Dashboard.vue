<template>
  <div class="dashboard">
    <h1>Selamat Datang di Dashboard</h1>
    <p>Ini adalah tampilan dashboard Anda.</p>
    <button @click="login()">Auth</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const dashboardData = ref({
  title: 'Dashboard',
  description: 'Tampilan dashboard ini menampilkan informasi dasar tentang aplikasi Anda.'
});

import * as identity from "@dfinity/identity";

const login = async () => {
  try {
    console.log(`Login berhasil`);
    // Tambahkan logika setelah login berhasil di sini, seperti mengarahkan ke halaman lain
  } catch (error) {
    console.error(`Gagal login: ${error}`);
  }
}


</script>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: #f5f5f5;
}

.dashboard h1 {
  color: #333;
  margin-bottom: 20px;
}

.dashboard p {
  color: #666;
}
</style>
