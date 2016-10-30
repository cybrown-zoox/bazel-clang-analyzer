# Running clang analyzer with bazel
## Summary
This repository contains scripts for running the [clang
analyzer](http://clang-analyzer.llvm.org/) static
analysis tool in a bazel workspace. It is forked from [this
gist](https://gist.github.com/bsilver8192/0115ee5d040bb601e3b7).

## Installation and setup
Place `BUILD`, `generate_compile_command.py`, and
`generate_compile_commands_json.py` in a suitable folder in your bazel
workspace. For installation purposes assume they are in `REPO_ROOT/tools/actions`.

The `BUILD` file references `//third_party/bazel:extra_actions_proto_py`. You
can generate this file by executing `protoc` on
[this](https://github.com/bazelbuild/bazel/blob/master/src/main/protobuf/extra_actions_base.proto)
bazel source proto.

You also need the python library
[scan-build](https://github.com/rizsotto/scan-build), which you can install
with:

```
pip install scan-build
```

Setup is not at all stable. You may run into strange permissions and paths
issues when executing. Sorry!  You will need to edit most of the files. The
bazel targets in `BUILD` must match your repo layout, and you must create a rule
somewhere to make `extra_actions_proto_py` visible to this package. If you don't
use the paths assumed here, you'll have to change the import paths in
`generate_compile_command.py`. On the other hand,
`generate_compile_commands_json.py` should work as is. If you use
`run_clang_analyzer.sh`, you will probably need to change or remove the
`--use-analyzer` option.

## Usage
Before running static analysis tools, you must generate the compilation commands
database. Assuming you set up the targets as above, you can do this with:

```
# From repository root:
bazel clean
bazel build --experimental_action_listener=tools/actions:generate_compile_commands_listener BAZEL_LABELS
./tools/actions/generate_compile_commands_json.py
```

This creates the compilation database file in the repository root with the name
`compile_commands.json`. Other clang tools like `clang-tidy` also like this
file!

To get a static analysis repot, just call `analyze-build`, which was installed
with the `scan-build` python package:

```
analyze-build --cdb compile_commands.json -o clang-analysis --html-title "My Report" 
```

This generates html files in clang-analysis/scan-xxx, which you can serve or
view with a tool of your choice.

##Gotchas
If you use a bazel externalized crosstool (instead of just one in /usr/bin),
you'll have to pass in the compiler path to analyze-build using the
`--use-analyzer` option. In addition, you might have problems with bazel's crazy
source tree. In my repository, I had to execute `analyze-build` from the bazel
execution_root:

```
REPO_ROOT=$PWD
cd `bazel info execution_root`
analyze-build --cdb $REPO_ROOT/compile_commands.json -o $REPO_ROOT/clang-analysis --html-title "My Report" --use-analyzer external/clang_3_8/usr/bin/clang-3.8
```

In addition, bazel may set strange permissions on the bazel cache, so `sudo` may
be required on your `analyze-build` command.

The script `run_clang_analyzer.sh` contains an example workflow. Use like this:

```
./run_clang_analyzer.sh //bazel/targets/...
```
