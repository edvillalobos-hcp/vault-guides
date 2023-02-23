module "task_role" {
  source                        = "../modules/vault-task/iam"
  name                          = "${var.name}-product-api"
  ecs_task_efs_access_point_arn = local.product_api_efs_access_point_arn
}