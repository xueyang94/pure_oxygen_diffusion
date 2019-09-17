# [Mesh]
#   type = GeneratedMesh
#   dim = 1
#   nx = 100
#   xmin = 0
#   xmax = 130
# []

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  xmin = 0
  xmax = 130
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
  [./phi_gas]
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
[]

[ICs]
  [./IC_mu_o]
    type =   FunctionIC
    function = 'x/1000'
    variable = mu_o
  [../]
  # [./IC_mn_o]
  #   type = ConstantIC
  #   value = 1e-4
  #   variable = mu_o
  # [../]
  # [./IC_mu_o]
  #   type = BoundingBoxIC
  #   variable = mu_o
  #   x1 = 0
  #   x2 = 100
  #   y1 = 0
  #   y2 = 100
  #   inside = 1e-5
  #   outside = 1e-3
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
  [./IC_phi_gas]
    type = BoundingBoxIC
    variable = phi_gas
    x1 = 100
    x2 = 130
    y1 = 0
    y2 = 100
    inside = 1
    outside = 0
  [../]
[]

[Modules]
  [./PhaseField]
    [./GrandPotential]
      switching_function_names = 'heta0 hphi_gas'
      anisotropic = false

      chemical_potentials = 'mu_o'
      mobilities = 'M_o'
      susceptibilities = 'chi'
      free_energies_w = 'rho_metal rho_gas'

      mobility_name_gr = L
      kappa_gr = kappa
      free_energies_gr = 'omega_metal omega_gas'

      additional_ops = 'phi_gas'
      gamma_op = gamma
      gamma_grxop = gamma
      mobility_name_op = L
      kappa_op = kappa
      free_energies_op = 'omega_metal omega_gas'
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
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'gamma Va   kB        cmetal_eq cgas_eq k_metal k_gas interface_energy_sigma interface_thickness_l phase_mobility_M L'
    prop_values = '1.5  13.8 8.617e-5  1e-4       0.9    1e-4    1e-4   10                    10                    1e-5             1e6' #phase_mobility is the same as Ian's paper value
  [../]
  #PARAMETERS
  [./kappa] #assume that two interfaces having the same interfacial energy and thickness
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
  # [./mobility_L] #assume that the three phases having the same mobility
  #   type = ParsedMaterial
  #   f_name = L
  #   material_property_names = 'phase_mobility_M interface_thickness_l'
  #   function = '4*phase_mobility_M/(3*interface_thickness_l)'
  # [../]
  #SWITCHING FUNCTIONS
  [./switch_eta0]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    function_name = heta0
    eta = eta0
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
    args = mu_o
    material_property_names = 'Va k_metal cmetal_eq'
    function = '-0.5*mu_o^2/(Va^2*k_metal) - cmetal_eq*mu_o/Va'
    derivative_order = 2
  [../]
  [./omega_gas]
    type = DerivativeParsedMaterial
    f_name = omega_gas
    args = mu_o
    material_property_names = 'Va k_gas cgas_eq'
    function = '-0.5*mu_o^2/(Va^2*k_gas) - cgas_eq*mu_o/Va'
    derivative_order = 2
  [../]
  # susceptibility
  [./chi]
    type = DerivativeParsedMaterial
    f_name = chi
    args = 'eta0 phi_gas'
    material_property_names = 'Va heta0(eta0) hphi_gas(phi_gas) k_metal k_gas'
    function = '(heta0/k_metal + hphi_gas/k_gas)/Va^2'
    derivative_order = 2
  [../]
  #DENSITIES/CONCENTRATION
  [./rho_metal]
    type = DerivativeParsedMaterial
    f_name = rho_metal
    args = mu_o
    material_property_names = 'Va k_metal cmetal_eq'
    function = 'mu_o/(Va^2*k_metal) + cmetal_eq/Va'
    derivative_order = 2
  [../]
  [./rho_gas]
    type = DerivativeParsedMaterial
    f_name = rho_gas
    args = mu_o
    material_property_names = 'Va k_gas cgas_eq'
    function = 'mu_o/(Va^2*k_gas) + cgas_eq/Va'
    derivative_order = 2
  [../]
  # [./mobility]
  #   type = DerivativeParsedMaterial
  #   material_property_names = 'chi(eta0,phi_gas)'
  #   f_name = M_o
  #   function = 'chi*1e19'
  #   derivative_order = 2
  # [../]
  [./mobility]
    type = DerivativeParsedMaterial
    material_property_names = 'chi(eta0,phi_gas)'
    f_name = M_o
    function = 'chi*1e7'
    derivative_order = 2
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
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
  exodus = true
[]
