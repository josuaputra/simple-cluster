variable "rules" {
  description = "Available security groups rules"
  type        = map(list(any))
  default = {
    # Fallback if no valid rules selected
    _   = [0, 0, "", ""]
    all = [0, 0, "-1", "Allow all traffic"]

    # Common
    ssh-22-tcp       = [22, 22, "tcp", "SSH 22"]
    dns-53-tcp       = [53, 53, "tcp", "DNS 53 TCP"]
    dns-53-udp       = [53, 53, "udp", "DNS 53 UDP"]
    openvpn-1194-tcp = [1194, 1194, "tcp", "OpenVPN 1194 TCP"]
    openvpn-1194-udp = [1194, 1194, "udp", "OpenVPN 1194 UDP"]

    # HTTP
    http-80-tcp   = [80, 80, "tcp", "HTTP 80"]
    http-8080-tcp = [8080, 8080, "tcp", "HTTP 8080"]
    https-443-tcp = [443, 443, "tcp", "HTTPS 443"]

    # Database
    pgsql-5432-tcp        = [5432, 5432, "tcp", "PostgreSQL 5432"]
    pgbouncer-5439-tcp    = [5439, 5439, "tcp", "PGBouncer 5439"]
    mysql-3306-tcp        = [3306, 3306, "tcp", "MySQL 3306"]
    redshift-5439-tcp     = [5439, 5439, "tcp", "Redshift 5439"]

    # Cache
    redis-6379-tcp      = [6379, 6379, "tcp", "Redis"]
    memcached-11211-tcp = [11211, 11211, "tcp", "Memcached 11211"]

    # Kafka & ZooKeeper
    zookeeper-2181-tcp = [2181, 2181, "tcp", "Zookeeper 2181"]
    kafka-9092-tcp     = [9092, 9092, "tcp", "Kafka 9092"]

    # RabbitMQ
    rabbitmq-4369-tcp  = [4369, 4369, "tcp", "RabbitMQ epmd"]
    rabbitmq-5671-tcp  = [5671, 5671, "tcp", "RabbitMQ"]
    rabbitmq-5672-tcp  = [5672, 5672, "tcp", "RabbitMQ"]
    rabbitmq-15672-tcp = [15672, 15672, "tcp", "RabbitMQ"]
    rabbitmq-25672-tcp = [25672, 25672, "tcp", "RabbitMQ"]

    # ElasticSearch
    elasticsearch-kibana-5601-tcp = [5601, 5601, "tcp", "ElasticSearch Kibana 5601"]
    elasticsearch-9200-tcp        = [9200, 9200, "tcp", "ElasticSearch REST 9200"]
    elasticsearch-9300-tcp        = [9300, 9300, "tcp", "ElasticSearch Java 9300"]

    # Kubernetes
    k8s-apiserver-6443-tcp       = [6443, 6443, "tcp", "Kubernetes APIServer 6443"]
    k8s-etcdpeer-2380-tcp        = [2380, 2380, "tcp", "Kubernetes ETCD Peer 2380"]
    k8s-etcdserver-2379-tcp      = [2379, 2379, "tcp", "Kubernetes ETCD Server 2379"]
    k8s-kubelet-10250-tcp        = [10250, 10250, "tcp", "Kubernetes Kubelet 10250"]
    k8s-nodeport-30000-32767-tcp = [30000, 32767, "tcp", "Kubernetes NodePort TCP"]
    k8s-nodeport-30000-32767-udp = [30000, 32767, "udp", "Kubernetes NodePort UDP"]

    # Hashicorp
    vault-telemetry-8125-tcp = [8125, 8125, "tcp", "Vault Telemetry 8125"]
    vault-server-8200-tcp    = [8200, 8200, "tcp", "Vault Server 8200"]
    consul-server-8300-tcp   = [8300, 8300, "tcp", "Consul Server 8300"]
    consul-serflan-8301-tcp  = [8301, 8302, "tcp", "Consul Serf LAN 8301 TCP"]
    consul-serflan-8301-udp  = [8301, 8302, "udp", "Consul Serf LAN 8301 UDP"]
    consul-serfwan-8302-tcp  = [8302, 8302, "tcp", "Consul Serf LAN 8302 TCP"]
    consul-serfwan-8302-udp  = [8302, 8302, "udp", "Consul Serf LAN 8302 UDP"]
    consul-http-8500-tcp     = [8500, 8500, "tcp", "Consul HTTP 8500"]
    consul-dns-8600-tcp      = [8600, 8600, "tcp", "Consul DNS 8600 TCP"]
    consul-dns-8600-udp      = [8600, 8600, "udp", "COnsul DNS 8600 UDP"]

    # Prometheus
    prometheus-metrics-9100-9799-tcp = [9100, 9799, "tcp", "Prometheus Metrics Exporter"]
    prometheus-server-9090-tcp       = [9090, 9090, "tcp", "Prometheus Server 9090"]
    prometheus-pushgateway-9091-tcp  = [9090, 9090, "tcp", "Prometheus PushGateway 9091"]
    prometheus-alertmanager-9093-tcp = [9093, 9093, "tcp", "Prometheus AlertManager 9093"]
    prometheus-alertmanager-9094-tcp = [9094, 9094, "tcp", "Prometheus AlertManager 9094"]

    # Jenkins
    jenkins-agent-50000-tcp = [50000, 50000, "tcp", "Jenkins Slave agent 50000"]
  }
}
