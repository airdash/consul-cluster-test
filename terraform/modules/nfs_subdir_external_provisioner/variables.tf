variable "chart_version" { default = "" }

# The following variable defines an arbitrary number of NFS based PVC classes.

# reclaim_policy can be "Recycle", "Retain" or "Delete"
# binding_mode can be "Immediate" for now

# variable "nfs_shares" { 
#   type = list(object({
#     name = string
#     server = string
#     share = string
#     reclaim_policy = string
#     binding_mode = string
#   }))
# 
#   default = []
# }
