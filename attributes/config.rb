
default['windows_cluster'] = {
    'config' => {
      'cluster_name' => 'cluster1',
      'cluster_ip_superNAP' => '10.100.200.250',
      'cluster_ip_dr' => 'IP Address of Cluster',
      'nodes' => [
        {
          'ip' => '10.100.200.182',
          'env' => 'superNAP',
        },
        {
          'ip' => '10.100.200.9',
          'env' => 'superNAP',
        },
        {
          'ip' => '10.100.200.158',
          'env' => 'DR',
        },
      ],
      'fs_witness' => '\\\\10.100.200.158\fs_witness_share',
      'runas_user' => 'cnb.customer.net\\cluster_admin',
      'runas_password' => 'wer987@#ASDF',
    },
  }

# default['windows_cluster']['storage'] = nil
