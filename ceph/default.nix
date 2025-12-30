{ vars, ... }:

let
  mon-ip = "${vars.ceph-ip}";
  username = "${vars.ceph-username}";
  secret = "${vars.ceph-secret}";
  mount1-directory = "${vars.ceph-directory1}";
  mount1-filesystem = "${vars.ceph-filesystem1}";
  mount2-directory = "${vars.ceph-directory2}";
  mount2-filesystem = "${vars.ceph-filesystem2}";
  mount3-directory = "${vars.ceph-directory3}";
  mount3-filesystem = "${vars.ceph-filesystem3}";
  mount4-directory = "${vars.ceph-directory4}";
  mount4-filesystem = "${vars.ceph-filesystem4}";
in
{
  systemd.tmpfiles.rules = [
    "d ${mount1-directory} 0777 root root"
    "d ${mount2-directory} 0777 root root"
    "d ${mount3-directory} 0777 root root"
    "d ${mount4-directory} 0777 root root"
  ];

  fileSystems."${mount1-directory}" = {
    device = "${mon-ip}:/";
    fsType = "ceph";
    options = [
      "name=${username}"
      "secret=${secret}"
      "mds_namespace=${mount1-filesystem}"
      "noatime"
      "_netdev"
      "acl"
    ];
  };

  fileSystems."${mount2-directory}" = {
    device = "${mon-ip}:/";
    fsType = "ceph";
    options = [
      "name=${username}"
      "secret=${secret}"
      "mds_namespace=${mount2-filesystem}"
      "noatime"
      "_netdev"
      "acl"
    ];
  };

  fileSystems."${mount3-directory}" = {
    device = "${mon-ip}:/";
    fsType = "ceph";
    options = [
      "name=${username}"
      "secret=${secret}"
      "mds_namespace=${mount3-filesystem}"
      "noatime"
      "_netdev"
      "acl"
    ];
  };

  fileSystems."${mount4-directory}" = {
    device = "${mon-ip}:/";
    fsType = "ceph";
    options = [
      "name=${username}"
      "secret=${secret}"
      "mds_namespace=${mount4-filesystem}"
      "noatime"
      "_netdev"
      "acl"
    ];
  };
}
