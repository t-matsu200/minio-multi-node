output "connect_instance_cmds" {
  value = templatefile("./output-template.txt", {
    AWS_INSTANCE1 = aws_instance.minio_multi_node[0].id
    AWS_INSTANCE2 = aws_instance.minio_multi_node[1].id
    AWS_INSTANCE3 = aws_instance.minio_multi_node[2].id
    AWS_INSTANCE4 = aws_instance.minio_multi_node[3].id
  })
}
