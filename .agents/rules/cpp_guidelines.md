# C++ & Qt Coding Guidelines for Pari

To ensure code quality, optimal performance, and prevent runtime bugs before code review and CI checks, all developers and AI agents must follow these guidelines.

## Static Analysis & Quality Checks

Run `clang-tidy` and `clazy-standalone` locally using the build compilation database:

```bash
# Export compile commands
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Run clang-tidy
clang-tidy -p build src/integrations/*.cpp src/core/*.cpp src/editor/*.cpp src/formatting/*.cpp

# Run Qt-specific static analysis (Clazy)
clazy-standalone -p build src/integrations/*.cpp src/core/*.cpp src/editor/*.cpp src/formatting/*.cpp
```

## Qt Container & Lifetime Rules

1. **Avoid Container Detachment in Range Loops (`-Wclazy-range-loop-detach`)**:
   - In C++11 range loops over non-const Qt containers (`QList`, `QStringList`), always wrap the container with `std::as_const(...)` to prevent copy-on-write (COW) detachment and unexpected deep copies.
   - **Incorrect**: `for (const QString &line : lines)`
   - **Correct**: `for (const QString &line : std::as_const(lines))`

2. **Avoid Dangling References on Container Erasure**:
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

3. **String Allocation & Regex Performance**:
   - Prefer multi-argument `.arg(a, b, c)` over chained `.arg(a).arg(b)` to avoid intermediate temporary `QString` allocations (`-Wclazy-qstring-arg`).
   - Use `static const QRegularExpression` for regexes used repeatedly in hot paths (`-Wclazy-use-static-qregularexpression`).
   - Prefer hex integer literals for `QColor` (e.g. `QColor(0x888888)`) over string literals `QColor("#888888")` (`-Wclazy-qcolor-from-literal`).

4. **Code Formatting**:
   - Always run `clang-format` on modified C++ files according to `.clang-format`.
