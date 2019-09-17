#modify Chai's smooth square function into a tanh form because it is constant at the plateau. It is the best square wave function. See MATLAB script named tanh_switching_function regarding how this function is derived. (u is how long the function was shifted along x axis)
#use L=s1s2(L12-Lb) + s2s3(L23-Lb) + Lb
#unit of lengh is nm
#modified IC of mu_o; equlibrium concentration of oxygen in metal and oxide phases should be consistant with the parabolic equation rather than the common tangent concentration
#make oxygen phase free energy have the same common tangent line as the other two phases, and tangent point (1, -2.45)
#change parabolic coeff from 3.2 to 6.4, bacause in the free energy equation, it is defined as k/2
#increased nl_abs_tol from 1e-7 to 1e-5, otherwise convergence is very bad

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 300
  xmin = 0
  xmax = 300
  ny = 1
  ymin = 0
  ymax = 100
[]

# [GlobalParams]
#   Va = '13.8'
#   k_metal = '3.2'
#   k_oxide = '3.2'
#   k_gas = '3.2'
#   cmetal_eq = '0.03125'
#   coxide_eq = '0.78125'
#   cgas_eq = '1'
# []

[Variables]
  [./mu_o]
  [../]
  [./eta_metal]
  [../]
  [./eta_oxide]
  [../]
  [./eta_gas]
  [../]
[]

# [BCs]
#   [./mu_o]
#     type = DirichletBC
#     variable = mu_o
#     boundary = right
#     value = 0
#   [../]
# []

[ICs]
  [./IC_mu_o_metal]
    type = FunctionIC
    variable = mu_o
    #function = 'if(x<100, -8.832, if(x<130, -44.16, 0))'
    #function = 'if(x<100, -4.416e-3, if(x<130, -22.08, 0))'
    function = '0'
  [../]

  [./IC_eta_metal]
    type = BoundingBoxIC
    variable = eta_metal
    x1 = 0
    x2 = 100
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
  [./IC_eta_oxide]
    type = BoundingBoxIC
    variable = eta_oxide
    x1 = 100
    x2 = 130
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
  [./IC_eta_gas]
    type = BoundingBoxIC
    variable = eta_gas
    x1 = 130
    x2 = 300
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
[]

[Kernels]
#order parameter eta_metal
[./ACmetal_bulk]
  type = ACGrGrMulti
  variable = eta_metal
  v = 'eta_oxide eta_gas'
  gamma_names = 'g_oxide g_gas'
  mob_name = L
[../]
[./ACmetal_sw]
  type = ACSwitching
  variable = eta_metal
  Fj_names = 'omega_metal omega_oxide omega_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_oxide eta_gas mu_o'
  mob_name = L
[../]
[./ACmetal_int]
  type = ACInterface
  variable = eta_metal
  kappa_name = kappa
  mob_name = L
[../]
[./metal_td]
  type = TimeDerivative
  variable = eta_metal
[../]
#order parameter eta_oxide
[./ACoxide_bulk]
  type = ACGrGrMulti
  variable = eta_oxide
  v = 'eta_metal eta_gas'
  gamma_names = 'g_metal g_gas'
  mob_name = L
[../]
[./ACoxide_sw]
  type = ACSwitching
  variable = eta_oxide
  Fj_names = 'omega_metal omega_oxide omega_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_metal eta_gas mu_o'
  mob_name = L
[../]
[./ACoxide_int]
  type = ACInterface
  variable = eta_oxide
  kappa_name = kappa
  mob_name = L
[../]
[./oxide_td]
  type = TimeDerivative
  variable = eta_oxide
[../]
#order parameter eta_gas
[./ACgas_bulk]
  type = ACGrGrMulti
  variable = eta_gas
  v = 'eta_metal eta_oxide'
  gamma_names = 'g_metal g_oxide'
  mob_name = L
[../]
[./ACgas_sw]
  type = ACSwitching
  variable = eta_gas
  Fj_names = 'omega_metal omega_oxide omega_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_metal eta_oxide mu_o'
  mob_name = L
[../]
[./ACgas_int]
  type = ACInterface
  variable = eta_gas
  kappa_name = kappa
  mob_name = L
[../]
[./gas_td]
  type = TimeDerivative
  variable = eta_gas
[../]
#chemical potential
[./mu_std]
  type = SusceptibilityTimeDerivative
  variable = mu_o
  f_name = chi
  args = mu_o  #or args = ' '?
[../]
[./diffusion]
  type = MatDiffusion
  variable = mu_o
  diffusivity = M_o
  args = ' '  #correct?
