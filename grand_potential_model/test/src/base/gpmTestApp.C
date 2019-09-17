//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "gpmTestApp.h"
#include "gpmApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

template <>
InputParameters
validParams<gpmTestApp>()
{
  InputParameters params = validParams<gpmApp>();
  return params;
}

gpmTestApp::gpmTestApp(InputParameters parameters) : MooseApp(parameters)
{
  gpmTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

gpmTestApp::~gpmTestApp() {}

void
gpmTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  gpmApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"gpmTestApp"});
    Registry::registerActionsTo(af, {"gpmTestApp"});
  }
}

void
gpmTestApp::registerApps()
{
  registerApp(gpmApp);
  registerApp(gpmTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
gpmTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  gpmTestApp::registerAll(f, af, s);
}
extern "C" void
gpmTestApp__registerApps()
{
  gpmTestApp::registerApps();
}
