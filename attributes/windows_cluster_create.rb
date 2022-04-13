
default['windows_cluster'] = {
  'cluster' => {
    'cluster_ip' => 'IP Address of Cluster',
    'nodes' => [
      '10.100.200.182',
      '10.100.200.9',
    ],
    'disks' => {
      'quorum_disk' => 'quorum_disk name',
    },
    'cluster_user' => nil,
    'cluster_password' => nil,
  },
}

# default['windows_cluster']['storage'] = nil