[../]
[./coupled_eta_metal]
  type = CoupledSwitchingTimeDerivative
  variable = mu_o
  v = eta_metal
  Fj_names = 'rho_metal rho_oxide rho_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_metal eta_oxide eta_gas'
[../]
[./coupled_eta_oxide]
  type = CoupledSwitchingTimeDerivative
  variable = mu_o
  v = eta_oxide
  Fj_names = 'rho_metal rho_oxide rho_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_metal eta_oxide eta_gas'
[../]
[./coupled_eta_gas]
  type = CoupledSwitchingTimeDerivative
  variable = mu_o
  v = eta_gas
  Fj_names = 'rho_metal rho_oxide rho_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_metal eta_oxide eta_gas'
[../]
[]

[Materials]
[./constants]
  type = GenericConstantMaterial #what is mu??? I don't need it in my equations but is somehow required -- mu is m in larry paper
  prop_names = 'g_metal g_oxide g_gas   Va     D  cmetal_eq coxide_eq cgas_eq k_metal k_oxide k_gas  interface_energy_sigma interface_thickness_l bulk_mobility phase_mobility_12 phase_mobility_23 phase_mobility_13 u    pi     delta'
  prop_values = '1.5    1.5     1.5     13.8  1e8    1e-1       0.5      1      6.4     6.4    6.4   10                   10                      0.4e4           0.3e4                  0.5e4             0.6e4      0.07 3.1416 0.0001'
[../]
[./m]
  type = ParsedMaterial
  f_name = mu
  material_property_names = 'interface_energy_sigma interface_thickness_l'
  function = '6*interface_energy_sigma/interface_thickness_l'
[../]
[./kappa] #assume that three interfaces having the same interfacial energy and thickness
  type = ParsedMaterial
  f_name = kappa
  material_property_names = 'interface_energy_sigma interface_thickness_l'
  function = '3*interface_energy_sigma*interface_thickness_l/4'
[../]

[./L12]
  type = ParsedMaterial
  f_name = L12
  material_property_names = 'phase_mobility_12 interface_thickness_l'
  function = '4*phase_mobility_12/3/interface_thickness_l'
[../]
[./L23]
  type = ParsedMaterial
  f_name = L23
  material_property_names = 'phase_mobility_23 interface_thickness_l'
  function = '4*phase_mobility_23/3/interface_thickness_l'
[../]
[./L13]
  type = ParsedMaterial
  f_name = L13
  material_property_names = 'phase_mobility_13 interface_thickness_l'
  function = '4*phase_mobility_13/3/interface_thickness_l'
[../]
[./L_bulk]
  type = ParsedMaterial
  f_name = L_bulk
  material_property_names = 'bulk_mobility interface_thickness_l'
  function = '4*bulk_mobility/3/interface_thickness_l'
[../]

[./L_switch_metal]
  type = ParsedMaterial
  f_name = L_switch_metal
  args = 'eta_metal'
  material_property_names = 'u pi delta'
  function = '1/2*tanh(sin(pi*(1/(1 - 2*u))*(eta_metal - u))/delta) + 1/2'
[../]
[./L_switch_oxide]
  type = ParsedMaterial
  f_name = L_switch_oxide
  args = 'eta_oxide'
  material_property_names = 'u pi delta'
  function = '1/2*tanh(sin(pi*(1/(1 - 2*u))*(eta_oxide - u))/delta) + 1/2'
[../]
[./L_switch_gas]
  type = ParsedMaterial
  f_name = L_switch_gas
  args = 'eta_gas'
  material_property_names = 'u pi delta'
  function = '1/2*tanh(sin(pi*(1/(1 - 2*u))*(eta_gas - u))/delta) + 1/2'
[../]

[./L]
  type = ParsedMaterial
  f_name = L
  args = 'eta_metal eta_oxide eta_gas'
  material_property_names = 'L_switch_metal L_switch_oxide L_switch_gas L12 L23 L13 L_bulk'
  #function = 'L_switch_metal*((L12 + L13 - L23 - L_bulk)/2) + L_switch_oxide*((L23 + L12 - L13 - L_bulk)/2) + L_switch_gas*((L13 + L23 - L12 - L_bulk)/2) + L_bulk'
  function = 'L_switch_metal*L_switch_oxide*(L12 - L_bulk) + L_switch_oxide*L_switch_gas*(L23 - L_bulk) + L_bulk'
  outputs = exodus
[../]
[./view_L]
  type = ParsedMaterial
  f_name = view_L
  args = 'eta_metal eta_oxide eta_gas'
  material_property_names = 'L L_bulk'
  function = 'L/L_bulk'
  outputs = exodus
