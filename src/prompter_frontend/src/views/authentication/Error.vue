<template>
  <div class="error-page">
    <h1>Oops! Terjadi Kesalahan</h1>
    <p>Maaf, halaman yang Anda cari tidak ditemukan. Silakan coba kembali ke halaman utama.</p>
    <router-link to="/">Kembali ke Beranda</router-link>
  </div>
</template>

<script>
export default {
  name: 'ErrorPage'
}
</script>

<style scoped>
.error-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: #f5f5f5;
}

.error-page h1 {
  color: #333;
  margin-bottom: 20px;
}

.error-page p {
  color: #666;
  margin-bottom: 40px;
}

.error-page a {
  background-color: #007bff;
  color: white;
  padding: 10px 20px;
  border-radius: 20px;
  text-decoration: none;
  transition: background-color 0.3s ease;
}

.error-page a:hover {
  background-color: #0056b3;
}
</style>
