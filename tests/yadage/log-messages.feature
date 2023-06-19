# Tests for the expected log messages

Feature: Log messages

    As a researcher,
    I want to be able to see the log messages of my workflow execution,
    So that I can verify that the workflow ran correctly.

    Scenario: The workflow start has produced the expected messages
        When the workflow is finished
        Then the engine logs should contain "yadage.creators | MainThread | INFO | initializing workflow"
        And the engine logs should contain "yadage.wflowview | MainThread | INFO | added </gendata:0|defined|unknown>"
        And the engine logs should contain "yadage.wflowview | MainThread | INFO | added </fitdata:0|defined|unknown>"

    Scenario: The generation step has produced the expected messages
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

    Scenario: The fitting step has produced the expected messages
        When the workflow is finished
        Then the job logs for the "fitdata" step should contain "MIGRAD MINIMIZATION HAS CONVERGED."

    Scenario: The workflow completion has produced the expected messages
        When the workflow is finished
        Then the engine logs should contain "adage | MainThread | INFO | workflow completed successfully."
        And the engine logs should contain "adage | MainThread | INFO | execution valid. (in terms of execution order)"
