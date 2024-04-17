#! /bin/sh

echo "K8S_DASHBOARD_VERSION=$K8S_DASHBOARD_VERSION"
echo "K8S_DASHBOARD_PORT=$K8S_DASHBOARD_PORT"
echo "PROMETHEUS_PORT=$PROMETHEUS_PORT"
echo "GRAFANA_PORT=$GRAFANA_PORT"

echo "Install kubernetes dashboard $K8S_DASHBOARD_VERSION"
export GITHUB_URL=https://github.com/kubernetes/dashboard/releases && kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${K8S_DASHBOARD_VERSION}/aio/deploy/recommended.yaml

export DASHBOARD_PATCH="{\"spec\":{\"type\":\"NodePort\",\"ports\":[{\"nodePort\":$K8S_DASHBOARD_PORT,\"port\":443,\"protocol\":\"TCP\",\"targetPort\":8443}]}}"
kubectl --namespace kubernetes-dashboard patch svc kubernetes-dashboard --patch $DASHBOARD_PATCH
echo "Expose Dashboard as a NodePort service ($K8S_DASHBOARD_PORT)"

echo "Create monitoring namespace to Prometheus"
kubectl create namespace monitoring

echo "Install Prometheus, Kube state metrics and node exporter"
kubectl apply -f prometheus/ --recursive

export PROMETHEUS_PATCH="{\"spec\":{\"type\":\"NodePort\",\"ports\":[{\"nodePort\":$PROMETHEUS_PORT,\"port\":8080,\"protocol\":\"TCP\",\"targetPort\":9090}]}}"
kubectl --namespace monitoring patch svc prometheus-service --patch $PROMETHEUS_PATCH
echo "Expose Prometheus as a NodePort service ($PROMETHEUS_PORT)"

echo "Install Grafana"
kubectl apply -f grafana/

export GRAFANA_PATCH="{\"spec\":{\"type\":\"NodePort\",\"ports\":[{\"nodePort\":$GRAFANA_PORT,\"port\":3000,\"protocol\":\"TCP\",\"targetPort\":3000}]}}"
kubectl --namespace monitoring patch svc grafana --patch $GRAFANA_PATCH
echo "Expose Grafana as a NodePort service ($GRAFANA_PORT)"

echo "Waiting for k3s services initialized..."
export MAX_TRY=60
export INITIAL_DELAY=10
export DELAY=10

echo "Inital delay: $INITIAL_DELAY sec..."
sleep $INITIAL_DELAY

TRY=0
while : ; do
		TRY=$((${TRY} + 1))
		
		echo "====================================================================================="
		echo "Try ${TRY}/${MAX_TRY}"
		
		PODS_STATUS=$(kubectl get pod --field-selector=status.phase!=Running,status.phase!=Succeeded --all-namespaces)

		SIZE=$(expr "$PODS_STATUS" : '.*')
		
		echo "Pod status:"
		echo "$PODS_STATUS"
		echo "====================================================================================="

		sleep $DELAY
		
    [[ $SIZE != 0 && $TRY != $MAX_TRY ]] || break
done