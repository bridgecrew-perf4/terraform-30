locals {

  master_user_data = templatefile("${path.module}/user-data.yaml",
                    {
                    es_version = var.es_version
                    })

  data_user_data = templatefile("${path.module}/user-data.yaml",
                    {
                    es_version = var.es_version
                    })

  ingest_user_data = templatefile("${path.module}/user-data.yaml",
                    {
                    es_version = var.es_version
                    })                    

}
