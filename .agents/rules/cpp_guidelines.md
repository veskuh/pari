# C++ & Qt Coding Guidelines for Pari

To ensure code quality and prevent runtime bugs before code review and CI checks, all developers and AI agents must follow these guidelines.

## Static Analysis & Quality Checks

Run `clang-tidy` locally using the build compilation database before opening a PR:

```bash
# Export compile commands and run clang-tidy
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
clang-tidy -p build src/integrations/*.cpp src/core/*.cpp src/editor/*.cpp src/formatting/*.cpp
```

## Qt Container & Lifetime Rules

1. **Avoid Dangling References on Container Erasure**:
   - Never assign a `const T&` reference to an iterator's value (`it.value()`) or map element immediately before calling `.erase(it)` or mutating the container.
   - **Incorrect**:
     ```cpp
     const CommandContext& ctx = it.value();
     m_runningCommands.erase(it); // Danger: ctx is now a dangling reference!
     dispatchCommandOutput(ctx);
     ```
   - **Correct**:
     ```cpp
     CommandContext ctx = it.value(); // Make a value copy before erasing
     m_runningCommands.erase(it);
     dispatchCommandOutput(ctx);
     ```

2. **Qt Signals and Slots**:
   - Do not mix `private slots:` and `private:` without understanding that `clang-tidy` ignores redundant access specifier warnings for Qt macros when `-readability-redundant-access-specifiers` is disabled.

3. **Code Formatting**:
   - Always run `clang-format` on modified C++ files according to `.clang-format`.
