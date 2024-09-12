# Fault Injection Simulation

This module provides a set of AWS FIS templates that can be re-used and parametrized.

The documentations input and output can be generated with:

````bash
terraform-docs markdown --anchor=false --html=false --indent=3 --output-file=terraform-docs.md .
````

## Core concepts

AWS FIS is a tool to execute chaos engineering experiments on your AWS infrastructure. This module will contain a set of opt-in, configurable experiments you can use to create chaos and verify hypothesis about your infrastructure.

By default no resources are created, you have to opt-in to everything you specifically want to do. In the future, once this practice has been established, we will enable all experiments by default, because we hope the system will be strong enough.

## How do you use this module?

Create the following new module block with the desired parameters in `application_name.tf`

```tf
module "chaos_engineering" {
  source  = "tx-pts-dai/fis/aws"
  version = "1.0.0"

  instance_termination = true
  instance_termination_parameters = {
    target_tag = {
      key   = "chaos"
      value = "ready"
    }
  }
}
```
