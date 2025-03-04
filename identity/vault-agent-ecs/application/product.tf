data "aws_ecs_cluster" "cluster" {
  cluster_name = var.name
}

locals {
  product_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "product"
    }
  }
  product_api_name = "product-api"
  product_api_port = 9090
}

module "product_api" {
  source          = "../modules/vault-task/ecs"
  family          = local.product_api_name
  vault_address   = local.hcp_vault_public_endpoint
  vault_namespace = local.hcp_vault_namespace

  vault_agent_template = base64encode(templatefile("templates/conf.json", {
    vault_database_creds_path = local.product_db_vault_path,
    database_address          = local.product_database_hostname,
    products_api_port         = local.product_api_port
  }))

  vault_agent_template_file_name = "conf.json"
  vault_agent_exit_after_auth    = false

  task_role = {
    arn = local.product_api_role_arn
    id  = local.product_api_role
  }

  execution_role = {
    arn = local.product_api_role_arn
    id  = local.product_api_role
  }

  efs_file_system_id  = local.efs_file_system_id
  efs_access_point_id = local.product_api_efs_access_point_id
  log_configuration   = local.product_log_config
  container_definitions = [{
    name      = local.product_api_name
    image     = "hashicorpdemoapp/product-api:v0.0.22"
    essential = true
    portMappings = [
      {
        containerPort = local.product_api_port
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "NAME"
        value = local.product_api_name
      },
      {
        name  = "CONFIG_FILE"
        value = "/config/conf.json"
      },
    ]
  }]
  tags = local.tags
}

resource "aws_ecs_service" "product_api" {
  name            = "product-api"
  cluster         = data.aws_ecs_cluster.cluster.id
  task_definition = module.product_api.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = local.private_subnets
    security_groups = [local.ecs_security_group, local.database_security_group]
  }
  launch_type            = var.enable_ec2_launch_type ? "EC2" : "FARGATE"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true
  load_balancer {
    target_group_arn = local.target_group_arn
    container_name   = "product-api"
    container_port   = 9090
  }
}