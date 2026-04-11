#!/bin/bash

# Pari Code Coverage Report Generator
# Automates: clean -> test -> lcov -> genhtml -> report -> cleanup

BUILD_DIR="build"
OUTPUT_DIR="coverage_html"
INFO_ALL="coverage_all.info"
INFO_UI="coverage_ui.info"
INFO_COMBINED="coverage_combined.info"
FILTERED_INFO="coverage_filtered.info"

# lcov 2.0+ on macOS needs specific ignore flags for clang output
LCOV_OPTS="--ignore-errors unsupported,empty,inconsistent,format,unused"
GENHTML_OPTS="--ignore-errors source,category"

# Navigate to project root (assuming script is in scripts/)
cd "$(dirname "$0")/.."

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

# 3. Run Unit Tests (tst_all)
echo "Running unit test suite (tst_all)..."
"./$BUILD_DIR/tests/tst_all" > /dev/null 2>&1
lcov --capture --directory "$BUILD_DIR/tests/CMakeFiles/tst_all.dir" --output-file "$INFO_ALL" --quiet $LCOV_OPTS

# 4. Run UI Tests (tst_ui)
echo "Running UI test suite (tst_ui)..."
"./$BUILD_DIR/tests/tst_ui" -input "$(pwd)/tests" > /dev/null 2>&1
lcov --capture --directory "$BUILD_DIR/tests/CMakeFiles/tst_ui.dir" --output-file "$INFO_UI" --quiet $LCOV_OPTS

# 5. Merge Results
echo "Combining coverage data..."
lcov --add-tracefile "$INFO_ALL" --add-tracefile "$INFO_UI" --output-file "$INFO_COMBINED" --quiet $LCOV_OPTS

# 6. Filter to only include src/
echo "Filtering report to include only src/ files..."
lcov --extract "$INFO_COMBINED" "$(pwd)/src/*" --output-file "$FILTERED_INFO" --quiet $LCOV_OPTS

# 7. Generate HTML Report
echo "Generating HTML report in $OUTPUT_DIR..."
rm -rf "$OUTPUT_DIR"
genhtml "$FILTERED_INFO" --output-directory "$OUTPUT_DIR" --quiet --title "Pari Code Coverage" $GENHTML_OPTS

# 8. Generate Text Summary
echo ""
echo "=================================================================="
echo "                  CODE COVERAGE SUMMARY (CPPs)                    "
echo "=================================================================="
printf "%-35s | %10s | %10s\n" "Source File" "Coverage" "Lines"
echo "------------------------------------------------------------------"

lcov --summary "$FILTERED_INFO" $LCOV_OPTS | awk '
/src\/.*\.cpp/ {
    file=$1
    split(file, f, "/")
    filename = f[length(f)]
    
    # Simple parsing of lcov summary output for the file
    # This might need adjustment depending on lcov version summary format
}
' 

# Use a simpler summary from lcov for the text report
lcov --list "$FILTERED_INFO" $LCOV_OPTS | grep ".cpp" | sort -rn -k 2

# 9. Cleanup
rm -f "$INFO_ALL" "$INFO_UI" "$INFO_COMBINED" "$FILTERED_INFO"
find . -name "*.gcov" -delete 2>/dev/null

echo ""
echo "HTML report ready at: $(pwd)/$OUTPUT_DIR/index.html"
