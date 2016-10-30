BAZEL_TARGET=$1
TITLE="Clang analyzer report for Bazel Target $1"
REPO_ROOT=$PWD
EXECUTION_ROOT=`bazel info execution_root`

bazel clean
bazel build --experimental_action_listener tools/actions:generate_compile_commands_listener $BAZEL_TARGET
./tools/actions/generate_compile_commands_json.py
echo "Performing static analysis..."

cd $EXECUTION_ROOT
analyze-build --cdb $REPO_ROOT/compile_commands.json -o $REPO_ROOT/clang-analysis --html-title "$TITLE" --use-analyzer external/clang_3_8/usr/bin/clang-3.8
cd -
