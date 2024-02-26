from importlib import import_module
from importlib.util import find_spec

def import_if_exists(module_name):
    try:
        return import_module(module_name)
    except ModuleNotFoundError:
        return None

def _get_debugger():
    library_ops = import_if_exists("image_utils.library_ops")
    if find_spec("pudb"):
        return import_module("pudb").set_trace
    elif find_spec("ipdb"):
        return import_module("ipdb").set_trace
    elif find_spec("pdb"):
        return import_module("pdb").set_trace
    
custom_debugger = _get_debugger()