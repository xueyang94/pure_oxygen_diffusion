#include "gpmApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<gpmApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

gpmApp::gpmApp(InputParameters parameters) : MooseApp(parameters)
{
  gpmApp::registerAll(_factory, _action_factory, _syntax);
}

gpmApp::~gpmApp() {}

void
gpmApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"gpmApp"});
  Registry::registerActionsTo(af, {"gpmApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
gpmApp::registerApps()
{
  registerApp(gpmApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
gpmApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  gpmApp::registerAll(f, af, s);
}
extern "C" void
gpmApp__registerApps()
{
  gpmApp::registerApps();
}
