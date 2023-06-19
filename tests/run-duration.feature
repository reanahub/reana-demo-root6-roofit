# This file is part of REANA.
# Copyright (C) 2023 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

Feature: Run duration

    As a researcher,
    I want to verify that my workflow finishes in a reasonable amount of time,
    So that I can detect any unusual problems with computing infrastructure.

    Scenario: The workflow terminates in a reasonable amount of time
        When the workflow is finished
        Then the workflow run duration should be less than 4 minutes

    Scenario: The data generation step terminates in a reasonable amount of time
        When the workflow is finished
        Then the duration of the step "gendata" should be less than 2 minutes

    Scenario: The fitting step terminates in a reasonable amount of time
        When the workflow is finished
        Then the duration of the step "fitdata" should be less than 2 minutes

