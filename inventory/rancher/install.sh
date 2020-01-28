SUCCESS=0
ERROR=1

TRUE=$SUCCESS
FALSE=$ERROR

DEBUG=$TRUE

TRAEFIK_NAMESPACE=traefik
METALLB_NAMESPACE=metallb
METALLB_ADDRESSES=192.168.3.193/26
RANCHER_HELM_REPO="rancher-latest https://releases.rancher.com/server-charts/latest"
RANCHER_NAMESPACE=cattle-system
RANCHER_HOSTNAME=rancher.home.nephelai.io

debug() {

    if [ $# -gt 0 ]; then
        DEBUGSTR=$@
        if [ $DEBUG -eq $TRUE ]; then
            echo $DEBUGSTR
        fi
    fi

}

install_rke() {

    rke up

}

init_helm() {
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
}

create_namespace() {

    if [ "$#" -eq "1" ]; then
        namespace_name=$1
        if kubectl get namespace $namespace_name 2>%1> /dev/null; then
            debug namespace $namespace_name exists
        else
            debug creating namespace
            kubectl create namespace $namespace_name
        fi
    elif [ "$#" -gt "1" ]; then
        for namespace_name in "$@"; do
            create_namespace $namespace_name
        done
    elif [ "$#" -lt "1" ]; then
        echo missing required parameter to create_namespace
        exit $ERROR
    fi

}

helm_install() {

    nargs=2
    helm repo update
    if [ "$#" -gt "$nargs" ]; then
        helm_namespace=$1 ; shift
        helm_release=$1 ; shift
        helm_chart=$1 ; shift
        helm_args="$helm_release $helm_chart --namespace $helm_namespace $@"
        release_count=$(helm list --namespace $helm_namespace -o json |  jq ".[] | [select(.name==\"$helm_release\")] | length")
        if [ "0$release_count" -eq "0" ]; then
            debug helm install $helm_args
            helm install $helm_args
        else
            debug helm upgrade $helm_args
            helm upgrade $helm_args
        fi
    else
        echo missing required parameters to helm_install
        echo "helm_install <name> <chart> ..."
        exit $ERROR
    fi
}

install_metallb() {

    nargs=2
    if [ "$#" -eq "$nargs" ]; then
        export metallb_namespace=$1
        export metallb_addresses=$2
        export metallb_configmap=metallb-config
        create_namespace $metallb_namespace
        envsubst < templates/metallb.yml > build/metallb.yml
        if kubectl create -f build/metallb.yml > /dev/null; then
            debug configmap/${metallb_configmap} created
        else
            kubectl update -f build/metallb.yml
        fi
        helm_install $metallb_namespace metallb stable/metallb
    elif [ "$#" -gt "$nargs" ]; then
        echo too many parameters to install_metallb $@
        echo "usage ${FUNCNAME[0]} <namespace> <network>"
        exit $ERROR
    elif [ "$#" -lt "$nargs" ]; then
        echo missing required parameters to install_metallb
        echo "usage ${FUNCNAME[0]} <namespace> <network>"
        exit $ERROR
    fi
}

install_rancher() {

    nargs=2
    if [ "$#" -eq "$nargs" ]; then
        rancher_namespace=$1
        rancher_hostname=$2
        create_namespace $rancher_namespace
        helm repo add $RANCHER_HELM_REPO 2>&1 >/dev/null
        helm_install $rancher_namespace rancher rancher-latest/rancher --set hostname=$rancher_hostname
        kubectl patch service/rancher -n $rancher_namespace -p '{"spec": {"type": "LoadBalancer"}}'
    elif [ "$#" -gt "$nargs" ]; then
        echo too many parameters to install_rancher $@
        echo "usage ${FUNCNAME[0]} <namespace> <hostname>"
        exit $ERROR
    elif [ "$#" -lt "$nargs" ]; then
        echo missing required parameters to install_rancher
        echo "usage ${FUNCNAME[0]} <namespace> <hostname>"
        exit $ERROR
    fi

}

install_traefik() {

    nargs=2
    if [ "$#" -eq "$nargs" ]; then
        traefik_namespace=$1
        create_namespace $traefik_namespace
        helm_install $traefik_namespace traefik stable/traefik
    elif [ "$#" -gt "$nargs" ]; then
        echo too many parameters to install_traefik $@
        echo "usage ${FUNCNAME[0]} <namespace> <hostname>"
        exit $ERROR
    elif [ "$#" -lt "$nargs" ]; then
        echo missing required parameters to install_rancher
        echo "usage ${FUNCNAME[0]} <namespace> <hostname>"
        exit $ERROR
    fi
}

init_helm
install_metallb $METALLB_NAMESPACE $METALLB_ADDRESSES
install_traefik $TRAEFIK_NAMESPACE
