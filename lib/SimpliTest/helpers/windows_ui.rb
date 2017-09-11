module WindowsUIHelpers
  # :nocov:
  # button constants
  BUTTONS_OK = 0
  BUTTONS_OKCANCEL = 1
  BUTTONS_ABORTRETRYIGNORE = 2
  BUTTONS_YESNO = 4

  # return code constants
  CLICKED_OK = 1
  CLICKED_CANCEL = 2
  CLICKED_ABORT = 3
  CLICKED_RETRY = 4
  CLICKED_IGNORE = 5
  CLICKED_YES = 6
  CLICKED_NO = 7
  APP_TITLE ='SimpliTest'

  def message_box(txt, title, buttons)   
    MessageBox::MessageBoxA nil, txt, title, buttons
  end

  def user_consents_via_prompt?(question)
    message_box(question, APP_TITLE, BUTTONS_YESNO) == CLICKED_YES
  end

  def user_informed_via_prompt?(message)
    message_box(message, APP_TITLE, BUTTONS_OK) == CLICKED_OK
  end
  # :nocov:
end


# Create module as body for an importer instance
module MessageBox
  # Load importer part of fiddle (ffi) library
  require 'fiddle/import'

  # Extend this module to an importer
  extend Fiddle::Importer
  # Load 'user32' dynamic library into this importer
  dlload 'user32'
  # Set C aliases to this importer for further understanding of function signatures
  typealias 'HANDLE', 'void*'
  typealias 'HWND', 'HANDLE'
  typealias 'LPCSTR', 'const char*'
  typealias 'LPCWSTR', 'const wchar_t*'
  typealias 'UINT', 'unsigned int'
  # Import C functions from loaded libraries and set them as module functions
  extern 'int MessageBoxA(HWND, LPCSTR, LPCSTR, UINT)'
  extern 'int MessageBoxW(HWND, LPCWSTR, LPCWSTR, UINT)'
end