locals {

  master_user_data = templatefile("${path.module}/user-data.yaml",
                    {})                

}
