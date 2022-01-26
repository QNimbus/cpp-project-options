# cpp-project-options

A general-purpose CMake library that makes using CMake easier...

## Usage

<details>
<summary>Click to show the example:</summary>

```cmake

...

```

</details>

## `project_options` function

It accepts the following named flags:

- `WARNINGS_AS_ERRORS`: Treat the warnings as errors
- `ENABLE_PCH`: Enable Precompiled Headers
- `ENABLE_CONAN`: Use Conan for dependency management

It gets the following named parameters (each accepting multiple values):

- `PCH_HEADERS`: the list of the headers to precompile
- `MSVC_WARNINGS`: Override the defaults for the MSVC warnings
- `CLANG_WARNINGS`: Override the defaults for the CLANG warnings
- `GCC_WARNINGS`: Override the defaults for the GCC warnings
- `CONAN_OPTIONS`: Extra Conan options

<details>
<summary>Click to show the example:</summary>

```cmake

```

</details>