from importlib import import_module

def import_if_exists(module_name):
    try:
        return import_module(module_name)
    except ModuleNotFoundError:
        return None

np = import_if_exists("numpy")
torch = import_if_exists("torch")
einx = import_if_exists("einx")
library_ops = import_if_exists("image_utils.library_ops")
Im = import_if_exists("image_utils.Im")

try:
    import sys
    import IPython
    sys.breakpointhook = IPython.embed
except ImportError as e:
    pass