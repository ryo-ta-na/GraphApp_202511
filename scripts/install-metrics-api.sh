kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl delete deployment metrics-server -n kube-system

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --kubelet-insecure-tls
        image: k8s.gcr.io/metrics-server/metrics-server:v0.7.0
        imagePullPolicy: IfNotPresent
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
EOF