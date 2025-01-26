# versions.tf - This file content it can be simply added to main.tf however for the best practices of management Terraform tool it is ok to have this code block separated, which specifies provider versions and Terraform requirements.

     terraform {
       required_version = ">= 1.0"

       required_providers {
         google = {
           source  = "hashicorp/google"
           version = "~> 4.0"
         }
         helm = {
           source  = "hashicorp/helm"
           version = "~> 2.0"
         }
       }
     }
