#use only Fe and FeO phases to test the thermodynamic phase diagram


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

[Variables]
  [./mu_o]
  [../]
  [./eta_metal]
  [../]
  [./eta_oxide]
  [../]
[]

[ICs]
  [./IC_mu_o_metal]
    type = FunctionIC
    variable = mu_o
    #function = 'if(x<100, -8.832, if(x<130, -44.16, 0))'
    #function = 'if(x<100, -4.416e-3, if(x<130, -22.08, 0))'
    #function = '-24.84'
    function = '0'
  [../]

  [./IC_eta_metal]
    type = BoundingBoxIC
    variable = eta_metal
    x1 = 0
    x2 = 200
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
  [./IC_eta_oxide]
    type = BoundingBoxIC
    variable = eta_oxide
    x1 = 200
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
  v = eta_oxide
  gamma_names = g_oxide
  mob_name = L
[../]
[./ACmetal_sw]
  type = ACSwitching
  variable = eta_metal
  Fj_names = 'omega_metal omega_oxide'
  hj_names = 'switch_metal switch_oxide'
  args = 'eta_oxide mu_o'
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
  v = eta_metal
  gamma_names = g_metal
  mob_name = L
[../]
[./ACoxide_sw]
  type = ACSwitching
  variable = eta_oxide
  Fj_names = 'omega_metal omega_oxide'
  hj_names = 'switch_metal switch_oxide'
  args = 'eta_metal mu_o'
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
  Fj_names = 'rho_metal rho_oxide'
  hj_names = 'switch_metal switch_oxide'
  args = 'eta_metal eta_oxide'
[../]
[./coupled_eta_oxide]
  type = CoupledSwitchingTimeDerivative
  variable = mu_o
  v = eta_oxide
  Fj_names = 'rho_metal rho_oxide'
  hj_names = 'switch_metal switch_oxide'
  args = 'eta_metal eta_oxide'
[../]
[]

[Materials]
[./constants]
  type = GenericConstantMaterial #what is mu??? I don't need it in my equations but is somehow required -- mu is m in larry paper
  prop_names = 'g_metal g_oxide Va     D  cmetal_eq coxide_eq k_metal k_oxide interface_energy_sigma interface_thickness_l L'
  prop_values = '1.5    1.5     13.8  1e6  0.28125   0.78125   6.4     6.4         10                   5                 1e4'
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
[./chi]
  type = DerivativeParsedMaterial
  f_name = chi
  args = mu_o
  material_property_names = 'Va switch_metal switch_oxide k_metal k_oxide'
  function = '(switch_metal/k_metal + switch_oxide/k_oxide)/Va^2'
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
  material_property_names = 'switch_metal switch_oxide rho_metal rho_oxide Va'
  function = 'Va*(switch_metal*rho_metal + switch_oxide*rho_oxide)'
  outputs = exodus
[../]

[./switch_metal]
  type = SwitchingFunctionMaterial
  h_order = HIGH
  function_name = switch_metal
  h_name = switch_metal
  eta = 'eta_metal'
[../]
[./switch_oxide]
  type = SwitchingFunctionMaterial
  h_order = HIGH
  function_name = switch_oxide
  eta = 'eta_oxide'
[../]
[./omega_metal]
  type = DerivativeParsedMaterial
  args = mu_o
  f_name = omega_metal
  material_property_names = 'Va k_metal cmetal_eq'
  function = '-0.5*mu_o^2/Va^2/k_metal - cmetal_eq*mu_o/Va - 0.9'
  derivative_order = 2
[../]
[./omega_oxide]
  type = DerivativeParsedMaterial
  args = mu_o
  f_name = omega_oxide
  material_property_names = 'Va k_oxide coxide_eq'
  function = '-0.5*mu_o^2/Va^2/k_oxide - coxide_eq*mu_o/Va - 1.8'
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
