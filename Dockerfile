# Environment: ROOT6
FROM reanahub/reana-env-root6

# Code: generation and fitting macros
WORKDIR /code
ADD gendata.C gendata.C
ADD fitdata.C fitdata.C
