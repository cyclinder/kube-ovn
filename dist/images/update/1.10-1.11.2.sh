#!/bin/bash
set -eo pipefail

echo "begin upgrade iptables-dnat-rules"
all_dnat=$(kubectl get dnat -o name)
for dnat in $all_dnat;do
    nat_anno=$(kubectl get $dnat -o jsonpath='{.metadata.annotations}'|grep "ovn.kubernetes.io/vpc_eip")
    if [ -n "$nat_anno" ];then
        continue
    fi
    eip=$(kubectl get $dnat -o jsonpath='{.spec.eip}')
    kubectl annotate $dnat ovn.kubernetes.io/vpc_eip=$eip
    eip_anno=$(kubectl get eip $eip -o jsonpath='{.metadata.annotations}'|grep "ovn.kubernetes.io/vpc_nat")
    if [ -n "$eip_anno" ];then
        continue
    fi
    echo "annotate $eip ovn.kubernetes.io/vpc_nat"
    nat_name=$(kubectl get $dnat -o jsonpath='{.metadata.name}')
    kubectl annotate eip $eip ovn.kubernetes.io/vpc_nat=$nat_name
done

echo "begin annotate iptables-snat-rules.kubeovn.io"
all_snat=$(kubectl get snat -o name)
for snat in $all_snat;do
    nat_anno=$(kubectl get $snat -o jsonpath='{.metadata.annotations}'|grep "ovn.kubernetes.io/vpc_eip")
    if [ -n "$nat_anno" ];then
        continue
    fi
    eip=$(kubectl get $snat -o jsonpath='{.spec.eip}')
    kubectl annotate $snat ovn.kubernetes.io/vpc_eip=$eip
    eip_anno=$(kubectl get eip $eip -o jsonpath='{.metadata.annotations}'|grep "ovn.kubernetes.io/vpc_nat")
    if [ -n "$eip_anno" ];then
        continue
    fi
    nat_name=$(kubectl get $snat -o jsonpath='{.metadata.name}')
    kubectl annotate eip $eip ovn.kubernetes.io/vpc_nat=$nat_name
done

echo "begin annotate iptables-fip-rules.kubeovn.io"
all_fip=$(kubectl get fip -o name)
for fip in $all_fip;do
    nat_anno=$(kubectl get $fip -o jsonpath='{.metadata.annotations}'|grep "ovn.kubernetes.io/vpc_eip")
    if [ -n "$nat_anno" ];then
        continue
    fi
    eip=$(kubectl get $fip -o jsonpath='{.spec.eip}')
    kubectl annotate $fip ovn.kubernetes.io/vpc_eip=$eip
    eip_anno=$(kubectl get eip $eip -o jsonpath='{.metadata.annotations}'|grep "ovn.kubernetes.io/vpc_nat")
    if [ -n "$eip_anno" ];then
        continue
    fi
    nat_name=$(kubectl get $snat -o jsonpath='{.metadata.name}')
    kubectl annotate eip $eip ovn.kubernetes.io/vpc_nat=$nat_name
done
