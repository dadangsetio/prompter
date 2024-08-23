<template>
  <div class="chat" ref="currentMsg">
    <div
      v-if="!chat.isAi"
      class="
        w-full
        border-b border-black/10
        dark:border-gray-900/50
        text-gray-800
        dark:text-gray-100
        group
        dark:bg-gray-800
      "
    >
      <div
        class="
          text-base
          gap-4
          md:gap-6
          m-auto
          md:max-w-2xl
          lg:max-w-2xl
          xl:max-w-3xl
          p-4
          md:py-6
          flex
          lg:px-0
        "
      >
        <div class="w-[30px] flex flex-col relative items-end">
          <div
            class="
              relative
              h-[30px]
              w-[30px]
              p-1
              rounded-sm
              text-white
              flex
              items-center
              justify-center
            "
            style="background-color: rgb(16, 163, 127)"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor"
            >
              <title>account-badge</title>
              <path
                d="M14 19.5C14 17.5 15.1 15.7 16.7 14.8C15.4 14.3 13.8 14 12 14C7.6 14 4 15.8 4 18V20H14V19.5M19.5 16C17.6 16 16 17.6 16 19.5S17.6 23 19.5 23 23 21.4 23 19.5 21.4 16 19.5 16M16 8C16 10.2 14.2 12 12 12S8 10.2 8 8 9.8 4 12 4 16 5.8 16 8Z"
              />
            </svg>
          </div>
        </div>
        <div
          class="
            relative
            flex
            w-[calc(100%-50px)]
            flex-col
            gap-1
            md:gap-3
            lg:w-[calc(100%-115px)]
          "
        >
          <div class="flex flex-grow flex-col gap-3">
            <div
              class="
                min-h-[20px]
                flex flex-col
                items-start
                gap-4
                whitespace-pre-wrap
              "
            >
              {{ chat.value }}

              <div v-for="(message, index) in messages" :key="index + 'sdf'">
                <span v-if="index === currentMessage">{{ currentChar }}</span>
                <span v-else>{{ message }}</span>
              </div>
            </div>
          </div>
          <div
            class="
              text-gray-400
              flex
              self-end
              lg:self-center
              justify-center
              mt-2
              gap-3
              md:gap-4
              lg:gap-1
              lg:absolute
              lg:top-0
              lg:translate-x-full
              lg:right-0
              lg:mt-0
              lg:pl-2
              visible
            "
          >
            <button
              class="
                p-1
                rounded-md
                hover:bg-gray-100
                hover:text-gray-700
                dark:text-gray-400
                dark:hover:bg-gray-700
                dark:hover:text-gray-200
                disabled:dark:hover:text-gray-400
                md:invisible
                md:group-hover:visible
              "
            >
              <svg
                stroke="currentColor"
                fill="none"
                stroke-width="2"
                viewBox="0 0 24 24"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="h-4 w-4"
                height="1em"
                width="1em"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"
                ></path>
                <path
                  d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"
                ></path>
              </svg>
            </button>
          </div>
          <div class="flex justify-between"></div>
        </div>
      </div>
    </div>
    <div
      v-else
      class="
        w-full
        border-b border-black/10
        dark:border-gray-900/50
        text-gray-800
        dark:text-gray-100
        group
        bg-gray-50
        dark:bg-[#444654]
      "
    >
      <div
        class="
          text-base
          gap-4
          md:gap-6
          m-auto
          md:max-w-2xl
          lg:max-w-2xl
          xl:max-w-3xl
          p-4
          md:py-6
          flex
          lg:px-0
        "
      >
        <div class="w-[30px] flex flex-col relative items-end">
          <div
            class="
              relative
              h-[30px]
              w-[30px]
              p-1
              rounded-sm
              text-white
              flex
              items-center
              justify-center
            "
            style="background-color: rgb(16, 163, 127)"
          >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
            class="h-6 w-6"
          >
            <path d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2zm0 18a8 8 0 100-16 8 8 0 000 16zm.75-11.25h-1.5v-1.5h-1.5v1.5h-1.5v1.5h1.5v1.5h1.5v-1.5h1.5v-1.5z" />
          </svg>
          </div>
        </div>
        <div
          class="
            relative
            flex
            w-[calc(100%-50px)]
            flex-col
            gap-1
            md:gap-3
            lg:w-[calc(100%-115px)]
          "
        >
          <div class="flex flex-grow flex-col gap-3">
            <div
              class="
                min-h-[20px]
                flex flex-col
                items-start
                gap-4
                whitespace-pre-wrap
              "
            >
              <div
                class="
                  markdown
                  prose
                  w-full
                  break-words
                  dark:prose-invert
                  light
                "
              >
                <p>
                  {{ currentChar }}
                </p>
              </div>
            </div>
          </div>
          <div class="flex justify-between">
            <div
              class="
                text-gray-400
                flex
                self-end
                lg:self-center
                justify-center
                mt-2
                gap-3
                md:gap-4
                lg:gap-1
                lg:absolute
                lg:top-0
                lg:translate-x-full
                lg:right-0
                lg:mt-0
                lg:pl-2
                visible
              "
            >
              <button
                class="
                  p-1
                  rounded-md
                  hover:bg-gray-100
                  hover:text-gray-700
                  dark:text-gray-400
                  dark:hover:bg-gray-700
                  dark:hover:text-gray-200
                  disabled:dark:hover:text-gray-400
                "
              >
                <svg
                  stroke="currentColor"
                  fill="none"
                  stroke-width="2"
                  viewBox="0 0 24 24"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="h-4 w-4"
                  height="1em"
                  width="1em"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"
                  ></path>
                </svg></button
              ><button
                class="
                  p-1
                  rounded-md
                  hover:bg-gray-100
                  hover:text-gray-700
                  dark:text-gray-400
                  dark:hover:bg-gray-700
                  dark:hover:text-gray-200
                  disabled:dark:hover:text-gray-400
                "
              >
                <svg
                  stroke="currentColor"
                  fill="none"
                  stroke-width="2"
                  viewBox="0 0 24 24"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="h-4 w-4"
                  height="1em"
                  width="1em"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17"
                  ></path>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { nextTick, onMounted, ref, watch, computed } from "vue";
const props = defineProps({
  chat: {
    type: Object || null,
  },
});

let test = ref("");

let currentChar = ref("");
let typingSpeed = ref(20);
let currentMsg = ref(null);

const getData = computed(() => {
  return props.chat;
});

const wait = (time) => {
  return new Promise((resolve) => setTimeout(resolve, time));
};

onMounted(async () => {
  await nextTick();
  const div = currentMsg.value;
  div.scrollIntoView({ behavior: "smooth" });
});

watch(
  getData,
  async (newValue, oldValue) => {
    const fetchMessages = async () => {
      if (newValue.isAi) {
        for (let i = 0; i < newValue.value.length; i++) {
          await wait(typingSpeed.value);
          currentChar.value = newValue.value.slice(0, i + 1);
        }
        // await wait(100);
      }
    };
    fetchMessages();
  },
  { immediate: true }
);
</script>

<style scoped>
span {
  display: inline-block;
  font-size: 20px;
  font-weight: bold;
}
</style>
