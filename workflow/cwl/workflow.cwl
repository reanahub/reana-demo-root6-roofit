#!/usr/bin/env cwl-runner

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


steps:
  gendata:
    run: gendata.cwl
    in:
      gendata_tool: gendata_tool
      events: events
    out: [data]
  fitdata:
    run: fitdata.cwl
    in:
      fitdata: fitdata_tool
      data: gendata/data
    out: [result]
