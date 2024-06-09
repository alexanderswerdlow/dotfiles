import inspect

"""
This script does a *very* hacky thing to make Ctrl-p and Ctrl-n skip multiline inputs when navigating the history.
Oftentimes, it's annoying to navigate with the up arrow when pasting in large blocks of code.
This monkeypatches auto_up/auto_down in prompt_toolkit which ipython calls. When the calling file is emacs.py, it goes directly back but otherwise it preserves the original behavior, e.g., when navigating with the arrow keys to allow for editing.
"""

def get_calling_files():
    current_frame = inspect.currentframe()
    callers = inspect.getouterframes(current_frame)
    files = [caller.filename for caller in callers[1:-3]]
    return files

def _auto_up(
    self, count: int = 1, go_to_start_of_line_if_history_changes: bool = False
) -> None:
    """
    If we're not on the first line (of a multiline input) go a line up,
    otherwise go back in history. (If nothing is selected.)
    """
    if self.complete_state:
        self.complete_previous(count=count)
    elif self.document.cursor_position_row > 0:
        calling_files = get_calling_files()
        if 'emacs' in calling_files[1]:
            self.history_backward(count=count)
        else:
            self.cursor_up(count=count)
    elif not self.selection_state:
        self.history_backward(count=count)

        # Go to the start of the line?
        if go_to_start_of_line_if_history_changes:
            self.cursor_position += self.document.get_start_of_line_position()

def _auto_down(
    self, count: int = 1, go_to_start_of_line_if_history_changes: bool = False
) -> None:
    """
    If we're not on the last line (of a multiline input) go a line down,
    otherwise go forward in history. (If nothing is selected.)
    """
    if self.complete_state:
        self.complete_next(count=count)
    elif self.document.cursor_position_row < self.document.line_count - 1:
        calling_files = get_calling_files()
        if 'emacs' in calling_files[1]:
            self.history_forward(count=count)
        else:
            self.cursor_down(count=count)
    elif not self.selection_state:
        self.history_forward(count=count)

        # Go to the start of the line?
        if go_to_start_of_line_if_history_changes:
            self.cursor_position += self.document.get_start_of_line_position()
            
def post_run_cell(*args, **kwargs):
    from prompt_toolkit.buffer import Buffer
    Buffer.auto_up = _auto_up
    Buffer.auto_down = _auto_down

post_run_cell()