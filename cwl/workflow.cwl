#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  events:
    type: int

outputs:
  plot:
    type: File
    outputSource:
      fitdata/result


steps:
  gendata:
    run: gendata.cwl
    in:
      events: events
    out: [data]
  fitdata:
    run: fitdata.cwl
    in:
      data: gendata/data
    out: [result]
