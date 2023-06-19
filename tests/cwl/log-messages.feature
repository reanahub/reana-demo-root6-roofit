# Tests for the expected log messages

Feature: Log messages

    As a researcher,
    I want to be able to see the log messages of my CWL workflow execution,
    So that I can verify that the workflow ran correctly.

    Scenario: The workflow start has produced the expected messages
        When the workflow is finished
        Then the engine logs should contain "cwltool | MainThread | INFO | [workflow ] start"
        And the engine logs should contain "cwltool | MainThread | INFO | [step gendata] start"
        And the engine logs should contain "cwltool | MainThread | INFO | [step fitdata] start"

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
        Then the engine logs should contain "cwltool | MainThread | INFO | Final process status is success"
