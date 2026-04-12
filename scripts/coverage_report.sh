#!/bin/bash

# Pari Code Coverage Report Generator
# Automates: clean -> test -> lcov -> genhtml -> report -> cleanup

BUILD_DIR="build"
OUTPUT_DIR="coverage_html"
INFO_ALL="coverage_all.info"
INFO_UI="coverage_ui.info"
INFO_COMBINED="coverage_combined.info"
FILTERED_INFO="coverage_filtered.info"
LOG_FILE="coverage_run.log"

# lcov options: ignore common mismatched/missing data errors in clang/macOS
LCOV_OPTS="--ignore-errors unsupported,empty,inconsistent,format,unused,missing"
GENHTML_OPTS="--ignore-errors source,category"

# Navigate to project root (assuming script is in scripts/)
cd "$(dirname "$0")/.."

# Clear log file
> "$LOG_FILE"

# 1. Check Requirements
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory '$BUILD_DIR' not found."
    exit 1
fi

if ! grep -q "ENABLE_COVERAGE:BOOL=ON" "$BUILD_DIR/CMakeCache.txt" 2>/dev/null; then
    echo "Error: Coverage is not enabled in the current build."
    echo "Please run: cmake -B build -DENABLE_COVERAGE=ON"
    exit 1
fi

if ! command -v lcov &> /dev/null; then
    echo "Error: lcov not found. Please install it (e.g., brew install lcov)."
    exit 1
fi

# 2. Clean old data
echo "Cleaning old profiling data..."
find "$BUILD_DIR" -name "*.gcda" -delete 2>/dev/null
rm -f "$INFO_ALL" "$INFO_UI" "$INFO_COMBINED" "$FILTERED_INFO"

# 3. Run Unit Tests (tst_all)
echo "Running unit test suite (tst_all)..."
"./$BUILD_DIR/tests/tst_all" >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then echo "Warning: Unit tests had some failures."; fi

lcov --capture --directory "$BUILD_DIR" --output-file "$INFO_ALL" --quiet $LCOV_OPTS 2>> "$LOG_FILE"

# 4. Run UI Tests (tst_ui)
echo "Running UI test suite (tst_ui)..."
"./$BUILD_DIR/tests/tst_ui" -input "$(pwd)/tests" >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then echo "Warning: UI tests had some failures."; fi

lcov --capture --directory "$BUILD_DIR" --output-file "$INFO_UI" --quiet $LCOV_OPTS 2>> "$LOG_FILE"

# 5. Combine and Filter Results
echo "Processing coverage data..."

# Initialize tracefile list
TRACEFILES=""
[ -f "$INFO_ALL" ] && TRACEFILES="$TRACEFILES --add-tracefile $INFO_ALL"
[ -f "$INFO_UI" ] && TRACEFILES="$TRACEFILES --add-tracefile $INFO_UI"

if [ -z "$TRACEFILES" ]; then
    echo "Error: No coverage data was captured. Check if tests actually ran and generated .gcda files."
    exit 1
fi

# Combine
lcov $TRACEFILES --output-file "$INFO_COMBINED" --quiet $LCOV_OPTS 2>> "$LOG_FILE"

# Filter to only include src/ files
if [ -f "$INFO_COMBINED" ]; then
    echo "Filtering report to include only src/ files..."
    lcov --extract "$INFO_COMBINED" "$(pwd)/src/*" --output-file "$FILTERED_INFO" --quiet $LCOV_OPTS 2>> "$LOG_FILE"
else
    echo "Error: Failed to create $INFO_COMBINED"
    exit 1
fi

# 6. Generate HTML Report
if [ -f "$FILTERED_INFO" ]; then
    echo "Generating HTML report in $OUTPUT_DIR..."
    rm -rf "$OUTPUT_DIR"
    genhtml "$FILTERED_INFO" --output-directory "$OUTPUT_DIR" --quiet --title "Pari Code Coverage" $GENHTML_OPTS 2>> "$LOG_FILE"
    
    echo ""
    echo "=================================================================="
    echo "                  CODE COVERAGE SUMMARY                           "
    echo "=================================================================="
    lcov --list "$FILTERED_INFO" $LCOV_OPTS 2>> "$LOG_FILE" | grep -E "\.cpp|\.h" | sort -rn -k 2
else
    echo "Error: Failed to create $FILTERED_INFO"
    exit 1
fi

# 7. Count Warnings
# Count lines containing "WARNING" or "QWARN" or "Error:" (that didn't stop execution)
WARNING_COUNT=$(grep -Ei "warning|qwarn" "$LOG_FILE" | wc -l | xargs)

# 8. Cleanup
rm -f "$INFO_ALL" "$INFO_UI" "$INFO_COMBINED" "$FILTERED_INFO"
find . -name "*.gcov" -delete 2>/dev/null

echo ""
echo "Total Warnings/Issues detected during run: $WARNING_COUNT"
echo "HTML report ready at: $(pwd)/$OUTPUT_DIR/index.html"
echo "Log file available at: $(pwd)/$LOG_FILE"
