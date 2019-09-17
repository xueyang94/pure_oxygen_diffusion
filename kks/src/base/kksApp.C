#include "kksApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<kksApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

kksApp::kksApp(InputParameters parameters) : MooseApp(parameters)
{
  kksApp::registerAll(_factory, _action_factory, _syntax);
}

kksApp::~kksApp() {}

void
kksApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"kksApp"});
  Registry::registerActionsTo(af, {"kksApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
kksApp::registerApps()
{
  registerApp(kksApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
kksApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  kksApp::registerAll(f, af, s);
}
extern "C" void
kksApp__registerApps()
{
  kksApp::registerApps();
}
