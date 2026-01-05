

VRF

```


router ospf 1 vrf NAME
 network IP 0.0.0.0 area 0
 redistribute bgp AS subnets
```



MP-BGP配置

```
router bgp AS
  bgp router-id X:X:X:X
  no bgp default ipv4-unicast
  neighbor IP remote AS
  neighbor IP update-source INTERFACE
  address-family vpnv4
    neighbor IP activate
    neighbor IP send-community extended
```

重发布

```
router bgp AS
  address-family ipv4 vrf NAME
  redistribute ospf 1 vrf NAME match internal external
  
router ospf 1 vrf NAME
 network IP 0.0.0.0 area 0
 redistribute bgp AS subnets
```