[../]

[./chi]
  type = DerivativeParsedMaterial
  f_name = chi
  args = mu_o
  material_property_names = 'Va switch_metal switch_oxide switch_gas k_metal k_oxide k_gas'
  function = '(switch_metal/k_metal + switch_oxide/k_oxide + switch_gas/k_gas)/Va^2'
  derivative_order = 2
[../]
[./mobility]
  type = DerivativeParsedMaterial
  f_name = M_o
  material_property_names = 'chi D'
  function = 'chi*D'
  derivative_order = 2
[../]
[./oxygen_concentration]
  type = ParsedMaterial
  f_name = o_concentration
  args = mu_o
  material_property_names = 'switch_metal switch_oxide switch_gas rho_metal rho_oxide rho_gas Va'
  function = 'Va*(switch_metal*rho_metal + switch_oxide*rho_oxide + switch_gas*rho_gas)'
  outputs = exodus
[../]


[./switch_metal]
  type = SwitchingFunctionMultiPhaseMaterial
  h_name = switch_metal
  all_etas = 'eta_metal eta_oxide eta_gas'
  phase_etas = eta_metal
[../]
[./switch_oxide]
  type = SwitchingFunctionMultiPhaseMaterial
  h_name = switch_oxide
  all_etas = 'eta_metal eta_oxide eta_gas'
  phase_etas = eta_oxide
[../]
[./switch_gas]
  type = SwitchingFunctionMultiPhaseMaterial
  h_name = switch_gas
  all_etas = 'eta_metal eta_oxide eta_gas'
  phase_etas = eta_gas
[../]
[./omega_metal]
  type = DerivativeParsedMaterial
  args = mu_o
  f_name = omega_metal
  material_property_names = 'Va k_metal cmetal_eq'
  function = '-0.5*mu_o^2/Va^2/k_metal - cmetal_eq*mu_o/Va'
  derivative_order = 2
[../]
[./omega_oxide]
  type = DerivativeParsedMaterial
  args = mu_o
  f_name = omega_oxide
  material_property_names = 'Va k_oxide coxide_eq'
  function = '-0.5*mu_o^2/Va^2/k_oxide - coxide_eq*mu_o/Va'
  derivative_order = 2
[../]
[./omega_gas]
  type = DerivativeParsedMaterial
  args = mu_o
  f_name = omega_gas
  material_property_names = 'Va k_gas cgas_eq'
  function = '-0.5*mu_o^2/Va^2/k_gas - cgas_eq*mu_o/Va'
  derivative_order = 2
[../]
[./rho_metal]
  type = DerivativeParsedMaterial
  f_name = rho_metal
  args = mu_o
  material_property_names = 'Va k_metal cmetal_eq'
  function = 'mu_o/Va^2/k_metal + cmetal_eq/Va'
  derivative_order = 1
[../]
[./rho_oxide]
  type = DerivativeParsedMaterial
  f_name = rho_oxide
  args = mu_o
  material_property_names = 'Va k_oxide coxide_eq'
  function = 'mu_o/Va^2/k_oxide + coxide_eq/Va'
  derivative_order = 1
[../]
[./rho_gas]
  type = DerivativeParsedMaterial
  f_name = rho_gas
  args = mu_o
  material_property_names = 'Va k_gas cgas_eq'
  function = 'mu_o/Va^2/k_gas + cgas_eq/Va'
  derivative_order = 1
[../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Postprocessors]
  [./oxygen_concentration]
    type = ElementIntegralMaterialProperty
    mat_prop = o_concentration
    #outputs = exodus
  [../]
  [./metal_area]
    type = ElementIntegralVariablePostprocessor
    variable = eta_metal
    outputs = csv
  [../]
  [./oxide_area]
    type = ElementIntegralVariablePostprocessor
    variable = eta_oxide
    outputs = csv
  [../]
  [./gas_area]
    type = ElementIntegralVariablePostprocessor
    variable = eta_gas
    outputs = csv
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart -sub_ksp_type'
  petsc_options_value = ' asm      lu           1               31                 preonly'
  # nl_max_its = 20
  # l_max_its = 30
  l_tol = 1e-8
  nl_rel_tol = 1e-12
  nl_abs_tol = 1e-5
  start_time = 0
  dt = 2e-5
  num_steps = 10000
[]

[Outputs]
  [./exodus]
    type = Exodus
    execute_on = 'initial timestep_end final'
    interval = 1
  [../]
  [./csv]
    type = CSV
    execute_on = 'initial timestep_end final'
    interval = 1
  [../]
  perf_graph = true
[]
