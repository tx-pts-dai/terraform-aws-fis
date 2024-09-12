variable "rds_reboot" {
  description = "Enable the RDS reboot experiment."
  type        = bool
  default     = false
}

variable "rds_failover" {
  description = "Enable the RDS failover experiment."
  type        = bool
  default     = false
}

variable "rds_parameters" {
  description = "Configuration of the instance termination experiment."
  type = object({
    number_of_instances_for_reboot     = optional(number, 1)
    instances_reboot_force_failover_az = optional(bool, false) # If the value is true, and if instances are Multi-AZ, forces failover from one Availability Zone to another.
    number_of_clusters_for_failover    = optional(number, 1)
    target_tag = optional(object({
      key   = string
      value = string
    }))
  })

  validation {
    condition     = var.rds_parameters.number_of_instances_for_reboot > 0
    error_message = "Number of instances to reboot must be greater than 0"
  }

  validation {
    condition     = var.rds_parameters.number_of_clusters_for_failover > 0
    error_message = "Number of clusters to failover must be greater than 0"
  }
}

resource "aws_fis_experiment_template" "rds_reboot" {
  count       = var.rds_reboot ? 1 : 0
  description = "Reboot RDS instances matching a tag."
  role_arn    = aws_iam_role.experiment_runner.arn

  stop_condition {
    source = "none"
  }

  action {
    name      = "reboot-rds-instances"
    action_id = "aws:rds:reboot-db-instances"

    target {
      key   = "DBInstances"
      value = "RDS"
    }

    parameter {
      key   = "forceFailover"
      value = var.rds_parameters.instances_reboot_force_failover_az
    }
  }

  target {
    name           = "RDS"
    resource_type  = "aws:rds:db"
    selection_mode = "COUNT(${var.rds_parameters.number_of_instances_for_reboot})"

    resource_tag {
      key   = (var.rds_parameters.target_tag != null) ? var.rds_parameters.target_tag.key : "chaos"
      value = (var.rds_parameters.target_tag != null) ? var.rds_parameters.target_tag.value : "ready"
    }
  }

  tags = {
    "Name" = "rds-instance-reboot"
  }
}

resource "aws_fis_experiment_template" "cluster_failover" {
  count       = var.rds_failover ? 1 : 0
  description = "Failover RDS clusters matching a tag."
  role_arn    = aws_iam_role.experiment_runner.arn

  stop_condition {
    source = "none"
  }

  action {
    name      = "failover-rds-cluster"
    action_id = "aws:rds:failover-db-cluster"

    target {
      key   = "DBInstances"
      value = "RDS"
    }
  }

  target {
    name           = "RDS"
    resource_type  = "aws:rds:cluster"
    selection_mode = "COUNT(${var.rds_parameters.number_of_clusters_for_failover})"

    resource_tag {
      key   = (var.rds_parameters.target_tag != null) ? var.rds_parameters.target_tag.key : "chaos"
      value = (var.rds_parameters.target_tag != null) ? var.rds_parameters.target_tag.value : "ready"
    }
  }

  tags = {
    "Name" = "rds-cluster-failover"
  }
}
