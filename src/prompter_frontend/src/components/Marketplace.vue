<template>
  <div class="flex flex-col h-screen bg-gray-900 text-white">
    <!-- Navigation -->
    <nav class="bg-gray-800 p-4 flex justify-between items-center">
      <h1 class="text-xl font-bold">Prompter</h1>
      <div class="flex items-center space-x-4">
        <button class="px-4 py-2 bg-blue-500 rounded hover:bg-blue-600">New chat</button>
        <div class="relative">
          <ShoppingCart class="text-gray-300" />
          <span v-if="cartItems > 0" class="absolute -top-2 -right-2 bg-red-500 rounded-full w-5 h-5 flex items-center justify-center text-xs">
            {{ cartItems }}
          </span>
        </div>
      </div>
    </nav>
    
    <!-- Main Content -->
    <div class="flex-1 p-6 overflow-auto">
      <h2 class="text-2xl font-bold mb-4">Marketplace</h2>
      <!-- Search Bar -->
      <div class="mb-4 relative">
        <input
          v-model="searchTerm"
          type="text"
          placeholder="Search marketplace..."
          class="w-full p-2 bg-gray-700 rounded-md pr-10"
        />
        <Search class="absolute right-3 top-2.5 text-gray-400" />
      </div>
      <!-- Marketplace Items -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div v-for="item in mockItems" :key="item.id" class="bg-gray-800 p-4 rounded-lg">
          <h3 class="font-semibold">{{ item.name }}</h3>
          <p class="text-gray-400">{{ item.price }}</p>
          <button
            @click="addToCart"
            class="mt-2 px-4 py-2 bg-green-500 rounded hover:bg-green-600"
          >
            Add to Cart
          </button>
        </div>
      </div>
    </div>
    
    <!-- Bottom Input -->
    <div class="bg-gray-800 p-4">
      <input
        type="text"
        placeholder="Ask anything..."
        class="w-full p-2 bg-gray-700 rounded-md"
      />
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { ShoppingCart, Search } from 'lucide-vue-next'

export default {
  components: {
    ShoppingCart,
    Search
  },
  setup() {
    const searchTerm = ref('')
    const cartItems = ref(0)
    const mockItems = ref([
      { id: 1, name: 'Premium Prompt Pack', price: '$9.99' },
      { id: 2, name: 'AI Writing Assistant', price: '$19.99' },
      { id: 3, name: 'Code Generation Tool', price: '$14.99' },
    ])

    const addToCart = () => {
      cartItems.value++
    }

    return {
      searchTerm,
      cartItems,
      mockItems,
      addToCart
    }
  }
}
</script>