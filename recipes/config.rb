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
if node.exist?('vault', 'tenant_id') && node.exist?('vault', 'client_id') && node.exist?('vault', 'client_secret')
  # Wrap in begin/rescue statement in case SPN credentials are expired
  begin
    # Build SPN credentials to access AKV
    spn = {
      'tenant_id' => node['vault']['tenant_id'],
      'client_id' => node['vault']['client_id'],
      'secret'    => node['vault']['client_secret'],
    }

    # Disable SSL verification if node is not in Azure
    ssl_verify = !node['cloud'].nil?
    powershell_script 'Create Cluster' do
      code <<-EOH
      New-Cluster -Name #{node['windows_cluster']['config']['cluster_name']} -Node #{node['hostname']} -StaticAddress #{node['windows_cluster']['config']['cluster_ip_superNAP']} -Force
      EOH
      # user node['windows_cluster']['config']['runas_user']
      user akv_get_secret(node['vault']['name'], node['activedirectory']['username_key'], spn, ssl_verify)
      # password node['windows_cluster']['config']['runas_password']
      password akv_get_secret(node['vault']['name'], node['activedirectory']['password_key'], spn, ssl_verify)
      flags '-ExecutionPolicy Unrestricted'
      sensitive false
      not_if { powershell_out("(Get-Cluster #{node['windows_cluster']['config']['cluster_name']}.#{node['domain']}).name").stdout.chomp == node['windows_cluster']['config']['cluster_name'] }
    end
  rescue
    message = 'Azure SPN is invalid or has expired, please update the node attribute if the server needs to be joined to the domain.'
    puts(message)
    Chef::Log.info(message)
  end
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

# powershell_script "Configuring File Share Witness: #{node['windows_cluster']['config']['fs_witness']}" do
#   code <<-EOH
#   Set-ClusterQuorum -NodeAndFileShareMajority \'#{node['windows_cluster']['config']['fs_witness']}\'
#   EOH
#   # user node['windows_cluster']['config']['runas_user']
#   user akv_get_secret(node['vault']['name'], node['activedirectory']['username_key'], spn, ssl_verify)
#   # @node['activedirectory']['domain_name']
#   # password node['windows_cluster']['config']['runas_password']
#   password akv_get_secret(node['vault']['name'], node['activedirectory']['password_key'], spn, ssl_verify)
#   flags '-ExecutionPolicy Unrestricted'
#   sensitive false
#   not_if { powershell_out('(Get-ClusterResource "File Share Witness").Name').stdout.chomp == 'File Share Witness' }
#   not_if { powershell_out('(Get-ClusterResource "File Share Witness" | Get-ClusterParameter SharePath).Value').stdout.chomp == node['windows_cluster']['config']['fs_witness'] }
# end
# TODO: Fileshare permission needs to be fixed in the above resource
# Check to see if the Azure credentials attributes are present

# powershell_script 'Adding Cluster Node' do
#   code <<-EOH
#   Add-ClusterNode -Cluster #{node['windows_cluster']['config']['cluster_name']} -Name #{node['hostname']}
#   EOH
#   # user node['windows_cluster']['config']['runas_user']
#   # password node['windows_cluster']['config']['runas_password']
#   flags '-ExecutionPolicy Unrestricted'
#   sensitive false
#   not_if { powershell_out('(Get-ClusterNode).Name').stdout.chomp == node['hostname'] }
#   only_if { powershell_out("(Get-Cluster #{node['windows_cluster']['config']['cluster_name']}.#{node['domain']}).name").stdout.chomp == node['windows_cluster']['config']['cluster_name'] }
#   # not_if { powershell_out('(Get-ClusterResource "File Share Witness" | Get-ClusterParameter SharePath).Value').stdout.chomp == node['windows_cluster']['config']['fs_witness']}
# end

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

# # Join the domain and add to a specific OU path
# execute "Join the #{node['activedirectory']['domain_name']} AD realm" do
#   command lazy { "echo '
#   #{akv_get_secret(node['vault']['name'], node['activedirectory']['password_key'], spn, ssl_verify)}
#   ' | /usr/sbin/realm join --computer-ou=#{node['activedirectory']['ou_path']} --user=
#   #{akv_get_secret(node['vault']['name'], node['activedirectory']['username_key'], spn, ssl_verify)[/[^@]+/]} #{node['activedirectory']['domain_name']}
#    --membership-software=adcli" }
#   not_if "sudo grep -i '#{node['activedirectory']['domain_name']}' /etc/sssd/sssd.conf"
#   sensitive true
# end
