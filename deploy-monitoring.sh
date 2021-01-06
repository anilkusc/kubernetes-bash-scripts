#!/bin/bash
echo "
kind: Namespace
apiVersion: v1
metadata:
  name: monitoring
  labels:
    name: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: default
  namespace: monitoring
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-alert
  labels:
    name: prometheus-alert
  namespace: monitoring
data:
  alert.rules: |-
    groups:
    - name: example
      rules:
      - alert: Node Down
        expr: up{job="node-exporter"} == 0
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "\n Environment Informations \n 10.10.0.38:9100 = development-active"
          description: "This node is down: {{ $labels }} "
      - alert: Excessive Disk Usage
        expr: 100 - (node_filesystem_avail_bytes*100) / (node_filesystem_size_bytes) > 75
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "\n Environment Informations \n 10.10.0.38:9100 = development-active"
          description: "The node with this IP ({{ $labels.instance }}) needs more disk space({{ it is using % $labels }})"
      - alert: Excessive RAM Usage
        expr: 100 *((node_memory_MemTotal_bytes) - (node_memory_MemFree_bytes + node_memory_Buffers_bytes + node_memory_Cached_bytes)) / node_memory_MemTotal_bytes > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "\n Environment Informations \n 10.10.0.38:9100 = development-active"
          description: "The node with this IP({{ $labels.instance }}).\n It is using over %80 of its RAM ({{ $labels  }}) "
      - alert: High Cpu Load
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "\n Environment Informations \n 10.10.0.38:9100 = development-active"
          description: "CPU load is > 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }} "
      - alert: Unusual Network Throughput In
        expr: sum by (instance) (irate(node_network_receive_bytes_total[2m])) / 1024 / 1024 > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Unusual network throughput in (instance {{ $labels.instance }})"
          description: "Host network interfaces are probably receiving too much data (> 100 MB/s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }} "
      - alert: Unusual Network Throughput Out
        expr: sum by (instance) (irate(node_network_transmit_bytes_total[2m])) / 1024 / 1024 > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Unusual network throughput out (instance {{ $labels.instance }})"
          description: "Host network interfaces are probably sending too much data (> 100 MB/s)\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }} "
      - alert: Some of the Containers Restarted or Killed
        expr: time() - container_last_seen{namespace="prod",pod_name=~"mongo-0|postgres-0|mssql-0|redis-0",container=~"mongo|postgres|mssql|redis"}  > 60
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Some of the database containers have killed or restarted in prod space: (server {{ $labels.instance }} database {{ $labels.pod }})"
          description: "A container has disappeared\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }} "          
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-server-conf
  labels:
    name: prometheus-server-conf
  namespace: monitoring
data:
  prometheus.yml: |-
    global:
      scrape_interval: 5s
      evaluation_interval: 5s
    alerting:
      alertmanagers:
      - static_configs:
        - targets: ['alertmanager.monitoring.svc.cluster.local:9093']
    rule_files:
       - ./rules/alert.rules
    scrape_configs:
      - job_name: 'node-exporter'
        static_configs:
        - targets: ['10.10.0.20:9100','10.10.0.21:9100','10.10.0.22:9100']
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
        - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https
      - job_name: 'kubernetes-nodes'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name
      - job_name: 'kubernetes-cadvisor'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
      - job_name: 'kubernetes-service-endpoints'
        kubernetes_sd_configs:
        - role: endpoints
        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-deployment
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus-server
  template:
    metadata:
      labels:
        app: prometheus-server
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:v2.2.1
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus/"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: prometheus-config
              mountPath: /etc/prometheus/              
            - name: prometheus-alert
              mountPath: /etc/prometheus/rules/       
            - name: prometheus-storage-volume
              mountPath: /prometheus/            
      volumes:
        - name: prometheus-config
          configMap:
            name: prometheus-server-conf            
        - name: prometheus-alert
          configMap:
            name: prometheus-alert            
        - name: prometheus-storage-volume
          hostPath:
            path: /volumes/prometheus/
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus-service
  namespace: monitoring
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/port:   '9090'
spec:
  selector:
    app: prometheus-server
  type: NodePort
  ports:
    - port: 9090
      targetPort: 9090
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager
  labels:
    name: alertmanager
  namespace: monitoring
data:
  alertmanager.yml: |-
    global:
      resolve_timeout: 5m
      smtp_smarthost: 'smtp.gmail.com:25'
      smtp_from: 'alarm@gmail.com'
      smtp_require_tls: false
      smtp_hello: 'alert'
    route:
      group_by: ['instance', 'alert']
      group_wait: 30s
      group_interval: 1m
      repeat_interval: 15m
      receiver: team-1
    receivers:
      - name: 'team-1'
        email_configs:
          - to: 'anilkuscu95@gmail.com'
            send_resolved: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alertmanager
  template:
    metadata:
      labels:
        app: alertmanager
    spec:
      containers:
        - name: alertmanager
          image: prom/alertmanager:v0.19.0
          ports:
            - containerPort: 9093
          volumeMounts:
            - name: alertmanager-config
              mountPath: /etc/alertmanager/   
      volumes:
        - name: alertmanager-config
          configMap:
            name: alertmanager
---
apiVersion: v1
kind: Service
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 9093
    targetPort: 9093
  selector:
    app: alertmanager
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana
        imagePullPolicy: Never
        ports:
        - containerPort: 3000
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  labels:
    kubernetes.io/cluster-service: 'true'
    kubernetes.io/name: monitoring-grafana
  name: grafana
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: grafana
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      name: node-exporter
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:v0.18.1
        ports:
        - containerPort: 9100
          name: scrape
        securityContext:
          privileged: true
" > monitoring.yaml
kubectl apply -f monitoring.yaml
