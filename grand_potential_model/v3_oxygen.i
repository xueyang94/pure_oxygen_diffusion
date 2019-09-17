#use kernel action
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

[GlobalParams]
  op_num = 1
  var_name_base = eta
[]

[Variables]
  [./mu_o]
  [../]
  [./eta0]
  [../]
  [./phi_oxide]
  [../]
  [./phi_gas]
  [../]
[]

[AuxVariables]
  [./bnds]
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
  # [./IC_mu_o]
  #   type = BoundingBoxIC
  #   variable = mu_o
  #   x1 = 0
  #   x2 = 130
  #   y1 = 0
  #   y2 = 100
  #   inside = 0.005
  #   outside = 0
  # [../]
  # [./IC_mn_o]
  #   type = ConstantIC
  #   value = 0
  #   variable = mu_o
  # [../]
  [./IC_eta0]
    type = BoundingBoxIC
    variable = eta0
    x1 = 0
    x2 = 100
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
  [./IC_phi_oxide]
    type = BoundingBoxIC
    variable = phi_oxide
    x1 = 100
    x2 = 130
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
  [./IC_oxide_gas]
    type = BoundingBoxIC
    variable = phi_gas
    x1 = 130
    x2 = 300
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
[]

[Modules]
  [./PhaseField]
    [./GrandPotential]
      switching_function_names = 'heta0 hphi_oxide hphi_gas'
      anisotropic = false

      chemical_potentials = 'mu_o'
      mobilities = 'M_o'
      susceptibilities = 'chi'
      free_energies_w = 'rho_metal rho_oxide rho_gas'

      #gamma_gr = 'gamma_1'
      mobility_name_gr = 'L'
      kappa_gr = kappa
      free_energies_gr = 'omega_metal omega_oxide omega_gas'


      #energy_barrier_gr = m   #add on #it is mu

      additional_ops = 'phi_oxide phi_gas'
      gamma_op = gamma
      gamma_grxop = gamma
      mobility_name_op = 'L'
      kappa_op = kappa
      free_energies_op = 'omega_metal omega_oxide omega_gas'
    [../]
  [../]
[]

[AuxKernels]
  [./bnds_aux]
    type = BndsCalcAux
    variable = bnds
  [../]
[]

[Materials]
  #REFERENCES
 [./constants]
    type = GenericConstantMaterial #what is mu??? I don't need it in my equations but is somehow required -- mu is m in larry paper
    prop_names = 'gamma   Va      kB        cmetal_eq coxide_eq cgas_eq k_metal k_oxide k_gas interface_energy_sigma interface_thickness_l phase_mobility_M'
    prop_values = '1.5    13.8    8.6112e-5  1e-4      0.5       1      3.2     3.2     3.2    10                     10                   1e4'
    # prop_names =  'Va      cb_eq cm_eq kb   km    gamma L      L_phi  kappa  kB'
    # prop_values = '0.04092 1.0   1e-5  1400 140 1.5 1.5   5.3e+3 2.3e+4 295.85 8.6173324e-5'
  [../]
  #PARAMETERS
  [./kappa] #assume that three interfaces having the same interfacial energy and thickness
    type = ParsedMaterial
    f_name = kappa
    material_property_names = 'interface_energy_sigma interface_thickness_l'
    function = '3*interface_energy_sigma*interface_thickness_l/4'
  [../]
  [./m]
    type = ParsedMaterial
    f_name = mu
    material_property_names = 'interface_energy_sigma interface_thickness_l'
    function = '6*interface_energy_sigma/interface_thickness_l'
  [../]
  [./L]
    type = ParsedMaterial
    f_name = L
    material_property_names = 'phase_mobility_M interface_thickness_l'
    function = '4*phase_mobility_M/(3*interface_thickness_l)'
  [../]

  #SWITCHING FUNCTIONS
  [./switch_eta0]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    function_name = heta0
    eta = eta0
  [../]
  [./switch_phi_oxide]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    function_name = hphi_oxide
    eta = phi_oxide
  [../]
  [./switch_phi_gas]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    function_name = hphi_gas
    eta = phi_gas
  [../]
  #grand potential density for each phase
  [./omega_metal]
    type = DerivativeParsedMaterial
    f_name = omega_metal
    args = 'mu_o eta0'
    material_property_names = 'Va k_metal cmetal_eq'
    function = '-0.5*mu_o^2/Va^2/k_metal - cmetal_eq*mu_o/Va - 0.9'
    derivative_order = 2
  [../]
  [./omega_oxide]
    type = DerivativeParsedMaterial
    f_name = omega_oxide
    args = 'mu_o phi_oxide'
    material_property_names = 'Va k_oxide coxide_eq'
    function = '-0.5*mu_o^2/Va^2/k_oxide - coxide_eq*mu_o/Va - 1.8'
    derivative_order = 2
  [../]
  [./omega_gas]
    type = DerivativeParsedMaterial
    f_name = omega_gas
    args = 'mu_o phi_gas'
    material_property_names = 'Va k_gas cgas_eq'
    function = '-0.5*mu_o^2/Va^2/k_gas - cgas_eq*mu_o/Va'
    derivative_order = 2
  [../]
  # susceptibility
  [./chi]
    type = DerivativeParsedMaterial
    f_name = chi
    args = 'mu_o'
    material_property_names = 'Va heta0 hphi_oxide hphi_gas k_metal k_oxide k_gas'
    function = '(heta0/k_metal + hphi_oxide/k_oxide + hphi_gas/k_gas)/Va^2'
    derivative_order = 2
  [../]
  #DENSITIES/CONCENTRATION
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

  # [./concentration]
  #   type = ParsedMaterial
  #   f_name = c
  #   material_property_names = 'rhom hm rhob hb Va'
  #   function = 'Va*(hm*rhom + hb*rhob)'
  #   outputs = exodus
  # [../]

  # [./mobility]
  #   type = DerivativeParsedMaterial
  #   material_property_names = 'chi kB'
  #   constant_names = 'T Em D0'
  #   constant_expressions = '1400 2.4 1.25e2'
  #   f_name = M_o
  #   function = 'chi*D0*exp(-Em/kB/T)'
  # [../]

  [./mobility]
    type = DerivativeParsedMaterial
    material_property_names = 'chi'
    f_name = M_o
    function = 'chi*0'
    derivative_order = 2
  [../]
  # [./oxide_region]
  #   type = ParsedMaterial
  #   f_name = oxide
  #   args = phi_oxide
  #   function = 'if(phi_oxide>0.9999, 1, 0)'
  #   outputs = exodus
  # [../]
  [./oxygen_concentration]
    type = ParsedMaterial
    f_name = o_concentration
    args = mu_o
    material_property_names = 'Va k_metal k_gas k_oxide cmetal_eq coxide_eq cgas_eq heta0 hphi_oxide hphi_gas'
    function = '(mu_o/Va/k_metal + cmetal_eq)*heta0 + (mu_o/Va/k_oxide + coxide_eq)*hphi_oxide + (mu_o/Va/k_gas + cgas_eq)*hphi_gas'
    outputs = exodus
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Postprocessors]
  # [./oxide_area]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = oxide
  # [../]
  [./oxygen_concentration]
    type = ElementIntegralMaterialProperty
    mat_prop = o_concentration
  [../]
  [./metal_area]
    type = ElementIntegralVariablePostprocessor
    variable = eta0
    outputs = csv
  [../]
  [./oxide_area]
    type = ElementIntegralVariablePostprocessor
    variable = phi_oxide
    outputs = csv
  [../]
  [./gas_area]
    type = ElementIntegralVariablePostprocessor
    variable = phi_gas
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
