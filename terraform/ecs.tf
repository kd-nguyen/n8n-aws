resource "aws_ecs_cluster" "n8n" {
  name = var.app_name
}

resource "aws_ecs_task_definition" "n8n" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = jsonencode([
    {
        name            = var.app_name
        image           = "docker.n8n.io/n8nio/n8n"
        cpu             = 1024
        memory          = 2048
        essential       = true
        portMappings    = [
            {
                containerPort = 5678
                hostPort      = 5678
            }
        ]
    }
  ])

}

resource "aws_ecs_service" "n8n" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.n8n.id
  task_definition = aws_ecs_task_definition.n8n.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.n8n.arn
    container_name   = var.app_name
    container_port   = 5678
  }

  network_configuration {
    subnets = var.public_subnets
    assign_public_ip  = true
    security_groups = [aws_security_group.n8n.id]
  }
}
