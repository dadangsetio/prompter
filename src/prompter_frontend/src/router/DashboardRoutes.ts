const DashboardRoutes = {
    path: '/dashboard',
    component: () => import('@/layouts/BlankLayout.vue'),
    meta: {
        requiredAuth: true,
        requiredSuper: false
    },
    children: [
        {
            name: 'Dashboard',
            path: '/',
            component: () => import('@/views/dashboard/Dashboard.vue')
        }
    ]
};

export default DashboardRoutes;
