#!/usr/bin/env cwl-runner

# Note that if you are working on the analysis development locally, i.e. outside
# of the REANA platform, you can proceed as follows:
#
#   $ cd reana-demo-root6-roofit
#   $ mkdir cwl-local-run
#   $ cd cwl-local-run
#   $ cp -a ../code ../workflow/cwl/input.yml .
#   $ cwltool --quiet --outdir="../results" ../workflow/cwl/workflow.cwl input.yml
#   $ firefox ../results/plot.png


cwlVersion: v1.0
class: Workflow

inputs:
  gendata_tool: File
  fitdata_tool: File
  events: int

outputs:
  plot:
    type: File
    outputSource:
      fitdata/result
  gendata.log:
    type: File
    outputSource:
      gendata/gendata.log
  fitdata.log:
    type: File
    outputSource:
      fitdata/fitdata.log

steps:
  gendata:
    run: gendata.cwl
    in:
      gendata_tool: gendata_tool
      events: events
    out: [data, gendata.log]
  fitdata:
    run: fitdata.cwl
    in:
      fitdata: fitdata_tool
      data: gendata/data
    out: [result, fitdata.log]
