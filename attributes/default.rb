default['windows_cluster']['cluster_user'] = nil
default['windows_cluster']['cluster_password'] = nil
default['windows_cluster']['nodes'] = {
  'node1' => {
    'role' => 'primary',
    'ip' => '10.100.200.35',
    'hostname' => 'changeit',
  },
  'node2' => {
    'role' => 'failover',
    'ip' => 'a.b.c.d',
    'hostname' => 'changeit',
  },
}

default['windows_cluster']['storage'] = nil
