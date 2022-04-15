#
# Cookbook:: windows_cluster
# Recipe:: config
#
# Copyright:: 2022, The Authors, All Rights Reserved.

# TODO: Write code to create fs_witness share on DR server
# require 'pry'
# binding.pry

windows_feature 'Installing Failover-Clustering' do
  feature_name 'Failover-Clustering'
  management_tools true
  install_method :windows_feature_powershell
  action :install
  # May need to reboot after installing the service
end

powershell_script 'Create Cluster' do
  code <<-EOH
  New-Cluster -Name #{node['windows_cluster']['config']['cluster_name']} -Node #{node['hostname']} -StaticAddress #{node['windows_cluster']['config']['cluster_ip_superNAP']} -Force
  EOH
  # user node['windows_cluster']['config']['runas_user']
  # password node['windows_cluster']['config']['runas_password']
  flags '-ExecutionPolicy Unrestricted'
  sensitive false
  not_if { powershell_out("(Get-Cluster #{node['windows_cluster']['config']['cluster_name']}.#{node['domain']}).name").stdout.chomp == node['windows_cluster']['config']['cluster_name'] }
end
# TODO: following error generated when username and password are used. Permission issue needs to be fixed
# New-Cluster : There was an error adding node 'EC2AMAZ-TBO0THD' to the cluster
#     You do not have administrative privileges on the server 'EC2AMAZ-TBO0THD.cnb.customer.net'.
#     Requested registry access is not allowed.
# At line:1 char:2
# +  New-Cluster -Name cluster3 -Node EC2AMAZ-TBO0THD -StaticAddress 10.1 ...
# +  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     + CategoryInfo          : NotSpecified: (:) [New-Cluster], ClusterCmdletException
#     + FullyQualifiedErrorId : New-Cluster,Microsoft.FailoverClusters.PowerShell.NewClusterCommand

powershell_script "Configuring File Share Witness: #{node['windows_cluster']['config']['fs_witness']}" do
  code <<-EOH
  Set-ClusterQuorum -NodeAndFileShareMajority \'#{node['windows_cluster']['config']['fs_witness']}\'
  EOH
  # user node['windows_cluster']['config']['runas_user']
  # password node['windows_cluster']['config']['runas_password']
  flags '-ExecutionPolicy Unrestricted'
  sensitive false
  not_if { powershell_out('(Get-ClusterResource "File Share Witness").Name').stdout.chomp == 'File Share Witness' }
  not_if { powershell_out('(Get-ClusterResource "File Share Witness" | Get-ClusterParameter SharePath).Value').stdout.chomp == node['windows_cluster']['config']['fs_witness'] }
end
# TODO: Fileshare permission needs to be fixed in the above resource

powershell_script 'Adding Cluster Node' do
  code <<-EOH
  Add-ClusterNode -Cluster #{node['windows_cluster']['config']['cluster_name']} -Name #{node['hostname']}
  EOH
  # user node['windows_cluster']['config']['runas_user']
  # password node['windows_cluster']['config']['runas_password']
  flags '-ExecutionPolicy Unrestricted'
  sensitive false
  not_if { powershell_out('(Get-ClusterNode).Name').stdout.chomp == node['hostname'] }
  only_if { powershell_out("(Get-Cluster #{node['windows_cluster']['config']['cluster_name']}.#{node['domain']}).name").stdout.chomp == node['windows_cluster']['config']['cluster_name'] }
  # not_if { powershell_out('(Get-ClusterResource "File Share Witness" | Get-ClusterParameter SharePath).Value').stdout.chomp == node['windows_cluster']['config']['fs_witness']}
end

# windows_cluster_node node['windows_cluster']['config']['cluster_name'] do
#   cluster_ip node['windows_cluster']['config']['cluster_ip_superNAP']
#   cluster_name node['windows_cluster']['config']['cluster_name']
#   install_tools true
#   fs_witness                node['windows_cluster']['config']['fs_witness']
#   # quorum_disk                String
#   run_as_user               node['windows_cluster']['config']['runas_user']
#   run_as_password           node['windows_cluster']['config']['runas_password']
#   action :create
#   # only_if { fs_witness share exist }
#   # only_if { end is superNAP }
#   # only_if { Create computer objects permission exist on OU for runas user} #https://lokna.no/?p=1704
# end

# windows_cluster_node 'name' do
#   cluster_ip node['windows_cluster']['cluster']['cluster_ip']
#   cluster_name               node['windows_cluster']['cluster'].keys
#   #    install_tools              true, false # default value: true
#   fs_witness                 String
#   # quorum_disk                String
#   run_as_password            node['windows_cluster']['runas_user']
#   run_as_user                node['windows_cluster']['runas_password']
#   action                     :join
#   # only_if { fs_witness share exist }
#   # only_if { end is superNAP }
# end
