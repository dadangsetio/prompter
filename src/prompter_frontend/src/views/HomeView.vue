<script setup>
import TheWelcome from '../components/TheWelcome.vue'
import { prompter_backend } from 'declarations/prompter_backend';

const { sendPrompt } = prompter_backend;

const response = ref('');
const question = ref('');

const askQuestion = async () => {
  console.log(question.value);
  response.value = await sendPrompt(1, question.value);
};
</script>

<template>
  <main>
    <input type="text" v-model="question" placeholder="Ask any question..">
    <button @click="askQuestion">Ask</button>
    <p>{{ response }}</p>
  </main>
</template>
