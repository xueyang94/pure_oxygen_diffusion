# try KKS model with Fe and FeO phases
# Executioner NEWTON does not converge. Use PJFNK

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 300
  xmin = 0
  xmax = 300
  ny = 100
  ymin = 0
  ymax = 100
[]

[Variables]
  [./c]
  [../]
  [./c1]
    #initial_condition = 0.8
  [../]
  [./c2]
    #initial_condition = 0.9
  [../]
  [./eta]
  [../]
  [./mu]
  [../]
[]

[AuxVariables]
  [./Fglobal]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./c]
    type = BoundingBoxIC
    int_width = 5
    x1 = 30
    x2 = 60
    y1 = 30
    y2 = 60
    inside = 0.3
    outside = 0.8
    variable = c
  [../]
  # [./c]
  #   type = MultiBoundingBoxIC
  #   int_width = 10
  #   corners = '-5 -5 0 200 -5 0'
  #   opposite_corners = '200 105 0 305 105 0'
  #   inside = '0.8 0.9'
  #   variable = c
  # [../]
  [./eta]
    type = BoundingBoxIC
    variable = eta
    int_width = 10
    x1 = -10
    x2 = 200
    y1 = -10
    y2 = 110
    # x1 = 0
    # x2 = 200
    # y1 = 0
    # y2 = 100
    inside = 0.5
    outside = 1
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'kappa M L'
    prop_values = '1    1e5 1e3'
  [../]
  [./Fe_energy]
    type = DerivativeParsedMaterial
    f_name = Fe_energy
    args = 'c1'
    #function = '3.2*c1^2 - 1.8*c1 - 0.65'
    function = '(c1 - 0.3)^2'
  [../]
  [./FeO_energy]
    type = DerivativeParsedMaterial
    f_name = FeO_energy
    args = 'c2'
    #function = '3.2*c2^2 - 5*c2 + 0.15'
    function = '(c2 - 0.7)^2'
  [../]
  [./h_eta]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = eta
  [../]
  [./g_eta]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta
  [../]
[]

[Kernels]
  active = 'PhaseConc ChemPotSolute CHBulk ACBulkF ACBulkC ACInterface dcdt detadt ckernel'
  # enforce c = (1-h(eta))*c1 + h(eta)c2
  [./PhaseConc]
    type = KKSPhaseConcentration
    c = c
    ca = c1
    variable = c2
    eta = eta
  [../]
  #enforce pointwise equality of chemical potentials
  [./ChemPotSolute]
    type = KKSPhaseChemicalPotential
    variable = c1
    cb = c2
    fa_name = Fe_energy
    fb_name = FeO_energy
  [../]

  # CH equation
  [./CHBulk]
    type = KKSSplitCHCRes
    variable = c
    w = mu
    ca = c1
    cb = c2
    fa_name = Fe_energy
    fb_name = FeO_energy
  [../]
  [./dcdt]
    type = CoupledTimeDerivative
    variable = mu
    v = c
  [../]
  [./ckernel]
    type = SplitCHWRes
    mob_name = M
    variable = mu
  [../]

  # AC equation
  [./ACBulkF]
    type = KKSACBulkF
    variable = eta
    fa_name = Fe_energy
    fb_name = FeO_energy
    w = 1.0 #same as w in AuxKernel
    args = 'c1 c2'
  [../]
  [./ACBulkC]
    type = KKSACBulkC
    variable = eta
    ca = c1
    cb = c2
    fa_name = Fe_energy
    fb_name = FeO_energy
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa
  [../]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]
[]

[AuxKernels]
  [./GlobalFreeEnergy]
    variable = Fglobal
    type = KKSGlobalFreeEnergy
    fa_name = Fe_energy
    fb_name = FeO_energy
    w = 1.0
    interfacial_vars = eta
    kappa_names = kappa
  [../]
[]

[Postprocessors]
  [./oxygen_concentration]
    type = ElementIntegralVariablePostprocessor
    variable = c
    outputs = csv
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      ilu          nonzero'

  l_max_its = 100
  nl_max_its = 100

  num_steps = 300
  dt = 1e-3
[]

[Preconditioning]
  [./full]
    type = SMP
    full = true
  [../]
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
