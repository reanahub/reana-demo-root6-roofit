# Tests for the expected workflow run duration

Feature: Run duration

    As a researcher,
    I want to verify that my workflow finishes in a reasonable amount of time,
    so that I can stay assured that there are no unusual problems with computing resources.

    Scenario: The workflow terminates in a reasonable amount of time
        When the workflow is finished
        Then the workflow run duration should be less than 10 minutes

    Scenario: The data generation step terminates in a reasonable amount of time
        When the workflow is finished
        Then the duration of the step "gendata" should be less than 8 minutes

    Scenario: The fitting step terminates in a reasonable amount of time
        When the workflow is finished
        Then the duration of the step "fitdata" should be less than 5 minutes

