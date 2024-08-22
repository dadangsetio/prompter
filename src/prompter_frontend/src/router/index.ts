import { createRouter, createWebHistory } from "vue-router";
import AuthRoutes from "./AuthRoutes";
import DashboardRoutes from "./DashboardRoutes";

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/:pathMatch(.*)*",
      component: () => import("../views/authentication/Error.vue"),
    },
    AuthRoutes,
    DashboardRoutes,
  ],
});

// router.beforeEach(async (to, from, next) => {
//   const isAuthenticated = localStorage.hasOwnProperty('authenticated') ? true : false;
//   const requiredAuth = to.meta.requiredAuth;

//   if (requiredAuth) {
//     if (isAuthenticated) next();
//     else next({ name: 'Login' });
//   } else {
//     if (isAuthenticated) next({ name: 'Dashboard' });
//     else next();
//   }
// });
