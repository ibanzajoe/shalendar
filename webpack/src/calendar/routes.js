const {
  setup,
  settings,
  dashboard,
  ping,
  createEmployee,
  myEmployee,
  myEmployees,
  myPips,
  pipCreate,
  pip,
  managerAssignEmployees,
  employee,
  employeeAssignManager,
  employeeOnboard,
  terms,
  privacy,
  importRequest
} = require('./pages'),
  store = require('./store')

module.exports = [
  {
    path: '/',
    component: dashboard,
    beforeEnter (to, from, next) {
      if (store.state.current_user.role == 'admin') return next()

      next('/setup')
    }
  },
  { path: '/terms', component: terms },
  { path: '/privacy', component: privacy },
  { path: '/settings', component: settings },
  { path: '/setup', component: setup },

  { path: '/import-request', component: importRequest },
  { path: '/ping', component: ping },
  { path: '/employee/create/:employee_type?', component: createEmployee },
  { path: '/my/employee/:employee_id?', component: myEmployee },
  { path: '/my/employees/:filter_type?', component: myEmployees },
  { path: '/my/pips/:filter_type?', component: myPips },
  {
    path: '/pip/create/:pip_type',
    component: pipCreate
  },
  { path: '/pip/:pip_id', component: pip },
  { path: '/manager/:manager_id/assign-employees', component: managerAssignEmployees },
  { path: '/employee/:employee_id/assign-manager', component: employeeAssignManager },

  { path: '/employee', component: employee },
  { path: '/employee/onboard', component: employeeOnboard }
]