const AuthRoutes = {
    path: '/auth',
    component: () => import('@/layouts/BlankLayout.vue'),
    meta: {
        requiredAuth: false,
        requiredSuper: false
    },
    children: [

        {
            name: 'Login',
            path: '/auth/login',
            component: () => import('@/views/authentication/BoxedLogin.vue')
        }
    ]
};

export default AuthRoutes;
