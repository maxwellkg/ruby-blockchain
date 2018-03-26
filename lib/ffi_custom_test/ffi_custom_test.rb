require 'ffi'

module FfiCustomTest
  extend FFI::Library
  ffi_lib './ffi_test.so'

  attach_function :say_hello, [:string], :string
end
