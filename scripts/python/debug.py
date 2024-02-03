from importlib import import_module
from importlib.util import find_spec

def _get_debugger():
    if find_spec("pudb"):
        return import_module("pudb").set_trace
    elif find_spec("ipdb"):
        return import_module("ipdb").set_trace
    elif find_spec("pdb"):
        return import_module("pdb").set_trace
    
custom_debugger = _get_debugger()