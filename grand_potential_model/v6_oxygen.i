#study the influence of switching function. In this file use SwitchingFunctionMultiPhaseMaterial, and compare with v5_oxygen SwitchingFunctionMaterial
#unit of lengh is nm
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  xmin = 0
  xmax = 300
  ny = 100
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
  [./IC_mu_o]
    type = FunctionIC
    function = 'x/1000'
    variable = mu_o
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
  mob_name = L_metal
[../]
[./ACmetal_sw]
  type = ACSwitching
  variable = eta_metal
  Fj_names = 'omega_metal omega_oxide omega_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_oxide eta_gas mu_o'
  mob_name = L_metal
[../]
[./ACmetal_int]
  type = ACInterface
  variable = eta_metal
  kappa_name = kappa
  mob_name = L_metal
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
  mob_name = L_oxide
[../]
[./ACoxide_sw]
  type = ACSwitching
  variable = eta_oxide
  Fj_names = 'omega_metal omega_oxide omega_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_metal eta_gas mu_o'
  mob_name = L_oxide
[../]
[./ACoxide_int]
  type = ACInterface
  variable = eta_oxide
  kappa_name = kappa
  mob_name = L_oxide
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
  mob_name = L_gas
[../]
[./ACgas_sw]
  type = ACSwitching
  variable = eta_gas
  Fj_names = 'omega_metal omega_oxide omega_gas'
  hj_names = 'switch_metal switch_oxide switch_gas'
  args = 'eta_metal eta_oxide mu_o'
  mob_name = L_gas
[../]
[./ACgas_int]
  type = ACInterface
  variable = eta_gas
  kappa_name = kappa
  mob_name = L_gas
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
  D_name = M_o
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
  prop_names = 'g_metal g_oxide g_gas   Va     D  cmetal_eq coxide_eq cgas_eq k_metal k_oxide k_gas interface_energy_sigma interface_thickness_l phase_mobility_metal phase_mobility_oxide phase_mobility_gas'
  prop_values = '1.5    1.5     1.5     13.8  1e7   1e-4      0.5       1      3.2     3.2     3.2    10                   10                    1e7                  1e4                 1e2'
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
# [./L]
#   type = ParsedMaterial
#   f_name = L
#   material_property_names = 'phase_mobility_M interface_thickness_l'
#   function = '4*phase_mobility_M/(3*interface_thickness_l)'
# [../]
[./L_metal]
  type = ParsedMaterial
  f_name = L_metal
  material_property_names = 'phase_mobility_metal interface_thickness_l'
  function = '4*phase_mobility_metal/3/interface_thickness_l'
[../]
[./L_oxide]
  type = ParsedMaterial
  f_name = L_oxide
  material_property_names = 'phase_mobility_oxide interface_thickness_l'
  function = '4*phase_mobility_oxide/3/interface_thickness_l'
[../]
[./L_gas]
  type = ParsedMaterial
  f_name = L_gas
  material_property_names = 'phase_mobility_gas interface_thickness_l'
  function = '4*phase_mobility_gas/3/interface_thickness_l'
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
# [./metal_region]
#   type = ParsedMaterial
#   f_name = metal_area
#   args = eta_metal
#   function = 'if(eta_metal>0.9999, 1, 0)'
#   outputs = exodus
# [../]
# [./oxide_region]
#   type = ParsedMaterial
#   f_name = oxide_area
#   args = eta_oxide
#   function = 'if(eta_oxide>0.9999, 1, 0)'
#   outputs = exodus
# [../]
# [./gas_region]
#   type = ParsedMaterial
#   f_name = gas_area
#   args = eta_gas
#   function = 'if(eta_gas>0.9999, 1, 0)'
#   outputs = exodus
# [../]
[./switch_metal]
  # type = SwitchingFunctionMaterial
  # h_order = HIGH
  # function_name = switch_metal
  # eta = eta_metal
  type = SwitchingFunctionMultiPhaseMaterial
  h_name = switch_metal
  all_etas = 'eta_metal eta_oxide eta_gas'
  phase_etas = eta_metal
[../]
[./switch_oxide]
  # type = SwitchingFunctionMaterial
  # h_order = HIGH
  # function_name = switch_oxide
  # eta = eta_oxide
  type = SwitchingFunctionMultiPhaseMaterial
  h_name = switch_oxide
  all_etas = 'eta_metal eta_oxide eta_gas'
  phase_etas = eta_oxide
[../]
[./switch_gas]
  # type = SwitchingFunctionMaterial
  # h_order = HIGH
  # function_name = switch_gas
  # eta = eta_gas
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
  # [./metal_area]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = metal_area
  # [../]
  # [./oxide_area]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = oxide_area
  # [../]
  # [./gas_area]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = gas_area
  # [../]
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
  nl_max_its = 20
  l_max_its = 30
  l_tol = 1e-4
  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-7
  start_time = 0
  dt = 2e-5
  num_steps = 30
[]

[Outputs]
  perf_graph = true
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
[]
