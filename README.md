## This Reporistory contains three main folders 
1. **container**: it contains python code and Dockerfiles
2. **task**: it contains the requested task including kubernetes manifest files/helm charts + grafana + prometheus setup modules 
3. **bonus**: it contains two folders flagger and aws-terraform-k8s 
   1. flagger: contains step by step how to implement a flagger to fully taking over the canary deployment automation including monitoring the deployment as well notify via slack when it finishes 
   2. aws-terraform-k8s: step by step how to build kuberentes cluster using terraform where nodes are in different availablity zones   

### My answers comments for the challanges and the questions : 
1. **It should be highly available and scalable: The application has to be fault-tolerant regarding the loss of one cluster node and automatically scalable depending on the CPU load available across multiple nodes.**  
**Ans:** I did build a deployment with HPA that starts with 2 pods and it can increases up to 5 pods depending on CPI load and traffic please check `task/k8s/employees/templates/emp-deployment.yaml` and `task/k8s/employees/templates/emp-hpa.yaml` , by nature kubernetes will migrate the pods on specific nodes if it has a failure and we can setup autoscalling group for the kuberentes service which can increase the number of nodes (with upper and lower limits) in case there is need.  

2. **Give an example of how you would expose secure credentials as an environment variable. It could be faking the database connection even if the app doesn't need one**  
**Ans:** the application i build requires a connection to DB and i did put the connection credntial in secret configuration and exposed it as environment variable to the deployment's pods please `task/k8s/employees/templates/db-secrets.yaml` and `task/k8s/employees/templates/emp-secrets.yaml` and added the secrets as environment variables to `task/k8s/employees/templates/db-deploy.yaml` and  `task/k8s/employees/templates/emp-deployment.yaml` like below  
``` 
- secretRef:
    name: mysql-secret
---
- secretRef:
    name: emp-secret
```
3. **If the application is stateful - then it should have a persistent volume configuration**  
   **Ans:** My main application is a stateless application written in python/flask which requires DB connection , in this setup i setup the DB as deployment of one replicas which makes it works but for production environments i would have one of the two options: 
   - if we are on cloud i would prefer to use a cloud managed DB rather than keep the data base within the kubernetes cluster
   - if i've to set it up within the cluster i would choose statefulset as setup for the DB in order to have DB cluster one primary and one secondary one is having read/write and second is having only read access and both are sharing the persistent volume

4. **You should make use of the readiness and liveness probe as much as feasible.**  
**Ans:** I build a health page for my main microservice on `/api/health` and defined liveness/readiness within the deployment please check file `task/k8s/employees/templates/emp-deployment.yaml`
```
livenessProbe:
    httpGet:
       path: /api/info
       port: 8080
readinessProbe:
    httpGet:
       path: /api/health
       port: 8080
```
5. **if possible, Ingress should be deployed for the opportunity to access the application outside of the private network**  
**Ans:** I used helm repo to install ingress-nginx charts ![install-ingress-nginx](https://github.com/moaaznoaman/k8s/tree/master/task#install-ingress-nginx)

## follow-up questions: 
1. **Where and how did you set up the Kubernetes cluster? Why did you consider this option? How would you handle the cluster setup next time you'll need a new one?**
**Ans:** I did setup kubernetes on AWS as well sometimes i do set it up on GKE. 
usually i use kops to setup the cluster but there are different many other alternatives which i used before like
    - kops for AWS
    ```bash 
        # create cluster using kops with nodes in multiple availability zones
        kops create cluster \
        --name k8s.moaaznoaman.com \
        --state s3://hash-kops-kube-bucket \
        --cloud aws \
        --master-size t2.medium \
        --master-count 1 \
        --master-zones eu-west-1a \
        --node-size t2.medium \
        --node-count 1 \
        --zones eu-west-1a,eu-west-1b,eu-west-1c
    ```
    - eksctl for AWS
    ``` bash
    # create simple k8s cluster on aws using eksctl
    cat <<EOF | eksctl create cluster -f -
        apiVersion: eksctl.io/v1alpha5
        kind: ClusterConfig
        metadata:
        name: EKS-cluster
        region: eu-west-1
        nodeGroups:
        - name: ng-1
            instanceType: t2.small
            desiredCapacity: 3
            ssh: # use existing EC2 key
            publicKeyName: eks-keypair
        EOF
    ```

    - gcloud for GKE
    ```bash
        gcloud container clusters create my-k8s-cluster \
        --project "project-name" \
        --zone "europe-west1-b" \
        --cluster-version "latest" \ 
        --machine-type "n1-standard-4" \
        --num-nodes "3" \  
        --enable-autoscaling \
        --min-nodes "3" \
        --max-nodes "6"
    ```
    - kubespray for all cloud providers
    - previously i used `terraform` to build high available kubernetes clusters in different AWS availability zones  

1. **How would you improve the application setup?**
    a. **Would you go with CI/CD pipeline? If so, which one?**  
    **Ans:**  
    Using integration tools like gitlab/jenkins i am familiar with pipeline for both as we use already gitlab pipelines for building DC infrastructure using terraform as well we use jenkins pipeline applications deployment pipelines and i alreayd write a sample pipeline in Jenkinsfile (task/Jenkinsfile) 

    b. **Would you template the setup? If so, which tool would you choose for that?**  
    **Ans:**  
    If so, which tool would you choose for that? if the question about templating the kubernetes code there are different alternatives like helm and kustomize , i used helm to build my chart and you can find info how to trigger it in file `task/README.md` in section "install my application using helm chartchart" 

    c. **How would you monitor the application? What kind of metrics would you choose**  
    **Ans:**  
    There are different way to monitor kubernetes cluster and the applications i already explained in step-by-step approach how to integrate kubernetes cluster with prometheus and grafana and exposing the application metrics using kube-state-metrics via `/metrics` path , however we can monitor the application and forward the cluster logs to ELK stack as well.  

2. **How would you scale the application setup across multiple regions?**
  **Ans:** 
     - We can build a cluster on different cloud provider and using different tools , for AWS then EKS would be perfect choice for the above case since it's managed kubernetes service provided by AWS and we can build the cluster on nodes on different availablity zones even using `spot instances` , with spot instances we can build kubernetes on nodes with very high discounts and actually we can run a script to get the termination notice from the metadata and if there is a termination flag the script can cordon the node then the schedular will no longer and schedule any pods for this node and migrate the existing ones to new node which could start by the autoscalar group in case there is no enough capacity in the nodes of the existing cluster.
       sample command 
       ```bash
       # this creates a cluster with single nodegroup in specific region 
       eksctl create cluster --name EKS-cluster \
       --region eu-west-1 \
       --nodegroup-name standard-nodes \
       --node-type t2.small \
       --nodes 3 \ # initial nodes count 
       --nodes-min 3 \ # min nodes count 
       --nodes-max 5 \ # max nodes count 
       --ssh-public-key eks-keypair.pem
       --managed
       ```
       to setup eks cluster with nodegroup in multiple availability zones
       ```bash
        eksctl create cluster -f task/eks-multi-az.yaml
       ```
      - Important to mention that setup depends on the application architecture and design, for example EBS can't shared between AZs so we can have different nodegroups , one of them handles the stateful applications workloads and others handle the stateless applications workload
      - as well we can use kops and other utilities to build such multi zones and multi region clusters 


## Note
Within every folder a README.md file which explains steps-by-step the requirements