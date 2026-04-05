#!/bin/bash

# Pari Code Coverage Report Generator
# Automates: clean -> test -> lcov -> genhtml -> report -> cleanup

BUILD_DIR="build"
OUTPUT_DIR="coverage_html"
INFO_FILE="coverage.info"
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

# 3. Run Tests
echo "Running test suite (tst_all)..."
"./$BUILD_DIR/tests/tst_all" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Warning: Some tests failed. Coverage might be incomplete."
fi

# 4. Capture Coverage with lcov
# We point to the specific directory where tst_all compiled its sources
echo "Capturing coverage data with lcov..."
lcov --capture --directory "$BUILD_DIR/tests/CMakeFiles/tst_all.dir" --output-file "$INFO_FILE" --quiet $LCOV_OPTS

# 5. Filter to only include src/
echo "Filtering report to include only src/ files..."
lcov --extract "$INFO_FILE" "$(pwd)/src/*" --output-file "$FILTERED_INFO" --quiet $LCOV_OPTS

# 6. Generate HTML Report
echo "Generating HTML report in $OUTPUT_DIR..."
rm -rf "$OUTPUT_DIR"
genhtml "$FILTERED_INFO" --output-directory "$OUTPUT_DIR" --quiet --title "Pari Code Coverage" $GENHTML_OPTS

# 7. Generate Text Summary (for CLI convenience)
echo ""
echo "=================================================================="
echo "                  CODE COVERAGE SUMMARY (CPPs)                    "
echo "=================================================================="
printf "%-35s | %10s | %10s\n" "Source File" "Coverage" "Lines"
echo "------------------------------------------------------------------"

# Use gcov -p to get the summaries for the text report
cd "$BUILD_DIR/tests"
find . -name "*.gcno" -not -path "*_autogen*" -exec gcov -p {} + > "../../gcov_temp.log" 2>&1
cd ../..

awk '
/File .*src\/.*\.cpp/ {
    file=$0
    next
}
/Lines executed:/ {
    if (file != "") {
        split(file, f, "/")
        filename = f[length(f)]
        gsub(/'\''/, "", filename)
        
        split($0, a, ":")
        split(a[2], b, "%")
        percent = b[1]
        total_lines = $4
        
        if (total_lines > 0) {
            sum += percent * total_lines / 100
            total += total_lines
            printf "%-35s | %9s%% | %10d\n", filename, percent, total_lines
        }
        file = ""
    }
}
END {
    print "------------------------------------------------------------------"
    if (total > 0) {
        printf "OVERALL WEIGHTED AVERAGE: %.2f%%\n", (sum / total * 100)
    }
    print "=================================================================="
}
' "gcov_temp.log" | sort -rn -k 3

# 8. Cleanup
rm -f "$INFO_FILE" "$FILTERED_INFO" "gcov_temp.log" "test.info"
find . -name "*.gcov" -delete 2>/dev/null

echo ""
echo "HTML report ready at: $(pwd)/$OUTPUT_DIR/index.html"
echo "You can open it with: open $OUTPUT_DIR/index.html"
