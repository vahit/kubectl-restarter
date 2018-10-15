# Kubectl Restarter
Restart a whole of a namespace or specific deployments in it. You can Exclude some deployments too.

### Options:
+ **n**: Namespace (defauotl value=**default**)
+ **e**: Exclude one or more deployments. this option argument is an *array of deployments.*
+ **o**: You can specific deployments list with this option.

#### Examples:
+ Restart all of deployments in *default* namespace:
```kubectl-restart.sh```
+ Restart all of deployments in *testing* namespace:
```kubectl-restart -n testing```
+ Restart all of deployments in *testing* namespace except *mysql* and *redis* deployments:
```kubectl-restart -n testing -e "mysql redis"```
and ...

