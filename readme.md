# Kubectl Restarter
Restart/Scale DOWN and UP it again a whole of deployments in a namespace or specific deployment.
You can Exclude some deployments and you can use this script to only Scale UP or Scale DOWN (specific or all of)Deployments in namespace.

### Options:
+ **n**: Namespace (*REQUIRED*)
+ **e**: Exclude one or more deployments. this option argument is an *array of deployments.*
+ **o**: Deployment name, If you wand work on one specific deployment it's *REQUIRED*. 
+ **s**: Scale UP/DOWN, If you wand scale up or down deployment you need this option.
+ **r**: Restart one or more deployment. This option Don't has any argument.

#### Note:
You should use as one of **r** or **s** options.

#### Examples:
+ Restart all of deployments in *testing* namespace:
`kubectl-restart -n testing`
+ Restart all of deployments in *testing* namespace except *mysql* and *redis* deployments:
`kubectl-restart -n testing -e "mysql redis"`
+ Scale *mysql* deployment to 5 from *testing* namespace.
`kubectl-restart -n testing -s 5 -o mysql`
and ...

