<template>
  <div class="dashboard">
    <h1>Selamat Datang di Dashboard</h1>
    <p>Ini adalah tampilan dashboard Anda.</p>
    <button @click="login">Auth</button>
    <p v-if="principal">Principal Anda: {{ principal }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { AuthClient } from "@dfinity/auth-client";
import { Actor, HttpAgent, Identity } from "@dfinity/agent";
import { prompter_backend } from 'declarations/prompter_backend';

const dashboardData = ref({
  title: 'Dashboard',
  description: 'Tampilan dashboard ini menampilkan informasi dasar tentang aplikasi Anda.'
});

const principal = ref('');
const BACKEND_CANISTER_ID = 'bkyz2-fmaaa-aaaaa-qaaaq-cai';

let _identity: Identity | null = null;

const idlFactory = ({ IDL }: { IDL: any }) => {
  return IDL.Service({
    whoami: IDL.Func([], [IDL.Principal], ["query"])
  });
};

const login = async () => {
  try {
    
    let host;
    if (process.env.DFX_NETWORK === "local") {
      host = `http://localhost:4943/?canisterId=${process.env.CANISTER_ID_INTERNET_IDENTITY}`;
    } else if (process.env.DFX_NETWORK === "ic") {
      host = `https://${process.env.CANISTER_ID_INTERNET_IDENTITY}.ic0.app`;
    } else {
      host = `https://${process.env.CANISTER_ID_INTERNET_IDENTITY}.dfinity.network`;
    }
    
    _identity = await new Promise(async (resolve, reject) => {
      let timer: any = setTimeout(() => {
        timer = null;
        reject('Autentikasi II timeout!');
      }, 120 * 1000);

      const authClient = await AuthClient.create();
      authClient.login({
        maxTimeToLive: BigInt(24 * 60 * 60 * 1000000000),
        identityProvider: host,
        onSuccess: async () => {
          if (timer != null) {
            clearTimeout(timer);
            timer = null;
          }
          let identity = await authClient.getIdentity();
          resolve(identity);
        },
        onError: (err) => {
          if (timer != null) {
            clearTimeout(timer);
            timer = null;
          }
          reject(err);
        }
      });
    });

    if (_identity) {
      const result = await prompter_backend.whoami();
      principal.value = result.toText();
      console.log(`Login berhasil. Principal: ${principal.value}`);
    }
  } catch (error) {
    console.error(`Gagal login: ${error}`);
  }
};

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