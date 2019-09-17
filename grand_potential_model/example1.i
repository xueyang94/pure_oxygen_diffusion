[Mesh]
  type = GeneratedMesh
  xmax = 200
  ymax = 200
  nx = 100
  ny = 100
  dim = 2
  uniform_refine = 1
[]

[Modules]
  [./PhaseField]
    [./Conserved]
      [./c]
        free_energy = F
        kappa = kappa
        mobility = M
        solve_type = FORWARD_SPLIT
      [../]
    [../]
  [../]
[]

[AuxVariables]
  [./Fdens]
      family = MONOMIAL
      order = CONSTANT
  [../]
[]

[AuxKernels]
  [./auxker]
    type = TotalFreeEnergy
    kappa_names = 'kappa'
    interfacial_vars = 'c'
    variable = Fdens
  [../]
[]


[ICs]
  [./c_IC]
    type = FunctionIC
    variable = c
    function = '0.5 + 0.01*(cos(0.105*x)*cos(0.11*y) +
      (cos(0.13*x)*cos(0.087*y))^2 +
      cos(0.025*x - 0.15*y)*cos(0.07*x - 0.02*y))'
  [../]
[]

[Materials]
  [./constant_props]
    type = GenericConstantMaterial
    prop_names = 'kappa M'
    prop_values = '2 5'
  [../]
  [./F_mat]
    type = DerivativeParsedMaterial
    f_name = F
    args = c
    function = 'A*(c - ca)^2*(c - cb)^2'
    constant_names = 'A ca cb'
    constant_expressions = '5 0.3 0.7'
  [../]
[]

# [BCs]
#   [./Periodic]
#     [./All]
#       auto_direction = 'x y'
#     [../]
#   [../]
# []

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
  []

  [Postprocessors]
    [./dt]
      type = TimestepSize
      execute_on = 'INITIAL TIMESTEP_END'
    [../]
    [./nelem]
      type = NumElems
      execute_on = 'INITIAL TIMESTEP_END'
    [../]
    [./totalc]
      type = ElementIntegralVariablePostprocessor
      variable = c
      execute_on = 'INITIAL TIMESTEP_END'
    [../]
    [./total_free_energy]
      type = ElementIntegralVariablePostprocessor
      variable = Fdens
    [../]
    [./feature_counter]
      type = FeatureFloodCount
      variable = c
      threshold = 0.5
      execute_on = 'initial timestep_end'
    [../]
  []

  [Executioner]
    type = Transient
    solve_type = NEWTON
    scheme = bdf2
    petsc_options_iname = '-pc_type -sub_pc_type'
    petsc_options_value = 'asm lu'

    nl_max_its = 12
    l_max_its = 40
    l_tol = 1e-4
    nl_rel_tol = 1e-8
    end_time = 1e6
    #num_steps = 100

    [./TimeStepper]
      type = IterationAdaptiveDT
      dt = 0.1
      growth_factor = 1.1
      cutback_factor = 0.8
      optimal_iterations = 6
    [../]
  []

  [Outputs]
    exodus = true
    csv = true
    perf_graph = true
  []
