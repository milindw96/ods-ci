*** Settings ***
Documentation       Test suite testing SERH Metrics
Resource            ../../../Resources/RHOSi.resource
Resource            ../../../Resources/ODS.robot
Resource            ../../../Resources/Common.robot


*** Variables ***
@{serh_querys}   node_namespace_pod_container:container_memory_working_set_bytes  node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate
                ...  namespace_workload_pod:kube_pod_owner:relabel  kube_pod_container_info  kube_pod_status_ready
                ...  kube_namespace_status_phase  node_namespace_pod:kube_pod_info  kube_pod_container_status_last_terminated_reason    kube_pod_container_status_waiting
                ...  kube_service_info   cluster:namespace:pod_memory:active:kube_pod_container_resource_limits  container_cpu_cfs_throttled_seconds_total
                ...  container_fs_usage_bytes  container_network_transmit_bytes_total  kube_pod_container_resource_requests    container_memory_usage_bytes
                ...  container_network_receive_bytes_total  kube_deployment_status_replicas_available  kube_node_status_capacity   container_memory_working_set_bytes
                ...  kube_deployment_status_replicas_unavailable  kube_persistentvolumeclaim_status_phase  kube_pod_container_resource_limits
                ...  node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate  cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits
                ...  container_network_receive_packets_total  container_network_transmit_packets_total  container_network_transmit_packets_total  container_network_transmit_packets_total
                ...  container_cpu_usage_seconds_total  kube_pod_container_status_restarts_total  kube_pod_status_phase  cluster:namespace:pod_memory:active:kube_pod_container_resource_requests
                ...  jmx_config_reload_success_total  jmx_scrape_duration_seconds  jmx_scrape_cached_beans  jmx_scrape_error  jmx_exporter_build_info  jmx_config_reload_failure_total
                ...  jmx_config_reload_failure_created  jmx_config_reload_success_created

*** Test Cases ***
Verify STARBURST Query For Observatorium
    [Documentation]    Verifies the Observatorium metrics values are not none
    [Tags]    MISV-96
    ${SSO_TOKEN}    Prometheus.Get Observatorium Token
    @{value}=    Create List
    FOR  ${query}   IN   @{serh_querys}
        ${obs_query_op}=    Prometheus.Run Query    ${STARBURST.OBS_URL}    ${SSO_TOKEN}
        ...   ${query}{namespace="redhat-starburst-operator"}   project=SERH
        Should Be Equal    ${obs_query_op.json()['status']}    success
        FOR  ${data}    IN   @{obs_query_op.json()['data']['result']}
            Should Not Be Empty    ${data['value']}
            Length Should Be   ${data['value']}   ${2}

            Log  ${data['metric']['__name__']} |${data['metric']['pod']}| ${data['value']}
            Append To List  ${value}    ${data['value']}
        END
    END
    ${count}    Get Length    ${value}
    Should Be Equal   ${count}   ${394}
