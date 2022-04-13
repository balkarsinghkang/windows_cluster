#
# Cookbook:: windows_cluster
# Recipe:: default
#
# Copyright:: 2022, The Authors, All Rights Reserved.

# Verify all servers are on same version of Windows Server

# Verify hardware and stoerge requirements

# Verify Storage Access to the server (optional)

# Verify the server is in the same AD domain

# include_recipe 'windows_cluster_disksetup'
# include_recipe 'windows_cluster_configure'

# Z27uMBF;6RSl*n*tL$N2RMpN?mPNLZ7Z
#  m!cziQyOFhuK@U;I2;vbJ3(XjBKlGCSp
# windows_failover_cluster_node 'name' do
#   cluster_ip node['windows_cluster']['cluster']['cluster_ip']
#   cluster_name               node['windows_cluster']['cluster'].keys
#   #    install_tools              true, false # default value: true
#   #    fs_witness                 String TODO: Verify this with Jean
#   quorum_disk                String
#   run_as_password            String # default value: node['windows_failover_cluster']['run_as_password']
#   run_as_user                String # default value: node['windows_failover_cluster']['run_as_user']
#   action                     Symbol # defaults to :create if not specified
# end
