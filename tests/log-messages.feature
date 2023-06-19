# This file is part of REANA.
# Copyright (C) 2023 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

Feature: Log messages

    As a researcher,
    I want to be able to see the log messages of my workflow execution,
    So that I can verify that my workflow jobs ran correctly.

    Scenario: The workflow engine produces expected messages
        When the workflow is finished
        Then the engine logs should contain "Publishing step:0, cmd: mkdir -p results && root -b -q"

    Scenario: The generation step produces expected messages
        When the workflow is finished
        Then the job logs for the "gendata" step should contain
            """
            variables
            ---------
            (a0,a1,mean,nbkg,nsig,sig1frac,sigma1,x)
            """
        And the job logs for the "gendata" step should contain
            """
            datasets
            --------
            RooDataSet::modelData(x)
            """

    Scenario: The fitting step produces expected messages
        When the workflow is finished
        Then the job logs for the "fitdata" step should contain "MIGRAD MINIMIZATION HAS CONVERGED."
