{ config, vars, ... }:

let
  username = "${vars.ceph-username}";
  mon-ip = "${vars.ceph-ip}";
  mount1-directory = "${vars.ceph-directory1}";
  mount1-filesystem = "${vars.ceph-filesystem1}";
  mount2-directory = "${vars.ceph-directory2}";
  mount2-filesystem = "${vars.ceph-filesystem2}";
in

{
  systemd.tmpfiles.rules = [
    "d ${mount1-directory} 0777 root root"
    "d ${mount2-directory} 0777 root root"
  ];

  fileSystems."${mount1-directory}" = {
    device = "${mon-ip}:/";
    fsType = "ceph";
    options = [
      "name=${username}"
      "mds_namespace=${mount1-filesystem}"
      "acl"
    ];
  };

  fileSystems."${mount2-directory}" = {
    device = "${mon-ip}:/";
    fsType = "ceph";
    options = [
      "name=${username}"
      "mds_namespace=${mount2-filesystem}"
      "acl"
    ];
  };
}
